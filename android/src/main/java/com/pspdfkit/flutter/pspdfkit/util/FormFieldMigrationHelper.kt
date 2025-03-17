/*
 *   Copyright © 2025 PSPDFKit GmbH. All rights reserved.
 *
 *   THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
 *   AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
 *   UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
 *   This notice may not be removed from this file.
 */

package com.pspdfkit.flutter.pspdfkit.util

import com.pspdfkit.annotations.actions.AnnotationTriggerEvent
import com.pspdfkit.annotations.actions.JavaScriptAction
import com.pspdfkit.document.PdfDocument
import com.pspdfkit.forms.FormElement
import com.pspdfkit.forms.FormType
import com.pspdfkit.forms.TextInputFormat

object FormFieldMigrationHelper {
    @JvmStatic
    fun migrateFieldFormatActions(document: PdfDocument): Boolean {
        var changed = false
        document.formProvider.formElements.forEach { element ->
            if (element.type == FormType.TEXT) {
                changed = migrateFieldFormatActions(element) or changed
            }
        }
        return changed
    }

    private fun migrateFieldFormatActions(element: FormElement): Boolean {
        if (element.getInputFormat() in listOf(TextInputFormat.DATE, TextInputFormat.TIME)) return false

        element.getJavaScriptActionForEvent(AnnotationTriggerEvent.FIELD_FORMAT)?.let { action ->
            if (action.startsWith("AFTime") || action.startsWith("AFDate")) {
                action.replace("_Format", "_Keystroke").also { fixedFormat ->
                    element.annotation.setAdditionalAction(AnnotationTriggerEvent.FORM_CHANGED, JavaScriptAction(fixedFormat))
                    return true
                }
            }
        }
        return false
    }

    private fun FormElement.getInputFormat(): TextInputFormat {
        val formatString = getJavaScriptActionForEvent(AnnotationTriggerEvent.FORM_CHANGED)
            ?: return TextInputFormat.NORMAL

        return when {
            formatString.startsWith("AFDate_Keystroke")
                -> TextInputFormat.DATE
            formatString.startsWith("AFTime_Keystroke")
                -> TextInputFormat.TIME
            else -> TextInputFormat.NORMAL
        }
    }

    private fun FormElement.getJavaScriptActionForEvent(event: AnnotationTriggerEvent): String? =
        (annotation.getAdditionalAction(event) as? JavaScriptAction
            ?: formField.getAdditionalAction(event) as? JavaScriptAction)?.script
}