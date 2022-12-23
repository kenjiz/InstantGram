import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../state/auth/providers/user_id_provider.dart';
import '../../state/comments/models/post_comment_request.dart';
import '../../state/comments/providers/post_comment_provider.dart';
import '../../state/comments/providers/send_comment_provider.dart';
import '../../state/posts/typedefs/post_id.dart';
import '../components/animations/empty_contents_with_text_animation_view.dart';
import '../components/animations/error_animation_view.dart';
import '../components/animations/loading_animation_view.dart';
import '../components/comment/comment_tile.dart';
import '../constants/strings.dart';
import '../extensions/dismiss_keyboard.dart';

class PostCommentView extends HookConsumerWidget {
  final PostId postId;
  const PostCommentView({
    super.key,
    required this.postId,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentController = useTextEditingController();
    final hasText = useState(false);
    final request = useState(RequestForPostAndComments(postId: postId));
    final comments = ref.watch(postCommentProvider(request.value));

    useEffect(() {
      commentController.addListener(() {
        hasText.value = commentController.text.isNotEmpty;
      });
      return () {};
    }, [commentController]);

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.comments),
        actions: [
          IconButton(
            onPressed: hasText.value
                ? () {
                    _submitCommentWithController(commentController, ref);
                  }
                : null,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
      body: SafeArea(
        child: Flex(
          direction: Axis.vertical,
          children: [
            Expanded(
              flex: 4,
              child: comments.when(
                data: (comments) {
                  if (comments.isEmpty) {
                    return const SingleChildScrollView(
                      child: EmptyContentsWithTextAnimationView(
                        text: Strings.noCommentsYet,
                      ),
                    );
                  }

                  return RefreshIndicator(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        final comment = comments.elementAt(index);
                        return CommentTile(comment: comment);
                      },
                      itemCount: comments.length,
                    ),
                    onRefresh: () {
                      ref.refresh(postCommentProvider(request.value));
                      return Future.delayed(
                        const Duration(seconds: 1),
                      );
                    },
                  );
                },
                loading: () {
                  return const LoadingAnimationView();
                },
                error: (_, __) {
                  return const ErrorAnimationView();
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    right: 8.0,
                  ),
                  child: TextField(
                    controller: commentController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (comment) {
                      if (comment.isNotEmpty) {
                        _submitCommentWithController(commentController, ref);
                      }
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: Strings.writeYourCommentHere,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitCommentWithController(
    TextEditingController controller,
    WidgetRef ref,
  ) async {
    final userId = ref.read(userIdProvider);
    if (userId == null) return;
    final isSent = await ref.read(sendCommentProvider.notifier).sendComment(
          fromUserId: userId,
          comment: controller.text,
          onPostId: postId,
        );

    if (isSent) {
      controller.clear();
      dismissKeyboard();
    }
  }
}
