import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resell/UIPart/android_ios/model/item.dart';

final itemStreamProvider =
    StreamProvider.family<Item, DocumentReference<Map<String, dynamic>>>(
  (ref, documentReference) {
    return documentReference.snapshots().map(
      (snapshot) {
        final data = snapshot.data();
        if (data == null) {
          print("data is null");
          throw Exception('Document does not exist');
        }
        Timestamp? timeStamp = data['createdAt'];
        timeStamp ??= Timestamp.fromMicrosecondsSinceEpoch(
            DateTime.now().millisecondsSinceEpoch);
        final item = Item.fromJson(
          data,
          snapshot,
          snapshot.reference,
        );
        print('data is parsed');
        return item; // Parse the data into an Item object
      },
    );
  },
);
