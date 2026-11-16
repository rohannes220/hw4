-- T3. Rating sessions. A user's ratings form one session until there is a gap
-- of more than 1800 seconds (30 minutes) since that user's previous rating.
-- Required columns, one row per session:
--   user_id, session_no, n_ratings, start_ts, duration_s
-- session_no counts 1, 2, 3, ... within each user, in time order.
-- Suggested steps (one CTE each): gap with LAG; a 0/1 new_session flag;
-- a running SUM of the flag with an explicit ROWS frame; GROUP BY.
--
-- Prediction (commit before running): median ratings per session = ______.

-- YOUR QUERY HERE
with gaps as (
   select user_id,
          timestamp,
          lag(timestamp)
          over(partition by user_id
               order by timestamp
          ) as prev_time
     from ratings
),flags as (
   select user_id,
          timestamp,
          case
             when prev_time is null
                 or timestamp - prev_time > 1800 then
                1
             else
                0
          end as new_session
     from gaps
),sessions as (
   select user_id,
          timestamp,
          sum(new_session)
          over(partition by user_id
               order by timestamp
             rows unbounded preceding
          ) as session_num
     from flags
)
select user_id,
       session_num as session_no,
       count(*) as n_ratings,
       min(timestamp) as start_time,
       max(timestamp) - min(timestamp) as duration
  from sessions
 group by user_id,
          session_num
 order by user_id,
          session_num;