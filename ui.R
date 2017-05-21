#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
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



dashboardPage(
  title = "한국 영화 DB 대시보드 - South Korea Movie Data Dashboard",      # 브라우저 탭에 보이는 제목
  skin  = "blue",
  
  dashboardHeader(title = "영화 DB 대시보드"),    # 사이드바 위에 나타나는 제목. 사이드바를 접어도 남아있음.
  
  # 왼쪽 사이드 바
  dashboardSidebar(
    
    uiOutput("selectMovie"),
    uiOutput("selectActor"),
    
    sidebarMenu(
      id = "sbMenu",
      
      menuItem(
        "첫 화면", 
        tabName = "frontPage"
      ),
      
      menuItem(
        "영화 정보", 
        tabName = "movies", 
        icon = icon("film"),
        menuSubItem(
          "한 눈에 보기", 
          tabName = "movie_glance", 
          icon = icon("th")
        ),
        menuSubItem(
          "자세히 보기", 
          tabName = "movie_detail", 
          icon = icon("search")
        )
      ),
      
      menuItem(
        "배우 정보",
        tabName = "actors",
        icon = icon("user"),
        menuSubItem(
          "한 눈에 보기",
          tabName = "actor_glance",
          icon = icon("th")
        ),
        menuSubItem(
          "자세히 보기",
          tabName = "actor_detail",
          icon = icon("search")
        )
      ),
      
      tags$hr(),    # 수평선    a horizontal line
      p(
        h4("Created by Daniel Kim"),
        tags$a(href="http://danielykim.me", "[Homepage]"),
        tags$br(),
        tags$a(href="https://www.linkedin.com/in/danielyounghokim", "[LinkedIn]")
      )
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$link(
        rel  = "stylesheet",
        type = "text/css",
        href = "custom.css"    # 사용자 지정 스타일 파일. 위치  www/custom.css
      )
    ),
    
    tabItems(
      
      ## Front Page
      ### width: integer    (domain=[1,12])
      tabItem(
        "frontPage",
        fluidRow(
          column(
            width = 10,
            box(
              title  = "사용 안내",
              class  = "information",
              width  = 12,
              status = "primary",
              solidHeader = TRUE,
              collapsible = FALSE,
              collapsed   = FALSE,
              h3("첫 화면"),
              hr(),
              p("이 화면은 처음 실행했거나 왼쪽의 사이드바 메뉴에서 ", tags$b("첫 화면"), "을 클릭하면 보이는 화면입니다."),
              tags$br(),
              h3("사이드바 메뉴"),
              hr(),
              p("왼쪽의 사이드바 메뉴를 보세요.", "여기에서 ", tags$b("영화 정보"), "와 ", tags$b("배우 정보"),"는 각각 두 가지 하위 메뉴를 포함하는 드롭다운 메뉴입니다."),
              h4("영화 정보"),
              tags$ul(
                tags$li(tags$b("한 눈에 보기: "),"영화들의 기본 정보를 한 눈에 볼 수 있습니다."),
                tags$li(tags$b("자세히 보기: "),"영화별 정보와 관객수 추세를 볼 수 있습니다. 이 메뉴를 선택하면 왼쪽 사이드바 메뉴에 영화를 고르는 메뉴가 생깁니다.")
              ),
              h4("배우 정보"),
              tags$ul(
                tags$li(tags$b("한 눈에 보기: "),"배우들의 기본 정보를 한 눈에 볼 수 있습니다."),
                tags$li(tags$b("자세히 보기: "),"배우별 정보, 관객수 추세, 장르 분포 등을 볼 수 있습니다. 이 메뉴를 선택하면 왼쪽 사이드바 메뉴에 배우를 고르는 메뉴가 생깁니다.")
              ),
              tags$br(),
              h3("수정 사항"),
              hr(),
              p(tags$b("자세히 보기"),"를 선택했을 때 영화나 배우를 고르는 메뉴에서 현재 선택된 영화나 배우를 지우고 다시 입력하는 기능이 제대로 작동하지 않는 버그가 있습니다.")
            )
          )
        )
      ),
      
      ## Movie info and sales quantity series
      tabItem(
        "movie_glance",
        fluidRow(
          box(
            width = 12,
            #sparklineOutput("movieSparkLine"),
            dataTableOutput("movieDataTable")
          )
        )
      ),
      
      tabItem(
        "movie_detail",
        fluidRow(
          column(
            width = 3,
            box(
              width  = 12,
              height = 420,
              class  = "information",
              status = "primary",
              solidHeader = TRUE,
              title = "포스터",
              plotOutput('thumbnail')
            )
          ),
          column(
            width = 9,
            fluidRow(
              column(
                width = 4,
                infoBoxOutput("movieTitleBox", width = 12)
              ),
              column(
                width = 4, 
                infoBoxOutput("movieGenreBox", width = 12)
              ),
              column(
                width = 4, 
                infoBoxOutput("movieRunningTimeBox", width = 12)
              )
            ),
            fluidRow(
              tags$br()
            ),
            fluidRow(
              column(
                width = 4,
                infoBoxOutput("movieGradeBox", width = 12)
              ),
              column(
                width = 4,
                infoBoxOutput("movieReleaseDateBox", width = 12)
              ),
              column(
                width = 4,
                infoBoxOutput("movieAgencyBox", width = 12)
              )
            ),
            fluidRow(
              tags$br()
            ),
            fluidRow(
              column(
                width = 4,
                infoBoxOutput("movieSalesBox", width = 12)
              ),
              column(
                width = 4,
                infoBoxOutput("movieAudiencesBox", width = 12)
              )
            )
            # ,
            # fluidRow(
            #   column(
            #     width = 6,
            #     infoBoxOutput("movieScreensBox", width = 12)
            #   ),
            #   column(
            #     width = 6,
            #     infoBoxOutput("moviePlaysBox", width = 12)
            #   )
            # )
          )
        ),
        fluidRow(
          column(
            width=12,
            box(
              class  = "information",
              status = "primary",
              solidHeader = TRUE,
              title = "관객수 추이",
              width  = 12,
              plotlyOutput("movieDetailSeriesPlot")
            )
          )
        ),
        ## 적어도 하나는 선택하도록 강제하는 코드
        ## The number of checked items should be at least one.
        HTML(
          "<script>
           $(\"input[name$='seriesDataTypes']\").on('change', function() {
           if ( $(\"input[name$='seriesDataTypes']:checked\").length < 1 ) {
           this.checked = true;
           }
           });
           </script>"
        )
      ),
      
      tabItem(
        "actor_glance",
        fluidRow(
          box(
            width = 6,
            dataTableOutput("actorDataTable")
          )
        )
      ),
      
      tabItem(
        "actor_detail",
        fluidRow(
          column(
            width = 4,
            infoBoxOutput("actorNameBox", width = 12)
          ),
          # column(
          #   width = 3, 
          #   infoBoxOutput("actorBirthDateBox", width = 12)
          # ),
          column(
            width = 4,
            infoBoxOutput("actorMoviesBox", width = 12)
          ),
          column(
            width = 4,
            infoBoxOutput("actorTotalAudiencesBox", width = 12)
          )
        ),
        fluidRow(
          tags$br()
        ),
        fluidRow(
          column(
            width = 6,
            box(
              class  = "information",
              status = "primary",
              solidHeader = TRUE,
              title = "관객수 추이",
              width = 12,
              plotlyOutput('actorAudienceSeriesPlot')
            )
          ),
          column(
            width = 6,
            box(
              class  = "information",
              status = "primary",
              solidHeader = TRUE,
              title = "출연 영화 장르",
              width = 12,
              plotlyOutput('actorGenreRadarPlot')
            )
          )
        )
      ),
      
      tabItem(
        "info", 
        includeMarkdown("info.md")
      )
      
    ) # tabItems
  ) # body
) # page
