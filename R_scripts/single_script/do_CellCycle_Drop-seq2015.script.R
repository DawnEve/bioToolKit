# aim: scRNAseq to determine cell cycle. 
# how to use: $ Rscript this.script.R xx.Seurat.obj [outputRoot [keyword]]
# Flaw: this method for cell line, as no phase G0 considered.
# source: 2015 cell, drop seq;
# Env: R 4.1.0
# v0.3 fix filter line.
# v0.4 for Seurat object

#
#Help on how to use this script: 
#1. input raw counts as expression data: row as gene, column as cell.
#2. seurat_clusters is requied.
#3. genelist of 5 phages are included in this script file.

start.time=Sys.time() # time

## Some best practice:
#1. once for a type of cells, many maybe inaccuracy
#2. if paired as treat(drug, stimulation, ...) and contrl: use normal to select genelist, then asign cell cycle to 2 groups.
#3. rm all 0 rows.
#4. 3'reads use log(cpm+1) as normalization step in step2; Full length may use log(tpm+1) Or log(rpkm+1)

if(0){
  # how to run as a script? 
  # in Docker shell R4:
  # $ whereis Rscript
  # $ /usr/local/bin/Rscript ~/data/scPolyA-seq2/chenxi/pipeline/script_single/do_CellCycle_Drop-seq2015.script.R \
  # /path/to/Seurat.obj.Rds /output/dir keyword
  # at least 1 parameters, or stop and give help information.
  #
  # example
  # $ /usr/local/bin/Rscript ~/data/scPolyA-seq2/chenxi/pipeline/script_single/do_CellCycle_Drop-seq2015.script.R \
  # /data/wangjl/scPolyA-seq2/chenxi/PBMC/UMAP/star_solo/scObj_final-PBMC_8plates.Star_Solo_PC25res0.8.CellCycle.withDEG.Seurat.Rds \
  # /data/wangjl/scPolyA-seq2/chenxi/PBMC/trajectory/dustbin/ CD4_PBMC
}
#seurat_filename="/data/wangjl/scPolyA-seq2/chenxi/PBMC/UMAP/star_solo/scObj_final-PBMC_8plates.Star_Solo_PC25res0.8.CellCycle.withDEG.Seurat.Rds"
#outputRoot="/data/wangjl/scPolyA-seq2/chenxi/PBMC/UMAP/cell_cycle/"
#keyword="CellCycle"

# ** Settings begin ###############
# default
myArgs<-commandArgs(TRUE)
if(length(myArgs)==0){
  stop("You must give at least 1 parameter to run CellCycle from Drop-seq2015:\n$ Rscript /path/to/this.script.R seurat_filename [outputRoot [keyword]]")
}

seurat_filename=myArgs[1]
outputRoot = "./"
keyword="CellCycle"

# set
if(! file.exists(seurat_filename) ){
  stop("input seurat file not exists: ", seurat_filename)
}

if(length(myArgs)>=2){
  outputRoot=myArgs[2] 
  # must end with /
  if(substring(outputRoot, nchar(outputRoot)) != "/"){
    outputRoot=paste0(outputRoot, "/")
  }
  # the dir must exist
  if(!dir.exists(outputRoot)){
    stop( sprintf("Error: dir not exist, outputRoot=%s", outputRoot) )
  }
}

if(length(myArgs)>=3){
  keyword=paste0(keyword, "_", myArgs[3])
  if( length(grep("/", myArgs[3]) )){
    stop( sprintf("Error: keyword must NOT contain '/', keyword=%s", myArgs[3]) )
  }
}

message( sprintf("###### \n=>parameters: \n\t seurat_filename=%s, outputRoot=%s, keyword=%s", 
                 seurat_filename, outputRoot, keyword) )
# ** Settings End ###############






# Functions & Tools ----

now=function(style=4){
  switch(
    EXPR = style,
    "1"={format(Sys.time(), '_%Y%m%d_%H%M%S')},
    "2"={format(Sys.time(), '%Y%m%d_%H%M%S')},
    "3"={format(Sys.time(), '[%Y%m%d_%H%M%S]')},
    "4"={format(Sys.time(), '[%Y/%m/%d_%H:%M:%S]')},
    stop("Invalid style. Please choose one of 1,2,3,4")
  )
}
#now()

