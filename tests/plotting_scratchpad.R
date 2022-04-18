

mart = useMart("ensembl", dataset = paste0("hsapiens","_gene_ensembl"))

h_genes <- grep("ENSG+", r_rowData$gene_name, value=TRUE)
h_genes_ensembl = getBM(attributes = c("ensembl_gene_id", "external_gene_name"),
                     filters = "ensembl_gene_id",
                     values = h_genes,
                     mart = mart)


rownames(r_rowData) <- r_rowData$ensembl_id
r_rowData[h_genes_ensembl$ensembl_gene_id, "gene_name"] <- paste0(h_genes_ensembl[,"external_gene_name"],"_HUMAN")
saveRDS(r_rowData, "data/rabbit/rowData.rds")


coords <- as.data.frame(r_reducedDims[[input$dimred]])
names(coords) <- c("X", "Y")

counts <- as.numeric(link[match(as.character(input$gene),
                               as.character(r_rowData[,"gene_name"])),])

order = order(counts)

celltypes <- r_colData$celltype


p <- ggplot(mapping = aes(x = celltypes, y = counts, fill = celltypes)) +
  scale_fill_manual(values=scrabbitr::getCelltypeColours()) + geom_boxplot() +
  theme(legend.position = "none")



library(dplyr)
library(ggrepel)

.calcEuclidean <- function(x1,y1,x2,y2) (x1-y1)**2 + (x2-y2)**2

palette <- scrabbitr::getCelltypeColours()

col_data <- as.data.frame(r_colData)
col_data$group <- col_data[["celltype"]]


col_data <- cbind(col_data, coords)


# Get mean position for each group
mean_data <- col_data %>% group_by(group) %>% summarize_at(.vars = vars(X,Y),.funs = c("mean"))
mean_data <- as.data.frame(mean_data[complete.cases(mean_data),])
rownames(mean_data) <- mean_data$group

# Get position of closest cell to group mean
label_pos <- col_data %>% group_by(group) %>%  filter(
  .calcEuclidean(X, mean_data[group,"X"], Y, mean_data[group,"Y"]) ==
    min(.calcEuclidean(X, mean_data[group,"X"], Y, mean_data[group,"Y"])))

# Wrap long labels
#label_pos$group_wrapped <- stringr::str_wrap(label_pos$group , width = 10)
p <- ggplot(col_data, aes_string(x="X",y="Y",colour="celltype")) +
  scattermore::geom_scattermore() +
  geom_text_repel(data=label_pos, aes(x=X, y=Y,label=celltype_id,segment.colour=group),color="black",
                  min.segment.length = 0,box.padding = 0.5,max.overlaps=Inf,size=3,force=10,
                  segment.size = 1,fontface = 'bold') +
  coord_cartesian(clip = "off") +
  scale_colour_manual(aesthetics=c("color","segment.colour"),
                      values=palette[col_data$celltype],drop=TRUE) +
 # xlab(paste0(input$dimred, "_1")) + ylab(paste0(input$dimred,"_2")) +

  theme_void()+
  theme(legend.position="none",
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text=element_blank(),
        axis.ticks=element_blank(),
        aspect.ratio=1)





