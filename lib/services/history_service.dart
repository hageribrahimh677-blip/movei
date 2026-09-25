import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie.dart';

/// بيدير حقل `history` جوه users/{uid} في Firestore.
class HistoryService {
  static const int maxHistoryItems = 50;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid);
  }

  Future<void> addToHistory(Movie movie) async {
    final docRef = _userDoc;
    if (docRef == null) return;

    final snapshot = await docRef.get();
    final data = snapshot.data();

    List<Map<String, dynamic>> history =
    (data?['history'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    history.removeWhere((item) => item['id'] == movie.id);
    history.insert(0, movie.toHistorySnapshot());

    if (history.length > maxHistoryItems) {
      history = history.sublist(0, maxHistoryItems);
    }

    await docRef.set({'history': history}, SetOptions(merge: true));
  }

  Future<void> removeFromHistory(int movieId) async {
    final docRef = _userDoc;
    if (docRef == null) return;

    final snapshot = await docRef.get();
    final data = snapshot.data();

    final history = (data?['history'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
      ..removeWhere((item) => item['id'] == movieId);

    await docRef.set({'history': history}, SetOptions(merge: true));
  }

  Future<void> clearHistory() async {
    final docRef = _userDoc;
    if (docRef == null) return;
    await docRef.set({'history': []}, SetOptions(merge: true));
  }
}