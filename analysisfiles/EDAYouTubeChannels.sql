create database youtube_analytics;

show databases;

use youtube_analytics;

# Table to append the data of youtubers extracted using python 

create table if not exists youtube_channel_data (
    Channel_Name varchar(255),
    Subscribers int,
    TotalVideos int,
    Views int,
    playlist_id varchar(50)
);

select * from youtube_channel_data;


# Range of Subscribers of Youtubers
select min(Subscribers) as MinSubscribers,  max(Subscribers) as MaxSubscribers 
from youtube_channel_data;

# Range ofTotal Videos Posted
select min(TotalVideos) as MinVideos,  max(TotalVideos) as MaxVideos 
from youtube_channel_data;

# Range of Views 
select concat(round(min(Views)/1000000,0),' M') as MinViews,  concat(round(max(Views)/1000000,0),' M') as MaxViews 
from youtube_channel_data;

# Codebasics Channel Details 
select * 
from youtube_channel_data
where Channel_Name = 'codebasics';

# Here the playlsist id is the id which contains all the videos uploaded by the particular Channel . 


# Stored Procedure to get channel details of any channel

DELIMITER $ 
CREATE DEFINER=`root`@`localhost` PROCEDURE `channelssummary`(Par_Channel_Name VARCHAR(255))
BEGIN
	if exists (select distinct Channel_Name from youtube_channel_data where Channel_Name = Par_Channel_Name ) 
    then
	SELECT *
    FROM youtube_channel_data
    WHERE Channel_Name = Par_Channel_Name;
    else 
	select 'Invalid Channel_Name' as Message;
    end if;
END
DELIMITER ; 

call channelssummary('How to Power BI');

# Which Youtuber has highest number of Subscribers ?
select * 
from youtube_channel_data
where Subscribers = 
(select max(Subscribers)
from youtube_channel_data); 

# Which Youtuber has lowest number of Subscribers ?

select * 
from youtube_channel_data
where Subscribers = 
(select min(Subscribers)
from youtube_channel_data); 

# Ranking the channels based on the subscriber rank and stored procedure to pass rank dynamically 

DELIMITER $
CREATE DEFINER=`root`@`localhost` PROCEDURE `channeldetailsbysubscribersrank`(par_rank int)
BEGIN
    IF EXISTS (
        SELECT rankbysubribers FROM (
            SELECT *,
                DENSE_RANK() OVER (ORDER BY subscribers DESC) AS rankbysubribers
            FROM youtube_channel_data
        ) AS cte
        WHERE rankbysubribers = par_rank
    ) THEN
        SELECT *
        FROM (
            SELECT *,
                DENSE_RANK() OVER (ORDER BY subscribers DESC) AS rankbysubribers
            FROM youtube_channel_data
        ) AS cte
        WHERE rankbysubribers = par_rank;
    ELSE
        SELECT 'Input rank within 10' AS Message;
    END IF;
END
DELIMITER ;

call youtube_analytics.channeldetailsbysubscribersrank(2);



# Which Youtuber has uploaded highest number of videos ?

select * 
from youtube_channel_data
where TotalVideos = 
(select max(TotalVideos)
from youtube_channel_data); 

# Which Youtuber has uploaded lowest number of videos ?

select * 
from youtube_channel_data
where TotalVideos = 
(select min(TotalVideos)
from youtube_channel_data); 

# Which Youtuber has got highest number of views ?

select * 
from youtube_channel_data
where views = 
(select max(views)
from youtube_channel_data); 

# Which Youtuber has got lowest number of  views ?

select * 
from youtube_channel_data
where views = 
(select min(views)
from youtube_channel_data); 

# Which youtuber has got second highest views 

with cte as (
select *,
dense_rank() over(order by views desc) as rankbyviews
from youtube_channel_data)
select *
from cte 
where rankbyviews = 2;


# Stored Procedure to get details of the channel names based on the sunscribers count rank 

with cte as (
select *,
dense_rank() over(order by views desc) as rankbyviews
from youtube_channel_data)
select *
from cte 
where rankbyviews = 2;


# Creating the table to append the video details of top 5 youtubers based on reach 
create table if not exists videos_data (
    VideoTitle varchar(255),
    Published_date date,
    Views int,
    Likes int,
    Comments int,
    Month varchar(50)
);

select * 
from videos_data;

# exploring the range of values for data validation 
alter table videos_data 
drop column Month;

select distinct Channel_Name 
from videos_data;

# range of values of every columns in dataset 
select min(Views) as MinViews,  max(Views) as MaxViews 
from videos_data;

select * 
from videos_data
where Views = 0;

select min(Likes) as MinLikes,  max(Likes) as MaxLikes
from videos_data;

select * 
from videos_data
where Likes = 0;

select min(Comments) as MinComments,  max(Comments) as MaxComments
from videos_data;

select * 
from videos_data
where Comments = 0;

select * from videos_data;

select min(Views) as MinViews,  max(Views) as MaxViews, round(avg(Views),0) as AvgViews
from videos_data
where Channel_Name = 'codebasics';

# video with minimum view of particular youtube channel
select *
from videos_data
where Channel_Name = 'codebasics' 
and Views = 
(select min(Views) from videos_data
where Channel_Name = 'codebasics');

# View of codebasics video with maximum views 
create view maximumviewsofcodebasics as
select *
from videos_data
where Channel_Name = 'codebasics' 
and Views = 
(select max(Views) from videos_data
where Channel_Name = 'codebasics');

select * from maximumviewsofcodebasics;

select * from videos_data;

# Top 10 Viewed Videos of codebasics

with cte as(
select *,
dense_rank() over(order by Views desc) as videos_rank
from videos_data
where Channel_Name = 'codebasics')
select VideoTitle
from cte 
limit 10;

# bottom 10  Videos of codebasics by views

with cte as(
select *,
dense_rank() over(order by Views ) as videos_rank
from videos_data
where Channel_Name = 'codebasics')
select VideoTitle
from cte 
limit 10;

# stored Procedure to get top 10 videos of channel by views, Takes channel name as input

DELIMITER $

CREATE DEFINER=`root`@`localhost` PROCEDURE `videosrankbychannels`(Par_Channel_Name varchar(50))
BEGIN
if exists (select distinct Channel_Name from videos_data where Channel_Name = Par_Channel_Name)
then
with cte as (
select *,
dense_rank() over(order by Views desc) as videos_rank
from videos_data
where Channel_Name = Par_Channel_Name)
select VideoTitle
from cte 
limit 10;
else 
select 'Invalid Channel Name' as Message;
end if;
END
DELIMITER ;

call youtube_analytics.videosrankbychannels('techTFQ');

# Number of videos posted codebasics by channel by year

select year(Published_date) , count(VideoTitle) as numberofvideos
from videos_data
where Channel_Name = 'codebasics'
group by year(Published_date)
order by numberofvideos desc;

set sql_mode = ' ' ; 

# Number of videos posted and views they have go by codebasics by channel by year and month

select year(Published_date) as Year, monthname(Published_date) as MonthName, count(VideoTitle) as numberofvideos, sum(Views) as totalviews
from videos_data
where Channel_Name = 'codebasics' 
group by Year, MonthName
order by Year desc, month(Published_date);

# To filter the data as per out requirement using cte

with cte as (
select year(Published_date) as Year, monthname(Published_date) as MonthName, count(VideoTitle) as numberofvideos, sum(Views) as totalviews
from videos_data
where Channel_Name = 'Krish Naik' 
group by Year, MonthName
order by Year desc, month(Published_date))
select *
from cte 
where MonthName = 'January' or MonthName = 'December'
order by Year desc, MonthName;










