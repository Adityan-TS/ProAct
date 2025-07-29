import 'dart:developer';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CustomImagePicker {
  final ImagePicker picker = ImagePicker();

  Future<File?> pickProfilePicture() async {
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        return await _cropImageInCircle(File(image.path));
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Invalid Image. Please select another image');
      log("Error while getting image: $e");
    }
    return null;
  }

  Future<File?> _cropImageInCircle(File file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.png,
      maxHeight: 500,
      maxWidth: 500,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Crop Your Image",
          lockAspectRatio: true,
          cropStyle: CropStyle.circle,
        ),
        IOSUiSettings(
          title: "Crop Your Image",
          aspectRatioLockEnabled: true,
          aspectRatioPickerButtonHidden: true,
          cropStyle: CropStyle.circle,
        ),
      ],
    );

    if (croppedImage != null) {
      return File(croppedImage.path);
    }
    return null;
  }

  Future<File?> pickNormalPicture({source = ImageSource.gallery}) async {
    try {
      final XFile? image = await picker.pickImage(source: source,imageQuality: 50);
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Invalid Image. Please select another image');
      log("Error while getting image: $e");
    }
    return null;
  }


  Future<List<XFile>> pickNormalMultiPicture({source = ImageSource.gallery}) async {
    try {
      final List<XFile> image = await picker.pickMultiImage(imageQuality: 50);
      return image;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Invalid Image. Please select another image');
      log("Error while getting image: $e");
    }
    return [];
  }
}
