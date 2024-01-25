import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/providers/google/google_provider.dart';
import 'package:vr_trip/services/google_auth_client/google_auth_client.dart';
import 'package:vr_trip/services/google_drive/google_drive_service.dart';
import 'package:vr_trip/utils/libraryItem_utils.dart';
import 'package:vr_trip/utils/logger.dart';

class GoogleDriveLibrary extends HookConsumerWidget {
  const GoogleDriveLibrary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authHeaders = ref.watch(authGoogleSP);
    final folders = useState<List<drive.File>>([]);
    final googleSignInObj = useState<signIn.GoogleSignIn?>(null);
    final googleAccountObj = useState<signIn.GoogleSignInAccount?>(null);
    final isLoadingItemId = useState<String?>(null);

    listFiles() async {
      if (authHeaders == null) {
        return;
      }
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      var files = await driveApi.files.list();

      folders.value = files.files ?? [];
    }

    login() async {
      // Sign in
      final signIn.GoogleSignIn googleSignIn = signIn.GoogleSignIn.standard(
          scopes: ['https://www.googleapis.com/auth/drive']);
      googleSignInObj.value = googleSignIn;
      // Account
      final signIn.GoogleSignInAccount? account = await googleSignIn.signIn();
      googleAccountObj.value = account;

      if (account == null) {
        return;
      }
      final authHeaders = await account.authHeaders;
      ref.read(authGoogleSP.notifier).state = authHeaders;
      listFiles();
    }

    useEffect(() {
      login();
      return () async {
        googleSignInObj.value = null;
        googleAccountObj.value = null;
        ref.read(authGoogleSP.notifier).state = null;
      };
    }, []);

    handleItemPress(drive.File item) async {
      Logger.log('handleItemLongPress - item: ${item.toString()}');
      if (authHeaders == null) {
        return;
      }

      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);
      Logger.log('handleItemLongPress - google clients initialized');

      if (item.mimeType == 'application/vnd.google-apps.folder' && item.name != null) {
        isLoadingItemId.value = item.name;
        Logger.log('handleItemLongPress - is folder');
        // Handle folder download

        Directory? dir =
            await LibraryItemUtils.createFolderForLibraryItem(item.name!);
        if (dir != null) {
          Logger.log('handleItemLongPress - dir: ${dir.path}');
          try {
            await GoogleDriveService.downloadFolder(
                item, authenticateClient, driveApi, dir.path);
            Logger.log('handleItemLongPress - folder downloaded');
          } catch (e) {
            Logger.error('Error downloading folder: e.toString()');
          }
        }else{
          Logger.error('handleItemLongPress - dir is null');
        }
        isLoadingItemId.value = null;
      }
      Logger.log('handleItemLongPress - completed');
    }

    return Container(
      child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                color: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: const Icon(
                          Icons.cloud,
                          color: Colors.blue,
                        )),
                    Text(
                        "Sincronizzazione GoogleDrive: ${authHeaders != null ? "Effettuata" : "Non effettuata"}"),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: login,
                    child: const Text(
                      "Sincronizza con Google Drive",
                    ),
                  ),
                  ElevatedButton(
                      onPressed: listFiles, child: const Text("Aggiorna")),
                ],
              ),
              Container(
                height: 200,
                child: ListView.builder(
                  itemCount: folders.value.length,
                  itemBuilder: (context, index) {
                    final item = folders.value[index];
                    return GestureDetector(
                      onTap: () => handleItemPress(item),
                      child: Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.all(10),
                        child: Center(
                            child: Row(
                          children: [
                            Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.folder,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface)),
                            Text(item.name ?? 'nome non disponibile'),
                            if (isLoadingItemId.value == item.name)
                              const CircularProgressIndicator(),
                          ],
                        )),
                      ),
                    );
                  },
                ),
              ),
            ],
          )),
    );
  }
}
