import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_cef_example/core/utils/constants.dart';
import 'package:webview_cef_example/features/browser/bloc/browser_bloc.dart';
import 'package:webview_cef_example/features/browser/presentation/widgets/dashed_shortcut_button.dart';

class BrowserHomePageBody extends StatelessWidget {
  const BrowserHomePageBody({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BrowserBloc>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppImages.logo,
                width: 42,
                height: 42,
              ),
              const SizedBox(width: 14),
              const Text(
                "Comet Browser",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DashedShortcutButton(
                onTap: () =>
                    bloc.add(const BrowserUrlLoadRequested("google.com")),
              ),
              const SizedBox(width: 16),
              DashedShortcutButton(
                onTap: () =>
                    bloc.add(const BrowserUrlLoadRequested("github.com")),
              ),
              const SizedBox(width: 16),
              DashedShortcutButton(
                onTap: () =>
                    bloc.add(const BrowserUrlLoadRequested("flutter.dev")),
              ),
              const SizedBox(width: 16),
              DashedShortcutButton(
                onTap: () =>
                    bloc.add(const BrowserUrlLoadRequested("youtube.com")),
              ),
              const SizedBox(width: 16),
              DashedShortcutButton(
                onTap: () =>
                    bloc.add(const BrowserUrlLoadRequested("reddit.com")),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
