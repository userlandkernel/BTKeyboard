//
//  ViewController.m
//  keyboard
//
//  Created by Sem Voigtländer on 03/03/20.
//  Copyright © 2020 kernelprogrammer. All rights reserved.
//

#import "ViewController.h"
#import "USKeyboard.h"
#import "utils.h"

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    BluetoothL2CAPPSM l2capPSM;
    [NSEvent addGlobalMonitorForEventsMatchingMask:3072 handler:(id)^(NSEvent* event){
        [self myProcessKeyevent:event];
    }];

    self.mIncomingChannelNotification_l2cap_all = [IOBluetoothL2CAPChannel registerForChannelOpenNotifications:self selector:@selector(L2CAPIncomingChannelOpened:withChannel:)];
    
    self.sdpEntries = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AppleKeyboardService" ofType:@"plist"]];
    
    // Get the service record
    
    self.serviceRecord = [IOBluetoothSDPServiceRecord publishedServiceRecordWithDictionary:self.sdpEntries];
    
    // And the handle for that record
    BluetoothSDPServiceRecordHandle handle;
    [self.serviceRecord getServiceRecordHandle:&handle]; // Service record handle
    self.mServerHandle = handle;
    
    // And the L2CAP PSM for that record
    
    NSLog(@"Service: %@\n", [self.serviceRecord getServiceName]);
    NSLog(@"Device: %@\n", [self.serviceRecord device]);
    NSLog(@"Get PSM Status: %s\n", mach_error_string([self.serviceRecord getL2CAPPSM:&l2capPSM]));
    
}

- (void)astop {
    
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
        self.interruptChannel = l2capChannel;
        NSLog(@"InterruptChannel: %@\n", self.interruptChannel);
    }
    else if (l2capChannel.PSM == 17) {
        self.controlChannel = l2capChannel;
        [self.controlChannel setDelegate:self];
        NSLog(@"Control channel: %@\n", self.controlChannel);
    }
}

- (void)l2capChannelData:(IOBluetoothL2CAPChannel *)l2capChannel data:(void *)dataPointer length:(size_t)dataLength {
    hexdump("DATA", dataPointer, (int)dataLength);
}

- (void)l2capChannelOpenComplete:(IOBluetoothL2CAPChannel *)l2capChannel status:(IOReturn)error {
    IOBluetoothDevice* device = [l2capChannel device];
    NSString* address = [device addressString];
    NSLog(@"Channel now open: %@ for device: %@\n", l2capChannel, address);
    
}

- (void)l2capChannelClosed:(IOBluetoothL2CAPChannel *)l2capChannel {
    NSLog(@"Channel closed: %@\n", l2capChannel);
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

- (void)sendKey:(int)keyCode modifier:(int)modifier {
    uint8_t* report = hidReport(0x04, modifier);
    NSLog(@"Sending key %d with modifier %d\n", keyCode, modifier);
    kern_return_t err = [self.interruptChannel writeAsync:&report length:14 refcon:NULL];
    printf("%s\n", mach_error_string(err));
}

- (void)start_bt_now {
    
}

- (void)add_devices_into_menu_device {
    NSApplication* app = [NSApplication sharedApplication];
    NSMenu* menu = [app mainMenu];
    NSMenuItem* item = [menu itemAtIndex:1];
    NSMenu* submenu = [item submenu];
    
}

- (void)reload_menus {
    
}

- (void)show_menu {
    if(self.statusItem) {
        NSStatusBar* systemBar = [NSStatusBar systemStatusBar];
        [systemBar removeStatusItem:self.statusItem];
        self.statusItem = NULL;
    }
    // if( dword_100012AD4 == 1 )
    // ...
}

- (void)check_status_bar_mode_change {
    BOOL before = self.darkModeOn;
    [self refreshDarkMode];
    if(before != self.darkModeOn)
        [self show_menu];
}

- (void)refreshDarkMode {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    self.darkModeOn = [[defaults stringForKey:@"AppleInterfaceStyle"] isEqualToString:@"Dark"];
}

- (void)add_a_device {
    
}

- (void)build_keytables {
    self.key_array = malloc(6264);
    bzero(self.key_array, 6264);
}

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
        int keyCode = keyEvent.keyCode;
        int modifierFlags = keyEvent.modifierFlags;
        unsigned int v8 = (modifierFlags >> 14) & 0x10;
        unsigned int modifier = v8 | ((modifierFlags >> 12) & 0x20);
        modifier = modifier | ((modifierFlags >> 13) & 0x40);
        modifier = modifier | ((modifierFlags >> 13) & 0x80);
        [self sendKey:keyCode modifier:modifier];
    }
}

- (BOOL)textField:(NSTextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)replacement {
    return FALSE;
}

- (int)find_hid_value:(int)kvirt {
    return kvirttohid(kvirt);
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
    if(self.connected) {
        [self mydisconnect];
        
    }
}

- (void)do_delete_device {
    
}

- (void)reconnect {
    
}

- (void)mydisconnect {
    NSLog(@"Disconnecting...\n");
    if(self.controlChannel) {
        NSLog(@"Closing control channel...\n");
        [self.controlChannel closeChannel];
        self.controlChannel = NULL;
    }
    if(self.interruptChannel){
        NSLog(@"Closing interrupt channel...\n");
        [self.interruptChannel closeChannel];
        self.interruptChannel = NULL;
    }
}


- (IBAction)connectBtnClick:(id)sender {
    
    if(self.connected) {
        [self mydisconnect];
    }
    else {
        [self reconnect];
    }
}
- (IBAction)popupBtnChange:(id)sender {
}
@end
