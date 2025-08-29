///
///  Copyright 2024-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutrient_example/models/nutrient_example_item.dart';
import 'package:nutrient_example/nutrient_ai_assistant_example.dart';
import 'package:nutrient_example/nutrient_web_event_listeners.dart';
import 'package:nutrient_example/toolbar_customization.dart';
import 'package:nutrient_flutter/nutrient_flutter.dart';

import 'custom_toolbar_example.dart';
import 'instant_collaboration_web.dart';
import 'annotation_preset_customisation.dart';
import 'document_example.dart';
import 'event_listeners_example.dart';
import 'zoom_example.dart';
import 'utils/file_utils.dart';
import 'utils/platform_utils.dart';
import 'package:nutrient_example/configuration_example.dart';
import 'package:nutrient_example/instant_collaboration_example.dart';
import 'package:nutrient_example/measurement_tools.dart';
import 'package:nutrient_example/pdf_generation_example.dart';
import 'package:nutrient_example/save_as_example.dart';
import 'package:nutrient_example/nutrient_annotation_flags.dart';

import 'basic_example.dart';
import 'form_example.dart';
import 'instantjson_example.dart';
import 'annotations_example.dart';
import 'manual_save_example.dart';
import 'annotation_processing_example.dart';
import 'password_example.dart';
import 'nutrient_annotation_creation_mode_example.dart';
import 'hide_delete_annotation_example.dart';

const String _documentPath = 'PDFs/PSPDFKit.pdf';
const String _measurementsDocs = 'PDFs/Measurements.pdf';
const String _lockedDocumentPath = 'PDFs/protected.pdf';
const String _imagePath = 'PDFs/PSPDFKit_Image_Example.jpg';
const String _formPath = 'PDFs/Form_example.pdf';
const String _instantDocumentJsonPath = 'PDFs/Instant/instant-document.json';
const String _xfdfPath = 'PDFs/Instant/document.xfdf';
const String _processedDocumentPath = 'PDFs/Embedded/PSPDFKit-processed.pdf';

