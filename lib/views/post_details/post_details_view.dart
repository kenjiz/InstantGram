import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instant_gram/enums/date_sorting.dart';
import 'package:instant_gram/state/comments/models/post_comment_request.dart';
import 'package:instant_gram/state/posts/providers/can_current_user_delete_post_provider.dart';
import 'package:instant_gram/state/posts/providers/delete_post_provider.dart';
import 'package:instant_gram/state/posts/providers/specific_post_with_comments_provider.dart';
import 'package:instant_gram/views/components/animations/error_animation_view.dart';
import 'package:instant_gram/views/components/animations/loading_animation_view.dart';
import 'package:instant_gram/views/components/animations/small_error_animation_view.dart';
import 'package:instant_gram/views/components/comment/compact_comment_column.dart';
import 'package:instant_gram/views/components/dialogs/alert_dialog_model.dart';
import 'package:instant_gram/views/components/dialogs/delete_dialog.dart';
import 'package:instant_gram/views/components/like_button.dart';
import 'package:instant_gram/views/components/likes_count_view.dart';
import 'package:instant_gram/views/components/post/post_date_view.dart';
import 'package:instant_gram/views/components/post/post_display_name_and_message_view.dart';
import 'package:instant_gram/views/components/post/post_image_or_video_view.dart';
import 'package:instant_gram/views/post_comments/post_comments_view.dart';
import 'package:share_plus/share_plus.dart';

import '../../state/posts/models/post.dart';
import '../constants/strings.dart';

class PostDetailsView extends ConsumerStatefulWidget {
  final Post post;
  const PostDetailsView({
    super.key,
    required this.post,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PostDetailsViewState();
}

class _PostDetailsViewState extends ConsumerState<PostDetailsView> {
  @override
  Widget build(BuildContext context) {
    final request = RequestForPostAndComments(
      postId: widget.post.postId,
      limit: 3,
      sortByCreatedAt: true,
      dateSorting: DateSorting.oldestOnTop,
    );

    // get the actual post together with its comments
    final postWithComments = ref.watch(
      specificPostWithCommentsProvider(request),
    );

    // can we delete this post
    final canDeletePost = ref.watch(
      canCurrentUserDeletePostProvider(widget.post),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.postDetails),
        actions: [
          // share button is always present
          postWithComments.when(
            data: (postWithComments) {
              return IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  final url = postWithComments.post.fileUrl;
                  Share.share(
                    url,
                    subject: Strings.checkOutThisPost,
                  );
                },
              );
            },
            error: (_, __) => const SmallErrorAnimationView(),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          // can user delete post
          if (canDeletePost.value ?? false)
            IconButton(
              icon: const Icon(
                Icons.delete,
              ),
              onPressed: () async {
                final shouldDeletePost =
                    await DeleteDialog(titleOfObjectToDelete: Strings.post)
                        .present(context)
                        .then((value) => value ?? false);

                if (shouldDeletePost) {
                  // delete the post now
                  ref.read(deletePostProvider.notifier).deletePost(
                        post: widget.post,
                      );
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
        ],
      ),
      body: postWithComments.when(
          data: (postWithComments) {
            final postId = postWithComments.post.postId;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PostImageOrVideoView(post: postWithComments.post),
                  // like and comment button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // like button if the post allows liking it
                      if (postWithComments.post.allowLikes)
                        LikeButton(postId: postId),

                      // comment button if the post allows it
                      if (postWithComments.post.allowComments)
                        IconButton(
                          icon: const Icon(Icons.mode_comment_outlined),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    PostCommentView(postId: postId),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  PostDisplayNameAndMessageView(post: postWithComments.post),
                  PostDateView(dateTime: postWithComments.post.createdAt),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Divider(
                      color: Colors.white70,
                    ),
                  ),
                  CompactCommentColumn(
                    comments: postWithComments.comments,
                  ),
                  // display like counts
                  if (postWithComments.post.allowLikes)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          LikesCountView(
                            post: postWithComments.post,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
          error: (_, __) => const ErrorAnimationView(),
          loading: () => const LoadingAnimationView()),
    );
  }
}
