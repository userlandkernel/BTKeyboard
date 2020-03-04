//
//  myconfig.h
//  keyboard
//
//  Created by Sem Voigtländer on 04/03/20.
//  Copyright © 2020 kernelprogrammer. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSUserDefaults* registry;
extern int show_paste_buffer;
extern int show_draft_text;

@interface myconfig : NSObject
+ (void)add_device:(NSString*)name mac:(NSString*)mac;
+ (void)save_configuration;
+ (void)load_configuration;
@end
