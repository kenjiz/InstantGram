import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/firebase_collection_name.dart';
import '../../constants/firebase_field_name.dart';
import '../models/like.dart';
import '../models/like_dislike_request.dart';

final likeDislikePostProvider = FutureProvider.autoDispose
    .family<bool, LikeDislikeRequest>((ref, request) async {
  final query = await FirebaseFirestore.instance
      .collection(FirebaseCollectionName.likes)
      .where(
        FirebaseFieldName.postId,
        isEqualTo: request.postId,
      )
      .where(
        FirebaseFieldName.userId,
        isEqualTo: request.likeBy,
      )
      .get();

  // first see if the user liked the post already or not
  final hasLiked = query.docs.isNotEmpty;
  if (hasLiked) {
    // delete the like
    try {
      for (final doc in query.docs) {
        await doc.reference.delete();
      }
      return true;
    } catch (_) {
      return false;
    }
  } else {
    final like = Like(
      postId: request.postId,
      likedBy: request.likeBy,
      date: DateTime.now(),
    );
    try {
      await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.likes)
          .add(like);
      return true;
    } catch (_) {
      return false;
    }
  }
});
