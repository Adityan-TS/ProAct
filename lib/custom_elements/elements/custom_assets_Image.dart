import 'package:flutter/cupertino.dart';

class CustomAssetsImage extends StatelessWidget {
   CustomAssetsImage({
     Key? key,
     required this.imagePath,
     this.height,
     this.fit,
     this.width,
     this.color
   }) : super(key: key);

   String imagePath;
    double? width;
    double? height;
    BoxFit? fit;
    Color? color;
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: width,
      height: height,color:color,
      fit: fit ?? BoxFit.cover,
    );
  }
}
