import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:lingua_flutter/utils/sizes.dart';

import 'bloc/bloc.dart';
import 'bloc/state.dart';
import 'widgets/container.dart';

const SHOW_MIN_EXAMPLES = 1;

class Examples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationBloc, TranslationState>(
      builder: (context, state) {
        if (state is TranslationLoaded && state.examples != null) {
          final List<dynamic> examples = state.examples[0];

          return TranslationViewContainer(
            title: state.word,
            entity: 'examples',
            itemsAmount: examples.length,
            maxItemsToShow: SHOW_MIN_EXAMPLES,
            withBottomMargin: true,
            childBuilder: (bool expanded) => ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) => ExamplesItem(
                item: examples[index],
              ),
              itemCount: expanded ? examples.length : SHOW_MIN_EXAMPLES,
            ),
          );
        }

        return Container();
      }
    );
  }
}


class ExamplesItem extends StatelessWidget {
  final List<dynamic> item;

  ExamplesItem({
    Key key,
    @required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String text = item[0];

    return Container(
      margin: EdgeInsets.only(top: SizeUtil.vmax(15)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.format_quote,
            size: SizeUtil.vmax(20),
            color: Color.fromRGBO(119, 119, 119, 1),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.78,
            margin: EdgeInsets.only(left: SizeUtil.vmax(20)),
            child: Html(
              data: """$text""",
              defaultTextStyle: TextStyle(
                fontSize: SizeUtil.vmax(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
