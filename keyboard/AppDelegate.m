//
//  AppDelegate.m
//  keyboard
//
//  Created by Sem Voigtländer on 03/03/20.
//  Copyright © 2020 kernelprogrammer. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate () {
    myController* ny;
    NSMenuItem* amenu_show_paste_buffer;
    NSMenuItem* amenu_show_draft_text;
}

@end

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSUserDefaults* defaults = [NSUserDefaults alloc];
    if([defaults respondsToSelector:@selector(initWithSuiteName:)]){
        defaults = [defaults initWithSuiteName:@"RR9F5EPNVM.mochakeyboard"];
    }
    else {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    registry = defaults;
    [myconfig load_configuration];
    self->ny = [[myController alloc] initWithWindowNibName:@"myController"];
    [self->ny save_mother:self];
}


- (void)update_menu_states {
    [self->amenu_show_paste_buffer setState:show_paste_buffer == 1];
    [self->amenu_show_draft_text setState:show_draft_text == 1];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [myconfig save_configuration];
}

// UNIMPLEMENTED: app_paste

- (BOOL)validateMenuItem:(NSMenuItem*)item {
    BOOL valid = [item respondsToSelector:@selector(action)];
    if([item action] == NSSelectorFromString(@"app_paste: ")) {
        //valid = [self->ny request_paste_state];
    }
    return valid;
}


@end
