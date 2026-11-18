### T1 — Prediction

T1(a): I predict that the query will return 100,000 rows because the window functions calculate each user's and each movie's average rating.

T1(b): Some ratings will be higher than both the user's average and the movie's average, but if we remove movies with fewer than 20 ratings, the percentages of ratings that meet both conditions might change.

T1(c): The window-function query will return the same results as the original CTE query because both calculate movie ratings relative to their genre's average.

## Task 2 — Predictions

T2a — ROW_NUMBER(): Each occupation will have up to three movies in the results. If two movies have the same average rating, ROW_NUMBER() will still give them different ranks.

T2b — RANK(): RANK() may return more movies than ROW_NUMBER() because movies with the same average rating can share a rank.

## Task 2 — Results and Explanation

ROW_NUMBER() vs. RANK():

The ROW_NUMBER() query returned 27 rows, compared to 28 rows from RANK(). This difference happens because ROW_NUMBER() gives every movie a unique position, while RANK() allows movies with the same average rating to share a position. As a result, RANK() can include additional movies when there is a tie for third place.

Occupations with fewer than three movies:

Executive and technician were the two occupations with fewer than three qualifying movies. Additionally, 11 occupations had no qualifying movies because no movies received at least 20 ratings from users in those occupations.

Which would I use for a recommendation page?

For a "top picks for your profession" page, I would choose ROW_NUMBER() because it limits the results to three movies per occupation. Using this method would make it easier to display a consistent number of recommendations whenever enough movies qualify.

When would DENSE_RANK() be better?

I would use DENSE_RANK() to show movies with the top three different average ratings, including ties. Unlike ROW_NUMBER(), it gives tied movies the same rank, and unlike RANK(), it does not skip ranking numbers. This makes it useful when we want to include all ties without skipping any rating levels.

## Task 3 — Predictions

**T3a — Sessions:**

I predict that the query will group each user's ratings into sessions based on the time between ratings. If the gap is greater than 30 minutes, a new session will begin. 

**T3b — Running Average:**

ROWS and the default RANGE frame will produce different averages for some ratings that share the same timestamp. ROWS calculates the average one rating at a time, while RANGE includes all ratings with the same timestamp together. 

## Task 3 — Results and Explanation

**T3a — Sessions:**

The query identified 2,793 sessions across 943 users, with a median of 11 ratings per session. Removing ROWS should not change the results because ratings with identical timestamps belong to the same session. 

**T3b — Running Average:**

ROWS and RANGE produced different averages for 49,787 rows, all of which shared timestamps with other ratings. ROWS processes ratings individually, while RANGE includes ratings with the same timestamp together. Unlike T3a's session flags, individual ratings can change the average.

### T4 — Explanation

**A_profile:** Already uses an index on `(user_id, movie_id)` to find a user's ratings. However, SQLite needs a temporary B-tree to sort the ratings by timestamp.

**B_movie_page:** Initially scans the table. Our new index on `(movie_id, rating)` helps SQLite find a movie's ratings and calculate the average.

**C_recent:** Initially scans the table. Our timestamp index allows SQLite to search for ratings after a certain date.

**D_month:** Remains a SCAN because `strftime()` converts every timestamp into a month. The timestamp index cannot directly search using this conversion.

### D_month Rewrite

The original query checks every rating to see which month it belongs to.

The rewritten query searches between two timestamps, such as February 1 and March 1. This allows SQLite to use the timestamp index instead of scanning every rating.

The rewrite did not change my index choices because the timestamp index helps both C_recent and the rewritten D_month.

## T4 — Results and Explanations

### Actual Results

| Query | Before (ms) | After (ms) |
|---|---:|---:|
| A_profile | 0.059 | 0.059 |
| B_movie_page | 2.873 | 0.008 |
| C_recent | 2.787 | 0.019 |
| D_month | 18.887 | 17.475 |
| D_rewrite | 3.618 | 0.213 |

### Explanation

**A_profile:** Already uses an index on `(user_id, movie_id)` to find a user's ratings. SQLite uses a temporary B-tree to sort the ratings by timestamp. Its execution time stayed at 0.059 ms.

**B_movie_page:** Changed from SCAN to SEARCH using the `(movie_id, rating)` index. Its execution time improved from 2.873 ms to 0.008 ms.

**C_recent:** Changed from SCAN to SEARCH using the timestamp index. Its execution time improved from 2.787 ms to 0.019 ms.

**D_month:** Remains a SCAN because `strftime()` converts timestamps into months. SQLite cannot directly search by month using the timestamp index. Its execution time changed from 18.887 ms to 17.475 ms.

### D_month Rewrite

The original query checks every rating to see which month it belongs to. The rewritten query searches between two timestamps, such as February 1 and March 1. This allows SQLite to use the timestamp index instead of scanning every rating.

The rewritten query improved from 3.618 ms to 0.213 ms.

The rewrite did not change my index choices because the timestamp index helps both C_recent and the rewritten D_month.

### Index Storage

Before adding the indexes, the database size was 3,629,056 bytes. After adding the indexes, it increased to 6,168,576 bytes.

The two indexes used an additional **2,539,520 bytes** of storage.

This shows that indexes can improve query performance but also increase database storage requirements.

---

## T5 — Index Recommendation

I recommend adding two indexes: `(movie_id, rating)` and `(timestamp)`.

The first index helps the database find ratings for a particular movie and calculate its average. Our results show that B_movie_page improved from 2.873 milliseconds to 0.008 milliseconds.

The second index helps the database find ratings within a certain time period. C_recent improved from 2.787 milliseconds to 0.019 milliseconds. It also helps the rewritten monthly query, which improved from 3.618 milliseconds to 0.213 milliseconds.

One risk of adding indexes is increased database storage. Our two indexes added 2,539,520 bytes. Indexes also require maintenance when new ratings are inserted or existing ratings are updated, which can slow down those operations.

