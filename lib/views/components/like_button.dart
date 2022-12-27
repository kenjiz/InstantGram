import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instant_gram/state/auth/providers/user_id_provider.dart';
import 'package:instant_gram/state/likes/models/like_dislike_request.dart';
import 'package:instant_gram/state/likes/providers/has_liked_post_provider.dart';
import 'package:instant_gram/state/likes/providers/like_dislike_post_provider.dart';
import 'package:instant_gram/views/components/animations/small_error_animation_view.dart';

import '../../state/posts/typedefs/post_id.dart';

class LikeButton extends ConsumerWidget {
  final PostId postId;
  const LikeButton({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasLiked = ref.watch(hasLikedPostProvider(postId));

    return hasLiked.when(data: (hasLiked) {
      return IconButton(
        icon: FaIcon(
          hasLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
        ),
        onPressed: () {
          final userId = ref.read(userIdProvider);
          if (userId == null) {
            return;
          }
          final likeDislikeRequest = LikeDislikeRequest(
            postId: postId,
            likeBy: userId,
          );

          ref.read(likeDislikePostProvider(likeDislikeRequest));
        },
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
