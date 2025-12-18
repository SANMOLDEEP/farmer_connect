import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../models/community_model.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get current user name
  Future<String> get currentUserName async {
    final user = _auth.currentUser;
    if (user == null) return 'Anonymous';
    
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc.data()?['name'] ?? user.displayName ?? 'Anonymous';
    } catch (e) {
      return user.displayName ?? 'Anonymous';
    }
  }

  // ========== POSTS ==========
  
  Future<String> createPost(CommunityPost post) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('community_posts')
          .add(post.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating post: $e');
      throw Exception('Failed to create post: $e');
    }
  }

  Stream<List<CommunityPost>> getPosts({String category = 'All'}) {
    try {
      Query query = _firestore
          .collection('community_posts')
          .orderBy('createdAt', descending: true)
          .limit(50);

      return query.snapshots().map((snapshot) {
        var posts = snapshot.docs
            .map((doc) {
              try {
                return CommunityPost.fromFirestore(doc);
              } catch (e) {
                print('Error parsing post ${doc.id}: $e');
                return null;
              }
            })
            .whereType<CommunityPost>()
            .toList();
        
        if (category != 'All') {
          posts = posts.where((post) => post.category == category).toList();
        }
        
        return posts;
      }).handleError((error) {
        print('Error in posts stream: $error');
        return <CommunityPost>[];
      });
    } catch (e) {
      print('Error getting posts: $e');
      return Stream.value([]);
    }
  }

  Future<CommunityPost?> getPost(String postId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('community_posts')
          .doc(postId)
          .get();
      
      if (doc.exists) {
        return CommunityPost.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting post: $e');
      return null;
    }
  }

  // ✅ FIXED - Like/Unlike post (user can only like once)
  Future<void> toggleLike(String postId, String userId) async {
    try {
      DocumentReference postRef = _firestore
          .collection('community_posts')
          .doc(postId);

      return _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(postRef);
        
        if (!snapshot.exists) {
          throw Exception('Post does not exist');
        }
        
        List<String> likedBy = List<String>.from(snapshot['likedBy'] ?? []);
        int likes = snapshot['likes'] ?? 0;

        // Toggle like
        if (likedBy.contains(userId)) {
          // Unlike
          likedBy.remove(userId);
          likes = (likes - 1).clamp(0, 999999);
        } else {
          // Like (only if not already liked)
          if (!likedBy.contains(userId)) {
            likedBy.add(userId);
            likes++;
          }
        }

        transaction.update(postRef, {
          'likes': likes,
          'likedBy': likedBy,
        });
      });
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }

  // Check if current user liked a post
  Future<bool> hasUserLiked(String postId) async {
    final userId = currentUserId;
    if (userId == null) return false;

    try {
      final doc = await _firestore
          .collection('community_posts')
          .doc(postId)
          .get();
      
      if (!doc.exists) return false;
      
      List<String> likedBy = List<String>.from(doc['likedBy'] ?? []);
      return likedBy.contains(userId);
    } catch (e) {
      print('Error checking like status: $e');
      return false;
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('community_posts').doc(postId).delete();
      
      // Also delete all comments for this post
      final comments = await _firestore
          .collection('comments')
          .where('postId', isEqualTo: postId)
          .get();
      
      for (var doc in comments.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting post: $e');
      rethrow;
    }
  }

  // ========== COMMENTS ==========

  Future<void> addComment(Comment comment) async {
    try {
      await _firestore
          .collection('comments')
          .add(comment.toFirestore());

      await _firestore
          .collection('community_posts')
          .doc(comment.postId)
          .update({
        'commentsCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  Stream<List<Comment>> getComments(String postId) {
    try {
      return _firestore
          .collection('comments')
          .where('postId', isEqualTo: postId)
          .snapshots()
          .map((snapshot) {
        var comments = snapshot.docs
            .map((doc) {
              try {
                return Comment.fromFirestore(doc);
              } catch (e) {
                print('Error parsing comment ${doc.id}: $e');
                return null;
              }
            })
            .whereType<Comment>()
            .toList();
        
        // Sort on client side (oldest to newest)
        comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        
        return comments;
      }).handleError((error) {
        print('❌ Error in comments stream: $error');
        return <Comment>[];
      });
    } catch (e) {
      print('❌ Error setting up comments stream: $e');
      return Stream.value([]);
    }
  }

  Future<void> deleteComment(String commentId, String postId) async {
    try {
      await _firestore.collection('comments').doc(commentId).delete();
      
      await _firestore
          .collection('community_posts')
          .doc(postId)
          .update({
        'commentsCount': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error deleting comment: $e');
      rethrow;
    }
  }

  // ========== IMAGE UPLOAD ==========

  Future<List<String>> uploadImages(List<File> images) async {
    List<String> imageUrls = [];
    final userId = currentUserId ?? 'anonymous';

    for (var image in images) {
      try {
        String fileName = 'community/$userId/${DateTime.now().millisecondsSinceEpoch}_${imageUrls.length}.jpg';
        Reference ref = _storage.ref().child(fileName);
        await ref.putFile(image);
        String downloadUrl = await ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }

    return imageUrls;
  }
}