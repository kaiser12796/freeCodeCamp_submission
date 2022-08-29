#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS

do
  if [[ $WINNER != "winner" ]]
    then
      #get team id
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      #if not found
      if [[ -z $TEAM_ID ]]
        then
          #insert team
          INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')")
          : 'if [[ $INSERT_WINNER=="INSERT 0 1" ]]
            then
              echo Inserted into teams: $WINNER
          fi '
      fi
      #get new team id
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  fi  

  if [[ $OPPONENT != "opponent" ]]
    then
      #get team id
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

      #if not found
      if [[ -z $TEAM_ID ]]
        then
          #insert team 
          INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")
          : 'if [[ $INSERT_OPPONENT=="INSERT 0 1" ]]
            then
              echo Inserted into teams: $OPPONENT
          fi '
      fi
      #get new team id
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  fi

  #get game id
  if [[ $YEAR != "year" ]]
    then
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

      #if not found
      if [[ -z $WINNER_ID || -z $OPPONENT_ID ]]
        then
          WINNER_ID=null
          OPPONENT_ID=null
      fi     
      #insert game
      INSERT_GAME=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
      : 'if [[ $INSERT_GAME == "INSERT 0 1" ]]
        then
          echo Inserted into games: $ROUND $WINNER $OPPONENT
      fi '
  fi
done