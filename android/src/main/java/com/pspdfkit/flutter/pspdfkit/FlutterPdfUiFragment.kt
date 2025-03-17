/*
 * Copyright © 2018-2025 PSPDFKit GmbH. All rights reserved.
 * <p>
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit

///  Copyright © 2021-2025 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
import android.os.Bundle
import android.view.View
import com.pspdfkit.annotations.AnnotationType
import com.pspdfkit.annotations.configuration.StampAnnotationConfiguration
import com.pspdfkit.annotations.stamps.StampPickerItem
import com.pspdfkit.document.PdfDocument
import com.pspdfkit.ui.PdfUiFragment

class FlutterPdfUiFragment : PdfUiFragment() {

    override fun onDocumentLoaded(document: PdfDocument) {
        super.onDocumentLoaded(document)
      // Notify the Flutter PSPDFKit plugin that the document has been loaded.
        EventDispatcher.getInstance().notifyDocumentLoaded(document)
        val items = listOf(
            StampPickerItem.fromTitle(requireContext(), "Great!").build(),
            StampPickerItem.fromTitle(requireContext(), "Stamp!").build(),
            StampPickerItem.fromTitle(requireContext(), "Like").build()
        )
        // Available stamps can be configured through the `PdfFragment`.
        requirePdfFragment().annotationConfiguration.put(
            AnnotationType.STAMP,
            StampAnnotationConfiguration.builder(requireContext())
                // Here you set the list of stamp picker items that are going to be available in the stamp picker.
                .setAvailableStampPickerItems(items)
                .build()
        )
    }
}