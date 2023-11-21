# google_maps_places_autocomplete_widgets package

## 1.2.2

* Added `onFinishedEditingWithNoSuggestion` callback from https://github.com/leandro-zanardi/maps_places_autocomplete/pull/6

## 1.2.1

* Updated README.md, modified version number to properly reflect the number of internal versions
  iterated through before public release.

## 1.0.1

* Refactor suggestion query and overlay functionality to `SuggestionOverlayMixin`
  mixin via the clases `AddresssAutocompleteStatefulWidget` and
  `OverlaySuggestionDetails`.
* Refactor big gain is now there is a single version of all suggestiona and overlay
  functionality for both `AddressAutocompleteTextField` and
  `AddressAutocompleteTextFormField`.
* Extensive expansion of the `example/main.dart` example app to show most various
  features of the package.
* Moved to new package name and layout.

## 1.0.0

* Refactor package and create both `TextField` and `TextFormField` versions of the
  `AddressAutocompleteXXXX` widgets
* Add many more callback capabilities to allow modification of behavior in various
  ways.
* Added `TextFieldTapRegion` use for desktop support
* Extensive testing and bug fixing
* Add many more standard `Place` properties
* Change to retrieve additional formatted address info from google maps api
* Added support for zip code lookup

## 0.0.2

* Add custom layout config.

## 0.0.1

* Initial release.
