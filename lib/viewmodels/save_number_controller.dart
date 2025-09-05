// import 'dart:convert';
// import 'package:al_marwa_water_app/core/utils/custom_snackbar.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:http/http.dart' as http;

// class GoogleContactProvider with ChangeNotifier {
//   final GoogleSignIn _googleSignIn = GoogleSignIn(
//     scopes: ['https://www.googleapis.com/auth/contacts'],
//     serverClientId:
//         '741234659626-91mg00ik2kst8jku65mrghqn0825k1ic.apps.googleusercontent.com',
//   );

//   bool isSaving = false;
//   String? message;
//   Future<String?> _signInAndGetAccessToken() async {
//     try {
//      final GoogleSignInAccount? account = await _googleSignIn.signIn().catchError((e) {
//   debugPrint("Google Sign-In error: $e");
// });

//       final GoogleSignInAuthentication auth = await account!.authentication;
//       return auth.accessToken;
//     } catch (e) {
//       debugPrint("Sign-in failed: $e");
//       return null;
//     }
//   }

//   Future<void> createGoogleContact({
//     required String name,
//     required String phoneNumber,
//     required BuildContext context,
//   }) async {
//     isSaving = true;
//     message = null;
//     notifyListeners();

//     final accessToken = await _signInAndGetAccessToken();
//     if (accessToken == null) {
//       message = 'Google sign-in failed';
//       isSaving = false;
//       notifyListeners();
//       return;
//     }

//     final response = await http.post(
//       Uri.parse('https://people.googleapis.com/v1/people:createContact'),
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         "names": [
//           {"givenName": name}
//         ],
//         "phoneNumbers": [
//           {"value": phoneNumber}
//         ],
//       }),
//     );

//     if (response.statusCode == 200) {

//       message = 'Contact created successfully!';
//     } else {
//       message =
//           'Failed to create contact: ${response.statusCode}\n${response.body}';
//     }

//     isSaving = false;
//     notifyListeners();

//     showSnackbar(
//       message: "$message",
//     );
//   }
// }
