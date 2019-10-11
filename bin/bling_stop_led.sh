#!/bin/bash

source /badge/bin/badge_vars.sh

ledpid=$(pgrep -f "python /badge/bin/bling_led_shiftreg.py .*")
eval kill $ledpid $SUPPRESS
$P/bling_led_shiftreg.py cleanup $SUPPRESS &
