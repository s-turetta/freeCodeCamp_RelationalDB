#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ Welcome to Salon ~~~~\n"

MAIN_MENU () {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # Printing services available
  echo "Please select from the services listed"
  echo -e "\n1) Manicure\n2) Pedicure\n3) Waxing\n4) Haircut"

  # Selecting service
  read SERVICE_ID_SELECTED
  
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # Send back to main menu
    MAIN_MENU "Please enter a number"
  else
    QUERY_SERVICE_RESULT=$($PSQL "SELECT * FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    
    if [[ -z $QUERY_SERVICE_RESULT ]]
    then
      MAIN_MENU "Please enter a valid option"
    else
      # Get phone number
      echo -e "\nPlease enter your phone number"
      read CUSTOMER_PHONE
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      
      if [[ -z $CUSTOMER_ID ]]
      then
        echo -e "You are new client. Please enter your name to register:"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      echo -e "\nPlease enter the time for your appointment"
      read SERVICE_TIME
      INSERT_SERVICE_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      SERVICE_NAME_RESULT=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

      echo -e "\nI have put you down for a $SERVICE_NAME_RESULT at $SERVICE_TIME, $CUSTOMER_NAME." | sed -r 's/ +/ /g'

    fi
  fi
}

MAIN_MENU