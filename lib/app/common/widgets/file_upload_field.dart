import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/constant/app_assets.dart';
import 'package:samsung_admin_main_new/app/common/widgets/asset_image_widget.dart';

import '../../app_theme/app_colors.dart';
import '../../app_theme/textstyles.dart';

/// A reusable file upload field that lets the user pick a local file,
/// shows the selected file name, and exposes the [PlatformFile] to the caller.
///
/// Example usage:
/// ```dart
/// PlatformFile? selectedFile;
///
/// FileUploadField(
///   labelText: 'Upload document',
///   hintText: 'No file selected',
///   onFileSelected: (file) {
///     selectedFile = file;
///     // You can now send file.bytes or file.path to your DB / API.
///   },
/// )
/// ```

class FileUploadField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final PlatformFile? initialFile;
  final ValueChanged<PlatformFile?>? onFileSelected;
  final Widget? suffix;
  final FileType fileType;
  final bool enabled;
  final double height;
  final String? errorText;
  final int? maxFileSizeBytes;

  const FileUploadField({
    super.key,
    this.labelText,
    this.hintText,
    this.fileType = FileType.image,
    this.initialFile,
    this.onFileSelected,
    this.suffix,
    this.enabled = true,
    this.height = 44,
    this.errorText,
    this.maxFileSizeBytes,
  });

  @override
  State<FileUploadField> createState() => _FileUploadFieldState();
}

class _FileUploadFieldState extends State<FileUploadField> {
  PlatformFile? _selectedFile;
  bool _isPicking = false;
  String? _sizeError;

  @override
  void initState() {
    super.initState();
    _selectedFile = widget.initialFile;
  }

  @override
  void didUpdateWidget(FileUploadField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFile != oldWidget.initialFile) {
      _selectedFile = widget.initialFile;
    }
    if (oldWidget.hintText == 'File Already Uploaded' ||
        oldWidget.hintText == 'fileAlreadyUploaded'.tr) {
      if (widget.hintText == null ||
          (widget.hintText != 'File Already Uploaded' &&
              widget.hintText != 'fileAlreadyUploaded'.tr)) {
        _selectedFile = null;
      }
    }
  }

  Future<void> _pickFile() async {
    if (!widget.enabled || _isPicking) return;

    setState(() {
      _isPicking = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: widget.fileType,
        allowMultiple: false,
        withData: true,
        compressionQuality: 85,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (widget.maxFileSizeBytes != null &&
            file.size > widget.maxFileSizeBytes!) {
          setState(() {
            _sizeError = 'fileSizeExceeds49MB'.tr;
            _selectedFile = null;
          });
          return;
        }

        setState(() {
          _sizeError = null;
          _selectedFile = file;
        });

        widget.onFileSelected?.call(file);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPicking = false;
        });
      }
    }
  }

  void _removeFile() {
    if (!widget.enabled) return;

    setState(() {
      _selectedFile = null;
      _sizeError = null;
    });

    widget.onFileSelected?.call(null);
  }

  bool get _hasFile {
    return _selectedFile != null ||
        widget.hintText == 'File Already Uploaded' ||
        widget.hintText == 'fileAlreadyUploaded'.tr;
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.labelText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label.isNotEmpty)
          Text(
            label,
            style: AppTextStyles.rubik14w400(context: context),
          ).marginOnly(bottom: 8),
        MouseRegion(
          cursor: widget.enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: widget.enabled ? _pickFile : null,
            child: Container(
              constraints: BoxConstraints(minHeight: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.gradientColor1.withValues(alpha: 0.2),
                    AppColors.gradientColor2.withValues(alpha: 0.2),
                  ],
                  stops: const [0.0, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedFile?.name ??
                          (widget.hintText ?? 'No file selected'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.rubik12w400(
                        context: context,
                      ).copyWith(color: _getTextColor()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_isPicking)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    )
                  else if (_hasFile)
                    GestureDetector(
                      onTap: _removeFile,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: AssetImageWidget(
                          imagePath: AppAssets.trashIcon,
                          height: 18,
                          width: 18,
                        ),
                      ),
                    )
                  else
                    (widget.suffix ??
                        Icon(
                          Icons.upload_file,
                          color: Colors.white70,
                          size: 20,
                        )),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 20,
          child: _sizeError != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _sizeError!,
                    style: const TextStyle(
                      fontFamily: 'samsungsharpsans',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                )
              : widget.errorText != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    widget.errorText!,
                    style: const TextStyle(
                      fontFamily: 'samsungsharpsans',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Color _getTextColor() {
    if (_selectedFile != null || widget.hintText == 'File Already Uploaded') {
      return Colors.white;
    } else {
      return Colors.white.withValues(alpha: 0.3);
    }
  }
}
