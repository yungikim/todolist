
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main(){
  HttpOverrides.global = MyHttpOverrides();
  runApp(DownloadFile());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class DownloadFile extends StatefulWidget {
  const DownloadFile({Key? key}) : super(key: key);

  @override
  State<DownloadFile> createState() => _DownloadFileState();
}

class _DownloadFileState extends State<DownloadFile> {

  bool downloading = true;
  String savePath = "";
  var imageUrl = "https://www.gallery360.co.kr/artimage/byhokim68@naver.com/art/watermark/byhokim68@naver.com_b638703d6a1774f15b286ffd5a9471d8.22101052.jpg";
  String downloadingStr = "No Data";

  @override
  void initState(){
    super.initState();
    //downloadFile();
  }

  Future downloadFile() async{
    try{
      Dio dio = Dio();
      String filename = imageUrl.substring(imageUrl.lastIndexOf("/") + 1);
      filename = "111.jpg";
      savePath = await getFilePath(filename);
      print(savePath);
      await dio.download(imageUrl, savePath, onReceiveProgress: (rec, total){
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
      
    }catch(e){
      print(e.toString());
    }
  }

  Future<String> getFilePath(uniqueFileName) async{
    String path = '';
    Directory dir = await getApplicationDocumentsDirectory();
    path = '${dir.path}/$uniqueFileName';
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.pink),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Download File"),
          backgroundColor: Colors.pink,
        ),
        body: Column(
          children: [
            ElevatedButton(onPressed: (){
              downloadFile();
            }, child: Text("다운로드 시작")),
            Center(
              child: downloading
              ? Container(
                height: 250,
                width: 250,
                child: Card(
                  color: Colors.pink,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(backgroundColor: Colors.white,),
                      SizedBox(height: 20,),
                      Text(downloadingStr, style: TextStyle(color: Colors.white),)
                    ],

                  ),
                ),
              )
              :Container(

                child: Center(
                  child: Center(
                    child: Image.file(File(savePath), ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
