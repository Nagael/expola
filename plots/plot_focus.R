suppressMessages(library(ggplot2))
suppressMessages(library(plyr))
suppressMessages(library(dplyr))
suppressMessages(library(RColorBrewer))
suppressMessages(library(purrr))
Sys.setenv("MKL_NUM_THREADS" = "1", "OMP_NUM_THREADS"="1")

args <- commandArgs(trailingOnly=TRUE)

# res <- read.table(args[1], col.names=c("method", "m", "n", "b", "time"), na.strings="N/A")
res <- read.table(args[1], col.names=c("id", "method", "m", "n", "b", "time", "cycles", "L1", "L2"),
                  na.strings="N/A")


# res_med <- ddply(res, ~method+m+n+b, summarize, time=min(time), cycles=min(cycles), L1=min(L1), L2=min(L2))
res_med <- ddply(res, ~method+n+m+b, summarize, "time"=median(time), "cycles"=median(cycles), "L1"=median(L1), "L2"=median(L2))

# (*) Pour # de flops, MGS est 2*M*N^2. Et A2V et V2Q sont le même nombre et ce nombre est 2MN^2 – 2/3 N^3. 
res_med$flops <- with(res_med, if("MGS" %in% method) { 2*m*n*n } else {2*m*n*n - 2*n*n*n/3} )

res_med$method <- factor(recode(res_med$method,
           "MGS_LL_BLAS" = "Left Looking", "MGS_LL_TILED_BLAS"="Tiled LL",
	   "MGS_RL_BLAS" = "Right Looking", "MGS_RL_TILED_BLAS"="Tiled RL",
	   "MGS_REC_BLAS" = "Recursive",
	   "HH_A2VLL_BLAS" = "Left Looking", "HH_A2VLL__TILED_BLAS" = "Tiled LL",
	   "HH_A2V_LL_BLAS" = "Left Looking", "HH_A2V_LL_TILED_BLAS" = "Tiled LL",
	   "HH_A2V_RL_BLAS" = "Right Looking", "HH_A2V_RL_TILED_BLAS" = "Tiled RL",
	   "HH_V2Q_LL_BLAS" = "Left Looking", "HH_V2Q_LL_TILED_BLAS" = "Tiled LL",
	   "HH_V2Q_RL_BLAS" = "Right Looking", "HH_V2Q_RL_TILED_BLAS" = "Tiled RL",
	   "HH_V2Q_REC_BLAS" = "Recursive", "HH_A2V_REC_BLAS" = "Recursive",
	   "ORG2R" = "QR2", "ORGQR" = "QR", "GEQRF" = "QR", "GEQR2" = "QR2"))

colors <- brewer.pal(7, "Set1")
names(colors) <- c("Left Looking", "QR2", "Tiled LL", "Tiled RL", "Recursive", "Right Looking", "QR")
colors <- colors[levels(res_med$method)]

# print(res_med)

base_name <- gsub(".txt", "", args[1])

normalized_time_as_a_function_of_n <- function(p, yaxis="time (s)") {
# p <- p + facet_wrap(n~m, scales="free", labeller=partial(label_both, multi_line=FALSE), ncol=4)
p <- p + labs(x="N", y=yaxis)
p <- p + expand_limits(y=0)
p <- p + scale_color_manual(name="Variant", values=colors, drop=TRUE)
p <- p + theme(legend.position="bottom")
p
}

w <- 6.4
h <- 5.1

p <- ggplot(res_med, aes(x=n, y=time, color=method)) + geom_line()
# p <- p + geom_hline(data=res_med_base, aes(yintercept=time, color=method))
p <- p + scale_y_log10()
p <- normalized_time_as_a_function_of_n(p)

ggsave(paste(base_name, "_time", ".pdf", sep=""), p, width=w, height=h)

p <- ggplot(res_med, aes(x=n, y=flops/time/1000/1000/1000, color=method)) + geom_line()
# p <- p + geom_hline(data=res_med_base, aes(yintercept=time, color=method))
p <- normalized_time_as_a_function_of_n(p, yaxis="Gflop / second")

ggsave(paste(base_name, "_flops", ".pdf", sep=""), p, width=w, height=h)

# p <- ggplot(res_med, aes(x=b, y=cycles, color=method)) + geom_line()
# p <- p + geom_hline(data=res_med_base, aes(yintercept=cycles, color=method))
# p <- time_as_a_function_of_block_size(p, "cycles")

# ggsave(paste(base_name, "_cycles", ".pdf", sep=""), p, width=w, height=h)

# p <- ggplot(res_med, aes(x=b, y=L1, color=method)) + geom_line()
# p <- p + geom_hline(data=res_med_base, aes(yintercept=L1, color=method))
# p <- time_as_a_function_of_block_size(p, "L1 cache misses")

# ggsave(paste(base_name, "_L1", ".pdf", sep=""), width=w, height=h)

# p <- ggplot(res_med, aes(x=b, y=L2, color=method)) + geom_line()
# p <- p + geom_hline(data=res_med_base, aes(yintercept=L2, color=method))
# p <- time_as_a_function_of_block_size(p, "L2 cache misses")

# ggsave(paste(base_name, "_L2", ".pdf", sep=""), width=w, height=h)


# p <- ggplot(res_med_best, aes(x=factor(m), y=factor(n), fill=ratio)) + geom_tile(width=1, height=1)
# p <- p + geom_label(aes(label=paste(base, round(ratio, 2), b, sep='\n')))
# p <- p + labs(x="M", y = "N", fill="Speedup of Tiled")
# p <- p + scale_fill_binned(low="yellow", high="red")
# p <- p + theme(legend.position="bottom")

# ggsave(paste(base_name, "_speedup", ".pdf", sep=""), p, width=5, height=5)