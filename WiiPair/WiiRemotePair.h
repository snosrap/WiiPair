//
//  WiiRemotePair.h
//  WiiPair
//
//  Created by Ford Parsons on 9/5/12.
//  Copyright (c) 2012 Ford Parsons. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>

#ifndef NSLogDebug
#if DEBUG
#	define NSLogIOReturn(result) if (result != kIOReturnSuccess) { printf ("IOReturn error (%s [%d]): system 0x%x, sub 0x%x, error 0x%x\n", __FILE__, __LINE__, err_get_system (result), err_get_sub (result), err_get_code (result)); }
#else
#	define NSLogIOReturn(result)
#endif
#endif

@interface WiiRemotePair : NSObject
- (void)listenForConnection;
- (void)attemptPair;
@end

@interface IOBluetoothDevice (WiimoteAdditions)
- (BOOL)isWiimote;
+ (NSArray *)pairedWiimotes;
@end