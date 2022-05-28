
library(shiny)
library(vitessceR)
library(scrabbitr)


shinyServer(function(input, output, session) {


  output$vitessce_visualization <- render_vitessce(expr = {

    # Configure Vitessce
    #base_url <- "http://localhost:8080/"
    base_url <- "https://content.cruk.cam.ac.uk/jmlab/RabbitGastrulation2022/scrabbit-web/"

    # Create Vitessce view config
    vc <- VitessceConfig$new("Ton, Keitley et. al. 2022")
    dataset <- vc$add_dataset("RabbitGastrulation2022")$add_file(
      url = paste0(base_url, "r_data_store.zarr"),
      data_type = DataType$CELLS,
      file_type = "anndata-cells.zarr",
      options = list(mappings= list(UMAP = list(key = "obsm/X_umap", dims = c(0,1)),
                                    TSNE = list(key = "obsm/X_tsne", dims = c(0,1)),
                                    FA = list(key = "obsm/X_draw_graph_fa", dims = c(0,1))),
                     factors = c("obs/celltype", "obs/stage", "obs/somite_count",
                     "obs/anatomical_loc", "obs/singler"))
    )$add_file(
      url = paste0(base_url, "r_data_store.zarr"),
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
      url = paste0(base_url, "r_data_store.zarr"),
      data_type = DataType$EXPRESSION_MATRIX,
      file_type = "anndata-expression-matrix.zarr",
      options = list(matrix = "X")
    )$add_file(
      data_type = DataType$RASTER,
      file_type = FileType$RASTER_JSON,
      options = list(renderLayers = list("Histology test"),
                     schemaVersion = "0.0.2",
                     images = list(vitessceR::obj_list(name = "Histology test",
                                                       url = paste0(base_url, "histology/gd7_test_image_16k.ome.tif"),
                                                       type = "ome-tiff",
                                                       metadata = list(omeTiffOffsetsUrl = paste0(base_url, "histology/gd7_test_image_16k.json"))
                     ))
      ))




    spatial <- vc$add_view(dataset, Component$SPATIAL)
    #spatial_layers <- vc$add_view(dataset, Component$LAYER_CONTROLLER)

    scatterplot_umap <- vc$add_view(dataset, Component$SCATTERPLOT, mapping = "UMAP")
    scatterplot_tsne <- vc$add_view(dataset, Component$SCATTERPLOT, mapping = "TSNE")
    scatterplot_fa <- vc$add_view(dataset, Component$SCATTERPLOT, mapping = "FA")

    gene_list <- vc$add_view(dataset, Component$GENES)
    cell_sets <- vc$add_view(dataset, Component$CELL_SETS)

    celltype_colours <- scrabbitr::getCelltypeColours()
    celltype_colours_list <- lapply(names(celltype_colours), function(celltype) {
      out <- obj_list(path = c("Cell type", celltype))
      out$color <- as.vector(col2rgb(celltype_colours[celltype]))
      return(out)
    })

    c_scopes <- vc$add_coordination(c(CoordinationType$CELL_SET_COLOR))
    c_scopes[[1]]$set_value_raw(celltype_colours_list)

    scatterplot_umap$use_coordination(c_scopes)
    cell_sets$use_coordination(c_scopes)
    scatterplot_tsne$use_coordination(c_scopes)
    scatterplot_fa$use_coordination(c_scopes)

    vc$layout(
      hconcat(
        vconcat(scatterplot_umap,
          hconcat(scatterplot_tsne,scatterplot_fa)
        ), vconcat(gene_list, cell_sets),
        hconcat(spatial)
      )

    )

    vc$widget(theme = "light")
  })



})


