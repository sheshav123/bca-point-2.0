import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/pdf_annotation_model.dart';

class AnnotationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save annotation
  Future<void> saveAnnotation(PdfAnnotation annotation) async {
    try {
      final data = annotation.toMap();
      debugPrint('Annotation data to save: $data');
      
      await _firestore
          .collection('annotations')
          .doc(annotation.id)
          .set(data);
      
      debugPrint('Annotation saved to Firestore successfully');
    } catch (e) {
      debugPrint('Error saving annotation to Firestore: $e');
      rethrow;
    }
  }

  // Get annotations for a material
  Stream<List<PdfAnnotation>> getAnnotations(String materialId, String userId) {
    return _firestore
        .collection('annotations')
        .where('materialId', isEqualTo: materialId)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PdfAnnotation.fromMap(doc.data()))
          .toList();
    });
  }

  // Delete annotation
  Future<void> deleteAnnotation(String annotationId) async {
    try {
      await _firestore.collection('annotations').doc(annotationId).delete();
    } catch (e) {
      debugPrint('Error deleting annotation: $e');
      rethrow;
    }
  }

  // Delete all annotations for a material
  Future<void> deleteAllAnnotations(String materialId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection('annotations')
          .where('materialId', isEqualTo: materialId)
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Error deleting annotations: $e');
      rethrow;
    }
  }
}
