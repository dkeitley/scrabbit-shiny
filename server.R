
library(shiny)
library(vitessceR)


shinyServer(function(input, output, session) {


  output$vitessce_visualization <- render_vitessce(expr = {

    # Configure Vitessce
    #base_url <- "http://localhost:8080/"
    base_url <- "https://content.cruk.cam.ac.uk/jmlab/RabbitGastrulation2022/"

    # Create Vitessce view config
    vc <- VitessceConfig$new("Ton, Keitley et. al. 2022")
    dataset <- vc$add_dataset("RabbitGastrulation2022")$add_file(
      url = paste0(base_url, "r_data_store.zarr"),
      data_type = DataType$CELLS,
      file_type = "anndata-cells.zarr",
      options = list(mappings= list(UMAP = list(key = "obsm/X_umap", dims = c(0,1)),
                                    TSNE = list(key = "obsm/X_tsne", dims = c(0,1)),
                                    FA = list(key = "obsm/X_draw_graph_fa", dims = c(0,1))))
    )$add_file(
      url = paste0(base_url, "r_data_store.zarr"),
      data_type = DataType$EXPRESSION_MATRIX,
      file_type = "anndata-expression-matrix.zarr",
      options = list(matrix = "X")
    )

    # $add_file(
    #   url = paste0(base_url, "r_data_store.zarr"),
    #   data_type = DataType$CELL_SETS,
    #   file_type = "anndata-cell-sets.zarr",
    #   options = list(list(groupName = "Cell type", setName = "obs/celltype"))
    # )

    scatterplot_umap <- vc$add_view(dataset, Component$SCATTERPLOT, mapping = "UMAP")
    scatterplot_tsne <- vc$add_view(dataset, Component$SCATTERPLOT, mapping = "TSNE")
    scatterplot_fa <- vc$add_view(dataset, Component$SCATTERPLOT, mapping = "FA")

    gene_list <- vc$add_view(dataset, Component$GENES)


    vc$layout(
      hconcat(
        vconcat(scatterplot_umap,
          hconcat(scatterplot_tsne,scatterplot_fa)
        ), gene_list
      )
    )

    vc$widget()
  })



})


