import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/providers/google/google_provider.dart';
import 'package:vr_trip/services/google_auth_client/google_auth_client.dart';
import 'package:vr_trip/services/google_drive/google_drive_service.dart';
import 'package:vr_trip/shared/ui_kit/my_button/my_button_component.dart';
import 'package:vr_trip/utils/libraryItem_utils.dart';
import 'package:vr_trip/utils/logger.dart';

class GoogleDriveLibrary extends HookConsumerWidget {
  const GoogleDriveLibrary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //Providers
    final authHeaders = ref.watch(authGoogleSP);
    final googleSignInObj = ref.watch(googleSignInSP);
    final googleAccountObj = ref.watch(googleAccountSP);
    final folders = ref.watch(googleDriveFoldersSP);
    final googleDownloadFolder = ref.watch(googleDownloadFolderSP);
    //State
    final isLoading = useState(false);

    listFiles() async {
      isLoading.value = true;
      if (authHeaders != null) {
        final authenticateClient = GoogleAuthClient(authHeaders);
        final driveApi = drive.DriveApi(authenticateClient);

        var files = await driveApi.files.list(
            q: "name contains 'VrTrip' and mimeType = 'application/vnd.google-apps.folder'");

        ref.read(googleDriveFoldersSP.notifier).state = files.files ?? [];
      }
      isLoading.value = false;
    }

    login() async {
      await Future.delayed(const Duration(seconds: 1));
      // Sign in
      final signIn.GoogleSignIn googleSignIn = signIn.GoogleSignIn.standard(
          scopes: ['https://www.googleapis.com/auth/drive']);
      ref.read(googleSignInSP.notifier).state = googleSignIn;
      // Account
      final signIn.GoogleSignInAccount? account = await googleSignIn.signIn();
      ref.read(googleAccountSP.notifier).state = account;

      if (account == null) {
        return;
      }
      final authHeaders = await account.authHeaders;
      ref.read(authGoogleSP.notifier).state = authHeaders;
      // wait 1 second
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 2));
      listFiles();
    }

    useEffect(() {
      if (googleSignInObj == null ||
          googleAccountObj == null ||
          authHeaders == null) {
        login();
      }
    }, []);

    handleItemPress(drive.File item) async {
      Logger.log('handleItemLongPress - item: ${item.toString()}');
      if (authHeaders == null) {
        return;
      }

      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);
      Logger.log('handleItemLongPress - google clients initialized');

      if (item.mimeType == 'application/vnd.google-apps.folder' &&
          item.name != null && !googleDownloadFolder.contains(item.name)) {
        ref.read(googleDownloadFolderSP.notifier).state = [
          ...googleDownloadFolder,
          item.name!
        ];
        Logger.log('handleItemLongPress - is folder');
        // Handle folder download

        Directory? dir =
            await LibraryItemUtils.createFolderForLibraryItem(item.name!);
        if (dir != null) {
          Logger.log('handleItemLongPress - dir created: ${dir.path}');
          Logger.log('handleItemLongPress - downloading items');
          try {
            await GoogleDriveService.downloadFolder(
                item, authenticateClient, driveApi, dir.path);
            Logger.log('handleItemLongPress - folder downloaded');
          } catch (e) {
            Logger.error('Error downloading folder: e.toString()');
          }
        } else {
          Logger.error('handleItemLongPress - dir is null');
        }
        var newDownloadFolders = [...googleDownloadFolder];
        newDownloadFolders.remove(item.name);
        ref.read(googleDownloadFolderSP.notifier).state = newDownloadFolders;
      }
      Logger.log('handleItemLongPress - completed');
    }

    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0))),
              child: Row(
                children: [
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.cloud,
                        color: Theme.of(context).primaryColor,
                      )),
                  Text(
                      "Sinc GoogleDrive: ${authHeaders != null ? "Effettuata" : "Non effettuata"}"),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: const BorderRadius.all(Radius.circular(8.0))),
                child: isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        itemCount: folders.length,
                        itemBuilder: (context, index) {
                          final item = folders[index];
                          return GestureDetector(
                            onTap: () => handleItemPress(item),
                            child: Container(
                              width: 50,
                              height: 50,
                              color: Theme.of(context).colorScheme.surface,
                              margin: const EdgeInsets.all(10),
                              child: Center(
                                  child: Row(
                                children: [
                                  Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Icon(Icons.folder,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface)),
                                  Text(item.name ?? 'nome non disponibile'),
                                  Expanded(child: Container()),
                                  if (googleDownloadFolder.contains(item.name))
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Theme.of(context).primaryColor,
                                        strokeWidth: 2,
                                      ),
                                    )
                                ],
                              )),
                            ),
                          );
                        },
                      ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyButton(
                  "Connetti a Google Drive",
                  onPressed: login,
                ),
                MyButton(
                  "Aggiorna",
                  onPressed: listFiles,
                ),
              ],
            ),
          ],
        ));
  }
}
