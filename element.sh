#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t -c"

if [[ $1 ]]
then
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    QUERY_RESULT=$($PSQL "SELECT atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number=$1")
  else
    if [[ $1 =~ ^[A-Z]$|^[A-Z][a-z]$ ]]
    then
      QUERY_RESULT=$($PSQL "SELECT atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE symbol='$1'")
    else
      QUERY_RESULT=$($PSQL "SELECT atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE name='$1'")
    fi
  fi
  
  if [[ -z $QUERY_RESULT ]]
  then
    echo I could not find that element in the database.
  else
    echo "$QUERY_RESULT" | while read AN BAR SM BAR NM BAR AM BAR MP BAR BP BAR TP
    do
      echo "The element with atomic number $AN is $NM ($SM). It's a $TP, with a mass of $AM amu. $NM has a melting point of $MP celsius and a boiling point of $BP celsius."
    done
  fi

else
  echo Please provide an element as an argument.
fi