#helper: return cell phase names
getCellPhaseList=function(){
  c('G1S', 'S','G2M','M','MG1');
}



# colors
library(RColorBrewer)
colorset.cycle5 = RColorBrewer::brewer.pal(n = 6,name = "Set2")[1:5]
names(colorset.cycle5)=c('G1S',"S","G2M","M","MG1")
colorset.cycle5

# lib
library(ggplot2)
library(pheatmap)




# 1. load data ----
# - raw counts, seurat_clusters
# - cell cycle gene list
message(now(), "1. loading Seurat data: ", keyword) # [2024/05/06_11:50:02]1. loading Seurat data: CellCycle

## (1) Seurat obj ====
library(Seurat)
scObj=readRDS(seurat_filename)
DimPlot(scObj, label=T)

# setwd(outputRoot)
getwd()


#1)load raw counts
#fname=paste0(infoPath,"BC_HeLa.225cells.count.V3.csv")
#data=read.csv(fname,row.names = 1)
data = scObj@assays$RNA@counts
dim(data) #[1] 15855  3066
data[1:4,1:4]
#        AAACACCA_1 AAACGAGA_1 AAACTTAG_1 AACAGTGT_1
#SAMD11           .          .          .          .


#2)cell type
#cellType=read.csv( paste0(infoPath,"cellInfo.txt"),row.names = 1)
cellType=scObj@meta.data
head(cellType)
#           orig.ident nCount_RNA nFeature_RNA time percent.MT percent.RP RNA_snn_res.0.6 seurat_clusters RNA_snn_res.0.8     S.Score   G2M.Score
#AAACACCA_1     0hRep1      45113         2173   0h   4.528628   35.01208               6               7               7 -0.16194784 -0.07448709
#AAACGAGA_1     0hRep1      56217         2290   0h   5.347137   33.76025               6               7               7 -0.15868987 -0.08012947

colnames(cellType) |> jsonlite::toJSON()
#["orig.ident","nCount_RNA","nFeature_RNA","time","percent.MT","percent.RP","RNA_snn_res.0.6","seurat_clusters","RNA_snn_res.0.8","S.Score","G2M.Score","Phase","old.ident","cid","seurat_cid"] 

dim(cellType) #3066   15



