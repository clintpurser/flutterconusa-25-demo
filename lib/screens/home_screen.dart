import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../consts.dart';
import '../data/repositories/robot_repository.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              ListTile(
                title: Text('Demo LED Bot 🤖'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  context.read<RobotRepository>().connect(
                    host: host,
                    apiKeyID: apiKeyID,
                    apiKey: apiKey,
                  );
                  context.go('/robot');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
