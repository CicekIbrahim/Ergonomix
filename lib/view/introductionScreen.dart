import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          title: Text('Nasıl Calışır?',
              style: TextStyle(
                fontFamily: 'Lobster',
                fontSize: 32,
                color: Colors.black,
              )),
          centerTitle: true,
          backgroundColor: Colors.grey.shade600,
        ),
        backgroundColor: Colors.grey.shade500,
        body: Container(
            child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  '1- Galeri butonuna basarak galeriden fotoğrafınızı seçiniz ya da Kamera butonuna basarak bir fotoğraf çekiniz.',
                  style: GoogleFonts.courgette(
                      fontStyle: FontStyle.italic, fontSize: 25),
                ),
                Row(
                  children: [
                    Image.asset('assets/images/galeri.png'),
                    Image.asset('assets/images/kamera.png'),
                  ],
                ),
                Text(
                  '2- Teşhiş butonuna basıp ergonomi teşhisini tamamlanmasını bekleyiniz.',
                  style: GoogleFonts.courgette(
                      fontStyle: FontStyle.italic, fontSize: 25),
                ),
                Image.asset('assets/images/teshis.png'),
                Text(
                  '3- Temizleyip baştan başlamak için Temizle butonuna basınız',
                  style: GoogleFonts.courgette(
                      fontStyle: FontStyle.italic, fontSize: 25),
                ),
                Image.asset('assets/images/temizle.png')
              ],
            ),
          ),
        )));
  }
}
