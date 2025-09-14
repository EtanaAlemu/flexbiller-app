# Android 15 External Storage Implementation

This document explains the external storage implementation for FlexBiller app with Android 15 (API 35) compliance.

## Overview

The external storage functionality allows users to export CSV and Excel files to external storage (like Downloads folder) with proper permission handling across different Android versions.

## Android Version Compatibility

### Android 15 (API 35) & Android 14 (API 34) & Android 13 (API 33+)

- Uses **Media Permissions** (`READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_MEDIA_AUDIO`)
- Falls back to `MANAGE_EXTERNAL_STORAGE` if media permissions are not sufficient
- Most secure and recommended approach

### Android 12 (API 31) & Android 11 (API 30)

- Uses `MANAGE_EXTERNAL_STORAGE` permission
- Requires user to grant "All files access" permission in settings

### Android 10 (API 29) & Below

- Uses traditional `READ_EXTERNAL_STORAGE` and `WRITE_EXTERNAL_STORAGE` permissions
- Simpler permission model

## Permissions Required

### Android Manifest Permissions

```xml
<!-- For Android 13+ (API 33+) - Media permissions -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />

<!-- For Android 11+ (API 30+) - Manage external storage -->
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"
    tools:ignore="ScopedStorage" />

<!-- For Android 10+ (API 29+) - Traditional storage -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

<!-- Legacy permissions for older versions -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
```

## Implementation Details

### Permission Strategy

The app uses a tiered permission strategy:

1. **Android 13+**: Request media permissions first, fallback to manage external storage
2. **Android 11-12**: Request manage external storage permission
3. **Android 10 and below**: Request traditional storage permissions

### Key Methods

#### `_requestStoragePermission()`

Main entry point for permission requests. Automatically detects Android version and uses appropriate strategy.

#### `_requestMediaPermissions()`

Requests media permissions for Android 13+. These are more granular and user-friendly.

#### `_requestManageExternalStorage()`

Requests the "All files access" permission. Requires user to manually enable in settings.

#### `_requestTraditionalStoragePermissions()`

Requests traditional storage permissions for older Android versions.

## Usage Examples

### Smart CSV Export (External Storage with Fallback)

```dart
final exportService = getIt<ExportService>();

try {
  // This method automatically tries external storage first,
  // then falls back to internal storage if external fails
  final filePath = await exportService.exportAccountsToCSV(accounts);
  print('File saved to: $filePath');
} catch (e) {
  print('Export failed: $e');
}
```

### Smart Excel Export (External Storage with Fallback)

```dart
try {
  // This method automatically tries external storage first,
  // then falls back to internal storage if external fails
  final filePath = await exportService.exportAccountsToExcel(accounts);
  print('Excel file saved to: $filePath');
} catch (e) {
  print('Excel export failed: $e');
}
```

### How It Works

1. **First Attempt**: Tries to export to external storage with proper permissions
2. **User Choice**: If permissions granted, user can choose save location via file picker
3. **Fallback**: If external storage fails (permission denied, user cancelled, etc.), automatically falls back to internal app storage
4. **Seamless**: User doesn't need to know about the complexity - it just works!

## User Experience

### Permission Flow

1. User taps export button
2. App requests appropriate permissions based on Android version
3. If permissions granted, file picker opens
4. User selects save location
5. File is saved with UTF-8 encoding

### Error Handling

- **Permission denied**: Clear error message explaining why export failed
- **User cancelled**: Graceful handling when user cancels file picker
- **File write error**: Detailed error message for debugging

## Testing on Different Android Versions

### Android 15 (API 35)

- Test with media permissions
- Verify fallback to manage external storage
- Test file picker functionality

### Android 13-14 (API 33-34)

- Test media permissions
- Verify proper permission requests

### Android 11-12 (API 30-31)

- Test manage external storage permission
- Verify "All files access" settings integration

### Android 10 and below (API 29-)

- Test traditional storage permissions
- Verify backward compatibility

## Troubleshooting

### Common Issues

1. **Permission Denied on Android 11+**

   - User needs to manually enable "All files access" in settings
   - Guide user to: Settings > Apps > FlexBiller > Permissions > All files access

2. **File Picker Not Opening**

   - Check if permissions are granted
   - Verify file picker package is properly configured

3. **Files Not Saving**
   - Check if target directory is writable
   - Verify UTF-8 encoding is working correctly

### Debug Information

```dart
// Check permission status
final status = await Permission.manageExternalStorage.status;
print('Manage external storage: $status');

// Check media permissions
final photosStatus = await Permission.photos.status;
print('Photos permission: $photosStatus');
```

## Security Considerations

1. **Minimal Permissions**: Only request necessary permissions
2. **User Control**: Always allow user to choose save location
3. **Data Privacy**: No data is sent to external servers
4. **File Validation**: Validate file paths and content before saving

## Future Improvements

1. **Device Info Detection**: Use `device_info_plus` for accurate Android version detection
2. **Permission Rationale**: Show explanation dialogs for permission requests
3. **Batch Operations**: Support for exporting multiple file types at once
4. **Cloud Storage**: Integration with Google Drive, Dropbox, etc.

## Dependencies

- `permission_handler: ^11.3.1` - Permission management
- `file_picker: ^8.0.0+1` - File picker functionality
- `path_provider: ^2.1.1` - Path utilities
- `excel: ^4.0.6` - Excel file generation

## References

- [Android 15 Storage Changes](https://developer.android.com/about/versions/15/behavior-changes-15)
- [Scoped Storage Guide](https://developer.android.com/training/data-storage)
- [Permission Handler Documentation](https://pub.dev/packages/permission_handler)
- [File Picker Documentation](https://pub.dev/packages/file_picker)
