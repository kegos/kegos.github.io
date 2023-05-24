
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kakao_login_test/screens/commdetailview.dart';
import 'package:kakao_login_test/screens/component/basket.dart';
import '../assetdetailview.dart';


class AssetBasketCard extends StatelessWidget {
  final int id;
  final Widget image;
  final String callname;
  final int price;
  final int price2;
  final int price3;
  final int price4;
  final int room;
  final int bath;
  final int size;
  final String direction;
  final String indate;
  final String floor;
  final int totalfloor;
  final String type;
  final String gubun;

  const AssetBasketCard({
    required this.price,
    required this.price2,
    required this.price3,
    required this.price4,
    required this.id,
    required this.image,
    required this.callname,
    required this.direction,
    required this.floor,
    required this.totalfloor,
    required this.indate,
    required this.bath,
    required this.room,
    required this.size,
    required this.type,
    required this.gubun,
    Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var f = NumberFormat('###,###,###,###');

    return Dismissible(
      // Each Dismissible must contain a Key. Keys allow Flutter to
      // uniquely identify widgets.
      key: UniqueKey(),
      // Provide a function that tells the app
      background: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(20),
        alignment: Alignment.centerLeft,
        color: Colors.red,
        child: const Icon(Icons.delete,size: 36,),
      ),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        if(direction == DismissDirection.startToEnd) {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("관심 등록 삭제"),
                content: const Text("관심 물건에서 제외 하시겠습니까 ?"),
                actions: <Widget>[
                  TextButton(
                      onPressed: () {
                        deleteItem(id,gubun);
                        Navigator.of(context).pop(true);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text("$callname 관심등록 삭제됨")));
                      },
                      child: const Text("예")
                  ),
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("아니오")
                  ),
                ],
              );
            },
          );
        }
      },
      onDismissed: (direction) {
        // Remove the item from the data source.
        // setState(() {
        //   _items.removeAt(index);
        // });
        //
        // Then show a snackbar.
        if(direction == DismissDirection.endToStart) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("$callname 관심 리스트에서 삭제됨")));
        }
      },

      child: GestureDetector(
        onTap: () {
          if(gubun == 'H')
            Get.to(() => AssetDetailViewScreen(id: id,));
          else
            Get.to(() => CommDetailViewScreen(id: id,));
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                SizedBox(
                  height: 95,
                  width: 95,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: image,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: Text(
                                  '$callname',
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                  ),
                                ),
                              ),
                              Text(
                                '${(gubun == 'H' ? size * 0.3052 : size).round()}평',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primaryContainer
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                if (price2 != 0)
                                  Text(
                                    '매:${f.format(int.parse((price3/10000).round().toString()))}/전:${f.format(int.parse((price4/10000).round().toString()))}/보:${f.format(int.parse((price/10000).round().toString()))}/${f.format(int.parse((price2/10000).round().toString()))}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primaryContainer,
                                    ),
                                  ),
                                if (price2 == 0)
                                  Text(
                                    '매:${f.format(int.parse((price3/10000).round().toString()))}/전:${f.format(int.parse((price4/10000).round().toString()))}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primaryContainer,
                                    ),
                                  ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '$type',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4,),
                        gubun == 'H' ?
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '방$room/욕실$bath',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                  ),
                                ),
                                Text(
                                  '$direction향',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                  ),
                                ),
                                Text(
                                  '$floor/$totalfloor (층)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                  ),
                                ),]
                          ) : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '층수 : $floor',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                ),
                              ),
                              Text(
                                '면적 : ${(size).round()}평',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                ),
                              ),
                            ],
                          )

                        ,Text(
                          '입주가능일 : $indate',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
