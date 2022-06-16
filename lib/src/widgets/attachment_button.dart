import 'package:flutter/material.dart';
import 'inherited_chat_theme.dart';
import 'inherited_l10n.dart';

/// A class that represents attachment button widget
class AttachmentButton extends StatelessWidget {
  /// Creates attachment button widget
  const AttachmentButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  /// Callback for attachment button tap event
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: InheritedChatTheme.of(context).theme.inputBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      height: 40,
      padding: const EdgeInsets.all(2),
      width: 40,
      child: IconButton(
        icon: InheritedChatTheme.of(context).theme.attachmentButtonIcon != null
            ? Image.asset(
                InheritedChatTheme.of(context).theme.attachmentButtonIcon!,
                color: InheritedChatTheme.of(context).theme.inputTextColor,
              )
            : Image.asset(
                'assets/icon-attachment.png',
                color: InheritedChatTheme.of(context).theme.inputTextColor,
                package: 'flutter_chat_ui',
              ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        tooltip:
            InheritedL10n.of(context).l10n.attachmentButtonAccessibilityLabel,
      ),
    );
  }
}
