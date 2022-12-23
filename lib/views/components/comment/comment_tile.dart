import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instant_gram/state/auth/providers/user_id_provider.dart';
import 'package:instant_gram/state/comments/providers/delete_comment_provider.dart';
import 'package:instant_gram/state/user_info/providers/user_info_model_provider.dart';
import 'package:instant_gram/views/components/animations/small_error_animation_view.dart';

import '../../../state/comments/models/comment.dart';
import '../../constants/strings.dart';
import '../dialogs/alert_dialog_model.dart';
import '../dialogs/delete_dialog.dart';

class CommentTile extends ConsumerWidget {
  final Comment comment;

  const CommentTile({
    super.key,
    required this.comment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoModelProvider(comment.fromUserId));

    return userInfo.when(data: (user) {
      final currentUser = ref.read(userIdProvider);
      return ListTile(
        title: Text(user.displayName),
        subtitle: Text(comment.comment),
        trailing: currentUser == comment.fromUserId
            ? IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final shouldDeleteComment = await showDeleteDialog(context);
                  if (shouldDeleteComment) {
                    ref
                        .read(deleteCommentProvider.notifier)
                        .deleteComment(commentId: comment.id);
                  }
                },
              )
            : null,
      );
    }, loading: () {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }, error: (_, __) {
      return const SmallErrorAnimationView();
    });
  }

  Future<bool> showDeleteDialog(BuildContext context) async {
    return DeleteDialog(titleOfObjectToDelete: Strings.comments)
        .present(context)
        .then((value) => value ?? false);
  }
}
