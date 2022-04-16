
library(shiny)


big_plot_width = "900px"
big_plot_height = "500px"

narrower_plot_width = "650px"


shinyUI(navbarPage(title="RabbitGastrulation2022",

                   tabPanel("Landing page",
                        includeHTML("html/home.html")
                   ),

                   tabPanel("Query expression",
                        sidebarLayout(
                            sidebarPanel(
                                id="sidebar",
                                width=3,
                                h3("Plot options"),

                                selectInput(
                                    "dimred",
                                    "Dimensionality reduction",
                                    choices = c("UMAP" = "UMAP",
                                                "TSNE" = "TSNE",
                                                "ForceAtlas2" = "FA")
                                ),

                                selectizeInput("ensemblId",
                                               "Ensembl ID",
                                               choices=NULL),

                                selectizeInput("gene",
                                               "Gene",
                                               choices=NULL),


                            ),

                            mainPanel(id="main",
                                      width=8,
                                      plotOutput("gene_plot",
                                                 width = narrower_plot_width,
                                                 height = big_plot_height)
                            )
                        )

                    ),


                   tabPanel("Genome annotation",
                            includeHTML("html/GA_igv.html"),
                   ),

                   tabPanel("Compare neighbourhoods 3D",
                                includeHTML("html/compare_neighbourhoods_3d.html"),
                                HTML('<div id="nhoods3dDiv"></div>'),
                                includeHTML("html/compare_nhoods_3d.html"),

                   )
        )

)



