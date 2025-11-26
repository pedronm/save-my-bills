class Screenshot {
  final String? id;
  final String screenshotId;
  final String filename;
  final String? contentType;
  final double? fileSize;
  final String driveFileId;
  final String? driveFileUrl;
  final DateTime uploadedAt;
  final DateTime? lastAccessedAt;
  final String? userId;
  final String? category;
  final double? amount;
  final String? currency;
  final DateTime? billDate;
  final String? vendor;
  final Map<String, String>? tags;

  Screenshot({
    this.id,
    required this.screenshotId,
    required this.filename,
    this.contentType,
    this.fileSize,
    required this.driveFileId,
    this.driveFileUrl,
    required this.uploadedAt,
    this.lastAccessedAt,
    this.userId,
    this.category,
    this.amount,
    this.currency,
    this.billDate,
    this.vendor,
    this.tags,
  });

  factory Screenshot.fromJson(Map<String, dynamic> json) {
    return Screenshot(
      id: json['id'],
      screenshotId: json['screenshotId'],
      filename: json['filename'],
      contentType: json['contentType'],
      fileSize: json['fileSize']?.toDouble(),
      driveFileId: json['driveFileId'],
      driveFileUrl: json['driveFileUrl'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      lastAccessedAt: json['lastAccessedAt'] != null 
          ? DateTime.parse(json['lastAccessedAt']) 
          : null,
      userId: json['userId'],
      category: json['category'],
      amount: json['amount']?.toDouble(),
      currency: json['currency'],
      billDate: json['billDate'] != null 
          ? DateTime.parse(json['billDate']) 
          : null,
      vendor: json['vendor'],
      tags: json['tags'] != null 
          ? Map<String, String>.from(json['tags']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'screenshotId': screenshotId,
      'filename': filename,
      'contentType': contentType,
      'fileSize': fileSize,
      'driveFileId': driveFileId,
      'driveFileUrl': driveFileUrl,
      'uploadedAt': uploadedAt.toIso8601String(),
      'lastAccessedAt': lastAccessedAt?.toIso8601String(),
      'userId': userId,
      'category': category,
      'amount': amount,
      'currency': currency,
      'billDate': billDate?.toIso8601String(),
      'vendor': vendor,
      'tags': tags,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'screenshotId': screenshotId,
      'filename': filename,
      'contentType': contentType,
      'fileSize': fileSize,
      'driveFileId': driveFileId,
      'driveFileUrl': driveFileUrl,
      'uploadedAt': uploadedAt.toIso8601String(),
      'lastAccessedAt': lastAccessedAt?.toIso8601String(),
      'userId': userId,
      'category': category,
      'amount': amount,
      'currency': currency,
      'billDate': billDate?.toIso8601String(),
      'vendor': vendor,
      'tags': tags?.toString(),
    };
  }

  factory Screenshot.fromMap(Map<String, dynamic> map) {
    return Screenshot(
      id: map['id'],
      screenshotId: map['screenshotId'],
      filename: map['filename'],
      contentType: map['contentType'],
      fileSize: map['fileSize']?.toDouble(),
      driveFileId: map['driveFileId'],
      driveFileUrl: map['driveFileUrl'],
      uploadedAt: DateTime.parse(map['uploadedAt']),
      lastAccessedAt: map['lastAccessedAt'] != null 
          ? DateTime.parse(map['lastAccessedAt']) 
          : null,
      userId: map['userId'],
      category: map['category'],
      amount: map['amount']?.toDouble(),
      currency: map['currency'],
      billDate: map['billDate'] != null 
          ? DateTime.parse(map['billDate']) 
          : null,
      vendor: map['vendor'],
    );
  }
}
