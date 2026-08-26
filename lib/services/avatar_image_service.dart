import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Result of picking + processing a profile photo: a local file (higher
/// resolution, for fast on-device display) and a small base64 JPEG
/// (low resolution, for syncing into Firestore group/member docs — the app
/// has no Firebase Storage on the Spark plan, so photos travel inline as
/// base64 rather than as uploaded files/URLs).
class ProcessedAvatar {
  const ProcessedAvatar({required this.localFile, required this.base64Thumbnail});

  final File localFile;
  final String base64Thumbnail;
}

/// Picks an image (camera or gallery), center-crops it to a square, and
/// produces both a local copy for fast display and a small base64 copy
/// cheap enough to embed inline in Firestore documents.
class AvatarImageService {
  static const _localSize = 256;
  static const _thumbnailSize = 96;
  static const _thumbnailQuality = 55;

  final _picker = ImagePicker();

  Future<ProcessedAvatar?> pickAndProcess({required ImageSource source}) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 90);
    if (picked == null) return null;

    final bytes = await picked.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    final squared = _centerCropSquare(decoded);

    final local = img.copyResize(squared, width: _localSize, height: _localSize);
    final localBytes = img.encodeJpg(local, quality: 85);
    final localFile = await _writeLocalFile(localBytes);

    final thumbnail = img.copyResize(squared, width: _thumbnailSize, height: _thumbnailSize);
    final thumbnailBytes = img.encodeJpg(thumbnail, quality: _thumbnailQuality);
    final base64Thumbnail = base64Encode(thumbnailBytes);

    return ProcessedAvatar(localFile: localFile, base64Thumbnail: base64Thumbnail);
  }

  /// Re-derives a small base64 thumbnail from an already-saved local avatar
  /// file (e.g. `UserProfile.photoPath`) — used when creating/joining a
  /// Community group, so the member entry starts with the user's current
  /// photo instead of null. Returns null if there's no local file yet.
  Future<String?> thumbnailBase64FromFile(String? path) async {
    if (path == null) return null;
    final file = File(path);
    if (!file.existsSync()) return null;
    final decoded = img.decodeImage(await file.readAsBytes());
    if (decoded == null) return null;
    final thumbnail = img.copyResize(decoded, width: _thumbnailSize, height: _thumbnailSize);
    return base64Encode(img.encodeJpg(thumbnail, quality: _thumbnailQuality));
  }

  img.Image _centerCropSquare(img.Image source) {
    final side = source.width < source.height ? source.width : source.height;
    final x = (source.width - side) ~/ 2;
    final y = (source.height - side) ~/ 2;
    return img.copyCrop(source, x: x, y: y, width: side, height: side);
  }

  Future<File> _writeLocalFile(List<int> bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    // Fixed filename so re-picking a photo overwrites the old one instead of
    // accumulating orphaned files.
    final file = File(p.join(dir.path, 'avatar.jpg'));
    return file.writeAsBytes(bytes, flush: true);
  }
}
