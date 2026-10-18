package com.ahmedelmansy.taqs

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class TaqsWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.taqs_widget_4x2).apply {
                val temperature = widgetData.getString("taqs_widget_temperature", "--°") ?: "--°"
                val cityName = widgetData.getString("taqs_widget_city_name", "طقس مصر") ?: "طقس مصر"
                val condition = widgetData.getString("taqs_widget_condition", "") ?: ""
                val nextPrayer = widgetData.getString("taqs_widget_next_prayer", "") ?: ""
                val updatedTime = widgetData.getString("taqs_widget_updated_time", "") ?: ""

                setTextViewText(R.id.widget_temperature, temperature)
                setTextViewText(R.id.widget_city_name, cityName)
                setTextViewText(R.id.widget_condition, condition)
                setTextViewText(R.id.widget_next_prayer, nextPrayer)
                setTextViewText(R.id.widget_updated_time, updatedTime)

                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
