;Initializes the VIA's for joystick reading
.import __joy_init

;Checks joystick input and handles any pressed buttons using
;the macro handlers defined in this file.
.import __joy_handle

.scope joy
        init   = __joy_init
        handle = __joy_handle
.endscope
