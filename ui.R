library(shiny)
library(ggplot2)
source("chooser.R")

shinyUI(navbarPage(
  title = 'Shiny Wrangler',
  tabPanel('Load data set',     
    fluidRow(
    column(3,
      wellPanel(
        fileInput('file1', 'Choose file to upload',
                accept = c(
                  'text/csv',
                  'text/comma-separated-values',
                  'text/tab-separated-values',
                  'text/plain',
                  '.csv',
                  '.tsv'
                )
          ),
          hr(),
          checkboxInput('header', 'Header', TRUE),
          wellPanel(
            radioButtons('sep', 'Separator',
                   c(Comma=',',
                     Semicolon=';',
                     Tab='\t'),
                   ',')
          ),
          wellPanel(
            radioButtons('quote', 'Quote',
                   c(None='',
                     'Double Quote'='"',
                     'Single Quote'="'"),
                   '"')
          ),
          hr(),
          p('If you want a sample .csv or .tsv file to upload,',
             'you can first download the sample',
             a(href = 'mtcars.csv', 'mtcars.csv'), 'or',
             a(href = 'pressure.tsv', 'pressure.tsv'),
             'files, and then try uploading them.'
          )
        )
      ),
    column(8,
      dataTableOutput('view')
    )
  )
  ),
  tabPanel('Reshape Data',   
    fluidRow(
      column(2, h3("Untidy Columns")),
      column(2, h3("Tidy Columns"))
    ),
    fluidRow(
      column(4,uiOutput("chooser")),
      column(3, textInput("varName", "Name for variable column", value = "Variable"), 
                textInput("valueName", "Name for value column", value = "Value"))
    ),
    actionButton("melt", "Melt Data"),
    br(),
    hr(),
    br(),
    fluidRow(
      column(3, uiOutput("colOutput")),
      column(3, uiOutput("cellOutput"))
    ),
    actionButton("cast", "Cast Data"),
    br(),
    hr(),
    dataTableOutput("view2")
  ),
  
  
  
  tabPanel('Download data',
    fluidRow(
      column(3,
        textInput("fileName", "Save as:"),
        helpText("Note: you do not need to write a file extension above"),
        radioButtons("filetype", "File type:",
                   choices = c("csv", "tsv")),
        downloadButton('downloadData', 'Download')
      ),
      column(8,
        dataTableOutput("view3")
      )
    )
  )
))
