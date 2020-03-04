//
//  ViewController.m
//  keyboard
//
//  Created by Sem Voigtländer on 03/03/20.
//  Copyright © 2020 kernelprogrammer. All rights reserved.
//

#import <Carbon/Carbon.h>
#import "ViewController.h"
#import "USKeyboard.h"
#import "utils.h"


@implementation ViewController

NSMutableArray* devices = nil;

- (void)logMessage:(NSString*)message {
    [_keyboardInputView insertText:message];
}

- (BOOL)publishService {
    
    BluetoothL2CAPPSM l2capPSM;
    
    // Detect L2CAP Channel Open notifications
    self->mIncomingChannelNotification_l2cap_all = [IOBluetoothL2CAPChannel registerForChannelOpenNotifications:self selector:@selector(L2CAPIncomingChannelOpened:withChannel:)];
    
    // Load the service descriptor
    self->sdpEntries = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AppleKeyboardService" ofType:@"plist"]];
    
    // Get the service record
    self->serviceRecord = [IOBluetoothSDPServiceRecord publishedServiceRecordWithDictionary:self->sdpEntries];
    
    // Start pretending to be a keyboard
    [self set_my_fusker_class];
    
    // And the handle for that record
    BluetoothSDPServiceRecordHandle handle;
    if([self->serviceRecord getServiceRecordHandle:&handle]) {
        return NO;
    }
    
    // Update our handle reference
    self->mServerHandle = handle;
    
    // Print out service details and get the PSM
    NSLog(@"Service: %@\n", [self->serviceRecord getServiceName]);
    NSLog(@"Device: %@\n", [self->serviceRecord device]);
    NSLog(@"Get PSM Status: %s\n", mach_error_string([self->serviceRecord getL2CAPPSM:&l2capPSM]));
    
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Intercept keyboard keypresses (Make sure you marked this app as trusted in Settings>Security & Privacy>Privacy
    [NSEvent addGlobalMonitorForEventsMatchingMask:3072 handler:(id)^(NSEvent* event){
        [self myProcessKeyevent:event]; // Forward the keypress to the remote bluetooth device
    }];
    
    if(![self publishService]) {
        [self show_messagebox:@"Error" maintext:@"Failed to publish the BLE keyboard service."];
    }
    else {
        [self logMessage:@"BLE Keyboard service running!"];
    }
    
    self->mytimer = [NSTimer scheduledTimerWithTimeInterval:100.0 target:self selector:@selector(my_timer) userInfo:NULL repeats:1];
    self->mytimer_paste = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(my_timer_paste) userInfo:NULL repeats:1];
    [self build_keytables];
    self->whichPboard = [NSPasteboard generalPasteboard];
    [self show_menu];
    [self add_devices_into_menu_device];
    [self refreshDarkMode];
    [self load_pairs];
    [self reconnect];
}

- (void)astop {
    [self->serviceRecord removeServiceRecord];
}

- (void)show_messagebox:(NSString*)message maintext:(NSString*)maintext {
    NSAlert* msgbox = [[NSAlert alloc] init];
    [msgbox addButtonWithTitle:@"OK"];
    [msgbox setMessageText:message];
    [msgbox setInformativeText:maintext];
    [msgbox setAlertStyle:0];
    [msgbox runModal];
}

- (void)L2CAPIncomingChannelOpened:(IOBluetoothUserNotification *)notification withChannel:(IOBluetoothL2CAPChannel*)l2capChannel {
    IOBluetoothDevice* device = [l2capChannel device];
    NSString* address = [device addressString];
    NSLog(@"Received L2CAP channel for device: %@\n", address);
    if(l2capChannel.PSM == 19){
        self->interruptChannel = l2capChannel;
        [self logMessage:[[NSString alloc] initWithFormat:@"InterruptChannel: %@\n", self->interruptChannel]];
    }
    else if (l2capChannel.PSM == 17) {
        self->controlChannel = l2capChannel;
        [self->controlChannel setDelegate:self];
        [self logMessage:[[NSString alloc] initWithFormat:@"Control channel: %@\n", self->controlChannel]];
    }
}

- (void)l2capChannelData:(IOBluetoothL2CAPChannel *)l2capChannel data:(void *)dataPointer length:(size_t)dataLength {
    hexdump("DATA", dataPointer, (int)dataLength);
}

- (void)l2capChannelOpenComplete:(IOBluetoothL2CAPChannel *)l2capChannel status:(IOReturn)error {
    IOBluetoothDevice* device = [l2capChannel device];
    NSString* address = [device addressString];
    [self logMessage:[[NSString alloc] initWithFormat:@"Channel now open: %@ for device: %@\n", l2capChannel, address]];
    [self logMessage:[[NSString alloc] initWithFormat:@"Start typing to forward keys to the device..."]];

    
}

- (void)l2capChannelClosed:(IOBluetoothL2CAPChannel *)l2capChannel {
    [self logMessage:[[NSString alloc] initWithFormat:@"Channel closed: %@\n", l2capChannel]];
    if((l2capChannel.PSM | 2) == 0x13) {
        [self mydisconnect];
    }
}

