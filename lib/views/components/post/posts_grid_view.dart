import 'package:flutter/material.dart';
import 'package:instant_gram/views/components/post/post_thumbnail_view.dart';

import '../../../state/posts/models/post.dart';

class PostGridView extends StatelessWidget {
  final Iterable<Post> posts;
  const PostGridView({
    Key? key,
    required this.posts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final post = posts.elementAt(index);
          return PostThumbnailView(
            post: post,
            onTapped: () {
              // TODO navigate to post details view
            },
          );
        },
        itemCount: posts.length,
      ),
    );
  }
}
