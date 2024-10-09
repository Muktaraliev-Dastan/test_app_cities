import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app_cities/src/features/cities/data/repositories/cities_repository_impl.dart';
import 'package:test_app_cities/src/features/cities/domain/use_cases/cities_use_case.dart';
import 'package:test_app_cities/src/internal/helpers/api_requester.dart';
import 'package:test_app_cities/src/features/cities/data/model/city_model.dart';

part 'providers.g.dart';

@riverpod
ApiRequester apiRequester(ApiRequesterRef ref) {
  return ApiRequester();
}

@riverpod
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) async {
  return await SharedPreferences.getInstance();
}

@riverpod
Future<CitiesRepositoryImpl> citiesRepositoryImpl(
    CitiesRepositoryImplRef ref) async {
  final apiRequester = ref.watch(apiRequesterProvider);
  final sharedPreferences = await ref.watch(sharedPreferencesProvider.future);

  return CitiesRepositoryImpl(
    apiRequester: apiRequester,
    sharedPreferences: sharedPreferences,
  );
}

@riverpod
Future<CitiesUseCase> citiesUseCase(CitiesUseCaseRef ref) async {
  final citiesRepositoryAsyncValue =
      await ref.watch(citiesRepositoryImplProvider.future);

  return CitiesUseCase(citiesRepository: citiesRepositoryAsyncValue);
}

class CitiesStateNotifier extends StateNotifier<List<CityModel>> {
  final CitiesUseCase citiesUseCase;

  CitiesStateNotifier({required this.citiesUseCase}) : super([]);

  Future<void> fetchCities({String? search}) async {
    try {
      final cities = await citiesUseCase.getCities(search: search);
      state = cities;
    } catch (e) {
      print('Ошибка при получении городов: $e');
    }
  }
}

@riverpod
class CitiesState extends _$CitiesState {
  @override
  AsyncValue<List<CityModel>> build() {
    return const AsyncValue.loading();
  }

  Future<void> fetchCities({String? search}) async {
    state = const AsyncValue.loading();

    final citiesUseCase = await ref.watch(citiesUseCaseProvider.future);

    try {
      final cities = await citiesUseCase.getCities(search: search);
      state = AsyncValue.data(cities);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
