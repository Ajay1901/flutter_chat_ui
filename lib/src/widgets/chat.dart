import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/src/widgets/inherited_l10n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../chat_l10n.dart';
import '../chat_theme.dart';
import '../conditional/conditional.dart';
import '../util.dart';
import 'inherited_chat_theme.dart';
import 'inherited_user.dart';
import 'input.dart';
import 'message.dart';

/// Entry widget, represents the complete chat
class Chat extends StatefulWidget {
  /// Creates a chat widget
  Chat({
    Key? key,
    this.dateLocale,
    this.disableImageGallery,
    this.isAttachmentUploading,
    this.l10n = const ChatL10nEn(),
    required this.messages,
    this.onAttachmentPressed,
    this.onMessageLongPress,
    this.onMessageTap,
    this.onPreviewDataFetched,
    required this.onSendPressed,
    this.theme = const DefaultChatTheme(),
    required this.user,
    this.usersUidMap,
    this.deviceTimeOffset = 0,
    this.room,
    this.isMultiselectOn = false,
    this.isDeleteButtonVisible = false,
    this.isEditButtonVisible = false,
    this.onEditMessage,
    this.selectedMessages,
    this.onDeleteMessages,
    this.selfUidMap,
  }) : super(key: key);

  final Map<String, String>? usersUidMap;
  final Map<String, String>? selfUidMap;
  final types.Room? room;
  final int deviceTimeOffset;

  /// See [Message.dateLocale]
  final String? dateLocale;

  final bool? isDeleteButtonVisible;
  final bool? isEditButtonVisible;

  final Function(types.TextMessage message, String text)? onEditMessage;
  final Function(List<types.Message> messages)? onDeleteMessages;

  /// Disable automatic image preview on tap.
  final bool? disableImageGallery;

  /// See [Input.isAttachmentUploading]
  final bool? isAttachmentUploading;

  /// Localized copy. Extend [ChatL10n] class to create your own copy or use
  /// existing one, like the default [ChatL10nEn]. You can customize only
  /// certain variables, see more here [ChatL10nEn].
  final ChatL10n l10n;

  /// List of [types.Message] to render in the chat widget
  final List<types.Message> messages;

  /// See [Input.onAttachmentPressed]
  final void Function()? onAttachmentPressed;

  /// See [Message.onMessageLongPress]
  final void Function(types.Message)? onMessageLongPress;

  /// See [Message.onMessageTap]
  final void Function(types.Message)? onMessageTap;

  /// See [Message.onPreviewDataFetched]
  final void Function(types.TextMessage, types.PreviewData)?
      onPreviewDataFetched;

  /// See [Input.onSendPressed]
  final void Function(types.PartialText) onSendPressed;

  /// Chat theme. Extend [ChatTheme] class to create your own theme or use
  /// existing one, like the [DefaultChatTheme]. You can customize only certain
  /// variables, see more here [DefaultChatTheme].
  final ChatTheme theme;

  /// See [InheritedUser.user]
  final types.User user;

  bool isMultiselectOn;

  final Function(List<types.Message>)? selectedMessages;

  @override
  _ChatState createState() => _ChatState();
}

/// [Chat] widget state
class _ChatState extends State<Chat> {
  bool _isImageViewVisible = false;
  int _imageViewIndex = 0;
  final List<types.Message> _selectedMessages = [];
  bool _isCopyVisible = true;
  bool _isdeleteVisible = true;
  bool _isEditVisible = true;

  Widget _imageGalleryLoadingBuilder(
    BuildContext context,
    ImageChunkEvent? event,
  ) {
    return Center(
      child: SizedBox(
        width: 20.0,
        height: 20.0,
        child: CircularProgressIndicator(
          value: event == null || event.expectedTotalBytes == null
              ? 0
              : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
        ),
      ),
    );
  }

  bool _isMessageSelected(types.Message message) {
    return _selectedMessages.contains(message);
  }

