import 'package:test_app_cities/src/features/cities/data/model/city_model.dart';
import 'package:test_app_cities/src/features/cities/domain/repositories/cities_repository.dart';

class CitiesUseCase {
  final CitiesRepository citiesRepository;

  CitiesUseCase({required this.citiesRepository});

  Future<List<CityModel>> getCities({String? search}) async {
    return await citiesRepository.getCities(search: search);
  }
}
