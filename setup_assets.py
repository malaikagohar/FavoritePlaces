from PIL import Image
import os
import shutil
import subprocess
import re

# Define the input icon image path, project directory, background color for your splash screen and the new label for your app
image_name = "favorite_places.png"
project_directory = "F:/Applications/favorite_places"
background_color = "#ffffff"
new_app_label = "Favorite Places"

# Update AndroidManifest.xml for Android
android_manifest_path = "android/app/src/main/AndroidManifest.xml"
try:
    with open(android_manifest_path, 'r') as android_manifest_file:
        android_manifest_data = android_manifest_file.read()
        # Use regular expression to find and replace the app label
        android_manifest_data = re.sub(
            r'(android:label=")[^"]*"', r'\1' + new_app_label + '"', android_manifest_data)

        if 'android.permission.INTERNET' not in android_manifest_data:
            android_manifest_data = android_manifest_data.replace(
                '    <application',
                '    <uses-permission android:name="android.permission.INTERNET" />\n    <application'
            )

    with open(android_manifest_path, 'w') as android_manifest_file:
        android_manifest_file.write(android_manifest_data)
    print("App label updated successfully in AndroidManifest.xml")
except FileNotFoundError:
    print("AndroidManifest.xml not found.")

# Update Info.plist for iOS
ios_info_plist_path = "ios/Runner/Info.plist"
try:
    with open(ios_info_plist_path, 'r') as ios_info_plist_file:
        ios_info_plist_data = ios_info_plist_file.read()
        # Use regular expression to find and replace the CFBundleName value
        ios_info_plist_data = re.sub(
            r'(<key>CFBundleName<\/key>\s*<string>)[^<]*(<\/string>)', r'\1' + new_app_label + r'\2', ios_info_plist_data)
    with open(ios_info_plist_path, 'w') as ios_info_plist_file:
        ios_info_plist_file.write(ios_info_plist_data)
    print("App label updated successfully in Info.plist for iOS")
except FileNotFoundError:
    print("Info.plist not found.")

# Define the output directory for different densities
output_directory = os.path.join(project_directory, "android/app/src/main/res")

# Define the sizes for different densities (in pixels)
sizes = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192
}

# Open the input icon image
input_image = Image.open(image_name)

# Loop through different densities and resize the image
for density, size in sizes.items():
    # Create the output directory if it doesn't exist
    output_path = os.path.join(output_directory, f"mipmap-{density}")
    os.makedirs(output_path, exist_ok=True)

    # Resize the image and save it as ic_launcher.png
    output_image = input_image.resize((size, size), Image.LANCZOS)
    output_image.save(os.path.join(output_path, "ic_launcher.png"))

print("Icon images resized and saved.")

# Create a directory for assets if it doesn't exist
assets_directory = os.path.join(project_directory, "assets")
if not os.path.exists(assets_directory):
    os.makedirs(assets_directory)

# Copy the splash image to the assets directory
shutil.copy(image_name, assets_directory)

# Create and write the splash screen configuration YAML file
splash_config = f"""\
flutter_native_splash:
  image: assets/{image_name}
  color: "{background_color}"
  android_gravity: "center"
  ios_content_mode: "scaleAspectFill"
"""

with open(os.path.join(project_directory, "flutter_native_splash.yaml"), "w") as config_file:
    config_file.write(splash_config)

# Run the Flutter command to generate the splash screen
subprocess.run(["flutter.bat", "pub", "add", "flutter_native_splash"],
               cwd=project_directory, stdout=subprocess.DEVNULL)
subprocess.run(["flutter.bat", "pub", "get"],
               cwd=project_directory, stdout=subprocess.DEVNULL)
subprocess.run(["dart.bat", "run", "flutter_native_splash:create"],
               cwd=project_directory, stdout=subprocess.DEVNULL)

print("Splash screen setup completed!")

# Create empty directories in the lib folder
lib_directory = os.path.join(project_directory, "lib")
directories_to_create = ["screens", "widgets", "providers", "models", "data"]

for directory_name in directories_to_create:
    directory_path = os.path.join(lib_directory, directory_name)
    os.makedirs(directory_path, exist_ok=True)

print("Empty directories created in the lib folder to help you organize your project.")
