import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  Future<int?> getShootingTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('shooting_time');
    } catch (e) {
      throw Exception('設定の取得中にエラーが発生しました。');
    }
  }

  Future<void> saveShootingTime(int shootingTime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('shooting_time', shootingTime);
    } catch (e) {
      throw Exception('設定の保存中にエラーが発生しました。');
    }
  }
}
