// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class LoginResult {
//   final bool success;
//   final String message;

//   LoginResult({
//     required this.success,
//     required this.message,
//   });
// }

// class LoginService {
//   static final FirebaseAuth _auth =
//       FirebaseAuth.instance;

//   static final FirebaseFirestore _firestore =
//       FirebaseFirestore.instance;

//   // ----------------------------------------------------------
//   // LOGIN
//   // ----------------------------------------------------------

//   static Future<LoginResult> login({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       // Firebase Authentication
//       final credential =
//           await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       final User? user = credential.user;

//       if (user == null) {
//         return LoginResult(
//           success: false,
//           message: 'Unable to login.',
//         );
//       }

//       // Get user account information
//       final userDoc = await _firestore
//           .collection('Users')
//           .doc(user.uid)
//           .get();

//       if (!userDoc.exists) {
//         await _auth.signOut();

//         return LoginResult(
//           success: false,
//           message:
//               'Account information was not found.',
//         );
//       }

//       final data = userDoc.data()!;

//       // ------------------------------------------------------
//       // ACCOUNT STATUS
//       // ------------------------------------------------------

//       final String status =
//           data['status'] ?? 'disabled';

//       if (status != 'active') {
//         await _auth.signOut();

//         return LoginResult(
//           success: false,
//           message:
//               'Your account has been disabled. Please contact the administrator.',
//         );
//       }

//       // ------------------------------------------------------
//       // SUBSCRIPTION EXPIRY
//       // ------------------------------------------------------

//       final Timestamp? expiry =
//           data['subscriptionExpiry'];

//       if (expiry != null) {
//         final DateTime expiryDate =
//             expiry.toDate();

//         final DateTime now = DateTime.now();

//         if (now.isAfter(expiryDate)) {
//           await _auth.signOut();

//           return LoginResult(
//             success: false,
//             message:
//                 'Your subscription has expired. Please contact the administrator.',
//           );
//         }
//       }

//       return LoginResult(
//         success: true,
//         message: 'Login successful.',
//       );
//     } on FirebaseAuthException catch (e) {
//       String message = 'Login failed.';

//       if (e.code == 'invalid-credential') {
//         message = 'Incorrect email or password.';
//       } else if (e.code == 'user-not-found') {
//         message = 'No account found with this email.';
//       } else if (e.code == 'wrong-password') {
//         message = 'Incorrect password.';
//       } else if (e.code == 'invalid-email') {
//         message = 'Invalid email address.';
//       } else if (e.code == 'user-disabled') {
//         message = 'This account has been disabled.';
//       } else if (e.code == 'too-many-requests') {
//         message =
//             'Too many attempts. Please try again later.';
//       }

//       return LoginResult(
//         success: false,
//         message: message,
//       );
//     } catch (e) {
//       return LoginResult(
//         success: false,
//         message:
//             'Something went wrong. Please try again.',
//       );
//     }
//   }

//   // ----------------------------------------------------------
//   // FORGOT PASSWORD
//   // ----------------------------------------------------------

//   static Future<LoginResult> resetPassword({
//     required String email,
//   }) async {
//     try {
//       await _auth.sendPasswordResetEmail(
//         email: email,
//       );

//       return LoginResult(
//         success: true,
//         message:
//             'Password reset email has been sent.',
//       );
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'invalid-email') {
//         return LoginResult(
//           success: false,
//           message: 'Invalid email address.',
//         );
//       }

//       return LoginResult(
//         success: false,
//         message:
//             'Unable to send password reset email.',
//       );
//     }
//   }

//   // ----------------------------------------------------------
//   // LOGOUT
//   // ----------------------------------------------------------

//   static Future<void> logout() async {
//     await _auth.signOut();
//   }
// }








import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginResult {
  final bool success;
  final String message;

  LoginResult({
    required this.success,
    required this.message,
  });
}

class LoginService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Check email + password in Firebase Authentication
      final UserCredential credential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = credential.user;

      if (user == null) {
        return LoginResult(
          success: false,
          message: 'Unable to login.',
        );
      }

      // 2. Get the user's account document from Firestore
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore
              .collection('Users')
              .doc(user.uid)
              .get();

      // 3. Check whether users/{uid} exists
      if (!userDoc.exists) {
        await _auth.signOut();

        return LoginResult(
          success: false,
          message:
              'Account information was not found in the users collection.',
        );
      }

      final data = userDoc.data();

      if (data == null) {
        await _auth.signOut();

        return LoginResult(
          success: false,
          message: 'Account data is empty.',
        );
      }

      // 4. Check account status
      final String status =
          data['status']?.toString().toLowerCase() ?? 'disabled';

      if (status != 'active') {
        await _auth.signOut();

        return LoginResult(
          success: false,
          message:
              'Your account is disabled. Please contact the administrator.',
        );
      }

      // 5. Check subscription expiry
      final dynamic expiryValue =
          data['subscriptionExpiry'];

      if (expiryValue != null &&
          expiryValue is Timestamp) {
        final DateTime expiryDate =
            expiryValue.toDate();

        if (DateTime.now().isAfter(expiryDate)) {
          await _auth.signOut();

          return LoginResult(
            success: false,
            message:
                'Your subscription has expired. Please contact the administrator.',
          );
        }
      }

      // 6. Everything is OK
      return LoginResult(
        success: true,
        message: 'Login successful.',
      );
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code}');
      print('Firebase Auth Message: ${e.message}');

      switch (e.code) {
        case 'invalid-credential':
          return LoginResult(
            success: false,
            message: 'Invalid email or password.',
          );

        case 'user-not-found':
          return LoginResult(
            success: false,
            message: 'No account found with this email.',
          );

        case 'wrong-password':
          return LoginResult(
            success: false,
            message: 'Incorrect password.',
          );

        case 'invalid-email':
          return LoginResult(
            success: false,
            message: 'Invalid email address.',
          );

        case 'user-disabled':
          return LoginResult(
            success: false,
            message: 'This Firebase account has been disabled.',
          );

        case 'too-many-requests':
          return LoginResult(
            success: false,
            message:
                'Too many login attempts. Please try again later.',
          );

        default:
          return LoginResult(
            success: false,
            message:
                'Firebase login failed: ${e.message ?? e.code}',
          );
      }
    } on FirebaseException catch (e) {
      print('Firebase Error: ${e.code}');
      print('Firebase Message: ${e.message}');

      return LoginResult(
        success: false,
        message:
            'Firebase error: ${e.message ?? e.code}',
      );
    } catch (e) {
      print('Login Error: $e');

      return LoginResult(
        success: false,
        message:
            'Something went wrong: $e',
      );
    }
  }

  static Future<LoginResult> resetPassword({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );

      return LoginResult(
        success: true,
        message:
            'Password reset email has been sent.',
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return LoginResult(
          success: false,
          message: 'Invalid email address.',
        );
      }

      if (e.code == 'user-not-found') {
        return LoginResult(
          success: false,
          message: 'No account found with this email.',
        );
      }

      return LoginResult(
        success: false,
        message:
            'Unable to send reset email.',
      );
    } catch (e) {
      return LoginResult(
        success: false,
        message: 'Something went wrong.',
      );
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }
}