# STATS 501 Project

Each file name is a clickable link to the file location.

## `data`

Contains all the data files:
- [`Economic_Data.csv`](https://github.com/brodyee/STATS501_project/blob/main/data/Economic_Data.csv): Contains the economic data for the counties. Ranging from proverty rate to welfare money per capita.
- [`SADCQ.csv`](https://github.com/brodyee/STATS501_project/blob/main/data/SADCQ.csv): Contains the youth survey answers, race, gender, county, ect. of the survey takers. 
- [`question_breakdown.txt`](https://github.com/brodyee/STATS501_project/blob/main/data/question_breakdown.csv): Categories for the questions in `SADCQ.csv`.
- [`knnImputeVio.csv`](https://github.com/brodyee/STATS501_project/blob/main/data/knnImputeVio.csv), [`meanImputeVio.csv`](https://github.com/brodyee/STATS501_project/blob/main/data/meanImputeVio.csv), [`medianImputeVio.csv`](https://github.com/brodyee/STATS501_project/blob/main/data/medianImputeVio.csv), [`modeImputeVio.csv`](https://github.com/brodyee/STATS501_project/blob/main/data/modeImputeVio.csv): Imputed questions based on county and year. 4 different methods of imputing.
- [`knnImputeVio_WSex.csv`](https://github.com/brodyee/STATS501_project/blob/main/data/knnImputeVio_WSex.csv): Same as above with the Sex column.
- [`params.csv`](https://github.com/brodyee/STATS501_project/blob/main/data/params.csv), [`predictVars.csv`](https://github.com/brodyee/STATS501_project/blob/main/data/predictVars.csv), [`sampleVars.csv`](https://github.com/brodyee/STATS501_project/blob/main/data/sampleVars.csv): Bootstrap output for the split on sex model without higher order terms.
- [`violenceKNN.csv`](https://github.com/brodyee/STATS501_project/blob/main/data/violenceKNN.csv), [`violenceMean.csv`](https://github.com/brodyee/STATS501_project/blob/main/data/violenceMean.csv), [`violenceMedian.csv`](https://github.com/brodyee/STATS501_project/blob/main/data/violenceMedian.csv), [`violenceMode.csv`](https://github.com/brodyee/STATS501_project/blob/main/data/violenceMode.csv): Datasets based off impute.
- [`vioRespKNNSexSplit.csv`](https://github.com/brodyee/STATS501_project/blob/main/data/vioRespKNNSexSplit.csv), [`vioRespMeanSexSplit.csv`](https://github.com/brodyee/STATS501_project/blob/main/data/vioRespMeanSexSplit.csv), [`vioRespMedSexSplit.csv`](https://github.com/brodyee/STATS501_project/blob/main/data/vioRespMedSexSplit.csv), [`vioRespModeSexSplit.csv`](https://github.com/brodyee/STATS501_project/blob/main/data/vioRespModeSexSplit.csv): Violence Score response based off impute.
- [`violenceKNNResp_wSex_NotSplitImp.csv`](https://github.com/brodyee/STATS501_project/blob/main/data/violenceKNNResp_wSex_NotSplitImp.csv): Final data response used. 

## `code`

Contains the R and Python code for project:
- [`DataCleaning&EDA.ipynb`](https://github.com/brodyee/STATS501_project/blob/main/code/DataCleaning&EDA.ipynb): Contains code for dataset up and exploration.
- [`Analysis.ipynb`](https://github.com/brodyee/STATS501_project/blob/main/code/Analysis.ipynb): Contains code for the models selection, cv-mse, and some of the bootstrap. Done in python.
- [`UnsplitModel.ipynb`](https://github.com/brodyee/STATS501_project/blob/main/code/UnsplitModel.ipynb), [`UnsplitModel.r`](https://github.com/brodyee/STATS501_project/blob/main/code/UnsplitModel.r): Contains code for the model not split by sex. Done in R.
- [`SplineModel.ipynb`](https://github.com/brodyee/STATS501_project/blob/main/code/SplineModel.ipynb), [`SplineModel.r`](https://github.com/brodyee/STATS501_project/blob/main/code/SplineModel.r): Contains code for the spline model. Done in R.
- [`bootstrapScript.py`](https://github.com/brodyee/STATS501_project/blob/main/code/bootstrapScript.py): Contains code for the the bootstrap, which was run on Slurm on GreatLakes. Done in python.

## `writeUps`

Contain all presentation and report materials:
- [`STATS501_Proposal.pdf`](https://github.com/brodyee/STATS501_project/blob/main/writeUps/STATS501_Proposal.pdf): Proposal for the project.
- [`STATS501_Proposal_2.pdf`](https://github.com/brodyee/STATS501_project/blob/main/writeUps/STATS501_Proposal_2.pdf): Proposal for the project, after change of plans.
- [`FinalReport501.pdf`](https://github.com/brodyee/STATS501_project/blob/main/writeUps/FinalReport501.pdf): Final write up of our findings. 
