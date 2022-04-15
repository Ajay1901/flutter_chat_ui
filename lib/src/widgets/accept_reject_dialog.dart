import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RejectAcceptDialog extends StatefulWidget {
  final String? title;
  final String body;
  final Function() okAction;
  final Function() cancel;

  RejectAcceptDialog({
    required this.title,
    required this.body,
    required this.okAction,
    required this.cancel,
  });

  @override
  _RejectAcceptDialogState createState() => _RejectAcceptDialogState();
}

class _RejectAcceptDialogState extends State<RejectAcceptDialog> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    final devWidth = MediaQuery.of(context).size.width;
    final devHeight = MediaQuery.of(context).size.height;

    return MergeSemantics(
      child: Semantics(
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          backgroundColor: const Color(0xFFFFFFFF),
          child: IntrinsicHeight(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all( Radius.circular(30.0)),
              ),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SvgPicture.asset(
                        'packages/flutter_chat_ui/assets/dialog_image.svg',
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: devHeight * 0.01,
                              left: devWidth * 0.06,
                              right: devWidth * 0.25,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (widget.title != null)
                                  BlockSemantics(
                                    child: Text(
                                      widget.title!,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18),
                                    ),
                                  ),
                                if (widget.title != null)
                                  SizedBox(
                                    height: devHeight * 0.03,
                                  ),
                                Text(
                                  widget.body,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                      color: Color.fromRGBO(75, 93, 107, 0.81)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 25, left: 25),
                              child: GestureDetector(
                                onTap: () {
                                  widget.cancel();
                                },
                                child: Container(
                                  width: 70,
                                  height: 30,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.all(
                                           Radius.circular(8)),
                                      border: Border.all(
                                          color: const Color(0xFF4B5D6B),
                                          width: 2)),
                                  child: const Center(
                                    child: Text(
                                      'CANCEL',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: Color(0xFF4B5D6B)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 16,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  widget.okAction();
                                },
                                child: Container(
                                  width: 70,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color:  Color(0xFF4B5D6B),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(8)),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'YES',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