## (2) cycle genelist ====
# included in this script
cc.genes2 = list(
  G1S=c("ACD","ACYP1","ADAMTS1","ANKRD10","APEX2","ARGLU1","ATAD2","BARD1","BRD7","C1orf63","C7orf41","C14orf142","CAPN7","CASP2","CASP8AP2","CCNE1","CCNE2","CDC6","CDC25A","CDCA7","CDCA7L","CEP57","CHAF1A","CHAF1B","CLSPN","CREBZF","CTSD","DIS3","DNAJC3","DONSON","DSCC1","DTL","E2F1","EIF2A","ESD","FAM105B","FAM122A","FLAD1","GINS2","GINS3","GMNN","HELLS","HOXB4","HRAS","HSF2","INSR","INTS8","IVNS1ABP","KIAA1147","KIAA1586","LNPEP","LUC7L3","MCM2","MCM4","MCM5","MCM6","MDM1","MED31","MRI1","MSH2","NASP","NEAT1","NKTR","NPAT","NUP43","ORC1","OSBPL6","PANK2","PCDH7","PCNA","PLCXD1","PMS1","PNN","POLD3","RAB23","RECQL4","RMI2","RNF113A","RNPC3","SEC62","SKP2","SLBP","SLC25A36","SNHG10","SRSF7","SSR3","TAF15","TIPIN","TOPBP1","TRA2A","TTC14","UBR7","UHRF1","UNG","USP53","VPS72","WDR76","ZMYND19","ZNF367","ZRANB2"),
  S=c("ABCC5","ABHD10","ANKRD18A","ASF1B","ATAD2","BBS2","BIVM","BLM","BMI1","BRCA1","BRIP1","C5orf42","C11orf82","CALD1","CALM2","CASP2","CCDC14","CCDC84","CCDC150","CDC7","CDC45","CDCA5","CDKN2AIP","CENPM","CENPQ","CERS6","CHML","COQ9","CPNE8","CREBZF","CRLS1","DCAF16","DEPDC7","DHFR","DNA2","DNAJB4","DONSON","DSCC1","DYNC1LI2","E2F8","EIF4EBP2","ENOSF1","ESCO2","EXO1","EZH2","FAM178A","FANCA","FANCI","FEN1","GCLM","GOLGA8A","GOLGA8B","H1F0","HELLS","HIST1H2AC","HIST1H4C","INTS7","KAT2A","KAT2B","KDELC1","KIAA1598","LMO4","LYRM7","MAN1A2","MAP3K2","MASTL","MBD4","MCM8","MLF1IP","MYCBP2","NAB1","NEAT1","NFE2L2","NRD1","NSUN3","NT5DC1","NUP160","OGT","ORC3","OSGIN2","PHIP","PHTF1","PHTF2","PKMYT1","POLA1","PRIM1","PTAR1","RAD18","RAD51","RAD51AP1","RBBP8","REEP1","RFC2","RHOBTB3","RMI1","RPA2","RRM1","RRM2","RSRC2","SAP30BP","SLC38A2","SP1","SRSF5","SVIP","TOP2A","TTC31","TTLL7","TYMS","UBE2T","UBL3","USP1","ZBED5","ZWINT"),
  G2M=c("ANLN","AP3D1","ARHGAP19","ARL4A","ARMC1","ASXL1","ATL2","AURKB","BCLAF1","BORA","BRD8","BUB3","C2orf69","C14orf80","CASP3","CBX5","CCDC107","CCNA2","CCNF","CDC16","CDC25C","CDCA2","CDCA3","CDCA8","CDK1","CDKN1B","CDKN2C","CDR2","CENPL","CEP350","CFD","CFLAR","CHEK2","CKAP2","CKAP2L","CYTH2","DCAF7","DHX8","DNAJB1","ENTPD5","ESPL1","FADD","FAM83D","FAN1","FANCD2","G2E3","GABPB1","GAS1","GAS2L3","H2AFX","HAUS8","HINT3","HIPK2","HJURP","HMGB2","HN1","HP1BP3","HRSP12","IFNAR1","IQGAP3","KATNA1","KCTD9","KDM4A","KIAA1524","KIF5B","KIF11","KIF20B","KIF22","KIF23","KIFC1","KLF6","KPNA2","LBR","LIX1L","LMNB1","MAD2L1","MALAT1","MELK","MGAT2","MID1","MIS18BP1","MND1","NCAPD3","NCAPH","NCOA5","NDC80","NEIL3","NFIC","NIPBL","NMB","NR3C1","NUCKS1","NUMA1","NUSAP1","PIF1","PKNOX1","POLQ","PPP1R2","PSMD11","PSRC1","RANGAP1","RCCD1","RDH11","RNF141","SAP30","SKA3","SMC4","STAT1","STIL","STK17B","SUCLG2","TFAP2A","TIMP1","TMEM99","TMPO","TNPO2","TOP2A","TRAIP","TRIM59","TRMT2A","TTF2","TUBA1A","TUBB","TUBB2A","TUBB4B","TUBD1","UACA","UBE2C","VPS25","VTA1","WSB1","ZNF587","ZNHIT2"),
  M=c("AHI1","AKIRIN2","ANKRD40","ANLN","ANP32B","ANP32E","ARHGAP19","ARL6IP1","ASXL1","ATF7IP","AURKA","BIRC2","BIRC5","BUB1","CADM1","CCDC88A","CCDC90B","CCNA2","CCNB2","CDC20","CDC25B","CDC27","CDC42EP1","CDCA3","CENPA","CENPE","CENPF","CEP55","CFLAR","CIT","CKAP2","CKAP5","CKS1B","CKS2","CNOT10","CNTROB","CTCF","CTNNA1","CTNND1","DEPDC1","DEPDC1B","DIAPH3","DLGAP5","DNAJA1","DNAJB1","DR1","DZIP3","E2F5","ECT2","FAM64A","FOXM1","FYN","G2E3","GADD45A","GAS2L3","GOT1","GRK6","GTSE1","HCFC1","HMG20B","HMGB3","HMMR","HN1","HP1BP3","HPS4","HS2ST1","HSPA8","HSPA13","INADL","KIF2C","KIF5B","KIF14","KIF20B","KLF9","LBR","LMNA","MCM4","MDC1","MIS18BP1","MKI67","MLLT4","MZT1","NCAPD2","NCOA5","NEK2","NUF2","NUP35","NUP98","NUSAP1","ODF2","ORAOV1","PBK","PCF11","PLK1","POC1A","POM121","PPP1R10","PRPSAP1","PRR11","PSMG3","PTP4A1","PTPN9","PWP1","QRICH1","RAD51C","RANGAP1","RBM8A","RCAN1","RERE","RNF126","RNF141","RNPS1","RRP1","SEPHS1","SETD8","SFPQ","SGOL2","SHCBP1","SMARCB1","SMARCD1","SPAG5","SPTBN1","SRF","SRSF3","SS18","SUV420H1","TACC3","THRAP3","TLE3","TMEM138","TNPO1","TOMM34","TPX2","TRIP13","TSG101","TSN","TTK","TUBB4B","TXNDC9","TXNRD1","UBE2D3","USP13","USP16","VANGL1","WIBG","WSB1","YWHAH","ZC3HC1","ZFX","ZMYM1","ZNF207"),
  MG1=c("AGFG1","AGPAT3","AKAP13","AMD1","ANP32E","ANTXR1","BAG3","BTBD3","CBX3","CDC42","CDK7","CDKN3","CEP70","CNIH4","CTR9","CWC15","DCP1A","DCTN6","DEXI","DKC1","DNAJB6","DSP","DYNLL1","EIF4E","ELP3","FAM60A","FAM189B","FOPNL","FOXK2","FXR1","G3BP1","GATA2","GNB1","GRPEL1","GSPT1","GTF3C4","HIF1A","HMG20B","HMGCR","HSD17B11","HSPA8","ILF2","JMJD1C","KDM5B","KIAA0586","KIF5B","KPNB1","KRAS","LARP1","LARP7","LRIF1","LYAR","MORF4L2","MRPL19","MRPS2","MRPS18B","MSL1","MTPN","NCOA3","NFIA","NFIC","NUCKS1","NUFIP2","NUP37","ODF2","OPN3","PAK1IP1","PBK","PCF11","PLIN3","PPP2CA","PPP2R2A","PPP6R3","PRC1","PSEN1","PTMS","PTTG1","RAD21","RAN","RHEB","RPL13A","SLC39A10","SNUPN","SRSF3","STAG1","SYNCRIP","TAF9","TCERG1","TLE3","TMEM138","TOB2","TOP1","TROAP","TSC22D1","TULP4","UBE2D3","VANGL1","VCL","WIPF2","WWC1","YY1","ZBTB7A","ZCCHC10","ZNF24","ZNF281","ZNF593")
)

