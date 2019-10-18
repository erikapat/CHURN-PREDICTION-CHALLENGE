


rm(list=ls())
require(data.table)
require(dplyr)
require(recipes)
require(lubridate)
require(arules)
library(FSelector)
require(ggplot2)
require(tidyquant)
require(corrr)

source('src/graphics.R')
#source('src/visualize_data.R')

CV_data <- fread('churn.all.txt')

names = c('state', 'account_length', 'area_code', 'phone_number', 'international_plan', 'voice_mail_plan',  
         'number_vmail_messages', 'total_day_minutes', 'total_day_calls', 'total_day_charge', 'total_eve_minutes',
         'total_eve_calls', 'total_eve_charge', 'total_night_minutes', 'total_night_calls', 'total_night_charge', 
         'total_intl_minutes', 'total_intl_calls', 'total_intl_charge', 'number_customer_service_calls', 'Churn')

names(CV_data) <- names
head(CV_data)

# eliminate variables
CV_data <- CV_data %>%  select(-phone_number) %>% mutate(Churn = as.character(Churn), Churn = if_else(Churn == "False." , 0, 1))
# DUMMIES -----------------------------------------------------------------------------------------------
#Transform character to dummies
rec_obj <- recipe(Churn ~ ., data = CV_data) %>%
  step_dummy(all_nominal(), -all_outcomes()) %>%
  #step_discretize(premium, options = list(cuts = 6)) %>%
  prep(data = data)

CV_data    <- bake(rec_obj, new_data = CV_data)
CV_data    <- as.data.table(data)
CV_data <- CV_data %>%  select(-area_code)
dim(CV_data)

dt <- only_numeric_variables(CV_data) # take only numeric data for now
dt <- data.frame(dt, churn = CV_data$Churn)
m = mean(dt$total_eve_charge) + mean(dt$total_night_charge) + mean(dt$total_day_charge) + mean(dt$total_intl_charge)
m
#dt <- dt %>% mutate(consume_high = ifelse(total_eve_charge + total_night_charge + total_day_charge + 
#                                            total_intl_charge < m, 0, 1))
#table(dt$consume_high)
dt.x <- dt %>%  select('account_length', 'number_vmail_messages', 'total_day_minutes', 'total_day_calls', 'total_day_charge', 'total_eve_minutes',
                       'total_eve_calls', 'total_eve_charge', 'total_night_minutes', 'total_night_calls', 'total_night_charge', 
                       'total_intl_minutes', 'total_intl_calls', 'total_intl_charge', 'number_customer_service_calls', 'international_plan_yes', 'voice_mail_plan_yes',
                       'churn')

# include variable

CorrelationGraph(dt.x, tam= 1.5, figures.dir = 'fig')


#Information gain
dt.values.no.interactions <- information.gain(churn ~., dt %>%  select(-Churn))
g <- gain_info_graph(dt.values.no.interactions, top = 20)
g$d

#------------------------------------------------------------------------------------------------------


# DECISION TREE

require(tree)
##################################################
m1 = dt %>%  select(-Churn)
control.values <- tree.control(nrow(m1), mincut = 0, minsize = 2, mindev = 0.01)
#method = "recursive.partition",
#split = c("deviance", "gini"),
m1.tr <- tree(m1$churn ~.,m1[, 1:68], split = "deviance", wts="TRUE") #usamos el estad?stico de Gini...
m1.tr
summary(m1.tr)
plot(m1.tr); text(m1.tr)

pred <- predict(m1.tr,m1[, 1:68])
result <- rep(0, length(pred))
result[pred >= 0.5] <- 1

require(SDMTools)
confusion.matrix(m1$churn, result, threshold = 0.5)

#-----------------------------------------------------------------------------------------------------
m1 <- m1 %>% select('account_length', 'number_vmail_messages', 'total_day_minutes', 'total_day_calls', 'total_day_charge', 'total_eve_minutes',
                    'total_eve_calls', 'total_eve_charge', 'total_night_minutes', 'total_night_calls', 'total_night_charge', 
                    'total_intl_minutes', 'total_intl_calls', 'total_intl_charge', 'number_customer_service_calls', 'international_plan_yes', 'voice_mail_plan_yes',
                    'churn')
data_long <- gather(m1, variable, value, account_length:voice_mail_plan_yes, factor_key=TRUE)
data_long %>% head()
# 

p <- ggplot(data = data_long, aes(x=variable, y=value)) +  geom_boxplot(aes(fill=factor(churn))) 
p <- p+ coord_flip() 
#p <- p + facet_wrap( ~ variable)
p <- p + theme(text = element_text(size=20),axis.text.x = element_text(angle=90, hjust=1)) 
p


p <- ggplot(data = data_long, aes(x=variable, y=churn)) 
p <- p + geom_boxplot(aes(fill=factor(churn))) + coord_flip()
#p <- p + geom_jitter()
p <- p + facet_wrap( ~ variable, scales="free")
p <- p + xlab("x-axis") + ylab("y-axis") + ggtitle("Title")
p <- p + guides(fill=guide_legend(title="Legend_Title"))
p 
