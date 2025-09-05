// import 'dart:io';
// import 'package:al_marwa_water_app/core/utils/custom_snackbar.dart';
// import 'package:al_marwa_water_app/repositories/image_repository.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class CustomerImageController extends ChangeNotifier {
//   final CustomerImageRepository _customerRepository = CustomerImageRepository();

//   bool isUploading = false;
//   File? selectedImage;

//   void setSelectedImage(File file) {
//     selectedImage = file;
//     notifyListeners();
//   }

//   Future<void> uploadImage({
//     required int customerId,
//     required File imageFile,
//     required BuildContext context,
//   }) async {
//     isUploading = true;
//     notifyListeners();

//     try {
//       final result = await _customerRepository.uploadCustomerImage(
//         customerId: customerId,
//         imageFile: imageFile,
//       );

//       showSnackbar(message: result['message'] ?? "Image uploaded successfully");
//     } catch (e) {
//       showSnackbar(message: "Upload failed: $e", isError: true);
//     } finally {
//       isUploading = false;
//       notifyListeners();
//     }
//   }
// }

// class ImagePickerHelper {
//   static Future<File?> pickImage(BuildContext context) async {
//     return showModalBottomSheet<File?>(
//       context: context,
//       builder: (context) {
//         return SafeArea(
//           child: Wrap(
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Gallery'),
//                 onTap: () async {
//                   final pickedFile = await ImagePicker().pickImage(
//                     source: ImageSource.gallery,
//                   );
//                   Navigator.pop(
//                     context,
//                     pickedFile != null ? File(pickedFile.path) : null,
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Camera'),
//                 onTap: () async {
//                   try {
//                     final pickedFile = await ImagePicker().pickImage(
//                       source: ImageSource.camera,
//                     );
//                     Navigator.pop(
//                       context,
//                       pickedFile != null ? File(pickedFile.path) : null,
//                     );
//                   } catch (e) {
//                     Navigator.pop(context, null);
//                     showSnackbar(
//                       message: "Failed to capture image: $e",
//                       isError: true,
//                     );
//                   }
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

import 'dart:io';
import 'package:al_marwa_water_app/core/utils/custom_snackbar.dart';
import 'package:al_marwa_water_app/repositories/image_repository.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class CustomerImageController extends ChangeNotifier {
  final CustomerImageRepository _customerRepository = CustomerImageRepository();

  bool isUploading = false;
  File? selectedImage;

  /// Set picked image after compression
  Future<void> setSelectedImage(File file) async {
    final compressedFile = await _compressImage(file);
    selectedImage = compressedFile;
    debugPrint("📸 Selected image (compressed): ${selectedImage!.path}");
    notifyListeners();
  }

  /// Upload image to server
  Future<void> uploadImage({
    required int customerId,
    required File imageFile,
    required BuildContext context,
  }) async {
    isUploading = true;
    notifyListeners();

    try {
      final result = await _customerRepository.uploadCustomerImage(
        customerId: customerId,
        imageFile: imageFile,
      );

      debugPrint("📦 Raw upload response: $result");
      if (result.containsKey("errors")) {
        debugPrint("❌ Server errors: ${result['errors']}");
        showSnackbar(
          message: "Upload failed: ${result['errors']}",
          isError: true,
        );
        debugPrint("❌ Upload failed: ${result['errors']}");
      } else {
        showSnackbar(
          message: result['message'] ?? "Image uploaded successfully",
        );
        debugPrint("✅ Upload successful: ${result['message']}");
      }
    } catch (e, stack) {
      debugPrint("🔥 Upload exception: $e");
      debugPrint("📜 Stacktrace: $stack");
      showSnackbar(message: "Upload failed: $e", isError: true);
      debugPrint(
        "📜 Stacktrace: $stack || Upload failed: $e",
      );
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  /// Compress image (JPG, quality 80, max 1080px width)
  Future<File> _compressImage(File file) async {
    try {
      final originalBytes = await file.readAsBytes();
      final originalImage = img.decodeImage(originalBytes);

      if (originalImage == null) {
        debugPrint("⚠️ Could not decode image, skipping compression");
        return file;
      }

      // Resize if too large
      final resized = img.copyResize(
        originalImage,
        width: originalImage.width > 1080 ? 1080 : originalImage.width,
      );

      // Compress to JPG
      final compressedBytes = img.encodeJpg(resized, quality: 80);

      final newPath = "${file.path}_compressed.jpg";
      final compressedFile = File(newPath)..writeAsBytesSync(compressedBytes);

      debugPrint(
        "📏 Original size: ${(file.lengthSync() / 1024).toStringAsFixed(2)} KB",
      );
      debugPrint(
        "📏 Compressed size: ${(compressedFile.lengthSync() / 1024).toStringAsFixed(2)} KB",
      );

      return compressedFile;
    } catch (e) {
      debugPrint("⚠️ Compression failed: $e");
      return file;
    }
  }
}

class ImagePickerHelper {
  static Future<File?> pickImage(BuildContext context) async {
    return showModalBottomSheet<File?>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  Navigator.pop(
                    context,
                    pickedFile != null ? File(pickedFile.path) : null,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  try {
                    final pickedFile = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                    );
                    Navigator.pop(
                      context,
                      pickedFile != null ? File(pickedFile.path) : null,
                    );
                  } catch (e) {
                    Navigator.pop(context, null);
                    showSnackbar(
                      message: "Failed to capture image: $e",
                      isError: true,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
