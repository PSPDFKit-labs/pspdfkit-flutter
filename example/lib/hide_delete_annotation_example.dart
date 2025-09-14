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

/// Example demonstrating how to use the hideDelete custom data to disable
/// annotation editing while still allowing movement.
/// 
/// This example shows how to create "protected" annotations that can be moved but not
/// edited or resized. When annotations have 'hideDelete': true in their customData:
/// - The contextual toolbar/menu is completely disabled
/// - Annotation resizing is blocked
/// - Annotation movement is still allowed
/// - All modification actions (delete, edit, copy, cut, style picker, etc.) are prevented
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
          title: const Text('Protected Annotations (Move Only)'),
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
  /// These annotations will have their contextual toolbar/menu completely disabled and cannot be resized,
  /// but can still be moved around the page.
  /// 
  /// Behavior for protected annotations:
  /// - No contextual toolbar/menu appears when selected
  /// - Cannot be resized (handles are disabled)
  /// - Can still be moved by dragging
  /// - Cannot be deleted, edited, copied, cut, styled, etc.
  /// 
  /// The hideDelete property can be set as:
  /// - String: 'hideDelete': 'true' 
  /// - Boolean: 'hideDelete': true
  /// 
  /// Reference: https://www.nutrient.io/guides/flutter/annotations/annotation-json/
  Future<void> _addProtectedAnnotations() async {
    final protectedAnnotations = [
      // Protected highlight annotation - contextual menu disabled, resizing blocked, movement allowed
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
          'hideDelete': 'true', // This will disable contextual menu and resizing, but allow movement
          'protected': 'true',  // Additional custom property for application logic
          'reason': 'System generated annotation', // Additional metadata
        },
      ),

      // Protected note annotation - contextual menu disabled, resizing blocked, movement allowed
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
        flags: [AnnotationFlag.lockedContents],
        creatorName: 'Administrator',
        customData: {
          'hideDelete': true, // Boolean value also works - disables contextual menu and resizing  
          'protected': true,  // Additional custom property for application logic
          'adminGenerated': true, // Additional metadata
        },
      ),

      // Protected free text annotation - contextual menu disabled, resizing blocked, movement allowed
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
        flags: [AnnotationFlag.lockedContents],
        customData: {
          'hideDelete': 'true',
          'systemGenerated': true,
          'importance': 'high',
        },
      ),
      InkAnnotation(
          id: 'ink-annotation-1',
          bbox: [267.4, 335.1, 97.2, 10.3],
          createdAt: '2025-01-06T16:36:59+03:00',
          lines: InkLines(
            points: [
              [
                [269.4, 343.4],
                [308.4, 341.7],
                [341.2, 339.6],
                [358.8, 339.6],
                [360.9, 339.2],
                [362.6, 338.8],
                [361.7, 337.1],
              ]
            ],
            intensities: [
              [1.0, 0.43, 0.64, 0.83, 0.98, 0.99, 0.97]
            ],
          ),
          lineWidth: 4,
          opacity: 1.0,
          flags: [AnnotationFlag.lockedContents],
          creatorName: 'Nutrient Flutter',
          name: 'Ink annotation 1',
          isDrawnNaturally: false,
          strokeColor: const Color(0xFFFF5722),
          customData: {
            "phone": "123-456-7890",
            "email": "3XZ5y@example.com",
            "address": "123 Main St, Anytown, USA 12345",
            "hideDelete": true,
            "userGenerated": true
          },
          pageIndex: 0)
    ];

    await document?.addAnnotations(protectedAnnotations);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Protected annotations added! Try selecting them - no contextual menu will appear, but you can still move them.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// Adds normal annotations without hideDelete custom data
  /// These annotations will show the full contextual toolbar/menu with all modification options
  /// 
  /// When hideDelete is not present or set to false, users can:
  /// - Delete annotations
  /// - Edit annotation content and properties  
  /// - Copy/cut annotations
  /// - Access style picker and inspector
  /// - Group/ungroup annotations
  /// - Resize annotations using handles
  /// - Move annotations by dragging
  /// 
  /// Reference: https://www.nutrient.io/guides/flutter/annotations/annotation-json/
  Future<void> _addEditableAnnotations() async {
    final editableAnnotations = [
      // Normal highlight annotation - full contextual menu available
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

      // Normal note annotation - full contextual menu available
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
          // hideDelete is not set, so full contextual menu will appear
        },
      ),

    ];

    await document?.addAnnotations(editableAnnotations);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Editable annotations added! These will show the full contextual menu with all editing options.'),
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
