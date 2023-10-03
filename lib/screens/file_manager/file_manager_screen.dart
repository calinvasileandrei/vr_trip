import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:io';

class FileManagerScreen extends HookWidget {
  const FileManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final folders = useState<List<String>>([]);

    useEffect(() {
      Directory dir = Directory('/storage/emulated/0');
      List<FileSystemEntity> file = dir.listSync();
      for (FileSystemEntity f in file) {
        folders.value = [...folders.value, f.path];
      }

/*
      Directory dirDownload = Directory('/storage/emulated/0');
      var downloadsFile = dirDownload.listSync().where((e) => e is File);
      print('downloadsFile: $downloadsFile');*/
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Host'),
      ),
      body: Center(
          child: Column(
            children: [
              Text('Device Host Screen'),
              ElevatedButton(
                onPressed: () {
                  //socket.emit('message', 'Hello from Socket Screen');
                },
                child: Text('Send Message to Server'),
              ),
              Container(
                color: Colors.blueGrey[300],
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: folders.value.length,
                  itemBuilder: (context, index) {
                    return Container(
                      child: Text('Folder: ${folders.value[index]}'),
                    );
                  },
                ),
              ),
            ],
          )),
    );
  }
}
