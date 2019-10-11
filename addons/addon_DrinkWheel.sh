#!/bin/bash

clear
array_of_drinks=('Fuzzy_Navel' 'Iced_Tea' 'Linux' 'Arnold_Palmer' 'Red_Bull' 'Tequila' 'Water' 'Beer' 'Wine' 'Whiskey_Sour' 'Gin&Tonic' 'Vodka&Cran' 'Rum&Coke' 'Bourbon' 'Scotch' 'JACKPOT' 'White_Rabbit' 'Sangria' 'Mimosa' 'Old_Fashion' 'Margarita' 'Moscow_Mule' 'Espresso_Martini' 'Manhattan' 'Daiquiri' 'Negroni')
array_of_phrases=("Yell... 'What should I drink?!'" 'Ask the human to your left' 'Go have what she is having (find the nearest female human)' 'Go find Jeff at the Blue Team Village and ask him.' '01001000 01101111 01100110 01100010 01110010 01100001 01110101 01101000 01100001 01110101 01110011 00100000' 'Buy a drink for someone with a BTV badge and chat. Dont forget to make friends with your badges!' "Find Matt at the Blue Team Village and ask him if he wants to be in 'da club." 'Ask someone with a BTV badge to flip a coin for you. Heads is Vodka. Tails is Vodka.')

drink_wheel=()
for count in $(seq 1 8); do
	drink_to_add=(${array_of_drinks[$RANDOM % ${#array_of_drinks[@]}]})
	drink_wheel+=($drink_to_add)
	temp_array=()
	for value in "${array_of_drinks[@]}"; do
		[[ $value != $drink_to_add ]] && temp_array+=($value)
	done
	array_of_drinks=("${temp_array[@]}")
	unset temp_array
done

#chooses the random number that will be the index for the winning drink
randomNumber=$(shuf -i 0-7 -n 1)
#chooses the winning drink
selecteddrink=${drink_wheel[randomNumber]}

clear
#set the initial X and Y coordinates where the first drink will be printed
colX=32
lineY=14
maxCol=40
#for loop to go through each selected drink
for i in "${!drink_wheel[@]}"; do
	drinkNameLength="${#drink_wheel[$i]}" #determine drink name length
	totalUsedSpace=$((colX+drinkNameLength)) #total space it will occupy from where it starts on X + the drink name length
	spaceLeft=$((maxCol-totalUsedSpace)) #total space left from the maxCol available subtracted by total used space calculated above
  if [ "$lineY" -ge 0 ]; then
    if [ "$colX" -eq 26 -a "$lineY" -ge 2 ]; then #This if will print the a drink item for LED 4
			if [ "$spaceLeft" -lt 0 ]; then #if there won't be any space left it will cut the drink into two parts for better presentation
				case "${drink_wheel[$i]}" in
					*'&'*)
						firstCutValueOfDrinkName="$(cut -d'&' -f1 <<<"${drink_wheel[$i]}")"
						secondCutValueOfDrinkName="$(cut -d'&' -f2 <<<"${drink_wheel[$i]}")"
						tput cup "$lineY" "$colX" ; echo "$firstCutValueOfDrinkName"
						tput cup $((lineY+1)) "$colX" ; echo "&${secondCutValueOfDrinkName}"
						((colX-=18))
						;;
					*'_'*)
						firstCutValueOfDrinkName="$(cut -d'_' -f1 <<<"${drink_wheel[$i]}")"
						secondCutValueOfDrinkName="$(cut -d'_' -f2 <<<"${drink_wheel[$i]}")"
						tput cup "$lineY" "$colX" ; echo "$firstCutValueOfDrinkName"
						tput cup $((lineY+1)) "$colX" ; echo "${secondCutValueOfDrinkName}"
						((colX-=18))
						;;
					*)
						tput cup "$lineY" $((colX+spaceLeft)) ; echo "${drink_wheel[$i]}" | tr _ ' '
						((lineY-=4))
						((colX-=2))
				esac
			else # if there is space left, just outputs the drinkname
      	tput cup "$lineY" "$colX" ; echo "${drink_wheel[$i]}" | tr _ ' '
      	((colX-=18))
			fi
    elif [ "$colX" -eq 8 -a "$lineY" -eq 2 ]; then #This elif will print the a drink item for LED 5
			if [ "$spaceLeft" -lt 0 ]; then #if there won't be any space left it will cut the drink into two parts for better presentation
				case "${drink_wheel[$i]}" in
					*'&'*)
						firstCutValueOfDrinkName="$(cut -d'&' -f1 <<<"${drink_wheel[$i]}")"
						secondCutValueOfDrinkName="$(cut -d'&' -f2 <<<"${drink_wheel[$i]}")"
						tput cup "$lineY" "$colX" ; echo "$firstCutValueOfDrinkName"
						tput cup $((lineY+1)) "$colX" ; echo "&${secondCutValueOfDrinkName}"
						((colX-=2))
						((lineY+=4))
						;;
					*'_'*)
						firstCutValueOfDrinkName="$(cut -d'_' -f1 <<<"${drink_wheel[$i]}")"
						secondCutValueOfDrinkName="$(cut -d'_' -f2 <<<"${drink_wheel[$i]}")"
						tput cup "$lineY" "$colX" ; echo "$firstCutValueOfDrinkName"
						tput cup $((lineY+1)) "$colX" ; echo "${secondCutValueOfDrinkName}"
						((colX-=2))
						((lineY+=4))
						;;
					*)
						tput cup "$lineY" $((colX+spaceLeft)) ; echo "${drink_wheel[$i]}" | tr _ ' '
						((lineY-=4))
						((colX-=2))
				esac
			else # if there is space left, just outputs the drinkname
      	tput cup "$lineY" "$colX" ; echo "${drink_wheel[$i]}" | tr _ ' '
      	((colX-=2))
      	((lineY+=4))
			fi
    elif [ "$colX" -le 8 -a "$lineY" -ge 6 ]; then #This elif will print the last 3 drink items for LED 6,7,8.
			if [ "$spaceLeft" -lt 0 ]; then #if there won't be any space left it will cut the drink into two parts for better presentation
				case "${drink_wheel[$i]}" in
					*'&'*)
						firstCutValueOfDrinkName="$(cut -d'&' -f1 <<<"${drink_wheel[$i]}")"
						secondCutValueOfDrinkName="$(cut -d'&' -f2 <<<"${drink_wheel[$i]}")"
						tput cup "$lineY" "$colX" ; echo "$firstCutValueOfDrinkName"
						tput cup $((lineY+1)) "$colX" ; echo "&${secondCutValueOfDrinkName}"
						((colX-=2))
						((lineY+=4))
						;;
					*'_'*)
						firstCutValueOfDrinkName="$(cut -d'_' -f1 <<<"${drink_wheel[$i]}")"
						secondCutValueOfDrinkName="$(cut -d'_' -f2 <<<"${drink_wheel[$i]}")"
						tput cup "$lineY" "$colX" ; echo "$firstCutValueOfDrinkName"
						tput cup $((lineY+1)) "$colX" ; echo "${secondCutValueOfDrinkName}"
						((colX-=2))
						((lineY+=4))
						;;
					*)
						tput cup "$lineY" $((colX+spaceLeft)) ; echo "${drink_wheel[$i]}" | tr _ ' '
						((lineY-=4))
						((colX-=2))
				esac
			else #if there is space left, just outputs the drinkname
      	tput cup "$lineY" "$colX" ; echo "${drink_wheel[$i]}" | tr _ ' '
      	((colX-=2))
      	((lineY+=4))
			fi
    else #This else will print the first 3 drink items for LED 1,2,3.
			if [ "$spaceLeft" -lt 0 ]; then #if there won't be any space left it will cut the drink into two parts for better presentation
				case "${drink_wheel[$i]}" in
					*'&'*)
						firstCutValueOfDrinkName="$(cut -d'&' -f1 <<<"${drink_wheel[$i]}")"
						secondCutValueOfDrinkName="$(cut -d'&' -f2 <<<"${drink_wheel[$i]}")"
						tput cup "$lineY" "$colX" ; echo "$firstCutValueOfDrinkName"
						tput cup $((lineY+1)) "$colX" ; echo "&${secondCutValueOfDrinkName}"
						((lineY-=4))
						((colX-=2))
						;;
					*'_'*)
						firstCutValueOfDrinkName="$(cut -d'_' -f1 <<<"${drink_wheel[$i]}")"
						secondCutValueOfDrinkName="$(cut -d'_' -f2 <<<"${drink_wheel[$i]}")"
						tput cup "$lineY" "$colX" ; echo "$firstCutValueOfDrinkName"
						tput cup $((lineY+1)) "$colX" ; echo "${secondCutValueOfDrinkName}"
						((lineY-=4))
						((colX-=2))
						;;
					*)
						tput cup "$lineY" $((colX+spaceLeft)) ; echo "${drink_wheel[$i]}" | tr _ ' '
						((lineY-=4))
						((colX-=2))
				esac
			else # if there is space left, just outputs the drinkname
      	tput cup "$lineY" "$colX" ; echo "${drink_wheel[$i]}" | tr _ ' '
      	((lineY-=4))
      	((colX-=2))
			fi
    fi
  else
    echo "Just grab a drink would yah!!!" #This shouldnt ever be called unless someone messes with the initial Y value
  fi