sapply(cc.genes2, length)
#G1S   S G2M   M MG1 
#100 113 133 151 106












# 2. begin ----
## (0) filter genelist ====
message(now(), "2.0 keep expressed genes in raw data ")
geneSets=list();
for(i in 1:length(getCellPhaseList() )){
  set_name=getCellPhaseList()[i]
  init_genes=cc.genes2[[set_name]]
  # intersect with
  geneSets[[set_name]]=intersect(init_genes, row.names(data))
  message( sprintf("[%s], %s: {init: %s, final: %s}", i, set_name, length(init_genes), length(geneSets[[set_name]]) ))
}

## step1: exclude genes cor<0.3 with mean of the set ----
message(now(), "2.1: exclude genes cor<0.3 with mean of the set")
geneSets2=list();
for(i in 1:length(getCellPhaseList() )){
  # mean exp of genelist
  set_name=getCellPhaseList()[i] #'G1S';
  setMean=apply(data[geneSets[[set_name]], ], 2,mean)
  # cor of gene & genelist
  tmpGenes=c()
  for(g in geneSets[[set_name]]){
    #rs=cor(t(data[g,]), setMean)
    rs=cor(as.numeric(data[g,]), setMean)
    if(rs>=0.3){
      tmpGenes=c(tmpGenes,g)
    }
  }
  geneSets2[[set_name]]=tmpGenes
  message( sprintf("[%s] keep cor>=0.3, %s: %s", i, set_name,  length(tmpGenes) ))
}
names(geneSets2)
sum(sapply(geneSets2, function(x){length(x)}))  #473





