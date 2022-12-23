import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instant_gram/state/constants/firebase_collection_name.dart';
import 'package:instant_gram/state/constants/firebase_field_name.dart';

import '../../posts/typedefs/user_id.dart';
import '../models/user_info_model.dart';

final userInfoModelProvider = StreamProvider.autoDispose
    .family<UserInfoModel, UserId>((ref, UserId userId) {
  final controller = StreamController<UserInfoModel>();

  final sub = FirebaseFirestore.instance
      .collection(FirebaseCollectionName.users)
      .where(
        FirebaseFieldName.userId,
        isEqualTo: userId,
      )
      .limit(1)
      .snapshots()
      .listen((snaps) {
    if (snaps.docs.isNotEmpty) {
      final data = snaps.docs.first.data();
      controller.add(
        UserInfoModel.fromJson(
          data,
          userId: userId,
        ),
      );
    }
  });

  ref.onDispose(() {
    controller.close();
    sub.cancel();
  });
  return controller.stream;
});
