##XCore Driver for I2C Real Time Clock
This project provides an XCore driver module for interfacing to popular Real Time Clock chips such as the **DS1338** (**DS1307** register compatible).  The driver is implemented in the XC language and has been tested on the XMOS [startKIT](http://www.xmos.com/startkit).

The **DS1338** IC was selected for development of the driver for its ability to run at 3.3 volts while remaining compatible with popular RTC chips.  Communication with the IC is via the two wire serial I2C bus.  Two 1 pin ports on the microcontroller are used with the "simple" version of the [XMOS XCore I2C module](https://github.com/xcore/sc_i2c).

**Note**  A recent revision removes the control register from driver API interface.  If the application declares its buffer size using the header define **RTC_REG_COUNT** (which was 8 and is now 7) nothing will break.  The reasoning for this change is to allow support for the more accurate and featured **DS3231/3232** chips, which have compatibility with time-setting registers of the earlier parts but not with the control register.  Support for these new parts will be released after testing is complete - [hardware](http://www.adafruit.com/products/255) is on order...

###Two or Three Pins
Interfacing to the clock chip on I2C requires two pins, **SCL** clock, and **SDA** data.  

Connecting a third port allows applications to utilize a feature of this RTC chip - its single output pin **SQW**.  The driver sets **SQW** up to generate 1Hz notification events.  This is optional and can be disabled if you don't have a pin to spare.

All three require external pull-up resistors.

###Example
The repository also contains an example clock program application to demonstrate the driver.  The example incorporates a [SparkFun Serial 7 Segment Display](https://github.com/teachop/xcore_seven_seg) as the clock display, and uses a [matrix keypad](https://github.com/teachop/xcore_keypad) for input controls.  

###Driver API
Application clients use the driver by means of an XC [interface](https://www.xmos.com/support/documentation/xtools?subcategory=xTIMEcomposer&component=17653&page=23#xc-prog-guide-interface-connection) API.  This is an XCore message passing inter-task communication feature.

The XC interface feature called **notification** is used to generate events for the client application at 1Hz.  The 1Hz events are based on the **SQW** output from the chip.

- **getTime(str)** Gets the current time as a string in the format "20YY-MM-DDThh:mm:ss", including null termination into a 20 byte buffer.
- **setTime(str)** Sets the clock from a string in the format "20YY-MM-DDThh:mm:ss".  In this string only the YY MM DD hh mm ss matter.  The delimiters, high year digits, and ending null are ignored.
- **regRead(regs)** Read from the first 7 **DS1338** registers directly.
- **regWrite(regs)** Write to the first 7 **DS1338** registers directly.
- **tick1Hz()** - Notification event indicating to the client at 1Hz.  Notification is cleared by **getTime(str)** or **regRead(regs)**.  This feature is optional.

**Note:**  The notification (and use of the third pin) can be disabled by passing the port pin as null [(see nullable types)](https://www.xmos.com/support/documentation/xtools?subcategory=xTIMEcomposer&component=17653&page=25) when the task is started.
