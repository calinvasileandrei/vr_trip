import 'package:go_router/go_router.dart';
import 'package:vr_trip/main.dart';
import 'package:vr_trip/router/routes.dart';
import 'package:vr_trip/screens/device_client/device_client_screen.dart';
import 'package:vr_trip/screens/device_client/screens/vr_player_client/vr_player_client_screen.dart';
import 'package:vr_trip/screens/devices_management/device_management_screen.dart';
import 'package:vr_trip/screens/file_manager/file_manager_screen.dart';
import 'package:vr_trip/screens/select_manager/select_manager_screen.dart';
import 'package:vr_trip/screens/settings/settings_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      routes: <GoRoute>[
        GoRoute(
          name: AppRoutes.deviceManagement.name,
          path: 'device_management',
          builder: (context, state) => const DeviceManagementScreen(),
        ),
        GoRoute(
          name: AppRoutes.selectManager.name,
          path: 'select_manager',
          builder: (context, state) => const SelectManagerScreen(),
        ),
        GoRoute(
          name: AppRoutes.deviceHost.name,
          path: 'device_host',
          builder: (context, state) => const DeviceClientScreen(),
          routes: <GoRoute>[
            GoRoute(
              name: AppRoutes.vrPlayerClient.name,
              path: 'vr_player_client/:libraryItemPath',
              builder: (context, state) => VrPlayerClientScreen(
                  libraryItemPath: state.pathParameters["libraryItemPath"]!),
            ),
          ],
        ),
        GoRoute(
          name: AppRoutes.fileManager.name,
          path: 'file_manager',
          builder: (context, state) => const FileManagerScreen(),
          routes: <GoRoute>[
            GoRoute(
              name: AppRoutes.vrPlayerFile.name,
              path: 'vr_player_file/:libraryItemPath',
              builder: (context, state) =>
                  VrPlayerClientScreen(libraryItemPath: state.pathParameters["libraryItemPath"]!),
            ),
          ],
        ),
        GoRoute(
          name: AppRoutes.settings.name,
          path: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
      name: AppRoutes.home.name,
      path: '/',
      builder: (context, state) => const MyHomePage(),
    ),
  ],
);
