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
            // Get the project ID associated with this specific widget instance
            var projectId = widgetData.getInt("widget_${appWidgetId}_id", -1)
            
            // If this is a new widget, associate it with the last project the user pinned
            if (projectId == -1) {
                projectId = widgetData.getInt("last_pinned_project_id", -1)
                // Persist the association
                if (projectId != -1) {
                    widgetData.edit().putInt("widget_${appWidgetId}_id", projectId).apply()
                }
            }

            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // Get data for this specific project
                val title = widgetData.getString("project_name_$projectId", "Widget AI")
                val iconPath = widgetData.getString("project_icon_$projectId", null)

                setTextViewText(R.id.widget_title, title)

                if (iconPath != null) {
                    val file = File(iconPath)
                    if (file.exists()) {
                        val bitmap = BitmapFactory.decodeFile(file.absolutePath)
                        setImageViewBitmap(R.id.widget_image, bitmap)
                    }
                } else {
                    // Fallback to default icon if no path provided
                    setImageViewResource(R.id.widget_image, R.mipmap.ic_launcher)
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
