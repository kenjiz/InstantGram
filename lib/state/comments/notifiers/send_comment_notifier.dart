import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instant_gram/state/comments/models/comment_payload.dart';
import 'package:instant_gram/state/constants/firebase_collection_name.dart';

import '../../image_upload/typedefs/is_loading.dart';
import '../../posts/typedefs/post_id.dart';
import '../../posts/typedefs/user_id.dart';

class SendCommentNotifier extends StateNotifier<IsLoading> {
  SendCommentNotifier() : super(false);

  set isLoading(value) => state = value;

  Future<bool> sendComment({
    required UserId fromUserId,
    required String comment,
    required PostId onPostId,
  }) async {
    isLoading = true;

    try {
      final payload = CommentPayload(
        fromUserId: fromUserId,
        onPostId: onPostId,
        comment: comment,
      );

      FirebaseFirestore.instance
          .collection(FirebaseCollectionName.comments)
          .add(payload);
      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
    }
  }
}
