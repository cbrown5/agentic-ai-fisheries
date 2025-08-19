# Produce the figures for the GLM test-case
# CJ Brown 2025-08-16 

# Richard to make plots here. Below are the files to use. 

library(tidyverse)
library(readr)
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

mean_scores <- test_results %>%
    group_by(Model, Question, Type) %>%
    summarise(Score_norm = mean(Score_norm, na.rm = TRUE))

ggplot(mean_scores) + 
    aes(x = Question, y = Model, fill = Score_norm) +
    geom_tile() +
    scale_fill_gradient(low = "white", high = "green") +
    theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        panel.background = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()
    ) 

mean_scores_type <- test_results %>%
    group_by(Model, Type, folder_name) %>%
    summarise(Score_norm = mean(Score_norm, na.rm = TRUE)) %>%
    ungroup() %>% 
    group_by(Model, Type) %>%
    summarise(
        Average = mean(Score_norm, na.rm = TRUE), 
        Aptitude = quantile(Score_norm, 0.9, na.rm = TRUE),
        Consistency = 1 - (quantile(Score_norm, 0.9, na.rm = TRUE) - quantile(Score_norm, 0.1, na.rm = TRUE))) %>%
    ungroup() %>%
    pivot_longer(cols = c(Average, Aptitude, Consistency), 
                 names_to = "Metric", 
                 values_to = "Score_norm") 
                 
                 
ggplot(mean_scores_type) + 
                    aes(x = Type, y = Model, fill = Score_norm, label = round(Score_norm, 2)) +
                    geom_tile() +
                    geom_text(size = 3) +
                    facet_grid(Metric~ .) +
                    scale_fill_gradient(low = "white", high = "green") +
                    theme(
                        axis.text.x = element_text(angle = 45, hjust = 1),
                        panel.background = element_blank(),
                        panel.grid.major = element_blank(),
                        panel.grid.minor = element_blank()
                    )

                    # Save the last plot as a PNG file
                    ggsave("Shared/Outputs/glm_summary_heatmap.png", width = 10, height = 6, dpi = 300)
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