
class PieceEntity {
  final int index;
  final List<int> data; // 조각 바이트
  final bool isUploaded;

  const PieceEntity({
    required this.index,
    required this.data,
    this.isUploaded = false,
  });

  PieceEntity copyWith({bool? isUploaded}) {
    return PieceEntity(
      index: index,
      data: data,
      isUploaded: isUploaded ?? this.isUploaded,
    ); 
  }
}