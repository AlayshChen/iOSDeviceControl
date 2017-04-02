//
//  main.m
//  iOSDeviceControl
//
//  Created by CorbinChen on 2017/4/2.
//  Copyright © 2017年 CorbinChen. All rights reserved.
//

#include <getopt.h>
#import <Foundation/Foundation.h>
#import "XRMobileDeviceDiscoveryPlugIn.h"

XRMobileDeviceLocator *deviceLocator;

#pragma mark - Function Declaration

void nslog(NSString* format, ...);
void usage(const char* app);
void show_version();
void load_framework();
void start_listening_devices();
void stop_listening_devices();
XRMobileDevice *get_device(const char *device_id);
void list_device();
void list_installed_application(const char *device_id);
void list_running_application(const char *device_id);
void run_applicaion(const char *device_id, const char *app_name);

#pragma mark - Function Definition

void nslog(NSString* format, ...) {
    va_list valist;
    va_start(valist, format);
    NSString* str = [[NSString alloc] initWithFormat:format arguments:valist];
    va_end(valist);
    printf("%s\n", str.UTF8String);
}

void usage(const char* app) {
    nslog(
          @"Usage: %@ [option]...\n"
          @"  -l, --list                        list device list\n"
          @"  -I, --list_installed_application  list installed application on device\n"
          @"  -R, --list_running_application    list running application on device\n"
          @"  -i, --id <device_id>              the id of the device to connect to\n"
          @"  -r, --run <app_name>              run application\n"
          @"  -v, --version                     print the executable version\n",
          [NSString stringWithUTF8String:app]);
}

void show_version() {
    nslog(@"%@", @
#include "version.h"
             );
}

void load_framework() {
    [[NSBundle bundleWithPath:@"/Applications/Xcode.app/Contents/Applications/Instruments.app/Contents/PlugIns/XRMobileDeviceDiscoveryPlugIn.xrplugin"] load];
}

void start_listening_devices() {
    deviceLocator = [[CBGetClass(XRMobileDeviceLocator) alloc] init];
    [CBGetClass(XRDeviceDiscovery) _faultDeviceDiscoveryImpls];
    [deviceLocator startListeningForDevices];
}

void stop_listening_devices() {
    [deviceLocator stopListeningForDevices];
}

XRMobileDevice *get_device(const char *device_id) {
    XRMobileDevice *res = nil;
    if (device_id != NULL) {
        NSString *device_id_string = [NSString stringWithCString:device_id encoding:NSUTF8StringEncoding];
        NSArray<XRMobileDevice *> *devices = [deviceLocator deviceList];
        for (XRMobileDevice *device in devices) {
            if ([device.deviceIdentifier isEqualToString:device_id_string]) {
                res = device;
                break;
            }
        }
    }
    if (res == nil) {
        nslog(@"Error: unable to get device with id %s", device_id);
    }
    else {
        nslog(@"%@", res);
    }
    return res;
}

void list_device() {
    NSArray<XRMobileDevice *> *devices = [deviceLocator deviceList];
    nslog(@"%@", devices);
}

void list_installed_application(const char *device_id) {
    XRMobileDevice *device = get_device(device_id);
    if (device) {
        [device makeConnection];
        NSArray *installed_applications = [device installedExecutables];
        for (PFTProcess *process in installed_applications) {
            NSString *executablePath = process.executablePath;
            nslog(@"%@", executablePath.lastPathComponent);
        }
        [device disconnect];
    }
}

void list_running_application(const char *device_id) {
    XRMobileDevice *device = get_device(device_id);
    if (device) {
        [device makeConnection];
        NSArray *running_applications = [device runningProcesses];
        for (PFTProcess *process in running_applications) {
            NSString *executablePath = process.executablePath;
            if ([executablePath containsString:@".app/"]) {
                nslog(@"%@", executablePath.lastPathComponent);
            }
        }
        [device disconnect];
    }
}

void run_applicaion(const char *device_id, const char *app_name) {
    XRMobileDevice *device = get_device(device_id);
    if (app_name == NULL) {
        nslog(@"Error: app_name is NULL");
    }
    if (device) {
        [device makeConnection];
        NSArray *installed_applications = [device installedExecutables];
        PFTProcess *app_executable;
        NSString *app_bundle = [NSString stringWithFormat:@"%s.app", app_name];
        for (PFTProcess *process in installed_applications) {
            NSString *executablePath = process.executablePath;
            if ([executablePath hasSuffix:app_bundle]) {
                app_executable = process;
                break;
            }
        }
        if (app_executable) {
            [device launchProcess:app_executable suspended:false error:nil];
        }
        else {
            nslog(@"Error: can not find app with name: %s", app_name);
        }
        [device disconnect];
    }
}

int main(int argc, char * argv[]) {
    @autoreleasepool {
        char *device_id = NULL;
        char *app_name = NULL;
        
        static struct option longopts[] = {
            { "list", no_argument, NULL, 'l' },
            { "list_installed_application", no_argument, NULL, 'I' },
            { "list_running_application", no_argument, NULL, 'R' },
            { "id", required_argument, NULL, 'i' },
            { "run", required_argument, NULL, 'r' },
            { "version", no_argument, NULL, 'v' },
            { NULL, 0, NULL, 0 },
        };
        char ch;
        BOOL is_list_command = false;
        BOOL is_list_installed_application_command = false;
        BOOL is_list_running_application_command = false;
        BOOL is_run_application_command = false;
        
        while ((ch = getopt_long(argc, argv, "lIRvi:r:", longopts, NULL)) != -1)
        {
            switch (ch) {
                case 'l':
                    is_list_command = true;
                    break;
                case 'I':
                    is_list_installed_application_command = true;
                    break;
                case 'R':
                    is_list_running_application_command = true;
                    break;
                case 'i':
                    device_id = optarg;
                    break;
                case 'r':
                    is_run_application_command = true;
                    app_name = optarg;
                    break;
                case 'v':
                    show_version();
                    return 0;
                default:
                    usage(argv[0]);
                    return 1;
            }
        }
        
        load_framework();
        start_listening_devices();
        
        if (is_list_command) {
            list_device();
        }
        else if (is_list_installed_application_command) {
            list_installed_application(device_id);
        }
        else if (is_list_running_application_command) {
            list_running_application(device_id);
        }
        else if (is_run_application_command) {
            run_applicaion(device_id, app_name);
        }
        else {
            usage(argv[0]);
        }
        
        stop_listening_devices();
    }
    return 0;
}
