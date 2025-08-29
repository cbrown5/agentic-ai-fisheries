# Produce the figures for the GLM test-case
# CJ Brown, R Takyi 2025-08-16 

library(tidyverse)
library(readr)
library(patchwork)

class_levels <- read_csv("Shared/Data/glm-class-levels.csv")
question_types <- read_csv("Shared/Data/glm-question-types.csv")

test_case_results <- read_csv("Shared/Data/glm-test-case-results.csv")


#Get maximum for each question type
test_case_results %>%
    pivot_longer(cols = -c(1:8, 30), 
                 names_to = "Question", 
                 values_to = "Score") %>%
    left_join(question_types, by = "Question") %>%
    group_by( Question) %>%
    summarize(Max_value = max(Score, na.rm = TRUE)) %>%
    data.frame()

#
# Pivot longer the results so that each question is a column, and each model is a row.
#
test_results <- test_case_results %>%
    pivot_longer(cols = -c(1:8, 30), 
                 names_to = "Question", 
                 values_to = "Score") %>%
    left_join(question_types, by = "Question") %>%
    #normalize scores by the max value for each question type
    mutate(Score_norm = Score / `Max value`)


# View(test_results)

names(test_results)


# Set the desired order for Type
mean_scores <- test_results %>%
    group_by(Model, Question, Type) %>%
    summarise(Score_norm = mean(Score_norm, na.rm = TRUE)) 

mean_scores$Type <- factor(mean_scores$Type, 
    levels = c("Interpretation", "Completeness", "Technical Implementation", "Bonus Points"))
    

## PLOT 3A
# Show all RColorBrewer palettes
library(RColorBrewer)
display.brewer.all()

fig3a <- ggplot(mean_scores) + 
    aes(x = Question, y = Model, fill = Score_norm, label = round(Score_norm, 2)) +
    geom_tile() +
    labs(x = "", y = "") + 
    geom_text(size = 3) +
    facet_grid(.~ Type, scales = "free_x", space = "free_x") +
    scale_fill_distiller("Accuracy \n score", palette = "Blues", direction = 1) +
    theme(
    axis.text.x = element_text(size = 11, angle = 45, hjust = 1),
    axis.text.y = element_text(size = 11),
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 11),
    strip.text = element_text(size = 9),
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
    ) 

fig3a


mean_scores_type <- test_results %>%
    group_by(Model, Type, Question) %>%
    summarise(Score_norm = mean(Score_norm, na.rm = TRUE)) %>%
    ungroup() %>% 
    group_by(Model, Type) %>%
    summarise(
        Accuracy = mean(Score_norm, na.rm = TRUE), 
        Aptitude = quantile(Score_norm, 0.9, na.rm = TRUE),
        Reliability = 1 - (quantile(Score_norm, 0.9, na.rm = TRUE) - quantile(Score_norm, 0.1, na.rm = TRUE))) %>%
    ungroup() %>%
    pivot_longer(cols = c(Accuracy, Aptitude, Reliability), 
                 names_to = "Metric", 
                 values_to = "Score_norm") 
          
mean_scores_type$Type <- factor(mean_scores_type$Type, 
    levels = c("Interpretation", "Completeness", "Technical Implementation", "Bonus Points"))

# PLOT 3B

fig3b <- ggplot(mean_scores_type) + 
                    aes(x = Type, y = Model, fill = Score_norm, label = round(Score_norm, 2)) +
                    geom_tile() +
                    geom_text(size = 3) +
                    facet_grid(Metric~ .) +
                    scale_fill_distiller("Score", palette = "Greens", direction = 1) +
                    ylab("") + 
                    xlab("") + 
                    theme(
                        axis.text.x = element_text(size = 11, angle = 45, hjust = 1),
                        axis.text.y = element_text(size = 11),
                        axis.title.x = element_text(size = 12),
                        axis.title.y = element_text(size = 12),
                        legend.title = element_text(size = 12),
                        legend.text = element_text(size = 11),
                        strip.text = element_text(size = 11),
                        panel.background = element_blank(),
                        panel.grid.major = element_blank(),
                        panel.grid.minor = element_blank()
                    )
fig3b
glm_fig <- (fig3a / fig3b) + 
    plot_annotation(tag_levels = 'a', tag_prefix = "(", 
        tag_suffix = ")") & 
    theme(plot.tag = element_text(size = 16))
glm_fig
# Save the above plot as fig3
ggsave(glm_fig, filename = "Shared/Outputs/figure-3.png", dpi = 600,
width = 11, height = 12)
#
# Cost plots 
#



# Mean total cost by type and model
mean_total_cost <- test_results %>%
  group_by(Model, Type, folder_name) %>%
  summarise(`Total cost` = mean(`Total cost`, na.rm = TRUE)) %>%
    ungroup() %>%
    group_by(Model, Type) %>%  
    summarise(
        `Average` = mean(`Total cost`, na.rm = TRUE), 
        `Aptitude` = quantile(`Total cost`, 0.9, na.rm = TRUE),
        `Consistency` = 1 - (quantile(`Total cost`, 0.9, na.rm = TRUE) - quantile(`Total cost`, 0.1, na.rm = TRUE))) %>%
    ungroup() %>%
    pivot_longer(cols = c(`Average`, `Aptitude`, `Reliability`), 
                 names_to = "Metric", 
                 values_to = "Total cost")

