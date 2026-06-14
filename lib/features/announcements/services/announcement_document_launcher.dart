import 'package:flutter/material.dart';
import 'package:kitoapp/features/announcements/models/announcement_item.dart';
import 'package:kitoapp/features/announcements/screens/announcement_document_screen.dart';
import 'package:kitoapp/features/announcements/services/announcement_document_storage.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_toast.dart';

class AnnouncementDocumentLauncher {
  AnnouncementDocumentLauncher._();

  static Future<bool> openDocument(
    BuildContext context,
    AnnouncementItem item,
  ) async {
    final url = item.documentUrl;
    if (url == null || url.isEmpty) return false;

    final l10n = AppLocalizations.of(context);
    final fileName = item.documentName ?? url;

    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (context) => AnnouncementDocumentScreen(
            url: url,
            title: item.documentName ?? l10n.readDocument,
            fileName: fileName,
          ),
        ),
      );
      return true;
    } catch (_) {
      if (context.mounted) {
        AppToast.showError(context, l10n.documentOpenFailed);
      }
      return false;
    }
  }

  static IconData iconFor(AnnouncementItem item) {
    final label = item.documentName ?? item.documentUrl ?? '';
    return AnnouncementDocumentStorage.iconFor(label);
  }
}
