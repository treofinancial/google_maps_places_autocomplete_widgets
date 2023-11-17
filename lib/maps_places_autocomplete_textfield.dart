library maps_places_autocomplete;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maps_places_autocomplete/maps_places_autocomplete_generic.dart';
import 'package:maps_places_autocomplete/model/place.dart';
import 'package:maps_places_autocomplete/service/address_service.dart';
import 'package:uuid/uuid.dart';

import 'model/suggestion.dart';

export 'package:maps_places_autocomplete/model/place.dart';
export 'package:maps_places_autocomplete/model/suggestion.dart';

class MapsPlacesAutocompleteTextField extends MapsPlacesAutocompleteStatefulWidget {

  @override
  /// Callback triggered before sending query to google places API.
  /// This allows the caller to prepare the query, modifying it in any way.  It might be
  /// used for adding things like City, State, Zip that may be already entered in other
  /// form elements.
  final String Function(String address)? prepareQuery;

  @override
  ///Callback triggered when user clicks clear icon.  This can be useful if the caller wants to clear other
  /// address fields that may be in their form.
  final void Function()? onClearClick;

  @override
  ///Callback triggered when a address item is selected, allows chance to 
  /// clear other fields awaiting [Place] details in [onSuggestionClick]
  /// or to use the [Suggestion] information directly.
  final void Function(Suggestion suggestion)? onInitialSuggestionClick;

  @override
  ///Callback triggered when after Place has been retreived after item is selected
  final void Function(Place place)? onSuggestionClick;

  @override
  ///Callback triggered when a item is selected
  final String? Function(Place place)? onSuggestionClickGetTextToUseForControl;

  @override
  ///Your Google Maps API key, this is required. 
  final String mapsApiKey;

  @override
  ///builder used to render each item displayed
  ///must not be null
  final Widget Function(Suggestion, int) buildItem;

  @override
  ///Hover color around [buildItem] widget on desktop platforms.
  final Color? hoverColor;

  @override
  ///Selection color around [buildItem] widget on desktop platforms.
  final Color? selectionColor;

  @override
  ///builder used to render a clear, it can be null, but in that case, a clear button is not displayed
  final Icon? clearButton;

  @override
  ///BoxDecoration for the suggestions external container
  final BoxDecoration? suggestionsOverlayDecoration;

  @override
  ///InputDecoration, if none is given, it defaults to flutter standards
  final InputDecoration? decoration;

  @override
  ///Elevation for the suggestion list
  final double? elevation;

  @override
  ///Offset between the TextField and the Overlay
  final double overlayOffset;

  @override
  ///if true, shows "powered by google" inside the suggestion list, after its items
  final bool showGoogleTradeMark;

  @override
  ///used to narrow down address search
  final String? componentCountry;

  @override
  ///Inform Google places of desired language the results should be returned.
  final String? language;

  @override
  ///PostalCode lookup instead of address lookup (defaults to false)
  final bool postalCodeLookup;

  @override
  ///debounce time in milliseconds (default 600)
  final int debounceTime;


  @override
  final TextEditingController? controller;


  @override
  final String? initialValue;

  @override
  final FocusNode? focusNode;



  // inherited TextField arguments
  @override
  final TextInputType? keyboardType;

  @override
  final TextCapitalization textCapitalization;

  @override
  final TextInputAction? textInputAction;

  @override
  final TextStyle? style;

  @override
  final StrutStyle? strutStyle;

  @override
  final TextAlign textAlign;

  @override
  final TextAlignVertical? textAlignVertical;

  @override
  final TextDirection? textDirection;

  @override
  final bool autofocus;

  @override
  final bool readOnly;

  @override
  final int? maxLines;

  @override
  final int? minLines;

  @override
  final bool expands;

  @override
  final bool? showCursor;

  @override
  final int? maxLength;

  @override
  final MaxLengthEnforcement? maxLengthEnforcement;

  @override
  final ValueChanged<String>? onChanged;

  const MapsPlacesAutocompleteTextField(
      {
      super.key,
      this.controller,
      this.focusNode,
      this.initialValue,
      this.prepareQuery,
      this.onClearClick,
      this.onInitialSuggestionClick,
      this.onSuggestionClick,
      this.onSuggestionClickGetTextToUseForControl,
      required this.mapsApiKey,
      required this.buildItem,
      this.hoverColor,
      this.selectionColor,      
      this.clearButton,
      this.suggestionsOverlayDecoration,
      this.decoration,
      this.elevation,
      this.overlayOffset = 4,
      this.showGoogleTradeMark = false,
      this.postalCodeLookup = false,
      this.debounceTime = 600,
      this.componentCountry,
      this.language,
      
      // inherited TextField arguments
      this.keyboardType,
      this.textCapitalization = TextCapitalization.none,
      this.textInputAction,
      this.style,
      this.strutStyle,
      this.textAlign = TextAlign.start,
      this.textAlignVertical,
      this.textDirection,
      this.autofocus = false,
      this.readOnly = false,
      this.showCursor,
      this.maxLines = 1,
      this.minLines,
      this.expands = false,
      this.maxLength,
      this.maxLengthEnforcement,
      this.onChanged,
      });

