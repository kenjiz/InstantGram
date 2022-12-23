// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable;

import 'package:instant_gram/state/comments/typedef/comment_id.dart';
import 'package:instant_gram/state/constants/firebase_field_name.dart';

import '../../posts/typedefs/post_id.dart';
import '../../posts/typedefs/user_id.dart';

@immutable
class Comment {
  final CommentId id;
  final String comment;
  final DateTime createdAt;
  final UserId fromUserId;
  final PostId fromPostId;

  Comment(
    Map<String, dynamic> json, {
    required this.id,
  })  : comment = json[FirebaseFieldName.comment],
        createdAt = (json[FirebaseFieldName.createdAt] as Timestamp).toDate(),
        fromUserId = json[FirebaseFieldName.userId],
        fromPostId = json[FirebaseFieldName.postId];

  @override
  bool operator ==(covariant Comment other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.comment == comment &&
        other.createdAt == createdAt &&
        other.fromUserId == fromUserId &&
        other.fromPostId == fromPostId;
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        comment,
        createdAt,
        fromPostId,
        fromUserId,
      ]);
}
