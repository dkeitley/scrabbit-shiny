
library(shiny)

shinyUI(navbarPage(title="RabbitGastrulation2021",

                   tabPanel("Landing page",
                        includeHTML("html/home.html")
                   ),

                   tabPanel("Query expression"),


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