- (void)l2capChannelReconfigured:(IOBluetoothL2CAPChannel *)l2capChannel {
    
}

- (void)l2capChannelWriteComplete:(IOBluetoothL2CAPChannel *)l2capChannel refcon:(void *)refcon status:(IOReturn)error {
    
}

- (void)l2capChannelQueueSpaceAvailable:(IOBluetoothL2CAPChannel *)l2capChannel {
    
}

- (void)sendKey:(uint16_t)keyCode modifier:(int)modifier {
    NSLog(@"Sending key %d with modifier %d\n", keyCode, modifier);
    
    struct keystack {
        uint16_t v7;
        char v8;
        char v9;
        char v10;
    } keystack = {
        .v7 = 417,
        .v8 = modifier,
        .v9 = 0,
        .v10 = keyCode,
    };
    
    if(!self->interruptChannel) {
        printf("CHANNEL IS DEAD!\n");
        return;
    }
    kern_return_t err = [self->interruptChannel writeAsync:&keystack length:sizeof(keystack) refcon:NULL];
    printf("%s\n", mach_error_string(err));
}

- (void)load_pairs {
    NSArray <IOBluetoothDevice*> *pairedDevices = [IOBluetoothDevice pairedDevices];

    for(IOBluetoothDevice* device in pairedDevices) {
        if([device isConnected]){
            NSString* address = IOBluetoothNSStringFromDeviceAddress([device getAddress]);
            NSString* deviceString = [[NSString alloc] initWithFormat:@"%@", address];
            [self->listofpairs addObject:deviceString];
            NSLog(@"Paired Device: %@ Connected: %d\n", [device name], [device isConnected]);
        }
    }
    devices = self->listofpairs;
}

- (void)beep {
    NSBeep();
}

- (void)start_bt_now {
    
}

- (void)add_devices_into_menu_device {
    NSApplication* app = [NSApplication sharedApplication];
    NSMenu* menu = [app mainMenu];
    NSMenuItem* item = [menu itemAtIndex:1];
    for(NSString* mac in self->listofpairs) {
        NSMenuItem* macItem = [[NSMenuItem alloc] initWithTitle:mac action:nil keyEquivalent:@""];
        [[item submenu] addItem:macItem];
    }
    
}

- (void)reload_menus {
    [self add_devices_into_menu_device];
    [self show_menu];
}

- (void)show_menu {
    if(self->statusItem) {
        NSStatusBar* systemBar = [NSStatusBar systemStatusBar];
        [systemBar removeStatusItem:self->statusItem];
        self->statusItem = NULL;
    }
    if(self->showInMenu) {
        
        NSMenu* _statusMenu = self->statusMenu;
        
        if(_statusMenu){
            [_statusMenu removeAllItems];
        }
        else {
            self->statusMenu = [[NSMenu alloc] init];
        }
        
    }
    // if( dword_100012AD4 == 1 )
    // ...
}

- (void)check_status_bar_mode_change {
    BOOL before = self->darkModeOn;
    [self refreshDarkMode];
    if(before != self->darkModeOn)
        [self show_menu];
}

- (void)refreshDarkMode {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    self->darkModeOn = [[defaults stringForKey:@"AppleInterfaceStyle"] isEqualToString:@"Dark"];
}

- (void)add_a_device {
    
}

- (void)build_keytables {
    uint32_t modifierStates[3] = { 2, 8, 10 };
    self->key_array = malloc(6264);
    bzero(self->key_array, 6264);
    TISInputSourceRef key_layout = TISCopyCurrentKeyboardLayoutInputSource();
    if(key_layout) {
        CFMutableDataRef layoutData = TISGetInputSourceProperty(key_layout, kTISPropertyUnicodeKeyLayoutData);
        
        if(layoutData) {
            const UCKeyboardLayout* layout = (const UCKeyboardLayout*)CFDataGetMutableBytePtr(layoutData);
            if(layout){
                int index = 0;
                uint32_t v8 = 0;
                while(v8 != 4) {
                    int v19 = v8;
                    uint v9 = v8 - 1;
                    int modifierStateIndex = (signed int)v8 - 1;
                    uint16_t virtualKeyCode = 0;
                    while(virtualKeyCode != 128) {
                        uint32_t modifierKeyState = 0;
                        if(v9 <= 2)
                            modifierKeyState = modifierStates[modifierStateIndex];
                        UniCharCount actualStringLength = 0;
                        uint32_t deadKeyState = 0;
                        uint32_t keyboardType = LMGetKbdType();
                        UniChar unicodeString = 0;
                        if(!(uint)UCKeyTranslate(layout, virtualKeyCode, 0, modifierKeyState, keyboardType, 0, &deadKeyState, 255, &actualStringLength, &unicodeString)){
                            if(actualStringLength) {
                                if(unicodeString != 28 && index <= 521 && unicodeString) {
                                   key_dims_t* dimRef = &self->key_array[index];
                                    dimRef->ch = virtualKeyCode;
                                    dimRef->unicodeString = unicodeString;
                                    dimRef->shift = 0;
                                    switch(v19) {
                                        case 3:
                                            dimRef->alt = 1;
                                            dimRef->shift = 1;
                                            break;
                                        case 2:
                                            dimRef->alt = 1;
                                            break;
                                        case 1:
                                            dimRef->shift = 1;
                                            break;
                                    }
                                    ++index;
                                }
                            }
                        }
                        ++virtualKeyCode;
                    }
                    v8 = (unsigned int)(v19 + 1);
                }
            }
            CFRelease(key_layout);
        }
    }
}

