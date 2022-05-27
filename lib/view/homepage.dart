import 'dart:io';
import 'dart:math';
import 'package:body_detection/body_detection.dart';
import 'package:body_detection/models/point3d.dart';
import 'package:body_detection/models/pose.dart';
import 'package:body_detection/models/pose_landmark_type.dart';
import 'package:body_detection/png_image.dart';
import 'package:ergonomix/services/pose_painter.dart';
import 'package:ergonomix/view/introductionScreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Image? _selectedImage;
  Pose? _detectedPose;
  Size _imageSize = Size.zero;
  late double x1;
  late double y1;
  late double x2;
  late double y2;
  late double y3;
  late double x3;
  late double alpha;

  Future _getImage(ImageSource source) async {
    PickedFile? result = await ImagePicker()
        .getImage(source: source, imageQuality: 50);
    if (result == null) return;
    final path = result.path;
    if (path != null) {
      _resetState();
      setState(() {
        _selectedImage = Image.file(File(path));
      });

    }
  }

  Future<void> _detectImagePose() async {
    PngImage? pngImage = await _selectedImage?.toPngImage();
    if (pngImage == null) return;
    setState(() {
      _imageSize = Size(pngImage.width.toDouble(), pngImage.height.toDouble());
    });
    final pose = await BodyDetection.detectPose(image: pngImage);
    _handlePose(pose);
    position();
  }

  void _handlePose(Pose? pose) {
    if (!mounted) return;
    setState(() {
      _detectedPose = pose;
    });
  }

  void showAlertDialog(BuildContext context, String baslik, String aciklama) {
    Widget okButton = TextButton(
      child: Text(
        "Kapat",
        style: GoogleFonts.courgette(
            fontStyle: FontStyle.italic, fontSize: 15, color: Colors.red),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.grey.shade400,
      title: Text(
        baslik,
        style: GoogleFonts.courgette(
            fontStyle: FontStyle.italic, fontSize: 25, color: Colors.black),
      ),
      content: Text(
        aciklama,
        style: GoogleFonts.courgette(
            fontStyle: FontStyle.italic, fontSize: 18, color: Colors.black),
      ),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void position() {
    for (final landmark in _detectedPose!.landmarks) {
      Point3d position = landmark.position;

      PoseLandmarkType type = landmark.type;

      if (PoseLandmarkType.rightShoulder == type) {
        x1 = position.x;
        y1 = position.y;
      } else if (PoseLandmarkType.rightKnee == type) {
        x2 = position.x;
        y2 = position.y;
      } else if (PoseLandmarkType.rightHip == type) {
        x3 = position.x;
        y3 = position.y;
      }
    }

    var kh = sqrt(pow(x3 - x2, 2) + pow(y3 - y2, 2));
    var sh = sqrt(pow(x3 - x1, 2) + pow(y3 - y1, 2));
    var sk = sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));

    alpha = 1 /
        cos(((pow(sh, 2) + pow(kh, 2) - pow(sk, 2)) / 2 * sh * kh) *
            (pi / 180));

    double f = alpha * (180 / pi);

    if (f < 0) {
      f = f + 180;
    }
    print("*********************************");
    print(f);

    if (f < 120 && f > 93) {
      showAlertDialog(
          context, 'Teşhis', 'Ergonomik bir pozisyondasınız. Tebrikler!');
    } else {
      showAlertDialog(context, 'Teşhis',
          'Ergonomik bir pozisyonda değilsiniz!. Lütfen dikkatli olunuz!');
    }
  }

  void _resetState() {
    setState(() {
      _detectedPose = null;
      _imageSize = Size.zero;
      _selectedImage = null;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ergonomix',
          style: GoogleFonts.lobster(
              fontStyle: FontStyle.italic, fontSize: 34, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey.shade600,
        leading: IconButton(
          icon: Icon(Icons.question_mark),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => IntroPage()));
          },
          color: Colors.black,
        ),
      ),
      backgroundColor: Colors.grey.shade500,
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomPaint(
              child: _selectedImage,
              foregroundPainter: PosePainter(
                pose: _detectedPose,
                imageSize: _imageSize,
              ),
            ),
            Stack(children: [
              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 50, 0, 10),
                      child: FloatingActionButton.extended(
                        icon: Icon(
                          Icons.photo_library_outlined,
                          size: 30.0,
                          color: Colors.black,
                        ),
                        backgroundColor: Colors.grey.shade400,
                        label: Text(
                          'Galeri',
                          style: GoogleFonts.courgette(
                              fontStyle: FontStyle.italic,
                              fontSize: 25,
                              color: Colors.black),
                        ),
                        onPressed: () {
                          _getImage(ImageSource.gallery);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: FloatingActionButton.extended(
                        onPressed: () {

                          _getImage(ImageSource.camera);
                        },
                        label: Text(
                          'Kamera',
                          style: GoogleFonts.courgette(
                              fontStyle: FontStyle.italic,
                              fontSize: 25,
                              color: Colors.black),
                        ),
                        backgroundColor: Colors.grey.shade400,
                        icon: Icon(
                          Icons.camera_alt_outlined,
                          size: 30.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          _detectImagePose();


                        },
                        label: Text(
                          'Teshis',
                          style: GoogleFonts.courgette(
                              fontStyle: FontStyle.italic,
                              fontSize: 25,
                              color: Colors.black),
                        ),
                        backgroundColor: Colors.grey.shade400,
                        icon: Icon(
                          Icons.person_outline,
                          size: 30.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          _resetState();
                        },
                        label: Text(
                          'Temizle',
                          style: GoogleFonts.courgette(
                              fontStyle: FontStyle.italic,
                              fontSize: 25,
                              color: Colors.black),
                        ),
                        backgroundColor: Colors.grey.shade400,
                        icon: Icon(
                          Icons.cancel_outlined,
                          size: 30.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
