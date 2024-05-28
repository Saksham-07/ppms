import 'package:mysql1/mysql1.dart';
import 'package:http/http.dart' as http;

class mySql{
  static String host ='14.142.248.34',
                user = 'sa',
                db = 'MHRIS',
                password = 'Admin@321#\$';
  static int port = 51121;

  mySql();

  Future<MySqlConnection> getConnection() async {
    try {
      print("Connecting to SQL....");
      var settings = ConnectionSettings(
        host: '14.142.248.34',
        port: 51121,
        user: 'saa',
        password: 'Admin@321#\$',
        db: 'MHRIS',
        timeout: Duration(seconds:120),

        characterSet: CharacterSet.UTF8MB4,
      );
      print("Connecting....");
      print(password);
      return await MySqlConnection.connect(settings);
    } catch (e) {
      print("Error connecting to SQL: $e");
      rethrow; // Rethrow the exception for higher-level error handling
    }
  }

}