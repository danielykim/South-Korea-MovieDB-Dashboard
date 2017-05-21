#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

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


# 실행 전에 아래 `setwd` 코드 괄호 안의 내용을 수정하여 Working Directory를 이 R 코드 파일이 있는 폴더로 변경하시길 바랍니다.
# 아래 명령어 대신 다음과 같이 Working Directory를 변경할 수 있습니다. 이 경우에는 아래 코드를 주석처리하시길 바랍니다.
# 1. 오른쪽 아래 창 "..." 을 클릭하여 이 R 코드 파일이 있는 폴더로 이동합니다.
# 2.  More -> Set As Working Directory  이렇게하여 Working Directory를 변경합니다.
library(DT)


values <- reactiveValues()
values$movieID <- 20129370
values$actorID <- 10050151

# Define server logic
shinyServer(function(input, output, session) {
  
  ## set up input menu in sidebar
  output$selectMovie <- renderUI({
    if (input$sbMenu == "movie_detail") {
      inputPanel(
        selectInput(
          "movieA",
          label    = "영화 제목 입력 및 선택",
          choices  = movieChoice,
          selected = 20129370
        )
      )
    }
  })
  
  
  output$selectActor <- renderUI({
    if (input$sbMenu == "actor_detail") {
      inputPanel(
        selectInput(
          "actorA",
          label    = "배우 이름 입력 및 선택",
          choices  = actorChoice,
          selected = 10050151
        )
      )
    }
  })
  
  
  ## Movie at a glance
  ### https://rpubs.com/jkaupp/sparkline-ex
  line_string <- "width:80, height:40, type: 'line', lineColor: '#333', fillColor: '#ccc', highlightLineColor: 'orange', highlightSpotColor: 'orange'"
  
  ## column definition for sparklines
  ### `targets = n`:  n-th column.
  # cd <- list(
  #   list(
  #     targets = 11,
  #     render  = JS("function(data, type, full){ return '<span class=\"movieSparkLine\">' + data + '</span>' }")
  #   )
  # )
  
  ## callback
  # cb <- JS(
  #   paste0(
  #     "function (oSettings, json) {\n  $('.movieSparkLine:not(:has(canvas))').sparkline('html', { ", 
  #     line_string, 
  #     " });\n}"), 
  #   collapse = ""
  # )
  
  ## Render "at a glance interactive table" with sparklines
  output$movieDataTable <- renderDataTable({
    dt <- datatable(
      df_movie2,
      rownames = FALSE, 
      options  = list(
        # columnDefs     = cd, 
        # fnDrawCallback = cb
      )
    )
  })
  
  
  ## For `movie_glance` and `movie_detail`
  observeEvent(input$movieA, {
    values$movieID <- input$movieA
  })

  observeEvent(input$actorA, {
    values$actorID <- input$actorA
  })
  
  
  ## 선택한 영화의 시계열 데이터 추출 및 변형
  ## data wrangling
  movieGlanceData <- reactive({
    req(input$movieA)
    
    basic_info <- df_movie %>% 
      filter(MovieID == input$movieA)

    series <- dfSeriesDaily %>% 
      filter(MovieID == input$movieA)
    
    info = list(basic_info = basic_info,
                series     = series)
    
    return(info)
  })
  
  actorGlanceData <- reactive({
    req(input$actorA)
    
    basic_info <- df_actor %>% 
      filter(ActorID == input$actorA)
    
    series <- read_csv(
      paste0('data/actor-time_series-2/', input$actorA, '.csv'), 
      col_types = cols(
        Date = col_date(format = "%Y%m%d"),
        Audiences = col_integer()
      )
    )
    
    movies <- df_actor_releaseDate_Title %>% filter(ActorID == input$actorA)
    movies <- movies[order(movies$ReleaseDate),]
    
    idx <- 2
    
    for (i in 2:length(series$Date)) {
      if ( idx <= length(movies$ReleaseDate) & (series$Date[i] == movies$ReleaseDate[idx]) ) {
        series$Audiences[i-1] <- 1
        idx <- idx + 1
      }
    }
    
    series <- series %>% filter(Audiences > 0)
    
    genres <- df_actor_genre_count %>% filter(ActorID == input$actorA)
    genres <- genres[colnames(genres) != "ActorID"]
    
    info = list(basic_info = basic_info,
                series     = series,
                movies     = movies,
                genres     = genres)
    
    return(info)
  })
  
    
  ## Movie detail
  ### Movie detail: Movie title
  output$thumbnail <- renderImage({
    filename <- paste('./www/thumbnails/', input$movieA, '.jpg', sep='')
    list(src = filename, height=350)
  }, deleteFile = FALSE)
  
  output$movieTitleBox <- renderInfoBox({
    infoBox(
      "영화 제목", 
      movieGlanceData()$basic_info$Title,
      icon  = icon("film"),
      color = "light-blue"
    )
  })
  
  output$movieGenreBox <- renderInfoBox({
    infoBox(
      "장르", 
      movieGlanceData()$basic_info$Genre,
      icon  = icon("tags"),
      color = "light-blue"
    )
  })

  output$movieRunningTimeBox <- renderInfoBox({
    infoBox(
      "상영시간", 
      paste0(movieGlanceData()$basic_info$RunningTime, "분"),
      icon  = icon("play"),
      color = "light-blue"
    )
  })

  output$movieGradeBox <- renderInfoBox({
    infoBox(
      "등급",
      as.character(movieGlanceData()$basic_info$Grade),
      icon  = icon("user"),
      color = "light-blue"
    )
  })
  
  ### Movie detail: Agency title
  output$movieAgencyBox <- renderInfoBox({
    infoBox(
      "배급사", 
      movieGlanceData()$basic_info$Agency,
      icon  = icon("globe"),
      color = "light-blue"
    )
  })
  
  ### Movie detail: Release date
  output$movieReleaseDateBox <- renderInfoBox({
    infoBox(
      "개봉일",
      format(movieGlanceData()$basic_info$ReleaseDate, format = "%Y-%m-%d"),
      icon  = icon("calendar"),
      color = "light-blue"
    )
  })

  output$movieSalesBox <- renderInfoBox({
    infoBox(
      "매출",
      paste0(prettyNum(movieGlanceData()$basic_info$Sales, big.mark = ",", scientific=FALSE),"원"),
      icon  = icon("thumbs-up"),
      color = "light-blue"
    )
  })
  
  output$movieAudiencesBox <- renderInfoBox({
    infoBox(
      "관객수",
      paste0(prettyNum(movieGlanceData()$basic_info$Audiences, big.mark = ",", scientific=FALSE),"명"),
      icon  = icon("user"),
      color = "light-blue"
    )
  })
  
  # output$movieScreensBox <- renderInfoBox({
  #   infoBox(
  #     "상영관수",
  #     paste0(movieGlanceData()$basic_info$Screens,"개"),
  #     icon  = icon("home"),
  #     color = "light-blue"
  #   )
  # })
  # 
  # output$moviePlaysBox <- renderInfoBox({
  #   infoBox(
  #     "상영횟수",
  #     paste0(movieGlanceData()$basic_info$Plays,"번"),
  #     icon  = icon("play"),
  #     color = "light-blue"
  #   )
  # })
  
  
  ## Draw sales quantity time series data without forecast
  output$movieDetailSeriesPlot <- renderPlotly({
    # https://plot.ly/r/shiny-coupled-hover-events/
    # https://plot.ly/r/range-slider/
    
    movieGlanceData_series <- movieGlanceData()$series
    
    plot_ly(
      movieGlanceData_series,
      x = as.Date(
        as.character(movieGlanceData_series$Date),
        format = "%Y%m%d"
      ),
      y = movieGlanceData_series$Audiences,
      type  = 'scatter', 
      mode  = 'lines') %>%
      
      layout(
        title = "",
        paper_bgcolor = 'rgb(255,255,255)', 
        plot_bgcolor  = 'rgb(229,229,229)',
        xaxis = list(
          title     = "날짜",
          gridcolor = 'rgb(255,255,255)',
          tickcolor = 'rgb(127,127,127)',
          ticks     = 'outside',
          showgrid  = TRUE,
          showline  = FALSE,
          zeroline  = FALSE,
          showticklabels = TRUE,
          rangeselector  = list(
            buttons = list(
              list(
                count    = 1,
                label    = "1개월 보기",
                step     = "month",
                stepmode = "backward"),
              list(
                count    = 1,
                label    = "1년 보기",
                step     = "year",
                stepmode = "backward"),
              list(
                label = "모두 보기",
                step  = "all"
              )
            )
          ),
          rangeslider = list(type = "date")
        ),
        yaxis = list(
          title          = "관객수",
          gridcolor      = 'rgb(255,255,255)',
          tickcolor      = 'rgb(127,127,127)',
          ticks          = 'outside',
          showgrid       = TRUE,
          showline       = FALSE,
          zeroline       = FALSE,
          showticklabels = TRUE
        )
      )
    
  })
  
  
  output$actorDataTable <- renderDataTable({
    dt <- datatable(
      df_actor2,
      rownames = FALSE, 
      options  = list(
        # columnDefs     = cd, 
        # fnDrawCallback = cb
      )
    )
  })
  
  
  output$actorNameBox <- renderInfoBox({
    infoBox(
      "배우 이름",
      actorGlanceData()$basic_info$Name,
      icon  = icon("user"),
      color = "light-blue"
    )
  })
  
  # output$actorBirthDateBox <- renderInfoBox({
  #   infoBox(
  #     "생년월일",
  #     actorGlanceData()$basic_info$BirthDate,
  #     icon  = icon("calendar"),
  #     color = "light-blue"
  #   )
  # })

  output$actorMoviesBox <- renderInfoBox({
    infoBox(
      "작품 수",
      paste0(prettyNum(actorGlanceData()$basic_info$Movies, big.mark = ",", scientific=FALSE),' 개'),
      icon  = icon("film"),
      color = "light-blue"
    )
  })
    
  output$actorTotalAudiencesBox <- renderInfoBox({
    infoBox(
      "총 관객수",
      paste0(prettyNum(actorGlanceData()$basic_info$TotalAudiences, big.mark = ",", scientific=FALSE),' 명'),
      icon  = icon("user"),
      color = "light-blue"
    )
  })
  
  ## Draw sales quantity time series data without forecast
  output$actorAudienceSeriesPlot <- renderPlotly({
    # https://plot.ly/r/shiny-coupled-hover-events/
    # https://plot.ly/r/range-slider/
    actorGlanceData_tmp <- actorGlanceData()
    actorGlanceData_movies <- actorGlanceData_tmp$movies
    actorGlanceData_series <- actorGlanceData_tmp$series
    
    ay_list <- runif(length(actorGlanceData_movies$ReleaseDate))*80-120
    
    plot_ly(
      actorGlanceData_series,
      x = ~Date,
      y = ~Audiences,
      type  = 'scatter', 
      mode  = 'lines') %>%
      
      layout(
        title = "",
        paper_bgcolor = 'rgb(255,255,255)', 
        plot_bgcolor  = 'rgb(229,229,229)',
        xaxis = list(
          title     = "날짜",
          gridcolor = 'rgb(255,255,255)',
          tickcolor = 'rgb(127,127,127)',
          ticks     = 'outside',
          showgrid  = TRUE,
          showline  = FALSE,
          zeroline  = FALSE,
          showticklabels = TRUE,
          rangeselector  = list(
            buttons = list(
              list(
                count    = 1,
                label    = "1개월 보기",
                step     = "month",
                stepmode = "backward"),
              list(
                count    = 3,
                label    = "3개월 보기",
                step     = "month",
                stepmode = "backward"),
              list(
                count    = 6,
                label    = "6개월 보기",
                step     = "month",
                stepmode = "backward"),
              list(
                count    = 1,
                label    = "1년 보기",
                step     = "year",
                stepmode = "backward"),
              list(
                count    = 3,
                label    = "3년 보기",
                step     = "year",
                stepmode = "backward"),
              list(
                label = "모두 보기",
                step  = "all"
              )
            )
          ),
          rangeslider = list(type = "date")
        ),
        yaxis = list(
          title          = "관객수",
          gridcolor      = 'rgb(255,255,255)',
          tickcolor      = 'rgb(127,127,127)',
          ticks          = 'outside',
          showgrid       = TRUE,
          showline       = FALSE,
          zeroline       = FALSE,
          showticklabels = TRUE
        ),
        margin=list(
          l=55,
          r=15,
          b=15,
          t=55,
          pad=5
        )
      ) %>%
      add_annotations(
        x = actorGlanceData_movies$ReleaseDate - 1,
        y = 0,
        text = actorGlanceData_movies$Title,
        xref = "x",
        yref = "y",
        showarrow = TRUE,
        arrowhead = 4,
        arrowsize = .75,
        ax = -10,
        ay = ay_list
      )
    
  })
  
  
  output$actorGenreRadarPlot <- renderPlotly({
    actorGlanceData_tmp <- actorGlanceData()
    actor_genre <- actorGlanceData_tmp$genres
    
    max_val <- max(actor_genre)
    
    df_tmp <- data.frame(
      rbind(t(actor_genre), t(actor_genre)[1,])
    )
    
    colnames(df_tmp) <- c('Count')
    
    df_tmp$theta <- seq(0, 2*pi, by = (2*pi)/length(actor_genre))
    
    df_tmp$x <- df_tmp$Count * cos(df_tmp$theta)
    df_tmp$y <- df_tmp$Count * sin(df_tmp$theta)
    
    df_tmp2 <- data.frame(
      c(round(max_val/4,digits=0), round(max_val/4,digits=0)*2, round(max_val/4,digits=0)*3)
    )
    
    colnames(df_tmp2) <- c('rVals')

    axisdf <- data.frame(
      x = 0*cos(df_tmp$theta), y = 0*sin(df_tmp$theta),
      xend = max_val*0.96*cos(df_tmp$theta), yend = max_val*0.96*sin(df_tmp$theta)
    )
    
    # https://moderndata.plot.ly/radial-stacked-area-chart-in-r-using-plotly/
    plot_ly(df_tmp,
      x = ~x,
      y = ~y,
      type = "scatter",
      mode = "lines",
      fill = "tonexty",
      fillcolor = "#e6e6e6",
      line = list(
        shape = "spline", 
        color = "#737373"
      ),
      hoverinfo='none'
    ) %>%
      
    add_text(
      x = (max_val*1.02) * cos(df_tmp$theta),
      y = (max_val*1.02) * sin(df_tmp$theta),
      text = rownames(df_tmp),
      inherit = FALSE,
      hoverinfo='none',
      textfont = list(
        color = "black", 
        size = 12
      )
    ) %>%
      
    add_text(
      x = df_tmp2$rVals * cos(df_tmp$theta[length(df_tmp$theta)-2]),
      y = df_tmp2$rVals * sin(df_tmp$theta[length(df_tmp$theta)-2]),
      text = df_tmp2$rVals,
      hoverinfo='none',
      inherit = FALSE,
      textfont = list(
        color = "black", 
        size = 20
      )
    ) %>%
    
    add_trace(
      x = round(max_val/4,digits=0) * cos(df_tmp$theta),
      y = round(max_val/4,digits=0) * sin(df_tmp$theta),
      inherit = FALSE,
      type = "scatter",
      mode = "lines",
      line = list(
        shape = "spline", 
        color = "#737373",
        dash  = "4px"
      ),
      hoverinfo='none',
      opacity = 0.5
    ) %>%
      
    add_trace(
      x = round(max_val/4,digits=0)*2 * cos(df_tmp$theta),
      y = round(max_val/4,digits=0)*2 * sin(df_tmp$theta),
      inherit = FALSE,
      type = "scatter",
      mode = "lines",
      line = list(
        shape = "spline", 
        color = "#737373",
        dash  = "4px"
      ),
      hoverinfo='none',
      opacity = 0.5
    ) %>%

    add_trace(
      x = round(max_val/4,digits=0)*3 * cos(df_tmp$theta),
      y = round(max_val/4,digits=0)*3 * sin(df_tmp$theta),
      inherit = FALSE,
      type = "scatter",
      mode = "lines",
      line = list(
        dash  = "4px",
        shape = "spline", 
        color = "#737373"
      ),
      hoverinfo='none',
      opacity = 0.5
    ) %>%
    
    add_segments(
      data = axisdf, 
      x = ~x, 
      y = ~y, 
      xend = ~xend, 
      yend = ~yend, 
      inherit = F,
      line = list(
        dash = "4px", 
        color = "#737373", 
        width = 2
      ),
      hoverinfo='none',
      opacity = 0.5
    ) %>%
      
    layout(
      showlegend = FALSE,
      xaxis = list(
        title = "",
        showgrid       = FALSE,
        showline       = FALSE,
        zeroline       = FALSE,
        showticklabels = FALSE,
        domain = c(0, max(actor_genre))
      ),
      yaxis = list(
        title = "",
        showgrid       = FALSE,
        showline       = FALSE,
        zeroline       = FALSE,
        showticklabels = FALSE,
        domain = c(0, max(actor_genre))
      ),
      margin=list(
        l=25,
        r=25,
        b=25,
        t=25,
        pad=5
      )
    )

  })
  
  
  
})