# Save the above plot as figure 3 and add to manuscript.qmd
#ggsave("Shared/Outputs/figure-3.png", dpi = 600) 

mean_total_cost <- test_results %>%
    group_by(Model, Type) %>%
    summarise(`Total cost` = mean(`Total cost`, na.rm = TRUE)) %>%
    ungroup()

ggplot(mean_total_cost) +
    aes(x = `Total cost`, y = Type, fill = Model, label = round(`Total cost`, 2)) +
    geom_bar(stat = "identity", position = "dodge") +
    geom_text(size = 3, position = position_dodge(width = 0.9), vjust = -0.5) +
    scale_fill_brewer(palette = "Set1") +
    labs(x = "Total Cost", y = "Type", title = "Average Total Cost by Model and Type") +
    theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        panel.background = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()
    )   

# Mean total tokens in and out by type and model
mean_total_tokens <- test_results %>%
    group_by(Model, Type) %>%
    summarise(
        `Total tokens in (1000s)` = mean(`Total tokens in (1000s)`, na.rm = TRUE),
        `Total tokens out (1000s)` = mean(`Total tokens out (1000s)`, na.rm = TRUE)
    ) %>%

    pivot_longer(cols = c(`Total tokens in (1000s)`, `Total tokens out (1000s)`), 
                 names_to = "Token_Type", 
                 values_to = "Total_tokens") %>%
    ungroup()      

ggplot(mean_total_tokens) +
    aes(x = Total_tokens, y = Type, fill = Model, label = round(Total_tokens, 2)) +
    geom_bar(stat = "identity", position = "dodge") +
    geom_text(size = 3, position = position_dodge(width = 0.9), vjust = -0.5) +
    facet_wrap(Token_Type~ .) +
    scale_fill_brewer(palette = "Set1") +
    labs(x = "Total tokens (in 1000s)", y = "Type", title = "Average Total Tokens by Model and Type") +
    theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        panel.background = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()
    )

mean_total_tokens_types <- test_results %>%
    group_by(Model) %>%
    summarise(
        `Total tokens in (1000s)` = mean(`Total tokens in (1000s)`, na.rm = TRUE),
        `Total tokens out (1000s)` = mean(`Total tokens out (1000s)`, na.rm = TRUE)
    ) %>%
    ungroup()

mean_total_tokens_types %>%
    pivot_longer(
        cols = c(`Total tokens in (1000s)`, `Total tokens out (1000s)`), 
        names_to = "Token_type", 
        values_to = "Total_tokens"
      ) %>%
    
      ggplot(aes(x = Model, y = Total_tokens, fill = Token_type, label = round(Total_tokens, 2))) +
      geom_bar(stat = "identity", position = "dodge") +
      labs(
        x = "Total tokens",
        y = "Total cost",
        title = "Total Cost vs Total Tokens by Model and Token Type"
      ) +
      scale_fill_brewer(palette = "Set1") +
      labs(x = "Model", y = "Total tokens", fill = "Token type", title = "Average Total Tokens by Model") +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        panel.background = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()
      )

mean_max_value <- test_results %>%
    group_by(Model, Question, Type) %>%
    summarise(`Max value` = mean(`Max value`, na.rm = TRUE))

ggplot(mean_max_value) + 
    aes(x = Type, y = Question, fill = `Max value`) +
    geom_tile() +
    scale_fill_gradient(low = "white", high = "green") +
    theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        panel.background = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()
    ) 


mean_score_30 <- test_results %>%
    group_by(Model, `...30`) %>%
    summarise(Score = mean(Score, na.rm = TRUE))

ggplot(mean_score_30) + 
    aes(x = `...30`, y = Model, fill = Score) +
    geom_tile() +
    scale_fill_gradient(low = "white", high = "green") +
    theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        panel.background = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()
    ) 

    



#  Questions for the rubric along with levels of answers. This is used to evaluate the AI's performance on the GLM test case.
`glm-class-levels.csv`

#Questions for the rubric along with types of answers split into three categories for summarizing. Includes maximum score for each question. 
`glm-question-types.csv`

# Results for all agent runs, marked against the rubric. 
`glm-test-case-results.csv`

#pre-processing:
# divide each question by its max value in the `glm-question-types.csv` file.

# We will use three metrics to evaluate scores. Summarize these for each model and question: 
# the average of the 10 runs for each model
# The 90% percentile score 'aptitude', is a measures of how good the model can be. 
# The difference between the 10% percentile and the 90% percentile is a measure of how consistent the model is. Do 1-this score to get a consistency score, where 1 is perfect consistency and 0 is no consistency.

#Then make a table where columns are each question and there is a row for each model and a facet for each metric. Values in the matrix are the scores. These can be coloured by the score, with a gradient from white (0) to green (1) (or colour of your choice).

# Then do a summary table. In this summary table take the table above, then average across each of aptitude, consistency and average for each model, grouping by the question type in the `glm-question-types.csv` file. So this graph has a row for each model and a column for each question type, a facet for each score type, with the values being the average across the questions of that type.