//-----------------------------------------------------------
// XCore Real Time Clock Test Application
// by teachop
//
// Control a real time clock display.
//

#include <xs1.h>
#include <timer.h>
#include <stdint.h>
#include "seven_seg.h"
#include "keypad.h"
#include "rt_clock.h"


// ---------------------------------------------------------
// clock_task - real time clock
//
void clock_task(interface rt_clock_if client rtc,
                interface keypad_if client keypad,
                interface seven_seg_if client display) {
    uint32_t editing=0;
    uint32_t toggle=0;
    uint8_t time[RTC_STRING_BUF];  // 20YY-MM-DDThh:mm:ss - string form
    uint8_t regs[RTC_REG_COUNT];   // RTC_xxx chip - register form
    uint8_t display_buf[] = "----";
    rtc.getTime(time);


    while (1) {
        select {
        case rtc.tick1Hz():
            // one second real time clock notify
            if ( editing ) {
                --editing;
                if ( !editing ) {
                    // timeout ends edit mode, validate range then write
                    if (2<time[11]) time[11]=2;
                    if ((2==time[11]) && (3<time[12])) time[12]=3;
                    if (5<time[14]) time[14]=5;
                    rtc.setTime(time);
                    toggle = 1;
                } else {
                    // clear notify
                    rtc.regRead(regs);
                }
            }
            if ( !editing ) {
                // read real time into string buffer, clears notify
                rtc.getTime(time);
                display.setClock(10*(time[11]&15)+(time[12]&15),//hour
                        10*(time[14]&15)+(time[15]&15),//minute
                        toggle? 0 : SSEG_COLON);//colon toggles
                toggle = !toggle;
            };
            break;

        case keypad.keyPressed():
            // key-press, reading keypad clears notify
            uint32_t pressed = keypad.getKey();
            if ( ('0'<=pressed) && ('9'>=pressed) ) {
                // '0'-'9' keys insert digits from the right
                display_buf[0] = time[11] = time[12];//H
                display_buf[1] = time[12] = time[14];//H
                display_buf[2] = time[14] = time[15];//M
                display_buf[3] = time[15] = pressed-'0';//M
                display.setText(display_buf);
                editing = 3;//seconds
            }
            break;
        }
    }
}


// ---------------------------------------------------------
// main - xCore rtc test
//

// matrix keypad
out port drive_pins= XS1_PORT_4E; // j7.22, 24, 16, 18
in port sense_pins = XS1_PORT_4D; // j7.9, 13, 12, 14

// serial display
port txd_pin       = XS1_PORT_4C; // j7.5, [6, 7, 8]

// real time clock chip
port sqw_pin       = XS1_PORT_1L; // j7.19
struct r_i2c i2c_pins = {
    XS1_PORT_1O, // scl, j7.21
    XS1_PORT_1I, // sda, j7.20
};

int main() {
    interface seven_seg_if display;
    interface keypad_if keypad;
    interface rt_clock_if rtc;

    set_port_pull_down(sense_pins);

    par {
        clock_task(rtc, keypad, display);
        rt_clock_task(i2c_pins, sqw_pin, rtc);
        keypad_task(drive_pins, sense_pins, keypad);
        seven_seg_task(txd_pin, display);
    }

    return 0;
}
