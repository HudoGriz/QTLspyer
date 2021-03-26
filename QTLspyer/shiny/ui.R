dashboardPage(
  dashboardHeader(
    title = "QTLspyer",
    tags$li(class = "dropdown",
            tags$li(
              class = "dropdown",
              actionLink("exit", "", class = "fas fa-power-off")
              )
              )
  ),
  dashboardSidebar(sidebarMenuOutput("menu")),
  dashboardBody(
    tags$head(
      tags$style(
        HTML(".logo {
          background-color: #6aa3d5 !important;
          }
          .navbar {
          background-color: #428BCA !important;
          }
          ")
      )
    ),
    tabItems(
      tabItem(
        tabName = "settings",
        uiOutput("tools_page")
      ),
      tabItem(
        tabName = "raw_fastq",
        uiOutput("raw_fastqcs")
      ),
      tabItem(
        tabName = "filter-tuning",
        uiOutput("tuning")
      ),
      tabItem(
        tabName = "genome-map",
        uiOutput("gmap")
      ),
      tabItem(
        tabName = "snp_stat",
        uiOutput("snp_stat_tables")
      ),
      tabItem(
        tabName = "qtl_delta",
        uiOutput("qtl_delta_tables")
      ),
      tabItem(
        tabName = "qtl_q",
        uiOutput("qtl_q_tables")
      ),
      tabItem(
        tabName = "help",
        fluidPage(
          column(
            width = 12,
            box(
              width = 12,
              title = "Introduction",
              collapsible = TRUE,
              includeMarkdown("markdown/introduction.md")
            ),
            box(
              width = 12,
              title = "User guide",
              collapsible = TRUE,
              includeMarkdown("markdown/user_guide.md")
            ),
            box(
              width = 12,
              title = "Input data",
              collapsible = TRUE,
              includeMarkdown("markdown/input_data.md")
            ),
            box(
              width = 12,
              title = "Germline short variant discovery",
              collapsible = TRUE,
              includeMarkdown("markdown/variant_calling.md")
            ),
            box(
              width = 12,
              title = "Filtering SNPs",
              collapsible = TRUE,
              includeMarkdown("markdown/filtering.md")
            ),
            box(
              width = 12,
              title = "QTL Analysis",
              collapsible = TRUE,
              includeMarkdown("markdown/analysis.md")
            ),
            box(
              width = 12,
              title = "QTL tables",
              collapsible = TRUE,
              includeMarkdown("markdown/table.md")
            )
          )
        )
      )
    )
  ),
  tags$head(includeCSS("www/styles.css"))
)
