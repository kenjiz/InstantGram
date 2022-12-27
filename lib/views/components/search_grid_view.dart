import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instant_gram/views/components/post/sliver_posts_grid_view.dart';

import '../../state/posts/providers/post_by_search_term_provider.dart';
import '../constants/strings.dart';
import 'animations/data_not_found_animation_view.dart';
import 'animations/empty_contents_with_text_animation_view.dart';
import 'animations/error_animation_view.dart';
import 'animations/loading_animation_view.dart';

class SearchGridView extends ConsumerWidget {
  final String searchTerm;
  const SearchGridView({
    super.key,
    required this.searchTerm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (searchTerm.isEmpty) {
      return const SliverToBoxAdapter(
        child: EmptyContentsWithTextAnimationView(
          text: Strings.enterYourSearchTerm,
        ),
      );
    }

    final posts = ref.watch(postBySearchTermProvider(searchTerm));

    return posts.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const SliverToBoxAdapter(
            child: DataNotFoundAnimationView(),
          );
        }
        return SliverPostsGridView(posts: posts);
      },
      error: (_, __) => const SliverToBoxAdapter(
        child: ErrorAnimationView(),
      ),
      loading: () => const SliverToBoxAdapter(
        child: LoadingAnimationView(),
      ),
    );
  }
}
