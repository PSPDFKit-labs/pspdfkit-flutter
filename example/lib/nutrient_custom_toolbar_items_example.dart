import 'package:flutter/material.dart';

import 'package:pspdfkit_flutter/pspdfkit.dart';
import 'utils/platform_utils.dart';

class NutrientCustomToolbarItemsExample extends StatefulWidget {
  final String documentPath;

  const NutrientCustomToolbarItemsExample(
      {super.key, required this.documentPath});

  @override
  State<NutrientCustomToolbarItemsExample> createState() =>
      _NutrientCustomToolbarItemsExampleState();
}

class _NutrientCustomToolbarItemsExampleState
    extends State<NutrientCustomToolbarItemsExample> {
  PspdfkitWidgetController? _pspdfkitWidgetController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: PlatformUtils.isAndroid(),
        // Do not resize the the document view on Android or
        // it won't be rendered correctly when filling forms.
        resizeToAvoidBottomInset: PlatformUtils.isIOS(),
        appBar: AppBar(
          title: const Text('Custom Toolbar Items'),
        ),
        body: SafeArea(
            top: false,
            bottom: false,
            child: Container(
                padding: PlatformUtils.isAndroid()
                    ? const EdgeInsets.only(top: kToolbarHeight)
                    : null,
                child: PspdfkitWidget(
                    customToolbarItems: [
                      CustomToolbarItem(
                        title: 'Image',
                        identifier: 'custom-toolbar-item',
                        iconColor: "#000000",
                        iconName: "toolbar_item",
                      ),
                      CustomToolbarItem(
                        title: 'Signature',
                        identifier: 'custom-toolbar-item-2',
                        iconColor: "#000000",
                        iconName: "toolbar_item",
                      ),
                      CustomToolbarItem(
                        identifier: 'custom-toolbar-item-3',
                        title: 'Pen',
                        iconColor: "#000000",
                        iconName: "toolbar_item",
                      ),
                    ],
                    onCustomToolbarItemTapped: (identifier) {
                      switch (identifier) {
                        case 'custom-toolbar-item':
                          {
                            _pspdfkitWidgetController
                                ?.enterAnnotationCreationMode(
                                    AnnotationTool.image);
                          }
                          break;
                        case 'custom-toolbar-item-2':
                          _pspdfkitWidgetController
                              ?.enterAnnotationCreationMode(
                                  AnnotationTool.signature);
                          break;
                        case 'custom-toolbar-item-3':
                          _pspdfkitWidgetController
                              ?.enterAnnotationCreationMode(
                                  AnnotationTool.inkPen);
                          break;
                      }
                    },
                    documentPath: widget.documentPath,
                    onPspdfkitWidgetCreated: (view) {
                      setState(() {
                        _pspdfkitWidgetController = view;
                      });
                    },
                    configuration: PdfConfiguration(
                        androidShowAnnotationListAction: false,
                        androidShowSearchAction: false,
                        androidShowShareAction: false,
                        androidShowDocumentInfoView: false,
                        androidShowThumbnailGridAction: false,
                        androidShowPrintAction: false)))));
  }
}
