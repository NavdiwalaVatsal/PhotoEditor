import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:draggable_widget/draggable_widget.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:screenshot/screenshot.dart';

class ImagePickerView extends StatefulWidget {
  const ImagePickerView({Key? key}) : super(key: key);

  @override
  State<ImagePickerView> createState() => _ImagePickerViewState();
}

class _ImagePickerViewState extends State<ImagePickerView> {
  
  var _image;

  Future getImage(ImgSource source) async {
    var image = await ImagePickerGC.pickImage(
        enableCloseButton: true,
        closeIcon: Icon(
          Icons.close,
          color: Colors.red,
          size: 12,
        ),
        context: context,
        source: source,
        barrierDismissible: true,
        cameraIcon: Icon(
          Icons.camera_alt,
          color: Colors.red,
        ), //cameraIcon and galleryIcon can change. If no icon provided default icon will be present
        cameraText: Text(
          "From Camera",
          style: TextStyle(color: Colors.red),
        ),
        galleryText: Text(
          "From Gallery",
          style: TextStyle(color: Colors.blue),
        ));
    setState(() {
      _image = image;
    });
  }

  String? _targetImageUrl;
  final dragController = DragController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("widget.title"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 300,
                child: ElevatedButton(
                  onPressed: () => getImage(ImgSource.Gallery),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                  ),
                  child: Text(
                    "From Gallery".toUpperCase(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Container(
                width: 300,
                child: ElevatedButton(
                  onPressed: () => getImage(ImgSource.Camera),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.deepPurple,
                  ),
                  child: Text(
                    "From Camera".toUpperCase(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Container(
                width: 300,
                child: ElevatedButton(
                  onPressed: () => getImage(ImgSource.Both),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                  ),
                  child: Text(
                    "Both".toUpperCase(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              _image != null
                  ? DraggableWidget(
                      bottomMargin: 80,
                      topMargin: 80,
                      intialVisibility: true,
                      horizontalSpace: 20,
                      child: Image.file(File(_image.path)))
                  : Container(),
              Draggable<String>(
                data:
                    "https://www.kindacode.com/wp-content/uploads/2020/11/my-dog.jpg",
                child: Container(
                  width: 300,
                  height: 200,
                  alignment: Alignment.center,
                  color: Colors.purple,
                  child: Image.network(
                    'https://www.kindacode.com/wp-content/uploads/2020/11/my-dog.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                // The widget to show under the pointer when a drag is under way
                feedback: Opacity(
                  opacity: 0.4,
                  child: Container(
                    color: Colors.purple,
                    width: 300,
                    height: 200,
                    alignment: Alignment.center,
                    child: Image.network(
                      'https://www.kindacode.com/wp-content/uploads/2020/11/my-dog.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),

              /// Target
              DraggableWidget(
                bottomMargin: 10,
                topMargin: 80,
                intialVisibility: true,
                horizontalSpace: 20,
                initialPosition: AnchoringPosition.bottomLeft,
                dragController: dragController,
                child: DragTarget<String>(
                  onAccept: (value) {
                    setState(() {
                      _targetImageUrl = value;
                    });
                  },
                  builder: (_, candidateData, rejectedData) {
                    return Container(
                      width: 300,
                      height: 200,
                      color: Colors.amber,
                      alignment: Alignment.center,
                      child: _targetImageUrl != null
                          ? Image.network(
                              _targetImageUrl!,
                              fit: BoxFit.cover,
                            )
                          : Container(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
