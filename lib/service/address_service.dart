import 'package:maps_places_autocomplete/api/place_api_provider.dart';
import 'package:maps_places_autocomplete/model/place.dart';
import 'package:maps_places_autocomplete/model/suggestion.dart';

class AddressService {
  AddressService(this.sessionToken, this.mapsApiKey) {
    apiClient = PlaceApiProvider(sessionToken, mapsApiKey);
  }

  final String sessionToken;
  final String mapsApiKey;
  late PlaceApiProvider apiClient;

  Future<List<Suggestion>> search(String query) async {
    return await apiClient.fetchSuggestions(query);
  }

  Future<Place> getPlaceDetail(String placeId) async {
    Place placeDetails = await apiClient.getPlaceDetailFromId(placeId);
    return placeDetails;
  }
}
