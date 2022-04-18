library(shiny)
library(ggplot2)
library(viridis)
library(ggrastr)
library(vitessceR)
library(dplyr)
library(ggrepel)
library(scrabbitr)


# Load data
link <- HDF5Array::HDF5Array("data/rabbit/logcounts_hdf5array_rowchunks.h5", name='logcounts',as.sparse = TRUE)
r_reducedDims <- readRDS("data/rabbit/reducedDims.rds")
r_rowData <- readRDS("data/rabbit/rowData.rds")
r_colData <- readRDS("data/rabbit/colData.rds")


shinyServer(function(input, output, session) {


  getDimRed <- reactive({
    coords <- as.data.frame(r_reducedDims[[input$dimred]])[,1:2]
    names(coords) <- c("X", "Y")
    return(coords)
  })


  getCounts <- reactive({
    count <- as.numeric(link[match(as.character(input$gene),
                                   as.character(r_rowData[,input$gene_format])),])
    return(count)
  })



  # Check which gene format selected
  observeEvent(input$gene_format, {
    if (input$gene_format == "gene_name") {
      updateSelectizeInput(session = session, inputId = 'gene',
                           choices = r_rowData[,"gene_name"],
                           server = TRUE, selected = "GATA1")
    } else if (input$gene_format == "ensembl_id") {
      updateSelectizeInput(session = session, inputId = 'gene',
                           choices = r_rowData[,"ensembl_id"],
                           server = TRUE, selected = "ENSOCUG00000025597")
    }
  })

  updateSelectizeInput(session = session, inputId = 'cell_obs',
                       choices = colnames(r_colData)[
                         colnames(r_colData) %in% c("sample", "dissection","stage",
                                                    "somite_count", "celltype",
                                                    "singler", "cluster")],
                       server = TRUE, selected = "celltype")





  plotExpression <- reactive({

    coords <- getDimRed()
    counts <- getCounts()

    order = order(counts)


    p <- ggplot(mapping = aes(x = coords[order,1], y = coords[order,2], col = counts[order])) +
      scattermore::geom_scattermore(size=1, alpha=1, shape=".") +
      scale_colour_viridis(name = input$gene, direction=-1) +
      xlab(paste0(input$dimred, "_1")) + ylab(paste0(input$dimred, "_2")) +
      theme_linedraw() +
      theme(panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            axis.text=element_blank(),
            axis.ticks=element_blank(),
            aspect.ratio=1)

    return(p)

  })

  plotObsExp <- reactive({

    counts <- getCounts()
    palette <- scrabbitr::getPalette(r_colData[[input$cell_obs]])
    col_data <- r_colData

    if(length(unique(r_colData[[input$cell_obs]]))>20) {
      col_data$obs_id <- scrabbitr::makeObsIDs(col_data[[input$cell_obs]])[col_data[[input$cell_obs]]]
      obs_id <- paste0(col_data$obs_id, " - ", col_data[[input$cell_obs]])

      # Order according to cell type ID
      label_order <- order(col_data[["obs_id"]])
      obs <- factor(obs_id,
                    levels = unique(obs_id[label_order]),ordered = TRUE)

      palette <- scrabbitr::getPalette(col_data[[input$cell_obs]])
      obs_ids <- col_data[["obs_id"]]

      col_data$obs_colour <- palette[col_data[[input$cell_obs]]]

      palette <- palette[names(palette) %in% names(obs_ids)]
      names(palette) <- paste0(obs_ids[names(palette)], " - ", names(palette))

    } else { obs <- as.character(col_data[[input$cell_obs]]) }


    p <- ggplot(mapping = aes(x = obs, y = counts, fill = obs)) +
      scale_fill_manual(values=palette[obs]) +
      geom_boxplot(outlier.size = 0.5) +
      scale_y_continuous(expand = c(0, 0)) +
      xlab(input$cell_obs) +
      theme_linedraw() +
      theme(legend.position = "none",
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            axis.text.x = element_text(angle = 90,hjust = 0.95,
                                       vjust = 0.2))

    return(p)

  })



  plotCellObs <- reactive({

    palette <- scrabbitr::getPalette(as.character(r_colData[[input$cell_obs]]))
    .calcEuclidean <- function(x1,y1,x2,y2) (x1-y1)**2 + (x2-y2)**2


    coords <- getDimRed()
    col_data <- as.data.frame(r_colData)
    col_data$group <- as.character(col_data[[input$cell_obs]])
    col_data <- cbind(col_data, coords)

    p <- ggplot(col_data, aes_string(x="X",y="Y",colour="group")) +
      scattermore::geom_scattermore() +
      scale_colour_manual(aesthetics=c("color"),
                          values=palette,drop=TRUE)

    if(input$show_labels) {

      if(length(unique(col_data$group)) > 20) {
        col_data$obs_id <- scrabbitr::makeObsIDs(col_data[[input$cell_obs]])[col_data[[input$cell_obs]]]
        r_colData$obs_id <- col_data$obs_id
        label <- "obs_id"
      }
      else {
        label <- input$cell_obs
      }

      # Get mean position for each group
      mean_data <- col_data %>% group_by(group) %>% summarize_at(.vars = vars(X,Y),.funs = c("mean"))
      mean_data <- as.data.frame(mean_data[complete.cases(mean_data),])
      rownames(mean_data) <- mean_data$group

      # Get position of closest cell to group mean
      label_pos <- col_data %>% group_by(group) %>%  filter(
        .calcEuclidean(X, mean_data[group,"X"], Y, mean_data[group,"Y"]) ==
          min(.calcEuclidean(X, mean_data[group,"X"], Y, mean_data[group,"Y"])))

      label_text <- paste0()
      p <- p + geom_text_repel(data=label_pos, label=label_pos[[label]],
                               segment.colour=palette[label_pos$group],
                               color="black",
                               min.segment.length = 0,box.padding = 0.5,max.overlaps=Inf,size=4,force=10,
                               segment.size = 0.8,fontface = 'bold') +
        coord_cartesian(clip = "off") +
        scale_colour_manual(aesthetics=c("segment.colour"),
                            values=palette[col_data[[input$cell_obs]]],drop=TRUE)
    }

    p <- p + theme_void() +
      theme(legend.position="none",
            legend.spacing.x = unit(0.01, 'cm'),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            axis.text=element_blank(),
            axis.ticks=element_blank(),
            aspect.ratio=1)


    return(p)

  })



  output$gene_plot = renderPlot({
    validate(
      need(input$gene %in% r_rowData[,"gene_name"] | input$gene %in% r_rowData[,"ensembl_id"],
           "Please select a gene; if you have already selected one, this gene is not in our annotation." )
    )
    return(plotExpression())
  })

  output$obs_plot = renderPlot({
    validate(
      need(input$cell_obs %in% colnames(r_colData),
           "Cell obs must be one of the available metadata fields" )
    )
    return(plotCellObs())
  })


  output$gene_celltype_boxplot <- renderPlot({
    validate(
      need(input$gene %in% r_rowData[,"gene_name"] | input$gene %in% r_rowData[,"ensembl_id"],
           "Please select a gene; if you have already selected one, this gene is not in our annotation." )
    )
    return(plotObsExp())
  })



  output$vitessce_visualization <- render_vitessce(expr = {
    vc <- VitessceConfig$new("My config")
    dataset <- vc$add_dataset("My dataset")
    dataset <- dataset$add_object(w)
    scatterplot <- vc$add_view(dataset, Component$SCATTERPLOT, mapping = "PCA")
    vc$layout(scatterplot)
    vc$widget()
  })


  # Legacy code for displaying image instead of obs plot
  output$obs_image <- renderUI({
    if(input$cell_obs == "celltype"){
      img(src='res/annotated_celltype_umap.png',
          align = "left", width=600)
    }
    else if(input$cell_obs == "stage"){
      img( src = "res/stage_umap.png",
           align = "left", width=600)
    }

  })


})


