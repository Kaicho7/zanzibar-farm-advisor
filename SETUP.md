# Zanzibar Farm AI — Setup Guide

## What You Need
- Flutter SDK installed (3.0+)
- Android Studio or VS Code with Flutter plugin
- Your model files:
  - `zanzibar_plant_vM.tflite`
  - `zanzibar_plant_vM_labels.json`

---

## Step 1 — Copy Your Model Files Into the Project

Copy both files into the `assets/` folder of this project:

```
zanzibar_farm_advisor/
  assets/
    zanzibar_plant_vM.tflite       ← copy here
    zanzibar_plant_vM_labels.json  ← copy here
    advisor_data.json              ← already included
```

---

## Step 2 — Check Your Labels File Format

The app supports two JSON formats for labels.

**Format A — Array (preferred):**
```json
["Tomato___Early_blight", "Tomato___healthy", "Cassava_Mosaic", ...]
```

**Format B — Object with index keys:**
```json
{"0": "Tomato___Early_blight", "1": "Tomato___healthy", ...}
```

Both work automatically. No changes needed.

---

## Step 3 — Install Dependencies

Open a terminal in the project folder:

```bash
flutter pub get
```

---

## Step 4 — Connect Your Android Phone

1. Enable **Developer Options** on your phone:
   - Settings → About Phone → tap "Build Number" 7 times
2. Enable **USB Debugging**
3. Connect phone via USB
4. Accept the debugging prompt on your phone

Verify connection:
```bash
flutter devices
```
You should see your phone listed.

---

## Step 5 — Run the App

```bash
flutter run
```

For a release build (faster, smaller):
```bash
flutter build apk --release
```
The APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## Step 6 — Install APK on Phone (if built offline)

```bash
flutter install
```
Or copy the APK to your phone and open it.

---

## Project File Structure

```
lib/
  main.dart                    ← Entry point
  app.dart                     ← App root + splash screen
  models/
    prediction.dart            ← Prediction data class
    advice.dart                ← Advice + LocalizedText models
  services/
    tflite_service.dart        ← TFLite model loading + inference
    advisor_service.dart       ← Disease advice lookup
    app_state.dart             ← App-wide state (ChangeNotifier)
  screens/
    home_screen.dart           ← Main screen with scan button
    result_screen.dart         ← Disease result + full advice
    settings_screen.dart       ← Language toggle + model info
  widgets/
    image_source_sheet.dart    ← Camera / Gallery / Files picker
    confidence_bar.dart        ← Animated confidence indicator
    advice_section.dart        ← Advice cards + remedies list
  utils/
    app_theme.dart             ← All colours, theme, severity styles
    constants.dart             ← Model paths, thresholds

assets/
  zanzibar_plant_vM.tflite         ← AI model (copy here)
  zanzibar_plant_vM_labels.json    ← Class labels (copy here)
  advisor_data.json                ← Disease advice EN+SW database
```

---

## Features

| Feature | Detail |
|---|---|
| Disease detection | TFLite inference on-device, no internet needed |
| Languages | English + Kiswahili, toggle in Settings |
| Image sources | Camera, Gallery, Google Drive, Files |
| Advice | Symptoms, Treatment, Prevention, Market Impact |
| Remedies | Organic + Chemical options per disease |
| Diseases covered | 18 detailed diseases in advisor database |
| Confidence scores | Top-3 predictions with animated bars |

---

## Troubleshooting

### "Model not found" error
- Make sure `zanzibar_plant_vM.tflite` is in the `assets/` folder
- Make sure `pubspec.yaml` lists it under `flutter: assets:`
- Run `flutter clean && flutter pub get`

### App crashes on launch
- Check your phone is Android 5.0+ (API 21+)
- Check `flutter doctor` for any issues

### Low confidence scores
- Use well-lit photos showing the disease clearly
- Fill the frame with the affected leaf/plant part
- Avoid blurry or heavily shadowed images

### Labels show as "Unknown_X"
- Check your `zanzibar_plant_vM_labels.json` file format (see Step 2)
- Make sure the number of labels matches your model output classes

---

## Adding More Diseases to the Advisor Database

Edit `assets/advisor_data.json`. Each disease entry looks like:

```json
{
  "key": "Early_blight",
  "name": {"en": "Early Blight", "sw": "Madoa ya Mapema"},
  "severity": "medium",
  "symptoms":    {"en": "...", "sw": "..."},
  "treatment":   {"en": "...", "sw": "..."},
  "prevention":  {"en": "...", "sw": "..."},
  "market_impact": {"en": "...", "sw": "..."},
  "organic_remedies": ["...", "..."],
  "chemical_options": ["...", "..."]
}
```

The `key` field is matched against your model label names (case-insensitive, partial match). For example, key `"Early_blight"` will match labels like `"Tomato___Early_blight"` or `"Potato___Early_Blight"`.

---

## Contact
MANREC Zanzibar: +255 24 223 1951
