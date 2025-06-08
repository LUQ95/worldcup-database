#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE games, teams")

tail -n +2 games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER != "name" ]]
  then
    # Get winner team_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name ='$WINNER'")
    # If not found, insert winner
    if [[ -z $WINNER_ID ]]
    then
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name ='$WINNER'")
    fi

      # get new winner_id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name ='$WINNER'")
    
    # Get opponent team_id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name ='$OPPONENT'")
    # If not found, insert opponent
    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name ='$OPPONENT'")
    fi

    # get new opponent_id
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name ='$OPPONENT'")
  fi

  if [[ $YEAR != "year" ]]
  then
    # Insert game
    if [[ -n $WINNER_ID && -n $OPPONENT_ID ]]
    then
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
      if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted into games: $YEAR, $ROUND, $WINNER_GOALS, $OPPONENT_GOALS"
      fi
    else
      echo "Error: Missing team IDs for $WINNER vs $OPPONENT in $YEAR $ROUND"
    fi
  fi
done