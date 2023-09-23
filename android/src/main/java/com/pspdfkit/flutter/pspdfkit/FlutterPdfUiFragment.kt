package com.pspdfkit.flutter.pspdfkit

import android.os.Bundle
import android.view.View
import com.pspdfkit.annotations.measurements.FloatPrecision
import com.pspdfkit.annotations.measurements.Scale
import com.pspdfkit.document.PdfDocument
import com.pspdfkit.ui.PdfUiFragment
import com.pspdfkit.ui.toolbar.AnnotationCreationToolbar
import com.pspdfkit.ui.toolbar.ContextualToolbar
import com.pspdfkit.ui.toolbar.ToolbarCoordinatorLayout
import java.util.EnumSet

class FlutterPdfUiFragment : PdfUiFragment(),
    ToolbarCoordinatorLayout.OnContextualToolbarLifecycleListener {

    private var scale: Scale? = null
    private var precision: FloatPrecision? = null

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setOnContextualToolbarLifecycleListener(this)
    }

    override fun onDocumentLoaded(document: PdfDocument) {
        super.onDocumentLoaded(document)
      // Notify the Flutter PSPDFKit plugin that the document has been loaded.
        EventDispatcher.getInstance().notifyDocumentLoaded(document)
        // We can register interest in newly created annotations so we can easily pick up measurement information.
        if (scale != null) {
            document.measurementScale = scale
        }
        if (precision != null) {
            document.measurementPrecision = precision
        }
    }

    fun setMeasurementScale(scale: Scale?) {
        this.scale = scale
    }

    fun setMeasurementPrecision(precision: FloatPrecision?) {
        this.precision = precision
    }

    override fun onPrepareContextualToolbar(toolbar: ContextualToolbar<*>) {
        if (toolbar is AnnotationCreationToolbar) {
            toolbar.setMenuItemGroupingRule(CustomAnnotationToolbarMenu(requireContext()))
            toolbar.layoutParams = ToolbarCoordinatorLayout.LayoutParams(
                ToolbarCoordinatorLayout.LayoutParams.Position.TOP, EnumSet.of(ToolbarCoordinatorLayout.LayoutParams.Position.TOP)
            )
        }
    }

    override fun onDisplayContextualToolbar(p0: ContextualToolbar<*>) {
    }

    override fun onRemoveContextualToolbar(p0: ContextualToolbar<*>) {
    }

}