import 'package:flutter/material.dart';

class HeroAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // timeDilation = 5.0; // 1.0 means normal animation speed.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Hero Animation'),
      ),
      body: Center(
        child: PhotoHero(
          photo: 'images/flippers-alpha.png',
          width: 300.0,
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (BuildContext context) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Flippers Page'),
                ),
                body: Container(
                  // The blue background emphasizes that it's a new route.
                  color: Colors.lightBlueAccent,
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.topLeft,
                  child: PhotoHero(
                    photo: 'images/flippers-alpha.png',
                    width: 100.0,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              );
            }));
          },
        ),
      ),
    );
  }
}

class PhotoHero extends StatelessWidget {
  // const PhotoHero({Key key, this.photo, this.onTap, this.width})
  //     : super(key: key);

  PhotoHero({
    required this.photo,
    required this.onTap,
    required this.width,
  });

  final String photo;
  final VoidCallback onTap;
  final double width;

  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Hero(
        tag: photo,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Image.asset(
              photo,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
