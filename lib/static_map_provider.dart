import 'dart:async';

import 'package:map_view/location.dart';
import 'package:uri/uri.dart';
import 'map_view.dart';
import 'locations.dart';
import 'directions_provider.dart';

class StaticMapProvider {
  final String googleMapsApiKey;
  static const int defaultZoomLevel = 4;
  static const int defaultWidth = 600;
  static const int defaultHeight = 400;

  StaticMapProvider(this.googleMapsApiKey);

  ///
  /// Creates a Uri for the Google Static Maps API
  /// Centers the map on [center] using a zoom of [zoomLevel]
  /// Specify a [width] and [height] that you would like the resulting image to be. The default is 600w x 400h
  ///

  Uri getStaticUri(Location center, int zoomLevel, {int width, int height}) {
    return _buildUrl(null, center, zoomLevel ?? defaultZoomLevel,
        width ?? defaultWidth, height ?? defaultHeight, false);
  }

  ///
  /// Creates a Uri for the Google Static Maps API using a list of locations to create pins on the map
  /// [locations] must have at least 1 location
  /// Specify a [width] and [height] that you would like the resulting image to be. The default is 600w x 400h
  ///

  Uri getStaticUriWithMarkers(List<Marker> markers, {int width, int height}) {
    return _buildUrl(
        markers, null, null, width ?? defaultWidth, height ?? defaultHeight, false);
  }
  
   Future<Uri> getStaticUriWithPolyLine(List<Marker> markers, {int width, int height}) async {
    return _buildUrl(
        markers, null, null, width ?? defaultWidth, height ?? defaultHeight, true);
  }

  Future<Uri> getStaticUriWithDirections(List<Marker> markers, {int width, int height}) async{
    DirectionsProvider directions = new DirectionsProvider(googleMapsApiKey);
    String polyline = await directions.getDirectionsPolyline(markers);
    return _buildUrl(markers, null, null, width, height, true, encoded_polyline: polyline);
  }

  ///
  /// Creates a Uri for the Google Static Maps API using an active MapView
  /// This method is useful for generating a static image
  /// [mapView] must currently be visible when you call this.
  /// Specify a [width] and [height] that you would like the resulting image to be. The default is 600w x 400h
  ///
  Future<Uri> getImageUriFromMap(MapView mapView,
      {int width, int height}) async {
    var markers = await mapView.visibleAnnotations;
    var center = await mapView.centerLocation;
    var zoom = await mapView.zoomLevel;
    return _buildUrl(markers, center, zoom.toInt(), width ?? defaultWidth,
        height ?? defaultHeight, false);
  }

  Uri _buildUrl(List<Marker> locations, Location center, int zoomLevel,
      int width, int height, bool polyline, {String encoded_polyline=''}) {
    var finalUri = new UriBuilder()
      ..scheme = 'https'
      ..host = 'maps.googleapis.com'
      ..port = 443
      ..path = '/maps/api/staticmap';

    if (center == null && (locations == null || locations.length == 0)) {
      center = Locations.centerOfUSA;
    }

    if (locations == null || locations.length == 0) {
      if (center == null) center = Locations.centerOfUSA;
      finalUri.queryParameters = {
        'center': '${center.latitude},${center.longitude}',
        'zoom': zoomLevel.toString(),
        'size': '${width ?? defaultWidth}x${height ?? defaultHeight}',
        'key': googleMapsApiKey,
      };
    } else {
      List<String> markers = new List();
      locations.forEach((location) {
        num lat = location.latitude;
        num lng = location.longitude;
        String marker = '$lat,$lng';
        markers.add(marker);
      });
      String markersString = markers.join('|');
      finalUri.queryParameters = {
        'markers': markersString,
        'size': '${width ?? defaultWidth}x${height ?? defaultHeight}',
        'key': googleMapsApiKey,
        'path' : polyline ? (encoded_polyline.isEmpty ? markersString : 'enc:' + encoded_polyline ) : '',
      };
    }
    var uri = finalUri.build();
    String temp = uri.toString() + '&style=element:geometry%7Ccolor:0xf5f5f5&style=element:labels.icon%7Cvisibility:off&style=element:labels.text.fill%7Ccolor:0x616161&style=element:labels.text.stroke%7Ccolor:0xf5f5f5&style=feature:administrative.land_parcel%7Celement:labels.text.fill%7Ccolor:0xbdbdbd&style=feature:administrative.neighborhood%7Cvisibility:off&style=feature:poi%7Celement:geometry%7Ccolor:0xeeeeee&style=feature:poi%7Celement:labels.text%7Cvisibility:off&style=feature:poi%7Celement:labels.text.fill%7Ccolor:0x757575&style=feature:poi.park%7Celement:geometry%7Ccolor:0xe5e5e5&style=feature:poi.park%7Celement:labels.text.fill%7Ccolor:0x9e9e9e&style=feature:road%7Celement:geometry%7Ccolor:0xffffff&style=feature:road%7Celement:labels%7Cvisibility:off&style=feature:road.arterial%7Celement:labels.text.fill%7Ccolor:0x757575&style=feature:road.highway%7Celement:geometry%7Ccolor:0xdadada&style=feature:road.highway%7Celement:labels.text.fill%7Ccolor:0x616161&style=feature:road.local%7Celement:labels.text.fill%7Ccolor:0x9e9e9e&style=feature:transit.line%7Celement:geometry%7Ccolor:0xe5e5e5&style=feature:transit.station%7Celement:geometry%7Ccolor:0xeeeeee&style=feature:water%7Celement:geometry%7Ccolor:0xc9c9c9&style=feature:water%7Celement:labels.text%7Cvisibility:off&style=feature:water%7Celement:labels.text.fill%7Ccolor:0x9e9e9e';
    print(temp);
    uri = Uri.parse(temp);
    print (uri.toString());
    return uri;
  }
}