  @override
  State<StatefulWidget> createState() => _MapsPlacesAutocomplete();
}

class _MapsPlacesAutocomplete extends State<MapsPlacesAutocompleteTextField>
        with SuggestionOverlayMixin
        implements OverlaySuggestionDetails {
          
  @override
  final LayerLink layerLink = LayerLink();

  @override
  final String sessionToken = const Uuid().v4();

  @override
  TextEditingController? controller;

  @override
  late final FocusNode focusNode;

  @override
  late AddressService addressService;

  @override
  OverlayEntry? entry;

  @override
  List<Suggestion> suggestions = [];

  @override
  Timer? debounceTimer;
/*
  void showOrHideOverlayOnFocusChange () {
    debugPrint('showOrHideOverlayOnFocusChange');
    if (focusNode.hasFocus) {
      showOverlay();
    } else {
      hideOverlay();
    }
  }
*/
  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    focusNode = FocusNode();

    addressService = AddressService(sessionToken, widget.mapsApiKey,
        widget.componentCountry, widget.language);

    focusNode.addListener(showOrHideOverlayOnFocusChange);
  }

  @override
  void dispose() {
    focusNode.removeListener(showOrHideOverlayOnFocusChange);

    controller?.dispose();
    focusNode.dispose();
    debounceTimer?.cancel();
    super.dispose();
  }
/*
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
      controller.clear();
      focusNode.unfocus();
      suggestions = [];
    });
  }

  List<Widget> buildList() {
    debugPrint('buildList _suggestions.length=${suggestions.length}');
    List<Widget> list = [];
    for (int i = 0; i < suggestions.length; i++) {
      Suggestion s = suggestions[i];
      Widget w = InkWell(
        hoverColor: widget.hoverColor,
        highlightColor: widget.selectionColor,        
        child: widget.buildItem(s, i),
        onTap: () async {
          hideOverlay();
          focusNode.unfocus();
          if (widget.onInitialSuggestionClick != null) {
            widget.onInitialSuggestionClick!(s);
          }
          if (widget.onSuggestionClickGetTextToUseForControl != null ||
              widget.onSuggestionClick != null) {
            // If they need more details now do async request
            // for Place details..
            Place place = await addressService.getPlaceDetail(s.placeId);
            if (widget.onSuggestionClickGetTextToUseForControl != null) {
              controller.text =
                  widget.onSuggestionClickGetTextToUseForControl!(place) ?? '';
            } else {
              // default to full formatted address
              controller.text = place.formattedAddress ?? '';
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

  Widget buildOverlay() => 
      TextFieldTapRegion(
        child:
        Material(
        color: widget.suggestionsOverlayDecoration != null
            ? Colors.transparent
            : Colors.white,
        elevation: widget.elevation ?? 0,
        child: Container(
          decoration: widget.suggestionsOverlayDecoration ?? const BoxDecoration(),
          child: Column(
            children: [
              ...buildList(),
              if (widget.showGoogleTradeMark)
                const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text('powered by google'),
                )
            ],
          ),
        )
      )
    );

  String _lastText = '';
  Future<void> searchAddress(String text) async {
    if(widget.prepareQuery!=null) {
      text = widget.prepareQuery!(text);
    }
    if (text != _lastText && text.isNotEmpty) {
      _lastText = text;
      suggestions = await addressService.search(text,
          includeFullSuggestionDetails: (widget.onInitialSuggestionClick != null),
          postalCodeLookup: widget.postalCodeLookup);
    }
    if(entry!=null) {
      entry!.markNeedsBuild();
    }
  }

  InputDecoration getInputDecoration() {
    if (widget.decoration != null) {
      if (widget.clearButton != null) {
        return widget.decoration!.copyWith(
            suffixIcon: IconButton(
          icon: widget.clearButton!,
          onPressed: _clearText,
        ));
      }
      return widget.decoration!;
    }
    return const InputDecoration();
  }

  void onTextChanges(text) async {
    if (debounceTimer?.isActive ?? false) debounceTimer!.cancel();
    debounceTimer = Timer(Duration(milliseconds: widget.debounceTime), () async {
      await searchAddress(text);
    });
  }
*/
  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: Stack(
        children: [
          TextField(
              focusNode: focusNode,
              controller: controller,
              onChanged: onTextChanges,
              decoration: getInputDecoration(),
              keyboardType: widget.keyboardType,
              textCapitalization: widget.textCapitalization,
              textInputAction: widget.textInputAction,
              style: widget.style,
              strutStyle: widget.strutStyle,
              textAlign: widget.textAlign,
              textAlignVertical: widget.textAlignVertical,
              textDirection: widget.textDirection,
              autofocus: widget.autofocus,
              readOnly: widget.readOnly,
              showCursor: widget.showCursor,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              expands: widget.expands,
              maxLength: widget.maxLength,
              maxLengthEnforcement: widget.maxLengthEnforcement,
            ),
        ],
      ),
    );
  }
}
