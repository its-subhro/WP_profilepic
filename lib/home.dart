import 'dart:io';
import 'dart:typed_data';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ScreenshotController screenshotController = ScreenshotController();
  String imageURL = "";
  Color color = Colors.black;

  // ignore: non_constant_identifier_names
  Widget BuildColorPicker() => ColorPicker(
      selectedPickerTypeColor: color,
      onColorChanged: (color) {
        setState(() {
          this.color = color;
        });
      });

  void pickColor(BuildContext context) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text('Pick Your Color'),
          content: Column(
            children: [
              BuildColorPicker(),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Select',
                    style: TextStyle(color: Colors.black),
                  )),
            ],
          )));

  void pickPhoto() async {
    final picker = ImagePicker();
    XFile? imagefile;
    try {
      imagefile = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        imageURL = imagefile!.path;
      });
    } catch (e) {
      return;
    }
  }

  captureImage(BuildContext context) {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    screenshotController
        .capture(pixelRatio: pixelRatio)
        .then((Uint8List? image) {
      saveimage(image!);
    }).catchError((err) {});
  }

  Future<bool> requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  saveimage(Uint8List bytes) async {
    final time = DateTime.now().toIso8601String().replaceAll('.', '_');
    final name = "wp_profilepic_$time";
    await requestPermission(Permission.storage);
    await ImageGallerySaver.saveImage(bytes, name: name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile Photo Editor',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.black,
        shadowColor: Colors.black87,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                imageURL != ""
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Screenshot(
                            controller: screenshotController,
                            child: Container(
                                height: 192,
                                width: 192,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    color: color,
                                    image: DecorationImage(
                                        image: FileImage(File(imageURL)),
                                        fit: BoxFit.contain))),
                          ),
                          Container(
                              height: 500,
                              width: 500,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(20),
                                  color: color,
                                  image: DecorationImage(
                                      image: FileImage(File(imageURL)),
                                      fit: BoxFit.contain))),
                        ],
                      )
                    : Container(
                        width: 500,
                        height: 500,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(20),
                            image: const DecorationImage(
                                image: AssetImage("assets/images/image.png")))),
                const SizedBox(
                  height: 20,
                ),
                Flexible(
                  flex: 2,
                  child: Container(
                    height: 250,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Background',
                                style: TextStyle(fontSize: 25),
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  pickColor(context);
                                },
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      const CircleBorder()),
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.all(10)),
                                  backgroundColor: MaterialStateProperty.all(
                                      color), // <-- Button color
                                ),
                                child: Text(
                                  '.',
                                  style: TextStyle(color: color),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // const SizedBox(
                              //   width: 10,
                              // ),
                              ElevatedButton(
                                  // style: ElevatedButton.styleFrom(
                                  //     fixedSize: Size(150, 8)),
                                  onPressed: () {
                                    setState(() {
                                      captureImage(context);
                                    });
                                  },
                                  child: const Text(
                                    'Download',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  )),
                              // const SizedBox(
                              //   width: 10,
                              // ),
                              ElevatedButton(
                                  // style: ElevatedButton.styleFrom(
                                  //     fixedSize: Size(150, 8)),
                                  onPressed: () {
                                    setState(() {
                                      pickPhoto();
                                    });
                                  },
                                  child: const Text(
                                    'Add Image',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
