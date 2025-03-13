import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class HomeEvent {}

class LoadHomeData extends HomeEvent {}

// States
abstract class HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<String> banners;
  final List<String> categories;

  HomeLoaded({required this.banners, required this.categories});
}

// Bloc Implementation
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeLoading()) {
    on<LoadHomeData>((event, emit) {
      // Mock data
      final banners = [
        'Big News',
        'Apply now',
        'Post Now',
      ];
      final categories = [
        'Cooking', 'Pet care', 'Gardening',
        'Transport', 'Carpenter', 'Shopping',
        'Delivery', 'Package & Lifting', 'Cleaning'
      ];

      emit(HomeLoaded(banners: banners, categories: categories));
    });
  }
}
