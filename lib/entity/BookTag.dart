import 'package:json_annotation/json_annotation.dart';
import 'package:book/entity/Chapter.dart';

part 'BookTag.g.dart';

@JsonSerializable()
class BookTag {
  int cur;

  int index;

  String bookName;
  List<Chapter> chapters;

  factory BookTag.fromJson(Map<String, dynamic> json) =>
      _$BookTagFromJson(json);

  Map<String, dynamic> toJson() => _$BookTagToJson(this);

  BookTag(this.cur, this.index, this.bookName, this.chapters);
}
