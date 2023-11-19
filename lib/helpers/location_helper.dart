import 'package:geolocator/geolocator.dart';
class LocationHelper{
  static Future<Position> determineCurrentLocation()async{
    bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();//لو مش فاتح لوكيشن خليه يفتح
    if(isServiceEnabled==false){
      await Geolocator.requestPermission();
    }
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );


  }
}