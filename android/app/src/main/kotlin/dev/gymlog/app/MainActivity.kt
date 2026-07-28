package dev.gymlog.app

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache

/**
 * Uses the engine [MainApplication] pre-warmed at process start instead of
 * creating a fresh one here (Stage 10, TS 11.6 cold-start profiling,
 * owner-approved 2026-07-28) -- see that class's doc comment for why.
 * [shouldDestroyEngineWithHost] keeps that single engine alive for the
 * process's lifetime (matching [FlutterEngineCache]'s single long-lived
 * entry) instead of destroying it whenever this activity is destroyed,
 * which would leave a stale, unusable engine behind in the cache for the
 * next time the activity is recreated within the same process.
 */
class MainActivity : FlutterActivity() {
    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return FlutterEngineCache.getInstance().get(MainApplication.ENGINE_ID)
            ?: super.provideFlutterEngine(context)
    }

    override fun shouldDestroyEngineWithHost(): Boolean = false
}
