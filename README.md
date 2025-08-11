# Automating fisheries modelling with agentic AI

Christopher J. Brown, Richard Takyi, ....

## TODO
- Move the test files to another project directory
- make a framework to record results. 
- Work out VB model
- Work out YPR model
- Do glm model runs again, I tihnk teh readme is good now. 

Workflow
- Copy files in GLM test case to agentic AI project directory
- Check Roo code autoapprove is on with right approvals
- Pick model and set to 'code' mode. 
- Run the test case
- Save teh chat log
- save tokens in, tokens out and cost. 
- save model info


## Summary

Fisheries modelling can take years of specialist training to learn. Agentic AI systems automate complex computing programming workflows and could lower the technical barrier for fisheries modelling. However, questions remain about the quality of AI derived models. Here we test whether agentic AI can write computer code to complete three common types of fisheries models. We test an agentic AI system (Roo Code) on its ability to complete three fisheries modelling workflows, from data analysis to report write-up: (1) VB parameter estimation, (2) generalized linear modelling of fish-habitat relationships, (3) spawner per recruit analysis. We use replicate prompts and a rubric to evaluate the AI generated reports. We find that... We show how careful prompting of the AI system can deliver high quality reports for fisheries modelling problems. Our results show that agentic AI systems can already complete complex fisheries workflows, particularly if users provide context-rich prompts. We discuss implications for fisheries science including equity of access to technical expertise and the immediate priority of increasing transparency of AI use in fisheries science, potential pitfalls, and the need for a community of practice around prompting.  

## Plan 

Look at three models:
VB parameter estimation - run them
- need to add bootstrapping
GLM of fish habitat. Done now, re-run for kimi k2
VPA/or SPR

Full YPR: https://haddonm.github.io/URMQMF/simple-population-models.html#simple-yield-per-recruit


## Directory 

Scripts has the test cases (copy to another folder then run agent)
Scripts also has validation cases which Chris wrote as the 'true' answers to each problem. 

## Models

### GLM

Deliberately didn't tell the AI about the confounding, to see if it ever found it. 
