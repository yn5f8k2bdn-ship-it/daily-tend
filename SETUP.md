# Wellness Works — Developer Setup

One-time setup to get the project building locally on Windows.

## 1. Install Flutter SDK

1. Download the latest stable Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\flutter` (or another path without spaces).
3. Add `C:\flutter\bin` to your user PATH.
4. Open a **new** terminal and run:
   ```
   flutter doctor
   ```
5. Resolve any `[x]` items `flutter doctor` flags. The ones that matter for this project:
   - Flutter SDK present
   - Android toolchain (you already have Android SDK installed)
   - Android Studio OR VS Code (either is fine)
   - Chrome (only needed if you ever want Flutter web; skip if not)

## 2. Upgrade to Java 17

Modern Flutter + Android Gradle Plugin require JDK 17. You currently have JDK 8.

1. Install Adoptium Temurin 17: https://adoptium.net/temurin/releases/?version=17
   - Pick **Windows x64 JDK .msi installer**.
2. During install, tick "Set JAVA_HOME" and "Add to PATH".
3. Verify in a new terminal:
   ```
   java -version
   ```
   You should see `17.x.x`.
4. Tell Flutter to use it (one-time):
   ```
   flutter config --jdk-dir "C:\Program Files\Eclipse Adoptium\jdk-17.0.x-hotspot"
   ```
   (Adjust the path to your actual install.)

## 3. Supabase account + project

1. Sign up at https://supabase.com (free tier is fine for V1).
2. **Create a new project.**
   - **Name:** anything (e.g. `wellness-works-dev`).
   - **Database password:** generate and save to a password manager.
   - **Region:** pick the closest to your users. Recommended: `ap-southeast-2 (Sydney)` if AU-focused, `eu-west-2 (London)` if UK/EU, `us-east-1 (N. Virginia)` if US.
3. Once created, open **Project Settings → API** and copy:
   - Project URL (looks like `https://xxxxxxxx.supabase.co`)
   - `anon` public key
   - `service_role` secret key (keep this secret — it's only used server-side)
4. Open **Project Settings → Database → Extensions** and enable `pg_cron` (needed for the nightly summariser).

## 4. OpenAI API key

1. Create account at https://platform.openai.com
2. Add billing (API usage is pay-as-you-go — with caching, expect <$5/month in early testing).
3. Create an API key at https://platform.openai.com/api-keys. Save it somewhere secure.

## 5. Supabase CLI (optional but recommended)

Lets you push migrations and deploy Edge Functions from the command line.

```
npm install -g supabase
```

Then log in:
```
supabase login
```

## 6. Local `.env` setup (will be created later)

Do not commit `.env` files. We'll set up a `.env.example` when the Flutter project is scaffolded. For now, keep these values ready:

- `SUPABASE_URL` — from step 3
- `SUPABASE_ANON_KEY` — from step 3
- `OPENAI_API_KEY` — from step 4 (set only as an Edge Function secret, never in the app)
- `OPENAI_MODEL` — default `gpt-4.1-mini`

## 7. Android emulator

You already have this. To confirm:
```
flutter emulators
flutter emulators --launch <emulator_id>
```

## Checklist before running the app

- [ ] `flutter doctor` shows no blocking issues
- [ ] `java -version` shows 17.x
- [ ] Supabase project created, URL + keys noted
- [ ] OpenAI API key created
- [ ] Android emulator runs or a physical device is connected (`adb devices`)
