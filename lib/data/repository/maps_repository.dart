

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/place.dart';
import '../models/place_directions.dart';
import '../models/place_suggestions.dart';
import '../web_services/places_web_services.dart';

class MapsRepository {
  final PlacesWebservices placesWebservices;

  MapsRepository(this.placesWebservices);

  Future<List<PlaceSuggestion>> fetchSuggestions(String place,
      String sessionToken) async {
    final suggestions =
    await placesWebservices.fetchSuggestions(place, sessionToken);

    return suggestions
        .map((suggestion) => PlaceSuggestion.fromJson(suggestion))
        .toList();
  }

  Future<Place> getPlaceLocation(String placeId, String sessionToken) async {
    final place =
    await placesWebservices.getPlaceLocation(placeId, sessionToken);
    return Place.fromJson(place);
  }

  Future<PlaceDirections> getDirections(
      LatLng origin, LatLng destination) async {
    final directions =
    await placesWebservices.getDirections(origin, destination);

    return PlaceDirections.fromJson(directions);
  }
}
