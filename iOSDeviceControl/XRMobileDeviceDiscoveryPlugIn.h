//
//  PrivateAPIHeader.h
//  iOSDeviceControl
//
//  Created by CorbinChen on 2017/4/2.
//  Copyright © 2017年 CorbinChen. All rights reserved.
//

#ifndef PrivateAPIHeader_h
#define PrivateAPIHeader_h

#import <objc/runtime.h>

@interface XRDeviceDiscovery : NSObject

+ (id)devicesMatching:(id)arg1;
+ (id)deviceForIdentifier:(id)arg1;
+ (id)allKnownDevices;
+ (id)availableDevices;
+ (void)unregisterForDeviceNotifications:(unsigned int)arg1;
+ (void)forgetDevice:(id)arg1;
+ (void)deviceStateChanged:(id)arg1;
+ (void)deviceConnected:(id)arg1;
+ (void)_systemDidWake:(id)arg1;
+ (void)_systemWillSleep:(id)arg1;
+ (void)initialize;
+ (id)deviceDiscoveryImplementations;
+ (void)_faultDeviceDiscoveryImpls;
+ (void)registerDeviceObserver:(id)arg1;
- (void)stopListeningForDevices;
- (void)startListeningForDevices;
- (id)deviceList;
- (id)deviceManagementItems;

@end

@interface XRMobileDeviceLocator : XRDeviceDiscovery

@end

@interface PFTProcess : NSObject

@property(readonly) NSString *executablePath;
@property(readonly) NSString *bundleIdentifier;
@property(copy) NSString *argumentsString;

- (id)initWithDevice:(id)arg1 path:(id)arg2 bundleIdentifier:(id)arg3 arguments:(id)arg4 environment:(id)arg5 launchOptions:(id)arg6;
- (void)addEnvironmentVariable:(id)arg1 value:(id)arg2;

@end

@interface XRDevice : NSObject

- (id)initWithIdentifier:(NSString *)identifier;
- (id)makeConnection;
- (void)disconnect;
- (id)runningProcesses;
- (BOOL)isOnLine;
- (void)activateProcess:(id)arg1;
- (int)launchProcess:(id)arg1 suspended:(BOOL)arg2 error:(id *)arg3;
- (void)terminateProcess:(id)arg1;
- (BOOL)resumeProcess:(id)arg1;

- (NSString *)deviceDisplayName;
- (NSString *)deviceIdentifier;

@property(readonly) NSArray *unrestrictedAppExtensions;
@property(readonly) NSArray *unrestrictedExecutables;
@property(readonly) NSArray *installedExecutables;

@end

@interface XRMobileDevice : XRDevice

@end

#define CBGetClass(classname) objc_getClass(#classname)

#endif /* PrivateAPIHeader_h */
