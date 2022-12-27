import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instant_gram/state/user_info/providers/user_info_model_provider.dart';
import 'package:instant_gram/views/components/animations/small_error_animation_view.dart';
import 'package:instant_gram/views/components/rich_two_parts_text.dart';

import '../../../state/comments/models/comment.dart';

class CompactCommentTile extends ConsumerWidget {
  final Comment comment;
  const CompactCommentTile({
    super.key,
    required this.comment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(
      userInfoModelProvider(comment.fromUserId),
    );
    return user.when(data: (user) {
      return RichTwoPartsText(
        leftPart: user.displayName,
        rightPart: comment.comment,
      );
    }, error: (_, __) {
      return const SmallErrorAnimationView();
    }, loading: () {
      return const Center(
        child: CircularProgressIndicator(),
      );
    });
  }
}
