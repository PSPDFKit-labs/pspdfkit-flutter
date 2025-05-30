///
///  Copyright © 2024-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/material.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

class DisableAnnotationEditingExample extends StatefulWidget {
  final String documentPath;

  const DisableAnnotationEditingExample(
      {super.key, required this.documentPath});

  @override
  State<DisableAnnotationEditingExample> createState() =>
      _DisableAnnotationEditingExampleState();
}

class _DisableAnnotationEditingExampleState
    extends State<DisableAnnotationEditingExample> {
  PspdfkitWidgetController? _pspdfkitWidgetController;
  var isAnnotationEditingEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            top: false,
            bottom: false,
            child: Stack(
              children: [
                PspdfkitWidget(
                  documentPath: widget.documentPath,
                  onPspdfkitWidgetCreated: (view) {
                    _pspdfkitWidgetController = view;
                    // Disable annotation editing
                  },
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_pspdfkitWidgetController != null) {
                        // Disable annotation editing
                        await _pspdfkitWidgetController
                            ?.enableAnnotationEditing(
                                enable: !isAnnotationEditingEnabled);
                        setState(() {
                          isAnnotationEditingEnabled =
                              !isAnnotationEditingEnabled;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Annotation editing disabled')),
                        );
                      }
                    },
                    child: const Text('Disable Annotation Editing'),
                  ),
                ),
              ],
            )));
  }
}
