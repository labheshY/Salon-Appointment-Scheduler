#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c" 
echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWELCOME TO MY Salon,how can I help you?\n"
MAIN_MENU(){
 if [[ $1 ]]
  then 
    echo -e "\n$1"
  fi
  # get services
  SERVICES=$($PSQL "SELECT service_id,name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do 
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  #if not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    #send to main menu
    MAIN_MENU "!INVALID INPUT, SELECT A NUMBER"
  else
    #get available service name
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    #check avilable service
    if [[ -z $SERVICE_NAME ]]
    then
      #send to main menu
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      #get customer number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      #if not found
      if [[ -z $CUSTOMER_NAME ]]
      then
        #get customer name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        #insert new customer and phone number
        INSERT_INTO_CUSTOMER=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
      fi
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      #ask appointment time
      echo -e "\nWhat time would you like your$SERVICE_NAME,$CUSTOMER_NAME?"
      read SERVICE_TIME 
      #get customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      #insert appointment
      INSERT_INTO_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
      echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."
    fi
  fi 

}
MAIN_MENU