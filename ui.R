# ui.R  of credit risk assessment application

#   required libraries
    require(shiny)
    require(rCharts)
    
#   load data
    load("data/credit_data.Rda")

#   user interface
    navbarPage("Credit Risk Assessment Application",
                       tabPanel("Documentation",
                                mainPanel(
                                    h1("Introduction"),
                                    p("The Credit Risk Assessement Application provides two tools for the assessment of individual risk of credit default. The application uses a modified version of the German Credit Data set which is provided by the ",
                                      a("UCI Machine Learning Repository.", 
                                        href = "https://archive.ics.uci.edu/ml/datasets/Statlog+%28German+Credit+Data%29"), 
                                      "The modified version of this data set can be found ",
                                      a("here.",
                                        href = "https://www.packtpub.com/books/content/support/13251"),
                                      "A description of the unmodified raw data can be downloaded from the ",
                                      a("UCI Machine Learning Repository.",
                                        href = "https://archive.ics.uci.edu/ml/machine-learning-databases/statlog/german/german.doc"),
                                      "The following paragraphs provide information on the scope and usage of the different functions of the application."
                                    ),
                                    h1("Exploration"),
                                    p("The ",
                                      em("Exploration"),
                                      " panel provides an interactive scatter plot which allows the visual exploration of the aforementioned data. The variables can be selected using drop-down lists and the data is automatically colored by credit default status. The plot is created using ",
                                      em("rCharts"),
                                      "."
                                    ),
                                    h1("Model Estimation"),
                                    p("The ",
                                      em("Model Estimation"),
                                      " panel offers an interface for training a random forest using k-fold cross-validation. The user provides two inputs:",
                                      tags$li("Percentage of total observations that should be used for training"),
                                      tags$li("Number of folds for cross-validation (restricted to 2-5 folds due to computational reasons)")
                                    ),
                                    p("Training and validation of the random forest model are performed using the ",
                                      em("caret"),
                                      " and the ",
                                      em("randomForest"),
                                      " package. After the user has set the parameters, the process can be started by clicking the ",
                                      em("Train Model - "),
                                      "buttom. It takes some time to train and evaluate the model, so pleace be patient until the results are displayed."
                                    ),
                                    p(strong("The model has to be fitted before you use the Individual Risk Assessment panel.")),
                                    h1("Individual Risk Assessment"),
                                    p("The ",
                                      em("Individual Risk Assessment"),
                                      " panel provides the possibility to input client data and to predict whether the default status will be 'yes' or 'no' based on the model estimated before and the entered data. Prediction is done by clicking on the ",
                                      em("Predict Default Status - "),
                                      "buttom."
                                    )
                                    
                                )
                       ),
                       tabPanel("Exploration",
                                sidebarLayout(
                                    sidebarPanel(
                                        selectInput(inputId = "xvar",
                                                    label = "Select variable for horizontal axis",
                                                    choices = sort(names(creditdata)[-17]),
                                                    selected = "job"
                                        ),
                                        selectInput(inputId = "yvar",
                                                    label = "Select variable for vertical axis",
                                                    choices = sort(names(creditdata)[-17]),
                                                    selected = "amount"
                                        )
                                    ),
                                    mainPanel(
                                        showOutput("graph", "polycharts")
                                    )
                                )
                       ),
                       tabPanel("Model Estimation",
                                sidebarLayout(
                                    sidebarPanel(
                                        sliderInput(inputId = "ppercent",
                                                    "Percent of observations for training data",
                                                    min = 0.1, max = 0.9, value = 0.6, step=0.1),
                                        sliderInput(inputId = "repet",
                                                    "Number of cross validations",
                                                    min = 2, max = 5, value = 1),
                                        actionButton(inputId = "estimatego",
                                                     label= "Train Model")
                                    ),
                                    mainPanel(
                                        h1("Random Forest Model Fit"),
                                        verbatimTextOutput("modelfitsum"),
                                        h1("Random Forest Confusion Matrix"),
                                        verbatimTextOutput("confmatrix")
                                        
                                    )
                                )
                       ),
                       tabPanel("Individual Risk Assessment",
                                sidebarLayout(
                                    sidebarPanel(
                                        selectInput(inputId = "cb",
                                                    label = "Checking Balance",
                                                    choices = sort(levels(creditdata$checking_balance)),
                                                    selected = "< 0 EUR"
                                        ),
                                        numericInput(inputId = "mld",
                                                     label = "Months Loan Duration",
                                                     value = "12",
                                                     min = "1",
                                                     max = "72"
                                        ),
                                        selectInput(inputId = "ch",
                                                    label = "Credit History",
                                                    choices = sort(levels(creditdata$credit_history)),
                                                    selected = "critical"
                                        ),
                                        selectInput(inputId = "pu",
                                                    label = "Purpose",
                                                    choices = sort(levels(creditdata$purpose)),
                                                    selected = "car"
                                        ),
                                        numericInput(inputId = "am",
                                                     label = "Amount",
                                                     value = "1000",
                                                     min = "0",
                                                     max = "20000"
                                        ),
                                        selectInput(inputId = "sb",
                                                    label = "Savings Balance",
                                                    choices = sort(levels(creditdata$savings_balance)),
                                                    selected = "< 50 EUR"
                                        ),
                                        selectInput(inputId = "ed",
                                                    label = "Employment Duration",
                                                    choices = sort(levels(creditdata$employment_duration)),
                                                    selected = "< 1 year"
                                        ),
                                        numericInput(inputId = "poi",
                                                     label = "Percent of Income",
                                                     value = "1",
                                                     min = "1",
                                                     max = "4"
                                        ),
                                        numericInput(inputId = "yar",
                                                     label = "Years at Residence",
                                                     value = "1",
                                                     min = "1",
                                                     max = "4"
                                        ),
                                        numericInput(inputId = "age",
                                                     label = "Age",
                                                     value = "18",
                                                     min = "18",
                                                     max = "75"
                                        ),
                                        selectInput(inputId = "oc",
                                                    label = "Other Credit",
                                                    choices = sort(levels(creditdata$other_credit)),
                                                    selected = "none"
                                        ),
                                        selectInput(inputId = "ho",
                                                    label = "Housing",
                                                    choices = sort(levels(creditdata$housing)),
                                                    selected = "rent"
                                        ),
                                        numericInput(inputId = "elc",
                                                     label = "Existing Loans Count",
                                                     value = "1",
                                                     min = "1",
                                                     max = "4"
                                        ),
                                        selectInput(inputId = "job",
                                                    label = "Job",
                                                    choices = sort(levels(creditdata$job)),
                                                    selected = "skilled"
                                        ),
                                        numericInput(inputId = "de",
                                                     label = "Dependents",
                                                     value = "1",
                                                     min = "1",
                                                     max = "2"
                                        ),
                                        selectInput(inputId = "ph",
                                                    label = "Phone",
                                                    choices = sort(levels(creditdata$phone)),
                                                    selected = "yes"
                                        ),
                                        actionButton(inputId = "enterdata",
                                                     label= "Predict Default Status")
                                    ),
                                    mainPanel(
                                        h1("Submitted Client Data"),
                                        tableOutput("clientdata"),
                                        h1("Predicted Default Status"),
                                        verbatimTextOutput("probdef")
                                    )
                                )
                                
                       )
    )