# paj7620u2-spin 
----------------

This is a P8X32A/Propeller driver object for the PAJ7620U2 Gesture Sensor

## Salient Features

* I2C connection at up to 400kHz
* Recognizes all 9 gestures supported by sensor (Up, Down, Left, Right, Forward, Backward, Clockwise, Counter-clockwise, Wave)
*

## Requirements

* 1 extra core/cog for the PASM I2C engine

## Compiler Compatibility

* P1/SPIN1: OpenSpin (tested with 1.00.81)

## Limitations

* Very early in development - may malfunction, or outright fail to build
* Detection reliability of forward and backward gestures requires some "debouncing" - this adds a noticeable delay in detection

## TODO

- [ ] Port to SPIN2
