class CityData {
  static const Map<String, List<String>> countryCities = {
    'COLOMBIA': [
      'MEDELLIN',
      'BOGOTA',
      'CALI',
      'BARRANQUILLA',
      'CARTAGENA',
      'BUCARAMANGA',
      'SANTA_MARTA',
      'MANIZALES',
      'PEREIRA',
      'ARMENIA',
    ],
    'ARGENTINA': [
      'BUENOS_AIRES',
      'CORDOBA',
      'ROSARIO',
      'Mendoza',
      'TUCUMAN',
      'CHACO',
      'CORRIENTES',
      'NEUQUEN',
    ],
    'CHILE': [
      'SANTIAGO',
      'VALPARAISO',
      'CONCEPCION',
      'LA_SERENA',
      'ANTOFAGASTA',
      'RANCAGUA',
      'TALCA',
      'CHILLAN',
    ],
    'MEXICO': [
      'MEXICO_CITY',
      'GUADALAJARA',
      'MONTERREY',
      'CANCUN',
      'PUEBLA',
      'TOLUCA',
      'VERACRUZ',
      'LEON',
      'TIJUANA',
      'MERIDA',
    ],
    'PERU': [
      'LIMA',
      'AREQUIPA',
      'CUSCO',
      'TRUJILLO',
      'CHICLAYO',
      'IQUITOS',
      'HUANCAYO',
      'PIURA',
      'CALLAO',
      'AYACUCHO',
    ],
    'ECUADOR': [
      'QUITO',
      'GUAYAQUIL',
      'CUENCA',
      'MACHALA',
      'SANTO_DOMINGO',
      'MANTA',
      'PORTOVIEJO',
      'AMBATO',
      'MILAGRO',
      'ESMERALDAS',
    ],
    'PANAMA': [
      'PANAMA_CITY',
      'COLON',
      'DAVID',
      'BOCAS_DEL_TORO',
      'PENONOME',
      'CHITRE',
      'SANTIAGO',
      'LA_CHORRERA',
      'AGUADULCE',
      'LOS_SANTOS',
    ],
    'COSTA_RICA': [
      'SAN_JOSE',
      'ALAJUELA',
      'CARTAGO',
      'HEREDIA',
      'LIBERIA',
      'LIMON',
      'PUNTARENAS',
      'QUEPOS',
      'TURRIALBA',
      'CORDOBILLA',
    ],
    'URUGUAY': [
      'MONTEVIDEO',
      'SALTO',
      'PUNTA_DEL_ESTE',
      'COLONIA',
      'MALDONADO',
      'Paysandu',
      'RIVERA',
      'ARTIGAS',
      'CERRO_LARGO',
      'SORIANO',
    ],
    'BRAZIL': [
      'SAO_PAULO',
      'RIO_DE_JANEIRO',
      'BRASILIA',
      'SALVADOR',
      'FORTALEZA',
      'BELO_HORIZONTE',
      'MANAUS',
      'CURITIBA',
      'RECIFE',
      'PORTO_ALEGRE',
    ],
  };

  static List<String> get countryList => countryCities.keys.toList();

  static List<String> getCitiesForCountry(String country) =>
      countryCities[country] ?? [];

  static String? findNearestCity(
    double userLat,
    double userLng,
    String country,
    Map<String, Map<String, double>> cityCoords,
  ) {
    final cities = getCitiesForCountry(country);
    if (cities.isEmpty) return null;

    String? nearestCity;
    double minDistance = double.infinity;

    for (final city in cities) {
      final coords = cityCoords[city];
      if (coords == null) continue;

      final cityLat = coords['lat']!;
      final cityLng = coords['lng']!;
      final distance = _calculateDistance(
        userLat,
        userLng,
        cityLat,
        cityLng,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestCity = city;
      }
    }

    return nearestCity ?? cities.first;
  }

