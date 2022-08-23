### Template for writing DOS Device Drivers in Open Watcom C

#### About

I needed to implement a DOS device driver for a project I'm working on. While searching for information, all the examples I found were developed in assembler. Although I have done things in assembler before, I find it much more satisfying to program in C and much, much easier to maintain, so I ended up figuring out a way to do it in C, using the Open Watcom toolkit.

Since I haven't seen anything like it out there, I'm sharing it in case anyone else finds it useful. Please open an issue if you encounter any bug or have some feedback.

#### License

All my code is under the GNU General Public License. The device.h header is fron the FreeDOS kernel, with some minor modifications, and is also GPLd. See the LICENSE.txt file for details.

#### Disclaimers

This is not a tutorial on writing DOS device drivers. There are excellent sources of information on the subject, both online and in print, so Google is your friend.

THIS PROGRAM IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK ASTO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION

#### Acknowledgements

* "Undocumented DOS 2nd ed." by Andrew Schulman et al.
* "Advanced MSDOS Programming", 2nd ed. by Ray Duncan
* The FreeDOS kernel
* Ralf Brown's Interrupt List

#### Usage

* Edit the cstrtsys.asm file and define the device name and attributes. Examples:

	For a char device:
	```
	  DEVICE_NAME     equ     'MYDEVIC$'
	  DEVICE_ATTR     equ     ATTR_CHAR
	```
	For a block device supporting generic IOCTL and 32-bit sectors:

	```
	  DEVICE_NAME     equ     0    ; First byte is number of units
	  DEVICE_ATTR     equ     ATTR_EXCALLS or ATTR_QRYIOCTL or ATTR_GENIOCTL or ATTR_HUGE
	```

* Implement the functions that your device is supporting and update the `dispatchTable` accordingly. Return value is a word (`uint16_t`) with the status code in the higher byte and the error code in the lower one.

	The available stack space for device drivers is very scarce. Restrict the use of automatic variables to simple data types. If you want to declare variables inside the scope of a function, make them `static`

    **NOTE**: If your driver implements a couple of functions, probably some if / else or a switch statement would be a better option than a dispatch table.

* Place everything your driver must execute during initialization inside the `DeviceInit()` function. If an error should cause abort, indicate so by telling the kernel to free all the driver space:
	```
	  fpRequest->r_endaddr = MK_FP( getCS(), 0 );
	```

* Any static variable outside a `#pragma data_seg("_CODE")` - `pragma data_seg()` block will be freed after driver initialization. That include static variables inside functions, so make sure to declare them between those pragmas:
	```
	  uint16_t exampleFunction( void )
	  {
	  #pragma data_seg("_CODE")
    	static uint32_t variable; 
	  #pragma data_seg()
    	  ...
	  }
	```

* Build using `wmake`