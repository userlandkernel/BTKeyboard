//
//  myController.m
//  keyboard
//
//  Created by Sem Voigtländer on 04/03/20.
//  Copyright © 2020 kernelprogrammer. All rights reserved.
//

#import "mypreferences.h"
#import "myController.h"
@implementation myController

- (void)show_paste_state {
    
}

- (void)openPreferences {
    
}

- (void)openLicense {
    
}

- (void)do_click_mac_icon:(id)unknown {
    NSProcessInfo* processInfo = [NSProcessInfo processInfo];
    NSMenu* menu = [[NSMenu alloc] initWithTitle:@"aContextual Menu"];
    [menu addItemWithTitle:[processInfo hostName] action:nil keyEquivalent:@""];
    [menu addItemWithTitle:@"Paste" action:@selector(do_paste) keyEquivalent:@""];
    [menu popUpMenuPositioningItem:nil atLocation:[NSEvent mouseLocation] inView:nil];
    
}



- (void)build_keytables {
    
}

- (void)refreshDarkMode {
    
}

- (void)reload_menus {
    
}

- (void)show_menu {
    
}

- (void)do_paste {
    
}


- (void)do_quit {
    
}

- (void)save_mother:(NSObject*)Mother {
    self->app_mother = Mother;
}
@end
