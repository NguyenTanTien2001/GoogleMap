import 'package:flutter_maps/model/place_search.dart';
import 'package:flutter_maps/secrets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class PlacesService {
  Future<List<PlaceSearch>> getAutocomplete(String search) async {
    var url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&key=${Secrets.API_KEY}";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var json = convert.jsonDecode(response.body);
      var jsonResult = json['predictions'] as List;
      return jsonResult.map((place) => PlaceSearch.fromJson(place)).toList();
    } else {
      throw Exception();
    }
  }
}
