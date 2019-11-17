import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import 'package:lingua_flutter/utils/api.dart';

abstract class TranslationState extends Equatable {
  const TranslationState();

  @override
  List<Object> get props => [];
}

class TranslationUninitialized extends TranslationState {}

class TranslationError extends TranslationState {
  final ApiException error;

  TranslationError([this.error]) : assert(error is ApiException);

  @override
  List<Object> get props => [error];

  @override
  String toString() => error.toString();
}

class TranslationRequestLoading extends TranslationState {}

class TranslationLoaded extends TranslationState {
  final int id;
  final String word;
  final String translationWord;
  final String pronunciation;
  final List<dynamic> highestRelevantTranslation;
  final List<dynamic> otherTranslations;
  final List<dynamic> definitions;
  final List<dynamic> definitionsSynonyms;
  final List<dynamic> examples;
  final String autoSpellingFix;
  final bool strangeWord;
  final String image;
  final List<dynamic> images;
  final String imageSearchWord;
  final bool imageLoading;
  final String createdAt;

  TranslationLoaded({
    @required this.id,
    @required this.word,
    @required this.translationWord,
    @required this.pronunciation,
    @required this.image,
    @required this.images,
    @required this.imageSearchWord,
    @required this.imageLoading,
    @required this.highestRelevantTranslation,
    @required this.otherTranslations,
    @required this.definitions,
    @required this.definitionsSynonyms,
    @required this.examples,
    @required this.autoSpellingFix,
    @required this.strangeWord,
    @required this.createdAt,
  }) : assert(word != null && translationWord != null);

  TranslationLoaded copyWith({
    List<dynamic> images,
    bool imageLoading,
    String image,
    String imageSearchWord,
  }) {
    return TranslationLoaded(
      id: this.id,
      word: this.word,
      translationWord: this.translationWord,
      pronunciation: this.pronunciation,
      image: image ?? (images != null ? images[0] : this.image),
      imageLoading: imageLoading ?? this.imageLoading,
      images: images ?? this.images,
      imageSearchWord: imageSearchWord ?? this.imageSearchWord,
      highestRelevantTranslation: this.highestRelevantTranslation,
      otherTranslations: this.otherTranslations,
      definitions: this.definitions,
      definitionsSynonyms: this.definitionsSynonyms,
      examples: this.examples,
      autoSpellingFix: this.autoSpellingFix,
      strangeWord: this.strangeWord,
      createdAt: this.createdAt,
    );
  }

  @override
  List<Object> get props => [
    id,
    word,
    translationWord,
    pronunciation,
    image,
    imageLoading,
    highestRelevantTranslation,
    otherTranslations,
    definitions,
    definitionsSynonyms,
    examples,
    autoSpellingFix,
    strangeWord,
    createdAt,
  ];

  @override
  String toString() => '$word -> $translationWord';
}
