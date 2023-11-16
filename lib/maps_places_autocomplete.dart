library maps_places_autocomplete;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maps_places_autocomplete/model/place.dart';
import 'package:maps_places_autocomplete/service/address_service.dart';
import 'package:uuid/uuid.dart';

import 'model/suggestion.dart';

export 'package:maps_places_autocomplete/model/place.dart';
export 'package:maps_places_autocomplete/model/suggestion.dart';

class MapsPlacesAutocomplete extends StatefulWidget {
  /// This allows the caller to prepare the query, modifying it in any way.  It might be
  /// used for adding things like City, State, Zip that may be already entered in other
  /// form elements.
  final String Function(String address)? prepareQuery;

  ///called when user clicks clear icon.  This can be useful if the caller wants to clear other
  /// address fields that may be in their form.
  final void Function()? onClearClick;

  ///callback triggered when a address item is selected, allows chance to 
  /// clear other fields awaiting [Place] details in [onSuggestionClick]
  /// or to use the [Suggestion] information directly.
  final void Function(Suggestion suggestion)? onInitialSuggestionClick;

  ///callback triggered when after Place has been retreived after item is selected
  final void Function(Place place)? onSuggestionClick;

  ///callback triggered when a item is selected
  final String? Function(Place place)? onSuggestionClickGetTextToUseForControl;

  ///your maps api key, must not be null
  final String mapsApiKey;

  ///builder used to render each item displayed
  ///must not be null
  final Widget Function(Suggestion, int) buildItem;

  ///builder used to render a clear, it can be null, but in that case, a clear button is not displayed
  final Icon? clearButton;

  ///BoxDecoration for the suggestions external container
  final BoxDecoration? containerDecoration;

  ///InputDecoration, if none is given, it defaults to flutter standards
  final InputDecoration? inputDecoration;

  ///Elevation for the suggestion list
  final double? elevation;

  ///Offset between the TextField and the Overlay
  final double overlayOffset;

  ///if true, shows "powered by google" inside the suggestion list, after its items
  final bool showGoogleTradeMark;

  ///used to narrow down address search
  final String? componentCountry;

  ///in witch language the results are being returned
  final String? language;

  ///PostalCode lookup instead of address lookup (defaults to false)
  final bool postalCodeLookup;

  ///debounce time in milliseconds (default 600)
  final int debounceTime;

  const MapsPlacesAutocomplete(
      {Key? key,
      this.prepareQuery,
      this.onClearClick,
      this.onInitialSuggestionClick,
      this.onSuggestionClick,
      this.onSuggestionClickGetTextToUseForControl,
      required this.mapsApiKey,
      required this.buildItem,
      this.clearButton,
      this.containerDecoration,
      this.inputDecoration,
      this.elevation,
      this.overlayOffset = 4,
      this.showGoogleTradeMark = false,
      this.postalCodeLookup = false,
      this.debounceTime = 600,
      this.componentCountry,
      this.language})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MapsPlacesAutocomplete();
}

class _MapsPlacesAutocomplete extends State<MapsPlacesAutocomplete> {
  final layerLink = LayerLink();
  final String sessionToken = const Uuid().v4();
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late AddressService _addressService;
  OverlayEntry? entry;
  List<Suggestion> _suggestions = [];
  Timer? _debounceTimer;

  void showOrHideOverlayOnFocusChange () {
    if (_focusNode.hasFocus) {
      showOverlay();
    } else {
      hideOverlay();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    _addressService = AddressService(sessionToken, widget.mapsApiKey,
        widget.componentCountry, widget.language);

    _focusNode.addListener(showOrHideOverlayOnFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(showOrHideOverlayOnFocusChange);

    _controller.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void showOverlay() {
    if (context.findRenderObject() != null) {
      final overlay = Overlay.of(context);
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final size = renderBox.size;
      entry = OverlayEntry(
          builder: (context) => Positioned(
                width: size.width,
                child: CompositedTransformFollower(
                    link: layerLink,
                    showWhenUnlinked: false,
                    offset: Offset(0, size.height + widget.overlayOffset),
                    child: buildOverlay()),
              ));
      overlay.insert(entry!);
    }
  }

  void hideOverlay() {
    entry?.remove();
    entry = null;
  }

  void _clearText() {
    setState(() {
      if(widget.onClearClick!=null) {
        widget.onClearClick!();
      }
      _controller.clear();
      _focusNode.unfocus();
      _suggestions = [];
    });
  }

  List<Widget> buildList() {
    List<Widget> list = [];
    for (int i = 0; i < _suggestions.length; i++) {
      Suggestion s = _suggestions[i];
      Widget w = InkWell(
        child: widget.buildItem(s, i),
        onTap: () async {
          hideOverlay();
          _focusNode.unfocus();
          if (widget.onInitialSuggestionClick != null) {
            widget.onInitialSuggestionClick!(s);
          }
          if (widget.onSuggestionClickGetTextToUseForControl != null ||
              widget.onSuggestionClick != null) {
            // If they need more details now do async request
            // for Place details..
            Place place = await _addressService.getPlaceDetail(s.placeId);
            if (widget.onSuggestionClickGetTextToUseForControl != null) {
              _controller.text =
                  widget.onSuggestionClickGetTextToUseForControl!(place) ?? '';
            } else {
              // default to full formatted address
              _controller.text = place.formattedAddress ?? '';
            }
            if (widget.onSuggestionClick != null) {
              widget.onSuggestionClick!(place);
            }
          }
        },
      );
      list.add(w);
    }
    return list;
  }

  Widget buildOverlay() => Material(
      color: widget.containerDecoration != null
          ? Colors.transparent
          : Colors.white,
      elevation: widget.elevation ?? 0,
      child: Container(
        decoration: widget.containerDecoration ?? const BoxDecoration(),
        child: Column(
          children: [
            ...buildList(),
            if (widget.showGoogleTradeMark)
              const Padding(
                padding: EdgeInsets.all(4.0),
                child: Text("powered by google"),
              )
          ],
        ),
      ));

  String _lastText = "";
  Future<void> searchAddress(String text) async {
    if(widget.prepareQuery!=null) {
      text = widget.prepareQuery!(text);
    }
    if (text != _lastText && text != "") {
      _lastText = text;
      _suggestions = await _addressService.search(text,
          includeFullSuggestionDetails: (widget.onInitialSuggestionClick != null),
          postalCodeLookup: widget.postalCodeLookup);
    }
    if(entry!=null) {
      entry!.markNeedsBuild();
    }
  }

  InputDecoration getInputDecoration() {
    if (widget.inputDecoration != null) {
      if (widget.clearButton != null) {
        return widget.inputDecoration!.copyWith(
            suffixIcon: IconButton(
          icon: widget.clearButton!,
          onPressed: _clearText,
        ));
      }
      return widget.inputDecoration!;
    }
    return const InputDecoration();
  }

  void onTextChanges(text) async {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(Duration(milliseconds: widget.debounceTime), () async {
      await searchAddress(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: Stack(
        children: [
          TextField(
              focusNode: _focusNode,
              controller: _controller,
              onChanged: onTextChanges,
              decoration: getInputDecoration()),
        ],
      ),
    );
  }
}
