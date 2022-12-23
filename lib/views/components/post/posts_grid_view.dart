import 'package:flutter/material.dart';

import '../../../state/posts/models/post.dart';
import '../../post_comments/post_comments_view.dart';
import 'post_thumbnail_view.dart';

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
              // TODO remove this
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PostCommentView(
                    postId: post.postId,
                  ),
                ),
              );
              // TODO navigate to post details view
            },
          );
        },
        itemCount: posts.length,
      ),
    );
  }
}
