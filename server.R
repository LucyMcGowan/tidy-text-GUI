library(shiny)
library(dplyr)
library(gutenbergr)
library(tidytext)
library(ggplot2)

shinyServer(function(input, output) {
  values <- reactiveValues(df_data = NULL)
  #If the data is a text string 
  observeEvent(input$go_string, {
   string_df <- data_frame(text = input$input_text)
   string_df %>%
      unnest_tokens(word, text) %>%
      anti_join(stop_words) %>%
      count(word, sort = TRUE) -> values$df_data
    
  })
  output$output_text <- renderTable({
    values$df_data
  })
  
  #If the data is a csv file
  output$output_csv <- renderTable({
    
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with 'name',
    # 'size', 'type', and 'datapath' columns. The 'datapath'
    # column will contain the local filenames where the data can
    # be found.
    
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    
    read.csv(inFile$datapath, header=input$header, sep=input$sep, 
             quote=input$quote)
  })
  #if the data is from gutenberg data set
  observeEvent(input$go, {
    id <- gutenberg_works(title == input$gutenberg_work)[1]
    gutenberg_download(id) %>%
      unnest_tokens(word, text) %>%
      anti_join(stop_words) %>%
      count(word, sort = TRUE) -> values$df_data
    
  })
  output$output_rda <- renderTable({
    head(values$df_data)
  })
  
  output$plot_text <- renderPlot({
    if (!is.null(values$df_data)){
    values$df_data %>%
      top_n(25,n) %>%
      mutate (word = reorder(word, n)) %>%
      ggplot(aes(word, n)) +
      geom_bar(stat = "identity") +
      xlab(NULL) +
      coord_flip()
    }
  })
  
  #Session Info
  output$sessionInfo <- renderPrint({
    capture.output(sessionInfo())
  })
})
