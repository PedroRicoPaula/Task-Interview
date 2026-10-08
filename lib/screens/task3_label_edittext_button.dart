import 'package:flutter/material.dart';

/// Task 3 - "Design a layout with three UI elements: a label, an EditText and a
/// button. When the button is pressed, the label should display the content of
/// the EditText."
///
/// Flutter equivalents of the Android widgets named in the task:
/// `EditText` -> [TextField], label (`TextView`) -> [Text].
class Task3LabelEditTextButtonScreen extends StatefulWidget {
  const Task3LabelEditTextButtonScreen({super.key});

  @override
  State<Task3LabelEditTextButtonScreen> createState() =>
      _Task3LabelEditTextButtonScreenState();
}

class _Task3LabelEditTextButtonScreenState
    extends State<Task3LabelEditTextButtonScreen> {
  static const String _initialLabel = 'The text will appear here';
  static const String _emptyInputLabel = 'The text field is empty';

  final TextEditingController _controller = TextEditingController();

  /// Text currently displayed by the label.
  String _label = _initialLabel;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showTextOnLabel() {
    setState(() {
      _label = _controller.text.isEmpty ? _emptyInputLabel : _controller.text;
    });
    // Dismiss the keyboard so the label stays visible.
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task 3 - Label, EditText, Button')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. The label.
            Container(
              key: const Key('label'),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 2. The text field (Android's EditText).
            TextField(
              key: const Key('editText'),
              controller: _controller,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _showTextOnLabel(),
              decoration: const InputDecoration(
                labelText: 'Type something',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // 3. The button.
            FilledButton(
              key: const Key('button'),
              onPressed: _showTextOnLabel,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Show on label'),
            ),
          ],
        ),
      ),
    );
  }
}
