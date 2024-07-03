#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_INFO=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")
if [[ -z $USER_INFO ]]
then
 echo "Welcome, $USERNAME! It looks like this is your first time here."
 INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  IFS='|' read -r USER_ID GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
USER_INFO=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")
IFS='|' read -r USER_ID GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
SECRET_NUMBER=$((RANDOM % 1000 + 1))
echo "Guess the secret number between 1 and 1000:"
GUESSES=0
((GAMES_PLAYED++))
while true; do
  read GUESS
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
    ((GUESSES++))
  elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
    ((GUESSES++))
  else
    ((GUESSES++))
    echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
done

UPDATE_GAMES_TABLE=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESSES)")
UPDATE_USERS_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE user_id = $USER_ID")
UPDATE_USERS_BEST_GAME=$($PSQL "UPDATE users SET best_game=(SELECT MIN(guesses) FROM games WHERE user_id = $USER_ID) WHERE user_id = $USER_ID")