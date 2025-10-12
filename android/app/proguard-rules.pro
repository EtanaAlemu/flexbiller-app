# Flutter specific ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep Google Play Core classes
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Keep specific missing classes
-keep class com.google.android.play.core.splitcompat.SplitCompatApplication { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallException { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallManager { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallManagerFactory { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallRequest { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallRequest$Builder { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallSessionState { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener { *; }
-keep class com.google.android.play.core.tasks.OnFailureListener { *; }
-keep class com.google.android.play.core.tasks.OnSuccessListener { *; }
-keep class com.google.android.play.core.tasks.Task { *; }

# Ignore missing classes warnings
-dontwarn com.google.android.play.core.**

# Keep SQLCipher classes
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.** { *; }

# Keep JWT decoder classes
-keep class com.auth0.jwt.** { *; }

# Keep model classes
-keep class * extends java.lang.Enum { *; }
-keep class * implements java.io.Serializable { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Flutter engine classes
-keep class io.flutter.embedding.** { *; }

# Keep Syncfusion classes
-keep class com.syncfusion.** { *; }

# Keep Dio/HTTP classes
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }

# Keep Gson classes
-keep class com.google.gson.** { *; }

# Keep Biometric classes
-keep class androidx.biometric.** { *; }

# Keep Permission Handler classes
-keep class com.baseflow.permissionhandler.** { *; }

# Keep File Picker classes
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# Keep Share Plus classes
-keep class dev.fluttercommunity.plus.share.** { *; }

# Keep Open File classes
-keep class com.crazecoder.openfile.** { *; }

# Keep Excel classes
-keep class com.pdftron.pdf.** { *; }

# Keep Local Auth classes
-keep class io.flutter.plugins.localauth.** { *; }

# Keep Secure Storage classes
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Keep Shared Preferences classes
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Keep Path Provider classes
-keep class io.flutter.plugins.pathprovider.** { *; }

# Keep Connectivity classes
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# Keep Country State City Picker classes
-keep class com.example.country_state_city_picker.** { *; }

# Keep Currency Picker classes
-keep class com.example.currency_picker.** { *; }

# Keep Dropdown Search classes
-keep class com.example.dropdown_search.** { *; }

# Keep Crashlytics classes
-keep class com.google.firebase.crashlytics.** { *; }

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Optimization settings
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-dontpreverify

# Keep generic signature of Call, Response (R8 full mode strips signatures from non-kept items).
-keep,allowshrinking,allowoptimization interface retrofit2.Call
-keep,allowshrinking,allowoptimization class retrofit2.Response

# With R8 full mode generic signatures are stripped for classes that are not
# kept. Suspend functions are wrapped in continuations where the type argument
# is used.
-keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation
