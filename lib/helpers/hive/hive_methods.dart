import 'package:hive/hive.dart';

class HiveMethods {
  static final HiveMethods _instance = HiveMethods._internal();

  factory HiveMethods() {
    return _instance;
  }

  HiveMethods._internal();

  static final _box = Hive.box('app');

  static String getLang() => _box.get('lang', defaultValue: 'ar');

  static void updateLang(String lang) => _box.put('lang', lang);

  static String? getToken() => _box.get('token');

  static void updateToken(String token) => _box.put('token', token);

  static void deleteToken() => _box.delete('token');

  static int? getUserId() => _box.get('userId');

  static void updateUserId(int? userId) => _box.put('userId', userId);

  static void deleteUserId() => _box.delete('userId');

  static bool isFirstTime() => _box.get('isFirstTime', defaultValue: true);

  static void updateFirstTime() => _box.put('isFirstTime', false);

  static double? getLat() => _box.get('lat');

  static void updateLat(double lat) => _box.put('lat', lat);

  static void deleteLat() => _box.delete('lat');

  static double? getLan() => _box.get('lan');

  static void deleteLan() => _box.delete('lan');

  static void updateLan(double lan) => _box.put('lan', lan);

  static int? getSelectedCity() => _box.get('selectedCity');

  static void updateSelectedCity(int cityId) => _box.put('selectedCity', cityId);

  static void deleteSelectedCity() => _box.delete('selectedCity');

  static int? getSelectedCityAreaId() => _box.get('selectedCityAreaId');

  static void updateSelectedCityAreaId(int cityId) => _box.put('selectedCityAreaId', cityId);

  static String? getCity() => _box.get('City');

  static void updateCity(String cityId) => _box.put('City', cityId);

  static void deleteCity() => _box.delete('City');

  static int? getNotificationsCount() => _box.get('notificationsCount');

  static void updateNotificationCount(int? notificationsCount) =>
      _box.put('notificationsCount', notificationsCount);

  static String _hiddenNotificationsKey() =>
      'hiddenNotificationIds_${getUserId() ?? 0}';

  static Set<String> getHiddenNotificationIds() {
    final stored = _box.get(
      _hiddenNotificationsKey(),
      defaultValue: <dynamic>[],
    );
    if (stored is! List) return <String>{};
    return stored.map((e) => e.toString()).toSet();
  }

  static bool isNotificationHidden(String? id) {
    if (id == null || id.isEmpty) return false;
    return getHiddenNotificationIds().contains(id);
  }

  static Future<void> hideNotificationIds(Iterable<String> ids) async {
    final merged = getHiddenNotificationIds()
      ..addAll(ids.where((id) => id.isNotEmpty));

    // Keep the local tombstone list bounded while preserving recent dismissals.
    final values = merged.toList();
    final limited = values.length > 5000
        ? values.sublist(values.length - 5000)
        : values;
    await _box.put(_hiddenNotificationsKey(), limited);
  }

  static bool isVisitor() => _box.get('isVisitor', defaultValue: false);

  static void updateIsVisitor(bool? isVisitor) => _box.put('isVisitor', isVisitor);
}
