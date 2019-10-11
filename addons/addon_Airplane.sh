#!/bin/bash

clear
array_of_quotes=("I haven't felt this awful since we saw that Ronald Reagan film." "Looks like I picked the wrong week to quit drinking." "i just wanted to say good luck and we're all counting on you" "I am serious, and don't call me Shirley." 'Joey, have you ever been in a turkish prison?' 'roger, Roger' 'Ok give me Hamm on 5 and hold the Mayo' 'There is no reason to become alarmed, and we hope you will enjoy the rest of your flight. By the way, is there anyone on board who knows how to fly a plane?')

#find a random number
randomNumber=$(shuf -i 0-7 -n 1)
#chooses the winning drink
selectedQuote=${array_of_quotes[randomNumber]}

figlet -w 40 -c -f term ${selectedQuote}
echo
echo
echo
echo
echo
