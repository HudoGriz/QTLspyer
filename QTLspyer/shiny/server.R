shinyServer(function(input, output, session) {
  snp_table_unfiltered <- reactiveVal(0)
  snp_table <- reactiveVal(0)
  qtl_tables <- reactiveVal(0)
  annotation <- reactiveVal(0)
  chromosomes <- reactiveVal(0)
  genes_selected <- reactiveVal(0)

  traces <- reactiveValues(
    render_proc_n = NULL,
    render_proc_diff = NULL,
    render_gprime = NULL,
    render_raw_n = NULL
  )

  ref_fastas <- list.files(path = "/QTLspyer/input/references/", pattern = "\\.fasta$")
  ref_fastas_gz <- list.files(
    path = "/QTLspyer/input/references/", pattern = "\\.fasta.gz$"
  )
  ref_fastas <- c(ref_fastas, ref_fastas_gz)
  if (identical(ref_fastas, character(0))) {
    ref_fastas <- NA
  }

  ref_vcf <- list.files(path = "/QTLspyer/input/references/", pattern = "\\.vcf.gz$")
  ref_vcf_gz <- list.files(path = "/QTLspyer/input/references/", pattern = "\\.vcf$")
  ref_vcf <- c(ref_vcf, ref_vcf_gz)
  if (identical(ref_vcf, character(0))) {
    ref_vcf <- NA
  }

  adapters <- list.files(path = "/QTLspyer/input/adapters/", pattern = "\\.fa")
  if (identical(adapters, character(0))) {
    adapters <- NA
  }

  ref_gtf <- list.files(path = "/QTLspyer/input/annotation/", pattern = "\\.gtf$")
  if (identical(ref_gtf, character(0))) {
    ref_gtf <- NA
  }

  output$menu <- renderMenu({
    sidebarMenu(
      menuItem("Variant discovery",
        tabName = "settings"
      ),
      menuItem("FastQC Reports",
        tabName = "raw_fastq"
      ),
      menuItem("Import & filtering",
        tabName = "filter-tuning"
      ),
      menuItem("QTL analysis",
        tabName = "genome-map"
      ),
      menuItem("Data tables",
        tabName = "table",
        menuSubItem("SNP results",
          tabName = "snp_stat"
        ),
        menuSubItem("QTL-seq results",
          tabName = "qtl_delta"
        ),
        menuSubItem("G' results",
          tabName = "qtl_q"
        )
      ),
      menuItem("Info",
        tabName = "help"
      )
    )
  })

  output$tools_page <- renderUI(
    sidebarLayout(
      sidebarPanel(
        width = 4,
        textInput(
          "ex_name",
          label = NULL,
          placeholder = "Experiment name"
        ),
        bsTooltip(
          "ex_name",
          "Name to be included in final .vcf and .table file name.",
          placement = "left", trigger = "hover", options = NULL
        ),
        prettyCheckboxGroup(
          inputId = "optional_proc",
          label = "Optional processes",
          choices = as.character(as.vector(optional_tools["name", ])),
          status = "primary",
          fill = TRUE,
          selected = as.character(as.vector(optional_tools["name", ]))
        ),
        bsTooltip(
          "optional_proc",
          paste(
            "Selected tool will be included in the pipeline.",
            "More about the tool can be found in info.",
            "The file needs to contain organism name +",
            "fasta (Saccharomyces_cerevisiae.fasta)."
          ),
          placement = "left", trigger = "hover", options = NULL
        ),
        prettyRadioButtons(
          inputId = "ref_fasta",
          label = "Reference FASTA file",
          choices = ref_fastas,
          status = "primary",
          fill = TRUE
        ),
        bsTooltip(
          "ref_fasta",
          paste(
            "It will be used as reference for input sequences.",
            "Same organism and strain is recommended."
          ),
          placement = "left", trigger = "hover", options = NULL
        ),
        prettyRadioButtons(
          inputId = "ref_vcf",
          label = "Reference variants",
          choices = ref_vcf,
          status = "primary",
          fill = TRUE
        ),
        bsTooltip(
          "ref_vcf",
          paste(
            "Select file with reference variant calls.",
            "File needs to be inside references in inputs."
          ),
          placement = "left", trigger = "hover", options = NULL
        ),
        prettyRadioButtons(
          inputId = "reference_gtf",
          label = "General Feature Format (GTF)",
          choices = ref_gtf,
          status = "primary",
          fill = TRUE
        ),
        bsTooltip(
          "reference_gtf",
          paste(
            "Select file with the right annotation.",
            "Compressed files wont be recognized in /annotation folder."
          ),
          placement = "left", trigger = "hover", options = NULL
        ),
        prettyRadioButtons(
          inputId = "adapters_file",
          label = "File with adapters",
          choices = adapters,
          status = "primary",
          fill = TRUE
        ),
        bsTooltip(
          "adapters_file",
          paste(
            "Select the right adapter file to be used.",
            "The adapter file needs to be inside the adapter folder in inputs."
          ),
          placement = "left", trigger = "hover", options = NULL
        ),
        prettyRadioButtons(
          inputId = "paired",
          label = "Fasta file",
          choices = c("Paired-end" = FALSE, "Single-end" = TRUE),
          status = "primary",
          fill = TRUE
        ),
        bsTooltip(
          "paired",
          "Are the sample sequences provided as paired end or single end.",
          placement = "left", trigger = "hover", options = NULL
        ),
        prettyCheckbox(
          inputId = "advanced_tools",
          label = "Advanced settings",
          value = FALSE,
          status = "primary",
          fill = TRUE
        ),
        uiOutput("control_button"),
        hr(),
        uiOutput("advanced_tools_settings")
      ),
      mainPanel(
        box(
          width = 12,
          solidHeader = FALSE,
          title = "Progress report",
          verbatimTextOutput("command"),
          verbatimTextOutput("log")
        ),
        box(
          width = 12,
          collapsible = TRUE,
          collapsed = TRUE,
          solidHeader = FALSE,
          title = "Standard output",
          verbatimTextOutput("so_log")
        )
      )
    )
  )

  observeEvent(input$advanced_tools, {
    if (isTRUE(input$advanced_tools)) {
      output$advanced_tools_settings <- renderUI(
        tagList(
          hr(),
          actionBttn(
            inputId = "renew_log",
            label = "renew reports",
            style = "material-flat",
            color = "primary",
            size = "sm"
          ),
          bsTooltip(
            "renew_log",
            paste(
              "Reset Progress report and Standard output log to original."
            ),
            placement = "left", trigger = "hover", options = NULL
          ),
          hr(),
          title = "Global",
          numericInput(
            "global_cores",
            label = "Number of cores per tool",
            value = 8, step = 1, min = 1
          ),
          bsTooltip(
            "global_cores",
            paste(
              "Some tools are able to take advantage of multithreading",
              "for greatly reduced processing time."
            ),
            placement = "left", trigger = "hover", options = NULL
          ),
          numericInput(
            "global_jobs",
            label = "Number of jobs to run simultaneously",
            value = 1, step = 1, min = 1
          ),
          bsTooltip(
            "global_jobs",
            paste(
              "The max number of parallel jobs."
            ),
            placement = "left", trigger = "hover", options = NULL
          ),
          prettyCheckbox(
            inputId = "global_yaml",
            label = "Create new config file",
            value = TRUE,
            status = "primary",
            fill = TRUE
          ),
          bsTooltip(
            "global_yaml",
            paste(
              "Should the process create a new config.yaml file or use an existing one."
            ),
            placement = "left", trigger = "hover", options = NULL
          ),
          hr(),
          title = "BBduk",
          prettyRadioButtons(
            inputId = "bbduk_qtrim",
            label = "qtrim:",
            choices = c("f", "r", "l", "rl", "w"),
            selected = "r",
            status = "primary",
            fill = TRUE
          ),
          bsTooltip(
            "bbduk_qtrim",
            paste(
              "Determine how BBduk will trim.",
              "You can set l for left or rl for both.",
              "W uses a moving window and f will disable trimming."
            ),
            placement = "left", trigger = "hover", options = NULL
          ),
          numericInput(
            "bbduk_trimq",
            label = "trimq",
            value = 20, step = 1, min = 1
          ),
          bsTooltip(
            "bbduk_trimq",
            paste(
              "This will quality-trim to Q20 using the Phred algorithm,",
              "which is more accurate than naive trimming."
            ),
            placement = "left", trigger = "hover", options = NULL
          ),
          prettyRadioButtons(
            inputId = "bbduk_ktrim",
            label = "ktrim:",
            choices = c("f", "r", "l"),
            selected = "r",
            status = "primary",
            fill = TRUE
          ),
          bsTooltip(
            "bbduk_ktrim",
            paste(
              "R is for right-trimming (3′ adapters),",
              "and L is for left-trimming (5′ adapters)."
            ),
            placement = "left", trigger = "hover", options = NULL
          ),
          numericInput(
            "bbduk_k",
            label = "k",
            value = 23, step = 1, min = 1, max = 31
          ),
          bsTooltip(
            "bbduk_k",
            paste(
              "BBDuk supports kmers of length 1-31.",
              "The longer a kmer, the high the specificity.",
              "Note that it is impossible to do kmer matching for reference",
              "sequences that are shorter than K."
            ),
            placement = "left", trigger = "hover", options = NULL
          ),
          numericInput(
            "bbduk_mink",
            label = "mink",
            value = 11, step = 1, min = 1
          ),
          bsTooltip(
            "bbduk_mink",
            paste(
              "Will additionally look for shorter kmers",
              "with lengths less then k."
            ),
            placement = "left", trigger = "hover", options = NULL
          ),
          numericInput(
            "bbduk_hdist",
            label = "hdist",
            value = 1, step = 1, min = 1
          ),
          bsTooltip(
            "bbduk_hdist",
            paste(
              "hdist means “hamming distance”.",
              "Given number of mismatches will be tolerated."
            ),
            placement = "left", trigger = "hover", options = NULL
          ),
          numericInput(
            "bbduk_ftm",
            label = "ftm",
            value = 5, step = 1, min = 1
          ),
          bsTooltip(
            "bbduk_ftm",
            paste(
              "Force trim the right end so that the reads length is equal to",
              "zero modulo 5 (ftm=5)."
            ),
            placement = "left", trigger = "hover", options = NULL
          ),
          numericInput(
            "bbduk_minlen",
            label = "minlen",
            value = 50, step = 1, min = 1
          ),
          bsTooltip(
            "bbduk_minlen",
            paste(
              "This will discard reads shorter than the set",
              "amount after quality trimming."
            ),
            placement = "left", trigger = "hover", options = NULL
          ),
          prettyRadioButtons(
            inputId = "bbduk_chas",
            label = "chastityfilter:",
            choices = c("f", "t"),
            selected = "f",
            status = "primary",
            fill = TRUE
          ),
          bsTooltip(
            "bbduk_chas",
            "If true will remove reads that fail Illumina chastity filtering.",
            placement = "left", trigger = "hover", options = NULL
          ),
          hr(),
          title = "HaplotypeCaller",
          numericInput(
            "hc_ploidy",
            label = "ploidy",
            value = 1, step = 1, min = 1
          ),
          bsTooltip(
            "hc_ploidy",
            paste(
              "Ploidy (number of chromosomes) per sample. For pooled data,",
              "set to (Number of samples in each pool * Sample Ploidy)."
            ),
            placement = "left", trigger = "hover", options = NULL
          ),
          numericInput(
            "hc_conf",
            label = "stand-call-conf",
            value = 20, step = 1, min = 1
          ),
          bsTooltip(
            "hc_conf",
            paste(
              "The minimum phred-scaled confidence threshold",
              "at which variants should be called."
            ),
            placement = "left", trigger = "hover", options = NULL
          )
        )
      )
    } else {
      output$advanced_tools_settings <- renderUI(NULL)
    }
  })

  observeEvent(log_data(), {
    now_running <- get.processes()

    if ("python3" %in% now_running$CMD) {
      output$control_button <- renderUI({
        actionBttn(
          inputId = "stop",
          label = "Stop process",
          style = "material-flat",
          color = "danger",
          size = "lg"
        )
      })
    }
    else {
      output$control_button <- renderUI({
        actionBttn(
          inputId = "run",
          label = "Start process",
          style = "material-flat",
          color = "primary",
          size = "lg"
        )
      })
    }
  })

  log_data <- reactiveFileReader(
    1000,
    session = session, "/QTLspyer/log/sample_processing.log", readLines
  )
  output$log <- renderText({
    paste(log_data(), collapse = "\n")
  })

  log_data_so <- reactiveFileReader(
    1000,
    session = session, "/QTLspyer/log/standard_output.log", readLines
  )
  output$so_log <- renderText({
    paste(log_data_so(), collapse = "\n")
  })

  observeEvent(input$run, {
    if (input$ex_name == "") {
      sendSweetAlert(
        session = session,
        title = "Oops",
        text = "The experiment name is missing!",
        type = "error"
      )
      return()
    }

    selected <- optional_tools["name", ] %in% input$optional_proc
    optional_tools["value", selected] <- 1

    pipeline_options <- make_command(input$pipeline_includes)

    if (input$advanced_tools) {
      options_bbduk <- BBduk(
        ktrim = input$bbduk_ktrim,
        qtrim = input$bbduk_qtrim, trimq = input$bbduk_trimq,
        k = input$bbduk_k, mink = input$bbduk_mink,
        hdist = input$bbduk_hdist, ftm = input$bbduk_ftm,
        chastityfilter = input$bbduk_chas,
        minlen = input$bbduk_minlen
      )

      options_hc <- HaplotypeCaller(
        ploidy = input$hc_ploidy, conf = input$hc_conf
      )

      options_global <- GlobalOptions(
        cores = input$global_cores, yaml = input$global_yaml,
        jobs = inptu$global_jobs
      )

      advanced_tool_options <- paste(options_bbduk, options_hc, options_global)
    } else {
      advanced_tool_options <- ""
    }

    script_command <- paste0(
      "/QTLspyer/variant_calling/variant_calling.py",
      " --experimentName ", input$ex_name,
      " --Reference ", input$ref_fasta,
      " --Adapters ", input$adapters_file,
      " --ReferenceName ", gsub(pattern = ".fasta", replacement = "", x = input$ref_fasta),
      " --ReferenceVCF ", input$ref_vcf,
      " --SeqSingle ", input$paired,
      " --runFastqcPreTrim ", optional_tools["value", "fastqc_rd"],
      " --runBBduk ", optional_tools["value", "trimming"],
      " --runFastqcPostTrim ", optional_tools["value", "fastqc_td"],
      " ", pipeline_options,
      " ", advanced_tool_options
    )

    print(script_command)

    future({
      system(script_command, wait = TRUE)
    })

    # output$command <- renderText(script_command)

    sendSweetAlert(
      session = session,
      title = "Success",
      text = "Pipeline successfully started!",
      type = "success"
    )
  })

  observeEvent(input$stop, {
    confirmSweetAlert(
      session,
      "stop_confirmation",
      title = "Stopping the process",
      text = "Are you sure you wish to stop the process?",
      type = "warning",
      btn_labels = c("No", "Yes"),
      btn_colors = NULL,
    )
  })

  observeEvent(input$stop_confirmation, {
    if (!input$stop_confirmation) {
      return()
    }

    now_running <- get.processes()

    running <- paste(now_running$PID, now_running$CMD, sep = " ")
    primal <- paste(primal_processes$PID, primal_processes$CMD, sep = " ")

    new <- now_running[!running %in% primal, ]
    new <- new[!new$CMD == "R", ]
    new <- new[!new$CMD == "sh", ]
    new <- new[!new$CMD == "ps", ]

    for (pid in new$PID) {
      system(paste("kill -15", as.numeric(pid)))
    }

    system("/QTLspyer/variant_calling/scripts/force_report.py")
  })

  observeEvent(input$renew_log, {
    system("/QTLspyer/variant_calling/scripts/restore_logs.py")
  })

  ##########
  # FASTQC #
  ##########

  output$raw_fastqcs <- renderUI({
    tagList(
      fluidPage(
        column(
          width = 12,
          inputPanel(
            column(
              width = 12,
              actionBttn(
                inputId = "look_for_fastqc",
                label = "Check for fastQC files",
                style = "material-flat",
                color = "primary",
                size = "lg"
              )
            ),
            column(
              width = 12,
              actionBttn(
                inputId = "clear_fastqc",
                label = "Clear fastQC files cache",
                style = "material-flat",
                color = "primary",
                size = "lg"
              )
            )
          ),
          uiOutput("tabs_untrimmed")
        )
      )
    )
  })

  observeEvent(input$look_for_fastqc, {
    fastqc_raw <- list.files(
      path = "/QTLspyer/output/fastqc/untrimmed/", pattern = "\\.html$"
    )
    fastqc_tri <- list.files(
      path = "/QTLspyer/output/fastqc/trimmed/", pattern = "\\.html$"
    )

    for (fqc in fastqc_raw) {
      file.copy(
        paste0("/QTLspyer/output/fastqc/untrimmed/", fqc),
        paste0("./www/fastqc/untrimmed"),
        overwrite = TRUE
      )
    }

    for (fqc in fastqc_tri) {
      file.copy(
        paste0("/QTLspyer/output/fastqc/trimmed/", fqc),
        paste0("./www/fastqc/trimmed"),
        overwrite = TRUE
      )
    }

    htmls_raw <- lapply(fastqc_raw, function(x) {
      inputPanel(
        width = 6,
        a(x, href = paste0("/fastqc/untrimmed/", x), target = "_blank")
      )
    })

    htmls_trim <- lapply(fastqc_tri, function(x) {
      inputPanel(
        width = 6,
        a(x, href = paste0("/fastqc/trimmed/", x), target = "_blank")
      )
    })

    output$tabs_untrimmed <- renderUI({
      tagList(
        hr(),
        title = "Untrimmed",
        htmls_raw,
        hr(),
        title = "Trimmed",
        htmls_trim
      )
    })
  })

  observeEvent(input$clear_fastqc, {
    path <- "www/fastqc"
    files <- list.files(pattern = "\\.html$", recursive = TRUE, path = path)

    for (file in files) {
      file.remove(paste(path, file, sep = "/"))
    }

    output$tabs_untrimmed <- renderUI({
      tagList(
        hr(),
        title = "Untrimmed",
        hr(),
        title = "Trimmed"
      )
    })
  })

  ##################
  # Filter tunning #
  ##################

  output$tuning <- renderUI(
    tagList(
      sidebarLayout(
        sidebarPanel(
          actionBttn(
            inputId = "table_refresh",
            label = "Check files",
            style = "material-flat",
            color = "primary"
          ),
          hr(),
          pickerInput(
            inputId = "table_picked",
            label = "Experiment",
            choices = ""
          ),
          bsTooltip(
            "table_picked",
            "The file name includes the experiment name.",
            placement = "left", trigger = "hover", options = NULL
          ),
          uiOutput("low_and_high"),
          actionBttn(
            inputId = "import_table",
            label = "import",
            style = "material-flat",
            color = "primary"
          ),
          uiOutput("filtering_options")
        ),
        mainPanel(
          uiOutput("plot_boxes")
        )
      )
    )
  )

  observeEvent(input$table_refresh, {
    files <- list.files(
      path = "/QTLspyer/output/GATK/tables/", pattern = "\\.table$"
    )

    if (is.null(input$ex_name)) {
      current_experiment <- NULL
    } else {
      position <- grep(pattern = input$ex_name, x = files)
      current_experiment <- files[position]
    }

    updatePickerInput(
      session = session,
      inputId = "table_picked",
      label = "Experiment",
      choices = files,
      selected = files[1]
    )
  })

  observeEvent(req(input$table_picked), {
    col.names <- read.table(
      paste0("/QTLspyer/output/GATK/tables/", input$table_picked),
      header = TRUE,
      nrows = 1
    )

    col.names <- colnames(col.names)
    col.names <- col.names[- (1:4)]
    bulks <- unique(gsub("\\/QTLspyer*", "", col.names))

    output$low_and_high <- renderUI(
      tagList(
        pickerInput(
          inputId = "low_bulk",
          label = "Low bulk (pool 1)",
          choices = bulks,
          selected = bulks[1]
        ),
        bsTooltip(
          "low_bulk",
          "Named after correlated input file name delimited by _ position.",
          placement = "left", trigger = "hover", options = NULL
        ),
        pickerInput(
          inputId = "high_bulk",
          label = "High bulk (pool 2)",
          choices = bulks,
          selected = bulks[2]
        ),
        bsTooltip(
          "high_bulk",
          "Named after correlated input file name delimited by _ position.",
          placement = "left", trigger = "hover", options = NULL
        ),
      )
    )
  })

  observeEvent(input$import_table, {
    if (input$table_picked == "" || is.null(input$table_picked)) {
      sendSweetAlert(
        session = session,
        title = "Oops",
        text = "First select a file!",
        type = "error"
      )
      return()
    }

    if (input$high_bulk == input$low_bulk) {
      sendSweetAlert(
        session = session,
        title = "Oops",
        text = "The bulks can't be the same!",
        type = "error"
      )
      return()
    }

    # Progress indicator
    progress <- shiny::Progress$new()
    on.exit(progress$close())

    progress$set(message = "Importing data", value = 0)
    n <- 5

    # Assign bulks
    high_bulk <- input$high_bulk
    low_bulk <- input$low_bulk

    # Import vcf tables
    progress$inc(1 / n, detail = paste("Reading table")) # 1
    raw_data <- paste0("/QTLspyer/output/GATK/tables/", input$table_picked)

    df <- importFromGATK(
      file = raw_data,
      highBulk = high_bulk,
      lowBulk = low_bulk
    )

    # Data frame type assignment
    df$CHROM <- as.numeric(df$CHROM)

    # Save to global
    progress$inc(2 / n, detail = paste("Saving")) # 2
    chromosomes(unique(df$CHROM))
    snp_table_unfiltered(df)
    snp_table(df)

    # Plot data stats
    progress$inc(3 / n, detail = paste("Creating plots")) # 3
    p1 <- ggplot(data = df) +
      geom_histogram(aes(x = DP.HIGH + DP.LOW))

    p2 <- ggplot(data = df) +
      geom_histogram(aes(x = REF_FRQ))

    p3 <- ggplot(data = df) +
      geom_histogram(aes(x = SNPindex.HIGH))

    p4 <- ggplot(data = df) +
      geom_histogram(aes(x = SNPindex.LOW))

    progress$inc(4 / n, detail = paste("Rendering plots")) # 4
    output$p1 <- renderPlotly(p1)
    output$p2 <- renderPlotly(p2)
    output$p3 <- renderPlotly(p3)
    output$p4 <- renderPlotly(p4)

    output$filtering_options <- renderUI(
      tagList(
        hr(),
        numericInput(
          "refAlleleFreq",
          label = "Reference allele frequency",
          value = 0.1,
          max = 1,
          min = 0
        ),
        bsTooltip(
          "refAlleleFreq",
          paste(
            "This will filter out SNPs with a Reference Allele Frequency less",
            "than refAlleleFreq and greater than 1 - refAlleleFreq. Eg.",
            "refAlleleFreq = 0.3 will keep SNPs with 0.3 <= REF_FRQ <= 0.7"
          ),
          placement = "left", trigger = "hover", options = NULL
        ),
        numericInput(
          "minTotalDepth",
          label = "Min total read depth",
          value = 100,
          min = 0
        ),
        bsTooltip(
          "minTotalDepth",
          paste(
            "The minimum total read depth for a SNP (counting both bulks)"
          ),
          placement = "left", trigger = "hover", options = NULL
        ),
        numericInput(
          "maxTotalDepth",
          label = "Max total read depth",
          value = 4000,
          min = 0
        ),
        bsTooltip(
          "maxTotalDepth",
          paste("The maximum total read depth for a SNP (counting both bulks)"),
          placement = "left", trigger = "hover", options = NULL
        ),
        numericInput(
          "minSampleDepth",
          label = "Min sample depth",
          value = 1,
          min = 0
        ),
        bsTooltip(
          "minSampleDepth",
          paste("The minimum read depth for a SNP in each bulk"),
          placement = "left", trigger = "hover", options = NULL
        ),
        numericInput(
          "depthDifference",
          label = "Depth difference",
          value = 1000,
          min = 0
        ),
        bsTooltip(
          "depthDifference",
          paste(
            "The maximum absolute difference in read depth between the bulks."
          ),
          placement = "left", trigger = "hover", options = NULL
        ),
        numericInput(
          "minGQ",
          label = "Min GQ",
          value = 10,
          min = 0
        ),
        bsTooltip(
          "minGQ",
          paste(
            "The minimum Genotype Quality as set by GATK.",
            "This is a measure of how confident GATK was with the",
            "assigned genotype (i.e. homozygous ref, heterozygous,",
            "homozygous alt)."
          ),
          placement = "left", trigger = "hover", options = NULL
        ),
        fluidRow(
          column(
            width = 6,
            actionBttn(
              inputId = "filter",
              label = "filter",
              style = "material-flat",
              color = "primary"
            )
          )
        )
      )
    )

    output$plot_boxes <- renderUI(
      tagList(
        box(
          shinycssloaders::withSpinner(plotlyOutput("p1"))
        ),
        bsTooltip(
            "p1",
            paste(
              "Histogram shows cumulative read depths of low and high bulk.",
              "The distribution on this plot should be condensed,",
              "without long tails into extreme lows or highs."
              ),
            placement = "left", trigger = "hover", options = NULL
          ),
        box(
          shinycssloaders::withSpinner(plotlyOutput("p2"))
        ),
        bsTooltip(
            "p2",
            paste(
              "Histogram shows total reference allele frequency.",
              "The distribution on this plot should be as close to a",
              "normal distribution as possible."
              ),
            placement = "left", trigger = "hover", options = NULL
          ),
        box(
          shinycssloaders::withSpinner(plotlyOutput("p3"))
        ),
        bsTooltip(
            "p3",
            paste(
              "Histogram shows SNP-index distribution of high bulk.",
              "The distribution on this plot is expected to contain two",
              "small peaks on each end and most of the SNPs should be",
              "approximately normally distributed around",
              "0.5 in an F2 population."
              ),
            placement = "left", trigger = "hover", options = NULL
          ),
        box(
          shinycssloaders::withSpinner(plotlyOutput("p4"))
        ),
        bsTooltip(
            "p4",
            paste(
              "Histogram shows SNP-index distribution of low bulk.",
              "The distribution on this plot is expected to contain two",
              "small peaks on each end and most of the SNPs should be",
              "approximately normally distributed around",
              "0.5 in an F2 population."
              ),
            placement = "left", trigger = "hover", options = NULL
          ),
      )
    )
  })

  observeEvent(input$filter, {
    df <- filterSNPs(
      SNPset = snp_table_unfiltered(),
      refAlleleFreq = input$refAlleleFreq,
      minTotalDepth = input$minTotalDepth,
      maxTotalDepth = input$maxTotalDepth,
      depthDifference = input$depthDifference,
      minSampleDepth = input$minSampleDepth,
      minGQ = input$minGQ,
      verbose = TRUE
    )

    snp_table(df)

    p1 <- ggplot(data = df) +
      geom_histogram(aes(x = DP.HIGH + DP.LOW))

    p2 <- ggplot(data = df) +
      geom_histogram(aes(x = REF_FRQ))

    p3 <- ggplot(data = df) +
      geom_histogram(aes(x = SNPindex.HIGH))

    p4 <- ggplot(data = df) +
      geom_histogram(aes(x = SNPindex.LOW))

    output$p1 <- renderPlotly(p1)
    output$p2 <- renderPlotly(p2)
    output$p3 <- renderPlotly(p3)
    output$p4 <- renderPlotly(p4)
  })

  observeEvent(input$analyse, {

  })


  ###############
  # QTL mapping #
  ###############

  output$gmap <- renderUI(
    tagList(
      inputPanel(
        column(
          width = 10,
          numericInput(
            "bulkSize_high",
            label = "High bulk (pool) size",
            value = 25,
            min = 1
          ),
          numericInput(
            "bulkSize_low",
            label = "Low bulk (pool) size",
            value = 35,
            min = 1
          ),
          prettyRadioButtons(
            inputId = "filter_method",
            label = "Outlier filter",
            choices = c("deltaSNP", "Hampel"),
            status = "primary",
            fill = TRUE
          ),
          bsTooltip(
            "filter_method",
            paste(
              "The Gprime set is trimmed to exclude outlier regions",
              "(i.e. QTL) either based on Hampel rule or an alternate method",
              "for filtering out QTL using absolute delta SNP",
              "indices greater than a set threshold to filter out potential",
              "QTL."
            ),
            placement = "left", trigger = "hover", options = NULL
          )
        ),
        column(
          width = 12,
          numericInput(
            "replications",
            label = "Bootstrap replications",
            value = 10000,
            min = 1
          ),
          bsTooltip(
            "replications",
            paste(
              "Defines the number of repeated simulations for each bulk.",
              "With the increase of replications the false discovery rate",
              "drops lower but the processing time increases."
            ),
            placement = "left", trigger = "hover", options = NULL
          ),
          numericInput(
            "windowSize",
            label = "Window size",
            value = 1e5,
            min = 100
          ),
          bsTooltip(
            "windowSize",
            paste(
              "The window size (in base pairs) bracketing",
              "each SNP for which the minimum read",
              "depth and the tricube-smoothed depth is calculated.",
              "Size above 1000 recommended."
            ),
            placement = "left", trigger = "hover", options = NULL
          ),
          prettyRadioButtons(
            inputId = "pop_structure",
            label = "Population structure",
            choices = c("F2", "RIL"),
            status = "primary",
            fill = TRUE
          ),
          bsTooltip(
            "pop_structure",
            paste(
              "The population structure. RIL - recombinant inbred line."
            ),
            placement = "left", trigger = "hover", options = NULL
          )
        ),
        column(
          width = 12,
          numericInput(
            "intervals",
            label = "Confidence intervals",
            value = 95,
            max = 100,
            min = 1
          ),
          bsTooltip(
            "intervals",
            paste(
              "Confidence intervals supplied as two-sided",
              "percentiles. i.e. If intervals = 95",
              "will return the two sided 95% confidence interval,",
              "2.5% on each side."
            ),
            placement = "left", trigger = "hover", options = NULL
          ),
          numericInput(
            "filter_threshold",
            label = "Filter threshold",
            value = 0.1,
            min = 0.0001,
            max = 0.5
          ),
          bsTooltip(
            "filter_threshold",
            paste(
              "Minimum SNP-index filter for removing outliers.",
              "Should be less than 0.5."
            ),
            placement = "left", trigger = "hover", options = NULL
          ),
          prettyRadioButtons(
            inputId = "dots_or_line",
            label = "Plot style",
            choices = c("Line", "Points"),
            status = "primary",
            fill = TRUE
          ),
          bsTooltip(
            "dots_or_line",
            paste(
              "WARNING: Plotting dots is significantly more resource intensive."
            ),
            placement = "left", trigger = "hover", options = NULL
          )
        ),
        column(
          width = 12,
          actionBttn(
            inputId = "analyse",
            label = "Analyse",
            style = "material-flat",
            color = "primary"
          ),
          uiOutput("genes")
        ),
        tags$style(
          type = "text/css",
          "#analyse {margin-top: 24px; margin-bottom: 12px;}"
        )
      ),
      uiOutput("results")
    )
  )

  observeEvent(input$analyse, {
    if (snp_table() == 0) {
      sendSweetAlert(
        session = session,
        title = "Oops",
        text = "First you need to import the data. This can be done in the 
        Import & filtering tab above.",
        type = "error"
      )
      return()
    }

    # Progress indication
    progress <- shiny::Progress$new()
    on.exit(progress$close())

    progress$set(message = "Analyzing data", value = 0)
    n <- 8

    # Get annotation
    progress$inc(1 / n, detail = paste("Obtaining annotation")) # 1
    tryCatch({
      anno <- get_annotation(gtf_path = input$reference_gtf)
      },
      error = function(e) {
        sendSweetAlert(
          session = session,
          title = "Oops",
          text = "Something is wrong with the annotation file.",
          type = "error"
        )
      }
    )
    if (!exists("anno")) {
      return()
    }

    # Update UI
    output$genes <- renderUI(
      selectInput(
        inputId = "gene", label = "Select genes",
        choices = as.character(anno$genes), multiple = TRUE
      )
    )

    # Prepare data
    progress$inc(1 / n, detail = paste("Preparing data")) # 2
    alpha <- (100 - input$intervals) / 100

    snps <- filterSNPs(
      SNPset = snp_table(),
      minSampleDepth = 1,
      verbose = TRUE
    )

    chrom_n <- length(unique(snps$CHROM))
    nam <- paste0("yaxis", c("", 2:chrom_n))
    line <- input$dots_or_line == "Line"

    # Analyse
    progress$inc(1 / n, detail = paste("Running window")) # 3

    tryCatch({
        qtl_o <- QTLseqr::runQTLseqAnalysis(
          SNPset = snps,
          windowSize = input$windowSize,
          popStruc = input$pop_structure,
          bulkSize = c(input$bulkSize_high, input$bulkSize_low),
          replications = input$replications,
          intervals = c(input$intervals),
          maxk = 10000
        )
      },
      error = function(e) {
        sendSweetAlert(
          session = session,
          title = "Oops",
          text = "Something went wrong calculating \u0394SNP index.\n
          Try changing settings or less restrictive filtering.",
          type = "error"
        )
      }
    )
    if (!exists("qtl_o")) {
      return()
    }

    progress$inc(1 / n, detail = paste("Calculating G")) # 4
    tryCatch({
        Gprime <- QTLseqr::runGprimeAnalysis(
          SNPset = qtl_o,
          windowSize = input$windowSize,
          outlierFilter = input$filter_method,
          filterThreshold = as.numeric(input$filter_threshold),
          maxk = 10000
        )
      },
      error = function(e) {
        sendSweetAlert(
          session = session,
          title = "Oops",
          text = "P and G statistics could not be estimated because of too many 
          patches of missing data. Most often this is caused by too restrictive 
          filtering and outlier removal. Try changing analysis settings or try 
          less restrictive filtering, but please be advised that the results 
          can be less truthful.",
          type = "error"
        )
      }
    )

    g_successful <- TRUE
    if (!exists("Gprime")) {
      Gprime <- qtl_o
      g_successful <- FALSE
    }

    # Plot
    progress$inc(1 / n, detail = paste("Creating plots")) # 5
    tryCatch({
        r_snps <- plot_raw_snps(data = Gprime)

        n_snps <- plot_nSNPs(SNPset = Gprime, line = line)
        d_snps <- plot_deltaSNP(SNPset = Gprime, line = line)

        if (g_successful) {
          p_vals <- plot_pvalue(SNPset = Gprime, q = alpha, line = line)
          gpri_d <- plotGprimeDist(
            SNPset = Gprime, outlierFilter = input$filter_method,
            binwidth = 0.5, filterThreshold = as.numeric(input$filter_threshold)
          ) + theme_minimal()
          gprime <- plot_gprime(SNPset = Gprime, q = alpha, line = line)
        }
      },
      error = function(e) {
        sendSweetAlert(
          session = session,
          title = "Oops",
          text = "Something went wrong when plotting.\n
          Try changing settings or less restrictive filtering.",
          type = "error"
        )
        return()
      }
    )

    # Edit plotly
    progress$inc(1 / n, detail = paste("Editing plots")) # 6
    r_snps <- edit_plotly(p = r_snps, names = nam, hovermode = "x unified")
    n_snps <- edit_plotly(p = n_snps, names = nam, hovermode = "x unified")
    d_snps <- edit_plotly(p = d_snps, names = nam, hovermode = "x unified")

    if (g_successful) {
      p_vals <- edit_plotly(p = p_vals, names = nam, hovermode = "x unified")
      gprime <- edit_plotly(p = gprime, names = nam, hovermode = "x unified")
    }

    # Render plots
    progress$inc(1 / n, detail = paste("Rendering plots")) # 7
    output$render_proc_n <- renderPlotly(n_snps)
    output$render_proc_diff <- renderPlotly(d_snps)
    output$render_raw_n <- renderPlotly(r_snps)

    if (g_successful) {
      output$render_pvalue <- renderPlotly(p_vals)
      output$render_gdistribution <- renderPlot(gpri_d)
      output$render_gprime <- renderPlotly(gprime)
    }

    outputOptions(output, "render_proc_n", suspendWhenHidden = FALSE)
    outputOptions(output, "render_proc_diff", suspendWhenHidden = FALSE)
    outputOptions(output, "render_raw_n", suspendWhenHidden = FALSE)

    if (g_successful) {
      outputOptions(output, "render_pvalue", suspendWhenHidden = FALSE)
      outputOptions(output, "render_gprime", suspendWhenHidden = FALSE)
    }

    # Generate table
    progress$inc(1 / n, detail = paste("Creating table")) # 8

    output$all_snips <- renderDataTable(
      Gprime,
      options = list(scrollX = TRUE)
    )

    QTLseq_df <- getQTLTable(
      SNPset = Gprime,
      method = "QTLseq",
      interval = input$intervals,
      export = FALSE
    )

    output$qtlseq_table <- renderDataTable(
      QTLseq_df,
      options = list(scrollX = TRUE)
    )

    if (g_successful) {
      Gprime_df <- getQTLTable(
        SNPset = Gprime,
        method = "Gprime",
        alpha = alpha,
        export = FALSE
      )

      output$gprime_table <- renderDataTable(
        Gprime_df,
        options = list(scrollX = TRUE)
      )
    }

    # Save to global variable
    snp_table(Gprime)
    if (g_successful) {
      qtl_tables(list(QTLseq = QTLseq_df, Gprime = Gprime_df))
    }
    else {
      qtl_tables(list(QTLseq = QTLseq_df, Gprime = NULL))
    }
    annotation(anno)

    traces$render_raw_n <- length(r_snps$x$data)
    traces$render_proc_n <- length(n_snps$x$data)
    traces$render_proc_diff <- length(d_snps$x$data)

    if (g_successful) {
      traces$render_pvalue <- length(p_vals$x$data)
      traces$render_gprime <- length(gprime$x$data)
    }

    # Render UI
    output$results <- renderUI(
      tabsetPanel(
        type = "tabs",
        tabPanel(
          "Raw SNP index", plotlyOutput("render_raw_n", height = "1500px")
        ),
        tabPanel(
          "Processed SNP density ",
          plotlyOutput("render_proc_n", height = "1500px")
        ),
        tabPanel(
          "Processed \u0394SNP density",
          plotlyOutput("render_proc_diff", height = "3000px")
        ),
        tabPanel(
          "G’ distribution", plotOutput("render_gdistribution")
        ),
        tabPanel(
          "G’ Statistics", plotlyOutput("render_gprime", height = "1500px")
        ),
        tabPanel(
          "P value", plotlyOutput("render_pvalue", height = "1500px")
        )
      )
    )
  })


  observeEvent(input$gene, {
      ## Mark selected genes
      # prepare
      old <- genes_selected()
      if (old == 0) {
        genes_selected(1)
        return()
      }
      if (old == 1) {
        genes_selected(2)
        return()
      }

      plots <- c(
        "render_proc_n",
        "render_proc_diff",
        "render_gprime",
        "render_raw_n",
        "render_pvalue"
      )
      anno <- annotation()
      selected_gene <- input$gene
      color <- randomColor(1, luminosity = "bright")

      # Check if selected or deselected
      if (length(input$gene) >= length(old)) {
        genes_selected(input$gene)

        new_gene <- tail(selected_gene, 1)
        gene_position <- filter_annotation(
          selected_gene = new_gene, anno = anno
        )

        for (p in plots) {
          mark_gene(
            session = session,
            p = p,
            position = gene_position,
            chromosomes = chromosomes(),
            col = color
          )
        }
      } else {
        if (is.null(selected_gene)) {
          genes_selected(2)
        } else {
          genes_selected(input$gene)
        }

        gene_to_delete <- which(!old %in% selected_gene)

        for (p in plots) {
          delete_gene(
            session = session,
            p = p,
            gene = gene_to_delete,
            trace = traces[[p]]
          )
        }
      }
    },
    ignoreNULL = FALSE
  )

  ##############
  # Data table #
  ##############

  # SNP stats all
  output$snp_stat_tables <- renderUI(
    tagList(
      inputPanel(
        downloadBttn(
          outputId = "save_dataframe_snps",
          label = "Save",
          style = "material-flat",
          color = "primary",
          size = "md",
          block = FALSE,
          no_outline = TRUE
        )
      ),
      DT::dataTableOutput("all_snips")
    )
  )

  output$save_dataframe_snps <- downloadHandler(
    filename = function() {
      sprintf("snp_results_%s.txt", input$ex_name)
    },
    content = function(con) {
      write.table(
        snp_table(),
        file = con, quote = FALSE, sep = "\t", row.names = FALSE
      )
    }
  )

  # deltaSNP significance
  output$qtl_delta_tables <- renderUI(
    tagList(
      inputPanel(
        downloadBttn(
          outputId = "save_dataframe_deltasnp",
          label = "Save",
          style = "material-flat",
          color = "primary",
          size = "md",
          block = FALSE,
          no_outline = TRUE
        )
      ),
      DT::dataTableOutput("qtlseq_table")
    )
  )

  output$save_dataframe_deltasnp <- downloadHandler(
    filename = function() {
      sprintf("qtl_seq_results_%s.txt", input$ex_name)
    },
    content = function(con) {
      write.table(
        qtl_tables()$QTLseq,
        file = con, quote = FALSE,
        sep = "\t", row.names = FALSE
      )
    }
  )

  # Q statistics
  output$qtl_q_tables <- renderUI(
    tagList(
      inputPanel(
        downloadBttn(
          outputId = "save_dataframe",
          label = "Save",
          style = "material-flat",
          color = "primary",
          size = "md",
          block = FALSE,
          no_outline = TRUE
        )
      ),
      DT::dataTableOutput("gprime_table")
    )
  )

  output$save_dataframe <- downloadHandler(
    filename = function() {
      sprintf("qtl_g_results_%s.txt", input$ex_name)
    },
    content = function(con) {
      write.table(
        qtl_tables()$Gprime,
        file = con, quote = FALSE,
        sep = "\t", row.names = FALSE
      )
    }
  )

  ##################
  # Exit container #
  ##################

  observeEvent(input$exit, {
    confirmSweetAlert(
      session,
      "exit_confirmation",
      title = "Exit QTLspyer",
      text = paste(
        "This will shoot down the docker container",
        "and end all running processes inside.",
        "To access the app again you will need to re-run QTLspyer.",
        "Are you sure you want to exit?"
      ),
      type = "warning",
      btn_labels = c("No", "Yes"),
      btn_colors = NULL,
    )
  })

  observeEvent(input$exit_confirmation, {
    if (!input$exit_confirmation) {
      return()
    }

    system("kill -15 1")
  })
})
