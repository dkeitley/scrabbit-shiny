
library(shiny)
library(vitessceR)


big_plot_width = "600px"
big_plot_height = "500px"

narrower_plot_width = "500px"


shinyUI(navbarPage(title="RabbitGastrulation2022",

                   tabPanel("Landing page",
                        includeHTML("html/home.html")
                   ),

                   tabPanel("Vitessce",
                            vitessce_output(output_id = "vitessce_visualization",
                                            height = "600px"),
                   ),


                   tabPanel("Genome annotation",
                            includeHTML("html/GA_igv.html"),
                   ),

                    tabPanel("Compare neighbourhoods 3D",
                                 includeHTML("html/compare_nhoods_page.html"),
                                 HTML('<div id="nhoods3dDiv"></div>'),
                                 includeHTML("html/compare_nhoods_3d.html"),

                    )


        )

)



