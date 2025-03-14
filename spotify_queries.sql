CREATE TABLE spotify (
artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
)

-- EDA
SELECT COUNT(*) FROM spotify;
SELECT COUNT(DISTINCT artist) FROM spotify;
SELECT DISTINCT album_type FROM spotify;
SELECT MAX(duration_min) FROM spotify;
SELECT MIN(duration_min) FROM spotify; -- THERE ARE SOME SONGS WITH 0 DURATION
SELECT * FROM spotify WHERE duration_min = 0; --2 RECORDS
DELETE FROM spotify WHERE duration_min = 0;
SELECT DISTINCT channel FROM spotify;
SELECT DISTINCT most_played_on FROM spotify;

-- -----------------------------------------------------------

-- Now start with Data analysis - easy level

--Retrieve the names of all tracks that have more than 1 billion streams.
SELECT * FROM spotify
WHERE stream > 1000000000;

-- List all albums along with their respective artists.
SELECT 
	DISTINCT album,
	artist
FROM spotify;

-- Get the total number of comments for tracks where licensed = TRUE.

SELECT 
	track,
	SUM(comments) total_comments
FROM spotify
WHERE licensed = true
GROUP BY track;
	
-- Find all tracks that belong to the album type single.

SELECT 
	DISTINCT track,
	album_type
FROM spotify
WHERE album_type ILIKE 'single';

-- Count the total number of tracks by each artist.
SELECT * FROM spotify;

SELECT 
	artist,
	COUNT(track) AS total_tracks
FROM spotify
GROUP BY artist;


-- Medium Level questions

-- Calculate the average danceability of tracks in each album.
SELECT 
	album,
	AVG(danceability)
FROM spotify
GROUP BY album
ORDER BY 2 DESC

-- Find the top 5 tracks with the highest energy values.
SELECT
	track,
	MAX(energy) AS energy_values
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
	
-- List all tracks along with their views and likes where official_video = TRUE.
SELECT 
	track,
	SUM(views) AS total_views,
	SUM(likes) AS total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY track;
	
-- For each album, calculate the total views of all associated tracks.
SELECT
	album,
	track,
	SUM(views) AS total_views
FROM spotify
GROUP BY album, track
ORDER BY total_views DESC;


-- Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT * FROM 
(
SELECT 
	track,
	SUM(CASE WHEN most_played_on = 'Spotify' THEN stream ELSE 0 END) AS streamed_on_spotify,
	SUM(CASE WHEN most_played_on = 'Youtube' THEN stream ELSE 0 END) AS streamed_on_youtube
FROM spotify
GROUP BY track
) AS t1
WHERE streamed_on_spotify > streamed_on_youtube
AND streamed_on_youtube != 0;


-- ===================================================================
-- ADVANCE PROBLEMS

Find the top 3 most-viewed tracks for each artist using window functions.
SELECT * FROM (
SELECT 
	artist,
	track,
	SUM(views) AS total_views,
	RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS rank
FROM spotify
GROUP BY artist, track
) AS t1
WHERE rank <= 3


	
--Write a query to find tracks where the liveness score is above the average.
SELECT 
	tracK,
	artist,
	liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify)
ORDER BY liveness DESC


-- Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH album_energy_stats AS (
    SELECT
        album,
        MAX(energy) AS highest_energy,
        MIN(energy) AS lowest_energy
    FROM spotify
    GROUP BY album
)
SELECT 
    album,
    ROUND((highest_energy - lowest_energy)::NUMERIC, 2) AS energy_diff
FROM album_energy_stats;

-- Find tracks where the energy-to-liveness ratio is greater than 1.2.
SELECT 
    track, 
    energy, 
    liveness, 
    (energy / NULLIF(liveness, 0)) AS energy_liveness_ratio
FROM spotify
WHERE (energy / NULLIF(liveness, 0)) > 1.2;

-- Calculate the cumulative sum of likes for tracks ordered by the 
-- number of views, using window functions.

SELECT 
    track,
    SUM(likes) AS total_likes,
    SUM(views) AS total_views,
    SUM(SUM(likes)) OVER(ORDER BY SUM(views) DESC) AS cumulative_likes
FROM spotify
GROUP BY track
ORDER BY total_views DESC;

EXPLAIN ANALYZE -- et 38.97 ms and pt 11.112 ms
SELECT
	artist,
	track,
	views
FROM spotify
WHERE artist = 'Gorillaz'
AND most_played_on = 'Youtube'
ORDER BY stream DESC LIMIT 25

CREATE INDEX artist_index ON spotify (artist);

-- Now Planning Time: 0.678 ms
-- and Execution Time: 0.342 ms