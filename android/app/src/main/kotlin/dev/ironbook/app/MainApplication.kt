package dev.ironbook.app

import android.app.Application
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugins.GeneratedPluginRegistrant

/**
 * Pre-warms a [FlutterEngine] as soon as the process starts (Stage 10, TS
 * 11.6 cold-start profiling, owner-approved 2026-07-28): by default
 * `FlutterActivity` creates and initializes its engine synchronously inside
 * `Activity.onCreate()`, serializing engine bootstrap (native library load,
 * Dart VM + isolate snapshot init, our Dart `main()`) *after* the OS has
 * already finished setting up the window. `Application.onCreate()` runs
 * earlier in the process's lifecycle, so starting the engine here lets that
 * bootstrap overlap with the OS's own window/activity setup instead of
 * waiting for it. [MainActivity] retrieves this pre-warmed engine from
 * [FlutterEngineCache] instead of creating a fresh one.
 *
 * If engine creation fails for any reason, the cache is simply left empty
 * and [MainActivity] falls back to its normal (unwarmed) engine-creation
 * path -- pre-warming is a startup-latency optimization, not something the
 * app depends on to function.
 */
class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        try {
            val flutterEngine = FlutterEngine(this)
            flutterEngine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )
            GeneratedPluginRegistrant.registerWith(flutterEngine)
            FlutterEngineCache.getInstance().put(ENGINE_ID, flutterEngine)
        } catch (_: Exception) {
            // Fall back to MainActivity's own engine creation (see class doc).
        }
    }

    companion object {
        const val ENGINE_ID = "main_engine"
    }
}
