package com.example.ssma

import android.net.wifi.WifiManager
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    companion object {
        private const val TAG = "SSMA_MULTICAST"
        private const val LOCK_TAG = "ssma_mdns_lock"
    }

    private var multicastLock: WifiManager.MulticastLock? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        acquireMulticastLock()
    }

    override fun onDestroy() {
        releaseMulticastLock()
        super.onDestroy()
    }

    private fun acquireMulticastLock() {
        try {
            val wifi = applicationContext.getSystemService(WIFI_SERVICE) as WifiManager?
            if (wifi == null) {
                Log.e(TAG, "WifiManager is null — cannot acquire MulticastLock")
                return
            }
            multicastLock = wifi.createMulticastLock(LOCK_TAG).also { lock ->
                lock.setReferenceCounted(true)
                lock.acquire()
                Log.i(TAG, "MulticastLock ACQUIRED — tag=$LOCK_TAG isHeld=${lock.isHeld}")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to acquire MulticastLock: ${e.message}", e)
        }
    }

    private fun releaseMulticastLock() {
        try {
            multicastLock?.let { lock ->
                if (lock.isHeld) {
                    lock.release()
                    Log.i(TAG, "MulticastLock RELEASED — tag=$LOCK_TAG")
                } else {
                    Log.w(TAG, "MulticastLock not held at release time")
                }
            } ?: Log.w(TAG, "MulticastLock was null at release time")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to release MulticastLock: ${e.message}", e)
        } finally {
            multicastLock = null
        }
    }
}