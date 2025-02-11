import 'package:flutter/material.dart';
import 'inherited_chat_theme.dart';
import 'inherited_l10n.dart';

/// A class that represents send button widget
class SendButton extends StatelessWidget {
  /// Creates send button widget
  const SendButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  /// Callback for send button tap event
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: InheritedChatTheme.of(context).theme.inputBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      height: 40,
      padding: const EdgeInsets.all(3),
      width: 40,
      child: IconButton(
        icon: InheritedChatTheme.of(context).theme.sendButtonIcon != null
            ? Image.asset(
                InheritedChatTheme.of(context).theme.sendButtonIcon!,
                color: InheritedChatTheme.of(context).theme.inputTextColor,
              )
            : Image.asset(
                'assets/icon-send.png',
                height: 20,
                width: 20,
                color: InheritedChatTheme.of(context).theme.inputTextColor,
                package: 'flutter_chat_ui',
              ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        tooltip: InheritedL10n.of(context).l10n.sendButtonAccessibilityLabel,
      ),
    );
  }
}
