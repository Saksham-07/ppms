import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../MainMenu/home_page1_widget.dart';

class TAppBar extends StatelessWidget {
  const TAppBar({
    super.key, required this.title,
  });
  final String title;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: AppBar(
        // backgroundColor: Colors.blue,
        backgroundColor: Color(0xFF5FE3D3),
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: ()=>(Get.to(()=>HomePage1Widget())), icon: const Icon(Iconsax.arrow_left),),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,style: TextStyle(
              fontSize: 16,
              color: Colors.white
            ))
          ],
        ),
      ),
    );
  }
}
