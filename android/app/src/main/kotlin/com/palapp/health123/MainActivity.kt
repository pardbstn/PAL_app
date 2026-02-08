package com.palapp.health123

import android.os.Bundle
import android.util.Base64
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import java.security.MessageDigest

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        printSigningInfo()
    }

    private fun printSigningInfo() {
        try {
            val packageInfo = packageManager.getPackageInfo(
                packageName,
                android.content.pm.PackageManager.GET_SIGNING_CERTIFICATES
            )
            val signatures = packageInfo.signingInfo?.apkContentsSigners
            signatures?.forEach { signature ->
                // SHA-256 (네이버용)
                val sha256Digest = MessageDigest.getInstance("SHA-256")
                val sha256Bytes = sha256Digest.digest(signature.toByteArray())
                val sha256Hex = sha256Bytes.joinToString(":") { "%02X".format(it) }

                // Key Hash (카카오용) - SHA1 + Base64
                val sha1Digest = MessageDigest.getInstance("SHA")
                val sha1Bytes = sha1Digest.digest(signature.toByteArray())
                val keyHash = Base64.encodeToString(sha1Bytes, Base64.NO_WRAP)

                Log.d("SIGNING", "================================================")
                Log.d("SIGNING", "")
                Log.d("SIGNING", "▶ 네이버 개발자 콘솔에 등록할 SHA-256:")
                Log.d("SIGNING", sha256Hex)
                Log.d("SIGNING", "")
                Log.d("SIGNING", "▶ 카카오 개발자 콘솔에 등록할 키 해시:")
                Log.d("SIGNING", keyHash)
                Log.d("SIGNING", "")
                Log.d("SIGNING", "================================================")
            }
        } catch (e: Exception) {
            Log.e("SIGNING", "Error: ${e.message}")
        }
    }
}
