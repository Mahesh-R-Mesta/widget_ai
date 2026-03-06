import 'package:home_widget/home_widget.dart';
import 'package:widget_ai/model/database.dart';

class HomeWidgetService {
  static const String _androidWidgetName = 'HomeWidgetProvider';

  /// Checks if the current device/launcher supports dynamic widget pinning.
  Future<bool> isPinningSupported() async {
    return await HomeWidget.isRequestPinWidgetSupported() ?? false;
  }

  /// Updates the home screen widget data for the given project.
  Future<void> updatePinnedWidget(WidgetModelData project) async {
    // Save project-specific data
    await HomeWidget.saveWidgetData<String>('project_name_${project.id}', project.name);
    await HomeWidget.saveWidgetData<String>('project_icon_${project.id}', project.iconPath);

    // Save as the last pinned project so the native side knows what to associate with a new widget
    await HomeWidget.saveWidgetData<int>('last_pinned_project_id', project.id);

    await HomeWidget.updateWidget(name: _androidWidgetName);
  }

  /// Requests the system to pin the widget to the home screen (Android only).
  Future<void> requestPinWidget() async {
    // Note: On Android 8.0+, this will trigger a dialog to add the widget.
    // The native HomeWidgetProvider will associate the new widget ID with 'last_pinned_project_id'.
    await HomeWidget.requestPinWidget(androidName: _androidWidgetName);
  }

  /// Clears the pinned widget data.
  Future<void> clearPinnedWidget() async {
    await HomeWidget.saveWidgetData<String>('app_name', null);
    await HomeWidget.saveWidgetData<String>('icon_path', null);
    await HomeWidget.saveWidgetData<int>('project_id', null);

    await HomeWidget.updateWidget(name: _androidWidgetName);
  }
}
