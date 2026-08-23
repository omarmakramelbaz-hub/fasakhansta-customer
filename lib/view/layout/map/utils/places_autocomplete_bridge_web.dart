import 'dart:async';
import 'dart:js' as js;

class WebPlacePrediction {
  final String description;
  final String placeId;

  const WebPlacePrediction({
    required this.description,
    required this.placeId,
  });
}

class WebPlaceDetails {
  final String formattedAddress;
  final double latitude;
  final double longitude;

  const WebPlaceDetails({
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
  });
}

js.JsObject? _placesNamespace() {
  final google = js.context['google'];
  if (google == null) return null;
  final maps = google['maps'];
  if (maps == null) return null;
  final places = maps['places'];
  return places is js.JsObject ? places : null;
}

Future<List<WebPlacePrediction>> getWebPlacePredictions({
  required String input,
  String countryCode = 'eg',
}) async {
  final places = _placesNamespace();
  if (places == null || input.trim().length < 2) return const [];

  final completer = Completer<List<WebPlacePrediction>>();

  try {
    final service = js.JsObject(places['AutocompleteService']);
    final request = js.JsObject.jsify({
      'input': input.trim(),
      'componentRestrictions': {'country': countryCode},
      'region': countryCode,
    });

    service.callMethod('getPlacePredictions', [
      request,
      js.allowInterop((dynamic predictions, dynamic status) {
        final results = <WebPlacePrediction>[];

        if (predictions is js.JsArray) {
          for (final item in predictions) {
            if (item is! js.JsObject) continue;
            final description = '${item['description'] ?? ''}'.trim();
            final placeId = '${item['place_id'] ?? ''}'.trim();
            if (description.isNotEmpty && placeId.isNotEmpty) {
              results.add(
                WebPlacePrediction(
                  description: description,
                  placeId: placeId,
                ),
              );
            }
          }
        }

        if (!completer.isCompleted) completer.complete(results);
      }),
    ]);
  } catch (_) {
    if (!completer.isCompleted) completer.complete(const []);
  }

  return completer.future.timeout(
    const Duration(seconds: 5),
    onTimeout: () => const [],
  );
}

Future<WebPlaceDetails?> getWebPlaceDetails({
  required String placeId,
}) async {
  final places = _placesNamespace();
  if (places == null || placeId.trim().isEmpty) return null;

  final completer = Completer<WebPlaceDetails?>();

  try {
    final document = js.context['document'];
    final container = document.callMethod('createElement', ['div']);
    final service = js.JsObject(places['PlacesService'], [container]);
    final request = js.JsObject.jsify({
      'placeId': placeId,
      'fields': ['formatted_address', 'geometry', 'name'],
    });

    service.callMethod('getDetails', [
      request,
      js.allowInterop((dynamic result, dynamic status) {
        try {
          if (result is! js.JsObject) {
            if (!completer.isCompleted) completer.complete(null);
            return;
          }

          final geometry = result['geometry'];
          final location = geometry is js.JsObject ? geometry['location'] : null;
          if (location is! js.JsObject) {
            if (!completer.isCompleted) completer.complete(null);
            return;
          }

          final lat = location.callMethod('lat');
          final lng = location.callMethod('lng');
          if (lat is! num || lng is! num) {
            if (!completer.isCompleted) completer.complete(null);
            return;
          }

          final formattedAddress = '${result['formatted_address'] ?? result['name'] ?? ''}'.trim();
          if (!completer.isCompleted) {
            completer.complete(
              WebPlaceDetails(
                formattedAddress: formattedAddress,
                latitude: lat.toDouble(),
                longitude: lng.toDouble(),
              ),
            );
          }
        } catch (_) {
          if (!completer.isCompleted) completer.complete(null);
        }
      }),
    ]);
  } catch (_) {
    if (!completer.isCompleted) completer.complete(null);
  }

  return completer.future.timeout(
    const Duration(seconds: 5),
    onTimeout: () => null,
  );
}
