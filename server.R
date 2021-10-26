
library(shiny)
library(ggplot2)
library(data.table)
library(profvis)


# umap2 <- data.table::fread(paste0("G:\\My Drive\\Postgrad\\PhD\\Projects\\data\\Ton_2020\\v2\\visual\\","umap.tab"),
#                            sep=" ",header = F,data.table=F)


#umap <- read.table(paste0("G:\\My Drive\\Postgrad\\PhD\\Projects\\data\\Ton_2020\\v2\\visual\\","umap.tab"))


#logcounts <- TENxMatrix(file = "data.h5", group = "assays/logcounts")



shinyServer(function(input, output) {




  # output$igvPlot <- renderUI({
  #
  # })
    # plotOverview = reactive({
    #
    #     plot = ggplot(data = umap2,
    #                   mapping = aes(x = V1,
    #                                 y = V2,
    #                                 col = "#005579")) +
    #         geom_point(size = 1,
    #                    alpha = 0.9) +
    #         ggtitle("Test") + theme_classic() +
    #         theme(axis.title = element_blank(), axis.text = element_blank(), axis.ticks = element_blank(), axis.line = element_blank()) +
    #         coord_fixed(ratio = 0.8)
    #
    #     return(plot)
    # })
    #
    #
    # output$data = output$data_dummy = renderPlot({
    #     plotOverview()
    # })

})
