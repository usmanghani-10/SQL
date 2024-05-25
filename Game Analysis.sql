/*1. Extract `P_ID`, `Dev_ID`, `PName`, and `Difficulty_level` of all players at Level 0.*/

select player_details.P_ID as Player_ID,Dev_ID as Device_ID,PName as Player_Name,
Difficulty as Difficulty_level,level
from player_details join level_details2 on player_details.P_ID = level_details2.P_ID 
where Level = 0;


/*2. Find the total number of stages crossed at each difficulty level for Level 2 with players.*/

select count(stages_crossed) as Count_Of_StagesCrossed,Difficulty from level_details2 
where Level = 2
group by Difficulty;


/*3. Find `Level1_code`wise average `Kill_Count` where `lives_earned` is 2,
 and at least 3 stages are crossed.
using `zm_series` devices. Arrange the result in decreasing order of the total number of stages crossed.*/

select L1_code as Level_1_Code,avg(kill_count) as Average_KillCount,sum(Stages_crossed)
 from player_details 
join level_details2 on player_details.P_ID = level_details2.P_ID
where Lives_Earned = 2 and Stages_crossed >= 3 and Dev_ID like "%zm%" 
group by L1_Code,Stages_crossed
order by sum(Stages_crossed) desc;


/*4. Extract `P_ID` and the total number of unique dates
 for those players who have played games on multiple days.*/
 
 select player_details.P_ID as Player_ID,PName as Player_Name, count(TimeStamp) as Unique_Dates
 from player_details
 join level_details2 on player_details.P_ID = level_details2.P_ID
 group by player_details.P_ID,PName
 having count(player_details.P_ID) > 1;
 
 


/* 5. Find `P_ID` and levelwise sum of `kill_counts` where `kill_count`
 is greater than the average kill count for Medium difficulty.*/

select P_ID as Player_ID,sum(Kill_count) as Sum_Of_KillCount from level_details2
where Kill_Count > (select avg(Kill_Count) from level_details2 where Level = "Medium")
group by P_ID;



/*6. Find `Level` and its corresponding `Level_code`wise sum of lives earned, excluding Level
0. Arrange in ascending order of level.*/

select Level,L1_code,L2_code, sum(lives_Earned) as Sum_of_LivesEarned from level_details2 left join player_details
on level_details2.P_ID = player_details.P_ID 
where Level != 0
group by Level,L1_Code,L2_Code
order by Level asc;


/*7. Find the top 3 scores based on each `Dev_ID` and rank them in increasing
 order using `Row_Number`. Display the difficulty as well.*/

With Top_3 as
( select Dev_ID as Device_ID,sum(Score) as Scores from level_details2 
 group by Dev_ID
 order by sum(Score) desc limit 3)
 
 select Device_ID,sum(Scores) from Top_3 
 group by Device_ID
 order by sum(Scores) asc;
 

/*8. Find the `first_login` datetime for each device ID.*/ 

select distinct(Dev_ID) as Device_ID ,MIN(TimeStamp) as First_Login from level_details2
group by Dev_ID; 


/*9. Find the top 5 scores based on each difficulty level and rank them in increasing
 order using `Rank`. Display `Dev_ID` as well.*/
 
WITH Ranked_Scores AS (
    SELECT Dev_ID as Device_ID,Score,Difficulty,
        RANK() OVER (PARTITION BY Difficulty ORDER BY Score DESC) AS Score_Rank
    FROM level_details2 )
SELECT Device_ID,Score,Difficulty,Score_Rank
FROM Ranked_Scores
WHERE Score_Rank <= 5
ORDER BY Difficulty,Score_Rank;



/*10. Find the device ID that is first logged in (based on `start_datetime`) for each player (`P_ID`).
 Output should contain player ID, device ID, and first login datetime.*/
 

    SELECT P_ID, Dev_ID, min(timestamp) as First_login
    FROM level_details2
    group by P_ID,Dev_ID;
    


/*11. For each player and date, determine how many `kill_counts` were played by the player so far.*/
/*a) Using window functions*/

SELECT P_ID, DATE(Timestamp) AS date, SUM(kill_count) 
OVER (PARTITION BY P_ID ORDER BY TimeStamp) AS kill_count
FROM level_details2;

/*b) Without window functions*/

SELECT P1.P_ID, DATE(P1.TimeStamp) AS date, 
       (SELECT SUM(P2.kill_count)
        FROM level_details2 P2
        WHERE P2.P_ID = P1.P_ID AND P2.TimeStamp <= P1.TimeStamp) AS cumulative_kill_count
FROM level_details2 P1;



/*12. Extract the top 3 highest sums of scores for each `Dev_ID` and the corresponding `P_ID`.*/

select P_ID as Player_ID,Dev_ID as Device_ID,sum(Score) from level_details2
group by P_ID,Dev_ID
Order by sum(Score) desc limit 3;

/*13. Find players who scored more than 50% of the average score,
 scored by the sum of scores for each `P_ID`.*/

SELECT P_ID AS Players_ID, sum(Score)
FROM level_details2
GROUP BY P_ID
having sum(Score) > (50/100) * (SELECT AVG(Score) FROM level_details2);




