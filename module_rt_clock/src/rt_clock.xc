//---------------------------------------------------------
// Real Time Clock driver
// by teachop
//

#include <xs1.h>
#include <stdint.h>
#include "rt_clock.h"

enum{RTC_SECONDS, RTC_MINUTES, RTC_HOURS, RTC_DAY,
     RTC_DATE, RTC_MONTH, RTC_YEAR, RTC_CONTROL};

#define RTC_REG_COUNT   8
#define I2C_ADDR 0x68 // 0xd0, shifted left by 1 in the driver

// ---------------------------------------------------------
// rt_clock_task - Real Time Clock driver task
//
[[combinable]]
void rt_clock_task(struct r_i2c &pins, interface rt_clock_if server rtc) {
    uint8_t clock_reg[RTC_REG_COUNT] = {0,0,0,1,1,1,0,0};

    i2c_master_init(pins);

    while( 1 ) {
        select {
        case rtc.getTime(uint8_t (&str)[20]): // 20YY-MM-DDThh:mm:ss
            i2c_master_read_reg(I2C_ADDR, 0, clock_reg, RTC_REG_COUNT, pins);
            uint32_t idx = 0;
            str[idx++] = '2';
            str[idx++] = '0';
            str[idx++] = '0' + (clock_reg[RTC_YEAR]>>4);        // year
            str[idx++] = '0' + (clock_reg[RTC_YEAR] & 15);
            str[idx++] = '-';
            str[idx++] = '0' + (clock_reg[RTC_MONTH]>>4);       // month
            str[idx++] = '0' + (clock_reg[RTC_MONTH] & 15);
            str[idx++] = '-';
            str[idx++] = '0' + (clock_reg[RTC_DATE]>>4);        // day
            str[idx++] = '0' + (clock_reg[RTC_DATE] & 15);
            str[idx++] = 'T';
            str[idx++] = '0' + ((clock_reg[RTC_HOURS]>>4) & 3); // hour, 24
            str[idx++] = '0' + (clock_reg[RTC_HOURS] & 15);
            str[idx++] = ':';
            str[idx++] = '0' + (clock_reg[RTC_MINUTES]>>4);     // minute
            str[idx++] = '0' + (clock_reg[RTC_MINUTES] & 15);
            str[idx++] = ':';
            str[idx++] = '0' + (clock_reg[RTC_SECONDS]>>4);     // second
            str[idx++] = '0' + (clock_reg[RTC_SECONDS] & 15);
            str[idx] = 0;
            break;

        case rtc.setTime(uint8_t (&str)[20]): // 20YY-MM-DDThh:mm:ss
            clock_reg[RTC_YEAR]    = (str[2] <<4) | (str[3] &15);
            clock_reg[RTC_MONTH]   = (str[5] <<4) | (str[6] &15);
            clock_reg[RTC_DATE]    = (str[8] <<4) | (str[9] &15);
            clock_reg[RTC_HOURS]   = (str[11]<<4) | (str[12]&15);
            clock_reg[RTC_MINUTES] = (str[14]<<4) | (str[15]&15);
            clock_reg[RTC_SECONDS] = (str[17]<<4) | (str[18]&15);
            i2c_master_write_reg(I2C_ADDR, 0, clock_reg, RTC_REG_COUNT, pins);
            break;
        }
    }

}
