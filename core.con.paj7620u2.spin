{
    --------------------------------------------
    Filename: core.con.paj7620u2.spin
    Author: Jesse Burt
    Description: Low-level constants
    Copyright (c) 2020
    Started May 21, 2020
    Updated May 21, 2020
    See end of file for terms of use.
    --------------------------------------------
}

CON

    I2C_MAX_FREQ        = 400_000               'Change to your device's maximum bus rate, according to its datasheet
    SLAVE_ADDR          = $73 << 1
                                            ' (7-bit format)
    DEVID_RESP          = $7620

' Register definitions
    PARTID_LSB          = $00
    PARTID_MSB          = $01
        PARTID_RESP     = $7620
    VERSION             = $02
        VERSION_RESP    = $01

PUB Null
'' This is not a top-level object
