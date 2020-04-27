;Checks joystick input and handles any pressed buttons using
;the macro handlers defined in this file.
.import __joy_handle
.import __joy_poll

.scope joy
        handle = __joy_handle
	poll   = __joy_poll
.endscope
