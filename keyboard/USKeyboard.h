//
//  uskeyboard.h
//  BTKeyboard
//
//  Created by Sem Voigtländer on 12/02/20.
//  Copyright © 2020 kernelprogrammer. All rights reserved.
//

#ifndef uskeyboard_h
#define uskeyboard_h

typedef struct key_dims {
    UniChar unicodeString;
    uint16_t ch;
    char shift;
    char alt;
    char hid_value;
} key_dims_t;

int kvirttohid(int kvirt);
uint8_t* hidReport(uint8_t keyCode, uint8_t modifier);
#endif /* uskeyboard_h */
