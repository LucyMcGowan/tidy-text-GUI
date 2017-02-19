library(shiny)
library(dplyr)
library(gutenbergr)
library(shinythemes)

gutenberg_works()[2] %>%
  na.omit() -> titles

shinyUI(fluidPage(
  theme = shinytheme("journal"),
  navbarPage("Tidy Text GUI",
             tabPanel("Import Data", icon = icon("table"),
                      sidebarLayout(
                        sidebarPanel(
                          radioButtons(
                            "data_type",
                            "I would like to analyze",
                            c(
                              "a public domain work in the Project Gutenberg collection" = "rda",
                              "a raw text string that I can paste in" = "string"
                              # "data from a csv file" = "csv"
                            )
                          ),
                          # conditionalPanel(
                          #   condition = "input.data_type == 'csv'",
                          #   fileInput(
                          #     'file1',
                          #     'Choose CSV File',
                          #     accept = c('text/csv',
                          #                'text/comma-separated-values,text/plain',
                          #                '.csv')
                          #   ),
                          #   tags$hr(),
                          #   checkboxInput('header', 'Header', TRUE),
                          #   radioButtons('sep', 'Separator',
                          #                c(
                          #                  Comma = ',',
                          #                  Semicolon = ';',
                          #                  Tab = '\t'
                          #                ),
                          #                ','),
                          #   radioButtons(
                          #     'quote',
                          #     'Quote',
                          #     c(
                          #       None = '',
                          #       'Double Quote' = '"',
                          #       'Single Quote' = "'"
                          #     ),
                          #     '"'
                          #   )
                          # ),
                          conditionalPanel(
                            condition = "input.data_type == 'string'",
                            tags$style(type = "text/css", "textarea {width:100%}"),
                            tags$textarea(
                              id = 'input_text',
                              placeholder = 'Paste your data here',
                              rows = 8,
                              ""
                            ),
                            actionButton("go_string", "Ready!")
                          ),
                          conditionalPanel(
                            condition = "input.data_type == 'rda'",
                            selectizeInput(
                              "gutenberg_work",
                              "Select Book - hit backspace to remove current selection & begin typing book title",
                              titles,
                              selected = "John F. Kennedy's Inaugural Address",
                              multiple = FALSE,
                              options = NULL
                            ),
                            actionButton("go", "Ready!")
                          )
                        ),
                        
                        mainPanel(
                                   conditionalPanel(condition = "input.data_type == 'string'",
                                                    tableOutput('output_text')),
                                   # conditionalPanel(condition = "input.data_type == 'csv'",
                                   #                  tableOutput('output_csv')),
                                   conditionalPanel(condition = "input.data_type == 'rda'",
                                                    tableOutput('output_rda'))
                          ))),
             tabPanel("Plot", icon = icon("bar-chart-o"),
                      plotOutput("plot_text")),
             tabPanel("References", icon = icon("book"),
                      h5("This was made possible due to the exquisite Tidy Text Mining book by Julia Silge and David Robinson", 
                         a("here.",     
                           href="http://tidytextmining.com/tidytext.html",
                           target = "_blank")),
                      h5("Below is my session information"),
                      verbatimTextOutput("sessionInfo")
             ),
             tabPanel("Feedback", icon = icon("commenting-o"),
                      h4("Would you like to see more? Or something different? Or just want to say hi?"))
                      )
  )

      
)

