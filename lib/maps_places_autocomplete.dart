library maps_places_autocomplete;

import 'package:flutter/material.dart';
import 'package:maps_places_autocomplete/model/place.dart';
import 'package:maps_places_autocomplete/service/address_service.dart';
import 'package:uuid/uuid.dart';

import 'model/suggestion.dart';

class MapsPlacesAutocomplete extends StatefulWidget {

  //callback triggered when a item is selected
  final void Function(Place place) onSuggestionClick;
  
  //your maps api key, must not be null
  final String mapsApiKey;

  //builder used to render each item displayed
  //must not be null
  final Widget Function(Suggestion, int) buildItem;

  //builder used to render a clear, it can be null, but in that case, a clear button is not displayed
  final Icon? clearButton;

  //BoxDecoration for the suggestions external container
  final BoxDecoration? containerDecoration;

  //InputDecoration, if none is given, it defaults to flutter standards
  final InputDecoration? inputDecoration;

  //Elevation for the suggestion list
  final double? elevation;

  //Offset between the TextField and the Overlay
  final double overlayOffset;

  //if true, shows "powered by google" inside the suggestion list, after its items
  final bool showGoogleTradeMark;

  //used to narrow down address search
  final String? componentCountry;

  //in witch language the results are being returned
  final String? language;

  const MapsPlacesAutocomplete(
      {Key? key,
      required this.onSuggestionClick,
      required this.mapsApiKey,
      required this.buildItem,
      this.clearButton,
      this.containerDecoration,
      this.inputDecoration,
      this.elevation,
      this.overlayOffset = 4,
      this.showGoogleTradeMark = true,
      this.componentCountry,
      this.language})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MapsPlacesAutocomplete();
}

class _MapsPlacesAutocomplete extends State<MapsPlacesAutocomplete> {
  final focusNode = FocusNode();
  final layerLink = LayerLink();
  final String sessionToken = const Uuid().v4();
  late TextEditingController _controller;
  late AddressService _addressService;
  OverlayEntry? entry;
  List<Suggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    _addressService = AddressService(sessionToken, widget.mapsApiKey,
        widget.componentCountry, widget.language);

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        showOverlay();
      } else {
        hideOverlay();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void showOverlay() {
    final overlay = Overlay.of(context)!;
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
        )
      );
    overlay.insert(entry!);
  }

  void hideOverlay() {
    entry?.remove();
    entry = null;
  }

  void _clearText() {
    setState(() {
      _controller.clear();
      focusNode.unfocus();
      _suggestions = [];
    });
  }

  List<Widget> buildList() {
    List<Widget> list = [];
    for (int i=0; i < _suggestions.length; i++) {
      Suggestion s = _suggestions[i];
      Widget w = InkWell(
        child: widget.buildItem(s, i),
        onTap: () async {
          _controller.text = s.description;
          hideOverlay();
          focusNode.unfocus();
          Place place = await _addressService.getPlaceDetail(s.placeId);
          widget.onSuggestionClick(place);
        },
      );
      list.add(w);
    }
    return list;
  }

  Widget buildOverlay() => Material(
    color: widget.containerDecoration != null ? Colors.transparent : Colors.white,
    elevation: widget.elevation ?? 0,
    child: Container(
      decoration: widget.containerDecoration ?? const BoxDecoration(),
      child: Column(
        children: [
          ...buildList(),
          if(widget.showGoogleTradeMark)
            const Padding(
              padding: EdgeInsets.all(4.0),
              child: Text("powered by google"),
            )
        ],
      ),
    ));

  String _lastText = "";
  Future<void> searchAddress(String text) async {
    if (text != _lastText && text != "") {
      _lastText = text;
      _suggestions = await _addressService.search(text);
    }
    entry!.markNeedsBuild();
  }

  InputDecoration getInputDecoration() {
    if(widget.inputDecoration != null) {
      if(widget.clearButton != null) {
        return widget.inputDecoration!.copyWith(
          suffixIcon: IconButton(
            icon: widget.clearButton!,
            onPressed: _clearText,
          )
        );
      }
      return widget.inputDecoration!;
    }
    return const InputDecoration();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: Stack(
        children: [
          TextField(
            focusNode: focusNode,
            controller: _controller,
            onChanged: (text) async => await searchAddress(text),
            decoration: getInputDecoration()
          ),
        ],
      ),
    );
  }
}
