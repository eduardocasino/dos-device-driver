; Open Watcom startup code for DOS 16-bit device drivers
;
; Copyright (C) 2022, Eduardo Casino (mail@eduardocasino.es)
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
; MA  02110-1301, USA.
;

; Assemble with 'WASM -bt=DOS -mt -0'
; Use 'DISABLE 1014' directive with WLINK to suppress warning about missing stack segment
;   Example: WLINK SYSTEM dos DISABLE 1014 NAME mydevice.sys FILE {cstrtsys.o mydevice.o}
;

ATTR_SUBST      equ     08000h
ATTR_CHAR       equ     08000h
ATTR_IOCTL      equ     04000h
ATTR_BLDFAT     equ     02000h
ATTR_REMOTE     equ     01000h
ATTR_EXCALLS    equ     00800h
ATTR_QRYIOCTL   equ     00080h
ATTR_GENIOCTL   equ     00040h
ATTR_RAW        equ     00400h
ATTR_FASTCON    equ     00010h
ATTR_CLOCK      equ     00008h
ATTR_NULL       equ     00004h
ATTR_CONOUT     equ     00002h
ATTR_HUGE       equ     00002h
ATTR_CONIN      equ     00001h

; Device name and attributes. Modify according to your needs
;

DEVICE_NAME     equ     'MYDEVIC$'
DEVICE_ATTR     equ     ATTR_CHAR

; End of user modifiable part

DGROUP  group   _TEXT, _BSS

_BSS    segment word public 'BSS'
        
        public  _small_code_

_small_code_    dw      ?

_BSS    ends   

_TEXT   segment word public 'CODE'

        org     0

_cstart_ label near

        extrn   DeviceStrategy_         : proc
        extrn   DeviceInterrupt_        : proc

        ; Device Header
        ;
        dd      -1                      ; Next device ( -1 == End of list )
        dw      DEVICE_ATTR
        dw      DeviceStrategy_
        dw      DeviceInterrupt_
        db      DEVICE_NAME

_TEXT   ends

        end     _cstart_
