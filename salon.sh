#! /bin/bash

# Connect to the database and get the services list
PSQL="psql -X --username=postgres --dbname=salon --tuples-only --no-align -c"

# Function to display services
display_services() {
  echo "$($PSQL "SELECT service_id, name FROM services")" | while IFS="|" read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

# Prompt for service_id
while [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
do
  echo -e "\nPlease select a service:"
  display_services
  read SERVICE_ID_SELECTED
done

# Prompt for customer phone number
echo -e "\nEnter your phone number:"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

# If customer doesn't exist, get name and insert
if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nEnter your name:"
  read CUSTOMER_NAME
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi

# Prompt for service time
echo -e "\nEnter the time for your appointment:"
read SERVICE_TIME

# Get customer_id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

# Insert appointment
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

# Get service name
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

# Output confirmation
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
