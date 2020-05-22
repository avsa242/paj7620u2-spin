{
    --------------------------------------------
    Filename: input.gesture.paj7620u2.i2c.spin
    Author: Jesse Burt
    Description: Driver for PAJ6520U2 Gesture Sensor
    Copyright (c) 2020
    Started May 21, 2020
    Updated May 22, 2020
    See end of file for terms of use.
    --------------------------------------------
}

CON

    SLAVE_WR            = core#SLAVE_ADDR
    SLAVE_RD            = core#SLAVE_ADDR|1

    DEF_SCL             = 28
    DEF_SDA             = 29
    DEF_HZ              = 100_000
    I2C_MAX_FREQ        = core#I2C_MAX_FREQ

    REACTION_TIME       = 200
    ENTRY_TIME          = 400
    QUIT_TIME           = 800

    RIGHT               = 1
    LEFT                = 2
    UP                  = 3
    DOWN                = 4
    FORWARD             = 5
    BACKWARD            = 6
    CLOCKWISE           = 7
    CCLOCKWISE          = 8
    WAVE                = 9

VAR


OBJ

    i2c : "com.i2c"
    core: "core.con.paj7620u2.spin"
    time: "time"

PUB Null
''This is not a top-level object

PUB Start: okay                                                 'Default to "standard" Propeller I2C pins and 400kHz

    okay := Startx (DEF_SCL, DEF_SDA, DEF_HZ)

PUB Startx(SCL_PIN, SDA_PIN, I2C_HZ): okay

    if lookdown(SCL_PIN: 0..31) and lookdown(SDA_PIN: 0..31)
        if I2C_HZ =< core#I2C_MAX_FREQ
            if okay := i2c.setupx (SCL_PIN, SDA_PIN, I2C_HZ)    'I2C Object Started?
                time.MSleep (1)
'                if i2c.present (SLAVE_WR)                       'Response from device?
                    if DeviceID == core#DEVID_RESP
                        return okay

    return FALSE                                                'If we got here, something went wrong

PUB Stop
' Put any other housekeeping code here required/recommended by your device before shutting down
    i2c.terminate

PUB Defaults
' Set factory defaults

PUB DeviceID
' Read device identification
    readReg(core#PARTID_LSB, 2, @result)

PUB Interrupt
' Flag indicating one or more interrupts have asserted
    readReg(core#INTFLAG_1, 2, @result)

PUB LastGesture | tmp

    case Interrupt
        core#FLAG_RIGHT:
            time.msleep(ENTRY_TIME)
            case Interrupt
                core#FLAG_FORWARD:
                    time.msleep(QUIT_TIME)
                    return FORWARD
                core#FLAG_BACKWARD:
                    time.msleep(QUIT_TIME)
                    return BACKWARD
                OTHER:
                    return RIGHT

        core#FLAG_LEFT:
            time.msleep(ENTRY_TIME)
            case Interrupt
                core#FLAG_FORWARD:
                    time.msleep(QUIT_TIME)
                    return FORWARD
                core#FLAG_BACKWARD:
                    time.msleep(QUIT_TIME)
                    return BACKWARD
                OTHER:
                    return LEFT

        core#FLAG_UP:
            time.msleep(ENTRY_TIME)
            case Interrupt
                core#FLAG_FORWARD:
                    time.msleep(QUIT_TIME)
                    return FORWARD
                core#FLAG_BACKWARD:
                    time.msleep(QUIT_TIME)
                    return BACKWARD
                OTHER:
                    return UP

        core#FLAG_DOWN:
            time.msleep(ENTRY_TIME)
            case Interrupt
                core#FLAG_FORWARD:
                    time.msleep(QUIT_TIME)
                    return FORWARD
                core#FLAG_BACKWARD:
                    time.msleep(QUIT_TIME)
                    return BACKWARD
                OTHER:
                    return DOWN

        core#FLAG_FORWARD:
            time.msleep(QUIT_TIME)
            return FORWARD

        core#FLAG_BACKWARD:
            time.msleep(QUIT_TIME)
            return BACKWARD

        core#FLAG_CLOCKWISE:
            return FORWARD

        core#FLAG_CCLOCKWISE:
            return FORWARD

        OTHER: ' FLAG_WAVE
            return WAVE

PUB Reset | tmp
' Reset the device
    tmp := $01
    writeReg(core#R_REGBANK_RESET, 1, @tmp)

PRI readReg(reg, nr_bytes, buff_addr) | cmd_packet, tmp
'' Read num_bytes from the slave device into the address stored in buff_addr
    case reg
        $000..$003, $032..$03F, $040..$052, $054..$05F, $060, $061, $063..$06C, $080..$089, $08B..$09D, $09F..$0A5, $0A9, $0AA..$0DF, $0EE, $0EF:
            cmd_packet.byte[0] := SLAVE_WR
            cmd_packet.byte[1] := reg

            i2c.start
            i2c.wr_block (@cmd_packet, 2)
            i2c.start
            i2c.write (SLAVE_RD)
            i2c.rd_block (buff_addr, nr_bytes, TRUE)
            i2c.stop
            return

        $100..$104, $125..$129, $130..$135, $142, $144, $165..$16F, $171..$174, $17F:
            cmd_packet.byte[0] := SLAVE_WR
            cmd_packet.byte[1] := core#REGBANKSEL
            cmd_packet.byte[2] := 1
            cmd_packet.byte[3] := reg

            i2c.start
            i2c.wr_block (@cmd_packet, 4)
            i2c.start
            i2c.write (SLAVE_RD)
            i2c.rd_block (buff_addr, nr_bytes, TRUE)
            i2c.stop
            return

        OTHER:
            return

PRI writeReg(reg, nr_bytes, buff_addr) | cmd_packet, tmp
'' Write num_bytes to the slave device from the address stored in buff_addr
    case reg                                                    'Basic register validation
        $003, $032..$03A, $03F, $040..$042, $046..$052, $05C..$05F, $061, $063..$06A, $080..$089, $08B..$09D, $09F..$0A5, $0A9, $0AA, $0AB, $0CC..$0D2, $0EE, $0EF:
            cmd_packet.byte[0] := SLAVE_WR
            cmd_packet.byte[1] := reg

            i2c.start
            i2c.wr_block (@cmd_packet, 2)
            repeat tmp from 0 to nr_bytes-1
                i2c.write (byte[buff_addr][tmp])
            i2c.stop
            return

        $100..$104, $125..$129, $130..$135, $142, $144, $165..$16F, $171..$174, $17F, $1EF:
            cmd_packet.byte[0] := SLAVE_WR
            cmd_packet.byte[1] := core#REGBANKSEL
            cmd_packet.byte[2] := 1
            cmd_packet.byte[3] := reg

            i2c.start
            i2c.wr_block (@cmd_packet, 4)
            repeat tmp from 0 to nr_bytes-1
                i2c.write (byte[buff_addr][tmp])
            i2c.stop
            return

        OTHER:
            return

DAT
{
    --------------------------------------------------------------------------------------------------------
    TERMS OF USE: MIT License

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
    associated documentation files (the "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
    following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial
    portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
    LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    --------------------------------------------------------------------------------------------------------
}
