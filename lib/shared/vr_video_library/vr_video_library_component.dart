import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vr_trip/models/library_item_model.dart';
import 'package:vr_trip/services/library_reader/library_reader_service.dart';
import 'package:vr_trip/shared/ui_kit/my_button/my_button_component.dart';
import 'package:vr_trip/shared/ui_kit/my_text/my_text_component.dart';
import 'package:vr_trip/shared/vr_video_library/widgets/library_item/library_item_component.dart';
import 'package:vr_trip/utils/file_utils.dart';

class VrVideoLibrary extends HookWidget {
  final Function(LibraryItemModel) onItemPress;
  Function(LibraryItemModel)? onItemLongPress;
  final bool? disableDeleteButton;
  final LibraryItemModel? selectedLibraryItem;

  VrVideoLibrary(
      {super.key,
      required this.onItemPress,
      this.onItemLongPress,
      this.disableDeleteButton,
      this.selectedLibraryItem});

  @override
  Widget build(BuildContext context) {
    final folders = useState<List<LibraryItemModel>>([]);
    final directoryWatcher = useRef<StreamSubscription<FileSystemEvent>?>(null);
    final isLoading = useState(false);

    handleListFilesInAppStorage() async {
      folders.value = await LibraryReaderService.loadLibrary();
    }

    useEffect(() {
      handleListFilesInAppStorage();

      (() async {
        Directory? libraryDirectory =
            await FileUtils.getLocalAppStorageFolder();
        if (libraryDirectory != null) {
          directoryWatcher.value = libraryDirectory.watch().listen((event) {
            handleListFilesInAppStorage();
          });
        }
      })();

      return () => directoryWatcher.value?.cancel(); // Cleanup
    }, const []);


    Widget? renderLeadingComponent(LibraryItemModel item){
      if(selectedLibraryItem != null){
        if(selectedLibraryItem!.name == item.name){
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.check,color: Theme.of(context).colorScheme.onSurface),
          );
        }
      }
      return null;
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                const BorderRadius.all(Radius.circular(8.0))),
            child: Row(
              children: [
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: const Icon(
                      Icons.ad_units_rounded,
                      color: Colors.blue,
                    )),
                MyText(
                  'Libreria Interna',
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              margin:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius:
                  const BorderRadius.all(Radius.circular(8.0))),
              child: ListView.builder(
                itemCount: folders.value.length,
                itemBuilder: (context, index) {
                  return LibraryItem(
                    item: folders.value[index],
                    onPress: onItemPress,
                    onLongPress: (item) {
                      if (onItemLongPress != null) {
                        onItemLongPress!(item);
                      }
                    },
                    leadingComponent: renderLeadingComponent(folders.value[index]),
                  );
                },
              ),
            ),
          ),
          if (disableDeleteButton == null || disableDeleteButton == false)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyButton(
                  'Delete Library',
                  onPressed: () async {
                    final Directory? libraryFolder =
                    await FileUtils.getLocalAppStorageFolder();
                    if (libraryFolder != null) {
                      await FileUtils.deleteEverythingInPath(libraryFolder.path);
                    }
                  },
                  isLoading: isLoading.value,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