- (int)find_key_array_element:(uint16_t)key {
    for(int  i = 0; i <= 0x209; i++) {
        if(self->key_array[i].ch == key) {
            return i;
        }
    }
    return -1;
}
/*
- (int)find_hid_value:(uint16_t)key {
    int idx = [self find_key_array_element:key];
    if(idx < 0)
        return idx;
    return self->key_array[idx].hid_value;
}
 */

- (void)my_timer_paste {
    
}

- (void)my_timer {
    [self set_my_fusker_class];
}

- (void)set_my_fusker_class {
    IOBluetoothHostController* controller = [IOBluetoothHostController defaultController];
    int current = [controller classOfDevice];
    [controller setClassOfDevice:current|0x380540 forTimeInterval:120.0];
}

- (BOOL)is_BT_on {
    IOBluetoothHostController* controller = [IOBluetoothHostController defaultController];
    if(!controller || ![controller respondsToSelector:@selector(powerState)])
        return NO;
    if([controller powerState] != kBluetoothHCIPowerStateON) {
        [self start_bt_now];
        return NO;
    }
    usleep(0x1E8480);
    return YES;
}

- (void)keyUp:(NSEvent*)event {
    
}

- (void)keyDown:(NSEvent*)event {
    
}

- (void)myProcessKeyevent:(NSEvent*)keyEvent {
    if(keyEvent) {
        
        int keyCode = keyEvent.keyCode; // Which key was pressed
        int type = keyEvent.type;   // What type of event (keyUp / keyDown etc.)
        int modifierFlags = keyEvent.modifierFlags; // Which modifier key (SHIFT, CAPS etc) is pressed
        
        uint v8 = (modifierFlags >> 14) & 0x10; // Unknown?
        uint modifier = v8 | ((modifierFlags >> 12) & 0x20) | ((modifierFlags >> 13) & 0x40) | ((modifierFlags >> 13) & 0x80); // The actual modifier
        
        if( (type & 0xB) == 11){
            [self sendKey:0 modifier:modifier];
        }
        int hidvalue = [self find_hid_value:keyCode];

        int v12 = '(';
        if(hidvalue != 'X')
            v12 = hidvalue;
        
        if(v12 != -1)
            [self sendKey:(unsigned int)(char)v12 modifier:modifier];
        
        NSString* characters = [keyEvent characters];
        if(characters && [characters length]) {
            char c = [characters characterAtIndex:0];
            // play it
        }
 
    }
}

- (BOOL)textField:(NSTextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)replacement {
    return FALSE;
}


- (int)find_hid_value:(int)kvirt {
    return kvirttohid(kvirt); //Translate virtual-key to HID-key
}

- (void)flagsChanged:(NSEvent *)event {
    int modifier = [event modifierFlags];
    if(!(modifier & 0x800000)) {
        [self sendKey:0 modifier:(((unsigned int)modifier >> 14) & 0x10) | (((unsigned int)modifier >> 12) & 0x20) | ((modifier >> 13) & 0x40) | ((modifier >> 13) & 0x80)];
    }
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)do_add_device {
    if(self->connected) {
        [self mydisconnect];
        
    }
}

- (void)do_delete_device {
    
}


- (void)reconnect {
    
    if(!devices)
        return;
    
    if([devices count]) {
        self->btDevice = [IOBluetoothDevice deviceWithAddressString:[devices objectAtIndex:0]];
        if(self->btDevice) {
            IOBluetoothL2CAPChannel* channel = NULL;
            [self->btDevice openL2CAPChannelAsync:&channel withPSM:17 delegate:self];
            self->controlChannel = channel;
            [self->controlChannel setDelegate:self];
        }
    }
}


- (void)mydisconnect {
    
    NSLog(@"Disconnecting...\n");

    // Close the L2CAP control channel if any
    if(self->controlChannel) {
        NSLog(@"Closing control channel...\n");
        [self->controlChannel closeChannel];
        self->controlChannel = NULL;
    }

    // Close the L2CAP interrupt channel if any
    if(self->interruptChannel){
        NSLog(@"Closing interrupt channel...\n");
        [self->interruptChannel closeChannel];
        self->interruptChannel = NULL;
    }
}


- (IBAction)connectBtnClick:(id)sender {
    
    if(self->connected) {
        [self mydisconnect];
    }
    else {
        [self reconnect];
    }
}
- (IBAction)popupBtnChange:(id)sender {
}
@end
