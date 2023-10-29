#! /bin/bash
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?"

# PSQL connection
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  # print any parameters
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # get list of services
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read ID BAR SERVICE
  do
    echo "$ID) $SERVICE"
  done
  read SERVICE_ID_SELECTED

  # if input is not a number
  #if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  #then
    # send to main menu
  #  MAIN_MENU "I could not find that service. What would you like today?"
  #fi

  # get service id from table
  FIND_SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  FIND_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  #echo "Service found: $FIND_SERVICE_NAME"

  # if not found send to main menu
  if [[ -z $FIND_SERVICE_ID ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # Get phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # find customer
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      #echo $CUSTOMER_NAME

    # if no matching record found by phone number, 
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get name
      echo -e "\n I don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # insert into database
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME' )")

    fi 

    # get a reference to customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # Ask for time
    echo -e "\nWhat time would you like your $FIND_SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # Insert appointment into database
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments( customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $(echo $FIND_SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
  fi

  
}

MAIN_MENU
