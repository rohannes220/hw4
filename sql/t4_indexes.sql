-- T4. At most TWO CREATE INDEX statements, chosen for the four app queries
-- in run.py (A_profile, B_movie_page, C_recent, D_month). run.py applies them to a
-- copy of the database and measures plans, time and size before and after.
--
-- Prediction (commit before running), for each app query:
--   plan before: ______    plan after: ______

-- YOUR INDEXES HERE
-- Index 1: Find a movie's ratings and average rating
create index idx_movie_rating on
   ratings (
      movie_id,
      rating
   );

-- Index 2: Find ratings based on timestamp
create index idx_timestamp on
   ratings (
      timestamp
   );