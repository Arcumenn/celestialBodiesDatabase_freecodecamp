#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\nWelcome to my humble salon! What do you need done?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  # get list of servives
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  # format services
  echo "$SERVICES" | sed -E 's/ \|/\)/'
  # read input
  read SERVICE_ID_SELECTED
  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  # go back when something else than a number is given as input
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] || [[ -z $SERVICE ]]
  then
    MAIN_MENU "That is either not a number or not one of the options in the lists. Please enter the number of one of the available service."
  else
    echo -e "\nWhat is your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nAh you are a new customer. What is your name?"
      read CUSTOMER_NAME
      SAVE_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi
    echo -e "\nWhen should we schedule your appointment?"
    read SERVICE_TIME
    ADD_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $(echo $SERVICE | sed -E s'/^ //') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E s'/^ //')."
  fi
}

MAIN_MENU