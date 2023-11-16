library maps_places_autocomplete;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maps_places_autocomplete/model/place.dart';
import 'package:maps_places_autocomplete/service/address_service.dart';
import 'package:uuid/uuid.dart';

import 'model/suggestion.dart';

export 'package:maps_places_autocomplete/model/place.dart';
export 'package:maps_places_autocomplete/model/suggestion.dart';

typedef ReportValidationFailureAndRequestFocusCallback = bool Function(
    String errorMessageForThisFailedValidation);

class MapsPlacesAutocompleteTextFormField extends StatefulWidget {
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

  final TextEditingController? controller;

  final bool requiredField;

  final Key? textFormFieldKey;

  final ReportValidationFailureAndRequestFocusCallback?
      reportValidationFailAndRequestFocus;

  // These correspond to arguments supported by standard Flutter TextFormField
  final String? initialValue;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final bool autofocus;
  final bool readOnly;
  final bool? showCursor;
  final String obscuringCharacter;
  final bool obscureText;
  final bool autocorrect;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final GestureTapCallback? onTap;
  final TapRegionCallback? onTapOutside;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final bool? enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  final InputCounterWidgetBuilder? buildCounter;
  final ScrollPhysics? scrollPhysics;
  final Iterable<String>? autofillHints;
  final AutovalidateMode? autovalidateMode;
  final ScrollController? scrollController;
  final bool enableIMEPersonalizedLearning;
  final MouseCursor? mouseCursor;
  final EditableTextContextMenuBuilder? contextMenuBuilder;
  final String? Function(String?)? validator;


  static String? defaultValidator(String? testThisData) {
    return null;
  }

  const MapsPlacesAutocompleteTextFormField(
      {Key? key,
      this.controller,
      this.requiredField = false,
      this.validator = defaultValidator,
      this.textFormFieldKey,
      this.reportValidationFailAndRequestFocus,
      this.debounceTime = 600,
      this.prepareQuery,
      this.onClearClick,
      this.onInitialSuggestionClick,
      this.onSuggestionClick,
      this.onSuggestionClickGetTextToUseForControl,
      required this.mapsApiKey,
      required this.buildItem,
      this.clearButton,
      this.containerDecoration,
      this.elevation,
      this.overlayOffset = 4,
      this.showGoogleTradeMark = false,
      this.postalCodeLookup = false,
      this.componentCountry,
      this.language,
      
      // arg passthroughs to TextFormField - same defaults as TextFormField
      this.initialValue,
      this.focusNode,
      this.decoration,
      this.keyboardType,
      this.textCapitalization = TextCapitalization.none,
      this.textInputAction,
      this.style,
      this.strutStyle,
      this.textDirection,
      this.textAlign = TextAlign.start,
      this.textAlignVertical,
      this.autofocus = false,
      this.readOnly = false,
      this.showCursor,
      this.obscuringCharacter = '•',
      this.obscureText = false,
      this.autocorrect = true,
      this.smartDashesType,
      this.smartQuotesType,
      this.enableSuggestions = true,
      this.maxLengthEnforcement,
      this.maxLines,
      this.minLines,
      this.expands = false,
      this.maxLength,
      this.onChanged,
      this.onTap,
      this.onTapOutside,
      this.onEditingComplete,
      this.onFieldSubmitted,
      this.inputFormatters,
      this.enabled,
      this.cursorWidth = 2.0,
      this.cursorHeight,
      this.cursorRadius,
      this.cursorColor,
      this.keyboardAppearance,
      this.scrollPadding = const EdgeInsets.all(20.0),
      this.enableInteractiveSelection,
      this.selectionControls,
      this.buildCounter,
      this.scrollPhysics,
      this.autofillHints,
      this.autovalidateMode,
      this.scrollController,
      this.enableIMEPersonalizedLearning = true,
      this.mouseCursor,
      this.contextMenuBuilder,
      
      })
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MapsPlacesAutocompleteTextFormField();
}

class _MapsPlacesAutocompleteTextFormField extends State<MapsPlacesAutocompleteTextFormField> {
  final layerLink = LayerLink();
  final String sessionToken = const Uuid().v4();

  // [_controller] is not final because it is possible that the dispose() can happen
  //  if caller does setState(), so we must be able to set it to null after dispose so that any
  //  of our pending callbacks can detect if it has been disposed and not use it.
  TextEditingController? _controller;
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
     debugPrint('_MapsPlacesAutocompleteTextFormField() init() called!!!!');
    super.initState();
    _controller = widget.controller ?? TextEditingController(text:widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();

    _addressService = AddressService(sessionToken, widget.mapsApiKey,
        widget.componentCountry, widget.language);

    _focusNode.addListener(showOrHideOverlayOnFocusChange);
  }

