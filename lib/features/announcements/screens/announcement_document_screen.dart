import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/announcements/services/announcement_document_storage.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';
import 'package:pdfx/pdfx.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AnnouncementDocumentScreen extends StatefulWidget {
  const AnnouncementDocumentScreen({
    super.key,
    required this.url,
    required this.title,
    required this.fileName,
  });

  final String url;
  final String title;
  final String fileName;

  @override
  State<AnnouncementDocumentScreen> createState() =>
      _AnnouncementDocumentScreenState();
}

class _AnnouncementDocumentScreenState extends State<AnnouncementDocumentScreen> {
  bool _isLoading = true;
  String? _error;
  PdfControllerPinch? _pdfController;
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  Future<void> _loadDocument() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _pdfController?.dispose();
      _pdfController = null;
      _webViewController = null;
    });

    try {
      if (AnnouncementDocumentStorage.isPdf(widget.fileName) ||
          AnnouncementDocumentStorage.isPdf(widget.url)) {
        final response = await http.get(Uri.parse(widget.url));
        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}');
        }

        final controller = PdfControllerPinch(
          document: PdfDocument.openData(response.bodyBytes),
        );

        if (!mounted) {
          controller.dispose();
          return;
        }

        setState(() {
          _pdfController = controller;
          _isLoading = false;
        });
        return;
      }

      final viewerUrl = _embeddedViewerUrl(widget.url);
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(AppColors.background)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              if (mounted) setState(() => _isLoading = false);
            },
            onWebResourceError: (error) {
              if (!mounted) return;
              setState(() {
                _error = error.description;
                _isLoading = false;
              });
            },
          ),
        )
        ..loadRequest(Uri.parse(viewerUrl));

      if (!mounted) return;
      setState(() {
        _webViewController = controller;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  String _embeddedViewerUrl(String documentUrl) {
    return 'https://docs.google.com/gviewer?embedded=true&url=${Uri.encodeComponent(documentUrl)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: widget.title,
      body: Stack(
        children: [
          if (_pdfController != null)
            PdfViewPinch(
              controller: _pdfController!,
              padding: 10,
              scrollDirection: Axis.vertical,
            )
          else if (_webViewController != null)
            WebViewWidget(controller: _webViewController!),
          if (_isLoading)
            const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          if (_error != null && !_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.documentOpenFailed,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _loadDocument,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.background,
                      ),
                      child: Text(l10n.tryAgain),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