List<NutrientExampleItem> examples(BuildContext context) => [
      NutrientExampleItem(
        title: 'Basic Example',
        description: 'Opens a PDF Document.',
        onTap: () async {
          await extractAsset(context, _documentPath).then(
              (value) => goTo(BasicExample(documentPath: value.path), context));
        },
      ),
      if (!kIsWeb)
        NutrientExampleItem(
          title: 'Basic Example using Platform Style',
          description:
              'Opens a PDF Document using Material page scaffolding for Android, and Cupertino page scaffolding for iOS.',
          onTap: () async {
            await extractAsset(context, _documentPath).then((value) =>
                goTo(BasicExample(documentPath: value.path), context));
          },
        ),
      NutrientExampleItem(
        title: 'Image Document',
        description: 'Opens an image document.',
        onTap: () => showImage(context),
      ),
      NutrientExampleItem(
          title: 'Document Example',
          description: 'Shows how to get document properties after loading.',
          onTap: () async {
            await extractAsset(context, _documentPath).then((value) =>
                goTo(DocumentExample(documentPath: value.path), context));
          }),
      NutrientExampleItem(
        title: 'Dark Theme',
        description: 'Opens a document in night mode with a custom dark theme.',
        onTap: () => applyDarkTheme(context),
      ),
      NutrientExampleItem(
        title: 'Custom configuration options',
        description: 'Opens a document with custom configuration options.',
        onTap: () => applyCustomConfiguration(context),
      ),
      NutrientExampleItem(
        title: 'Opens and unlocks a password protected document',
        description: 'Programmatically unlocks a password protected document.',
        onTap: () => unlockPasswordProtectedDocument(context),
      ),
      NutrientExampleItem(
        title: 'Programmatic Form Filling Example',
        description:
            'Programmatically sets and gets the value of a form field using a custom Widget.',
        onTap: () => showFormDocumentExample(context),
      ),
      NutrientExampleItem(
        title: 'Programmatically Adds and Removes Annotations',
        description:
            'Programmatically adds and removes annotations using a custom Widget.',
        onTap: () => annotationsExample(context),
      ),
      NutrientExampleItem(
        title: 'Protected Annotations (Move Only)',
        description:
            'Demonstrates how to create protected annotations that can be moved but not edited or resized. Uses custom data to disable contextual menus while preserving movement functionality.',
        onTap: () => hideDeleteAnnotationExample(context),
      ),
      NutrientExampleItem(
        title: 'Annotation Flags Example',
        description: 'Shows how to click an annotation and modify its flags.',
        onTap: () => annotationFlagsExample(context),
      ),
      if (!kIsWeb)
        NutrientExampleItem(
          title: 'PDF generation',
          description:
              'Programmatically generate PDFs from images, templates, and HTML.',
          onTap: () => pdfGenerationExample(context),
        ),
      NutrientExampleItem(
        title: 'Manual Save',
        description:
            'Add a save button at the bottom and disable automatic saving.',
        onTap: () => manualSaveExample(context),
      ),
      if (PlatformUtils.isCupertino(context))
        NutrientExampleItem(
          title: 'Save As',
          description:
              'Embed and save the changes made to a document into a new file',
          onTap: () => saveAsExample(context),
        ),
      if (PlatformUtils.isCupertino(context) || PlatformUtils.isAndroid())
        NutrientExampleItem(
          title: 'Process Annotations',
          description:
              'Programmatically adds and removes annotations using a custom Widget.',
          onTap: () => annotationProcessingExample(context),
        ),
      NutrientExampleItem(
        title: 'Import Instant Document JSON',
        description:
            'Shows how to programmatically import Instant Document JSON using a custom Widget.',
        onTap: () => importInstantJsonExample(context),
      ),
      if (PlatformUtils.isCupertino(context))
        NutrientExampleItem(
          title: 'Shows two Nutrient Widgets simultaneously',
          description:
              'Opens two different PDF documents simultaneously using two Nutrient Widgets.',
          onTap: () => pushTwoPspdfWidgetsSimultaneously(context),
        ),
      NutrientExampleItem(
          title: 'Nutrient Events Listeners',
          description: 'Shows how to use Nutrient Events Listeners.',
          onTap: () async {
            await extractAsset(context, _documentPath).then((value) =>
                goTo(EventListenerExample(documentPath: value.path), context));
          }),
      if (kIsWeb)
        NutrientExampleItem(
            title: 'Nutrient Web Events Listeners',
            description: 'Shows how to use Nutrient Web Events Listeners.',
            onTap: () async {
              await extractAsset(context, _documentPath).then((value) => goTo(
                  WebEventListenersExample(documentPath: value.path), context));
            }),
      NutrientExampleItem(
          title: 'Measurement tools',
          description: 'Shows how to use Nutrient Measurement tools.',
          onTap: () async {
            await extractAsset(context, _measurementsDocs).then((value) =>
                goTo(MeasurementsExample(documentPath: value.path), context));
          }),
      if (!kIsWeb)
        NutrientExampleItem(
            title: 'Annotations Preset Customization',
            description: 'Nutrient Annotations Preset Customization Example.',
            onTap: () async {
              await extractAsset(context, _documentPath).then((value) => goTo(
                  AnnotationPresetCustomization(documentPath: value.path),
                  context));
            }),
      NutrientExampleItem(
          title: 'Toolbar Customization',
          description: 'Shows how to customize the toolbar items.',
          onTap: () async {
            await extractAsset(context, _documentPath).then((value) => goTo(
                ToolbarCustomization(
                  documentPath: value.path,
                ),
                context));
          }),
      if (!kIsWeb)
        NutrientExampleItem(
            title: 'Custom Toolbar Items',
            description: 'Shows how to add and handle custom toolbar items.',
            onTap: () async {
              await extractAsset(context, _documentPath).then((value) => goTo(
                  CustomToolbarExample(documentPath: value.path), context));
            }),
      if (kIsWeb)
        NutrientExampleItem(
          title: 'Instant collaboration Web',
          description: 'Instant Synchronization Web Example',
          onTap: () => goTo(const InstantCollaborationWeb(), context),
        ),
      NutrientExampleItem(
          title: 'Zoom to Rect',
          description: 'Zoom and restore page zoom example ',
          onTap: () async {
            await extractAsset(context, _documentPath).then((value) =>
                goTo(ZoomExample(documentPath: value.path), context));
          }),
      NutrientExampleItem(
          title: 'Annotation Creation Mode',
          description: 'Shows how to use annotation creation mode.',
          onTap: () async {
            await extractAsset(context, _documentPath).then((value) => goTo(
                AnnotationCreationModeExampleWidget(documentPath: value.path),
                context));
          }),
      NutrientExampleItem(
          title: 'AI Assistant',
          description: 'Shows how to use AI Assistant.',
          onTap: () async {
            await extractAsset(context, _documentPath).then((value) => goTo(
                NutrientAiAssistantExample(documentPath: value.path), context));
          })
    ];

