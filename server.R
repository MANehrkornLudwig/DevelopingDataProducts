# server.R
require(shiny)
require(caret)
require(randomForest)
require(rCharts)
require(ggplot2)

#   load data
load("data/credit_data.Rda")

#   app
function(input, output) {

#   Exploratory Analysis Tab
    output$graph <- renderChart({
        plotdefault <- rPlot(input$xvar, 
                             input$yvar,
                             data=creditdata,
                             color='default',
                             type='point')
        
        plotdefault$addParams(dom = 'graph')
        
        return(plotdefault)
    })
    
    
#   Model Estimation Tab

    #   decision tree
        dectree <- eventReactive(input$estimatego, {
    
        #   create training and test set (when action buttom is pressed)
            inTrain <- createDataPartition(y = creditdata$default,
                                           p = input$ppercent,
                                           list = FALSE)
                                
            
            training <- creditdata[ inTrain,]
            testing  <- creditdata[-inTrain,]
            
        #   cv options (when action buttom is pressed)
            ctrl <- trainControl(method = "cv",
                                 number = input$repet)
            
        #   train model (when action buttom is pressed)
            modelfit <- train(default~.,
                              data=training,
                              method="rf",
                              trControl=ctrl,
                              prox=TRUE,
                              allowParallel=TRUE)
            
            modelfitsum <- modelfit #$results


        #   predict testing data
            predmodel <- predict(modelfit, newdata = testing)
            
        #   confusion matrix
            confmatrix <- confusionMatrix(data = predmodel, testing$default)
        
        #   create list for output
            dectree <- list(modelfitsum = modelfitsum, confmatrix = confmatrix)
    }
    )
        
    #   predict probability of default
        clientdatares <- eventReactive(input$enterdata, {
            int <- creditdata[1,-17]
            int[1,1] <- input$cb                        # checking balance
            int[1,2] <- input$mld                       # months_loan_duration
            int[1,3] <- input$ch                        # credit_history
            int[1,4] <- input$pu                        # purpose
            int[1,5] <- input$am                        # amount
            int[1,6] <- input$sb                        # savings_balance
            int[1,7] <- input$ed                        # employment_duration
            int[1,8] <- input$poi                       # percent_of_income
            int[1,9] <- input$yar                       # years_at_residence   
            int[1,10] <- input$age                      # age
            int[1,11] <- input$oc                       # other_credit
            int[1,12] <- input$ho                       # housing
            int[1,13] <- input$elc                      # existing_loans_count
            int[1,14] <- input$job                      # job
            int[1,15] <- input$de                       # dependents
            int[1,16] <- input$ph                       # phone
            
            int.t <- as.data.frame(t(int[,1:ncol(int)]))
            colnames(int.t) <- c("Client Data")
            
            probdef <- predict(modelfit, newdata = int)
            
            list(clientdata = int.t, probdef = probdef)
        })
        
    #   prepare output for ui
        output$modelfitsum <- renderPrint({dectree()$modelfitsum})
        output$confmatrix <- renderPrint({dectree()$confmatrix})
        output$clientdata <- renderTable({clientdatares()$clientdata})
        output$probdef <- renderPrint({clientdatares()$probdef})
    
    }