import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class AvatarPicker extends StatefulWidget {
  const AvatarPicker({this.size = 96, super.key});

  final double size;

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  IconData _avatarIcon = Icons.person_rounded;

  Future<void> _showPicker() async {
    final selectedIcon = await showModalBottomSheet<IconData>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pilih Foto Profil',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.photo_camera_rounded),
                  title: const Text('Ambil dari Kamera'),
                  onTap: () =>
                      Navigator.of(context).pop(Icons.photo_camera_rounded),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () =>
                      Navigator.of(context).pop(Icons.photo_library_rounded),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedIcon == null || !mounted) {
      return;
    }

    setState(() => _avatarIcon = selectedIcon);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Pilih foto profil',
      child: InkWell(
        borderRadius: BorderRadius.circular(widget.size),
        onTap: _showPicker,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: widget.size,
              height: widget.size,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.headerGradient,
              ),
              child: Icon(
                _avatarIcon,
                color: Colors.white,
                size: widget.size * 0.52,
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: widget.size * 0.34,
                height: widget.size * 0.34,
                decoration: BoxDecoration(
                  color: AppColors.teal700,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: widget.size * 0.18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
