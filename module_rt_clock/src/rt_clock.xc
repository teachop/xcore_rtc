//---------------------------------------------------------
// Real Time Clock driver
// by teachop
//

#include <xs1.h>
#include <stdint.h>
#include "rt_clock.h"

// ---------------------------------------------------------
// rt_clock_task - Real Time Clock driver task
//
[[combinable]]
void rt_clock_task(struct r_i2c &pins, port ?sqw, interface rt_clock_if server rtc) {
    uint8_t clock_reg[RTC_REG_COUNT] = {0,0,0,1,1,1,0};
    uint8_t control_reg[1] = {0}; // control address differs depending on chip
    uint8_t control_address = 7;  // for ds1307, 1338
    uint32_t enable_sqw = !isnull(sqw);// enable disable SQW pin
    uint32_t sqw_in = 0;

    i2c_master_init(pins);
    i2c_master_read_reg(I2C_ADDR, 0, clock_reg, sizeof(clock_reg), pins);

    control_reg[0] = enable_sqw? 0x10 : 0; // 1Hz SQW
    i2c_master_write_reg(I2C_ADDR, control_address, control_reg, 1, pins);

    while( 1 ) {
        select {
        case rtc.getTime(uint8_t (&str)[RTC_STRING_BUF]): // 20YY-MM-DDThh:mm:ss
            i2c_master_read_reg(I2C_ADDR, 0, clock_reg, sizeof(clock_reg), pins);
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

        case rtc.setTime(uint8_t (&str)[RTC_STRING_BUF]): // 20YY-MM-DDThh:mm:ss
            clock_reg[RTC_YEAR]    = (str[2] <<4) | (str[3] &15);
            clock_reg[RTC_MONTH]   = (str[5] <<4) | (str[6] &15);
            clock_reg[RTC_DATE]    = (str[8] <<4) | (str[9] &15);
            clock_reg[RTC_HOURS]   = (str[11]<<4) | (str[12]&15);
            clock_reg[RTC_MINUTES] = (str[14]<<4) | (str[15]&15);
            clock_reg[RTC_SECONDS] = (str[17]<<4) | (str[18]&15);
            i2c_master_write_reg(I2C_ADDR, 0, clock_reg, sizeof(clock_reg), pins);
            break;

        case rtc.regRead(uint8_t (&regs)[RTC_REG_COUNT]):
            i2c_master_read_reg(I2C_ADDR, 0, clock_reg, sizeof(clock_reg), pins);
            for (uint32_t loop=0; loop<sizeof(regs); ++loop) {
                regs[loop] = clock_reg[loop];
            }
            break;

        case rtc.regWrite(uint8_t (&regs)[RTC_REG_COUNT]):
            for (uint32_t loop=0; loop<sizeof(clock_reg); ++loop) {
                clock_reg[loop] = regs[loop];
            }
            i2c_master_write_reg(I2C_ADDR, 0, clock_reg, sizeof(clock_reg), pins);
            break;

        case enable_sqw => sqw when pinsneq(sqw_in) :> sqw_in:
            if ( sqw_in ) {
                rtc.tick1Hz();
            }
            break;
        }
    }

}
