import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/helpers/db.dart';
import 'package:lingua_flutter/utils/sizes.dart';
import 'package:lingua_flutter/widgets/pronunciation.dart';
import 'package:lingua_flutter/widgets/prompts.dart';
import 'package:lingua_flutter/screens/search/router.dart';
import 'package:lingua_flutter/screens/search/translation_view/bloc/bloc.dart';
import 'package:lingua_flutter/screens/search/translation_view/bloc/events.dart';
import 'package:lingua_flutter/widgets/resizable_image.dart';

import 'model/item.dart';
import 'model/list.dart';
import 'bloc/state.dart';
import 'bloc/events.dart';
import 'bloc/bloc.dart';

class TranslationsList extends StatefulWidget {
  @override
  _TranslationsListState createState() => _TranslationsListState();
}

class _TranslationsListState extends State<TranslationsList> {
  final _scrollController = ScrollController();
  TranslationsBloc _translationsBloc;
  Completer<void> _refreshCompleter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _translationsBloc = BlocProvider.of<TranslationsBloc>(context);
    _refreshCompleter = Completer<void>();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (
      _scrollController.position.pixels > 0.0
      && _scrollController.position.pixels == _scrollController.position.maxScrollExtent
    ) {
      _translationsBloc.add(TranslationsRequestMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TranslationsBloc, TranslationsState>(
      listener: (context, state) {
        if (state is TranslationsLoaded) {
          _refreshCompleter?.complete();
          _refreshCompleter = Completer();
        }
      },
      child: BlocBuilder<TranslationsBloc, TranslationsState>(
        builder: (context, state) {
          if (state is TranslationsLoaded && state.translations.isEmpty) {
            return Center(
              child: Text('no translations'),
            );
          }

          if (state.translations.isNotEmpty) {
            return Container(
              color: Colors.white,
              child: RefreshIndicator(
                onRefresh: () {
                  if (state is TranslationsLoaded && state.search != null) {
                    _translationsBloc.add(TranslationsSearch(state.search));
                  } else {
                    _translationsBloc.add(TranslationsRequest());
                  }
                  return _refreshCompleter.future;
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return Container(
                        padding: EdgeInsets.only(
                          left: SizeUtil.vmax(15),
                          top: SizeUtil.vmax(10),
                        ),
                        child: Row(
                          children: <Widget>[
                            Text(
                                'Total: ',
                                style: TextStyle(
                                  fontSize: SizeUtil.vmax(15),
                                  fontWeight: FontWeight.bold,
                                )
                            ),
                            Text(
                              '${state.totalAmount}',
                              style: TextStyle(
                                fontSize: SizeUtil.vmax(15),
                                fontWeight: FontWeight.bold,
                              )
                            ),
                          ],
                        ),
                      );
                    }

                    if (index - 1 == state.translations.length) {
                      return BottomLoader();
                    }

                    return TranslationsListItemWidget(
                      key: ValueKey('$index-${state.translations[index - 1].updatedAt}'),
                      translationItem: state.translations[index - 1],
                      withBorder: index < state.translations.length,
                    );
                  },
                  itemCount: state.translations.length + 2,
                  controller: _scrollController,
                ),
              ),
            );
          }

          if (state is TranslationsError) {
            return Center(
              child: Text(state.error.message),
            );
          }

          if (!(state is TranslationsLoaded)) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return null;
        },
      ),
    );
  }
}

class TranslationsListItemWidget extends StatelessWidget {
  final TranslationsItem translationItem;
  final bool withBorder;

  TranslationsListItemWidget({
    Key key,
    @required this.translationItem,
    @required this.withBorder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(translationItem.word),
      background: Container(
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              width: SizeUtil.vmax(80),
              child: Icon(
                Icons.delete,
                color: Colors.white,
                size: SizeUtil.vmax(30),
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (DismissDirection direction) async {
        return await wordRemovePrompt(context, translationItem.word, () {
          BlocProvider.of<TranslationsBloc>(context).add(
              TranslationsItemRemove(translationItem.id)
          );
        });
      },
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        print(direction);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: SizeUtil.vmax(2)),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: withBorder ? Color.fromRGBO(0, 0, 0, 0.1) : Color.fromRGBO(0, 0, 0, 0.0),
            ),
          ),
        ),
        child: ListTile(
          leading: Container(
            width: SizeUtil.vmax(50),
            child: ResizableImage(
              width: SizeUtil.vmax(150),
              height: SizeUtil.vmax(150),
              imageSource: translationItem.image,
              updatedAt: translationItem.updatedAt,
              isLocal: db != null,
            ),
          ),
          title: Container(
            margin: EdgeInsets.only(bottom: SizeUtil.vmax(2)),
            child: Text(
              translationItem.word,
              style: TextStyle(fontSize: SizeUtil.vmax(18)),
            ),
          ),
          subtitle: Container(
            margin: EdgeInsets.only(bottom: SizeUtil.vmax(2)),
            child: Text(
              translationItem.translation,
              style: TextStyle(fontSize: SizeUtil.vmax(16)),
            ),
          ),
          dense: true,
          trailing: PronunciationWidget(
            pronunciationUrl: translationItem.pronunciation,
            isLocal: db != null,
          ),
          onTap: () {
            BlocProvider.of<TranslationBloc>(context).add(TranslationClear());
            Navigator.pushNamed(
              context,
              SearchNavigatorRoutes.translation_view,
              arguments: translationItem.word,
            );
          },
        ),
      ),
    );
  }
}

class BottomLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationsBloc, TranslationsState>(
      builder: (context, state) {
        final int listLength = state.translations.length;
        if (listLength >= LIST_PAGE_SIZE && listLength < state.totalAmount) {
          return Container(
            padding: EdgeInsets.only(
              top: SizeUtil.vmax(10),
              bottom: SizeUtil.vmax(10),
            ),
            child: Center(
              child: SizedBox(
                width: SizeUtil.vmax(33),
                height: SizeUtil.vmax(33),
                child: CircularProgressIndicator(
                  strokeWidth: SizeUtil.vmax(1.5),
                ),
              ),
            ),
          );
        }

        return Container();
      }
    );
  }
}
