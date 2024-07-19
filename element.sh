#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

GET_ELEMENT() {
  INPUT="$1"

  JOINED_TABLE="SELECT atomic_number, symbol, name, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements AS e JOIN properties p USING(atomic_number) JOIN types USING(type_id)"

  # Check atomic number
  if [[ $INPUT =~ ^[0-9]+$ ]]; then
    ELEMENT_BY_NUMBER=$($PSQL "$JOINED_TABLE WHERE atomic_number='$INPUT'")
    if [[ -n $ELEMENT_BY_NUMBER ]]; then
      echo "$ELEMENT_BY_NUMBER"
      return
    fi
  else
    # Check symbol
    ELEMENT_BY_SYMBOL=$($PSQL "$JOINED_TABLE WHERE symbol='$INPUT'")
    if [[ -n $ELEMENT_BY_SYMBOL ]]; then
      echo "$ELEMENT_BY_SYMBOL"
      return
    fi

    # Check name
    ELEMENT_BY_NAME=$($PSQL "$JOINED_TABLE WHERE name='$INPUT'")
    if [[ -n $ELEMENT_BY_NAME ]]; then
      echo "$ELEMENT_BY_NAME"
      return
    fi
  fi

  return 1
}

FORMAT() {
echo "$1" | sed 's/ |/"/'
}

GET_TEXT() {
  ELEMENT=$(GET_ELEMENT "$1")  
  if [[ -n $ELEMENT ]]
    then
      echo "$ELEMENT" | while IFS="|" read -r ATOMIC_NUM SYMBOL NAME TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT
      do
        ATOMIC_NUM_FORMATTED=$(FORMAT "$ATOMIC_NUM")
        SYMBOL_FORMATTED=$(FORMAT "$SYMBOL")
        NAME_FORMATTED=$(FORMAT "$NAME")
        TYPE_FORMATTED=$(FORMAT "$TYPE")
        ATOMIC_MASS_FORMATTED=$(FORMAT "$ATOMIC_MASS")
        MELTING_POINT_FORMATTED=$(FORMAT "$MELTING_POINT")
        BOILING_POINT_FORMATTED=$(FORMAT "$BOILING_POINT")
        echo "The element with atomic number $ATOMIC_NUM_FORMATTED is $NAME_FORMATTED ($SYMBOL_FORMATTED). It's a $TYPE, with a mass of $ATOMIC_MASS_FORMATTED amu. $NAME_FORMATTED has a melting point of $MELTING_POINT_FORMATTED celsius and a boiling point of $BOILING_POINT_FORMATTED celsius."
      done
    else
    echo "I could not find that element in the database."
  fi
}

MAIN() {
  if [[ -z $1 ]]; then
    echo "Please provide an element as an argument."
    return
  fi
  GET_TEXT $1
}

MAIN $1
