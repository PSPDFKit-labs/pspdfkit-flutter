/*
 * Copyright © 2018-2024 PSPDFKit GmbH. All rights reserved.
 * <p>
 * THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 * AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 * UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 * This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit

///  Copyright © 2021-2024 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///
import android.os.Bundle
import android.view.View
import android.widget.Toast
import com.pspdfkit.document.PdfDocument
import com.pspdfkit.ui.PdfUiFragment
import com.pspdfkit.ui.toolbar.AnnotationEditingToolbar
import com.pspdfkit.ui.toolbar.ContextualToolbar
import com.pspdfkit.ui.toolbar.ContextualToolbarMenuItem
import com.pspdfkit.ui.toolbar.ToolbarCoordinatorLayout

class FlutterPdfUiFragment : PdfUiFragment(),  ToolbarCoordinatorLayout.OnContextualToolbarLifecycleListener {

    private lateinit var customTextSelectionAction: ContextualToolbarMenuItem
    private val id = View.generateViewId()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Create a custom menu item that will be shown inside the text selection toolbar.
        customTextSelectionAction = ContextualToolbarMenuItem.createSingleTextItem(
            requireContext(),
            id,
            ContextualToolbarMenuItem.Position.END
        )
    }

    override fun onDocumentLoaded(document: PdfDocument) {
        super.onDocumentLoaded(document)
      // Notify the Flutter PSPDFKit plugin that the document has been loaded.
        EventDispatcher.getInstance().notifyDocumentLoaded(document)
    }

    override fun onPrepareContextualToolbar(toolbar: ContextualToolbar<*>) {
        if (toolbar is AnnotationEditingToolbar) {
            val menuItems = toolbar.getMenuItems()
            if (!menuItems.contains(customTextSelectionAction)) {
                menuItems.add(customTextSelectionAction)
                toolbar.setMenuItems(menuItems)
            }
        }
    }

    override fun onDisplayContextualToolbar(toolbar: ContextualToolbar<*>) {
        toolbar.setOnMenuItemClickListener { _, menuItem ->
            var handled = false
            if (menuItem.id == id) {
                handled = true
                Toast.makeText(
                    requireContext(), "Custom action triggered!", Toast.LENGTH_SHORT
                ).show()
            }
            handled
        }
    }

    override fun onRemoveContextualToolbar(toolbar: ContextualToolbar<*>) {
        toolbar.setOnMenuItemClickListener(null)
    }
}