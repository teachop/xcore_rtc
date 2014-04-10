//---------------------------------------------------------
// Matrix keypad driver key mapping
// by teachop
//

#ifndef __CONFIG_KEYPAD_H__
#define __CONFIG_KEYPAD_H__

// this needs customized for particular keypad used
#ifdef __KEYPAD_C__
static const uint8_t key_map[16] = {
    'A','3','2','1',
    'B','6','5','4',
    'C','9','8','7',
    'D','#','0','*',
};
#endif

#endif // __CONFIG_KEYPAD_H__
