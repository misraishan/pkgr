# How to package your Flutter app for the Mac App Store
A brief and non-exhaustive guide to packaging your Flutter app for the Mac App Store. A lot of this is just half-baked research/notes, so some things may be incorrect or unnecessary, but it *does* get the job done.

## Step 1: Copy your provision profile to the app
- Apps require a provision profile to be signed and released to the Mac App Store.
- This can be done manually by copying the `Runner.provisionprofile` file to the `Runner.app` bundle, as shown below:
```bash
cp macos/Runner.provisionprofile build/macos/Build/Products/Release/Runner.app/Contents/embedded.provisionprofile
```
> [!IMPORTANT]
> `embedded.provisionprofile` is the required name for the provision profile.

## Step 2: Sign the app
- While Flutter signs the app, 
```bash
codesign --deep --force --sign "3rd Party Mac Developer Application: Your Name (Your Team ID)"
```
- `deep` ensures that all files in the app are signed.
- `force` ensures that the app is signed even if it has already been signed.
- `sign` is the identity of the Apple Developer account to sign the app with.
> [!IMPORTANT]
> The Developer ID Application identity is required to sign the app for the Mac App Store.

## Step 3: Sign the app with the entitlements
- Apps require entitlements to be signed.
- This can be done manually by signing the entitlements using the `codesign` command.
```bash
codesign --force --deep --sign "3rd Party Mac Developer Application: Your Name (Your Team ID)" --entitlements macos/Runner/Release.entitlements --options runtime --prefix com.yourcompany.yourappname yourappname.app/
```
- `deep` ensures that all files in the app are signed.
- `force` ensures that the app is signed even if it has already been signed.
- `sign` is the identity of the Apple Developer account to sign the app with.
- `prefix` is the bundle identifier of the app.

## Step 4: Create a pkg
- This can be done manually by creating a pkg using the `productbuild` command.
```bash
productbuild --component yourappname.app /Applications --sign "3rd Party Mac Developer Installer: Your Name (Your Team ID)" yourappname.pkg
```
- `component` is the path to the app bundle.
- `sign` is the identity of the Apple Developer account to sign the pkg with.
- `prefix` is the bundle identifier of the app.

## Step 5: Submit the app to the Mac App Store
- This can be done manually by submitting the app to the Mac App Store using the `altool` command OR through Transporter.