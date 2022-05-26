# Creates command lines for advanced tool options

make_command <- function(steps) {
  if (is.null(steps)) {
    return(NULL)
  } else {
    steps <- gsub(" ", "", steps)
    steps <- paste0("--", steps, " 1")
    paste(steps, collapse = " ")
  }
}


BBduk <- function(
  ktrim, qtrim, trimq, k, mink, hdist, ftm, chastityfilter, minlen
  ) {
  paste0(
    " --Bbduk_ktrim ", ktrim,
    " --Bbduk_qtrim ", qtrim,
    " --Bbduk_trimq ", trimq,
    " --Bbduk_k ", k,
    " --Bbduk_mink ", mink,
    " --Bbduk_hdist ", hdist,
    " --Bbduk_ftm ", ftm,
    " --Bbduk_chastityfilter ", chastityfilter,
    " --Bbduk_minlen ", minlen
  )
}


HaplotypeCaller <- function(ploidy, conf) {
  if (is.null(ploidy)) {
    return(NULL)
  } else {
    paste0(
      " --HaplotypeCaller_ploidy ", ploidy,
      " --HaplotypeCaller_confidence ", conf
    )
  }
}


GlobalOptions <- function(
  cores, yaml, jobs
) {
  if (is.null(cores) | is.null(yaml) | is.null(jobs)) {
    return(NULL)
  } else {
    paste0(
      " --CreateYAML ", yaml,
      " --Cores ", cores,
      " --Jobs ", jobs
    )
  }
}
