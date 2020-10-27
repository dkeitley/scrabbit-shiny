
library(shiny)


big_plot_width = 9 * 1.5
big_plot_height = 5 * 1.5

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    
    
    sidebarLayout(
        sidebarPanel(
            id="sidebar",
            # style = "position:fixed;width:15%;",
            width = 2,
            h3("Plot options"),
            
            
            #SIDEBAR INPUTS
            
            selectInput(
                "coord_type",
                "Projection type",
                choices = c("UMAP" = "umap",
                            "t-SNE" = "tsne"),
                selected="umap"
            ),
            selectInput(
                "stage",
                "Developmental stage",
                choices = c(
                    "All timepoints" = "all",
                    "GD7" = "gd7" ,
                    "GD8" ="gd8",
                    "GD9" = "gd9" 
                ),
                selected = "all"
            ),
            
            selectInput(
                "colourby",
                "Plot colour",
                choices = c(
                    "Cell type" = "celltype",
                    "Clusters" = "cluster",
                    "Timepoint" = "stage",
                    "Sample" = "sample"
                ),
                selected = "celltype"
            ),
            selectizeInput("gene", "Gene", choices = NULL, selected = 26600),
            
            #checkboxInput("numbers", "Annotate clusters in plot"),
            checkboxInput("subset", "Subset cells (faster plots when many points present)")
            # selectInput(
            #   "subset_degree",
            #   label = "Subsetting severity",
            #   choices = c("Low" = 100, "High" = 40)
            # ),
            #downloadButton("downloadOverview", label = "Overview vis"),
            #downloadButton("downloadGeneTSNE", label = "Gene expr. vis"),
            #downloadButton("downloadGeneViolin", label = "Gene expr. violins")
        ),
    
    
    
        mainPanel(
            id="main",
            width=10,
            titlePanel("Rabbit Gastrulation Atlas"),
        
        
        
            tabsetPanel(
                id = "tabs",
                
                tabPanel(
                    "Dataset overview",
                    id = "overiew",
                    plotOutput("data"),
                    
                ),
                
                tabPanel(
                    "Cell type markers",
                    id = "markers"
                    #plotOutput("data", width = big_plot_width, height = big_plot_height),
                    
                ),
                
                tabPanel(
                    "Compare cell types",
                    id = "celltype"
                    #plotOutput("data", width = big_plot_width, height = big_plot_height),
                    
                ),
                
                
                tabPanel(
                    "Compare trajectories",
                    id = "trajectory"
                    #plotOutput("data", width = big_plot_width, height = big_plot_height),
                    
                )
            )
        )
        
    )
    
))
