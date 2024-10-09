import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app_cities/src/features/cities/data/model/city_model.dart';
import 'package:test_app_cities/src/features/cities/domain/repositories/cities_repository.dart';
import 'package:test_app_cities/src/internal/helpers/api_requester.dart';
import 'package:test_app_cities/src/internal/helpers/catch_exception.dart';

class CitiesRepositoryImpl implements CitiesRepository {
  final ApiRequester apiRequester;
  final SharedPreferences sharedPreferences;

  CitiesRepositoryImpl(
      {required this.apiRequester, required this.sharedPreferences});

  @override
  Future<List<CityModel>> getCities({String? search}) async {
    try {
      final queryParams = search != null ? {'search': search} : null;
      Response response =
          await apiRequester.toGet('cities/', params: queryParams);

      if (response.statusCode == 200) {
        final List<CityModel> cities = (response.data as List)
            .map((city) => CityModel.fromJson(city))
            .toList();

        // Сохраняем данные в shared_preferences
        await sharedPreferences.setString('cities', response.data.toString());

        return cities;
      }
      throw response;
    } catch (error) {
      print(error);
      // Получаем данные из кэша, если запрос не удался
      final cachedData = sharedPreferences.getString('cities');
      if (cachedData != null) {
        return (cachedData as List)
            .map((city) => CityModel.fromJson(city))
            .toList();
      }
      throw CatchException.convertException(error);
    }
  }
}
