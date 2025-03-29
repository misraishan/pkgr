# Necessary MacOS Profiles
There are two certificates that are required to sign your app for the Mac App Store, and one profile that is required to sign the app and the installer for the Mac App Store. 

## Requirements
- A Mac with XCode installed
- A valid Apple Developer Account
- A valid Application Identifier (bundle ID)

## Developer ID Application
- Used to digitally identify the app by allowing MacOS' "Gatekeeper" to verify the developer and confirm that the app is safe to run. This is a pre-requisite for the notarization process when submitting to the Mac App Store.
1. Go to [Apple Developer Portal](https://developer.apple.com/account/resources/certificates/list)
2. Hit the "+" button on the top left (make sure you're in the "Certificates" tab)
3. Click on "Mac App Distribution"
4. Follow the instructions to create a Certificate Signing Request (CSR) using Keychain Access.
5. Hit continue and upload the CSR.
6. Download the certificate and double-click it to install it in your keychain.
7. You can verify that this certificate is installed by checking your keychain and looking for the certificate.


## Developer ID Installer
- Used specifically to sign the `.pkg` installer file, ensuring that it has not been tampered with. Also a pre-requisite for the notarization process.
1. Follow the same steps above until you get to the "Mac App Distribution" step, where you'll select "Mac Installer Distribution" instead.
2. Follow the remaining steps to generate the certificate.

To verify both of these have been installed correctly, you can run the following command in your terminal:
```shell
security find-identity -v -p macappstore
```
You should see at least two certificates along the lines of:
```shell
1. "hash_code" "3rd Party Mac Developer Installer: Your Name (Your Team ID)"
2. "hash_code" "3rd Party Mac Developer Application: Your Name (Your Team ID)"
```
---

## Provisioning Profile
- The provisioning profile acts as the bridge between your developer account and the app/bundle ID. It verifies the specific entitlements and the permissions your app has, It's what grants your application the permissions it needs to be able to run, and helps Apple identify and verify the app and it's entitlements.
1. Go to [Apple Developer Portal](https://developer.apple.com/account/resources/profiles/list)
2. Go to the profiles tab and hit the "+" button on the top left.
3. Select "Mac App Store Connect".
4. Select the app you want to sign (you should have already created an app in the Developer Portal).
5. Select the option along the lines of "Your Name (Distribution)For use in Xcode 11 or later"
6. Name it however you'd like (e.g. "app-name-distribution")
7. Download the profile.

You will be pointing at this provisioning profile whenever signing the app, however, you should NOT commit this to git.
