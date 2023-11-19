
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps/business_logic/cubit/maps/maps_cubit.dart';
import 'package:maps/presentation/screens/map_screen.dart';
import 'package:maps/presentation/widgets/place_search_item.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/place.dart';
import '../../data/models/place_directions.dart';
import '../../data/models/place_suggestions.dart';

class SearchWidget extends StatefulWidget {
  final  Position? position;
  final Set<Marker>? markers ;
  late final PlaceDirections? placeDirections;
  late final  List<LatLng>? polylinePoints;
  final progressIndicator=false;
    bool isSearchedPlaceMarkerClicked=false;
   bool isTimeAndDistanceVisible=false;




   SearchWidget({super.key, this.position,  this.markers, this.placeDirections, this.polylinePoints,});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final Completer<GoogleMapController> _mapController = Completer();

  // these variables for getPlaceLocation
  List<PlaceSuggestion>? places;

     late PlaceSuggestion placeSuggestion;

     late Place selectedPlace;

     late Marker searchedPlaceMarker;

     late Marker currentLocationMarker;

     late CameraPosition goToSearchedForPlace;

  //these variables for get directions




  late String time;
  late String distance;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildSuggestionBloc(),
          buildSelectedLocationBloc(),
          buildDirctionsBloc(),
        ],
      ),
    );
  }
  Widget buildDirctionsBloc(){
    return BlocListener<MapsCubit,MapsState>(
      listener: (context,state){
        if(state is DirectionsLoaded ){
          widget.placeDirections=state.placeDirections;
          getPolyLinePoints();

        }
      },
      child: Container(),
    );
  }
  void getPolyLinePoints(){
    widget.polylinePoints=widget.placeDirections?.polylinePoints.map((e) => LatLng(e.latitude,e.longitude)).toList();
  }

  Widget buildSelectedLocationBloc(){
    return BlocListener<MapsCubit,MapsState>(
        listener: (context,state){
          if(state is PlaceLocationLoaded ){
            selectedPlace= state.place;
            goToMySearchedForLocation();
            getDirections();

          }
        },
        child: Container(),
    );
  }
  void getDirections(){
    BlocProvider.of<MapsCubit>(context).emitGetDirections(
      LatLng(widget.position!.latitude, widget.position!.longitude),
        LatLng(selectedPlace!.result.geometry.location.lat, selectedPlace!.result.geometry.location.lng)

    );
  }

     void buildCameraNewPosition() {
       goToSearchedForPlace = CameraPosition(
         bearing: 0.0,
         tilt: 0.0,
         target: LatLng(
           selectedPlace.result.geometry.location.lat,
           selectedPlace.result.geometry.location.lng,
         ),
         zoom: 13,
       );
     }

     Future<void> goToMySearchedForLocation()async{
    buildCameraNewPosition();
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(goToSearchedForPlace));
    buildSearchedPlaceMarker();


  }

  void buildSearchedPlaceMarker(){
    searchedPlaceMarker=Marker(
        markerId: const MarkerId('2'),
      position: goToSearchedForPlace.target,
      onTap: (){
          buildCurrentLocationMarker();
          //show time and distance
        setState(() {
          widget.isSearchedPlaceMarkerClicked=true;
          widget.isTimeAndDistanceVisible=true;
        });
      },
      infoWindow:InfoWindow(
        title: placeSuggestion.description
      ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
    );
    addMarkerToMarkersAndUpdateUI(searchedPlaceMarker);
  }

  void buildCurrentLocationMarker(){
    currentLocationMarker=Marker(
        markerId: const MarkerId('4'),
        position: LatLng(widget.position!.latitude,widget.position!.longitude),

        infoWindow:const InfoWindow(
            title: "Your Current Location"
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
    );
    addMarkerToMarkersAndUpdateUI(currentLocationMarker);

  }

  void addMarkerToMarkersAndUpdateUI(Marker marker){
    setState(() {
      widget.markers?.add(marker);
    });

  }

  Widget buildSuggestionBloc() {
    return BlocBuilder<MapsCubit, MapsState>(builder: (context, state) {
      if (state is PlacesLoaded) {
        places = state.places;
        if (places!.isNotEmpty) {
          return buildPlacesList();
        } else {
          return Container();
        }
      } else {
        return Container();
      }
    });
  }

  Widget buildPlacesList() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () async {
            placeSuggestion =places![index];

            MapScreen().controller.close();
            getSelectedPlaceLocation(context);
            widget.polylinePoints?.clear();
            //removeAllMarkerAndUpdateUi();
          },
          child: PlaceItem(suggestion: places![index],),
        );
      },
      itemCount: places?.length,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
    );
  }

  void getSelectedPlaceLocation(BuildContext context){
    final sessionToken = const Uuid().v4();
    BlocProvider.of<MapsCubit>(context).emitPlaceSuggestions(placeSuggestion.placeId, sessionToken);
  }
}

