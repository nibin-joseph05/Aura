class UploadProfileImageResponse {
  final String url;
  final String? filename;

  const UploadProfileImageResponse({required this.url, this.filename});

  factory UploadProfileImageResponse.fromJson(Map<String, dynamic> json) {
    return UploadProfileImageResponse(
      url: json['url'] as String,
      filename: json['filename'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, if (filename != null) 'filename': filename};
  }
}
