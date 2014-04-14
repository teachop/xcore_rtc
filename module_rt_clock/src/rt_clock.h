//---------------------------------------------------------
// DS1338 Real time clock chip driver header
// by teachop
//

#ifndef __RT_CLOCK_H__
#define __RT_CLOCK_H__

// module_rt_clock requires module_i2c_simple from sc_i2c
#include "i2c.h"

// register map
enum{RTC_SECONDS, RTC_MINUTES, RTC_HOURS,
    RTC_DAY, RTC_DATE, RTC_MONTH, RTC_YEAR};
#define RTC_REG_COUNT   7

#define I2C_ADDR 0x68 // 0xd0, shifted left by 1 in the i2c driver

#define RTC_STRING_BUF 20

// driver interface
interface rt_clock_if {

    // signal at 1Hz based on chip sqw pin
    [[notification]] slave void tick1Hz(void);

    // get time via string "20YY-MM-DDThh:mm:ss"
    [[clears_notification]] void getTime( uint8_t (&str)[RTC_STRING_BUF] );
    void setTime( uint8_t (&str)[RTC_STRING_BUF] );

    // direct register access
    [[clears_notification]] void regRead( uint8_t (&regs)[RTC_REG_COUNT] );
    void regWrite( uint8_t (&regs)[RTC_REG_COUNT] );
};

[[combinable]]
void rt_clock_task(struct r_i2c &pin, port ?sqw, interface rt_clock_if server rtc);


#endif //__RT_CLOCK_H__
