import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.1
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Share Files',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.comfortable,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme       
        )
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isBtn1, isBtn2;
  static GlobalKey previewContainer = GlobalKey();

  @override
  void initState() {
    isBtn1 = false;
    isBtn2 = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: previewContainer,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.05,
                width: MediaQuery.of(context).size.width * 0.5,
                child: RaisedButton(
                  onPressed: screenShotAndShare,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: isBtn1
                        ? CircularProgressIndicator()
                        : Text(
                            'Screenshot & Share',
                            style: TextStyle(fontSize: 17),
                          ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.05,
                width: MediaQuery.of(context).size.width * 0.5,
                child: RaisedButton(
                  onPressed: saveAndShare,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: isBtn2
                        ? CircularProgressIndicator()
                        : Text(
                            'URL to File & Share',
                            style: TextStyle(fontSize: 17),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Null> screenShotAndShare() async {
    setState(() {
      isBtn1 = true;
    });
    try {
      RenderRepaintBoundary boundary =
          previewContainer.currentContext.findRenderObject();
      if (boundary.debugNeedsPaint) {
        Timer(Duration(seconds: 1), () => screenShotAndShare());
        return null;
      }
      ui.Image image = await boundary.toImage();
      final directory = (await getExternalStorageDirectory()).path;
      ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      File imgFile = new File('$directory/screenshot.png');
      imgFile.writeAsBytes(pngBytes);
      // print('Screenshot Path:' + imgFile.path);
      final RenderBox box = context.findRenderObject();
      Share.shareFile(File('$directory/screenshot.png'),
        subject: 'Screenshot + Share',
        text: 'Hey, check it out the sharefiles repo!',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size
      );
    } on PlatformException catch (e) {
      print("Exception while taking screenshot:" + e.toString());
    }
    setState(() {
      isBtn1 = false;
    });
  }

  Future<Null> saveAndShare() async {
    setState(() {
      isBtn2 = true;
    });
    final RenderBox box = context.findRenderObject();
    if (Platform.isAndroid) {
      var url = 'https://www.winklix.com/blog/wp-content/uploads/2020/01/6t1pv3xcd.png';
      var response = await get(url);
      final documentDirectory = (await getExternalStorageDirectory()).path;
      File imgFile = new File('$documentDirectory/flutter.png');
      imgFile.writeAsBytesSync(response.bodyBytes);

      Share.shareFile(File('$documentDirectory/flutter.png'),
          subject: 'URL conversion + Share',
          text: 'Hey! Checkout the Share Files repo',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } else {
      Share.share('Hey! Checkout the Share Files repo',
          subject: 'URL conversion + Share',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
    setState(() {
      isBtn2 = false;
    });
  }
}