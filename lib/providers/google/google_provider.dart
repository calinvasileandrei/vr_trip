import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

final authGoogleSP = StateProvider<Map<String,String>?>((ref) => null);
final googleSignInSP = StateProvider<GoogleSignIn?>((ref) => null);
final googleAccountSP = StateProvider<GoogleSignInAccount?>((ref) => null);
final googleDriveFoldersSP = StateProvider<List<drive.File>>((ref) => []);
