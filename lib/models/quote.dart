/// 명언/응원 메시지를 나타내는 모델 클래스입니다.
class Quote {
  /// 명언/응원 메시지의 고유 ID입니다.
  final String id;
  
  /// 명언/응원 메시지의 내용입니다.
  final String text;
  
  /// 명언/응원 메시지의 작성자입니다. (선택 사항)
  final String? author;
  
  /// 명언/응원 메시지를 생성합니다.
  const Quote({
    required this.id,
    required this.text,
    this.author,
  });
  
  /// Map에서 Quote 객체를 생성합니다.
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as String,
      text: json['text'] as String,
      author: json['author'] as String?,
    );
  }
  
  /// Quote 객체를 Map으로 변환합니다.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
    };
  }
  
  /// Quote 객체의 복사본을 생성합니다.
  Quote copyWith({
    String? id,
    String? text,
    String? author,
  }) {
    return Quote(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
    );
  }
  
  @override
  String toString() {
    return 'Quote{id: $id, text: $text, author: $author}';
  }
} 