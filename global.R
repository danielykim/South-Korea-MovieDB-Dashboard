# 이 파일을 반드시 UTF-8 인코딩으로 여시길 바랍니다.
# Please open this file with UTF-8 encoding
#
# 파일의 인코딩을 다음과 같이 바꿀 수 있습니다. (RStudio 1.0.136 기준)
# You can change text encoding like the following (RStudio 1.0.136)
#   File -> Reopen with Encoding -> UTF-8
#
# 아래의 순서로 다음에 열 때도 기본 인코딩을 UTF-8로 유지할 수 있습니다. (RStudio 1.0.136 기준)
# You can change your RStudio default text encoding setting (RStudio 1.0.136)
#   Tools -> Global Options -> Code -> Saving -> Default text encoding: -> UTF-8

options(warn = -1)    # Ignore warning messages
options(Encoding = "UTF-8")

# 실행 전에 아래 `setwd` 코드 괄호 안의 내용을 수정하여 Working Directory를 이 R 코드 파일이 있는 폴더로 변경하시길 바랍니다.
# 아래 명령어 대신 다음과 같이 Working Directory를 변경할 수 있습니다. 이 경우에는 아래 코드를 주석처리하시길 바랍니다.
# 1. 오른쪽 아래 창 "..." 을 클릭하여 이 R 코드 파일이 있는 폴더로 이동합니다.
# 2.  More -> Set As Working Directory  이렇게하여 Working Directory를 변경합니다.


# 아래 코드 중에서 library 괄호 안에 있는 패키지 중에서 하나라도 없으면, 다음과 같은 메시지가 아래 Console에 나타날 것입니다.
# If you do not have one of the below packages, you will see a message like the following in the Console:
#   Error in library(DT) : there is no package called ‘DT’
# 여기에서 DT는 아직 설치하지 않은 패키지입니다.
# where  ‘DT’  is a R package that you do not install yet.
# 설치하지 않은 다른 패키지들의 경우에도 Console에 마찬가지 메시지가 나타날 것입니다.
# For other packages you do not install, you will see same messages as well.
# 필요한 패키지들을 한번에 설치하려면, 다음과 같은 명령을 아래 Console에 그대로 입력하여 실행하시길 바랍니다.
# If you want to install all the required packages at once, please run the following command in the Console.
#   install.packages( c('tidyr', 'dplyr', 'shiny', 'shinydashboard', 'DT', 'sparkline', 'XLConnect', 'ggplot2', 'plotly') )
library(dplyr)    # 데이터 변형하기 For data wrangling

library(shiny)
library(shinydashboard)

library(DT)    # 대화형 표 다루기 For interactive tables
library(data.table)

# For sparkline (htmlwidgets >= 0.8)
# CRAN sparkline: https://cran.r-project.org/web/packages/sparkline/index.html
# CRAN htmlwidgets: https://cran.r-project.org/web/packages/htmlwidgets/index.html
#library(sparkline)

library(readr)
library(readxl)

library(ggplot2)    # 그래프 그리기 For plotting charts
library(plotly)    # 그래프 그리기 For plotting charts


df_movie <- read_excel("data/South_Korea_Box_office_2017-05-05-2004-201705.xlsx")

dfSeriesDaily <- read.csv('data/movie_time_series_sequential.csv')

df_movie$ReleaseDate <- as.Date(df_movie$ReleaseDate, format="%Y-%m-%d")

# DT에 sparkline 나타내기 위한 데이터 만들기
# Construct sparkline data
# See also
#   http://rstudio.github.io/DT/
# df_movie$Sparkline <- character(length(df_movie$MovieID))
# 
# for (i in 1:length(df_movie$Sparkline)) {
#   tmp <- dfSeriesDaily %>% filter(MovieID == df_movie$MovieID[i])
# 
#   df_movie$Sparkline[i] <- paste(tmp$Audiences, collapse = ',')
# }


# https://www.r-bloggers.com/select-operations-on-r-data-frames/
df_movie2 <- df_movie[,c('Title', 'Genre', 'RunningTime', 'Grade', 'ReleaseDate', 
                         'Sales', 'Audiences', 'Screens', 'Plays', 'MajorNationality', 
                         'Agency')]
colnames(df_movie2) <- c('제목', '장르', '상영시간(분)', '관람등급', '개봉일',
                         '매출액(원)', '관객수', '상영관수', '상영횟수', '주 제작국',
                         '배급사')

# 사이드 바 메뉴의 하위 메뉴인 `자세히 보기`와 `예측치와 함께 보기`를 클릭하면 영화 목록이 나타납니다.
# 여기에서 영화 제목을 선택했을 때 내부 처리를 위해 아래 두 줄 코드를 통해 ID와 맞춥니다.
movieChoice <- df_movie$MovieID
names(movieChoice) <- df_movie$Title


df_actor <- read_excel('data/actor_meta_info-1000.xlsx')

actorChoice <- df_actor$ActorID
names(actorChoice) <- df_actor$Name


df_actor_releaseDate_Title <- read_excel('data/actor_movieReleaseDate_movieTitle.xlsx')
df_actor_releaseDate_Title$ReleaseDate <- as.Date(df_actor_releaseDate_Title$ReleaseDate, format = "%Y-%m-%d")
df_actor_movies <- df_actor_releaseDate_Title %>% group_by(ActorID) %>% summarise(Movies = n())
df_actor <- left_join(df_actor, df_actor_movies)    # http://stat545.com/bit001_dplyr-cheatsheet.html

df_actor_genre_count <- read_excel('data/actor_genre_count.xls')


df_actor2 <- df_actor[,c('Name','Movies','TotalAudiences')]
colnames(df_actor2) <- c('이름','출연작 수','총 관객 수')