-- T2 (version 1, ROW_NUMBER). The three highest-rated movies for each
-- occupation, among movies rated at least 20 times by users with that occupation.
-- Required columns: occupation, pos, movie_id, title, n, mean_rating
-- Order the window so that the result is the same on every run (state your
-- tie-breaker in WRITEUP.md).
--
-- Prediction (commit before running): ______ rows.

-- YOUR QUERY HERE
with movie_averages as (
   select u.occupation,
          r.movie_id,
          avg(r.rating) as movie_mean,
          count(*) as rating_count
     from ratings r
     join users u
   on r.user_id = u.user_id
    group by u.occupation,
             r.movie_id
   having count(*) >= 20
),ranked_movies as (
   select occupation,
          movie_id,
          movie_mean,
          rating_count,
          row_number()
          over(partition by occupation
               order by movie_mean desc,
                        movie_id asc
          ) as movie_rank
     from movie_averages
)
select *
  from ranked_movies
 where movie_rank <= 3;