  void _onCloseGalleryPressed() {
    setState(() {
      _isImageViewVisible = false;
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  void _onImagePressed(
    String uri,
    List<String> galleryItems,
  ) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    setState(() {
      _isImageViewVisible = true;
      _imageViewIndex = galleryItems.indexOf(uri);
    });
  }

  Future<void> copySelectedMessage() async {
    _selectedMessages.sort((a, b) {
      return DateTime.fromMillisecondsSinceEpoch(a.timestamp! * 1000)
          .compareTo(DateTime.fromMillisecondsSinceEpoch(b.timestamp! * 1000));
    });
    var copiedMessages = '';
    for (var i = 0; i < _selectedMessages.length; i++) {
      final textMessage = _selectedMessages[i] as types.TextMessage;
      final key = textMessage.authorId;
      final date =
          DateTime.fromMillisecondsSinceEpoch(textMessage.timestamp! * 1000);
      final finalDate = DateFormat('dd/MM, hh:mm a').format(date);
      var name = widget.usersUidMap![key];
      name ??= widget.selfUidMap![key];
      copiedMessages =
          copiedMessages + '[$finalDate] $name: ${textMessage.text}\n';
    }
    final data = ClipboardData(text: copiedMessages);
    await Clipboard.setData(data);
  }

  int copyButtonVisiblityChecker() {
    int flag = 0;
    for (var i = 0; i < _selectedMessages.length; i++) {
      if (_selectedMessages[i].type == types.MessageType.file ||
          _selectedMessages[i].type == types.MessageType.image) {
        flag++;
      }
    }
    return flag;
  }

  void clearSelectedMessages() {
    _selectedMessages.clear();
    widget.isMultiselectOn = false;
    widget.selectedMessages?.call(_selectedMessages);
  }

  void _onPageChanged(int index) {
    setState(() {
      _imageViewIndex = index;
    });
  }

  void _onPreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    widget.onPreviewDataFetched?.call(message, previewData);
  }

  Widget _renderImageGallery(List<String> galleryItems) {
    return Dismissible(
      key: const Key('photo_view_gallery'),
      direction: DismissDirection.down,
      onDismissed: (direction) => _onCloseGalleryPressed(),
      child: Stack(
        children: [
          PhotoViewGallery.builder(
            builder: (BuildContext context, int index) =>
                PhotoViewGalleryPageOptions(
              imageProvider: Conditional().getProvider(galleryItems[index]),
            ),
            itemCount: galleryItems.length,
            loadingBuilder: (context, event) =>
                _imageGalleryLoadingBuilder(context, event),
            onPageChanged: _onPageChanged,
            pageController: PageController(initialPage: _imageViewIndex),
            scrollPhysics: const ClampingScrollPhysics(),
          ),
          Positioned(
            right: 20,
            top: 50,
            child: CloseButton(
              color: Colors.white,
              onPressed: _onCloseGalleryPressed,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _messageWidth =
        min(MediaQuery.of(context).size.width * 0.77, 440).floor();

    final galleryItems =
        widget.messages.fold<List<String>>([], (previousValue, element) {
      // Check if element is image message
      if (element is types.ImageMessage) {
        // For web add only remote uri, local files are not yet supported
        if (kIsWeb) {
          if (element.uri.startsWith('http')) {
            return [element.uri, ...previousValue];
          } else {
            return previousValue;
          }
          // For everything else add uri
        } else {
          return [element.uri, ...previousValue];
        }
      }

      return previousValue;
    });

    _isdeleteVisible = widget.isDeleteButtonVisible ?? true;

    _isEditVisible = widget.isEditButtonVisible ?? true;
    return InheritedUser(
      user: widget.user,
      child: InheritedChatTheme(
        theme: widget.theme,
        child: InheritedL10n(
          l10n: widget.l10n,
          child: Stack(
            children: [
              Container(
                color: widget.isMultiselectOn
                    ? const Color(0xff1d1d21).withOpacity(0.8)
                    : widget.theme.backgroundColor,
                child: SafeArea(
                  bottom: false,
                  child: Container(
                    color: widget.theme.backgroundColor,
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          multiSelectionOptionsBar(),
                          Flexible(
                            child: widget.messages.isEmpty
                                ? SizedBox.expand(
                                    child: Container(
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                      ),
                                      child: Text(
                                        widget.l10n.emptyChatPlaceholder,
                                        style: widget.theme.body1.copyWith(
                                          color: widget.theme.captionColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () => FocusManager
                                        .instance.primaryFocus
                                        ?.unfocus(),
                                    child: ListView.builder(
                                      itemCount: widget.messages.length + 1,
                                      padding: EdgeInsets.zero,
                                      reverse: true,
                                      itemBuilder: (context, index) {
                                        if (index == widget.messages.length) {
                                          return Container(height: 16);
                                        }

                                        final message = widget.messages[index];
                                        final isFirst = index == 0;
                                        final isLast =
                                            index == widget.messages.length - 1;
                                        final nextMessage = isLast
                                            ? null
                                            : widget.messages[index + 1];
                                        final previousMessage = isFirst
                                            ? null
                                            : widget.messages[index - 1];

                                        var nextMessageDifferentDay = false;
                                        var nextMessageSameAuthor = false;
                                        var previousMessageSameAuthor = false;
                                        var shouldRenderTime =
                                            message.timestamp != null;

                                        if (nextMessage != null &&
                                            nextMessage.timestamp != null) {
                                          nextMessageDifferentDay = message
                                                      .timestamp !=
                                                  null &&
                                              DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                    message.timestamp! * 1000,
                                                  ).day !=
                                                  DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                    nextMessage.timestamp! *
                                                        1000,
                                                  ).day;
                                          nextMessageSameAuthor =
                                              nextMessage.authorId ==
                                                  message.authorId;
                                        }

                                        if (previousMessage != null) {
                                          previousMessageSameAuthor =
                                              previousMessage.authorId ==
                                                  message.authorId;
                                          shouldRenderTime = message
                                                      .timestamp !=
                                                  null &&
                                              previousMessage.timestamp !=
                                                  null &&
                                              (!previousMessageSameAuthor ||
                                                  previousMessage.timestamp! -
                                                          message.timestamp! >=
                                                      60);
                                        }

                                        return Column(
                                          children: [
                                            if (nextMessageDifferentDay ||
                                                (isLast &&
                                                    message.timestamp != null))
                                              Container(
                                                margin: EdgeInsets.only(
                                                  bottom: 32,
                                                  top: nextMessageSameAuthor
                                                      ? 24
                                                      : 16,
                                                ),
                                                child: Text(
                                                  getVerboseDateTimeRepresentation(
                                                    DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                      message.timestamp! * 1000,
                                                    ),
                                                    widget.dateLocale,
                                                    widget.l10n.today,
                                                    widget.l10n.yesterday,
                                                  ),
                                                  style: widget.theme.subtitle2
                                                      .copyWith(
                                                    color: widget
                                                        .theme.subtitle2Color,
                                                  ),
                                                ),
                                              ),
                                            Message(
                                              isSelected:
                                                  _isMessageSelected(message),
                                              deviceTimeOffset:
                                                  widget.deviceTimeOffset,
                                              key: ValueKey(message),
                                              room: widget.room,
                                              usersUidMap: widget.usersUidMap,
                                              dateLocale: widget.dateLocale,
                                              message: message,
                                              messageWidth: _messageWidth,
                                              onMessageLongPress: (message) {
                                                if (widget.isMultiselectOn ==
                                                    true) {
                                                  return;
                                                }
                                                if (message.type ==
                                                        types
                                                            .MessageType.file ||
                                                    message.type ==
                                                        types.MessageType
                                                            .image) {
                                                  _isCopyVisible = false;
                                                } else {
                                                  _isCopyVisible = true;
                                                }
                                                if (message.type !=
                                                    types.MessageType.deleted) {
                                                  widget.onMessageLongPress
                                                      ?.call(message);
                                                  widget.isMultiselectOn = true;
                                                  _selectedMessages
                                                      .add(message);
                                                  widget.selectedMessages
                                                      ?.call(_selectedMessages);
                                                }
                                                setState(() {});
                                              },
                                              onMessageTap: (tappedMessage) {
                                                if (widget.isMultiselectOn) {
                                                  if (tappedMessage.type !=
                                                      types.MessageType
                                                          .deleted) {
                                                    _selectedMessages.contains(
                                                            tappedMessage)
                                                        ? _selectedMessages
                                                            .remove(
                                                                tappedMessage)
                                                        : _selectedMessages
                                                            .add(tappedMessage);
                                                    if (_selectedMessages
                                                        .isEmpty) {
                                                      widget.isMultiselectOn =
                                                          false;
                                                    }
                                                    widget.selectedMessages
                                                        ?.call(
                                                            _selectedMessages);
                                                    var flag =
                                                        copyButtonVisiblityChecker();
                                                    if (flag >= 1) {
                                                      _isCopyVisible = false;
                                                    } else {
                                                      _isCopyVisible = true;
                                                    }
                                                  }
                                                  setState(() {});
                                                } else {
                                                  if (tappedMessage is types
                                                          .ImageMessage &&
                                                      widget.disableImageGallery !=
                                                          true) {
                                                    _onImagePressed(
                                                      tappedMessage.uri,
                                                      galleryItems,
                                                    );
                                                  }
                                                  widget.onMessageTap
                                                      ?.call(tappedMessage);
                                                }
                                              },
                                              onPreviewDataFetched:
                                                  _onPreviewDataFetched,
                                              previousMessageSameAuthor:
                                                  previousMessageSameAuthor,
                                              shouldRenderTime:
                                                  shouldRenderTime,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                          ),
                          Input(
                            isAttachmentUploading: widget.isAttachmentUploading,
                            onAttachmentPressed: () {
                              clearSelectedMessages();
                              widget.onAttachmentPressed?.call();
                            },
                            onSendPressed: (text) {
                              clearSelectedMessages();
                              widget.onSendPressed(text);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_isImageViewVisible) _renderImageGallery(galleryItems),
            ],
          ),
        ),
      ),
    );
  }

  Visibility multiSelectionOptionsBar() {
    return Visibility(
      visible: widget.isMultiselectOn,
      child: Container(
        color: const Color(0xff1d1d21).withOpacity(0.8),
        child: ButtonBar(
          alignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                color: Colors.white,
                tooltip: 'Cancel',
                onPressed: () {
                  clearSelectedMessages();
                  setState(() {});
                },
                icon: const Icon(Icons.close)),
            Row(
              children: [
                if (_isCopyVisible)
                  IconButton(
                      color: Colors.white,
                      tooltip: 'Copy',
                      onPressed: () {
                        copySelectedMessage();
                        clearSelectedMessages();
                        showCopiedSnackbar();
                        setState(() {});
                      },
                      icon: const Icon(Icons.copy)),
                if (_isEditVisible)
                  // ExcludeSemantics(
                  //   child: SvgPicture.asset(
                  //     image,
                  //     //height: device.height * 0.35,
                  //     color: Colors.black,
                  //   ),
                  // ),
                  Tooltip(
                    message: 'Edit',
                    child: GestureDetector(
                      onTap: () {
                        _editMessage(
                            _selectedMessages.first as types.TextMessage);
                        clearSelectedMessages();
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: SvgPicture.asset(
                          'packages/flutter_chat_ui/assets/listed_by_todo_icon.svg',
                          width: 25.0,
                          height: 25.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (_isdeleteVisible)
                  IconButton(
                      color: Colors.white,
                      tooltip: 'Delete',
                      onPressed: () {
                        widget.onDeleteMessages?.call(_selectedMessages);
                        clearSelectedMessages();
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.delete,
                      )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showCopiedSnackbar() {
    final snackBar = SnackBar(
      duration: const Duration(milliseconds: 500),
      content: const Text(
        'Copied',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14),
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      margin: const EdgeInsets.fromLTRB(140, 30, 130, 100),
      backgroundColor: Colors.grey[700],
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _editMessage(types.TextMessage message) {
    final textEditingController = TextEditingController(
      text: message.text,
    );
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (context) {
          return Container(
            height: 200,
            margin: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 255, 251, 251),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text('Edit Message',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700])),
                TextField(
                  controller: textEditingController,
                  decoration: const InputDecoration(
                    hintText: 'Edit message',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (textEditingController.text.isNotEmpty &&
                            textEditingController.text.trim() !=
                                message.text.trim()) {
                          widget.onEditMessage?.call(
                            message,
                            textEditingController.text,
                          );
                        }
                      },
                      child: const Text(
                        'Save',
                        // style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
