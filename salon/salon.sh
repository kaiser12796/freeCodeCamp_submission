#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n\n~~~~ MY SALON ~~~~\n\n"

MAIN_MENU() {
  if [[ $1 ]]
    then
      echo -e "\n$1"
  fi

  SERVICES_LIST=$($PSQL "SELECT * FROM services")
  echo -e "\n$(echo "$SERVICES_LIST" | sed 's/|/) /')"
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-3]$ ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
      #on valid input ask for phone number
      else 
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE
        PHONE_RESULT=$($PSQL "SELECT * FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        
        #if no customer with entered phone number add new customer
        if [[ -z $PHONE_RESULT ]]
          then
            echo -e "\nI don't have a record for that phone number, what's your name?"
            read CUSTOMER_NAME
            ADD_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
        fi
        # get customer id and name from db
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

        #get time
        echo -e "\nAt what time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
        read SERVICE_TIME
        
        #insert appointement
        INSERT_APP_RESULT=$($PSQL "INSERT INTO appointments(time,customer_id,service_id) VALUES('$SERVICE_TIME','$CUSTOMER_ID','$SERVICE_ID_SELECTED')")
        
        #output success msg
        
        echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi 
}

MAIN_MENU "Welcome to My Salon, how can I help you?"
