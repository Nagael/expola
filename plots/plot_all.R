suppressMessages(library(ggplot2))
suppressMessages(library(plyr))
suppressMessages(library(dplyr))
suppressMessages(library(RColorBrewer))
suppressMessages(library(purrr))
Sys.setenv("MKL_NUM_THREADS" = "1", "OMP_NUM_THREADS"="1")

args <- commandArgs(trailingOnly=TRUE)

# res <- read.table(args[1], col.names=c("method", "m", "n", "b", "time"), na.strings="N/A")
res <- read.table(args[1], col.names=c("id", "method", "M", "N", "b", "time", "cycles", "L2", "L3"),
                  na.strings="N/A")

res$method <- factor(recode(res$method,
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

res <- res[res$M >= 5000,]
colors <- brewer.pal(7, "Set1")
names(colors) <- c("Left Looking", "QR2", "Tiled LL", "Tiled RL", "Recursive", "Right Looking", "QR")
colors <- colors[levels(res$method)]

res_med <- ddply(res, ~method+M+N+b, summarize, time=median(time), cycles=median(cycles), L3=median(L3), L2=median(L2))

# print(res_med)
res_med_base <- res_med[is.na(res_med$b),]
# print(res_med[!is.na(res_med$b),])
res_med_best <- ddply(res_med[!is.na(res_med$b),], ~method+M+N, summarize, b=b[which.min(time)], time=min(time))
res_med_best_best <- ddply(res_med[!is.na(res_med$b),], ~M+N, summarize, b=b[which.min(time)], method=method[which.min(time)], time=min(time))
res_med_base_best <- ddply(res_med_base, ~M+N, summarize, method=method[which.min(time)], time=min(time))

# print(res_med_base_best)

res_med_best_best$ratio <- res_med_base_best$time / res_med_best_best$time
res_med_best_best$base <- res_med_base_best$method

# print(res_med_base_best)
# print(res_med_best)

base_name <- gsub(".txt", "", args[1])

# dose.labs <- c("D0.5", "D1", "D2")
# names(dose.labs) <- c(, "1", "2")

time_as_a_function_of_block_size <- function(p, yaxis="time (s)") {
p <- p + facet_wrap(N~M, scales="free", labeller=partial(label_both, multi_line=FALSE), ncol=4)
p <- p + labs(x="Block size", y=yaxis)
p <- p + expand_limits(y=0)
p <- p + scale_color_manual(name="Variant", values=colors, drop=TRUE)
p <- p + theme(legend.position="bottom")
p
}

w <- 6.4
h <- 5.1

p <- ggplot(res_med, aes(x=b, y=time, color=method)) + geom_line()
p <- p + geom_hline(data=res_med_base, aes(yintercept=time, color=method))
p <- time_as_a_function_of_block_size(p)

ggsave(paste(base_name, "_time", ".pdf", sep=""), p, width=w, height=h)

# p <- ggplot(res_med, aes(x=b, y=cycles, color=method)) + geom_line()
# p <- p + geom_hline(data=res_med_base, aes(yintercept=cycles, color=method))
# p <- time_as_a_function_of_block_size(p, "cycles")

# ggsave(paste(base_name, "_cycles", ".pdf", sep=""), p, width=w, height=h)

p <- ggplot(res_med, aes(x=b, y=L2, color=method)) + geom_line()
## p <- p + scale_y_log10()
p <- p + geom_hline(data=res_med_base, aes(yintercept=L2, color=method))
p <- time_as_a_function_of_block_size(p, "L2 cache misses")

ggsave(paste(base_name, "_L2", ".pdf", sep=""), width=w, height=h)

p <- ggplot(res_med, aes(x=b, y=L3, color=method)) + geom_line()
## p <- p + scale_y_log10()
p <- p + geom_hline(data=res_med_base, aes(yintercept=L3, color=method))
p <- time_as_a_function_of_block_size(p, "L3 cache misses")

ggsave(paste(base_name, "_L3", ".pdf", sep=""), width=w, height=h)


# p <- ggplot(res_med_best_best, aes(x=factor(m), y=factor(n), fill=ratio)) + geom_tile(width=1, height=1)
# p <- p + geom_label(aes(label=paste(method, b, round(ratio, 2), base, sep='\n')))
# p <- p + labs(x="M", y = "N", fill="Speedup of Tiled")
# p <- p + scale_fill_binned(low="yellow", high="red")
# p <- p + theme(legend.position="bottom")

# ggsave(paste(base_name, "_speedup", ".pdf", sep=""), p, width=5, height=5)