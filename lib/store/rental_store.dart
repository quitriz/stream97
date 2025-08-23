import 'package:mobx/mobx.dart';
import 'package:streamit_flutter/models/pmp_models/pay_per_view_orders_model.dart';

part 'rental_store.g.dart';

class RentalStore = RentalStoreBase with _$RentalStore;
abstract class RentalStoreBase with Store {
  @observable
  ObservableList<OrderData> rentalList = ObservableList<OrderData>();

  @action
  void clearRentalList() {
    rentalList.clear();
  }

  @action
  void addRentals(List<OrderData> rentals) {
    rentalList.addAll(rentals);
  }

  /// pagination
  @observable
  int mPage = 1;

  @observable
  bool mIsLastPage = false;

  @action
  void setLastPage(bool value) {
    mIsLastPage = value;
  }

  @action
  void setPage(int page) {
    mPage = page;
  }

  @observable
  bool isError = false;

  @action
  void setError(bool value) {
    isError = value;
  }
}


