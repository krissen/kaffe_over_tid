# ui.R
# User Interface för Kaffekok-analys

ui <- fluidPage(
  # Custom CSS and favicon
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    tags$link(rel = "icon", type = "image/x-icon", href = "favicon.ico"),
    tags$title("Kaffekok: Tid per Kopp - Moccamaster Classic")
  ),
  
  # Title section with logo
  div(class = "title-panel",
    fluidRow(
      column(2,
        div(class = "logo-container",
          img(src = "moccamaster_logo.png", alt = "Moccamaster")
        )
      ),
      column(10,
        h2("Kaffekok: Tid per Kopp"),
        div(class = "subtitle", "Analys av bryggtid för Moccamaster Classic")
      )
    )
  ),
  
  sidebarLayout(
    sidebarPanel(
      h3("Lägg till ny data"),
      numericInput("cups_input", "Antal koppar:", value = 3, min = 1, max = 20),
      textInput("time_input", "Tid (m:ss):", value = "3:00", placeholder = "Ex: 3:30"),
      actionButton("add_button", "Lägg till", class = "btn-primary"),
      hr(),
      div(class = "info-text",
        p(style = "margin: 0;", strong("Tidsformat:"), "minuter:sekunder (ex: 3:30 för 3 min 30 sek)"),
        p(style = "margin: 5px 0 0 0;", "Accepterar också format som 3'30, 3:30, etc.")
      ),
      hr(),
      h4("Datatabell"),
      tableOutput("data_table")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Plot", 
                 div(class = "plot-container",
                   plotOutput("classical_plot", height = "500px")
                 ),
                 hr(),
                 h4("Tolkning:"),
                 p("Punkterna visar faktiska mätningar från ", strong("Moccamaster Classic"), "."),
                 p("Linjen visar modellens prediktion (kvadratisk modell)."),
                 p("Det skuggade området visar 95% prediktionsintervall - där nästa mätning förväntas ligga.")
        ),
        tabPanel("Prediktioner",
                 h3("Prognoser 1-10 koppar"),
                 tableOutput("predictions_table"),
                 hr(),
                 downloadButton("download_predictions", "Ladda ner CSV", class = "btn-success")
        ),
        tabPanel("Modellinfo",
                 h3("Modellinformation"),
                 verbatimTextOutput("model_info")
        )
      )
    )
  )
)
