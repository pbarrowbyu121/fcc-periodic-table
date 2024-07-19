#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# rename weight to atomic_mass
$PSQL "ALTER TABLE properties RENAME COLUMN weight TO atomic_mass"

# rename melting_point to meltin_point_celsius
$PSQL "ALTER TABLE properties RENAME COLUMN melting_point TO melting_point_celsius"
$PSQL "ALTER TABLE properties RENAME COLUMN boiling_point TO boiling_point_celsius"

# melting_point_celsius and boiling_point_celsius should not accept null
$PSQL "ALTER TABLE properties ALTER COLUMN melting_point_celsius SET NOT NULL"
$PSQL "ALTER TABLE properties ALTER COLUMN boiling_point_celsius SET NOT NULL"

# add unique to symbol and name in elements
$PSQL "ALTER TABLE elements ADD CONSTRAINT unique_symbol UNIQUE(symbol)"
$PSQL "ALTER TABLE elements ADD CONSTRAINT unique_name UNIQUE(name)"

# symbol and name should be not null
$PSQL "ALTER TABLE elements ALTER COLUMN symbol SET NOT NULL"
$PSQL "ALTER TABLE elements ALTER COLUMN name SET NOT NULL"

# foreign key atomic_number in properties to elements
$PSQL "ALTER TABLE properties ADD FOREIGN KEY(atomic_number) REFERENCES elements(atomic_number)"

# create types table
$PSQL "CREATE TABLE types()"
$PSQL "ALTER TABLE types ADD COLUMN type_id SERIAL PRIMARY KEY"
$PSQL "ALTER TABLE types ADD COLUMN type VARCHAR NOT NULL"
$PSQL "INSERT INTO types(type) VALUES('metal'), ('metalloid'), ('nonmetal')"

# properties table with type_id foreign key
$PSQL "ALTER TABLE properties ADD COLUMN type_id INT"
$PSQL "UPDATE properties SET type_id=(SELECT type_id FROM types WHERE types.type = properties.type)"
$PSQL "ALTER TABLE properties ADD FOREIGN KEY (type_id) REFERENCES types(type_id)"
$PSQL "ALTER TABLE properties ALTER COLUMN type_id SET NOT NULL"
$PSQL "ALTER TABLE properties DROP COLUMN type"

# remove 1000
$PSQL "DELETE FROM properties WHERE atomic_number=1000"
$PSQL "DELETE FROM elements WHERE atomic_number=1000"

# capitalize symbol in elements
CAPITALIZE_FIRST_LETTER() {
  echo "$1" | sed 's/^\(.\)/\U\1/'
}

SYMBOLS=$($PSQL "SELECT symbol FROM elements")
echo "$SYMBOLS" | while read SYMBOL
do
  UPPER_CASE=$(CAPITALIZE_FIRST_LETTER "$SYMBOL")  
  $PSQL "UPDATE elements SET symbol='$UPPER_CASE' WHERE symbol='$SYMBOL'" 
done

# remove trailing zeros from atomic mass
$PSQL "ALTER TABLE properties ALTER COLUMN atomic_mass TYPE FLOAT USING atomic_mass::FLOAT;"
REMOVE_TRAILING_ZEROS() {
  echo "$1" | sed -e 's/0*$//' -e 's/\.$/.0/'
}
ATOMIC_MASSES=$($PSQL "SELECT atomic_mass, atomic_number FROM properties")
echo "$ATOMIC_MASSES" | while IFS='|' read MASS ATOMIC_NUMBER
do
  ADJUSTED=$(REMOVE_TRAILING_ZEROS $MASS)    
  $PSQL "UPDATE properties SET atomic_mass='$ADJUSTED' WHERE atomic_number='$ATOMIC_NUMBER'" 
done

# # add Flourine
$PSQL "INSERT INTO elements(atomic_number, symbol, name) VALUES(9, 'F', 'Fluorine')"
$PSQL "INSERT INTO properties(atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id) 
VALUES(9, 18.998, -220, -188.1, 3)"

# add Neon
$PSQL "INSERT INTO elements(atomic_number, symbol, name) VALUES(10, 'Ne', 'Neon')"
$PSQL "INSERT INTO 
properties(
atomic_number, 
atomic_mass, 
melting_point_celsius, 
boiling_point_celsius, 
type_id) 
VALUES(
10, 
20.18, 
-248.6, 
-246.1, 
3)"