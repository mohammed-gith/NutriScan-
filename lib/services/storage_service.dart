import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'auth_service.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthService _authService = AuthService();

  Future<String?> uploadProfilePhoto(XFile imageFile) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return null;

    final bytes = await imageFile.readAsBytes();
    final ref = _storage.ref('users/$uid/profile.jpg');
    await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }
}
