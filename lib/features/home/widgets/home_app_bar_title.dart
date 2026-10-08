import 'package:flutter/material.dart';

/// ホーム AppBar のタイトル（アバター + プロフィール名）。
///
/// actions が多く title に残る幅が極端に狭い端末(320dp等)でも、
/// Row が溢れて縦書きの赤帯にならないよう、アバターも Flexible + FittedBox で縮める。
class HomeAppBarTitle extends StatelessWidget {
  final Widget avatar;
  final String name;

  const HomeAppBarTitle({super.key, required this.avatar, required this.name});

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
            child: Text(
              name,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }
}
