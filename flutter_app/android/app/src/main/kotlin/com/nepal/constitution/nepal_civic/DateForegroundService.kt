package com.nepal.constitution.nepal_civic

import android.app.*
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import java.util.Calendar
import java.util.Timer
import java.util.TimerTask

class DateForegroundService : Service() {

    companion object {
        const val CHANNEL_ID = "nepali_date_channel"
        const val NOTIFICATION_ID = 1001
        const val ACTION_START = "com.nepal.constitution.nepal_civic.START_DATE_SERVICE"
        const val ACTION_STOP = "com.nepal.constitution.nepal_civic.STOP_DATE_SERVICE"

        // Nepali month names
        private val nepaliMonths = arrayOf(
            "बैशाख", "जेठ", "असार", "श्रावण", "भदौ", "असोज",
            "कार्तिक", "मंसिर", "पुष", "माघ", "फागुन", "चैत"
        )

        // Nepali weekday names
        private val nepaliWeekdays = arrayOf(
            "आइतबार", "सोमबार", "मंगलबार", "बुधबार", "बिहीबार", "शुक्रबार", "शनिबार"
        )

        // English weekday names
        private val englishWeekdays = arrayOf(
            "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
        )

        // English month names
        private val englishMonths = arrayOf(
            "Jan", "Feb", "Mar", "Apr", "May", "Jun",
            "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
        )

        // BS month days for years 2070-2090
        private val bsMonthDays = mapOf(
            2070 to intArrayOf(31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30),
            2071 to intArrayOf(31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30),
            2072 to intArrayOf(31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31),
            2073 to intArrayOf(31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30),
            2074 to intArrayOf(31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30),
            2075 to intArrayOf(31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31),
            2076 to intArrayOf(31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30),
            2077 to intArrayOf(31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30),
            2078 to intArrayOf(31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31),
            2079 to intArrayOf(31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30),
            2080 to intArrayOf(31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30),
            2081 to intArrayOf(31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31),
            2082 to intArrayOf(31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30),
            2083 to intArrayOf(31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30),
            2084 to intArrayOf(31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31),
            2085 to intArrayOf(31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30),
            2086 to intArrayOf(31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30),
            2087 to intArrayOf(31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31),
            2088 to intArrayOf(31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30),
            2089 to intArrayOf(31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30),
            2090 to intArrayOf(31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31)
        )

        // Reference date: 2014-04-13 AD = 2071-01-01 BS
        private const val refAdYear = 2014
        private const val refAdMonth = 4
        private const val refAdDay = 13
        private const val refBsYear = 2071
        private const val refBsMonth = 1
        private const val refBsDay = 1

        data class BsDate(val year: Int, val month: Int, val day: Int)

        fun adToBs(year: Int, month: Int, day: Int): BsDate {
            val totalDays = daysSinceReference(year, month, day)

            var bsYear = refBsYear
            var bsMonth = refBsMonth
            var bsDay = refBsDay + totalDays

            if (totalDays >= 0) {
                while (true) {
                    val monthDays = getMonthDays(bsYear, bsMonth)
                    if (bsDay <= monthDays) break
                    bsDay -= monthDays
                    bsMonth++
                    if (bsMonth > 12) {
                        bsMonth = 1
                        bsYear++
                    }
                }
            } else {
                bsDay = refBsDay + totalDays
                while (bsDay < 1) {
                    bsMonth--
                    if (bsMonth < 1) {
                        bsMonth = 12
                        bsYear--
                    }
                    bsDay += getMonthDays(bsYear, bsMonth)
                }
            }

            return BsDate(bsYear, bsMonth, bsDay)
        }

        private fun getMonthDays(year: Int, month: Int): Int {
            val monthDays = bsMonthDays[year]
            return if (monthDays != null) {
                monthDays[month - 1]
            } else {
                intArrayOf(31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30)[month - 1]
            }
        }

        private fun daysSinceReference(year: Int, month: Int, day: Int): Int {
            val cal1 = Calendar.getInstance().apply {
                set(Calendar.YEAR, year)
                set(Calendar.MONTH, month - 1)
                set(Calendar.DAY_OF_MONTH, day)
                set(Calendar.HOUR_OF_DAY, 12)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }
            val cal2 = Calendar.getInstance().apply {
                set(Calendar.YEAR, refAdYear)
                set(Calendar.MONTH, refAdMonth - 1)
                set(Calendar.DAY_OF_MONTH, refAdDay)
                set(Calendar.HOUR_OF_DAY, 12)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }
            val diff = cal1.timeInMillis - cal2.timeInMillis
            return (diff / (1000L * 60 * 60 * 24)).toInt()
        }

        // Convert digit to Nepali
        fun toNepaliDigits(number: Int): String {
            val nepaliDigits = arrayOf("०", "१", "२", "३", "४", "५", "६", "७", "८", "९")
            return number.toString().map { nepaliDigits[it - '0'] }.joinToString("")
        }
    }

    private var midnightTimer: Timer? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
                return START_NOT_STICKY
            }
            else -> {
                startForeground(NOTIFICATION_ID, createNotification())
                scheduleMidnightUpdate()
                return START_STICKY
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        midnightTimer?.cancel()
        midnightTimer = null
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Nepali Date",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows today's Nepali date"
                setShowBadge(false)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }

            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val cal = Calendar.getInstance()
        val year = cal.get(Calendar.YEAR)
        val month = cal.get(Calendar.MONTH)
        val day = cal.get(Calendar.DAY_OF_MONTH)
        val weekday = cal.get(Calendar.DAY_OF_WEEK) - 1

        val bsDate = adToBs(year, month + 1, day)

        val nepaliDate = "${toNepaliDigits(bsDate.year)} ${nepaliMonths[bsDate.month - 1]} ${toNepaliDigits(bsDate.day)}"
        val nepaliWeekday = nepaliWeekdays[weekday]
        val englishDate = "${englishMonths[month]} $day, $year (${englishWeekdays[weekday]})"

        // Intent to open the calendar screen
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("nepalcivic://tools/nepali-calendar"))
        intent.setPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("$nepaliDate • $nepaliWeekday")
            .setContentText(englishDate)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setOngoing(true)
            .setAutoCancel(false)
            .setShowWhen(false)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setContentIntent(pendingIntent)
            .build()
    }

    private fun scheduleMidnightUpdate() {
        midnightTimer?.cancel()
        midnightTimer = Timer()

        // Calculate time until midnight
        val now = Calendar.getInstance()
        val midnight = Calendar.getInstance().apply {
            add(Calendar.DAY_OF_YEAR, 1)
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 5) // 5 seconds after midnight
            set(Calendar.MILLISECOND, 0)
        }

        val delay = midnight.timeInMillis - now.timeInMillis

        midnightTimer?.schedule(object : TimerTask() {
            override fun run() {
                // Update notification with new date
                val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                notificationManager.notify(NOTIFICATION_ID, createNotification())

                // Schedule next update
                scheduleMidnightUpdate()
            }
        }, delay)
    }
}
