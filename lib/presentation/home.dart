import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:widget_ai/model/database.dart';
import 'package:widget_ai/presentation/web_app_view.dart';
import 'package:widget_ai/service/file_system.dart';
import 'package:widget_ai/service/home_widget_service.dart';
import 'package:widget_ai/service/locator.dart';
import 'package:widget_ai/utility/theme.dart';

class WidgetScreen extends StatefulWidget {
  const WidgetScreen({super.key});

  @override
  State<WidgetScreen> createState() => _WidgetScreenState();
}

class _WidgetScreenState extends State<WidgetScreen> {
  final _db = locator<AppDatabase>();
  final _isGridView = ValueNotifier<bool>(true);

  /// Reactive stream of all saved projects, newest first.
  late final Stream<List<WidgetModelData>> _projectsStream;

  @override
  void initState() {
    super.initState();
    locator<FileSystemIO>().requestAccess();
    _projectsStream = _db.watchAllProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Text(
          'Widget AI',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22.sp),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _isGridView,
            builder: (_, isGrid, __) => IconButton(
              onPressed: () => _isGridView.value = !isGrid,
              icon: Icon(isGrid ? Icons.list_rounded : Icons.grid_view_rounded, color: Colors.black),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<WidgetModelData>>(
        stream: _projectsStream,
        builder: (context, snapshot) {
          final projects = snapshot.data ?? [];
          return ValueListenableBuilder<bool>(
            valueListenable: _isGridView,
            builder: (_, isGrid, __) => isGrid ? _buildGridView(projects) : _buildListView(projects),
          );
        },
      ),
    );
  }

  // ── Grid ──────────────────────────────────────────────────────────────────

  Widget _buildGridView(List<WidgetModelData> projects) {
    return GridView.builder(
      padding: EdgeInsets.all(16.r),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16.r,
        crossAxisSpacing: 16.r,
        childAspectRatio: 0.95,
      ),
      itemCount: projects.length + 1,
      itemBuilder: (context, index) {
        if (index == projects.length) return _buildAddButton();
        return _buildAppCard(projects[index]);
      },
    );
  }

  Widget _buildAppCard(WidgetModelData project) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () => _openProject(project),
      onLongPress: () => _showProjectOptions(context, project),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(project, size: 56.r),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                project.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── List ──────────────────────────────────────────────────────────────────

  Widget _buildListView(List<WidgetModelData> projects) {
    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: projects.length + 1,
      itemBuilder: (context, index) {
        if (index == projects.length) {
          return Padding(
            padding: EdgeInsets.only(top: 8.r),
            child: SizedBox(height: 100.h, child: _buildAddButton()),
          );
        }
        return Padding(
          padding: EdgeInsets.only(bottom: 12.r),
          child: _buildAppListTile(projects[index]),
        );
      },
    );
  }

  Widget _buildAppListTile(WidgetModelData project) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () => _openProject(project),
      onLongPress: () => _showProjectOptions(context, project),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            _buildIcon(project, size: 44.r),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  if (project.description.isNotEmpty)
                    Text(
                      project.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildIcon(WidgetModelData project, {required double size}) {
    final path = project.iconPath;
    if (path != null && File(path).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.file(File(path), width: size, height: size, fit: BoxFit.cover),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(Icons.widgets_rounded, size: size * 0.55, color: AppColors.primary),
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () => Navigator.pushNamed(context, '/create_widget'),
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          color: Colors.grey[400]!,
          dashPattern: const [6, 4],
          radius: Radius.circular(16.r),
          strokeWidth: 1.5,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: Colors.grey[400], size: 32.r),
              SizedBox(height: 4.h),
              Text(
                'Add Widget',
                style: TextStyle(color: Colors.grey[400], fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openProject(WidgetModelData project) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => WebAppView(project: project)));
  }

  void _showProjectOptions(BuildContext context, WidgetModelData project) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  _buildIcon(project, size: 40.r),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Project Options',
                          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.open_in_new_rounded, color: AppColors.primary),
              title: const Text('Open Project'),
              onTap: () {
                Navigator.pop(context);
                _openProject(project);
              },
            ),
            ListTile(
              leading: const Icon(Icons.push_pin_outlined, color: Colors.orange),
              title: const Text('Pin to Home Screen'),
              onTap: () {
                Navigator.pop(context);
                _pinToHome(project);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              title: const Text('Delete Project'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, project);
              },
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetModelData project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project?'),
        content: Text('This will permanently remove "${project.name}" and all its data. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProject(project);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _pinToHome(WidgetModelData project) async {
    final service = locator<HomeWidgetService>();
    try {
      // 1. Update the widget data first
      await service.updatePinnedWidget(project);

      // 2. Request pinning if supported (Android only)
      final canPin = await service.isPinningSupported();
      if (canPin) {
        await service.requestPinWidget();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Direct pinning is not supported on this device. You can add it manually from the Widget Gallery.',
              ),
            ),
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('"${project.name}" details updated for home widget.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pin: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _deleteProject(WidgetModelData project) async {
    try {
      final fileSystem = locator<FileSystemIO>();
      if (project.location != null) await fileSystem.deleteDirectory(project.location!);
      if (project.iconPath != null) await fileSystem.deleteFile(project.iconPath!);

      await _db.deleteProject(project.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"${project.name}" deleted.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red));
      }
    }
  }
}