## step2: depth norm; log2 norm ----
message(now(), "2.2: depth norm; log2 norm")
getNormalizedCts <- function ( cts ) {
  #ctsPath
  #cts <- read.table ( ctsPath , header = T , as.is = T )
  apply ( cts , 2 , function ( x ) { log2 ( ( 10^6 ) * x / sum ( x ) + 1 ) })
}
normCts=getNormalizedCts(data)
dim(normCts)
normCts[1:3,1:5]
#apply(normCts,2,sum)





##step3: calculate 5 phase scores each cell(mean of phase genes)====
message(now(), "2.3: calculate 5 phase scores each cell(mean of phase genes)")
# Tested. Passed.
assignSampleScore <- function ( phaseGenesList , normCts ) {
  scores <- lapply ( phaseGenesList , function ( pGenes ) {
    print(length(pGenes) )
    apply ( normCts , 2 , function ( x ) {
      mean ( x [ pGenes ] )
    } )
  } )
  do.call ( cbind , scores )
}
scoreMatrix <- assignSampleScore ( geneSets2 , normCts )
dim(scoreMatrix) #3066    5
head(scoreMatrix)
#                G1S         S      G2M         M      MG1
#AAACACCA_1 1.168661 1.0209002 1.009899 1.1902306 2.406812
#AAACGAGA_1 1.692690 1.0351732 1.281736 1.5714747 2.949646
write.table ( scoreMatrix , paste ( outputRoot , keyword, "_03_PhaseScores.txt" , sep = "" ) )
# pheatmap(scoreMatrix, scale='row', border_color = NA)





##step4: z-norm(each phase, then each cell) ====
message(now(), "2.4: z-norm(each phase, then each cell")
# Tested. Passed.
getNormalizedScores <- function ( scoreMatrix ) {
  norm1 <- apply ( scoreMatrix , 2 , scale )
  normScores <- t ( apply ( t ( norm1 ) , 2 , scale ) )
  rownames ( normScores ) <- rownames ( scoreMatrix )
  colnames ( normScores )  <- colnames ( scoreMatrix )
  normScores
}
normScores <- getNormalizedScores ( scoreMatrix )
head(normScores)
#                 G1S          S        G2M          M         MG1
#AAACACCA_1 -0.2413513  1.4479426 -0.2482228  0.3345608 -1.29292929
#AAACGAGA_1  1.1102859 -1.2931292 -0.6699977  0.8022636  0.05057733
write.table ( normScores , paste ( outputRoot , keyword,  "_04_PhaseNormScores.txt", sep = "" ) )
#pheatmap(normScores, scale='row', border_color = NA)

# draw cell cycle score of each phase for one cell
i=5;plot(normScores[i,],type='o',col=rainbow(i), main=rownames(normScores)[i])
i=8;plot(normScores[i,],type='o',col=rainbow(i), main=rownames(normScores)[i])
print(normScores[i,])




