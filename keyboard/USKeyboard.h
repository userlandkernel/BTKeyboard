//
//  uskeyboard.h
//  BTKeyboard
//
//  Created by Sem Voigtländer on 12/02/20.
//  Copyright © 2020 kernelprogrammer. All rights reserved.
//

#ifndef uskeyboard_h
#define uskeyboard_h
int kvirttohid(int kvirt);
uint8_t* hidReport(uint8_t keyCode, uint8_t modifier);
#endif /* uskeyboard_h */
