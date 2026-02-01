/// Earthquake data from USGS API
class Earthquake {
  final String id;
  final double magnitude;
  final String place;
  final DateTime time;
  final double latitude;
  final double longitude;
  final double depth;
  final String? url;
  final String? status;
  final int? felt;
  final String? alert;

  const Earthquake({
    required this.id,
    required this.magnitude,
    required this.place,
    required this.time,
    required this.latitude,
    required this.longitude,
    required this.depth,
    this.url,
    this.status,
    this.felt,
    this.alert,
  });

  factory Earthquake.fromUsgs(Map<String, dynamic> feature) {
    final props = feature['properties'] as Map<String, dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>;
    final coords = geometry['coordinates'] as List;

    return Earthquake(
      id: feature['id'] as String,
      magnitude: (props['mag'] as num?)?.toDouble() ?? 0.0,
      place: props['place'] as String? ?? 'Unknown location',
      time: DateTime.fromMillisecondsSinceEpoch(props['time'] as int),
      longitude: (coords[0] as num).toDouble(),
      latitude: (coords[1] as num).toDouble(),
      depth: (coords[2] as num).toDouble(),
      url: props['url'] as String?,
      status: props['status'] as String?,
      felt: props['felt'] as int?,
      alert: props['alert'] as String?,
    );
  }
}

/// Emergency contact information
class EmergencyContact {
  final String name;
  final String nameNp;
  final String number;
  final String? description;
  final String? descriptionNp;

  const EmergencyContact({
    required this.name,
    required this.nameNp,
    required this.number,
    this.description,
    this.descriptionNp,
  });
}

/// Static list of Nepal emergency contacts
const nepalEmergencyContacts = [
  EmergencyContact(
    name: 'Police',
    nameNp: 'प्रहरी',
    number: '100',
    description: 'Nepal Police Emergency',
    descriptionNp: 'नेपाल प्रहरी आपतकालीन',
  ),
  EmergencyContact(
    name: 'Ambulance',
    nameNp: 'एम्बुलेन्स',
    number: '102',
    description: 'Medical Emergency',
    descriptionNp: 'चिकित्सा आपतकालीन',
  ),
  EmergencyContact(
    name: 'Fire Brigade',
    nameNp: 'दमकल',
    number: '101',
    description: 'Fire Emergency',
    descriptionNp: 'आगलागी आपतकालीन',
  ),
  EmergencyContact(
    name: 'Tourist Police',
    nameNp: 'पर्यटक प्रहरी',
    number: '1144',
    description: 'Tourist Assistance',
    descriptionNp: 'पर्यटक सहायता',
  ),
  EmergencyContact(
    name: 'Weather Hotline',
    nameNp: 'मौसम हटलाइन',
    number: '1155',
    description: 'DHM Weather & Flood Info',
    descriptionNp: 'मौसम तथा बाढी जानकारी',
  ),
  EmergencyContact(
    name: 'Child Helpline',
    nameNp: 'बाल हेल्पलाइन',
    number: '1098',
    description: 'Child Protection',
    descriptionNp: 'बाल संरक्षण',
  ),
  EmergencyContact(
    name: 'Women Helpline',
    nameNp: 'महिला हेल्पलाइन',
    number: '1145',
    description: 'Women in Distress',
    descriptionNp: 'महिला सहायता',
  ),
  EmergencyContact(
    name: 'Traffic Police',
    nameNp: 'ट्राफिक प्रहरी',
    number: '103',
    description: 'Traffic Emergencies',
    descriptionNp: 'यातायात आपतकालीन',
  ),
];

/// External resource links
class EmergencyResource {
  final String name;
  final String nameNp;
  final String url;
  final String description;
  final String descriptionNp;
  final String icon;

  const EmergencyResource({
    required this.name,
    required this.nameNp,
    required this.url,
    required this.description,
    required this.descriptionNp,
    required this.icon,
  });
}

const emergencyResources = [
  EmergencyResource(
    name: 'Weather Alerts',
    nameNp: 'मौसम चेतावनी',
    url: 'https://www.dhm.gov.np/',
    description: 'DHM forecasts, flood warnings',
    descriptionNp: 'मौसम पूर्वानुमान, बाढी चेतावनी',
    icon: 'cloud',
  ),
  EmergencyResource(
    name: 'Road Status',
    nameNp: 'सडक स्थिति',
    url: 'https://navigate.dor.gov.np/app',
    description: 'Road closures & conditions',
    descriptionNp: 'सडक बन्द र अवस्था',
    icon: 'road',
  ),
  EmergencyResource(
    name: 'Earthquake Center',
    nameNp: 'भूकम्प केन्द्र',
    url: 'http://www.seismonepal.gov.np/',
    description: 'Nepal seismic monitoring',
    descriptionNp: 'नेपाल भूकम्प अनुगमन',
    icon: 'earthquake',
  ),
  EmergencyResource(
    name: 'Nepal Red Cross',
    nameNp: 'नेपाल रेडक्रस',
    url: 'https://nrcs.org/',
    description: 'Relief & blood donation',
    descriptionNp: 'राहत र रक्तदान',
    icon: 'medical',
  ),
  EmergencyResource(
    name: 'Disaster Portal',
    nameNp: 'विपद् पोर्टल',
    url: 'http://drrportal.gov.np/',
    description: 'Government disaster info',
    descriptionNp: 'सरकारी विपद् जानकारी',
    icon: 'warning',
  ),
  EmergencyResource(
    name: 'Air Quality',
    nameNp: 'वायु गुणस्तर',
    url: 'https://pollution.gov.np/',
    description: 'Air pollution monitoring',
    descriptionNp: 'वायु प्रदूषण अनुगमन',
    icon: 'air',
  ),
];
