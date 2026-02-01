import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/earthquake.dart';

part 'earthquake_provider.g.dart';

/// SeismoNepal - Official Nepal earthquake data source
const _seismoNepalUrl = 'http://www.seismonepal.gov.np/';

/// CORS proxy for web (SeismoNepal doesn't have CORS headers)
const _corsProxy = 'https://api.codetabs.com/v1/proxy?quest=';

/// USGS API endpoint for earthquakes in Himalayan region (fallback)
const _usgsApiUrl = 'https://earthquake.usgs.gov/fdsnws/event/1/query';

/// Fetch recent earthquakes from SeismoNepal (official source)
@riverpod
Future<List<Earthquake>> recentEarthquakes(Ref ref) async {
  try {
    // Try SeismoNepal first (official Nepal data)
    final earthquakes = await _fetchFromSeismoNepal();
    if (earthquakes.isNotEmpty) {
      return earthquakes;
    }
  } catch (e) {
    // Fall through to USGS
    // debugPrint('SeismoNepal fetch failed: $e');
  }

  // Fallback to USGS for wider Himalayan region
  return _fetchFromUsgs();
}

/// Parse earthquake data from SeismoNepal HTML table
Future<List<Earthquake>> _fetchFromSeismoNepal() async {
  // Use CORS proxy on web
  final url = kIsWeb
      ? '$_corsProxy$_seismoNepalUrl'
      : _seismoNepalUrl;

  final response = await http.get(Uri.parse(url));

  if (response.statusCode != 200) {
    throw Exception('Failed to fetch from SeismoNepal: ${response.statusCode}');
  }

  final html = response.body;
  final earthquakes = <Earthquake>[];

  // Parse the table rows using regex
  final rowPattern = RegExp(
    r'<tr data-key="[^"]*">\s*'
    r'<td>\d+</td>\s*'
    r'<td>B\.S\.: ([^<]+)\s*<br>\s*A\.D\.: ([^<]+)\s*</td>'
    r'<td>Local: ([^<]+)\s*<br>\s*UTC: ([^<]+)\s*</td>\s*'
    r'<td>([^<]+)</td>'  // latitude
    r'<td>([^<]+)</td>'  // longitude
    r'<td>([^<]+)</td>'  // magnitude
    r'<td><a href="([^"]*)"[^>]*>([^<]+)</a>',
    multiLine: true,
    dotAll: true,
  );

  for (final match in rowPattern.allMatches(html)) {
    try {
      final dateAd = match.group(2)?.trim() ?? '';
      final timeUtc = match.group(4)?.trim() ?? '';
      final lat = double.tryParse(match.group(5)?.trim() ?? '') ?? 0;
      final lon = double.tryParse(match.group(6)?.trim() ?? '') ?? 0;
      final mag = double.tryParse(match.group(7)?.trim() ?? '') ?? 0;
      final mapPath = match.group(8) ?? '';
      final place = match.group(9)?.trim().replaceAll('*', '') ?? '';

      // Parse date and time
      DateTime? time;
      try {
        // dateAd format: "2025-08-22", timeUtc format: "17:30"
        final parts = dateAd.split('-');
        final timeParts = timeUtc.split(':');
        if (parts.length == 3 && timeParts.length >= 2) {
          time = DateTime.utc(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
        }
      } catch (_) {
        time = DateTime.now();
      }

      earthquakes.add(Earthquake(
        id: 'seismonepal_${lat}_${lon}_${mag}',
        magnitude: mag,
        place: place,
        time: time ?? DateTime.now(),
        latitude: lat,
        longitude: lon,
        depth: 10.0, // SeismoNepal doesn't show depth in main table
        url: mapPath.isNotEmpty ? 'http://www.seismonepal.gov.np$mapPath' : null,
      ));
    } catch (e) {
      // Skip malformed entries
      continue;
    }
  }

  return earthquakes;
}

/// Fetch from USGS API (wider Himalayan region)
Future<List<Earthquake>> _fetchFromUsgs() async {
  final now = DateTime.now();
  final startTime = now.subtract(const Duration(days: 30));

  // Wider region: Nepal + Northern India + Tibet + Bhutan
  final uri = Uri.parse(_usgsApiUrl).replace(queryParameters: {
    'format': 'geojson',
    'starttime': startTime.toIso8601String().split('T')[0],
    'endtime': now.toIso8601String().split('T')[0],
    'minlatitude': '24',
    'maxlatitude': '32',
    'minlongitude': '78',
    'maxlongitude': '92',
    'minmagnitude': '2.0',
    'orderby': 'time',
    'limit': '50',
  });

  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw Exception('Failed to fetch from USGS: ${response.statusCode}');
  }

  final json = jsonDecode(response.body) as Map<String, dynamic>;
  final features = json['features'] as List;

  return features
      .map((f) => Earthquake.fromUsgs(f as Map<String, dynamic>))
      .toList();
}

/// Earthquake filter state
@riverpod
class EarthquakeMinMagnitude extends _$EarthquakeMinMagnitude {
  @override
  double build() => 2.5;

  void set(double value) => state = value;
}

/// Filtered earthquakes based on magnitude
@riverpod
List<Earthquake> filteredEarthquakes(Ref ref) {
  final earthquakes = ref.watch(recentEarthquakesProvider);
  final minMag = ref.watch(earthquakeMinMagnitudeProvider);

  return earthquakes.when(
    data: (list) => list.where((e) => e.magnitude >= minMag).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}
