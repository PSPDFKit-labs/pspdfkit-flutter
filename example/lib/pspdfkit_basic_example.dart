///
///  Copyright © 2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

import 'package:flutter/material.dart';
import 'utils/platform_utils.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

class PspdfkitBasicExample extends StatefulWidget {
  
  final String documentPath;

  const PspdfkitBasicExample(
      {Key? key, required this.documentPath})
      : super(key: key);

  @override
  _PspdfkitBasicExampleState createState() =>
      _PspdfkitBasicExampleState();
}

class _PspdfkitBasicExampleState extends State<PspdfkitBasicExample> {
late PspdfkitWidgetController pspdfkitWidgetController;

  Future<String> getExportPath(String assetPath) async {
    final tempDir = await Pspdfkit.getTemporaryDirectory();
    final tempDocumentPath = '${tempDir.path}/$assetPath';
    return tempDocumentPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          extendBodyBehindAppBar: PlatformUtils.isAndroid(),
          appBar: AppBar(),
          body: SafeArea(
              top: false,
              bottom: false,
              child: Container(
                  padding: PlatformUtils.isAndroid()
                      ? const EdgeInsets.only(top: kToolbarHeight)
                      : null,
                  child: Column(children: <Widget>[
                    Expanded(
                      child: PspdfkitWidget(
                        documentPath: widget.documentPath,
                        onPspdfkitWidgetCreated: (controller) {
                          pspdfkitWidgetController = controller;
                        },
                      ),
                    ),
                    SizedBox(
                        child: Column(children: <Widget>[
                      ElevatedButton(
                          onPressed: () async {
                          final newDocumentPath = await getExportPath(
                                'PDFs/Embedded/new_pdf_document_template.pdf');
                            await pspdfkitWidgetController.showAddPageView(
                                newDocumentPath);
                          },
                          child: const Text('Add Page'))
                    ]))
                  ]))));;
  }
}