List<NutrientExampleItem> globalExamples(BuildContext context) => [
      NutrientExampleItem(
        title: 'Basic Example',
        description: 'Opens a PDF Document.',
        onTap: () => showDocumentGlobal(context),
      ),
      NutrientExampleItem(
        title: 'Image Document',
        description: 'Opens an image document.',
        onTap: () => showImageGlobal(context),
      ),
      NutrientExampleItem(
        title: 'Dark Theme',
        description: 'Opens a document in night mode with a custom dark theme.',
        onTap: () => applyDarkThemeGlobal(context),
      ),
      NutrientExampleItem(
        title: 'Custom configuration options',
        description: 'Opens a document with custom configuration options.',
        onTap: () => applyCustomConfigurationGlobal(context),
      ),
      NutrientExampleItem(
        title: 'Opens and unlocks a password protected document',
        description: 'Programmatically unlocks a password protected document.',
        onTap: () => unlockPasswordProtectedDocumentGlobal(context),
      ),
      NutrientExampleItem(
        title: 'Programmatic Form Filling Example',
        description:
            'Programmatically sets and gets the value of a form field.',
        onTap: () => showFormDocumentExampleGlobal(context),
      ),
      NutrientExampleItem(
        title: 'Import Instant Document JSON',
        description:
            'Shows how to programmatically import Instant Document JSON.',
        onTap: () => importInstantJsonExampleGlobal(context),
      ),
      NutrientExampleItem(
        title: 'Nutrient Instant',
        description: 'Nutrient Instant Synchronization Example',
        onTap: () => presentInstant(context),
      ),
      NutrientExampleItem(
        title: 'Measurement tools',
        description: 'Shows how to use Nutrient Measurement tools.',
        onTap: () => showMeasurementExampleGlobal(context),
      ),
    ];

void showDocument(context) async {
  final extractedDocument = await extractAsset(context, _documentPath);
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) => BasicExample(documentPath: extractedDocument.path)));
}

void showImage(context) async {
  final extractedImage = await extractAsset(context, _imagePath);
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) => Scaffold(
          extendBodyBehindAppBar:
              PlatformUtils.isCupertino(context) ? false : true,
          appBar: AppBar(),
          body: SafeArea(
              top: false,
              bottom: false,
              child: Container(
                  padding: PlatformUtils.isCupertino(context)
                      ? null
                      : const EdgeInsets.only(top: kToolbarHeight),
                  child: NutrientView(documentPath: extractedImage.path))))));
}

void applyDarkTheme(context) async {
  final extractedDocument = await extractAsset(context, _documentPath);
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) => Scaffold(
          extendBodyBehindAppBar:
              PlatformUtils.isCupertino(context) ? false : true,
          appBar: AppBar(),
          body: SafeArea(
              top: false,
              bottom: false,
              child: Container(
                  padding: PlatformUtils.isCupertino(context)
                      ? null
                      : const EdgeInsets.only(top: kToolbarHeight),
                  child: NutrientView(
                      documentPath: extractedDocument.path,
                      configuration: PdfConfiguration(
                          appearanceMode: AppearanceMode.night,
                          androidDarkThemeResource:
                              'PSPDFKit.Theme.Example.Dark')))))));
}

void applyCustomConfiguration(context) async {
  final extractedDocument = await extractAsset(context, _documentPath);
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) =>
          ConfigurationExample(documentPath: extractedDocument.path)));
}

void unlockPasswordProtectedDocument(context) async {
  final extractedLockedDocument =
      await extractAsset(context, _lockedDocumentPath);
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) =>
          PasswordExample(documentPath: extractedLockedDocument.path)));
}

void showFormDocumentExample(context) async {
  final extractedFormDocument = await extractAsset(context, _formPath);
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) =>
          FormExampleWidget(documentPath: extractedFormDocument.path)));
}

void importInstantJsonExample(context) async {
  final extractedFormDocument = await extractAsset(context, _documentPath);
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) => InstantJsonExampleWidget(
            documentPath: extractedFormDocument.path,
            instantJsonPath: _instantDocumentJsonPath,
            xfaPath: _xfdfPath,
          )));
}

