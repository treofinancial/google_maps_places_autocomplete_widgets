library maps_places_autocomplete;

import 'package:flutter/material.dart';
import 'package:maps_places_autocomplete/model/place.dart';
import 'package:maps_places_autocomplete/service/address_service.dart';
import 'package:uuid/uuid.dart';

import 'model/suggestion.dart';

class MapsPlacesAutocomplete extends StatefulWidget {
  final void Function(Place place) onSuggestionClick;
  final String mapsApiKey;
  final String? componentCountry;
  final String? language;

  const MapsPlacesAutocomplete(
      {Key? key,
      required this.onSuggestionClick,
      required this.mapsApiKey,
      this.componentCountry,
      this.language})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MapsPlacesAutocomplete();
}

class _MapsPlacesAutocomplete extends State<MapsPlacesAutocomplete> {
  final focusNode = FocusNode();
  late TextEditingController _controller;
  OverlayEntry? entry;
  final layerLink = LayerLink();
  final String sessionToken = const Uuid().v4();
  List<Suggestion> _suggestions = [];
  late AddressService _addressService;

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
    final offset = renderBox.localToGlobal(Offset.zero);
    entry = OverlayEntry(
        builder: (context) => Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 4,
              width: size.width,
              child: CompositedTransformFollower(
                  link: layerLink,
                  showWhenUnlinked: false,
                  offset: Offset(0, size.height + 4),
                  child: buildOverlay()),
            ));
    overlay.insert(entry!);
  }

  void hideOverlay() {
    entry?.remove();
    entry = null;
  }

  void _clearText() {
    setState(() {
      _controller.text = '';
      _suggestions = [];
    });
  }

  List<Widget> buildList() {
    List<Widget> list = [];
    _suggestions.forEach((s) {
      Widget w = InkWell(
        child: Container(
            margin: const EdgeInsets.fromLTRB(2, 2, 2, 0),
            padding: const EdgeInsets.all(8),
            width: MediaQuery.of(context).size.width,
            color: Colors.amber[50],
            child: Text(s.description)),
        onTap: () async {
          _controller.text = s.description;
          hideOverlay();
          focusNode.unfocus();
          Place place = await _addressService.getPlaceDetail(s.placeId);
          widget.onSuggestionClick(place);
        },
      );
      list.add(w);
    });
    return list;
  }

  Widget buildOverlay() => Material(
      elevation: 8,
      child: Container(
        color: Colors.amber,
        child: Column(
          children: [...buildList(), const Text("powered by google")],
        ),
      ));

  String _lastText = "";
  Future<void> searchAddress(String text) async {
    if (text != _lastText && text != "") {
      _lastText = text;
      _suggestions = await _addressService.search(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CompositedTransformTarget(
          link: layerLink,
          child: Stack(
            children: [
              TextField(
                focusNode: focusNode,
                controller: _controller,
                onChanged: (text) async => await searchAddress(text),
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    hintText:
                        "Digite o endereço com número para melhorar a busca",
                    errorText: null),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: InkWell(
                  onTap: _clearText,
                  child: Container(
                      height: 36,
                      width: 36,
                      color: Colors.blue,
                      child: const Icon(Icons.clear)),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
