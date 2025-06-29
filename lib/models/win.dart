/// 승리 항목을 나타내는 모델 클래스입니다.
class Win {
  /// 승리 항목의 고유 ID입니다.
  final String id;
  
  /// 승리 항목의 내용입니다.
  String text;
  
  /// 승리 항목의 완료 여부입니다.
  bool isCompleted;
  
  /// 승리 항목이 생성된 시간입니다.
  final DateTime createdAt;
  
  /// 승리 항목을 생성합니다.
  Win({
    required this.id,
    required this.text,
    this.isCompleted = false,
    required this.createdAt,
  });
  
  /// Map에서 Win 객체를 생성합니다.
  factory Win.fromJson(Map<String, dynamic> json) {
    return Win(
      id: json['id'] as String,
      text: json['text'] as String,
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
  
  /// Win 객체를 Map으로 변환합니다.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  /// Win 객체의 복사본을 생성합니다.
  Win copyWith({
    String? id,
    String? text,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Win(
      id: id ?? this.id,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  @override
  String toString() {
    return 'Win{id: $id, text: $text, isCompleted: $isCompleted, createdAt: $createdAt}';
  }
} 