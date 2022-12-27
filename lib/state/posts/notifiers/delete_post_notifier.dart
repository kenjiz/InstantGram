import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instant_gram/state/constants/firebase_collection_name.dart';
import 'package:instant_gram/state/constants/firebase_field_name.dart';
import 'package:instant_gram/state/image_upload/extensions/get_collection_name_from_file_types.dart';

import '../../image_upload/typedefs/is_loading.dart';
import '../models/post.dart';

class DeletePostNotifier extends StateNotifier<IsLoading> {
  DeletePostNotifier() : super(false);

  set isLoading(value) => state = value;

  Future<bool> deletePost({required Post post}) async {
    isLoading = true;
    try {
      FirebaseFirestore.instance.runTransaction<bool>(
        (transaction) async {
          try {
            // delete post's thumbnail
            await FirebaseStorage.instance
                .ref()
                .child(post.userId)
                .child(FirebaseCollectionName.thumbnails)
                .child(post.thumbnailStorageId)
                .delete();

            // delete posts' original file (video or image)
            await FirebaseStorage.instance
                .ref()
                .child(post.userId)
                .child(post.fileType.getCollectionName())
                .child(post.originalFileStorageId)
                .delete();

            final commentsQuery = await FirebaseFirestore.instance
                .collection(FirebaseCollectionName.comments)
                .where(FirebaseFieldName.postId, isEqualTo: post.postId)
                .get();

            for (final doc in commentsQuery.docs) {
              transaction.delete(doc.reference);
            }

            final likesQuery = await FirebaseFirestore.instance
                .collection(FirebaseCollectionName.likes)
                .where(FirebaseFieldName.postId, isEqualTo: post.postId)
                .get();

            for (final doc in likesQuery.docs) {
              transaction.delete(doc.reference);
            }

            // finally delete the post itself
            final postQuery = await FirebaseFirestore.instance
                .collection(FirebaseCollectionName.posts)
                .where(FieldPath.documentId, isEqualTo: post.postId)
                .limit(1)
                .get();

            for (final doc in postQuery.docs) {
              transaction.delete(doc.reference);
            }
          } catch (e) {
            print(e);
            rethrow;
          }

          return true;
        },
        maxAttempts: 3,
        timeout: const Duration(seconds: 20),
      ).onError((error, stackTrace) {
        print(error);
        print(stackTrace);
        return false;
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    } finally {
      isLoading = false;
    }
  }
}
