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

    uint8_t time[20] = "2014-04-01T21:19:00";
    rtc.setTime(time);

    uint32_t display_rate = 500*1000*100;  // TODO use rtc notify tick to save timer?
    timer tick;
    uint32_t next_tick;
    tick :> next_tick;

    while (1) {
        select {
        case tick when timerafter(next_tick) :> void:
            next_tick += display_rate;
            rtc.getTime(time);
            display.setClock(10*(time[11]&15)+(time[12]&15), 10*(time[14]&15)+(time[15]&15),0);
            break;
        case keypad.keyPressed():
            // key-press notification, go get it
            uint32_t pressed = keypad.getKey();
            // TODO set time with keypad
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
        rt_clock_task(i2c_pins, rtc);
        keypad_task(drive_pins, sense_pins, keypad);
        seven_seg_task(txd_pin, display);
    }

    return 0;
}
