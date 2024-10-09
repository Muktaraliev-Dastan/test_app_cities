import 'package:test_app_cities/src/features/cities/data/model/city_model.dart';

abstract interface class CitiesRepository {
  Future<List<CityModel>> getCities({String? search});
}
