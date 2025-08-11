package com.iqonic.streamit_flutter
import android.app.Application

class App : Application() {

    override fun onCreate() {
        super.onCreate()

        app = this
    }

    companion object {
        private lateinit var app: App

        fun getAppInstance(): App {
            return app
        }
    }
}