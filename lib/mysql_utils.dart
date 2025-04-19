import 'package:mysql1/mysql1.dart';

class MysqlUtils {
  static final settings = ConnectionSettings(
    host: 'bvxtycsp6ekstxmjpoin-mysql.services.clever-cloud.com', 
    port: 3306,
    user: 'uhkpqzhbwehpm6bu',
    password: 'TauTb7UyQQWonPYkj2kR',
    db: 'bvxtycsp6ekstxmjpoin',
  );
  static late MySqlConnection conn;

  static void initConnection() async {
    conn = await MySqlConnection.connect(settings);
  }

  static Future<MySqlConnection> getConnection() async {
    return await MySqlConnection.connect(settings);
  }
}