import 'package:flutter/material.dart';
import '../../shop/title/title_plate.dart';

/// ホーム AppBar のタイトル（アバター + プロフィール名）。
///
/// actions が多く title に残る幅が極端に狭い端末(320dp等)でも、
/// Row が溢れて縦書きの赤帯にならないよう、アバターも Flexible + FittedBox で縮める。
class HomeAppBarTitle extends StatelessWidget {
  final Widget avatar;
  final String name;

  /// 選んだ称号の名前。null なら何も出さない。
  final String? titleName;

  const HomeAppBarTitle({super.key, required this.avatar, required this.name, this.titleName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: FittedBox(fit: BoxFit.scaleDown, child: avatar),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (titleName != null)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: TitlePlate(name: titleName!, width: 96),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
