-- T2 (version 2, RANK). The same question, with RANK() ordered by mean_rating
-- only, keeping rows with pos <= 3.
-- Required columns: occupation, pos, movie_id, title, n, mean_rating
--
-- Prediction (commit before running): ______ rows, which is (more / the same / fewer)
-- than version 1, because ______.

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
          rank()
          over(partition by occupation
               order by movie_mean desc
          ) as movie_rank
     from movie_averages
)
select *
  from ranked_movies
 where movie_rank <= 3;