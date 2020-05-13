#install.packages('shiny', dependencies = TRUE)
library(shiny)
#install.packages('tidyverse')
library(tidyverse)
#install.packages("openxlsx")
library(openxlsx)
#install.packages('leaflet')
library(leaflet)
#install.packages('dplyr')
library(dplyr)
#install.packages('leaflet.extras')
library(leaflet.extras)
#install.packages('DT')
library(DT)
#install.packages('ggplot2')
library(ggplot2)
#install.packages("jsonlite")
library(jsonlite)
#install.packages("sbtools")
library(sbtools)
library(data.table)

#Load the data file from ScienceBase not sure if that is correct or if we should pull the data from
authenticate_sb("rscully@usgs.gov", "PNAMPusgs28!")
id      <-"5e3c5883e4b0edb47be0ef1c"
file = paste0(getwd(), "All_Data.csv")
item_file_download(id, names="All_Data.csv", destinations  =file.path(getwd(), "All_Data.csv"), overwrite_file = TRUE)
data <- read.csv(paste0(getwd(), "/All_Data.csv"))

#Download the Metadata file 
metadata_id = '5e41a716e4b0edb47be63b22'
item_file_download(metadata_id, names="Metadata.xlsx", destinations  =file.path(getwd(), "Metadata.xlsx"), overwrite_file = TRUE)
metadata_file<- paste0(getwd(),"/Metadata.xlsx")
metadata <-as_tibble(read.xlsx(metadata_file, 3)) #read in the metadata 
 

#Variables to sort data on 
sort_variable         <- sort(unique(data$State))

# Extract the subset of metrics we are focusing on 
metric_list <- metadata %>% 
  filter(Subset_of_Metrics== "x")


#Partition out the stream power metrics and the other stream habitat metrics 
stream_power_metrics  <- names(data[16:17])
metrics               <- names(data[21:length(data)-2])


#Load the pallet for the map 
#pal <- colorFactor(crainbow(3), data$Program)

pal <- colorFactor(c("green","red","blue"), domain=c("BLM", "AREMP", "EPA"))

ui<- navbarPage(
  "Stream Habitat",
  # a tab for a map 
  tabPanel("Map", leafletOutput(outputId="map", width = "100%", height= 900), 
           absolutePanel(
             id = "controls", class = "panel panel-default", fixed = TRUE,
             draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
             width = 'auto', height = "auto",
             #Create a drop down with the sort_variable 
             selectInput(inputId ="e_id", label= "Choose a State", 
                         choices=(sort_variable), selected ='OR'), 
             selectInput(inputId='metric', label="Select Metric", choices=metrics, selected='D50'),
             plotOutput("hist", height = 200), 
             selectInput(inputId='metric_y', label="Select Stream Power", choices=stream_power_metrics, selected='Grad'),
             dataTableOutput("ProgramCount"), 
             plotOutput("plot", height = 200), 
          )),

#a tab for the metric descriptions 
  tabPanel("Method Description", dataTableOutput("Methods")), 

# a tab for downloading data  
  tabPanel("Explore Data", 
           sidebarLayout(
             sidebarPanel(downloadButton("downloadData", "Download")),   
             mainPanel(DT::dataTableOutput('table'))
           )
  ))


server <- function(input, output) { 
  # Create the map 
  
  output$map <-  renderLeaflet({
    data%>% 
      filter(State==input$e_id) %>%
      leaflet() %>%
      addTiles() %>%
      addCircles(lng=~verbatimLongitude, lat= ~verbatimLatitude, color=~pal(Program), 
                 popup= ~paste0("<b>",Program, "</b>", 
                                "<HR>", "<b>", "SiteID ", "</b>",  eventID, "</HR>",
                                "<HR>", "<b>", "ReachID ", "</b>",verbatimLocation,  "</HR>",
                                "<HR>", "<b>", "Year ", "</b>", Year,    "</HR>",
                                "<HR>", "<b>", "Date", "</b>", verbatimEventDate,"</HR>", 
                                "<br>")) %>%
      addLegend("topleft", pal=pal, values= ~Program, opacity =1)
    
  })
  
  #create a histogram 
  output$hist <- renderPlot({
    nvcs_h = data %>% 
      filter(State==input$e_id)%>%
      select(input$metric, "Program") 
    #ggplot(nvcs_h, aes(nvcs_h[1]))+geom_histogram()+facet_wrap(~Program)
    #ggplot(nvcs_h, aes(input$metric))+ geom_point()+facet_wrap(~Program)
    qplot(nvcs_h[,1], geom='histogram')+ xlab(names(nvcs_h[1]))
  })
  
#Table displaying the count of metrics for each program
output$ProgramCount <- renderDataTable({
  count_data = data %>% 
    filter(State==input$e_id)%>%
    select(input$metric, "Program") %>%
    drop_na(input$metric) %>%
    count(Program)
    col_header = paste("Count", input$metric, "measurments in ", input$e_id)
    setnames(count_data, c("Program", col_header))
    datatable(count_data, options = list(dom = 't'))
  })
  

#create simple scatter plot 
  output$plot<- renderPlot({
  subset_data = data %>% 
      filter(State==input$e_id)%>%
      select(input$metric,input$metric_y, "Program")
      sp <- ggplot(subset_data, aes(x=subset_data[,1], y=subset_data[,2], color=Program)) +geom_point() + scale_colour_manual(values=c("green","red","blue"), breaks=c("AREMP","BLM", "EPA"))
      sp + xlab(names(subset_data[1])) + ylab(names(subset_data[2]))
       })

  
  
#Second Tab to pull method data from MR.org using the APIs 
#Need help formating the html table 
output$Methods <- DT:: renderDataTable (DT::datatable({ 
  
    metric_index <- filter(metadata, Field==input$metric)
    mr_index     <- data.frame(select(metric_index, contains('ShortName')), select(metric_index, contains('CollectionMethod')))
    
    # add a row to put the text into 
    mr_index <- add_row(mr_index)
    mr_index <- add_row(mr_index)
    
    i =0 #reset the index 
    for(i in 1:length(mr_index)){
      id= mr_index[1,i]
      if(!is.na(id)){ 
        mr_method    <- paste0("https://www.monitoringresources.org/api/v1/methods/", id) 
        mr_method    <- URLencode(mr_method)
        method_text  <- fromJSON(mr_method) 
        instruction  <-  method_text$instructions
        if (!is.null(instruction)){
          mr_index[2,i]   <- method_text$citation$title
          mr_index[3,i]   <-  method_text$instructions
          
        } 
      }
    }
    mr_index
}))
  
  
  # Third tab table and data download 
  
  # create a table to output on the thrid tab 
  output$table<- renderDataTable({
    data %>% 
      filter(State==input$e_id)
  })
  
  # Downloadable csv of selected dataset ----
  download_data<- reactive({
    return(download_data= data.frame(data%>% 
                                       filter(Program==input$e_id)))
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste(input$metric, ".csv", sep = "")
    },
    content = function(file) {
      write.csv(download_data(), file, row.names = TRUE)
    })
  
  
}

shinyApp(server = server, ui=ui)

#} 

