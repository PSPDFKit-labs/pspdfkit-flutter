///
///  Copyright @ 2018-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
/// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';
import 'utils/platform_utils.dart';
import 'widgets/pdf_viewer_scaffold.dart';

/// Example demonstrating how to use the hideDelete custom data to conditionally
/// hide all annotation modification options in the PDF viewer.
/// 
/// This example shows how to create "protected" annotations that cannot be modified
/// by users. When annotations have 'hideDelete': true in their customData, all
/// modification actions are hidden from contextual menus.
/// 
/// References:
/// - Annotation Custom Data: https://www.nutrient.io/guides/flutter/annotations/annotation-json/
/// - Android Menu Customization: https://www.nutrient.io/guides/android/customizing-the-interface/customizing-the-toolbar/
/// - iOS Menu Customization: https://www.nutrient.io/guides/ios/customizing-the-interface/customizing-menus/
class HideDeleteAnnotationExampleWidget extends StatefulWidget {
  final String documentPath;
  final PdfConfiguration? configuration;

  const HideDeleteAnnotationExampleWidget({
    Key? key,
    required this.documentPath,
    this.configuration,
  }) : super(key: key);

  @override
  State<HideDeleteAnnotationExampleWidget> createState() =>
      _HideDeleteAnnotationExampleWidgetState();
}

class _HideDeleteAnnotationExampleWidgetState
    extends State<HideDeleteAnnotationExampleWidget> {
  late NutrientViewController view;
  late PdfDocument? document;

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCurrentPlatformSupported()) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Hide Annotation Modification Example'),
        ),
        body: Column(
          children: [
            // Control buttons at the top
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addProtectedAnnotations,
                      child: const Text('Add Protected'),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addEditableAnnotations,
                      child: const Text('Add Editable'),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _clearAllAnnotations,
                      child: const Text('Clear All'),
                    ),
                  ),
                ],
              ),
            ),
            // PDF viewer
            Expanded(
              child: PdfViewerScaffold(
                documentPath: widget.documentPath,
                configuration: widget.configuration,
                onPdfDocumentLoaded: (document) {
                  setState(() {
                    this.document = document;
                  });
                },
                onNutrientWidgetCreated: (controller) {
                  view = controller;
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text('Hide Annotation Modification Example')),
        body: Center(
          child: Text(
            '$defaultTargetPlatform is not yet supported by PSPDFKit for Flutter.',
          ),
        ),
      );
    }
  }

  /// Adds annotations with hideDelete: true custom data
  /// These annotations will not show any modification options (delete, edit, copy, cut, style picker, etc.) in their contextual menu
  /// 
  /// The hideDelete property can be set as:
  /// - String: 'hideDelete': 'true'
  /// - Boolean: 'hideDelete': true
  /// 
  /// Reference: https://www.nutrient.io/guides/flutter/annotations/annotation-json/
  Future<void> _addProtectedAnnotations() async {
    final protectedAnnotations = [
      // Protected highlight annotation - delete button will be hidden
      HighlightAnnotation(
        id: 'protected-highlight-1',
        name: 'Protected Highlight',
        bbox: [50.0, 400.0, 300.0, 20.0],
        createdAt: DateTime.now().toIso8601String(),
        color: const Color(0xFFFFEB3B),
        rects: [
          [50.0, 400.0, 350.0, 420.0],
        ],
        opacity: 0.7,
        pageIndex: 0,
        creatorName: 'System',
        customData: {
          'hideDelete': 'true', // This will hide all modification options (delete, edit, copy, cut, style picker, etc.)
          'protected': 'true',  // Additional custom property for application logic
          'reason': 'System generated annotation', // Additional metadata
        },
      ),

      // Protected note annotation - delete button will be hidden
      NoteAnnotation(
        id: 'protected-note-1',
        name: 'Protected Note',
        bbox: [400.0, 400.0, 32.0, 32.0],
        createdAt: DateTime.now().toIso8601String(),
        text: TextContent(
          value: 'This is a protected note that cannot be deleted',
          format: TextFormat.plain,
        ),
        color: const Color(0xFFFF5722),
        pageIndex: 0,
        creatorName: 'Administrator',
        customData: {
          'hideDelete': true, // Boolean value also works - hides all modification options  
          'protected': true,  // Additional custom property for application logic
          'adminGenerated': true, // Additional metadata
        },
      ),

      // Protected free text annotation - delete button will be hidden
      FreeTextAnnotation(
        id: 'protected-freetext-1',
        name: 'Protected Free Text',
        bbox: [50.0, 500.0, 200.0, 50.0],
        createdAt: DateTime.now().toIso8601String(),
        text: TextContent(
          format: TextFormat.plain,
          value: 'PROTECTED CONTENT',
        ),
        fontColor: const Color(0xFFFFFFFF),
        fontSize: 16,
        font: 'sans-serif',
        pageIndex: 0,
        creatorName: 'System',
        backgroundColor: const Color(0xFFFF5722),
        horizontalTextAlign: HorizontalTextAlignment.center,
        verticalAlign: VerticalAlignment.center,
        customData: {
          'hideDelete': 'true',
          'systemGenerated': true,
          'importance': 'high',
        },
      ),
    ];

    await document?.addAnnotations(protectedAnnotations);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Protected annotations added! Try to select them - no modification options will appear.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// Adds normal annotations without hideDelete custom data
  /// These annotations will show all modification options normally in their contextual menu
  /// 
  /// When hideDelete is not present or set to false, users can:
  /// - Delete annotations
  /// - Edit annotation content and properties  
  /// - Copy/cut annotations
  /// - Access style picker and inspector
  /// - Group/ungroup annotations
  /// 
  /// Reference: https://www.nutrient.io/guides/flutter/annotations/annotation-json/
  Future<void> _addEditableAnnotations() async {
    final editableAnnotations = [
      // Normal highlight annotation - delete button will be visible
      HighlightAnnotation(
        id: 'editable-highlight-1',
        name: 'Editable Highlight',
        bbox: [50.0, 300.0, 300.0, 20.0],
        createdAt: DateTime.now().toIso8601String(),
        color: const Color(0xFF4CAF50),
        rects: [
          [50.0, 300.0, 350.0, 320.0],
        ],
        opacity: 0.7,
        pageIndex: 0,
        creatorName: 'User',
        customData: {
          'editable': true,
          'userGenerated': true,
          // Note: no hideDelete property, so all modification options will be visible
        },
      ),

      // Normal note annotation - delete button will be visible
      NoteAnnotation(
        id: 'editable-note-1',
        name: 'Editable Note',
        bbox: [400.0, 300.0, 32.0, 32.0],
        createdAt: DateTime.now().toIso8601String(),
        text: TextContent(
          value: 'This note can be deleted normally',
          format: TextFormat.plain,
        ),
        color: const Color(0xFF2196F3),
        pageIndex: 0,
        creatorName: 'User',
        customData: {
          'editable': true,
          'userGenerated': true,
          // hideDelete is not set, so all modification options will appear
        },
      ),
    ];

    await document?.addAnnotations(editableAnnotations);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Editable annotations added! These will show all modification options.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Removes all annotations from the page
  Future<void> _clearAllAnnotations() async {
    try {
      final annotations = await document?.getAnnotations(0, AnnotationType.all);
      if (annotations == null) return;

      for (var annotation in annotations) {
        await document?.removeAnnotation(annotation);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All annotations cleared!'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing annotations: $e');
      }
    }
  }
}
