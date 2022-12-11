import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instant_gram/views/components/post/posts_grid_view.dart';

import '../../../state/posts/providers/user_posts_providers.dart';
import '../../components/animations/empty_contents_with_text_animation_view.dart';
import '../../components/animations/error_animation_view.dart';
import '../../components/animations/loading_animation_view.dart';
import '../../constants/strings.dart';

class UserPostsView extends ConsumerWidget {
  const UserPostsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(userPostsProvider);
    return RefreshIndicator(
      onRefresh: () => ref.refresh(userPostsProvider.future),
      child: posts.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const EmptyContentsWithTextAnimationView(
                text: Strings.youHaveNoPosts);
          }
          return PostGridView(posts: posts);
        },
        loading: () {
          return const LoadingAnimationView();
        },
        error: (error, stackTrace) {
          return const ErrorAnimationView();
        },
      ),
    );
  }
}
