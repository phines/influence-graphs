#! /usr/bin/Rscript

# Inputs
nodefile <- "ig_nodes.csv"
linkfile <- "ig_links.csv"

# Load libraries
library("qgraph")
library("methods")

# Load the node, link data
nodes <- read.csv(nodefile)
links <- read.csv(linkfile)
#nodes <- nodes[order(rownames(nodes)),]
#links <- links[order(rownames(links)),]

print(nodes)
print(links)
#quit();
#node_locs <- as.matrix(subset(nodes,select=c("x","y")))
node_sizes <- as.matrix(subset(nodes,select=c("vsize")))
#rownames(node_table) <- subset(nodes,select="name")
#print(node_locs)
node_sizes <- sqrt(node_sizes)*5
link_sizes <- as.matrix(subset(links,select=c("width")))
#print(node_sizes)

#qgraph(links,esize=5,gray=TRUE,labels=TRUE,layout=node_locs)
pdf("graph.pdf",width=7,height=5)
#qgraph(links,esize=5,gray=TRUE,labels=TRUE,vsize=node_sizes)
qgraph(links,esize=link_sizes,gray=TRUE,labels=TRUE)
#dev.off()
