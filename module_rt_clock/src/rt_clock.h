//---------------------------------------------------------
// DS1338 Real time clock chip driver header
// by teachop
//

#ifndef __RT_CLOCK_H__
#define __RT_CLOCK_H__

// module_rt_clock requires module_i2c_simple from sc_i2c
#include "i2c.h"

// driver interface
interface rt_clock_if {

    // get time "20YY-MM-DDThh:mm:ss" including null
    void getTime( uint8_t (&str)[20] );

    // set time "20YY-MM-DDThh:mm:ss"
    void setTime( uint8_t (&str)[20] );
};

[[combinable]]
void rt_clock_task(struct r_i2c &pin, interface rt_clock_if server rtc);


#endif //__RT_CLOCK_H__
