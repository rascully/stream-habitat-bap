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

#install.packages("DT")

# This should work, but for some reason I can't figure it out
#wd<- getwd()
#file<- paste0(wd,"/Data/All_Data_with_NVCS.csv")

# Can't figure out how to retreive WD and paste into a R file name?
wd <- "C:/Users/rscully/Documents/Projects/Habitat Data Sharing/2019_2020/Code/tributary-habitat-data-sharing-/"
file<- paste0(wd,"Data/All_Data.csv")
data <- read.csv(file)

#Load the data file from ScienceBase not sure if that is correct or if we should pull the data from
#authenticate_sb("rscully@usgs.gov", "PNAMPusgs28!")
#id      <-"5e3c5883e4b0edb47be0ef1c"
#data <- item_file_download(id,names= All_Data.csv, destionation=file.path(getwd(), "Data/All_Data.csv")

metadata_file<- paste0(wd,"/Data/Metadata.xlsx")
metadata <-as_tibble(read.xlsx(metadata_file, 3)) #read in the metadata 
 
#remove the data collection points with blanks lat, long
#data         <-data %>% drop_na(verbatimLongitude) %>% drop_na(verbatimLatitude)

#Variables to sort data on 
sort_variable         <- sort(unique(data$State))

#Load the metric list
#metrics_file  <- paste0(wd,"/Data/SubSetOfMetricNames.csv")
#metrics_list  <- as_tibble(read.csv(metrics_file))

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
  
  
  #create simple scatter plot 
 # output$plot<- renderPlot({
  #  nvcs_ec = data %>% 
   #   filter(State==input$e_id)%>%
    #  select(input$metric,input$metric_y, "Program")
    #ggplot(nvcs_ec, aes(x=nvcs_ec[,1], y=nvcs_ec[,2], color=Program))+geom_point()
   # plot(nvcs_ec)
 # })
  
# subset_data = data %>% 
 #    filter(State=="OR")%>%
  #   select("Grad","RPD", "Program")
  
  
    #create simple scatter plot 
  output$plot<- renderPlot({
  subset_data = data %>% 
      filter(State==input$e_id)%>%
      select(input$metric,input$metric_y, "Program")
      sp <- ggplot(subset_data, aes(x=subset_data[,1], y=subset_data[,2], color=Program)) +geom_point()
      sp + scale_color_manual(values=c("red","green","blue"))
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
