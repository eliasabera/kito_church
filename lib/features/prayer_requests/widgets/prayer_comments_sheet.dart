import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/prayer_requests/models/prayer_request.dart';
import 'package:kitoapp/features/profile/data/profile_data.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/prayer_requests_store_provider.dart';
import 'package:kitoapp/shared/widgets/profile_store_provider.dart';

void showPrayerCommentsSheet(
  BuildContext context, {
  required PrayerRequest request,
  required UserRole role,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => PrayerCommentsSheet(request: request, role: role),
  );
}

class PrayerCommentsSheet extends StatefulWidget {
  const PrayerCommentsSheet({
    super.key,
    required this.request,
    required this.role,
  });

  final PrayerRequest request;
  final UserRole role;

  @override
  State<PrayerCommentsSheet> createState() => _PrayerCommentsSheetState();
}

class _PrayerCommentsSheetState extends State<PrayerCommentsSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final profile = ProfileStoreProvider.of(context).profile ??
        ProfileData.forRole(widget.role);

    try {
      await PrayerRequestsStoreProvider.of(context).addComment(
        requestId: widget.request.id,
        authorName: profile.fullName,
        authorRole: widget.role,
        message: text,
      );
      _controller.clear();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).commentFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = PrayerRequestsStoreProvider.of(context);
    final locale = Localizations.localeOf(context).toString();
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final matches =
            store.requests.where((r) => r.id == widget.request.id).toList();
        if (matches.isEmpty) return const SizedBox.shrink();
        final request = matches.first;

        return Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.65,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.text.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.comments,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              Navigator.of(context, rootNavigator: true).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      request.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.6),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: request.comments.isEmpty
                        ? Center(
                            child: Text(
                              l10n.noComments,
                              style: TextStyle(
                                color: AppColors.text.withValues(alpha: 0.45),
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                            itemCount: request.comments.length,
                            itemBuilder: (context, index) {
                              final comment = request.comments[index];
                              final time =
                                  DateFormat.MMMd(locale).add_jm().format(
                                        comment.date,
                                      );
                              return _CommentBubble(
                                comment: comment,
                                time: time,
                              );
                            },
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border(
                        top: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: l10n.addCommentHint,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            onSubmitted: (_) => _submitComment(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _submitComment,
                          icon: const Icon(Icons.send, size: 18),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.background,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _CommentBubble extends StatelessWidget {
  const _CommentBubble({required this.comment, required this.time});

  final PrayerComment comment;
  final String time;

  @override
  Widget build(BuildContext context) {
    final isTeacher = comment.authorRole == UserRole.teacher;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isTeacher
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.primary.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  comment.authorName,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  time,
                  style: TextStyle(
                    color: AppColors.text.withValues(alpha: 0.4),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              comment.message,
              style: TextStyle(
                color: AppColors.text.withValues(alpha: 0.8),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