void annotationsExample(context) async {
  final extractedDocument = await extractAsset(context, _documentPath);
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) => PspdfkitAnnotationsExampleWidget(
          documentPath: extractedDocument.path)));
}

void pdfGenerationExample(context) async {
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) => const PDFGenerationExampleWidget()));
}

void manualSaveExample(context) async {
  final extractedWritableDocument = await extractAsset(context, _documentPath,
      shouldOverwrite: false, prefix: 'persist');

  // Automatic Saving of documents is enabled by default in certain scenarios [see for details: https://pspdfkit.com/guides/flutter/save-a-document/#auto-save]
  // In order to manually save documents, you might consider disabling automatic saving with disableAutosave: true in the config
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) => ManualSaveExampleWidget(
          documentPath: extractedWritableDocument.path,
          configuration: PdfConfiguration(disableAutosave: true))));
}

void saveAsExample(context) async {
  final extractedWritableDocument = await extractAsset(context, _documentPath,
      shouldOverwrite: false, prefix: 'persist');

  // Automatic Saving of documents is enabled by default in certain scenarios [see for details: https://pspdfkit.com/guides/flutter/save-a-document/#auto-save]
  // In order to manually save documents, you might consider disabling automatic saving with disableAutosave: true in the config
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) => SaveAsExampleWidget(
          documentPath: extractedWritableDocument.path,
          configuration: PdfConfiguration(disableAutosave: true))));
}

void annotationProcessingExample(context) async {
  final extractedDocument = await extractAsset(context, _documentPath);
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) => AnnotationProcessingExampleWidget(
          documentPath: extractedDocument.path,
          exportPath: _processedDocumentPath)));
}

void pushTwoPspdfWidgetsSimultaneously(context) async {
  try {
    final extractedDocument = await extractAsset(context, _documentPath);
    final extractedFormDocument = await extractAsset(context, _formPath);

    if (PlatformUtils.isCupertino(context)) {
      await Navigator.of(context).push<dynamic>(CupertinoPageRoute<dynamic>(
          builder: (_) => CupertinoPageScaffold(
              navigationBar: const CupertinoNavigationBar(),
              child: SafeArea(
                  bottom: false,
                  child: Column(children: <Widget>[
                    Expanded(
                        child:
                            NutrientView(documentPath: extractedDocument.path)),
                    Expanded(
                        child: NutrientView(
                            documentPath: extractedFormDocument.path))
                  ])))));
    } else {
      // This example is only supported in iOS at the moment.
      // Support for Android is coming soon.
    }
  } on PlatformException catch (e) {
    if (kDebugMode) {
      print("Failed to present document: '${e.message}'.");
    }
  }
}

void showDocumentGlobal(context) async {
  final extractedDocument = await extractAsset(context, _documentPath);
  await Nutrient.present(extractedDocument.path);
}

void showImageGlobal(context) async {
  final extractedImage = await extractAsset(context, _imagePath);
  await Nutrient.present(extractedImage.path);
}

void applyDarkThemeGlobal(context) async {
  final extractedDocument = await extractAsset(context, _documentPath);
  await Nutrient.present(extractedDocument.path,
      configuration: PdfConfiguration(
          appearanceMode: AppearanceMode.night,
          androidDarkThemeResource: 'PSPDFKit.Theme.Example.Dark'));
}

void applyCustomConfigurationGlobal(context) async {
  final extractedDocument = await extractAsset(context, _documentPath);
  await Nutrient.present(extractedDocument.path,
      configuration: PdfConfiguration(
          scrollDirection: ScrollDirection.vertical,
          pageTransition: PageTransition.scrollPerSpread,
          spreadFitting: SpreadFitting.fit,
          userInterfaceViewMode: UserInterfaceViewMode.always,
          androidShowSearchAction: true,
          inlineSearch: false,
          showThumbnailBar: ThumbnailBarMode.floating,
          androidShowThumbnailGridAction: true,
          androidShowOutlineAction: true,
          androidShowAnnotationListAction: true,
          showPageLabels: true,
          documentLabelEnabled: false,
          invertColors: false,
          androidGrayScale: false,
          startPage: 2,
          enableAnnotationEditing: true,
          enableTextSelection: false,
          androidShowBookmarksAction: false,
          androidEnableDocumentEditor: false,
          androidShowShareAction: true,
          androidShowPrintAction: false,
          androidShowDocumentInfoView: true,
          appearanceMode: AppearanceMode.defaultMode,
          androidDefaultThemeResource: 'PSPDFKit.Theme.Example',
          iOSRightBarButtonItems: [
            'thumbnailsButtonItem',
            'activityButtonItem',
            'searchButtonItem',
            'annotationButtonItem'
          ],
          iOSLeftBarButtonItems: ['settingsButtonItem'],
          iOSAllowToolbarTitleChange: false,
          toolbarTitle: 'Custom Title',
          settingsMenuItems: [
            'pageTransition',
            'scrollDirection',
            'androidTheme',
            'iOSAppearance',
            'androidPageLayout',
            'iOSPageMode',
            'iOSSpreadFitting',
            'androidScreenAwake',
            'iOSBrightness'
          ],
          showActionNavigationButtons: false,
          pageLayoutMode: PageLayoutMode.double,
          firstPageAlwaysSingle: true));
}

