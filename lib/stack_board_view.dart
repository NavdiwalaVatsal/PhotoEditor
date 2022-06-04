import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:stack_board/stack_board.dart';
import 'dart:math' as math;
import 'package:text_editor/text_editor.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';

class StackBoardView extends StatefulWidget {
  const StackBoardView({Key? key}) : super(key: key);

  @override
  State<StackBoardView> createState() => _StackBoardViewState();
}

class _StackBoardViewState extends State<StackBoardView> {
  ScreenshotController screenshotController = ScreenshotController();

  late Timer _timer;
  int _start = 0;
  int _startTwo = 61;

  void increasingStartTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start > 60) {
            timer.cancel();
          } else {
            _start = _start + 1;
          }
        },
      ),
    );
  }

  void decreasingStartTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_startTwo < 0) {
            timer.cancel();
          } else {
            _startTwo = _startTwo - 1;
          }
        },
      ),
    );
  }

  late StackBoardController _boardController;

  @override
  void initState() {
    super.initState();
    _boardController = StackBoardController();

    // _tapHandler(_text, _textStyle, _textAlign);
    // _boardController = _tapHandler as StackBoardController;
  }

  @override
  void dispose() {
    _boardController.dispose();
    _timer.cancel();
    super.dispose();
  }

  Future<bool> _onDel() async {
    final bool? r = await showDialog<bool>(
      context: context,
      builder: (_) {
        return Center(
          child: SizedBox(
            width: 400,
            child: Material(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 60),
                      child: Text('Want to Save or not?'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        IconButton(
                            onPressed: () => Navigator.pop(context, true),
                            icon: const Icon(Icons.check)),
                        IconButton(
                            onPressed: () => Navigator.pop(context, false),
                            icon: const Icon(Icons.clear)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    return r ?? false;
  }

  final fonts = [
    'OpenSans',
    'Billabong',
    'GrandHotel',
    'Oswald',
    'Quicksand',
    'BeautifulPeople',
    'BeautyMountains',
    'BiteChocolate',
    'BlackberryJam',
    'BunchBlossoms',
    'CinderelaRegular',
    'Countryside',
    'Halimun',
    'LemonJelly',
    'QuiteMagicalRegular',
    'Tomatoes',
    'TropicalAsianDemoRegular',
    'VeganStyle',
  ];
  TextStyle _textStyle = TextStyle(
    fontSize: 50,
    color: Colors.white,
    fontFamily: 'Billabong',
  );
  String _text = 'Sample Text';
  TextAlign _textAlign = TextAlign.center;

  void _tapHandler(text, textStyle, textAlign) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: Duration(
        milliseconds: 400,
      ), // how long it takes to popup dialog after button click
      pageBuilder: (_, __, ___) {
        // your widget implementation
        return Container(
          color: Colors.black.withOpacity(0.4),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              // top: false,
              child: Container(
                child: TextEditor(
                  fonts: fonts,
                  text: text,
                  textStyle: textStyle,
                  textAlingment: textAlign,
                  minFontSize: 10,
                  onEditCompleted: (style, align, text) {
                    setState(() {
                      _text = text;
                      _textStyle = style;
                      _textAlign = align;
                      _boardController.add(
                        StackBoardItem(
                            tapToEdit: true,
                            child: Text(
                              _text,
                              style: _textStyle,
                              textAlign: _textAlign,
                            )),
                      );
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

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
        ),
        //cameraIcon and galleryIcon can change. If no icon provided default icon will be present
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
      print("Image:${_image.toString()}");
      _boardController.add(
        StackBoardItem(child: Image.file(File(_image.path))
            // child: Image.file(
            //   _image,
            // ),
            ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Edit Image Demo'),
        elevation: 0,
        backgroundColor: Colors.purpleAccent,
      ),
      body: Screenshot(
        controller: screenshotController,
        child: StackBoard(
          controller: _boardController,
          caseStyle: const CaseStyle(
            borderColor: Colors.grey,
            iconColor: Colors.white,
          ),
          background: Image.asset("assets/demo.jpg"),
          customBuilder: (StackBoardItem t) {
            if (t is CustomItem) {
              return ItemCase(
                key: Key('StackBoardItem${t.id}'), // <==== must
                isCenter: false,
                onDel: () async => _boardController.remove(t.id),
                onTap: () => _boardController.moveItemToTop(t.id),
                caseStyle: const CaseStyle(
                  borderColor: Colors.grey,
                  iconColor: Colors.white,
                ),
                child: Container(
                  width: 100,
                  height: 100,
                  color: t.color,
                  alignment: Alignment.center,
                  child: const Text(
                    'Custom item',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }

            return null;
          },
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  const SizedBox(width: 25),
                  FloatingActionButton(
                    backgroundColor: Colors.purpleAccent,
                    onPressed: () {
                      setState(() {
                        _tapHandler(_text, _textStyle, _textAlign);
                      });

                      // Text(
                      //   _text,
                      //   style: _textStyle,
                      //   textAlign: _textAlign,
                      // );
                      // _boardController.add(
                      //   StackBoardItem(
                      //       tapToEdit: true,
                      //       child: Text(
                      //         _text,
                      //         style: _textStyle,
                      //         textAlign: _textAlign,
                      //       )),);
                      //   const AdaptiveText(
                      //   'Sample Text',
                      //   tapToEdit: true,
                      //   style: TextStyle(
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // )
                    },
                    child: const Icon(
                      Icons.text_fields,
                    ),
                  ),
                  _spacer,
                  FloatingActionButton(
                    backgroundColor: Colors.purpleAccent,
                    onPressed: () {
                      setState(() {
                        getImage(ImgSource.Both);
                      });
                    },
                    child: const Icon(Icons.add_a_photo_rounded),
                  ),
                  _spacer,
                  FloatingActionButton(
                    backgroundColor: Colors.purpleAccent,
                    child: const Icon(Icons.save),
                    onPressed: () {
                      screenshotController
                          .capture(delay: Duration(milliseconds: 10))
                          .then((capturedImage) async {
                        ShowCapturedWidget(context, capturedImage!);
                        _saved(capturedImage);
                      }).catchError((onError) {
                        print(onError);
                      });
                    },
                  ),
                  // FloatingActionButton(
                  //   onPressed: () {
                  //     _boardController.add(
                  //       const StackDrawing(
                  //         caseStyle: CaseStyle(
                  //           borderColor: Colors.grey,
                  //           iconColor: Colors.white,
                  //           boxAspectRatio: 1,
                  //         ),
                  //       ),
                  //     );
                  //   },
                  //   child: const Icon(Icons.color_lens),
                  // ),
                  // _spacer,
                  // FloatingActionButton(
                  //   onPressed: () {
                  //     _boardController.add(
                  //       StackBoardItem(
                  //         child: const Text(
                  //           'Custom Widget',
                  //           style: TextStyle(color: Colors.black),
                  //         ),
                  //         onDel: _onDel,
                  //         // caseStyle: const CaseStyle(initOffset: Offset(100, 100)),
                  //       ),
                  //     );
                  //   },
                  //   child: const Icon(Icons.add_box),
                  // ),
                  // _spacer,
                  // FloatingActionButton(
                  //   onPressed: () {
                  //     _boardController.add<CustomItem>(
                  //       CustomItem(
                  //         color: Color((math.Random().nextDouble() * 0xFFFFFF)
                  //                 .toInt())
                  //             .withOpacity(1.0),
                  //         onDel: () async => true,
                  //       ),
                  //     );
                  //   },
                  //   child: const Icon(Icons.add),
                  // ),
                ],
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: Colors.purpleAccent,
            onPressed: () => _boardController.clear(),
            child: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget get _spacer => const SizedBox(width: 5);
  Future<dynamic> ShowCapturedWidget(
      BuildContext context, Uint8List capturedImage) {
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text("Captured widget screenshot"),
        ),
        body: Center(
            child: capturedImage != null
                ? Image.memory(capturedImage)
                : Container()),
      ),
    );
  }

  _saved(image) async {
    final result = await ImageGallerySaver.saveImage(image);
    print("File Saved to Gallery");
  }
}

class CustomItem extends StackBoardItem {
  const CustomItem({
    required this.color,
    Future<bool> Function()? onDel,
    int? id, // <==== must
  }) : super(
          child: const Text('CustomItem'),
          onDel: onDel,
          id: id, // <==== must
        );

  final Color? color;

  @override // <==== must
  CustomItem copyWith({
    CaseStyle? caseStyle,
    Widget? child,
    int? id,
    Future<bool> Function()? onDel,
    dynamic Function(bool)? onEdit,
    bool? tapToEdit,
    Color? color,
  }) =>
      CustomItem(
        onDel: onDel,
        id: id,
        color: color ?? this.color,
      );
}
