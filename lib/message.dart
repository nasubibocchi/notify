import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
    Message (DocumentSnapshot doc) {
        Map<String, dynamic> extractdata = doc.data() as Map<String, dynamic>;
        this.documentReference = doc.reference;
        this.fcmToken = extractdata['fcmToken'];
        final Timestamp timestamp = extractdata['postAt'];
        this.postAt = timestamp.toDate();
    }
    late String fcmToken;
    late String title;
    late DateTime postAt;
    late DocumentReference documentReference;
}