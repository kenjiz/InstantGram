import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../state/likes/providers/post_likes_count_provider.dart';
import '../../state/posts/models/post.dart';
import 'animations/loading_animation_view.dart';
import 'animations/small_error_animation_view.dart';
import 'constants/strings.dart';

class LikesCountView extends ConsumerWidget {
  final Post post;
  const LikesCountView({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likesCount = ref.watch(
      postLikesCountProvider(post.postId),
    );

    return likesCount.when(
      data: (count) {
        final personOrPeople = count == 1 ? Strings.person : Strings.people;
        return Text('$count $personOrPeople ${Strings.likedThis}');
      },
      error: (_, __) => const SmallErrorAnimationView(),
      loading: () => const LoadingAnimationView(),
    );
  }
}
