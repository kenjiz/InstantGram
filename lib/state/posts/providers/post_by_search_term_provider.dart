import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instant_gram/state/constants/firebase_collection_name.dart';
import 'package:instant_gram/state/constants/firebase_field_name.dart';

import '../models/post.dart';
import '../typedefs/search_term.dart';

final postBySearchTermProvider = StreamProvider.autoDispose
    .family<Iterable<Post>, SearchTerm>((ref, searchTerm) {
  final controller = StreamController<Iterable<Post>>();

  final sub = FirebaseFirestore.instance
      .collection(FirebaseCollectionName.posts)
      .orderBy(FirebaseFieldName.createdAt, descending: true)
      .snapshots()
      .listen((snapshot) {
    final searchedPost = snapshot.docs
        .where((docs) => !docs.metadata.hasPendingWrites)
        .map(
          (doc) => Post(
            json: doc.data(),
            postId: doc.id,
          ),
        )
        .where(
          (post) => post.message.toLowerCase() == searchTerm.toLowerCase(),
        );

    controller.sink.add(searchedPost);
  });

  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });

  return controller.stream;
});
