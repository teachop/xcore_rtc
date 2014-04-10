##XCore Driver for I2C Real Time Clock
This project provides an XCore driver module for interfacing to a **DS1338** Real Time Clock chip (**DS1307** register compatible).  The driver is implemented in the XC language and has been tested on the XMOS [startKIT](http://www.xmos.com/startkit).

The **DS1338** was selected for its ability to run at 3.3 volts while remaining compatible with popular RTC chips.  Communication with the IC is via the two wire serial I2C bus.  Two 1 pin ports on the microcontroller are used with the "simple" version of the [XMOS XCore I2C module](https://github.com/xcore/sc_i2c).

###Two or Three Pins
Interfacing to the clock chip on I2C requires two pins, **SCL** clock, and **SDA** data.  

Connecting a third port allows applications to utilize a feature of this RTC chip - its single output pin **SQW**.  The driver sets **SQW** up to generate 1Hz notification events.  This is optional and can be disabled if you don't have a pin to spare.

All three require external pull-up resistors.

###Example
The repository also contains an example clock program application to demonstrate the driver.  The example incorporates a [SparkFun Serial 7 Segment Display](https://github.com/teachop/xcore_seven_seg) as the clock display, and uses a [matrix keypad](https://github.com/teachop/xcore_keypad) for input controls.  

###Driver API
Application clients use the driver by means of an XC [interface](https://www.xmos.com/support/documentation/xtools?subcategory=Programming%20in%20C%20and%20XC&component=app_interfaces_example) API.  This is an XCore message passing inter-task communication feature.

The XC interface feature called **notification** is used to generate events for the client application at 1Hz.  The 1Hz events are based on the **SQW** output from the chip.

- **getTime(str)** Gets the current time as a string in the format "20YY-MM-DDThh:mm:ss", including null termination into a 20 byte buffer.
- **setTime(str)** Sets the clock from a string in the format "20YY-MM-DDThh:mm:ss".  In this string only the YY MM DD hh mm ss matter.  The delimiters, high year digits, and ending null are ignored.
- **regRead(regs)** Read from the first 7 **DS1338** registers directly.
- **regWrite(regs)** Write to the first 7 **DS1338** registers directly.
- **tick1Hz()** - Notification event indicating to the client at 1Hz.  Notification is cleared by **getTime(str)** or **regRead(regs)**.  This feature is optional.

**Note:**  The notification (and use of the third pin) can be disabled by passing the port pin as [null](https://www.xmos.com/published/how-use-nullable-types) when the task is started.