  @override
  void dispose() {
    debugPrint('_MapsPlacesAutocompleteTextFormField() dispose() called!!!!');
    
    if(widget.controller==null) {
      _controller!.dispose(); // only dispose if we created it
      _controller = null;
    }
    if(widget.focusNode==null) {
      _focusNode.dispose(); // only dispose if we created it
    } else {
      // remove the listener so it's doesn't get stale, we will put it back later
      _focusNode.removeListener(showOrHideOverlayOnFocusChange);
    }

    _debounceTimer?.cancel();
    super.dispose();
  }

  void weHaveValidationErrorRequestFocusIfAvailable( String validationErrorMsg ) {
    // If there is an error for this input then request focus here
    // so form scrolls to show this
    // We only do this if another widget has not *already* requested the focus,
    // so the first field with an error in the form will be the field that gets the
    // focus, instead of the last.
    bool focusRequestedAlready = false;
    if (widget.reportValidationFailAndRequestFocus != null) {
      focusRequestedAlready =
          widget.reportValidationFailAndRequestFocus!.call(validationErrorMsg);
    }
    if (!focusRequestedAlready) {
      _focusNode.requestFocus();
    }
  }

  String? validatorWithFocusHandlingWrapper(String? value) {
    // first handle required field error if this is an empty value
    if(widget.requiredField && (value==null || value=='')) {
      const String validateErrorMsg = 'This field is required.';
      weHaveValidationErrorRequestFocusIfAvailable( validateErrorMsg );
      return validateErrorMsg;
    }
    // and now check value validation if there is a validation callback
    if (widget.validator != null) {
      String? validateRetMsg = widget.validator!.call(value);
      if (validateRetMsg != null) {
        // failed validation 
        weHaveValidationErrorRequestFocusIfAvailable(validateRetMsg);
      }
      return validateRetMsg;
    } else {
      return null;
    }
  }

  void showOverlay() {
    if(context.mounted) {
      if (context.findRenderObject() != null) {
        final overlay = Overlay.of(context);
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final size = renderBox.size;
        entry = OverlayEntry(
            builder: (overlayBuildContext) => Positioned(
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
      _controller?.clear();
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
              _controller?.text =
                  widget.onSuggestionClickGetTextToUseForControl!(place) ?? '';
            } else {
              // default to full formatted address
              _controller?.text = place.formattedAddress ?? '';
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
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(Duration(milliseconds: widget.debounceTime), () async {
      await searchAddress(text);
      if(widget.onChanged!=null) {
        widget.onChanged!(text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: Stack(
        children: [
          TextFormField(
              focusNode: _focusNode,
              controller: _controller,
              onChanged: onTextChanges,
              decoration: getInputDecoration(),

              key: widget.textFormFieldKey,
              validator:
                  widget.validator != null ? validatorWithFocusHandlingWrapper : null,
              onEditingComplete: widget.onEditingComplete,

              // passthru args
              keyboardType: widget.keyboardType,
              textCapitalization: widget.textCapitalization,
              textInputAction: widget.textInputAction,
              style: widget.style,
              strutStyle: widget.strutStyle,
              textDirection: widget.textDirection,
              textAlign: widget.textAlign,
              textAlignVertical: widget.textAlignVertical,
              autofocus: widget.autofocus,
              readOnly: widget.readOnly,
              showCursor: widget.showCursor,
              obscuringCharacter: widget.obscuringCharacter,
              obscureText: widget.obscureText,
              autocorrect: widget.autocorrect,
              smartDashesType: widget.smartDashesType,
              smartQuotesType: widget.smartQuotesType,
              enableSuggestions: widget.enableSuggestions,
              maxLengthEnforcement: widget.maxLengthEnforcement,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              expands: widget.expands,
              maxLength: widget.maxLength,
              onTap: widget.onTap,
              onTapOutside: widget.onTapOutside,
              onFieldSubmitted: widget.onFieldSubmitted,
              inputFormatters: widget.inputFormatters,
              enabled: widget.enabled,
              cursorWidth: widget.cursorWidth,
              cursorHeight: widget.cursorHeight,
              cursorRadius: widget.cursorRadius,
              cursorColor: widget.cursorColor,
              keyboardAppearance: widget.keyboardAppearance,
              scrollPadding: widget.scrollPadding,
              enableInteractiveSelection: widget.enableInteractiveSelection,
              selectionControls: widget.selectionControls,
              buildCounter: widget.buildCounter,
              scrollPhysics: widget.scrollPhysics,
              autofillHints: widget.autofillHints,
              autovalidateMode: widget.autovalidateMode,
              scrollController: widget.scrollController,
              enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
              mouseCursor: widget.mouseCursor,
              contextMenuBuilder: widget.contextMenuBuilder,
          ),
        ],
      ),
    );
  }
}
