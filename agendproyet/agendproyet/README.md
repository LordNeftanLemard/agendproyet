# Agendproyet

App de hábitos en Flutter: avatar por capas, alarmas recurrentes L-D y notificaciones locales con imagen temática + frase motivacional.

## Arranque
```bash
flutter create . --project-name agendproyet --org com.agendproyet   # genera android/ e ios/ sin tocar lib/
flutter pub get
flutter run
```

## Assets
**Ilustraciones de notificación** (ya incluidas, 5 imágenes de ejemplo):
- `assets/notifications/full/<nombre>.jpg` — versión vertical completa (pantalla al pulsar la notificación; adjunto en iOS).
- `assets/notifications/banner/<nombre>.jpg` — recorte 2:1 (1024x512) para la notificación expandida de Android.
- Se registran en `lib/data/motivational_content.dart` (`_images`). Cada imagen puede limitarse a ciertos tonos de piel del avatar (`skins`); así `fitness_1` (piel clara/trigueña) y `fitness_2` (piel oscura) se eligen según el avatar.
- Los temas `study` y `health` aún no tienen ilustración y salen solo con texto.

**Capas del avatar** (opcionales; sin ellas se usan dibujos vectoriales):
- `assets/avatar/skin/skin_0..4.png` — piel a color, PNG transparente, mismo lienzo.
- `assets/avatar/hair/hair_1..4.png` y `assets/avatar/beard/beard_1..3.png` — siluetas **blancas** (se tiñen con el color elegido).

## Android (`android/app/build.gradle` o `.kts`)
```gradle
android {
    compileOptions {
        coreLibraryDesugaringEnabled true
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
    defaultConfig { minSdkVersion 21 }
}
dependencies {
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'
}
```

## Android (`android/app/src/main/AndroidManifest.xml`)
Dentro de `<manifest>`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```
Dentro de `<application>`:
```xml
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>
```

## iOS (`ios/Runner/AppDelegate.swift`)
En `application(_:didFinishLaunchingWithOptions:)`, antes del `return`:
```swift
if #available(iOS 10.0, *) {
  UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
}
```

## Notas de diseño
- Las alarmas se guardan con `shared_preferences`; cada día de cada alarma es una notificación semanal (`id*10 + día`).
- El contenido de una notificación programada es fijo; por eso `AlarmsProvider.load()` reprograma todo al abrir la app y así rota la frase.
- Versiones de `flutter_local_notifications` (^18) y `flutter_timezone` (^3) fijadas a propósito: su API cambia entre versiones mayores.
