/*
 * Template for writing DOS device drivers in Open Watcom C
 *
 * Copyright (C) 2022, Eduardo Casino (mail@eduardocasino.es)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA  02110-1301, USA.
 *
 */

#include <dos.h>
#include <stdint.h>
#include <stddef.h>

#include "device.h"

typedef uint16_t (*driverFunction_t)(void);

#pragma data_seg("_CODE")

//
// Place here any variables or constants that should remain after driver installation
//

static request far *fpRequest = (request far *)0;

#pragma data_seg()

static char hellomsg[] =    "\r\nDOS Device Driver Template in Open Watcom C\r\n$";

static uint16_t Open( void )
{
    return S_DONE;
}

static uint16_t Close( void )
{
    return S_DONE;
} 

#pragma data_seg("_CODE")

static uint16_t DeviceInit( void );

static driverFunction_t dispatchTable[] =
{
    DeviceInit,          // 0x00 Initialize
    NULL,                // 0x01 MEDIA Check
    NULL,                // 0x02 Build BPB
    NULL,                // 0x03 Ioctl In
    NULL,                // 0x04 Input (Read)
    NULL,                // 0x05 Non-destructive Read
    NULL,                // 0x06 Input Status
    NULL,                // 0x07 Input Flush
    NULL,                // 0x08 Output (Write)
    NULL,                // 0x09 Output with verify
    NULL,                // 0x0A Output Status
    NULL,                // 0x0B Output Flush
    NULL,                // 0x0C Ioctl Out
    Open,                // 0x0D Device Open
    Close,               // 0x0E Device Close
    NULL,                // 0x0F Removable MEDIA
    NULL,                // 0x10 Output till busy
    NULL,                // 0x11 Unused
    NULL,                // 0x12 Unused
    NULL,                // 0x13 Generic Ioctl
    NULL,                // 0x14 Unused
    NULL,                // 0x15 Unused
    NULL,                // 0x16 Unused
    NULL,                // 0x17 Get Logical Device
    NULL,                // 0x18 Set Logical Device
    NULL                 // 0x19 Ioctl Query
};

static driverFunction_t currentFunction;

#pragma data_seg()

void far DeviceInterrupt( void )
#pragma aux DeviceInterrupt "*_" parm [] modify [ax bx cx dx si di bp es fs gs]
{
    __asm {
        push ds
        push cs
        pop ds
    }

    if ( fpRequest->r_command > C_MAXCMD || NULL == (currentFunction = dispatchTable[fpRequest->r_command]) )
    {
        fpRequest->r_status = S_DONE | S_ERROR | E_CMD;
    }
    else
    {
        fpRequest->r_status = currentFunction();
    }

    __asm {
        pop ds
    }
}

void __declspec(naked) far DeviceStrategy( void )
{
    __asm {
        mov     word ptr cs:[fpRequest], bx
        mov     word ptr cs:[fpRequest+2], es
        retf
    }
}

// Everything beyond and including DeviceInit() will be discarded from memory after initialization
//

__segment getCS( void );
#pragma aux getCS = \
    "mov ax, cs";

static void printMsg( const char *msg );
#pragma aux printMsg =        \
    "mov    ah, 0x9"        \
    "int    0x21"            \
    parm [dx]                \
    modify [ax di es];

static uint16_t DeviceInit( void )
{
    printMsg( hellomsg );

    fpRequest->r_endaddr = MK_FP( getCS(), DeviceInit );

    return 0;
}


