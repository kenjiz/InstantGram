import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instant_gram/state/user_info/providers/user_info_model_provider.dart';
import 'package:instant_gram/views/components/animations/small_error_animation_view.dart';
import 'package:instant_gram/views/components/rich_two_parts_text.dart';

import '../../../state/posts/models/post.dart';

class PostDisplayNameAndMessageView extends ConsumerWidget {
  final Post post;
  const PostDisplayNameAndMessageView({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoModelProvider(post.userId));
    return userInfo.when(data: (user) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: RichTwoPartsText(
          leftPart: user.displayName,
          rightPart: post.message,
        ),
      );
    }, loading: () {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }, error: (_, __) {
      return const SmallErrorAnimationView();
    });
  }
}
