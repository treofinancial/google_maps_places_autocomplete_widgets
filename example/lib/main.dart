import 'package:flutter/material.dart';
import 'package:maps_places_autocomplete/maps_places_autocomplete.dart';
import 'package:maps_places_autocomplete/model/place.dart';

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


  String? _streetNumber;
  String? _street;
  String? _city;
  String? _state;
  String? _zipCode;
  String? _vicinity;
  String? _country;
  double? _lat;
  double? _lng;

  // write a function to receive the place details callback
  void onSuggestionClick(Place placeDetails) {
    setState(() {
      _streetNumber = placeDetails.streetNumber;
      _street = placeDetails.street;
      _city = placeDetails.city;
      _state = placeDetails.state;
      _zipCode = placeDetails.zipCode;
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
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                
                /******** */
                //import the plugin
                // and configure
                MapsPlacesAutocomplete(
                  onSuggestionClick: onSuggestionClick
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
                    Text('Número: ${_streetNumber ?? '---'}'),
                    Text('Endereço: ${_street ?? '---'}'),
                    Text('Bairro: ${_vicinity ?? '---'}'),
                    Text('Cidade: ${_city ?? '---'}'),
                    Text('Estado: ${_state ?? '---'}'),
                    Text('País: ${_country ?? '---'}'),
                    Text('CEP: ${_zipCode ?? '---'}'),
                    Text('Latitude: ${_lat ?? '---'}'),
                    Text('Longitude: ${_lng ?? '---'}'),
                  ]),
                )
                
              ],
            ),
          ),
        ));
  }
}