##step5: assign phase for each cell====
message(now(), "2.5: assign phase for each cell")
getReferenceProfiles <- function () {
  referenceProfiles <- list (
    "G1S" = c ( 1 , 0 , 0 , 0 , 0 ) ,
    "G1S.S" =  c ( 1 , 1 , 0 , 0 , 0 ) ,
    "S" =  c ( 0 , 1 , 0 , 0 , 0 ) ,
    "S.G2M" =  c ( 0 , 1 , 1 , 0 , 0 ) ,
    "G2M" =  c ( 0 , 0 , 1 , 0 , 0 ) ,
    "G2M.M" =  c ( 0 , 0 , 1 , 1 , 0 ) ,
    "M" =  c ( 0 , 0 , 0 , 1 , 0 ) ,
    "M.MG1" =  c ( 0 , 0 , 0 , 1 , 1 ) ,
    "MG1" =  c ( 0 , 0 , 0 , 0 , 1 ) ,
    "MG1.G1S" =  c ( 1 , 0 , 0 , 0 , 1 ) ,
    "all" =  c ( 1 , 1 , 1 , 1 , 1 ) )
  #referenceProfiles <- lapply ( referenceProfiles , function ( x ) { names ( x ) <- c ( "G1S", "S", "G2" , "G2M" , "MG1" ); x } )
  referenceProfiles <- lapply ( referenceProfiles ,  function ( x ) { 
    names ( x ) <- c ( 'G1S', 'S','G2M','M','MG1' ); x } )
  do.call ( rbind , referenceProfiles )
}

# Tested. Passed.
assignRefCors <- function ( normScores ) {
  referenceProfiles <- getReferenceProfiles()
  t ( apply ( normScores , 1 , function ( sampleScores ) {
    apply ( referenceProfiles , 1 , function ( refProfile ) {
      cor ( sampleScores , refProfile ) } )
  } ) )
}
# Tested. Passed.
getPhases <- function ( ) {
  #phases <- c ( "G1S", "S", "G2" , "G2M" , "MG1" )
  phases <- c ( 'G1S', 'S','G2M','M','MG1' )
  names ( phases ) <- phases
  phases
}
# Tested. Passed.
assignPhase <- function ( refCors ) {
  phases <- getPhases ()
  apply ( refCors [ ,phases ] , 1  , function ( x ) {
    phases [ which.max ( x ) ]
  } )
}

## Score cycle similarity
refCors <- assignRefCors ( normScores )
head(refCors)
assignedPhase <- assignPhase ( refCors )
head(assignedPhase)
#
table(assignedPhase)
# assignedPhase
#G1S G2M   M MG1   S 
#674 519 281 929 663
#

getDFfromNamed=function(Namedxx){
  data.frame(
    id=attr(Namedxx,'names'),
    val=unname(Namedxx),
    row.names = 1
  )
}

rs=getDFfromNamed(assignedPhase)
head(rs)
# save label
write.csv(rs, paste ( outputRoot , keyword, "_05_cellCycle_phase.csv" , sep = "" ) )


#
# cmp to step 4?
i=5;plot(normScores[i,],type='o',col=rainbow(i), main=rownames(normScores)[i])
# Top score as the final phase.
#





##step6: Order cells ====
message(now(), "2.6: Order cells")
# Tested. Passed.
orderSamples <- function ( refCors , assignedPhase) {
  phases <- getPhases()
  orderedSamples <- list()
  
  for ( phase in phases ) {
    phaseCor <- refCors [ assignedPhase == phase , ]
    
    phaseIndex <- which ( colnames ( phaseCor ) == phase )
    if ( phaseIndex == 1 ) { preceding = ncol ( phaseCor ) - 1 } else { preceding <- phaseIndex - 1 }
    if ( phaseIndex == ncol ( phaseCor ) - 1 ) { following = 1 } else { following <- phaseIndex + 1 }
    
    earlyIndex <- phaseCor [ , preceding ] > phaseCor [ , following ]
    earlyCor <- subset ( phaseCor , earlyIndex )
    earlySamples <- rownames ( earlyCor ) [ order ( earlyCor [ , preceding ] , decreasing = T ) ]
    
    lateCor <- subset ( phaseCor , ! earlyIndex )
    lateSamples <- rownames ( lateCor ) [ order ( lateCor [ , following ] , decreasing = F ) ]
    
    orderedSamples [[ phase ]] <- c ( earlySamples , lateSamples )
  }
  refCors [ do.call ( c , orderedSamples ) , ]
}

