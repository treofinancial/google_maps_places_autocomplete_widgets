import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:maps_places_autocomplete/model/place.dart';
import 'package:maps_places_autocomplete/model/suggestion.dart';

/* FOR DEBUGGING */
void printWrapped(String text) {
  final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

void printJson(dynamic json, { String? title }) {
  JsonEncoder encoder = new JsonEncoder.withIndent('  '); 

  // encode it to string
  String prettyPrint = encoder.convert(json); 

  if(title!=null) {
    print(title);
  }
  printWrapped( prettyPrint );
}

const bool debugJson = true;
/* END FOR DEBUGGING */

class PlaceApiProvider {
  final client = Client();

  PlaceApiProvider(this.sessionToken, this.mapsApiKey, this.compomentCountry, this.language);

  final String sessionToken;
  final String mapsApiKey;
  final String? compomentCountry;
  final String? language;

  Future<List<Suggestion>> fetchSuggestions(String input) async {
    final Map<String, dynamic> parameters = <String, dynamic>{
      'input': input,
      'types': 'address',
      'key': mapsApiKey,
      'sessiontoken': sessionToken
    };

    if (language !=  null) {
      parameters.addAll(<String, dynamic>{'language': language});
    }
    if (compomentCountry != null) {
      parameters.addAll(<String, dynamic>{'components': 'country:$compomentCountry'});
    }

    final Uri request = Uri(
        scheme: 'https',
        host: 'maps.googleapis.com',
        path: '/maps/api/place/autocomplete/json',
        queryParameters: parameters);

    final response = await client.get(request);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {

        if(debugJson) printJson(result['predictions'],title:'GOOGLE MAP API RETURN VALUE result["predictions"]');

        // compose suggestions in a list
        return result['predictions']
            .map<Suggestion>((p) => Suggestion(p['place_id'], p['description']))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<Place> getPlaceDetailFromId(String placeId) async {
    // if you want to get the details of the selected place by place_id
    final Map<String, dynamic> parameters = <String, dynamic>{
      'place_id': placeId,  
      'fields': 'name,formatted_address,address_component,geometry',
      'key': mapsApiKey,
      'sessiontoken': sessionToken
    };
    final Uri request = Uri(
        scheme: 'https',
        host: 'maps.googleapis.com',
        path: '/maps/api/place/details/json',

   //PlaceApiNew     host: 'places.googleapis.com',
   //PlaceApiNew     path: '/v1/places/$placeId',

        queryParameters: parameters);

    print(request.toString());

    final response = await client.get(request);
    /* PlaceApiNew:
        , headers: {
            'X-Goog-Api-Key': mapsApiKey,
            'X-Goog-FieldMask': 'displayName,formattedAddress',
      });
    PlaceApiNew */

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {

        if(debugJson) printJson(result['result'],title:'GOOGLE MAP API RETURN VALUE result["result"]');

        final components =
            result['result']['address_components'] as List<dynamic>;

        // build result
        final place = Place();

        place.formattedAddress = result['result']['formatted_address'];
        place.name = result['result']['name'];
        place.lat = result['result']['geometry']['location']['lat'] as double;
        place.lng = result['result']['geometry']['location']['lng'] as double;

        components.forEach((c) {
          final List type = c['types'];
          if (type.contains('street_address')) {
            place.streetAddress = c['long_name'];
          }
          if (type.contains('street_number')) {
            place.streetNumber = c['long_name'];
          }
          if (type.contains('route')) {
            place.street = c['long_name'];
            place.streetShort = c['short_name'];
          }
          if (type.contains('sublocality') || type.contains('sublocality_level_1') ) {
            place.vicinity = c['long_name'];
          }
          if (type.contains('locality')) {
            place.city = c['long_name'];
          }
          if (type.contains('administrative_area_level_2')) {
            place.county = c['long_name'];
          }
          if (type.contains('administrative_area_level_1')) {
            place.state = c['long_name'];
            place.stateShort = c['short_name'];
          }
          if (type.contains('country')) {
            place.country = c['long_name'];
          }
          if (type.contains('postal_code')) {
            place.zipCode = c['long_name'];
          }
          if (type.contains('postal_code_suffix')) {
            place.zipCodeSuffix = c['long_name'];
          }
        });

        place.zipCodePlus4 ??= '${place.zipCode}${place.zipCodeSuffix!=null?'-${place.zipCodeSuffix}':''}';
        place.streetAddress ??= '${place.streetNumber} ${place.streetShort}';
        place.formattedAddress ??= '${place.streetNumber} ${place.streetShort}, ${place.city}, ${place.stateShort} ${place.zipCode}';
        place.formattedAddressZipPlus4 ??= '${place.streetNumber} ${place.streetShort}, ${place.city}, ${place.stateShort} ${place.zipCodePlus4}';
        return place;
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}
