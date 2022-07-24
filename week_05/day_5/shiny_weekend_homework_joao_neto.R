library(tidyverse)
library(janitor)
library(CodeClanData)
library(shiny)
library(bslib)
library(shinyWidgets)
library(shinydashboard)
library(DT)

# read data ---------------------------------------------------------------
game_sales <- CodeClanData::game_sales %>% 
  janitor::clean_names()




# Introduction ------------------------------------------------------------
# The dashboard have 2 "rows", each row has a slidebarlayout with the options 
# we need, and for each main panel will have a tab where it is possible to 
# see the plot, and aother tab with the table from our selection/filtered data.
# The filter of publisher could be selected more than one at once. Every time
# that make a change in filters, the button update should be press to refresh
# the information.



# ui ----------------------------------------------------------------------
ui <- fluidPage(
  titlePanel("Game Sales"),
  
  
  ## 1st sidebar -----------------------------------------------------------
  # where will be possible to filter by genre and publiser and see the amount 
  # of sales per year.
  # The filter of publisher allows to selected more than one option at once. 
  # Every time that make a change in filters, the button update should be press 
  # to refresh the information.
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId = "genre",
                  label = "Genre",
                  choices = unique(game_sales$genre)
      ),
      pickerInput(inputId = "publisher",
                  label = "Publisher",
                  choices = unique(game_sales$publisher),
                  options = list('actions-box' = TRUE),
                  multiple = TRUE
      ),
      actionButton(inputId = "update", label = "Update")
    ),
    mainPanel(
      fluidRow(
        tabsetPanel(
          tabPanel("Plots",
                   plotOutput("graph_plot")
          ),
          tabPanel("Data",
                   DT::dataTableOutput("data_table")
          ),
        ), 
      )  
    ) 
  ),
  
  
  ## 2nd sidebar ----------------------------------------------------------
  # The distribution of records of critic_score and user_score are showed in 
  # scatter plot to see if there are relation between those variables.
  # There are a option to filter per platform (just one or them all), and the 
  # information is showed by rating too, it means that the variable rating was
  # facet_wrap.
  
  sidebarLayout(
    sidebarPanel(
      pickerInput(inputId = "platform",
                  label = "Plataform",
                  choices = unique(game_sales$platform),
                  options = list('actions-box' = TRUE),
                  multiple = TRUE,
                  selected = "Wii"
      ),
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Plots",
                 plotOutput("plot_rating")
        ),
        tabPanel("Data",
                 DT::dataTableOutput("table_rating")
        ),
      ), 
    ) 
  )
)  




# server ------------------------------------------------------------------
server <- function(input, output) {
  
  #server -> 1st sidebar ---------------------------------------------------
  ##update button and repetitive action ---------------------
  filtered_sales <- eventReactive(
    input$update,
    game_sales %>% 
      group_by(year_of_release) %>% 
      filter(genre     == input$genre) %>% 
      filter(publisher %in%  input$publisher) %>% 
      mutate(sales = sum(sales)))
  
  
  ## tab "Plots" -------------------------------------------------------------
  output$graph_plot <- renderPlot(
    filtered_sales ()%>% 
      ggplot() +
      aes(x = year_of_release, y = sales) +
      geom_col(stat = "count") +
      geom_label(aes(label = sales), vjust = -1) +
      geom_label (aes(label= year_of_release), vjust = 0) +
      labs(
        title = "Amount of sales per Genre and publisher",
        x = "\nyear of release"
      ) +
      theme_minimal() +
      theme(panel.grid.minor.x = element_blank())
  )
  
  
  ## tab "Data" --------------------------------------------------------------
  output$data_table <- renderDataTable(
    filtered_sales ()
  )
  
  
  
  # server -> 2nd sidebar ---------------------------------------------------
  ## repetitive action ------------------------------------
  filtered_rating <- reactive({ 
    game_sales %>% 
      filter(platform %in% input$platform)
  })
  
  ## tab "Plots" -------------------------------------------------------------
  output$plot_rating <- renderPlot(
    filtered_rating ()%>% 
      ggplot() +
      aes(x = critic_score, y = user_score) +
      geom_point() +
      facet_wrap(~rating)
  )
  
  ## tab "Data" --------------------------------------------------------------
  output$table_rating <- renderDataTable(
    filtered_rating ()
  )
}

shinyApp(ui, server)


