# FlutterFire CLI Setup Guide

The error you encountered:
```
flutterfire : The term 'flutterfire' is not recognized ...
```
means the FlutterFire CLI is not installed or not in your system PATH.

## Step‑by‑step installation (Windows PowerShell)
1. **Activate the CLI via Dart Pub**
   ```powershell
   dart pub global activate flutterfire_cli
   ```
   This downloads the `flutterfire` binary to the global pub cache.

2. **Add the Pub cache to your PATH**
   The binary lives in:
   ```
   %USERPROFILE%\AppData\Roaming\Pub\Cache\bin
   ```
   Add this directory to the `PATH` environment variable:
   - Open **System Properties** → **Advanced** → **Environment Variables**.
   - Under *User variables*, edit `Path` and add a new entry with the path above.
   - Click **OK** to save.

3. **Restart the terminal**
   Close the current PowerShell window and open a new one so the updated `PATH` is loaded.

4. **Verify the installation**
   ```powershell
   flutterfire --version
   ```
   You should see the version number printed.

5. **Run the configure command**
   ```powershell
   flutterfire configure --project=yanafssi
   ```
   Follow the prompts to select the Firebase services you want to enable.

## Common pitfalls
- Ensure you have **Dart SDK** installed (it comes with Flutter). Run `dart --version` to check.
- If you get a permission error, run PowerShell as **Administrator** when adding the PATH entry.
- After adding the PATH, you can also run `refreshenv` (from Chocolatey) or simply restart Windows.

---
*This file was generated to help you set up the FlutterFire CLI and resolve the `CommandNotFoundException`.*
