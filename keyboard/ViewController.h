//
//  ViewController.h
//  keyboard
//
//  Created by Sem Voigtländer on 03/03/20.
//  Copyright © 2020 kernelprogrammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <CoreBluetooth/CoreBluetooth.h>
#include <IOBluetooth/IOBluetooth.h>
#include "USKeyboard.h"

@interface ViewController : NSViewController <IOBluetoothL2CAPChannelDelegate> {
    IOBluetoothDevice* btDevice;
    IOBluetoothL2CAPChannel* interruptChannel;
    IOBluetoothL2CAPChannel* controlChannel;
    IOBluetoothUserNotification* mIncomingChannelNotification_l2cap_all;
    IOBluetoothSDPServiceRecord* serviceRecord;
    NSMutableDictionary *sdpEntries;
    BluetoothSDPServiceRecordHandle mServerHandle;
    BOOL connected;
    BOOL darkModeOn;
    key_dims_t* key_array;
    NSStatusItem* statusItem;
    NSMenu* statusMenu;
    NSMutableArray *devices;
    NSEvent* eventMonitor;
    NSTimer* mytimer;
    NSTimer* mytimer_paste;
    NSPasteboard* whichPboard;
    NSMutableArray* listofpairs;
    int showInMenu;
    int bingo_state;
}
@property (unsafe_unretained) IBOutlet NSTextView *keyboardInputView;

@end

