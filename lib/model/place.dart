class Place {
  String? formattedAddress;
  String? streetAddress;
  String? streetNumber;
  String? streetShort;
  String? street;
  String? city;
  String? county;
  String? state;
  String? stateShort;
  String? zipCode;
  String? vicinity;
  String? country;
  double? lat;
  double? lng;

  Place({
    this.formattedAddress,
    this.streetAddress,
    this.streetNumber,
    this.streetShort,
    this.street,
    this.city,
    this.county,
    this.state,
    this.stateShort,
    this.zipCode,
    this.vicinity,
    this.country,
    this.lat,
    this.lng,
  });

  @override
  String toString() {
    return 'Place(formattedAddress:$formattedAddress streetNumber: $streetNumber, streetShort: $streetShort street: $street, city: $city, state:$state startShort:$stateShort county: $county, zipCode: $zipCode)';
  }
}