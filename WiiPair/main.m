//
//  main.m
//  WiiPair
//
//  Created by Ford Parsons on 9/6/12.
//  Copyright (c) 2012 Ford Parsons. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WiiRemotePair.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool
    {
        WiiRemotePair *remote = [[WiiRemotePair alloc] init];
        
        // Listen for paired devices (any of the buttons on the Wiimote, or the power button on the BalanceBoard)
        [remote listenForConnection];
        
        // Attempt to pair with new device (SYNC button must be pressed on device)
        [remote attemptPair];

        // Wait for the pairing to complete
        while ([[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
    }
    return 0;
}

