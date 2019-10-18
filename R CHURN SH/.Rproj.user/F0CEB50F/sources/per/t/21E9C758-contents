


only_numeric_variables <- function(data){
  
  tokeep <- which(sapply(data, is.numeric))
  data = data[ , tokeep]
  
  
  return(data)
}

CorrelationGraph <- function(dt.train, tam= 1.5, figures.dir){
  
  library(dplyr)
  library(reshape2)
  d_cor <- as.matrix(cor(dt.train, use = "pairwise.complete.obs"))
  d_cor_melt         <- arrange(melt(d_cor), -abs(value))
  d_cor_melt         <- as.data.table(d_cor_melt)
  
  d <- ggplot(data = d_cor_melt, aes(x=reorder(Var1, abs(value)), y=reorder(Var2, abs(value)), fill=value)) 
  d <- d + geom_tile() + xlab('') + ylab('')
  d <- d + scale_fill_gradient2(low = "orange", high = "blue", mid = "white", 
                                midpoint = 0, limit = c(-1,1), space = "Lab", 
                                name="Pearson\nCorrelation") 
  d <- d + geom_text(aes(Var1, Var2, label = round(value, 2)), color = "black", size = 4) 
  #d <- d + geom_tile(aes(fill = value), color='white') 
  d <- d + theme(axis.text.x = element_text(angle = 45, hjust = 1)) 
  d <- d + theme(axis.title.y = element_text(size = rel(tam)))
  d <- d + theme(axis.text.y = element_text(size = rel(tam)))
  d <- d + theme(axis.text.x = element_text(size = rel(tam)))
  d <- d + theme(axis.title.x = element_text(size = rel(tam)))
  d <- d + theme(legend.text = element_text(size = tam*10))
  d <- d + theme(legend.title = element_text(size = tam*10))
  
  plot.file <- paste0(figures.dir,'correlation_3', ".png")
  ggsave(plot.file, width=200, height=200, units="mm")
  
  return(d)
}
