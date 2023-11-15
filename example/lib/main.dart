import 'package:example/privatekeys.dart';
import 'package:flutter/material.dart';
import 'package:maps_places_autocomplete/maps_places_autocomplete.dart';
import 'package:maps_places_autocomplete/model/place.dart';
import 'package:maps_places_autocomplete/model/suggestion.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _formattedAddress;
  String? _formattedAddressZipPlus4;
  String? _streetAddress;
  String? _streetNumber;
  String? _street;
  String? _streetShort;
  String? _city;
  String? _county;
  String? _state;
  String? _stateShort;
  String? _zipCode;
  String? _zipCodeSuffix;
  String? _zipCodePlus4;
  String? _vicinity;
  String? _country;
  double? _lat;
  double? _lng;

  // write a function to receive the place details callback
  void onSuggestionClick(Place placeDetails) {
    setState(() {
      _formattedAddress = placeDetails.formattedAddress;
      _formattedAddressZipPlus4 = placeDetails.formattedAddressZipPlus4;
      _streetAddress = placeDetails.streetAddress;
      _streetNumber = placeDetails.streetNumber;
      _street = placeDetails.street;
      _streetShort = placeDetails.streetShort;
      _city = placeDetails.city;
      _county = placeDetails.county;
      _state = placeDetails.state;
      _stateShort = placeDetails.stateShort;
      _zipCode = placeDetails.zipCode;
      _zipCodeSuffix = placeDetails.zipCodeSuffix;
      _zipCodePlus4 = placeDetails.zipCodePlus4;
      _country = placeDetails.country;
      _vicinity = placeDetails.vicinity;
      _lat = placeDetails.lat;
      _lng = placeDetails.lng;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  //
                  /******** */
                  //import the plugin
                  // and configure
                  SizedBox(
                    height: 40,
                    child: MapsPlacesAutocomplete(
                      mapsApiKey: TIMS_ACCOUNT_GOOGLE_API_KEY,
                      onSuggestionClick: onSuggestionClick,
                      buildItem: (Suggestion suggestion, int index) {
                        return Container(
                          margin: const EdgeInsets.fromLTRB(2, 2, 2, 0),
                          padding: const EdgeInsets.all(8),
                          alignment: Alignment.centerLeft,
                          color: Colors.white,
                          child: Text(suggestion.description)
                        );
                      },
                      inputDecoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        hintText:
                            "Street number",
                        errorText: null),
                      clearButton: const Icon(Icons.close),
                      componentCountry: 'us',
                      language: 'en-Us'
                    ),
                  ),
                  /******** */
        
        
                  /******** */
                  // Use the details from callback
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text('FormattedAddress: ${_formattedAddress?? '---'}'),
                      Text('FormattedAddressZipPlus4: ${_formattedAddressZipPlus4?? '---'}'),
                      Text('StreetAddress: ${_streetAddress?? '---'}'),
                      Text('StreetNumber: ${_streetNumber ?? '---'}'),
                      Text('Street: ${_street ?? '---'}'),
                      Text('StreetShort: ${_streetShort ?? '---'}'),
                      Text('Vicinity: ${_vicinity ?? '---'}'),
                      Text('City: ${_city ?? '---'}'),
                      Text('County: ${_county ?? '---'}'),
                      Text('State: ${_state ?? '---'}'),
                      Text('StateShort: ${_stateShort ?? '---'}'),
                      Text('Country: ${_country ?? '---'}'),
                      Text('ZipCode: ${_zipCode ?? '---'}'),
                      Text('ZipCodeSuffix: ${_zipCodeSuffix ?? '---'}'),
                      Text('ZipCodePlus4: ${_zipCodePlus4 ?? '---'}'),
                      Text('Latitude: ${_lat ?? '---'}'),
                      Text('Longitude: ${_lng ?? '---'}'),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
