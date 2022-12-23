import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instant_gram/state/constants/firebase_collection_name.dart';
import 'package:instant_gram/state/constants/firebase_field_name.dart';

import '../../posts/typedefs/post_id.dart';

final postLikesCountProvider =
    StreamProvider.autoDispose.family<int, PostId>((ref, postId) {
  final controller = StreamController<int>.broadcast();

  controller.onListen = () {
    controller.sink.add(0);
  };

  final sub = FirebaseFirestore.instance
      .collection(FirebaseCollectionName.likes)
      .where(FirebaseFieldName.postId, isEqualTo: postId)
      .snapshots()
      .listen(
    (snapshot) {
      controller.sink.add(
        snapshot.docs.length,
      );
    },
  );

  ref.onDispose(() {
    controller.close();
    sub.cancel();
  });

  return controller.stream;
});
