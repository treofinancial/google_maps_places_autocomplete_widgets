library maps_places_autocomplete;

import 'package:flutter/material.dart';
import 'package:maps_places_autocomplete/api/place_api_provider.dart';
import 'package:maps_places_autocomplete/model/place.dart';
import 'package:maps_places_autocomplete/service/address_search.dart';
import 'package:uuid/uuid.dart';

import 'model/suggestion.dart';

class MapsPlacesAutocomplete extends StatefulWidget {
  final void Function(Place place) onSuggestionClick;

  const MapsPlacesAutocomplete({Key? key, required this.onSuggestionClick})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MapsPlacesAutocomplete();
}

class _MapsPlacesAutocomplete extends State<MapsPlacesAutocomplete> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: _controller,
          onTap: () async {
            final String sessionToken = const Uuid().v4();
            final Suggestion? result = await showSearch(
              context: context,
              delegate: AddressSearch(sessionToken),
            );

            //clique no resultado
            if (result != null) {
              final Place placeDetails = await PlaceApiProvider(sessionToken)
                  .getPlaceDetailFromId(result.placeId);
              
              setState(() {
                _controller.text = result.description;
                widget.onSuggestionClick(placeDetails);
              });
            }
          },
          decoration: const InputDecoration(
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              hintText: "Entre seu endereço de entrega",
              errorText: null),
        ),
      ],
    ));
  }
}
