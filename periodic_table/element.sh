#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"

if [[ -z $1 ]]
  then
    echo "Please provide an element as an argument."
  else
    ITEM_FOUND=false
    #is argument an integer?
    if [[ $1 =~ ^[0-9]+$ ]]
      then
        CHECK_INTEGER=true
      else
        CHECK_INTEGER=false
    fi

    if [[ $CHECK_INTEGER = true ]]
      then
        #check for atomic number entered
        ATOMIC_NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$1")
        if [[ $ATOMIC_NAME ]]
          then
            ATOMIC_NUMBER=$1
            ITEM_FOUND=true
        fi
      else
        #check if input = valid symbol
        ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1'")
        if [[ $ATOMIC_NUMBER ]]
          then
            ITEM_FOUND=true
          else
            #check if input = valid name
            ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$1'")
            if [[ $ATOMIC_NUMBER ]]
              then
                ITEM_FOUND=true
            fi
        fi
    fi

    if [[ $ITEM_FOUND = false ]]
      then
        echo "I could not find that element in the database."
      else
        SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
        NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
        MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
        MELT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
        BOIL=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
        TYPE=$($PSQL "SELECT t.type FROM properties p JOIN types t ON p.type_id=t.type_id WHERE atomic_number=$ATOMIC_NUMBER")
        echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
    fi
fi