done

#spin the LED wheel
ledNumber=$((randomNumber + 1))
python /badge/addons/DrinkWheel.py $ledNumber
wait
clear
if [ "$selecteddrink" = 'JACKPOT' ]; then
	randomNetworkingPhrase=${array_of_phrases[randomNumber]}
	tput cup 2 0
	figlet -w 40 -c -f term ${randomNetworkingPhrase}
	echo
	echo
	figlet -w 40 -c -f term "Please Hack and Drink Responsibily."
	echo
	echo
	wait
	tput sgr0
else
	if [ "$selecteddrink" = 'Linux' ]; then
		tput cup 2 0
		figlet -w 40 -c -f future ${selecteddrink}
		echo
		echo
		figlet -w 40 -c -f term "1 1/3oz Vodka"
		figlet -w 40 -c -f term "1 1/3oz Cointreau"
		figlet -w 40 -c -f term "Lime Juice"
		figlet -w 40 -c -f term "Coca Cola"
		echo
		echo
		figlet -w 40 -c -f term "Please Hack and Drink Responsibily."
	elif [ "$selecteddrink" = 'White_Rabbit' ]; then
		tput cup 2 0
		figlet -w 40 -c -f future ${selecteddrink}
		echo
		echo
		figlet -w 40 -c -f term "3oz Vodka"
		figlet -w 40 -c -f term "3oz Vanilla Liquer"
		figlet -w 40 -c -f term "1oz milk"
		figlet -w 40 -c -f term "1oz ice"
		echo
		echo
		figlet -w 40 -c -f term "Please Hack and Drink Responsibily."
	else
		tput cup 2 0
		figlet -w 40 -c -f future ${selecteddrink}
		echo
		echo
		figlet -w 40 -c -f term "Please Hack and Drink Responsibily."
		echo
		echo
		tput sgr0
	fi
fi