#
ordCor <- orderSamples ( refCors , assignedPhase )
write.table ( cbind ( ordCor , "assignedPhase" = assignedPhase [ rownames ( ordCor ) ] ) , 
              paste ( outputRoot , keyword, "_06_PhaseRefCor.txt" , sep = "" ) )
#
if(0){
  pheatmap(t(ordCor[, seq(1,10,2)]), scale = "none", 
           cluster_rows = F, show_rownames = T, 
           cluster_cols = F, show_colnames = F,
           
           clustering_method = "ward.D2",
           main="")
}
#






##step7: Plot ====
message(now(), "2.7: Plot")
# Passed.
plotCycle <- function  ( phaseCorsMatrix, ... ) {
  library("pheatmap")
  library("RColorBrewer")
  breaks <- seq ( -1 , 1 , length.out = 31 )
  heatColors <- rev (brewer.pal ( 9, 'RdBu'))
  heatColors <-colorRampPalette(heatColors)
  colorPallete <- heatColors((length ( breaks ) - 1 ))
  
  # create heatmap
  hm.parameters <- list(phaseCorsMatrix, border_color=NA,
                        color = colorPallete,
                        breaks = breaks,
                        cellwidth = NA, cellheight = NA, scale = "none",
                        treeheight_row = 50,
                        kmeans_k = NA,
                        show_rownames = T, show_colnames = F,
                        #main = "",
                        
                        clustering_method = "average",
                        cluster_rows = FALSE, cluster_cols = FALSE,
                        clustering_distance_rows = "euclidean",
                        clustering_distance_cols = NA ,
                        legend = T , annotation_legend = F,... )
  
  do.call("pheatmap", hm.parameters )
}

phases <- getPhases()
#jpeg ( paste ( outputRoot , "PhasePlot.jpg" , sep = "" ) , 5 , 3 , units = "in" , res = 300 )
result=plotCycle ( t ( ordCor [ , phases ] ), main= paste0(keyword, " ", nrow(ordCor), ' cells') )

pdf( paste0( outputRoot, keyword, "_07_A_PhasePlot.heatmap.pdf"), width=4, height=2.5)
grid::grid.newpage()
grid::grid.draw(result$gtable)
dev.off()
#







#3. check & visualization ----
## (1) stat ====
df1=rs
head(df1)
table(df1$val)
# G1S G2M   M MG1   S 
#674 519 281 929 663

cellType2=cellType[rownames(df1),]
cellType2$cellCycle=df1$val
head(cellType2, n=2)

table(cellType2$seurat_clusters, cellType2$cellCycle)
#       G1S G2M  M MG1  S
#BC_0  28  17 19  13 10
#BC_1  21   7 13  28 13



##(2) Seurat obj ====
df2=df1[rownames(scObj@meta.data), ,drop=F]
scObj@meta.data |> head(2)
scObj$Phase2=factor(df2$val, levels = c("G1S", "S", "G2M", "M", "MG1"))

table(scObj$Phase, scObj$Phase2)

DimPlot(scObj, group.by = "Phase")
#
DimPlot(scObj, group.by = "Phase2", pt.size = 0.2)+
  scale_color_manual(values=colorset.cycle5)
ggsave(file= paste0(outputRoot, keyword,'_3_02A_All.UMAP.pdf'), width=3.47, height=2.93)
#
DimPlot(scObj, group.by = "Phase2", split.by = "Phase2", pt.size = 0.2, ncol = 1)+
  scale_color_manual(values=colorset.cycle5)
ggsave(file= paste0(outputRoot, keyword,'_3_02B_split_phase2.UMAP.pdf'), width=2.8, height=8.1)
#
DimPlot(scObj, group.by = "Phase2", split.by = "time", pt.size = 0.2)+
  scale_color_manual(values=colorset.cycle5)
ggsave(file= paste0(outputRoot, keyword,'_3_02C_split_time.UMAP.pdf'), width=5.1, height=2.5)





#100 end of this script ----
message(now(), "End of do CellCycle script, keyword:", keyword, 
        ", time:", round(difftime(Sys.time(), start.time, units="sec"), 2), "sec")
print("End of this R script")
