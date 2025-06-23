import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:viam_sdk/widgets.dart';

import '../../consts.dart';
import 'teleop_viewmodel.dart';

class TeleOpScreen extends StatefulWidget {
  const TeleOpScreen({super.key, required this.viewModel});

  final TeleopViewModel viewModel;

  @override
  State<TeleOpScreen> createState() => _TeleOpScreenState();
}

class _TeleOpScreenState extends State<TeleOpScreen> {
  @override
  void dispose() {
    widget.viewModel.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LED Robot Demo')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, child) {
              final isConnected = widget.viewModel.isConnected;

              if (!isConnected || widget.viewModel.lightStatus == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text('Connecting...'),
                    ],
                  ),
                );
              }

              final lightStatus = widget.viewModel.lightStatus!;

              return Column(
                children: [
                  if (widget.viewModel.camera != null &&
                      widget.viewModel.streamClient != null)
                    ViamCameraStreamView(
                      streamClient: widget.viewModel.streamClient!,
                      camera: widget.viewModel.camera!,
                    ),
                  const SizedBox(height: 8),
                  ShadButton(
                    expands: true,
                    backgroundColor:
                        lightStatus.red ? Colors.red : Colors.grey.shade800,
                    onPressed:
                        () => widget.viewModel.updatePin(
                          redPin,
                          !lightStatus.red,
                        ),
                    child: Text('Red', style: TextStyle(color: Colors.white)),
                  ),
                  ShadButton(
                    expands: true,
                    backgroundColor:
                        lightStatus.green ? Colors.green : Colors.grey.shade800,
                    onPressed:
                        () => widget.viewModel.updatePin(
                          greenPin,
                          !lightStatus.green,
                        ),
                    child: Text('Green'),
                  ),
                  ShadButton(
                    expands: true,
                    backgroundColor:
                        lightStatus.blue ? Colors.blue : Colors.grey.shade800,
                    onPressed:
                        () => widget.viewModel.updatePin(
                          bluePin,
                          !lightStatus.blue,
                        ),
                    child: Text('Blue'),
                  ),
                  ShadButton(
                    expands: true,
                    backgroundColor:
                        lightStatus.yellow
                            ? Colors.amber
                            : Colors.grey.shade800,
                    onPressed:
                        () => widget.viewModel.updatePin(
                          yellowPin,
                          !lightStatus.yellow,
                        ),
                    child: Text('Yellow'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
