import 'package:flutter/material.dart';

import 'package:lingua_flutter/utils/sizes.dart';

class TranslationViewCategory extends StatelessWidget {
  final List<dynamic> category;
  final Function itemBuilder;
  final int maxItemsToShow;
  final bool expanded;

  TranslationViewCategory({
    Key key,
    @required this.category,
    @required this.itemBuilder,
    @required this.maxItemsToShow,
    @required this.expanded
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String categoryName = category[0];
    final List<dynamic> items = category[1];
    int itemsLength = items.length;

    if (!expanded && itemsLength > maxItemsToShow) {
      itemsLength = maxItemsToShow;
    }

    return Container(
      margin: EdgeInsets.only(top: SizeUtil.vmax(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              bottom: SizeUtil.vmax(5),
            ),
            child: Text(
              '${categoryName[0].toUpperCase()}${categoryName.substring(1)}',
              style: TextStyle(
                fontSize: SizeUtil.vmax(16),
                color: Theme.of(context).buttonTheme.colorScheme.secondaryVariant,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: itemBuilder,
            itemCount: itemsLength,
          ),
        ],
      ),
    );
  }
}
