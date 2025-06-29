/// 유효성 검사 함수를 제공하는 클래스입니다.
class Validators {
  /// 문자열이 비어있는지 확인합니다.
  static bool isEmpty(String? text) {
    return text == null || text.trim().isEmpty;
  }
  
  /// 문자열이 비어있지 않은지 확인합니다.
  static bool isNotEmpty(String? text) {
    return !isEmpty(text);
  }
  
  /// 문자열의 길이가 최소 길이 이상인지 확인합니다.
  static bool hasMinLength(String? text, int minLength) {
    if (isEmpty(text)) return false;
    return text!.length >= minLength;
  }
  
  /// 문자열의 길이가 최대 길이 이하인지 확인합니다.
  static bool hasMaxLength(String? text, int maxLength) {
    if (isEmpty(text)) return true;
    return text!.length <= maxLength;
  }
  
  /// 문자열이 유효한 이메일 형식인지 확인합니다.
  static bool isValidEmail(String? email) {
    if (isEmpty(email)) return false;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email!);
  }
  
  /// 문자열이 URL 형식인지 확인합니다.
  static bool isValidUrl(String? url) {
    if (isEmpty(url)) return false;
    
    final urlRegex = RegExp(
      r'^(http|https)://[a-zA-Z0-9-_.]+\.[a-zA-Z]{2,}[a-zA-Z0-9-_./?=&#]*$',
    );
    return urlRegex.hasMatch(url!);
  }
  
  /// 문자열이 숫자만 포함하는지 확인합니다.
  static bool isNumeric(String? text) {
    if (isEmpty(text)) return false;
    
    final numericRegex = RegExp(r'^[0-9]+$');
    return numericRegex.hasMatch(text!);
  }
  
  /// 입력된 승리 항목이 유효한지 확인합니다.
  static bool isValidWin(String? text) {
    // 승리 항목은 비어있지 않아야 합니다.
    return isNotEmpty(text);
  }
} 