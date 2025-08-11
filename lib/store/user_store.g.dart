// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UserStore on UserStoreBase, Store {
  late final _$loginEmailAtom =
      Atom(name: 'UserStoreBase.loginEmail', context: context);

  @override
  String get loginEmail {
    _$loginEmailAtom.reportRead();
    return super.loginEmail;
  }

  @override
  set loginEmail(String value) {
    _$loginEmailAtom.reportWrite(value, super.loginEmail, () {
      super.loginEmail = value;
    });
  }

  late final _$passwordAtom =
      Atom(name: 'UserStoreBase.password', context: context);

  @override
  String get password {
    _$passwordAtom.reportRead();
    return super.password;
  }

  @override
  set password(String value) {
    _$passwordAtom.reportWrite(value, super.password, () {
      super.password = value;
    });
  }

  late final _$setLoginEmailAsyncAction =
      AsyncAction('UserStoreBase.setLoginEmail', context: context);

  @override
  Future<void> setLoginEmail(String val, {bool isInitializing = false}) {
    return _$setLoginEmailAsyncAction
        .run(() => super.setLoginEmail(val, isInitializing: isInitializing));
  }

  late final _$setPasswordAsyncAction =
      AsyncAction('UserStoreBase.setPassword', context: context);

  @override
  Future<void> setPassword(String val, {bool isInitializing = false}) {
    return _$setPasswordAsyncAction
        .run(() => super.setPassword(val, isInitializing: isInitializing));
  }

  @override
  String toString() {
    return '''
loginEmail: ${loginEmail},
password: ${password}
    ''';
  }
}
