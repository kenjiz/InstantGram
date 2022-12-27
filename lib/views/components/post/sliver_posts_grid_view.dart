import 'package:flutter/material.dart';

import '../../../state/posts/models/post.dart';
import '../../post_details/post_details_view.dart';
import 'post_thumbnail_view.dart';

class SliverPostsGridView extends StatelessWidget {
  final Iterable<Post> posts;
  const SliverPostsGridView({
    super.key,
    required this.posts,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final post = posts.elementAt(index);
          return PostThumbnailView(
              post: post,
              onTapped: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailsView(post: post),
                  ),
                );
              });
        },
        childCount: posts.length,
      ),
    );
  }
}
