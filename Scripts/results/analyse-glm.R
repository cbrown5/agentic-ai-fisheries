# Produce the figures for the GLM test-case
# CJ Brown 2025-08-16 

# Richard to make plots here. Below are the files to use. 

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