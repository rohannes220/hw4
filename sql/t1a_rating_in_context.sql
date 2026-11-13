-- T1a. Every rating next to its user's mean and its movie's mean.
-- Required columns: user_id, movie_id, rating, user_mean, movie_mean
-- One query, no join, no GROUP BY.
--
-- Prediction (commit before running): this query returns 100000 rows, because there are 100000 ratings in the ratings table.

-- YOUR QUERY HERE
select user_id,
       movie_id,
       rating,
       avg(rating)
       over(partition by user_id) as user_mean,
       avg(rating)
       over(partition by movie_id) as movie_mean
  from ratings;