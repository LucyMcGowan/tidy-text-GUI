library(shiny)
library(dplyr)
library(gutenbergr)
library(tidytext)
library(ggplot2)

shinyServer(function(input, output) {
  values <- reactiveValues(df_data = NULL, sentiment = NULL)
  
  #If the data is a text string 
  observeEvent(input$go_string, {
   string_df <- data_frame(text = input$input_text)
   string_df %>%
      unnest_tokens(word, text) %>%
      anti_join(stop_words) %>%
      count(word, sort = TRUE) -> values$df_data
   string_df %>%
     unnest_tokens(word, text) %>%
     anti_join(stop_words) %>%
     inner_join(get_sentiments("bing")) %>%
     count(word, sentiment, sort = TRUE) %>%
     ungroup() -> values$sentiment
  })
  
  output$output_text <- renderDataTable({
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
    gutenberg_download(id) %>%
      unnest_tokens(word, text) %>%
      anti_join(stop_words) %>%
      inner_join(get_sentiments("bing")) %>%
      count(word, sentiment, sort = TRUE) %>%
      ungroup() -> values$sentiment
    
  })
  
  output$plot_text <- renderPlot({
    if (!is.null(values$df_data)){
    values$df_data %>%
      top_n(25,n) %>%
      mutate (word = reorder(word, n)) %>%
      ggplot(aes(word, n)) +
      geom_bar(stat = "identity") +
      xlab(NULL) +
      coord_flip() -> plot
      print(plot)
      ggsave(input$filename_plot,plot)
    }
  })
  
  output$plot_sentiment <- renderPlot({
    if (!is.null(values$df_data)){
    if (!nrow(values$sentiment)==0){
    values$sentiment %>%
        group_by(sentiment) %>%
        top_n(10) %>%
        mutate(word = reorder(word, n)) %>%
        ggplot(aes(word, n, fill = sentiment)) +
        geom_bar(stat = "identity", show.legend = FALSE) +
        facet_wrap(~sentiment, scales = "free_y") +
        labs(y = "Contribution to sentiment",
             x = NULL) +
        coord_flip() -> plot
      print(plot)
      ggsave(input$filename_plot_sentiment,plot)
    }
    }
  })
  
  output$download_plot_sentiment <- downloadHandler(
    filename = function() {
      input$filename_plot_sentiment
    },
    content = function(file) {
      file.copy(input$filename_plot_sentiment, file, overwrite=TRUE)
    }
  )
  
  output$download_plot <- downloadHandler(
    filename = function() {
      input$filename_plot
    },
    content = function(file) {
      file.copy(input$filename_plot, file, overwrite=TRUE)
    }
  )
  
  #Session Info
  output$sessionInfo <- renderPrint({
    capture.output(sessionInfo())
  })
})
