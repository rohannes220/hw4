-- T1b. How many ratings are above BOTH the user's mean and the movie's mean?
-- Required columns (one row):
--   n_ratings, n_above_both, share_above_both, share_above_both_20plus
-- share_above_both_20plus: the same share, counting only ratings of movies
-- that have at least 20 ratings.
-- Build on T1a in a CTE; filter or count outside it.
    --
    -- Prediction (commit before running): share_above_both is about ______.

    -- YOUR QUERY HERE
with averages as (
   select user_id,
          movie_id,
          rating,
          avg(rating)
          over(partition by user_id) as user_mean,
          avg(rating)
          over(partition by movie_id) as movie_mean,
          count(*)
          over(partition by movie_id) as movie_count
     from ratings
),above_both as (
   select *
     from averages
    where rating > user_mean
      and rating > movie_mean
)
select (
   select count(*)
     from above_both
) as n_above_both,
       (
          select count(*)
            from averages
       ) as n_ratings,
       (
          select count(*) * 1.0
            from above_both
       ) / (
          select count(*)
            from averages
       ) as share_above_both,
       (
          select count(*) * 1.0
            from above_both
           where movie_count >= 20
       ) / (
          select count(*)
            from averages
           where movie_count >= 20
       ) as share_above_both_20plus;