
library(shiny)
library(vitessceR)


big_plot_width = "600px"
big_plot_height = "500px"

narrower_plot_width = "500px"

vitessce_height = "600px"


image_files <- read.csv("https://content.cruk.cam.ac.uk/jmlab/RabbitGastrulation2022/scrabbit-web/imaging/ome-tiff-metadata.csv")
colnames(image_files)[1] <- "Dataset"


shinyUI(navbarPage(title="RabbitGastrulation2022",

                   tabPanel("Landing page",
                        includeHTML("html/home.html")
                   ),

                   tabPanel("scRNA-seq",

                            vitessce_output(output_id = "vitessce_rna",
                                            height = vitessce_height),
                            h4("Notes:"),
                            HTML("<ul><li>To make the gene expression as clear as possible, we recommend using the settings menu to switch the 'Cell Opacity Mode' and 'Cell Radius Mode' to manual and adjusting the 'Gene Expression Colormap Range'.</li>
                                 <li>Human gene alignments added in our modified genome annotation are listed by their Ensembl codes. E.g. Six3 is listed as 'ENSG00000138083'.</li>
                                 <li>Many well-studied genes may not have gene name annotations in OryCun 2.0 and may be listed by their Ensembl code. If a gene of interest is missing, Ensembl Compara can be used to identify related gene features. For example, SOX17 is not listed in the OryCun2.0 reference, however 'ENSOCUG00000037040' closely aligns with the human SOX17 gene and is differentially expressed in the PGCs.   See link - <a href='https://www.ensembl.org/Homo_sapiens/Location/Compara_Alignments/Image?align=680;db=core;g=ENSG00000164736;r=8:54457935-54460892;t=ENST00000260653'>Human-Rabbit alignment of SOX17</a></li>
                                 </ul>")



                   ),



                   tabPanel("Histology/RNAscope",

                            selectInput("dataset", "Select a dataset:",
                                        list(`Histology_GD7` = image_files$Dataset[image_files$Stage=="GD7" & image_files$Type=="Histology"],
                                             `Histology_GD8` = image_files$Dataset[image_files$Stage=="GD8" & image_files$Type=="Histology"],
                                             `Histology_GD9` = image_files$Dataset[image_files$Stage=="GD9" & image_files$Type=="Histology"],
                                             `RNAscope_GD7` = image_files$Dataset[image_files$Stage=="GD7" & image_files$Type=="RNAscope"],
                                             `RNAscope_GD8` = image_files$Dataset[image_files$Stage=="GD8" & image_files$Type=="RNAscope"],
                                             `RNAscope_GD9` = image_files$Dataset[image_files$Stage=="GD9" & image_files$Type=="RNAscope"]),
                                        selected = image_files$Dataset[image_files$Stage=="GD7" & image_files$Type=="Histology"][1],
                                        width="400px"),

                            selectInput("image", "Select an image:", choices=NULL,
                                        selected = T,
                                        width = "600px"),


                            vitessce_output(output_id = "vitessce_imaging",
                                            height = vitessce_height),
                            h4("Notes:"),
                            HTML("<ul><li> <p style='color:red'> There is currently a known issue preventing OME-TIF images from loading in VitessceR (Github issue <a href=https://github.com/vitessce/vitessceR/issues/65>#65</a>). While this is being addressed, the histology/RNAscope images can explored inside a Jupyter notebook.  See <a href=https://github.com/MarioniLab/RabbitGastrulation2022/blob/master/Histology_RNAscope/explore_images.ipynb>here</a>. </p> </ul>"),




                   ),


                   tabPanel("Genome annotation",
                            includeHTML("html/GA_igv.html"),
                            h4("Notes:"),
                            HTML("<ul><li>The read coverage shown here is from a single GD8 sample (SIGAC11).</li>
                            <li>If no data is showing at startup, try switching chromosomes or zooming in/out."),

                   ),

                    tabPanel("Compare neighbourhoods 3D",
                                 includeHTML("html/compare_nhoods_page.html"),
                                 HTML('<div id="nhoods3dDiv"></div>'),
                                 includeHTML("html/compare_nhoods_3d.html"),

                    )


        )

)



