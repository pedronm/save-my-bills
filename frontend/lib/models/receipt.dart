class Receipt {
  final String? id;
  final String receiptId;
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

  Receipt({
    this.id,
    required this.receiptId,
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

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'],
      receiptId: json['receiptId'],
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
      'receiptId': receiptId,
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
      'receiptId': receiptId,
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

  factory Receipt.fromMap(Map<String, dynamic> map) {
    Map<String, String>? tags;
    if (map['tags'] != null && map['tags'] is String) {
      // Parse tags string back to Map
      try {
        // Remove curly braces and split by comma
        String tagsStr = map['tags'].toString().replaceAll('{', '').replaceAll('}', '');
        if (tagsStr.isNotEmpty) {
          tags = {};
          for (var pair in tagsStr.split(',')) {
            var parts = pair.trim().split(':');
            if (parts.length == 2) {
              tags[parts[0].trim()] = parts[1].trim();
            }
          }
        }
      } catch (e) {
        // If parsing fails, leave tags as null
        tags = null;
      }
    }
    
    return Receipt(
      id: map['id'],
      receiptId: map['receiptId'],
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
      tags: tags,
    );
  }
}