void unlockPasswordProtectedDocumentGlobal(context) async {
  final extractedLockedDocument =
      await extractAsset(context, _lockedDocumentPath);
  await Nutrient.present(extractedLockedDocument.path,
      configuration: PdfConfiguration(password: 'test123'));
}

void showFormDocumentExampleGlobal(context) async {
  final formDocument = await extractAsset(context, _formPath);
  await Nutrient.present(formDocument.path);

  try {
    await Nutrient.setFormFieldValue('Lastname', 'Name_Last');
    await Nutrient.setFormFieldValue('0123456789', 'Telephone_Home');
    await Nutrient.setFormFieldValue('City', 'City');
    await Nutrient.setFormFieldValue('selected', 'Sex.0');
    await Nutrient.setFormFieldValue('deselected', 'Sex.1');
    await Nutrient.setFormFieldValue('selected', 'HIGH SCHOOL DIPLOMA');
  } on PlatformException catch (e) {
    if (kDebugMode) {
      print("Failed to set form field values '${e.message}'.");
    }
  }

  String? lastName;
  try {
    lastName = await Nutrient.getFormFieldValue('Name_Last');
  } on PlatformException catch (e) {
    if (kDebugMode) {
      print("Failed to get form field value '${e.message}'.");
    }
  }

  if (lastName != null) {
    if (kDebugMode) {
      print(
          "Retrieved form field for fully qualified name 'Name_Last' is $lastName.");
    }
  }
}

void importInstantJsonExampleGlobal(context) async {
  final extractedDocument = await extractAsset(context, _documentPath);
  await Nutrient.present(extractedDocument.path);

  // Extract a string from a file.
  final annotationsJson =
      await DefaultAssetBundle.of(context).loadString(_instantDocumentJsonPath);

  try {
    await Nutrient.applyInstantJson(annotationsJson);
  } on PlatformException catch (e) {
    if (kDebugMode) {
      print("Failed to import Instant Document JSON '${e.message}'.");
    }
  }
}

void presentInstant(BuildContext context) async {
  await Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
          builder: (context) => const InstantCollaborationExample()));
}

void measurementExample(BuildContext context) async {
  await extractAsset(context, _measurementsDocs).then((value) {
    Navigator.push<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
            builder: (context) => MeasurementsExample(
                  documentPath: value.path,
                )));
  });
}

void showMeasurementExampleGlobal(BuildContext context) {
  var scale = MeasurementScale(
      unitFrom: UnitFrom.inch,
      valueFrom: 1.0,
      unitTo: UnitTo.cm,
      valueTo: 2.54);
  var precision = MeasurementPrecision.fourDP;
  var measurementValueConfigurations = [
    MeasurementValueConfiguration(
        name: 'Custom Scale', scale: scale, precision: precision)
  ];
  extractAsset(context, _measurementsDocs).then((value) {
    Nutrient.present(
      value.path,
      configuration: PdfConfiguration(
        measurementValueConfigurations: measurementValueConfigurations,
      ),
    );
  });
}

void goTo(Widget widget, BuildContext context) {
  Navigator.push<dynamic>(
      context, MaterialPageRoute<dynamic>(builder: (context) => widget));
}

void annotationFlagsExample(BuildContext context) {
  goTo(
    const AnnotationFlagsExample(),
    context,
  );
}

void hideDeleteAnnotationExample(BuildContext context) async {
  final extractedDocument = await extractAsset(context, _documentPath);
  await Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
      builder: (_) => HideDeleteAnnotationExampleWidget(
          documentPath: extractedDocument.path)));
}
