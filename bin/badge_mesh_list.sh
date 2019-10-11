#!/bin/bash
# This file is part of DEF CON 27 Blue Team Village Badge
# https://fyrmassociates.com/BTVbadge

avahi-browse -atrpl -d P14U70 | grep = |  sed 's/;/ /g' | grep -v '\"' | awk '{print $8, $7}' | sed 's/\.P14U70//g'
