import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_widget/home_widget.dart';
import 'package:widget_ai/model/database.dart';
import 'package:widget_ai/presentation/create_widget_page.dart';
import 'package:widget_ai/presentation/home.dart';
import 'package:widget_ai/presentation/web_app_view.dart';
import 'package:widget_ai/service/locator.dart';
import 'package:widget_ai/utility/theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _checkLaunchedWidget();
    HomeWidget.setAppGroupId('group.com.example.widget_ai');
    HomeWidget.widgetClicked.listen((Uri? uri) => _handleWidgetClick(uri));
  }

  Future<void> _checkLaunchedWidget() async {
    final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (uri != null) {
      _handleWidgetClick(uri);
    }
  }

  void _handleWidgetClick(Uri? uri) async {
    if (uri != null && uri.scheme == 'widgetai' && uri.host == 'project') {
      final projectIdStr = uri.queryParameters['id'];
      if (projectIdStr != null) {
        final projectId = int.tryParse(projectIdStr);
        if (projectId != null) {
          final db = locator<AppDatabase>();
          final project = await db.getProjectById(projectId);
          if (project != null) {
            _navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => WebAppView(project: project)));
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          onGenerateRoute: (settings) {
            if (settings.name == '/create_widget') {
              return MaterialPageRoute(builder: (context) => const CreateWidgetPage());
            }
            return null;
          },
          title: 'Widget AI',
          builder: (context, child) => SafeArea(bottom: true, child: child!),
          theme: AppTheme.lightTheme,
          home: const WidgetScreen(),
        );
      },
    );
  }
}
