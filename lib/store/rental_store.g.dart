// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rental_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$RentalStore on RentalStoreBase, Store {
  late final _$rentalListAtom =
      Atom(name: 'RentalStoreBase.rentalList', context: context);

  @override
  ObservableList<OrderData> get rentalList {
    _$rentalListAtom.reportRead();
    return super.rentalList;
  }

  @override
  set rentalList(ObservableList<OrderData> value) {
    _$rentalListAtom.reportWrite(value, super.rentalList, () {
      super.rentalList = value;
    });
  }

  late final _$mPageAtom =
      Atom(name: 'RentalStoreBase.mPage', context: context);

  @override
  int get mPage {
    _$mPageAtom.reportRead();
    return super.mPage;
  }

  @override
  set mPage(int value) {
    _$mPageAtom.reportWrite(value, super.mPage, () {
      super.mPage = value;
    });
  }

  late final _$mIsLastPageAtom =
      Atom(name: 'RentalStoreBase.mIsLastPage', context: context);

  @override
  bool get mIsLastPage {
    _$mIsLastPageAtom.reportRead();
    return super.mIsLastPage;
  }

  @override
  set mIsLastPage(bool value) {
    _$mIsLastPageAtom.reportWrite(value, super.mIsLastPage, () {
      super.mIsLastPage = value;
    });
  }

  late final _$isErrorAtom =
      Atom(name: 'RentalStoreBase.isError', context: context);

  @override
  bool get isError {
    _$isErrorAtom.reportRead();
    return super.isError;
  }

  @override
  set isError(bool value) {
    _$isErrorAtom.reportWrite(value, super.isError, () {
      super.isError = value;
    });
  }

  late final _$RentalStoreBaseActionController =
      ActionController(name: 'RentalStoreBase', context: context);

  @override
  void clearRentalList() {
    final _$actionInfo = _$RentalStoreBaseActionController.startAction(
        name: 'RentalStoreBase.clearRentalList');
    try {
      return super.clearRentalList();
    } finally {
      _$RentalStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addRentals(List<OrderData> rentals) {
    final _$actionInfo = _$RentalStoreBaseActionController.startAction(
        name: 'RentalStoreBase.addRentals');
    try {
      return super.addRentals(rentals);
    } finally {
      _$RentalStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLastPage(bool value) {
    final _$actionInfo = _$RentalStoreBaseActionController.startAction(
        name: 'RentalStoreBase.setLastPage');
    try {
      return super.setLastPage(value);
    } finally {
      _$RentalStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPage(int page) {
    final _$actionInfo = _$RentalStoreBaseActionController.startAction(
        name: 'RentalStoreBase.setPage');
    try {
      return super.setPage(page);
    } finally {
      _$RentalStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setError(bool value) {
    final _$actionInfo = _$RentalStoreBaseActionController.startAction(
        name: 'RentalStoreBase.setError');
    try {
      return super.setError(value);
    } finally {
      _$RentalStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
rentalList: ${rentalList},
mPage: ${mPage},
mIsLastPage: ${mIsLastPage},
isError: ${isError}
    ''';
  }
}
