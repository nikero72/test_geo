
import 'dart:math';

import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MainScreenBody(),
    );
  }
}

class MainScreenBody extends StatefulWidget {
  const MainScreenBody({Key? key}) : super(key: key);

  @override
  State<MainScreenBody> createState() => _MainScreenBodyState();
}

class _MainScreenBodyState extends State<MainScreenBody> {
  final _controllerLon = TextEditingController();
  final _controllerLat = TextEditingController();
  final _controllerZoom = TextEditingController();

  var x = 0;
  var y = 0;
  var z = 0;

  void getTile() {
    String lon = _controllerLon.text;
    String lat = _controllerLat.text;
    String zoom = _controllerZoom.text;
    double invLongitude = double.tryParse(lon) ?? 0;
    double invLatitude = double.tryParse(lat) ?? 0;
    z = int.tryParse(zoom) ?? 0;

    double longitude = invLatitude * pi / 180.0;
    double latitude = invLongitude * pi / 180.0;
    int r = 6378137;
    double e = 0.0818191908426;
    var esinLat = e * sin(latitude);

    var tanTemp = tan(pi / 4 + latitude / 2);
    var powTemp = pow(tan(pi / 4 + asin(esinLat) / 2), e);
    var u = tanTemp / powTemp;

    var merkatLat = r * log(u);
    var merkatLon = r * longitude;
    double equatorLength = 40075016.685578488;
    var worldSize = pow(2, 31);
    double a = worldSize / equatorLength;
    double b = equatorLength / 2;

    x = ((((b + merkatLon) * a) / pow(2, 23 - z)) / 256).floor();
    y = ((((b - merkatLat) * a) / pow(2, 23 - z)) / 256).floor();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 256,
                  height: 256,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      width: 1,
                      color: Colors.black
                    )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _controllerLon,
                          decoration: const InputDecoration(
                              labelText: 'Долгота'
                          ),
                        ),
                        TextField(
                          controller: _controllerLat,
                          decoration: const InputDecoration(
                              labelText: 'Широта'
                          ),
                        ),
                        TextField(
                          controller: _controllerZoom,
                          decoration: const InputDecoration(
                              labelText: 'Зум'
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                            onPressed: () => getTile(),
                            child: const Text('Перевести')
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('X: $x, Y: $y, zoom: $z'),
                const SizedBox(height: 20),
                SizedBox(
                  width: 256,
                  height: 256,
                  child: Image.network(
                    'https://core-carparks-renderer-lots.maps.yandex.net/maps-rdr-carparks/tiles?l=carparks&x=$x&y=$y&z=$z&scale=1&lang=ru_RU',
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                      return const Center(
                        child: Icon(Icons.error_outline),
                      );
                    },
                    ),
                )
              ],
            ),
          )
      ),
    );
  }
}
