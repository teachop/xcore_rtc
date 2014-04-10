##Real Time Clock Example
Implements a real time clock to demonstrate the RTC driver.  A keypad is used to adjust the clock time.  The real-time clock chip requires I2C port for communication.

A serial 4 digit 7 segment display is used to show the lock combination value.

###Required Modules
For an xCore xC application, the required modules are listed in the Makefile:
- USED_MODULES = [module_seven_seg](https://github.com/teachop/xcore_seven_seg) [module_keypad](https://github.com/teachop/xcore_keypad) [module_i2c_simple](https://github.com/xcore/sc_i2c) module_rt_clock

###Wiring
The display uses a single pin for serial data.  The demo wires this to a 4-wide port LSB, but normally this would be a single output port pin.  The matrix requires two 4-wide ports, one output to drive the keypad, one to sense the inputs.  Internal pull-downs in the startKIT CPU are used to keep the keys off when not pressed.  For a "production job" external resistors are recommended.
- **XS1_PORT_4E**  Drive, j7.22, 24, 16, 18
- **XS1_PORT_4D**  Sense, j7.9, 13, 12, 14
- **XS1_PORT_4C**  TXD UART transmit, j7.5, [6, 7, 8]
- **XS1_PORT_1O**  I2C SCL, j7.21
- **XS1_PORT_1I**  I2C SDA, j7.20

The I2C port requires external pull-up resistors on both signals.  I used 4.7K and that worked.

Keypad connector pinout varies, this is just one example:

|    4x4    | pin 5 | pin 6 | pin 7 | pin 8 |
|:---------:|:-----:|:-----:|:-----:|:-----:|
| **pin 1** |   1   |   2   |   3   |   A   |
| **pin 2** |   4   |   5   |   6   |   B   |
| **pin 3** |   7   |   8   |   9   |   C   |
| **pin 4** |   *   |   0   |   #   |   D   |

