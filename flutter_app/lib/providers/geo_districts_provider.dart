import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'geo_districts_provider.g.dart';

/// GeoJSON district data model
class GeoDistrict {
  final String name;
  final int province;
  final String provinceName;
  final List<List<List<double>>> rings;

  const GeoDistrict({
    required this.name,
    required this.province,
    required this.provinceName,
    required this.rings,
  });

  factory GeoDistrict.fromJson(Map<String, dynamic> json) {
    return GeoDistrict(
      name: json['name'] ?? '',
      province: json['province'] ?? 0,
      provinceName: json['province_name'] ?? '',
      rings: (json['rings'] as List?)
              ?.map((ring) => (ring as List)
                  .map((point) => (point as List).cast<double>().toList())
                  .toList())
              .toList() ??
          [],
    );
  }

  /// Calculate centroid of the district
  (double lon, double lat) get centroid {
    if (rings.isEmpty || rings.first.isEmpty) return (0, 0);

    double sumLon = 0, sumLat = 0;
    int count = 0;
    for (final ring in rings) {
      for (final point in ring) {
        sumLon += point[0];
        sumLat += point[1];
        count++;
      }
    }
    return count > 0 ? (sumLon / count, sumLat / count) : (0, 0);
  }
}

/// GeoJSON districts collection
class GeoDistrictsData {
  final String source;
  final int count;
  final List<GeoDistrict> districts;

  const GeoDistrictsData({
    required this.source,
    required this.count,
    required this.districts,
  });

  factory GeoDistrictsData.fromJson(Map<String, dynamic> json) {
    return GeoDistrictsData(
      source: json['source'] ?? '',
      count: json['count'] ?? 0,
      districts: (json['districts'] as List?)
              ?.map((d) => GeoDistrict.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// GeoJSON local unit data model
class GeoLocalUnit {
  final String name;
  final String type;
  final List<List<List<double>>> rings;

  const GeoLocalUnit({
    required this.name,
    required this.type,
    required this.rings,
  });

  factory GeoLocalUnit.fromJson(Map<String, dynamic> json) {
    return GeoLocalUnit(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      rings: (json['rings'] as List?)
              ?.map((ring) => (ring as List)
                  .map((point) => (point as List).cast<double>().toList())
                  .toList())
              .toList() ??
          [],
    );
  }

  /// Calculate centroid of the local unit
  (double lon, double lat) get centroid {
    if (rings.isEmpty || rings.first.isEmpty) return (0, 0);

    double sumLon = 0, sumLat = 0;
    int count = 0;
    for (final ring in rings) {
      for (final point in ring) {
        sumLon += point[0];
        sumLat += point[1];
        count++;
      }
    }
    return count > 0 ? (sumLon / count, sumLat / count) : (0, 0);
  }
}

/// GeoJSON local units for a district
class GeoLocalUnitsData {
  final String district;
  final int count;
  final List<GeoLocalUnit> localUnits;

  const GeoLocalUnitsData({
    required this.district,
    required this.count,
    required this.localUnits,
  });

  factory GeoLocalUnitsData.fromJson(Map<String, dynamic> json) {
    return GeoLocalUnitsData(
      district: json['district'] ?? '',
      count: json['count'] ?? 0,
      localUnits: (json['local_units'] as List?)
              ?.map((lu) => GeoLocalUnit.fromJson(lu as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Provider for GeoJSON district boundaries
@Riverpod(keepAlive: true)
Future<GeoDistrictsData> geoDistricts(GeoDistrictsRef ref) async {
  final jsonString = await rootBundle.loadString('assets/data/election/districts_geo.json');
  final json = jsonDecode(jsonString) as Map<String, dynamic>;
  return GeoDistrictsData.fromJson(json);
}

/// Provider for GeoJSON local units of a specific district
@riverpod
Future<GeoLocalUnitsData> geoLocalUnits(GeoLocalUnitsRef ref, String districtName) async {
  // Convert district name to filename
  final filename = districtName
      .toLowerCase()
      .replaceAll(' ', '_')
      .replaceAll('(', '')
      .replaceAll(')', '');

  try {
    final jsonString = await rootBundle.loadString('assets/data/election/local_units/$filename.json');
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return GeoLocalUnitsData.fromJson(json);
  } catch (e) {
    // Return empty data if file not found
    return GeoLocalUnitsData(
      district: districtName,
      count: 0,
      localUnits: [],
    );
  }
}

/// Selected GeoJSON district provider
@riverpod
class SelectedGeoDistrict extends _$SelectedGeoDistrict {
  @override
  GeoDistrict? build() => null;

  void select(GeoDistrict? district) => state = district;
  void clear() => state = null;
}

/// Selected GeoJSON local unit provider
@riverpod
class SelectedGeoLocalUnit extends _$SelectedGeoLocalUnit {
  @override
  GeoLocalUnit? build() => null;

  void select(GeoLocalUnit? unit) => state = unit;
  void clear() => state = null;
}
