# iOSDeviceControl

A Mac OS X Command Line Tool for managing and manipulating iOS Devices.

## Requirements
- Mac OS X. Tested on 10.12.1, 10.12.3 and iOS 10.1.1, 10.2
- Xcode. Tested on 8.2, 8.3

## Features
- List connecting iOS device list.
- List installed applications on iOS device.
- List running applications on iOS device.
- Run application on iOS device.

## Usage
```
Usage: iOSDeviceControl [option]...
  -l, --list                        list device list
  -I, --list_installed_application  list installed application on device
  -R, --list_running_application    list running application on device
  -i, --id <device_id>              the id of the device to connect to
  -r, --run <app_name>              run application
  -v, --version                     print the executable version
```

## Examples
```
// list device list
iOSDeviceControl -l

// list installed application on device
iOSDeviceControl -I -i device_id

// list running application on device
iOSDeviceControl -R -i device_id

// run application
iOSDeviceControl -r AppStore -i device_id

// print the executable version
iOSDeviceControl -v

```