import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:kakao_login_test/status/controller.dart';
import '../../common/commondata.dart';


final String TableName = 'Items';
final controller = Get.put(Controller());

class basketItems {
  final int id;
  final String gubun;

  basketItems({required this.id,required this.gubun});
}



//Create
addData(int id, String gubun) async {
  final dio = Dio();
  await dio.post(
      '$appServerURL/basketadd',
      data: {
        'uuid': controller.userId.value,
        'id': id,
        'type': gubun,
      }
  ).then((res) {
    return res;
  }).catchError(
          (err) {
        print(err);
        return [];
      }
  );
  return [];
}

//Read All
Future<List<dynamic>> getAllItems(String type) async {
  final dio = Dio();
  final res = await dio.post(
        '$appServerURL/basketall',
        data: {
          'uuid': controller.userId.value,
          'type': type,
        }
  );
  dio.close();
  if (res.data.length == 0) return [];
  return res.data;
}

// Future<List<basketItems>> getAllCItems() async {
//   final db = await initDB();
//   var res = await db.rawQuery(
//       'SELECT id,gubun FROM $TableName where gubun == "C"');
//   List<Map<String, dynamic>> list = res;
//
//   if (list.length == 0) return [];
//   return List.generate(list.length, (i) {
//     return basketItems(
//       id: list[i]['id'],
//       gubun: list[i]['gubun'],
//     );
//   });
// }

//Delete
deleteItem(int id,String gubun) async {
  final dio = Dio();
  await dio.post(
      '$appServerURL/basketdelete',
      data: {
        'uuid': controller.userId.value,
        'id': id,
        'type': gubun,
      }
  );
}

//Delete All
// deleteAllItems() async {
//   final db = await initDB();
//   db.rawDelete('DELETE FROM $TableName');
// }