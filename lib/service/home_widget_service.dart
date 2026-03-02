import 'package:home_widget/home_widget.dart';
import 'package:widget_ai/model/database.dart';

class HomeWidgetService {
  static const String _androidWidgetName = 'HomeWidgetProvider';

  /// Checks if the current device/launcher supports dynamic widget pinning.
  Future<bool> isPinningSupported() async {
    return await HomeWidget.isRequestPinWidgetSupported() ?? false;
  }

  /// Updates the home screen widget with the details of the given project.
  Future<void> updatePinnedWidget(WidgetModelData project) async {
    await HomeWidget.saveWidgetData<String>('app_name', project.name);
    await HomeWidget.saveWidgetData<String>('icon_path', project.iconPath);
    await HomeWidget.saveWidgetData<int>('project_id', project.id);

    await HomeWidget.updateWidget(name: _androidWidgetName);
  }

  /// Requests the system to pin the widget to the home screen (Android only).
  Future<void> requestPinWidget() async {
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
