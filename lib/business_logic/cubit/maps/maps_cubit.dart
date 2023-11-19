import 'package:bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

import '../../../data/models/place.dart';
import '../../../data/models/place_directions.dart';
import '../../../data/models/place_suggestions.dart';
import '../../../data/repository/maps_repository.dart';

part 'maps_state.dart';

class MapsCubit extends Cubit<MapsState> {

  MapsCubit(this.mapsRepository) : super(MapsInitial());
  final MapsRepository mapsRepository;

  void emitPlaceSuggestions(String place, String sessionToken) {
    mapsRepository.fetchSuggestions(place, sessionToken).then((suggestions) {
      emit(PlacesLoaded(suggestions));
    });

}

  void emitPlaceLocation(String place, String sessionToken) {
    mapsRepository.getPlaceLocation(place, sessionToken).then((place) {
      emit(PlaceLocationLoaded(place));
    });

  }

  void emitGetDirections(LatLng origin, LatLng destination) {
    mapsRepository.getDirections(origin, destination).then((directions) {
      emit(DirectionsLoaded(directions));
    });

  }


}
