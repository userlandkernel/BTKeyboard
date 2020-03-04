//
//  myPair_it.h
//  keyboard
//
//  Created by Sem Voigtländer on 04/03/20.
//  Copyright © 2020 kernelprogrammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "myController.h"
#import "myconfig.h"

@interface myPair_it : NSWindowController {
    myController* mother;
    int bingo_state;
    NSTextField* bingo;
    NSMutableArray* listofpairs;
    NSTimer* mytimer;
}

@end
