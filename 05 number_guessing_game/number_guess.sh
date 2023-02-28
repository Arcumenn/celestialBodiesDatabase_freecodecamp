#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET=$(( $RANDOM % 1000 + 1 ))

echo -e "\nEnter your username:"
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
if [[ -z $USER_ID ]]
then
  NCHAR=${#USERNAME}
  if (( $NCHAR > 22 ))
  then
    # echo "The chosen username is too long. Exiting."
    exit 0
  else
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
    ADD_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  fi
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id=$USER_ID")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses." 
fi
echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS
NUMBER_OF_GUESSES=1
while [[ ! $GUESS = $SECRET ]]
do
  if [[ ! $GUESS =~ ^[0-9]+ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
    read GUESS
  elif (( $GUESS > $SECRET ))
  then
    echo -e "\nIt's lower than that, guess again:"
    ((NUMBER_OF_GUESSES=NUMBER_OF_GUESSES+1))
    read GUESS
  else
    echo -e "\nIt's higher than that, guess again:"
    ((NUMBER_OF_GUESSES=NUMBER_OF_GUESSES+1))
    read GUESS
  fi
done 
echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET. Nice job!"
ADD_GAME=$($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")
