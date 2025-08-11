
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/constants.dart';

part 'user_store.g.dart';

class UserStore = UserStoreBase with _$UserStore;

abstract class UserStoreBase with Store {

  @observable
  String loginEmail = getStringAsync(SharePreferencesKey.LOGIN_EMAIL);

  @observable
  String password = getStringAsync(SharePreferencesKey.LOGIN_PASSWORD);

  @action
  Future<void> setLoginEmail(String val, {bool isInitializing = false}) async {
    loginEmail = val;
    if (!isInitializing) await setValue(SharePreferencesKey.LOGIN_EMAIL, val);
  }

  @action
  Future<void> setPassword(String val, {bool isInitializing = false}) async {
    password = val;
    if (!isInitializing) await setValue(SharePreferencesKey.LOGIN_PASSWORD, val);
  }


}