import 'package:flutter/material.dart';
import 'package:maps_places_autocomplete/api/place_api_provider.dart';
import 'package:maps_places_autocomplete/model/suggestion.dart';

class AddressSearch extends SearchDelegate<Suggestion> {
  AddressSearch(this.sessionToken) {
    apiClient = PlaceApiProvider(sessionToken);
  }

  final sessionToken;
  late PlaceApiProvider apiClient;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pushReplacementNamed(context, '/home');
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
        // We will put the api call here
        future: query == "" ? null : apiClient.fetchSuggestions(query),
        builder: (context, snapshot) {
          if (query == '') {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: const Text('Enter your address'),
            );
          } else if (snapshot.hasData) {
            List<Suggestion> data = snapshot.data as List<Suggestion>;
            return ListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  // we will display the data returned from our future here
                  title: Text(data[index].description),
                  onTap: () {
                    close(context, data[index]);
                  },
                );
              },
              itemCount: data.length,
            );
          } else {
            return const Text('Loading...');
          }
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    throw UnimplementedError();
  }
}