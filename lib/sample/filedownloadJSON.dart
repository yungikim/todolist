import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../list_screen.dart';
import '../main.dart';
import '../todo.dart';
import 'ProductDataModel.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(DownloadFileJson());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class DownloadFileJson extends StatefulWidget {
  const DownloadFileJson({Key? key}) : super(key: key);

  @override
  State<DownloadFileJson> createState() => _DownloadFileJsonState();
}

class _DownloadFileJsonState extends State<DownloadFileJson> {
  @override
  Widget build(BuildContext context) {
    return home();
  }
}

class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  bool downloading = false;
  String downloadingStr = "";
  String downloadpath = "";

  List _items = [];

  Future downloadstart() async {
    try {
      Dio dio = Dio();
      String url = "https://exhibit.gallery360.co/load_VRRoom_rental_public.mon?sort=1&ty=all&artist=&q=&q_cond=all&perpage=150&page=1&start=0&_=1681978034178";
    //  String filename = await DefaultAssetBundle.of(context).loadString('assets/file/country.json');
      String filename = "111.json";
      downloadpath = await getFilePath(filename);
     // downloadpath = "/assets/file/222.json";
    //  downloadpath =  await DefaultAssetBundle.of(context).loadString('assets/file/country.json');
      print(downloadpath);
      await dio.download(url, downloadpath, onReceiveProgress: (rec, total) {
        setState(() {
          downloading = true;
          downloadingStr = "Downloading Image : $rec / $total";
        });
      });

      setState(() {
        print("downloading Complete................");
        downloading = false;
        downloadingStr = "Completed";

      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> getFilePath(uniqueFileName) async {
    String path = '';
    Directory dir = await getApplicationDocumentsDirectory();

    path = '${dir.path}/$uniqueFileName';
    return path;
  }

  Future jsonP() async{
    //final String response = await rootBundle.loadString("/data/user/0/com.example.todolist/app_flutter/111.json");
    try{
      print("downloadpath : " + downloadpath);

      print("==============================");
      print(File(downloadpath).existsSync());


      final file = File(downloadpath);
      final content = await file.readAsString();
      final data = await json.decode(content);

      //print(data);

      // var data = await rootBundle.loadString('assets/database/bcs-preparation.json'); this is working when when the file is inside assets
      //var jsonData = await json.decode(data);
      // print("==============================");
      // final String response = await rootBundle.loadString(downloadpath);
      //
      // print(response);
      //
      // final data = await json.decode(response);

      // final dpath = await File(downloadpath);
      // final data = await json.decode(dpath.readAsString().toString());
      //print(data);
      _items = data['list'];
      print(_items.length);
      for (Map<String, dynamic> doc in _items){
        print(doc['open_homepage']);

        await todos.add(Todo(
          title: doc['title'],
          dateTime: DateTime.now().millisecondsSinceEpoch,
        ));
      }



      setState(() {
        _items = data['list'];
      });

    }catch(e){
      print(e.toString());
    }
    // final String response = await rootBundle.loadString("assets/file/111.json");
    //
    // final data = await json.decode(response);
    // setState(() {
    //   _items = data["lending"];
    // });



  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Json Download")),
        body: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  downloadstart();
                },
                child: Text("다운로드")),
            ElevatedButton(onPressed: (){
              jsonP();
            }, child: Text("JSON 불러오기")),
            ElevatedButton(onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListScreen()),
              );
            }, child: Text("메인으로 이동")),
            SizedBox(
              height: 20,
            ),
            Text(
              downloadingStr,
              style: TextStyle(fontSize: 30),
            ),
            _items.isNotEmpty
            ? Expanded(
              child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index){
                    return Card(
                      child: ListTile(
                        leading: Text(_items[index]["viewcount"]),
                        title: Text(_items[index]["title"]),
                        subtitle: Text(_items[index]["open_homepage"]),
                      ),
                    );
                  }
              ),
            )
            : Container(
              child: Text("데이가 없다"),
            )
          ],
        ),
      ),
    );
  }
}
