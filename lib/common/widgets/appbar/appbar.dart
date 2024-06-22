import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../home_page1_widget.dart';

class TAppBar extends StatelessWidget {
  const TAppBar({
    super.key, required this.title,
  });
  final String title;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: ()=>(Get.to(()=>HomePage1Widget())), icon: const Icon(Iconsax.arrow_left),),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,style: Theme.of(context).textTheme.headlineSmall!.apply(color: Colors.white),)
          ],
        ),
      ),
    );
  }
}
