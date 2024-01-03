import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:http/http.dart' as myHttp;

class SimpanPage extends StatefulWidget {
  const SimpanPage({super.key});

  @override
  State<SimpanPage> createState() => _SimpanPageState();
}

class _SimpanPageState extends State<SimpanPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _token;

  @override
  void initState() {
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });
  }

  Future<LocationData?> _currentLocation() async {
    bool serviceEnable;
    PermissionStatus permissionGranted;

    Location location = new Location();

    serviceEnable = await location.serviceEnabled();

    if (!serviceEnable) {
      serviceEnable = await location.requestService();
      if (!serviceEnable) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }
    return await location.getLocation();
  }

  Future savePresensi(latitude, longitude) async {
    Map<String, String> body = {
      "latitude": latitude.toString(),
      "longitude": longitude.toString()
    };

    Map<String, String> headers = {'Authorization': 'Bearer ' + await _token};

    var response = await myHttp.post(
        Uri.parse('http://10.0.2.2:8000/api/save-presensi'),
        body: body,
        headers: headers);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sukses simpan Presensi')));
      Navigator.pop(context);
    } else {
      try {
        Map<String, dynamic> responseJson = json.decode(response.body);
        if (responseJson['message'] ==
                "Hari ini sudah presensi masuk dan pulang" &&
            response.statusCode == 422) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(responseJson['message'])));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal simpan Presensi')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Presensi"),
      ),
      body: FutureBuilder<LocationData?>(
        future: _currentLocation(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            final LocationData currentLocation = snapshot.data;
            print("KODING : " +
                currentLocation.latitude.toString() +
                "|" +
                currentLocation.longitude.toString());
            return SafeArea(
              child: Column(
                children: [
                  Container(
                    height: 300,
                    child: SfMaps(
                      layers: [
                        MapTileLayer(
                          initialFocalLatLng: MapLatLng(
                              currentLocation.latitude!,
                              currentLocation.longitude!),
                          initialZoomLevel: 15,
                          initialMarkersCount: 1,
                          urlTemplate:
                              "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          markerBuilder: (BuildContext context, int index) {
                            return MapMarker(
                              latitude: currentLocation.latitude!,
                              longitude: currentLocation.longitude!,
                              child: Icon(
                                Icons.location_on,
                                color: Colors.red,
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      savePresensi(
                          currentLocation.latitude, currentLocation.longitude);
                    },
                    child: Text("Simpan Presensi"),
                  )
                ],
              ),
            );
          } else if (snapshot.hasError) {
            // Handle error when location is not available or permission denied.
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
