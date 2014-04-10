##XCore Driver for I2C Real Time Clock
This project provides an XCore driver module for interfacing to an I2C Real Time Clock chip DS1338.  It is written in the XC language and has been tested on the XMOS [startKIT](http://www.xmos.com/startkit).  The repository also contains an example clock program that uses a [matrix keypad](https://github.com/teachop/xcore_keypad) for controls.  The example incorporates a [SparkFun Serial 7 Segment Display](https://github.com/teachop/xcore_seven_seg) as the clock display.

###Driver API
- **getTime(buffer)** Gets the current time as "20YY-MM-DDThh:mm:ss" including null.
- **getTime(buffer)** Sets the RTC from the string "20YY-MM-DDThh:mm:ss".  In this string only the YY MM DD hh mm ss matter.  The delimiters, high year, and null are ignored.
