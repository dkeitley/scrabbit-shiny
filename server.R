library(shiny)
library(ggplot2)
library(viridis)
library(ggrastr)

# Load data
temp_dir <- "G:/My Drive/Postgrad/PhD/Projects/rabbit-gastrulation-atlas/RabbitGastrulation2021/data-in/rabbit/logcounts_hdf5array_rowchunks.h5"
link <- HDF5Array::HDF5Array(temp_dir, name='logcounts',as.sparse = TRUE)
r_reducedDims <- readRDS("data/rabbit/reducedDims.rds")
r_rowData <- readRDS("data/rabbit/rowData.rds")

#umap_plot <- blankDimRed()

# blankDimRed <- function() {
#
#   coords <- getDimRed()
#
#   p <- ggplot(mapping = aes(x = coords[,1], y = coords[,2])) +
#     geom_point(size=0.1, alpha=0.7) +
#     xlab(paste0(input$dimred, "_1")) + ylab(paste0(input$dimred, "_2")) +
#     theme_linedraw() +
#     theme(panel.grid.major = element_blank(),
#           panel.grid.minor = element_blank(),
#           axis.text=element_blank(),
#           axis.ticks=element_blank(),
#           aspect.ratio=1)
#
#   return(p)
#
# }


shinyServer(function(input, output, session) {


  getDimRed <- reactive({
    coords <- as.data.frame(r_reducedDims[[input$dimred]])
    names(coords) <- c("X", "Y")
    return(coords)
  })


  getCounts <- reactive({
    count <- as.numeric(link[match(as.character(input$gene),
                                   as.character(r_rowData[,"gene_name"])),])
    return(count)
  })


  updateSelectizeInput(session = session, inputId = 'gene',
                       choices = r_rowData[,"gene_name"],
                       server = TRUE, selected = "GATA1")



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
    p <- ggrastr::rasterise(p, dpi = 300)

    return(p)

  })



  output$gene_plot = renderPlot({
    validate(
      need(input$gene %in% r_rowData[,"gene_name"],
           "Please select a gene; if you have already selected one, this gene is not in our annotation." )
    )
    return(plotExpression())
  })






})


