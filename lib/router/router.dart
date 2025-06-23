import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/robot_repository.dart';
import '../screens/home_screen.dart';
import '../screens/teleop/teleop.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'robot',
          builder:
              (context, state) => TeleOpScreen(
                viewModel: TeleopViewModel(context.read<RobotRepository>()),
              ),
        ),
      ],
    ),
  ],
);
