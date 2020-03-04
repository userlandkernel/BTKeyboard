//
//  myController.h
//  keyboard
//
//  Created by Sem Voigtländer on 04/03/20.
//  Copyright © 2020 kernelprogrammer. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"
#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "AppDelegate.h"

@interface myController : NSWindowController <IOBluetoothL2CAPChannelDelegate> {
    bool darkModeOn;
    bool has_focus;
    int paste_count;
    int paste_length;
    bool paste_abort;
    NSObject* app_mother;
    float full_window_height;
    float full_window_width;
    NSButton* knap_connect_diconnect;
    NSTextField *current_error_status;
    NSTextField *current_paste_status;
    NSTextField *current_online_status;
    NSTextField *lite_version_text;
    NSButton *paste_button;
    float draft_text_y;
    NSMenu *statusMenu;
    NSStatusItem* statusItem;
    int key_array[522];
    
}
- (void)save_mother:(NSObject*)Mother;
- (void)update_what_to_show_in_window;
- (void)openLicense;
- (void)openPreferences;
- (void)add_devices_into_menu_device;
- (void)reload_menus;
- (void)select_device;
- (void)show_menu;
- (void)check_status_bar_mode_change;
- (void)refreshDarkMode;
- (void)do_quit;
- (void)add_a_device;
- (void)build_keytables;
- (void)find_key_array_element;
- (void)check_paste_buffer;
- (void)show_paste_state;
@end
