import 'package:go_router/go_router.dart';
import 'package:vr_trip/main.dart';
import 'package:vr_trip/router/routes.dart';
import 'package:vr_trip/screens/device_host/device_host_screen.dart';
import 'package:vr_trip/screens/device_host/screens/vr_player_host/vr_player_host_screen.dart';
import 'package:vr_trip/screens/devices_management/device_management_screen.dart';
import 'package:vr_trip/screens/file_manager/file_manager_screen.dart';
import 'package:vr_trip/screens/vr_player/vr_player_screen.dart';

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
          name: AppRoutes.deviceHost.name,
          path: 'device_host',
          builder: (context, state) => const DeviceHostScreen(),
          routes: <GoRoute>[
            GoRoute(
              name: AppRoutes.vrPlayerHost.name,
              path: 'vr_player_host/:videoPath/:serverIp',
              builder: (context, state) => VrPlayerHostScreen(
                  videoPath: state.pathParameters["videoPath"]!,
                  serverIp: state.pathParameters["serverIp"]!
              ),
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
              path: 'vr_player_file/:videoPath',
              builder: (context, state) =>
                  VrPlayerScreen(videoPath: state.pathParameters["videoPath"]!),
            ),
          ],
        ),
      ],
      name: AppRoutes.home.name,
      path: '/',
      builder: (context, state) => const MyHomePage(),
    ),
  ],
);
