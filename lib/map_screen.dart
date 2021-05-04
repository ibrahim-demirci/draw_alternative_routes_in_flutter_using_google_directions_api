import 'package:flutter/material.dart';
import 'directions_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'directions_model.dart';
import 'map_style.dart';



class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String chosenValue = 'driving';

  static const _initialCameraPosition = CameraPosition(
    target: LatLng(41.017901, 28.847953),
    zoom: 16.5,
  );

  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  GoogleMapController _googleMapController;
  Marker _origin;
  Marker _destination;
  Directions _info;
  Set<Polyline> _polylines = {};

  BitmapDescriptor pinLocationIcon;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setCustomMapPin();
  }

  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/marker1.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        centerTitle: false,
        title: const Text("Waste Management"),
        actions: [
          // Origin butonu tıklayınca origine gidiyor.
          if (_origin != null)
            TextButton(
              onPressed: () => _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _origin.position,
                    zoom: 16.5,
                    tilt: 50.0,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                primary: Colors.green,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text("ORIGIN"),
            ),

          // Hedef butonu tıklayınca hedefe gidiyor
          if (_destination != null)
            TextButton(
              onPressed: () => _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _destination.position,
                    zoom: 16.5,
                    tilt: 50.0,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                primary: Colors.blue,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text("DESTINATION"),
            ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) {
              _googleMapController = controller;
              controller.setMapStyle(Utils.mapStyle);
            },
            markers: {

              if (_origin != null) _origin,
              if (_destination != null) _destination,

            },
            polylines: _polylines,

            // {
            //   if (_info != null)
            //     Polyline(
            //         polylineId: const PolylineId('overview_polyline'),
            //         color: Colors.orange,
            //         width: 5,
            //         points: _info.polylinePoints
            //             .map((e) => LatLng(e.latitude, e.longitude))
            //             .toList())
            // },

            // Uzun basışta addMarker fonksiyonunu çağırır.
            onLongPress: _addMarker,
          ),
          buildDropDownMenu(context),

          // If info is not null this build info container
          if (_info != null)
            buildDurationAndDistanceContainer(context)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey,
        foregroundColor: Colors.white,
        onPressed: () => _googleMapController.animateCamera(_info != null
            ? CameraUpdate.newLatLngBounds(_info.bounds, 100.0)
            : CameraUpdate.newCameraPosition(_initialCameraPosition)),
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

  Positioned buildDropDownMenu(BuildContext context) {
    return Positioned(
          bottom: 20,
          child: Container(
            width: MediaQuery.of(context).size.width / 2,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 6.0,
                )
              ],
            ),
            padding: const EdgeInsets.all(0.0),
            child: Center(
              child: DropdownButton<String>(
                dropdownColor: Colors.grey,
                value: chosenValue,
                //elevation: 5,
                style: TextStyle(color: Colors.white, fontSize: 20),

                items: <String>[
                  'driving',
                  'walking',
                  'bicycling',
                  'transit',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                hint: Text(
                  "Mod",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
                onChanged: (String value) {
                  setState(() {
                    chosenValue = value;
                  });
                },
              ),
            ),
          ),
        );
  }

  Positioned buildDurationAndDistanceContainer(BuildContext context) {
    return Positioned(
            top: 20,
            child: Column(
              children: [
                Container(
                  height: 45.0,
                  width: MediaQuery.of(context).size.width / 1.5,
                  padding: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(204, 147, 70, 140),
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 6.0,
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${_info.totalDistance}, ${_info.totalDuration}',
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),

                // if alternative route is available this container show.
                _info.alternativePolylinePoints !=null
                    ? Container(
                  height: 45.0,
                  width: MediaQuery.of(context).size.width / 1.5,
                  padding: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.5),
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 6.0,
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Alternative: ${_info.alternativeTotalDistance}, ${_info.alternativeTotalDuration}',
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                    : SizedBox(),
              ],
            ),
          );
  }

  // Marker ekleme fonksiyonu
  void _addMarker(LatLng pos) async {

    // There are two status
    // 1 -Both markers are available
    // 2 -No marker on map
    if (_origin == null || (_origin != null && _destination != null)) {
      setState(() {
        _origin = Marker(
            markerId: const MarkerId('origin'),
            infoWindow: const InfoWindow(title: 'Origin'),
            icon: pinLocationIcon,
            position: pos);
        _destination = null;

        // No information because destination is not available
        _info = null;

        // Clear lines on map
        _polylines.clear();
      });

    } else {
      // If there is a origin add destination marker
      setState(() {
        _destination = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: pinLocationIcon,
          position: pos,
        );
      });

      // Get directions
      final directions = await DirectionsRepository().getDirections(
          mode: chosenValue, origin: _origin.position, destination: pos);


      // Directions is not empty make these
      if (directions != null) {
        Polyline polyline;
        // Refresh screen
        setState(() {
          _info = directions;
          polyline = Polyline(
              polylineId: PolylineId("poly"),
              color: Color.fromARGB(204, 147, 70, 140),
              width: 6,
              points: _info.polylinePoints != null
                  ? _info.polylinePoints
                  .map((e) => LatLng(e.latitude, e.longitude))
                  .toList()
                  : null);

          _polylines.add(polyline);
          if (_info.alternativePolylinePoints != null) {
            polyline = Polyline(
                polylineId: PolylineId("poly1"),
                color: Color.fromRGBO(255, 255, 255, 0.5),
                width: 7,
                points: _info.alternativePolylinePoints
                    .map((e) => LatLng(e.latitude, e.longitude))
                    .toList());
            _polylines.add(polyline);
          }
        });
      }
    }
  }
}

