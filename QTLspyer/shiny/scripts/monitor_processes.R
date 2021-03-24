# Functions to track global processes and recourse usage.

get.processes  <- function(){
    # Get list of processes running

    processes <- system("ps -A", intern = TRUE)
    processes <- gsub("(?<=[\\s])\\s*|^\\s+|\\s+$", "", processes, perl=TRUE)
    processes <- data.frame(
        do.call('rbind', strsplit(as.character(processes), " ", fixed=TRUE)),
        stringsAsFactors = FALSE
        )
    names(processes) <- as.character(processes[1, ])
    row.names(processes) <- NULL
    processes <- processes[-1, ]

    return(as.data.frame(processes))
}
