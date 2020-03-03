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

@interface ViewController : NSViewController <IOBluetoothL2CAPChannelDelegate>
- (IBAction)popupBtnChange:(id)sender;
@property (weak) IBOutlet NSTextField *textField;
- (IBAction)connectBtnClick:(id)sender;
@property (weak) IBOutlet NSButton *connectBtn;
@property (weak) IBOutlet NSMenu *deviceList;
@property IOBluetoothL2CAPChannel* interruptChannel;
@property IOBluetoothL2CAPChannel* controlChannel;
@property IOBluetoothUserNotification* mIncomingChannelNotification_l2cap_all;
@property IOBluetoothSDPServiceRecord* serviceRecord;
@property NSMutableDictionary *sdpEntries;
@property BluetoothSDPServiceRecordHandle mServerHandle;
@property BOOL connected;
@property BOOL darkModeOn;
@property uint8_t* key_array;
@property NSStatusItem* statusItem;
@property NSMenu* statusMenu;
@property NSMutableArray *devices;
@property NSEvent* eventMonitor;
@end

