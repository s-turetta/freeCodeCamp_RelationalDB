#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo Enter your username:
  read USERNAME
  USERNAME_LENGTH=${#USERNAME}

  if [[ $USERNAME_LENGTH -le 22 ]]
  then
    USERNAME_QUERY_RESULT=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")
    
    if [[ -z $USERNAME_QUERY_RESULT ]]
    then
      echo Welcome, $USERNAME! It looks like this is your first time here.
      USER_INSERT_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 0)")
    else
      echo $USERNAME_QUERY_RESULT | while read GAMES_PLAYED BAR BEST_GAME
      do
        echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
      done
    fi

    NUMBER_TO_GUESS=$(($RANDOM % 1000 + 1))
    echo $NUMBER_TO_GUESS
    TRIES=0
    echo Guess the secret number between 1 and 1000:
    PLAY_GAME

  else
    MAIN_MENU "Username should be maximun 22 characters"
  fi

}

PLAY_GAME() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  read USER_GUESS

  if [[ $USER_GUESS =~ ^[0-9]+$ ]]
  then
    TRIES=$((TRIES+1))
    if [[ $USER_GUESS -eq $NUMBER_TO_GUESS ]]
    then
      echo You guessed it in $TRIES tries. The secret number was $NUMBER_TO_GUESS. Nice job!
      FINISH_GAME
    elif [[ $USER_GUESS -lt $NUMBER_TO_GUESS ]]
    then
      PLAY_GAME "It's higher than that, guess again:"
    else
      PLAY_GAME "It's lower than that, guess again:"
    fi
  else
    PLAY_GAME "That is not an integer, guess again:"
  fi

}

FINISH_GAME() {
  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$USERNAME'")

  if [[ $BEST_GAME -eq 0 || $TRIES -lt $BEST_GAME ]]
  then
    UPDATE_BEST_RESULT=$($PSQL "UPDATE users SET best_game=$TRIES WHERE username='$USERNAME'")
  fi

  
  
}

MAIN_MENU