import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:map_view/location.dart';
import 'package:uri/uri.dart';
import 'map_view.dart';
import 'locations.dart';

class DirectionsProvider {
  final String googleMapsApiKey;
  static const int defaultZoomLevel = 4;
  static const int defaultWidth = 600;
  static const int defaultHeight = 400;

  DirectionsProvider(this.googleMapsApiKey);

  ///
  /// Creates a Uri for the Google Static Maps API
  /// Centers the map on [center] using a zoom of [zoomLevel]
  /// Specify a [width] and [height] that you would like the resulting image to be. The default is 600w x 400h
  ///

  Future<String> getDirectionsPolyline(List<Marker> locations) async {
    Uri url = _buildUrl(locations);
    var httpClient = new HttpClient();

    String result = '';

    var request = await httpClient.getUrl(url);
    var response = await request.close();
    if (response.statusCode == HttpStatus.OK) {
      var json = await response.transform(UTF8.decoder).join();
      var data = JSON.decode(json);
      result = data['routes'][0]['overview_polyline']['points'].toString().replaceAll('\\\\', '\\');
    }

      return  result;
  }


  Uri _buildUrl(List<Marker> locations) {
    var finalUri = new UriBuilder()
      ..scheme = 'https'
      ..host = 'maps.googleapis.com'
      ..port = 443
      ..path = '/maps/api/directions/json';

    if (locations == null || locations.length == 0) {
      finalUri.queryParameters = {
        'key': googleMapsApiKey,
      };
    } else {
      List<String> waypoints = new List();
      locations.forEach((location) {
        num lat = location.latitude;
        num lng = location.longitude;
        String marker = '$lat,$lng';
        waypoints.add(marker);
      });
      String waypointsString = waypoints.join('|');
      finalUri.queryParameters = {
        'origin' : '$locations.first.latitude,$locations.first.longitude',
        'destination': '$locations.last.latitude,$locations.last.longitude',
        //'waypoints' : waypointsString,
        'key': googleMapsApiKey,
        //'path' : polyline ? markersString : ''
      };
    }

    var uri = finalUri.build();
    return uri;
  }
}
