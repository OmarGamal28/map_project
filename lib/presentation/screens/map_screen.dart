import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps/business_logic/cubit/maps/maps_cubit.dart';
import 'package:maps/data/models/place_directions.dart';
import 'package:maps/helpers/location_helper.dart';
import 'package:maps/presentation/widgets/distance_and_time.dart';
import 'package:maps/presentation/widgets/search.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:uuid/uuid.dart';

import '../../constants/colors.dart';
import '../widgets/my_drawer.dart';

class MapScreen extends StatefulWidget {
   MapScreen({super.key});
  final FloatingSearchBarController controller = FloatingSearchBarController();
  SearchWidget searchWidget=SearchWidget();

  @override
  State<MapScreen> createState() => _MapScreenState();


}


class _MapScreenState extends State<MapScreen> {



  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    getMyCurrentLocation();
  }
  static Position? position;

  static final CameraPosition myCurrentLocationCameraPosition = CameraPosition(
      target: LatLng(position!.latitude, position!.altitude),
      //خطوط الطول والعرض
      bearing: 0.0,
      tilt: 0.0,
      zoom: 17.0); //عرض علي الخريطه

  Future<void> getMyCurrentLocation() async {
    position= await LocationHelper.determineCurrentLocation().whenComplete(() {
      setState(() {

      });
    });

  }

  final Completer<GoogleMapController> _mapController = Completer();

  //Set<Marker> markers = {};
  SearchWidget searchWidget= SearchWidget();



  Widget buildMap() {
    return GoogleMap(
      markers: searchWidget.markers!,
      initialCameraPosition: myCurrentLocationCameraPosition,
      mapType: MapType.normal,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: (GoogleMapController controller){
        _mapController.complete(controller);//الي بيتحكم في الماب
      },
      polylines: widget.searchWidget.placeDirections! !=null ?{
         Polyline(
            polylineId:  PolylineId('myPolyline'),
          color: Colors.black,
          width: 2,
          points: widget.searchWidget.polylinePoints!
        ),

      }:{

      },
    );
  }

  Future<void> _goToMyCurrentLocation()async{
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(myCurrentLocationCameraPosition));

}

  Widget floatingSearchBar(){
  final isPortrait = MediaQuery.of(context).orientation== Orientation.portrait;
  return FloatingSearchBar(

    controller: widget.controller,
    elevation: 6,
    hintStyle: const TextStyle(fontSize: 18),
    queryStyle: const TextStyle(fontSize: 18),
    hint: 'Find a place..',
    border: const BorderSide(style: BorderStyle.none),
    margins: const EdgeInsets.fromLTRB(20, 70, 20, 0),
    padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
    height: 52,
    iconColor: MyColors.blue,
    scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
    transitionDuration: const Duration(milliseconds: 600),
    transitionCurve: Curves.easeInOut,
    physics: const BouncingScrollPhysics(),
    axisAlignment: isPortrait ? 0.0 : -1.0,
    openAxisAlignment: 0.0,
    width: isPortrait ? 600 : 500,
    debounceDelay: const Duration(milliseconds: 500),
    progress: widget.searchWidget.progressIndicator,
    onQueryChanged: (query) {
      getPlacesSuggestions(query);

    },
    onFocusChanged: (_) {
      widget.searchWidget.isTimeAndDistanceVisible=false;

      // hide distance and time row

    },
    transition: CircularFloatingSearchBarTransition(),
    actions: [
      FloatingSearchBarAction(
        showIfOpened: false,
        child: CircularButton(
            icon: Icon(Icons.place, color: Colors.black.withOpacity(0.6)),
            onPressed: () {}),
      ),
    ],
    builder: (context, transition) {
      return  SearchWidget(position: position!);
    },
  );

}
  void getPlacesSuggestions(query){
    final sessionToken= const Uuid().v4();
    BlocProvider.of<MapsCubit>(context).emitPlaceSuggestions(query, sessionToken);

  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      drawer: MyDrawer(),
      floatingActionButton: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 8, 30),
        child: FloatingActionButton(
          backgroundColor: MyColors.blue,
          onPressed:  _goToMyCurrentLocation,
          child: const Icon(
            Icons.place,
            color: Colors.white,
          ),


        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [

          position != null ? buildMap() : const Center(child: CircularProgressIndicator(color: MyColors.blue,)),
          floatingSearchBar(),
          searchWidget.isSearchedPlaceMarkerClicked ? DistanceAndTime(
            isVisibility:searchWidget.isTimeAndDistanceVisible ,
            placeDirections: searchWidget.placeDirections,
          ):Container(),

        ],
      ),
    );
  }
}
