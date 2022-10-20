#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))

GET_NAME() {
  if [[ $1 ]]
    then
      echo -e "\n$1"
      read USER_NAME
      NAME_LENGTH=${#USER_NAME}
      if (( $NAME_LENGTH > 22 ))
        then
          GET_NAME "Please enter a username with up to 22 characters length:"
          read USER_NAME
      fi
  fi
}

CHECK_NUMBER(){
  if [[ $1 ]]
    then
      echo -e "\n$1"
      read NUMBER
      if [[ $NUMBER =~ ^[0-9]+$ ]]
        then
          ((NUMBER_OF_GUESSES+=1))
          if [[ $NUMBER -gt $SECRET_NUMBER ]]
            then
              CHECK_NUMBER "It's lower than that, guess again:"
              elif [[ $NUMBER -lt $SECRET_NUMBER ]]
                then
                  CHECK_NUMBER "It's higher than that, guess again:"
                  else
                    echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
                    INSERT_GAME=$($PSQL "INSERT INTO games(user_id,number_of_guesses) VALUES ($USER_ID,$NUMBER_OF_GUESSES)")
          fi
          else
            CHECK_NUMBER "That is not an integer, guess again:"
      fi
  fi
}

GET_NAME "Enter your username:"

#get user_id
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USER_NAME'")

#welcome new and returned users
if [[ -z $USER_ID ]]
  then
    #if no user_id found, add new user to table users
    echo -e "\nWelcome, $USER_NAME! It looks like this is your first time here."
    ADD_USER=$($PSQL "INSERT INTO users(name) VALUES('$USER_NAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USER_NAME'")
    else
      #if user_id is found, reply with user statistics
      NUMBER_OF_GAMES=$($PSQL "SELECT COUNT(game_id) FROM users u JOIN games g ON u.user_id = g.user_id WHERE u.user_id = $USER_ID")
      USER_HIGHSCORE=$($PSQL "SELECT MIN(number_of_guesses) FROM users u JOIN games g ON u.user_id = g.user_id WHERE u.user_id = $USER_ID")
      echo -e "\nWelcome back, $USER_NAME! You have played $NUMBER_OF_GAMES games, and your best game took $USER_HIGHSCORE guesses."
fi

#start new game
NUMBER_OF_GUESSES=0
CHECK_NUMBER "Guess the secret number between 1 and 1000:"

