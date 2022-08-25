#
# Template for writing DOS device drivers in Open Watcom C
#
# Copyright (C) 2022, Eduardo Casino (mail@eduardocasino.es)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA  02110-1301, USA.
#

CC = wcc
AS = wasm
LD = wlink
RM = rm -f
CFLAGS  = -0 -bt=dos -ms -q -s -osh -zu 
ASFLAGS = -bt=DOS -zq -mt -0
LDFLAGS = SYSTEM dos DISABLE 1014 OPTION QUIET, STATICS, MAP=mydevice.map

TARGET = mydevice.sys

OBJ =	cstrtsys.obj mydevice.obj

all : $(TARGET)

clean : .SYMBOLIC
	$(RM) $(OBJ) $(TARGET) *.map *.err

$(TARGET) : $(OBJ)
	$(LD) $(LDFLAGS) NAME $(TARGET) FILE {$(OBJ)}

.asm.obj : .AUTODEPEND
	$(AS) $(ASFLAGS) -fo=$@ $<

.c.obj : .AUTODEPEND
	$(CC) $(CFLAGS) -fo=$@ $<
