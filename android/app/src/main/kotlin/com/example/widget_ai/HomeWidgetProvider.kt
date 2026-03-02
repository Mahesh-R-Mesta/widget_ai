package com.example.widget_ai

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File

class HomeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // Get data from SharedPreferences (synced by home_widget)
                val title = widgetData.getString("app_name", "Widget AI")
                val iconPath = widgetData.getString("icon_path", null)
                val projectId = widgetData.getInt("project_id", -1)

                setTextViewText(R.id.widget_title, title)

                if (iconPath != null) {
                    val file = File(iconPath)
                    if (file.exists()) {
                        val bitmap = BitmapFactory.decodeFile(file.absolutePath)
                        setImageViewBitmap(R.id.widget_image, bitmap)
                    }
                }

                // Create intent to launch app with specific project URI
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("widgetai://project?id=$projectId")
                )
                setOnClickPendingIntent(R.id.widget_image, pendingIntent)
                setOnClickPendingIntent(R.id.widget_title, pendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
