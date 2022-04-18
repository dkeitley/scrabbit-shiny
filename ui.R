
library(shiny)


big_plot_width = "600px"
big_plot_height = "500px"

narrower_plot_width = "500px"


shinyUI(navbarPage(title="RabbitGastrulation2022",

                   tabPanel("Landing page",
                        includeHTML("html/home.html")
                   ),

                   tabPanel("Query expression",
                      fluidRow(style = "background-color:#DFDFDE;",width=800,
                        column(2,
                          #h3("Plot options"),
                            selectInput(
                                    "dimred",
                                    "Dimensionality reduction",
                                    choices = c("UMAP" = "UMAP",
                                                "TSNE" = "TSNE",
                                                "PCA" = "PCA",
                                                "ForceAtlas2" = "FA")
                                )),
                        column(2,
                               #h3("Plot options"),
                               selectInput(
                                 "cell_obs",
                                 "Cell info",
                                 choices = NULL)
                               ),
                        column(2,
                               #br(), br(), br(),
                               checkboxInput(inputId = "show_labels", "Show labels",
                                             value = TRUE)

                        ),
                        column(2,
                                #br(), br(), br(),
                                radioButtons(inputId = "gene_format",
                                             label = "Gene format:",
                                             choices = c("ensembl_id", "gene_name"),
                                             selected = "gene_name")
                                ),
                        column(2,
                                #br(), br(), br(),
                                # selectizeInput("ensemblId",
                                #                "Ensembl ID",
                                #                choices=NULL),

                                selectizeInput("gene",
                                               "Gene",
                                               choices=NULL),


                            )),
                      br(), br(),

                            mainPanel(id="main",
                                      width=25,
                                      fluidRow(style="margin-left:5px",
                                        splitLayout(cellWidths = c("50%", "50%"),

                                      #uiOutput("obs_image"),

                                      # img(src='res/annotated_celltype_umap.png',
                                      #     align = "left", width=600),
                                      plotOutput("obs_plot",
                                                 width = 500,
                                                 height = 500),

                                      plotOutput("gene_plot",
                                                 width = narrower_plot_width,
                                                 height = big_plot_height)
                                      ),
                                      plotOutput("gene_celltype_boxplot",
                                                 width = 1200,
                                                 height=300)

                            ))
                        )

                    ,


                   tabPanel("Genome annotation",
                            includeHTML("html/GA_igv.html"),
                   ),

                   tabPanel("Compare neighbourhoods 3D",
                                includeHTML("html/compare_neighbourhoods_3d.html"),
                                HTML('<div id="nhoods3dDiv"></div>'),
                                includeHTML("html/compare_nhoods_3d.html"),

                   ),

                   # tabPanel("Vitessce",
                   #    vitessce_output(output_id = "vitessce_visualization",
                   #                    height = "600px"),
                   # )
        )

)



