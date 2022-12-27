import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instant_gram/state/comments/extensions/comment_sorting_by_request.dart';
import 'package:instant_gram/state/constants/firebase_collection_name.dart';
import 'package:instant_gram/state/constants/firebase_field_name.dart';

import '../../comments/models/comment.dart';
import '../../comments/models/post_comment_request.dart';
import '../../comments/models/post_with_comments.dart';
import '../models/post.dart';

final specificPostWithCommentsProvider = StreamProvider.autoDispose
    .family<PostWithComments, RequestForPostAndComments>((ref, request) {
  final controller = StreamController<PostWithComments>();

  Post? post;
  Iterable<Comment>? comments;

  void notify() {
    final localPost = post;
    if (localPost == null) return;
    final outputComments = (comments ?? []).applySortingFrom(request);

    final result = PostWithComments(
      post: localPost,
      comments: outputComments,
    );
    controller.sink.add(result);
  }

  final postSub = FirebaseFirestore.instance
      .collection(FirebaseCollectionName.posts)
      .where(
        FieldPath.documentId,
        isEqualTo: request.postId,
      )
      .limit(1)
      .snapshots()
      .listen((snapshot) {
    if (snapshot.docs.isEmpty) {
      post = null;
      comments = null;
      notify();
      return;
    }

    final doc = snapshot.docs.first;
    if (doc.metadata.hasPendingWrites) return;
    post = Post(
      json: doc.data(),
      postId: doc.id,
    );
    notify();
  });

  final commentsQuery = FirebaseFirestore.instance
      .collection(FirebaseCollectionName.comments)
      .where(
        FirebaseFieldName.postId,
        isEqualTo: request.postId,
      )
      .orderBy(
        FirebaseFieldName.createdAt,
        descending: true,
      );

  final limitedCommentsQuery = request.limit != null
      ? commentsQuery.limit(request.limit!)
      : commentsQuery;

  final commentsSub = limitedCommentsQuery.snapshots().listen((snapshot) {
    comments = snapshot.docs
        .where((doc) => !doc.metadata.hasPendingWrites)
        .map(
          (doc) => Comment(
            doc.data(),
            id: doc.id,
          ),
        )
        .toList();
    notify();
  });

  ref.onDispose(() {
    postSub.cancel();
    commentsSub.cancel();
    controller.close();
  });

  return controller.stream;
});
