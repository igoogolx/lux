class CoreHttpError {
  final String message;
  final int code;

  CoreHttpError({required this.message, required this.code});

  factory CoreHttpError.fromJson(Map<String, dynamic> json) {
    return CoreHttpError(
      message: json['message'] is String ? json['message'] : '',
      code: json['code'] is int ? json['code'] : coreHttpErrorDefaultCode,
    );
  }
}

const coreHttpErrorDefaultCode = 0;
const coreHttpErrorNotElevatedCode = 10000;

class CoreRunError extends Error {
  final String message;
  CoreRunError(this.message);
}
