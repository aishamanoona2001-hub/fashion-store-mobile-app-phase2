/// fashion_store/lib/widgets/loading_button.dart
///
/// A reusable elevated button that shows a [CircularProgressIndicator]
/// in place of its label while an async operation is in progress.
///
/// Used on both [LoginScreen] and [RegisterScreen] to prevent the user
/// from tapping twice while a Firebase request is in flight.

import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  /// The text shown when the button is idle.
  final String label;

  /// Callback invoked when the button is tapped (only when not loading).
  final VoidCallback onPressed;

  /// When true, the button shows a spinner and ignores taps.
  final bool isLoading;

  const LoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      // Disable the callback while loading to prevent duplicate requests.
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
          : Text(label),
    );
  }
}
