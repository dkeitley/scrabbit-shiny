
library(shiny)

#setwd("G:/My Drive/Postgrad/PhD/Projects/scrabbit-shiny/")

big_plot_width = 9 * 1.5
big_plot_height = 5 * 1.5


shinyUI(navbarPage(title="RabbitGastrulation2021",

                   tabPanel("Landing page",



                   ),


                   tabPanel("Genome annotation",
                            #tags$head(tags$script(src="igv.min.js")),
                            #HTML('<div id="igvDiv" style="padding-top: 10px;padding-bottom: 10px; border:1px solid lightgray"></div>'),
                            #tags$script(src = "igv.js")
                            includeHTML("GA_igv.html"),


                   ),

                   tabPanel("Compare neighbourhoods 3D",
                                includeHTML("compare_neighbourhoods_3d.html"),
                                HTML('<div id="nhoods3dDiv"></div>'),
                                includeHTML("compare_nhoods_3d.html"),

                   )
    )

)



    #tags$head(tags$script(src="igv.min.js")),

    # sidebarLayout(
    #     sidebarPanel(
    #         id="sidebar",
    #         # style = "position:fixed;width:15%;",
    #         width = 2,
    #         h3("Plot options"),
    #
    #
    #         #SIDEBAR INPUTS
    #
    #         selectInput(
    #             "coord_type",
    #             "Projection type",
    #             choices = c("UMAP" = "umap",
    #                         "t-SNE" = "tsne"),
    #             selected="umap"
    #         ),
    #         selectInput(
    #             "stage",
    #             "Developmental stage",
    #             choices = c(
    #                 "All timepoints" = "all",
    #                 "GD7" = "gd7" ,
    #                 "GD8" ="gd8",
    #                 "GD9" = "gd9"
    #             ),
    #             selected = "all"
    #         ),
    #
    #         selectInput(
    #             "colourby",
    #             "Plot colour",
    #             choices = c(
    #                 "Cell type" = "celltype",
    #                 "Clusters" = "cluster",
    #                 "Timepoint" = "stage",
    #                 "Sample" = "sample"
    #             ),
    #             selected = "celltype"
    #         ),
    #         selectizeInput("gene", "Gene", choices = NULL, selected = 26600),
    #
    #         #checkboxInput("numbers", "Annotate clusters in plot"),
    #         checkboxInput("subset", "Subset cells (faster plots when many points present)")
    #         # selectInput(
    #         #   "subset_degree",
    #         #   label = "Subsetting severity",
    #         #   choices = c("Low" = 100, "High" = 40)
    #         # ),
    #         #downloadButton("downloadOverview", label = "Overview vis"),
    #         #downloadButton("downloadGeneTSNE", label = "Gene expr. vis"),
    #         #downloadButton("downloadGeneViolin", label = "Gene expr. violins")
    #     ),    # sidebarLayout(
    #     sidebarPanel(
    #         id="sidebar",
    #         # style = "position:fixed;width:15%;",
    #         width = 2,
    #         h3("Plot options"),
    #
    #
    #         #SIDEBAR INPUTS
    #
    #         selectInput(
    #             "coord_type",
    #             "Projection type",
    #             choices = c("UMAP" = "umap",
    #                         "t-SNE" = "tsne"),
    #             selected="umap"
    #         ),
    #         selectInput(
    #             "stage",
    #             "Developmental stage",
    #             choices = c(
    #                 "All timepoints" = "all",
    #                 "GD7" = "gd7" ,
    #                 "GD8" ="gd8",
    #                 "GD9" = "gd9"
    #             ),
    #             selected = "all"
    #         ),
    #
    #         selectInput(
    #             "colourby",
    #             "Plot colour",
    #             choices = c(
    #                 "Cell type" = "celltype",
    #                 "Clusters" = "cluster",
    #                 "Timepoint" = "stage",
    #                 "Sample" = "sample"
    #             ),
    #             selected = "celltype"
    #         ),
    #         selectizeInput("gene", "Gene", choices = NULL, selected = 26600),
    #
    #         #checkboxInput("numbers", "Annotate clusters in plot"),
    #         checkboxInput("subset", "Subset cells (faster plots when many points present)")
    #         # selectInput(
    #         #   "subset_degree",
    #         #   label = "Subsetting severity",
    #         #   choices = c("Low" = 100, "High" = 40)
    #         # ),
    #         #downloadButton("downloadOverview", label = "Overview vis"),
    #         #downloadButton("downloadGeneTSNE", label = "Gene expr. vis"),
    #         #downloadButton("downloadGeneViolin", label = "Gene expr. violins")
    #     ),



        # mainPanel(
        #     id="main",
        #     width=10,
        #     titlePanel("Rabbit Gastrulation Atlas"),
        #
        #
        #
        #     tabsetPanel(
        #         id = "tabs",
        #
        #         tabPanel(
        #             "Landing page",
        #             id = "landing"
        #
        #         ),
        #
        #         tabPanel(
        #             "Genome annotation",
        #             id = "genome",
        #             plotOutput("igv_plot", "900px", "500px")
        #
        #
        #         ),
        #
        #         tabPanel(
        #             "Cell type annotation",
        #             id = "celltype_annotation"
        #         ),
        #
        #
        #         tabPanel(
        #             "Compare expression",
        #             id = "expression"
        #             #plotOutput("data"),
        #
        #         ),
        #
        #
        #         tabPanel(
        #             "Compare cell types",
        #             id = "celltype"
        #             #plotOutput("data", width = big_plot_width, height = big_plot_height),
        #
        #         ),
        #
        #
        #         tabPanel(
        #             "Compare trajectories",
        #             id = "trajectory"
        #             #plotOutput("data", width = big_plot_width, height = big_plot_height),
        #
        #         )
        #     ),
        #     HTML('  <div id="igvDiv" style="padding-top: 10px;padding-bottom: 10px; border:1px solid lightgray"></div>')
        #
        # )
        #

    #)



