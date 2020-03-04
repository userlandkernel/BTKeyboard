//
//  myPair_it.m
//  keyboard
//
//  Created by Sem Voigtländer on 04/03/20.
//  Copyright © 2020 kernelprogrammer. All rights reserved.
//

#import "myPair_it.h"

@implementation myPair_it

- (myPair_it*)initWithWindow:(NSWindow*)window {
    return [super initWithWindow:window];
}

- (void)set_mother:(id)Mother {
    self->mother = Mother;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    self->bingo_state = -1;
    [self->bingo setStringValue:@""];
    self->listofpairs = [[NSMutableArray alloc] init];
    [self load_pairs];
    self->mytimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(my_timer) userInfo:nil repeats:YES];
}

- (void)load_pairs {
    for(IOBluetoothDevice* device in [IOBluetoothDevice pairedDevices]) {
        if([device isConnected]) {
            NSString* address = IOBluetoothNSStringFromDeviceAddress([device getAddress]);
            NSString* deviceString = [[NSString alloc] initWithFormat:@"%@", address];
            [self->listofpairs addObject:deviceString];
            NSLog(@"Paired Device: %@ Connected: %d\n", [device name], [device isConnected]);
        }
    }
}

- (void)beep {
    NSBeep();
}

- (void)my_timer {
    IOBluetoothDevice* chosen = nil;
    int state = self->bingo_state;
    if(state == -1) {
        for(IOBluetoothDevice* device in [IOBluetoothDevice pairedDevices]){
            if([device isConnected]) {
                while(1){
                    if([device isConnected]) {
                        NSString* address = IOBluetoothNSStringFromDeviceAddress([device getAddress]);
                        chosen = device;
                    }
                }
            }
        }
        if(!chosen)
            return;
        NSString* msg = [NSString stringWithFormat:@"New connection: %@", [chosen name]];
        [self->bingo setStringValue:msg];
        [self beep];
        self->bingo_state = 16;
        NSString* mac = IOBluetoothNSStringFromDeviceAddress([chosen getAddress]);
        [myconfig add_device:[chosen name] mac:mac];
        if(self->mother) {
            [self->mother reload_menus];
        }
        [myconfig save_configuration];
    }
    
    else {
        self->bingo_state = state - 1;
        if(state <= 0) {
            [self do_cancel_pair];
        }
    }
}

- (void)do_cancel_pair {
    [self->mytimer invalidate];
    [[self window] close];
}

@end