  static double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    return _haversineDistance(lat1, lng1, lat2, lng2);
  }

  static double _haversineDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) *
            _cos(_toRadians(lat2)) *
            _sin(dLng / 2) *
            _sin(dLng / 2);
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degrees) => degrees * 3.141592653589793 / 180;
  static double _sin(double x) => _taylorSin(x);
  static double _cos(double x) => _taylorCos(x);
  static double _sqrt(double x) => _newtonSqrt(x);
  static double _atan2(double y, double x) => _approxAtan2(y, x);

  static double _taylorSin(double x) {
    x = x % (2 * 3.141592653589793);
    if (x > 3.141592653589793) x -= 2 * 3.141592653589793;
    if (x < -3.141592653589793) x += 2 * 3.141592653589793;
    double result = x;
    double term = x;
    for (int n = 1; n <= 10; n++) {
      term *= -x * x / ((2 * n) * (2 * n + 1));
      result += term;
    }
    return result;
  }

  static double _taylorCos(double x) {
    x = x % (2 * 3.141592653589793);
    if (x > 3.141592653589793) x -= 2 * 3.141592653589793;
    if (x < -3.141592653589793) x += 2 * 3.141592653589793;
    double result = 1;
    double term = 1;
    for (int n = 1; n <= 10; n++) {
      term *= -x * x / ((2 * n - 1) * (2 * n));
      result += term;
    }
    return result;
  }

  static double _newtonSqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 20; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  static double _approxAtan2(double y, double x) {
    if (x == 0) {
      if (y > 0) return 3.141592653589793 / 2;
      if (y < 0) return -3.141592653589793 / 2;
      return 0;
    }
    double atan = _taylorAtan(y / x);
    if (x < 0) {
      if (y >= 0) return atan + 3.141592653589793;
      return atan - 3.141592653589793;
    }
    return atan;
  }

  static double _taylorAtan(double x) {
    if (x.abs() > 1) {
      if (x > 1) return 3.141592653589793 / 2 - _taylorAtan(1 / x);
      return -3.141592653589793 / 2 - _taylorAtan(1 / x);
    }
    double result = x;
    double term = x;
    for (int n = 1; n <= 20; n++) {
      term *= -x * x;
      result += term / (2 * n + 1);
    }
    return result;
  }

  static Map<String, Map<String, double>> get cityCoordinates => {
        // COLOMBIA
        'MEDELLIN': {'lat': 6.2476, 'lng': -75.5658},
        'BOGOTA': {'lat': 4.7110, 'lng': -74.0721},
        'CALI': {'lat': 3.4516, 'lng': -76.5320},
        'BARRANQUILLA': {'lat': 10.9685, 'lng': -74.7813},
        'CARTAGENA': {'lat': 10.3910, 'lng': -75.4794},
        'BUCARAMANGA': {'lat': 7.1250, 'lng': -73.1198},
        'SANTA_MARTA': {'lat': 11.2404, 'lng': -74.2097},
        'MANIZALES': {'lat': 5.0689, 'lng': -75.5170},
        'PEREIRA': {'lat': 4.8133, 'lng': -75.6901},
        'ARMENIA': {'lat': 4.5350, 'lng': -75.6750},
        'IBAGUE': {'lat': 4.4360, 'lng': -75.2420},
        'NEIVA': {'lat': 2.9343, 'lng': -75.2818},
        'PASTO': {'lat': 1.2056, 'lng': -77.2804},
        'VILLavicencio': {'lat': 4.1510, 'lng': -73.6370},
        'CUCUTA': {'lat': 7.8890, 'lng': -72.5050},
        'VALLEDUPAR': {'lat': 10.4630, 'lng': -73.2530},
        'SOACHA': {'lat': 4.5833, 'lng': -74.2160},
        'MONTERIA': {'lat': 8.6913, 'lng': -75.8780},
        // ARGENTINA
        'BUENOS_AIRES': {'lat': -34.6037, 'lng': -58.3816},
        'CORDOBA': {'lat': -31.4201, 'lng': -64.1888},
        'ROSARIO': {'lat': -32.9442, 'lng': -60.6505},
        'Mendoza': {'lat': -32.8895, 'lng': -68.8458},
        'TUCUMAN': {'lat': -26.8083, 'lng': -65.2174},
        'CHACO': {'lat': -27.3333, 'lng': -58.6667},
        'CORRIENTES': {'lat': -27.4696, 'lng': -58.8311},
        'NEUQUEN': {'lat': -38.9533, 'lng': -68.0640},
        // CHILE
        'SANTIAGO': {'lat': -33.4489, 'lng': -70.6693},
        'VALPARAISO': {'lat': -33.0472, 'lng': -71.6127},
        'CONCEPCION': {'lat': -36.7861, 'lng': -73.0572},
        'LA_SERENA': {'lat': -29.9023, 'lng': -71.2524},
        'ANTOFAGASTA': {'lat': -23.6500, 'lng': -70.4000},
        'RANCAGUA': {'lat': -34.1700, 'lng': -70.7400},
        'TALCA': {'lat': -35.4264, 'lng': -71.9424},
        'CHILLAN': {'lat': -36.6066, 'lng': -72.1034},
        // MEXICO
        'MEXICO_CITY': {'lat': 19.4326, 'lng': -99.1332},
        'GUADALAJARA': {'lat': 20.6597, 'lng': -103.3496},
        'MONTERREY': {'lat': 25.6866, 'lng': -100.3161},
        'CANCUN': {'lat': 21.1619, 'lng': -86.8515},
        'PUEBLA': {'lat': 19.0414, 'lng': -98.2063},
        'TOLUCA': {'lat': 19.2826, 'lng': -99.5537},
        'VERACRUZ': {'lat': 19.1738, 'lng': -96.1349},
        'LEON': {'lat': 21.1168, 'lng': -101.6765},
        'TIJUANA': {'lat': 32.5149, 'lng': -117.0382},
        'MERIDA': {'lat': 20.9674, 'lng': -89.5926},
        // PERU
        'LIMA': {'lat': -12.0464, 'lng': -77.0428},
        'AREQUIPA': {'lat': -16.4090, 'lng': -71.5375},
        'CUSCO': {'lat': -13.5319, 'lng': -71.9675},
        'TRUJILLO': {'lat': -8.1116, 'lng': -79.0288},
        'CHICLAYO': {'lat': -6.7716, 'lng': -79.8395},
        'IQUITOS': {'lat': -3.7436, 'lng': -73.2516},
        'HUANCAYO': {'lat': -12.0651, 'lng': -75.2049},
        'PIURA': {'lat': -5.1945, 'lng': -80.6328},
        'CALLAO': {'lat': -12.0500, 'lng': -77.1300},
        'AYACUCHO': {'lat': -13.1588, 'lng': -74.2232},
        // ECUADOR
        'QUITO': {'lat': -0.1807, 'lng': -78.4678},
        'GUAYAQUIL': {'lat': -2.1894, 'lng': -79.8890},
        'CUENCA': {'lat': -2.9005, 'lng': -79.0059},
        'MACHALA': {'lat': -3.2583, 'lng': -79.9355},
        'SANTO_DOMINGO': {'lat': -0.3333, 'lng': -79.1667},
        'MANTA': {'lat': -0.9621, 'lng': -80.7127},
        'PORTOVIEJO': {'lat': -1.3544, 'lng': -80.4546},
        'AMBATO': {'lat': -1.2491, 'lng': -78.6168},
        'MILAGRO': {'lat': -1.9575, 'lng': -79.4693},
        'ESMERALDAS': {'lat': 0.9682, 'lng': -79.7117},
        // PANAMA
        'PANAMA_CITY': {'lat': 8.9824, 'lng': -79.5199},
        'COLON': {'lat': 9.3611, 'lng': -79.9000},
        'DAVID': {'lat': 8.4304, 'lng': -82.3409},
        'BOCAS_DEL_TORO': {'lat': 9.3401, 'lng': -82.2400},
        'PENONOME': {'lat': 8.5000, 'lng': -80.3610},
        'CHITRE': {'lat': 7.9667, 'lng': -80.6167},
        'LA_CHORRERA': {'lat': 8.9456, 'lng': -79.6537},
        // COSTA RICA
        'SAN_JOSE': {'lat': 9.9281, 'lng': -84.0907},
        'ALAJUELA': {'lat': 10.4024, 'lng': -84.4354},
        'CARTAGO': {'lat': 9.9760, 'lng': -83.7118},
        'HEREDIA': {'lat': 9.9910, 'lng': -84.1618},
        'LIBERIA': {'lat': 10.6323, 'lng': -85.4371},
        'LIMON': {'lat': 9.9901, 'lng': -83.0333},
        'PUNTARENAS': {'lat': 9.9658, 'lng': -84.8389},
        // URUGUAY
        'MONTEVIDEO': {'lat': -34.9011, 'lng': -56.1645},
        'SALTO': {'lat': -31.3889, 'lng': -57.9642},
        'PUNTA_DEL_ESTE': {'lat': -34.9667, 'lng': -54.9500},
        'COLONIA': {'lat': -34.4627, 'lng': -57.8398},
        'MALDONADO': {'lat': -34.7333, 'lng': -54.9167},
        'Paysandu': {'lat': -32.3172, 'lng': -58.0906},
        'RIVERA': {'lat': -30.8933, 'lng': -55.5508},
        // BRAZIL
        'SAO_PAULO': {'lat': -23.5505, 'lng': -46.6333},
        'RIO_DE_JANEIRO': {'lat': -22.9068, 'lng': -43.1729},
        'BRASILIA': {'lat': -15.7975, 'lng': -47.8919},
        'SALVADOR': {'lat': -12.9714, 'lng': -38.5014},
        'FORTALEZA': {'lat': -3.7172, 'lng': -38.5433},
        'BELO_HORIZONTE': {'lat': -19.9167, 'lng': -43.9345},
        'MANAUS': {'lat': -3.1190, 'lng': -60.0217},
        'CURITIBA': {'lat': -25.4284, 'lng': -49.2733},
        'RECIFE': {'lat': -8.0476, 'lng': -34.8770},
        'PORTO_ALEGRE': {'lat': -30.0346, 'lng': -51.2287},
      };
}