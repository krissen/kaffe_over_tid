# ui.R
# User Interface för Kaffekok-analys

ui <- fluidPage(
  # Custom CSS and favicon
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    tags$link(rel = "icon", type = "image/x-icon", href = "favicon.ico"),
    tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"),
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

      # Bayes-tabell (visas när klar)
      conditionalPanel(
        condition = "output.bayes_available",
        h5("Bayes-modell"),
        shinycssloaders::withSpinner(
          tableOutput("predictions_table_bayes"),
          type = 4, color = "#B2182B", size = 0.5
        ),
        hr()
      ),

      # Bayes-status (visas under beräkning)
      conditionalPanel(
        condition = "output.bayes_loading",
        div(class = "loading-message",
          style = "padding: 10px; background: #fff3cd; border-radius: 4px; margin: 10px 0;",
          p(style = "margin: 0; color: #856404;",
            tags$i(class = "fa-solid fa-spinner fa-spin"),
            " Beräknar Bayes-modell... (kan ta 10-30 sek)")
        ),
        hr()
      ),

      # Klassisk tabell (visas alltid)
      h5("Klassisk modell"),
      shinycssloaders::withSpinner(
        tableOutput("predictions_table_klassisk"),
        type = 4, color = "#2166AC", size = 0.5
      ),

      hr(),
      downloadButton("download_predictions", "Ladda ner CSV (båda)", class = "btn-success"),
      p(class = "info-text", style = "margin-top: 10px;",
        "Exporterar båda modellernas prediktioner i samma fil.")
    ),

    mainPanel(
      tabsetPanel(
        id = "main_tabs",
        selected = "Klassisk",  # Visa Klassisk initialt (server byter till Kombinerad när Bayes klar)
        tabPanel("Kombinerad",
                 div(class = "plot-container",
                   shinycssloaders::withSpinner(
                     plotOutput("combined_plot", height = "450px"),
                     type = 4, color = "#666666"
                   )
                 ),
                 div(class = "interpretation-section",
                   h4("Tolkning:"),
                   p("Båda modellerna visas i samma figur:"),
                   tags$ul(
                     tags$li(span(style = "color: #2166AC; font-weight: bold;", "Blå"), " = Klassisk regression"),
                     tags$li(span(style = "color: #B2182B; font-weight: bold;", "Röd"), " = Bayesiansk regression")
                   ),
                   p("Skuggade områden visar 95% prediktionsintervall."),
                   p(em("Om Bayes ej är tillgängligt visas endast klassisk modell."))
                 )
        ),
        tabPanel("Klassisk",
                 div(class = "plot-container",
                   shinycssloaders::withSpinner(
                     plotOutput("classical_plot", height = "450px"),
                     type = 4, color = "#2166AC"
                   )
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
                     shinycssloaders::withSpinner(
                       plotOutput("bayes_plot", height = "450px"),
                       type = 4, color = "#B2182B"
                     )
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
                   condition = "output.bayes_loading",
                   div(class = "info-section",
                     style = "text-align: center; padding: 40px;",
                     div(style = "font-size: 48px; color: #B2182B;",
                       tags$i(class = "fa-solid fa-gear fa-spin")
                     ),
                     h4("Beräknar Bayes-modell..."),
                     p("Detta kan ta 10-30 sekunder beroende på datamängd."),
                     p(em("Bayesiansk regression ger robustare prediktioner."))
                   )
                 ),
                 conditionalPanel(
                   condition = "!output.bayes_available && !output.bayes_loading",
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
                 shinycssloaders::withSpinner(
                   tableOutput("data_table"),
                   type = 4, color = "#666666", size = 0.5
                 )
        ),
        tabPanel("Modellinfo",
                 h3("Modellinformation"),
                 shinycssloaders::withSpinner(
                   verbatimTextOutput("model_info"),
                   type = 4, color = "#666666"
                 )
        )
      )
    )
  )
)
