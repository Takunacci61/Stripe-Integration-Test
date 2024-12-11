# Keep Stripe classes for Push Provisioning
-keep class com.stripe.android.** { *; }
-keep class com.reactnativestripesdk.** { *; }
-keep class com.facebook.react.** { *; }
-dontwarn com.stripe.android.**
-dontwarn com.reactnativestripesdk.**
-dontwarn com.facebook.react.**

# Keep annotations
-keepattributes *Annotation*
