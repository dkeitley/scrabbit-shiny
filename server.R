
library(shiny)
library(vitessceR)
library(scrabbitr)


# File listing images stored on content server
IMAGE_FILES <- read.csv("https://content.cruk.cam.ac.uk/jmlab/RabbitGastrulation2022/scrabbit-web/imaging/ome-tiff-metadata.csv")
colnames(IMAGE_FILES)[1] <- "Dataset"



# Checks that file requested is server file list
check_image_url <- function(image_url) {

  url_parts <- strsplit(test, "/")[[1]]
  image_file <- url_parts[length(url_parts)]
  image_file <- gsub("\\..*", "", image_file) # remove file type
  image_folder <- url_parts[length(url_parts)-1]

  if(!any(IMAGE_FILES[,1] %in% image_folder)) {
    return(FALSE)
  }

  if(!any(IMAGE_FILES[IMAGE_FILES[,1] == image_folder, "Image"] == image_file)) {
    return(FALSE)
  }

  return(TRUE)
}



shinyServer(function(input, output, session) {

  # Update image selection options based on dataset selected
  observeEvent(input$dataset,{
    updateSelectInput(session = session,
                      inputId = 'image',
                      label = "Select an image:",
                      choices=IMAGE_FILES$Image[IMAGE_FILES$Dataset == input$dataset])
  })


  # RNA-seq Vitessce visualisation
  output$vitessce_rna <- render_vitessce(expr = {

    # Configure Vitessce
    #DATA_URL <- "http://localhost:8080/"
    DATA_URL <- "https://content.cruk.cam.ac.uk/jmlab/RabbitGastrulation2022/scrabbit-web/"

    # Create Vitessce view config
    vc <- VitessceConfig$new("Ton, Keitley et. al. 2022")
    dataset <- vc$add_dataset("RabbitGastrulation2022")
    dataset$add_file(
      url = paste0(DATA_URL, "r_data_store.zarr"),
      data_type = DataType$CELLS,
      file_type = "anndata-cells.zarr",
      options = list(mappings= list(UMAP = list(key = "obsm/X_umap", dims = c(0,1)),
                                    TSNE = list(key = "obsm/X_tsne", dims = c(0,1)),
                                    FA = list(key = "obsm/X_draw_graph_fa", dims = c(0,1))),
                     factors = c("obs/celltype", "obs/stage", "obs/somite_count",
                     "obs/anatomical_loc", "obs/singler"))
    )$add_file(
      url = paste0(DATA_URL, "r_data_store.zarr"),
      data_type = DataType$CELL_SETS,
      file_type = "anndata-cell-sets.zarr",
      options = list(list(groupName = "Cell type", setName = "obs/celltype"),
                     list(groupName = "Developmental stage", setName = "obs/stage"),
                     list(groupName = "GD9 dissection", setName = "obs/anatomical_loc"),
                     #list(groupName = "Sample", setName = "obs/sample"),
                     list(groupName = "Somite count", setName = "obs/somite_count"),
                     list(groupName = "SingleR cell type", setName = "obs/singler"),
                     list(groupName = "Leiden res 1", setName = "obs/leiden_res1"),
                     list(groupName = "Leiden res 3", setName = "obs/leiden_res3"),
                     list(groupName = "Leiden res 5", setName = "obs/leiden_res5"),
                     list(groupName = "Leiden res 8", setName = "obs/leiden_res8"),
                     list(groupName = "Leiden res 10", setName = "obs/leiden_res10"))
    )$add_file(
      url = paste0(DATA_URL, "r_data_store.zarr"),
      data_type = DataType$EXPRESSION_MATRIX,
      file_type = "anndata-expression-matrix.zarr",
      options = list(matrix = "X")
    )

    scatterplot_umap <- vc$add_view(dataset, Component$SCATTERPLOT, mapping = "UMAP")
    scatterplot_tsne <- vc$add_view(dataset, Component$SCATTERPLOT, mapping = "TSNE")
    scatterplot_fa <- vc$add_view(dataset, Component$SCATTERPLOT, mapping = "FA")

    gene_list <- vc$add_view(dataset, Component$GENES)
    cell_sets <- vc$add_view(dataset, Component$CELL_SETS)

    celltype_colours <- scrabbitr::getCelltypeColours()
    celltype_colours_list <- lapply(names(celltype_colours), function(celltype) {
      out <- obj_list(path = c("Cell type", celltype))
      out$color = as.vector(col2rgb(celltype_colours[celltype]))
      return(out)
    })

    singler_colours_list <- lapply(names(celltype_colours), function(celltype) {
      out <- obj_list(path = c("SingleR cell type", celltype))
      out$color = as.vector(col2rgb(celltype_colours[celltype]))
      return(out)
    })

    stage_colours <- scrabbitr::getStageColours()
    stage_colours_list <- lapply(names(stage_colours), function(stage) {
      out <- obj_list(path = c("Developmental stage", stage))
      out$color = as.vector(col2rgb(stage_colours[stage]))
      return(out)
    })



   cluster_colours <- scrabbitr::getDiscreteColours(seq(1:100))
   names(cluster_colours) <- as.character(seq(0:99))
   clusters_colours_list <- NULL
   for( clusters in c("Leiden res 1", "Leiden res 3", "Leiden res 5",
                      "Leiden res 8", "Leiden res 10")) {

     cluster_colours_list <- lapply(names(cluster_colours), function(cluster) {
      out <- obj_list(path = c(clusters, cluster))
      out$color = as.vector(col2rgb(cluster_colours[cluster]))
      return(out)
     })
      clusters_colours_list <- c(clusters_colours_list, cluster_colours_list)
   }

   somite_colours <- viridis::viridis(6)
   names(somite_colours) <- c("0","4", "11","13","16","19")
   somite_colours_list <- lapply(names(somite_colours), function(somite) {
     out <- obj_list(path = c("Somite count", somite))
     out$color = as.vector(col2rgb(somite_colours[somite]))
     return(out)
   })

   dissection_colours <- c("Head"="#E52521",
                           "Trunk" = "#4B81EF",
                           "Tail" = "#39A85E",
                           "Yolk sac"= "#F7A418",
                           "Whole embryo" = "#C0BFB8")

   dissection_colours_list <- lapply(names(dissection_colours), function(dissection) {
     out <- obj_list(path = c("GD9 dissection", dissection))
     out$color = as.vector(col2rgb(dissection_colours[dissection]))
     return(out)
   })


    cell_set_colours <- c(celltype_colours_list,
                          stage_colours_list,
                          somite_colours_list,
                          singler_colours_list,
                          dissection_colours_list,
                          clusters_colours_list)

    c_scopes <- vc$add_coordination(c(CoordinationType$CELL_SET_COLOR))
    c_scopes[[1]]$set_value_raw(cell_set_colours)

    scatterplot_umap$use_coordination(c_scopes)
    cell_sets$use_coordination(c_scopes)
    scatterplot_tsne$use_coordination(c_scopes)
    scatterplot_fa$use_coordination(c_scopes)

    vc$layout(
      hconcat(
        vconcat(scatterplot_umap,
          hconcat(scatterplot_tsne,scatterplot_fa)
        ), vconcat(gene_list, cell_sets)
      )
    )

    vc$widget(theme = "light")
  })




  output$vitessce_imaging <- vitessceR::render_vitessce(expr = {

    # Configure Vitessce
    #IMAGE_URL <- "http://localhost:8080/"
    IMAGE_URL <- "https://content.cruk.cam.ac.uk/jmlab/RabbitGastrulation2022/scrabbit-web/imaging/"

    # Create Vitessce view config
    vc <- VitessceConfig$new("Ton, Keitley et. al. 2022")
    dataset <- vc$add_dataset("RabbitGastrulation2022")

    image_url <- paste0(IMAGE_URL, input$dataset, "/",  input$image, ".ome.tif")
    offset_url <- paste0(IMAGE_URL, input$dataset, "/", input$image, ".offsets.json")


    if(!check_image_url(image_url)) {stop("Invalid image requested.")}


    dataset$add_file(
      data_type = DataType$RASTER,
      file_type = FileType$RASTER_JSON,
      options = list(renderLayers = list(input$image),
                     schemaVersion = "0.0.2",
                     images = list(vitessceR::obj_list(name = input$image,
                                                       url = image_url,
                                                       type = "ome-tiff",
                                                       metadata = list(omeTiffOffsetsUrl = offset_url)
                     ))
      ))

    spatial <- vc$add_view(dataset, Component$SPATIAL)
    spatial_layers <- vc$add_view(dataset, Component$LAYER_CONTROLLER)

    vc$layout(
      hconcat(spatial, spatial_layers)
    )


    vc$widget(theme = "light")

  })



})




