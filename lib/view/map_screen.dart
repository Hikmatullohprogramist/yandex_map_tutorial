import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:yandex_map_tutorial/models/long_lat.dart';
import 'package:yandex_map_tutorial/service/map_service.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final mapControllerCompleter = Completer<YandexMapController>();

  @override
  void initState() {
    super.initState();
    _initPermission().ignore();
  }
  final List<MapObject> mapObjects = [];

  final MapObjectId mapObjectId = const MapObjectId('polygon');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Текущее местоположение'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _fetchCurrentLocation();
        },
        child: Icon(Icons.location_on),
      ),
      body: Column(
        children: [
          Expanded(
            child: YandexMap(
                  mapObjects: mapObjects,
                  onMapCreated: (controller) {
                mapControllerCompleter.complete(controller);
              },
            
            
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
                child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: () async {
                              if (mapObjects.any((el) => el.mapId == mapObjectId)) {
                                return;
                              }
            
                              final mapObject = PolygonMapObject(
                                mapId: mapObjectId,
                                polygon: const Polygon(
                                    outerRing: LinearRing(points: [
                                      Point(latitude: 56.34295, longitude: 5731.892253110097),
                                      Point(latitude: 56.04956, longitude: 125.07751),
                                    ]),
                                    innerRings: [
                                      LinearRing(points: [
                                        Point(latitude: 57.34295, longitude: 78.62829),
                                      ])
                                    ]
                                ),
                                strokeColor: Colors.orange[700]!,
                                strokeWidth: 3.0,
                                fillColor: Colors.yellow[200]!,
                                onTap: (PolygonMapObject self, Point point) => print('Tapped me at $point'),
                              );
            
                              setState(() {
                                mapObjects.add(mapObject);
                              });
                            },
                            child: Text('Add')
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (!mapObjects.any((el) => el.mapId == mapObjectId)) {
                                return;
                              }
            
                              final mapObject = mapObjects.firstWhere((el) => el.mapId == mapObjectId) as PolygonMapObject;
            
                              setState(() {
                                mapObjects[mapObjects.indexOf(mapObject)] = mapObject.copyWith(
                                  strokeColor: Colors.orange[700]!,
                                  strokeWidth: 3.0,
                                  fillColor: Colors.primaries[Random().nextInt(Colors.primaries.length)],
                                );
                              });
                            },
                            child: Text('Update')
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                mapObjects.removeWhere((el) => el.mapId == mapObjectId);
                              });
                            },
                            child: Text('Remove')

                          )
                        ],
                      )
                    ]
                )
            ),
          )
        ],
      ),
    );
  }

  Future<void> _initPermission() async {
    if (!await LocationService().checkPermission()) {
      await LocationService().requestPermission();
    }
    await _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    AppLatLong location;
    const defLocation = MoscowLocation();
    try {
      location = await LocationService().getCurrentLocation();
    } catch (_) {
      location = defLocation;
    }
    _moveToCurrentLocation(location);
  }

  Future<void> _moveToCurrentLocation(
    AppLatLong appLatLong,
  ) async {
    (await mapControllerCompleter.future).moveCamera(
      animation: const MapAnimation(type: MapAnimationType.linear, duration: 1),
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: appLatLong.lat,
            longitude: appLatLong.long,
          ),
          zoom: 12,
        ),
      ),
    );
  }
}
