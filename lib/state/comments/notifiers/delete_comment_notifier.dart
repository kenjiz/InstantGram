import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/firebase_collection_name.dart';
import '../../image_upload/typedefs/is_loading.dart';
import '../typedef/comment_id.dart';

class DeleteCommentNotifier extends StateNotifier<IsLoading> {
  DeleteCommentNotifier() : super(false);

  set isLoading(value) => state = value;

  Future<bool> deleteComment({required CommentId commentId}) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.comments)
          .where(FieldPath.documentId, isEqualTo: commentId)
          .limit(1)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
    }
  }
}
