### T1 — Prediction

T1(a): I predict that the query will return 100,000 rows because the window functions calculate each user's and each movie's average rating.

T1(b): Some ratings will be higher than both the user's average and the movie's average, but if we remove movies with fewer than 20 ratings, the percentages of ratings that meet both conditions might change.

T1(c): The window-function query will return the same results as the original CTE query because both calculate movie ratings relative to their genre's average.