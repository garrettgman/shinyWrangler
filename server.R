# By default, the file size limit is 5MB. It can be changed by
# setting this option. Here we'll raise limit to 9MB.
options(shiny.maxRequestSize = 9*1024^2)
source("chooser.R")
library(reshape2)

shinyServer(function(input, output) {

  
  # 1. Loading data
  dataInput <- reactive({
    inFile <- input$file1

    if (is.null(inFile))
      return(NULL)
    
    assign("reshaped", read.csv(inFile$datapath, header = input$header,
             sep = input$sep, quote = input$quote), envir = parent.env(environment()))
    assign("new.file", TRUE, envir = parent.env(environment()))
    NULL
  })
  
  
  output$view <- renderDataTable({
    dataInput()
    input$melt
    input$cast
    if (!exists("reshaped")) return(NULL)
    reshaped
  })
  
  
  # 2. reshaping data  
  melts <- reactive({
    if (input$melt != 0 & !new.file) {
      assign("reshaped", melt(reshaped, 
         id = isolate(input$mychooser$right),
         variable.name = isolate(input$varName),
         value.name = isolate(input$valueName)),
         envir = parent.env(environment()))
    }
  })
  
  casts <- reactive({
    if (input$cast != 0 & !new.file) {
      cformula <- as.formula(paste("... ~", isolate(input$cols)))
      assign("reshaped", dcast(reshaped, formula = cformula,
         value.var = isolate(input$cells)),
      envir = parent.env(environment()))
    }
  })
  
  output$view2 <- renderDataTable({
    melts()
    casts()
    columns()
    if (new.file) assign("new.file", FALSE, envir = parent.env(environment()))
    reshaped
  })
  
  columns <- reactive({
    dataInput()
    input$melt
    input$cast
    names(reshaped)
  })
  
  output$chooser <- renderUI({
    chooserInput("mychooser", 
        "Untidy Columns", "Tidy Columns",
         columns(),
         c(), size = 10, 
         multiple = TRUE)
  })
  
  output$colOutput <- renderUI({
    selectInput("cols", "Create new columns with", choices = columns())
  })
  
  output$cellOutput <- renderUI({
    clms <- columns()
    selectInput("cells", "Create new cell values with", choices = clms, 
                selected = clms[length(clms)])
  })
  
  
  # 3. Download file
  output$downloadData <- downloadHandler(

    filename = function() {
  	  paste(input$fileName, input$filetype, sep = ".")
	  },

    content = function(file) {
      sep <- switch(input$filetype, "csv" = ",", "tsv" = "\t")

      write.table(reshaped, file, sep = sep,
        row.names = FALSE)
    }
  )
  
  output$view3 <- renderDataTable({
    dataInput()
    melts()
    casts()
    reshaped
  })
})