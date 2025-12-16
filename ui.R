# ui.R
# User Interface för Kaffekok-analys

ui <- fluidPage(
  # Custom CSS and favicon
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    tags$link(rel = "icon", type = "image/x-icon", href = "favicon.ico"),
    tags$title("Kaffekok: Tid per Kopp - Moccamaster Classic")
  ),
  
  # Compact title section with logo
  div(class = "title-panel",
    fluidRow(
      column(2,
        div(class = "logo-container",
          img(src = "moccamaster_logo.png", alt = "Moccamaster")
        )
      ),
      column(10,
        div(class = "text-content",
          h2("Kaffekok: Tid per Kopp"),
          div(class = "subtitle", "Analys av bryggtid för Moccamaster Classic")
        )
      )
    )
  ),
  
  sidebarLayout(
    sidebarPanel(
      h4("Prediktioner (1-10 koppar)"),

      h5("Klassisk modell"),
      tableOutput("predictions_table_klassisk"),

      conditionalPanel(
        condition = "output.bayes_available",
        hr(),
        h5("Bayes-modell"),
        tableOutput("predictions_table_bayes")
      ),

      hr(),
      downloadButton("download_predictions", "Ladda ner CSV (båda)", class = "btn-success"),
      p(class = "info-text", style = "margin-top: 10px;",
        "Exporterar båda modellernas prediktioner i samma fil.")
    ),

    mainPanel(
      tabsetPanel(
        tabPanel("Klassisk",
                 div(class = "plot-container",
                   plotOutput("classical_plot", height = "450px")
                 ),
                 div(class = "interpretation-section",
                   h4("Tolkning:"),
                   p("Punkterna visar faktiska mätningar från ", strong("Moccamaster Classic"), "."),
                   p("Linjen visar modellens prediktion (kvadratisk regression)."),
                   p("Det skuggade området visar 95% prediktionsintervall."),
                   p(class = "warning-text",
                     em("OBS: Klassisk modell kan ge icke-monotona prediktioner vid höga koppantal."))
                 )
        ),
        tabPanel("Bayes",
                 conditionalPanel(
                   condition = "output.bayes_available",
                   div(class = "plot-container",
                     plotOutput("bayes_plot", height = "450px")
                   ),
                   div(class = "interpretation-section",
                     h4("Tolkning:"),
                     p("Punkterna visar faktiska mätningar från ", strong("Moccamaster Classic"), "."),
                     p("Linjen visar posterior median (Bayesiansk regression)."),
                     p("Det skuggade området visar 95% prediktivt intervall (posterior predictive)."),
                     p(class = "success-text",
                       em("Bayes-modellen ger oftast monotona prediktioner tack vare regularisering."))
                   )
                 ),
                 conditionalPanel(
                   condition = "!output.bayes_available",
                   div(class = "info-section",
                     h4("Bayes ej tillgängligt"),
                     p("Installera ", code("rstanarm"), " och ", code("loo"), " för Bayes-analys:"),
                     pre("install.packages(c('rstanarm', 'loo'))")
                   )
                 )
        ),
        tabPanel("Data",
                 h3("Dataset och ny mätning"),
                 h4("Lägg till ny mätning"),
                 numericInput("cups_input", "Antal koppar:", value = 3, min = 1, max = 20),
                 textInput("time_input", "Tid (m:ss):", value = "3:00", placeholder = "Ex: 3:30"),
                 actionButton("add_button", "Lägg till", class = "btn-primary"),
                 div(class = "info-text",
                   p(style = "margin: 0;", strong("Tidsformat:"), "minuter:sekunder (ex: 3:30)"),
                   p(style = "margin: 5px 0 0 0;", "Accepterar också 3'30, 3m30s, etc.")
                 ),
                 hr(),
                 h4("Aktuellt dataset"),
                 tableOutput("data_table")
        ),
        tabPanel("Modellinfo",
                 h3("Modellinformation"),
                 verbatimTextOutput("model_info")
        )
      )
    )
  )
)
