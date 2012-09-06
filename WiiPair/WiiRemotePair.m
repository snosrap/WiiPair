//
//  WiiRemotePair.m
//  WiiPair
//
//  Created by Ford Parsons on 9/5/12.
//  Copyright (c) 2012 Ford Parsons. All rights reserved.
//

#import "WiiRemotePair.h"

@implementation WiiRemotePair

- (void)listenForConnection
{
    NSLog(@"Listening...");
    [IOBluetoothDevice registerForConnectNotifications:self selector:@selector(connected:fromDevice:)];
}

- (void)attemptPair
{
    IOBluetoothDeviceInquiry *inquiry = [IOBluetoothDeviceInquiry inquiryWithDelegate:self];
    [inquiry setInquiryLength:20];
    [inquiry setSearchCriteria:kBluetoothServiceClassMajorAny majorDeviceClass:kBluetoothDeviceClassMajorPeripheral minorDeviceClass:kBluetoothDeviceClassMinorPeripheral2Joystick];
    [inquiry setUpdateNewDeviceNames:NO];
    IOReturn result = [inquiry start];

    NSLogIOReturn(result);
}

#pragma mark -
#pragma mark IOBluetoothUserNotification

- (void)connected:(IOBluetoothUserNotification *)note fromDevice:(IOBluetoothDevice *)device
{
    if(device.isWiimote && device.isPaired) {
        NSLog(@"Connected %@", device.name);
        [device registerForDisconnectNotification:self selector:@selector(disconnected:fromDevice:)];
    }
}

- (void)disconnected:(IOBluetoothUserNotification *)note fromDevice:(IOBluetoothDevice *)device
{
    if(device.isWiimote && device.isPaired) {
        NSLog(@"Disconnected %@", device.name);
        [note unregister];
    }
}

#pragma mark -
#pragma mark IOBluetoothDeviceInquiry

- (void)deviceInquiryStarted:(IOBluetoothDeviceInquiry*)sender
{
    NSLog(@"Searching...");
}

- (void)deviceInquiryDeviceFound:(IOBluetoothDeviceInquiry *)sender device:(IOBluetoothDevice *)device
{
    [sender stop];
}

- (void)deviceInquiryComplete:(IOBluetoothDeviceInquiry *)sender error:(IOReturn)error aborted:(BOOL)aborted
{
    if(error != kIOReturnSuccess && !aborted) {
        NSLogIOReturn(error);
        return;
    }
    
    for(IOBluetoothDevice *device in [sender foundDevices])
    {
        NSLog(@"Found %@", device.name);
        IOBluetoothDevicePair *pair = [IOBluetoothDevicePair pairWithDevice:device];
        [pair setDelegate:self];
        [pair start];
    }
    
    [sender clearFoundDevices];
    
    [sender start];
}

#pragma mark -
#pragma mark IOBluetoothDevicePair

- (void)devicePairingPINCodeRequest:(id)sender {
    
    BluetoothDeviceAddress addr;
    BluetoothPINCode pin;
    
    // TODO: There must be a more elegant way to obtain the host's BluetoothDeviceAddress
    if(IOBluetoothNSStringToDeviceAddress([[IOBluetoothHostController defaultController] addressAsString], &addr) != kIOReturnSuccess)
        return;
    
    // PIN is Bluetooth Host MAC backwards -- MAC=00:01:02:03:04:05 -> PIN=05:04:03:02:01:00
    for(int i=0;i<6;i++)
        pin.data[5-i] = addr.data[i];
    
    // Send PIN to device
    [sender replyPINCode:6 PINCode:&pin];
}

- (void)devicePairingFinished:(id)sender error:(IOReturn)error {
    
    if(error != kIOReturnSuccess) {
        NSLogIOReturn(error);
        return;
    }
    
    NSLog(@"Paired %@", [sender device].name);
}

@end

@implementation IOBluetoothDevice (WiimoteAdditions)

- (BOOL)isWiimote {
    return self.deviceClassMajor == kBluetoothDeviceClassMajorPeripheral &&
        self.deviceClassMinor == kBluetoothDeviceClassMinorPeripheral2Joystick &&
        [self.name hasPrefix:@"Nintendo"];
}

+ (NSArray *)pairedWiimotes {
    NSMutableArray *a = [NSMutableArray array];
    
    for(IOBluetoothDevice *d in [IOBluetoothDevice pairedDevices])
        if([d isWiimote])
            [a addObject:d];
    
    return [NSArray arrayWithArray:a];
}

@end