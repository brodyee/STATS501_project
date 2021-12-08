import pandas as pd
import numpy as np
import statsmodels.formula.api as smf
from random import choices

root = "../data/"

features = pd.read_csv(root + "Economic_Data.csv", index_col=0)
features.columns = ["year", "sitename"] + list(features.columns)[2:]
violenceqs = ["q12", "q13", "q15",
              "q16", "q17", "q18"]
bootDat = pd.read_csv(root + "knnImputeVio_WSex.csv")[violenceqs + ["year", 
                                                                    "sitename",
                                                                    "sex"]]
bootDat["sex"] = bootDat["sex"].replace({1 : "Female",
                                         2 : "Male"})
bootDat["sex"] = bootDat["sex"].replace({"Male" : 1,
                                         "Female" : 0})
dropCols = ["Ages 5 to 17 in Families SAIPE Poverty Universe",
            "Ages 5 to 17 in Families in Poverty Count",
            "Ages 5 to 17 in Families in Poverty Percent",
            "All Ages in Poverty Count",
            "All Ages SAIPE Poverty Universe",
            "Under Age 18 SAIPE Poverty Universe",
            "Under Age 18 in Poverty Count"]
features = features.drop(dropCols, axis=1)
features.columns = ['year', 'sitename', 'AllAgesInPovertyPercent', 
                    'UnderAge18inPovertyPercent', 
                    'MedianHouseholdIncomeInDollars',
                    'UnemploymentRate', 'Population', 'SNAP']

def violenceScore(dat):
    n = dat.shape[0]
    dat = dat.loc[:, ~dat.isna().any()]
    score = 0
    satScore = 0
    for col in dat.columns:
        if col == "q12":
            w = 1
            dat[col].replace({5 : 6})
            score += (dat[col] - 1).sum()
            satScore += n * w * 5
        elif col == "q13":
            w = 2
            dat[col].replace({5 : 6})
            score += w * (dat[col] - 1).sum()
            satScore += n * w * 5
        elif col == "q15":
            w = .5
            dat[col].replace({5 : 6})
            score += w * (dat[col] - 1).sum()
            satScore += n * w * 5
        elif col == "q16":
            w = 5
            dat[col].replace({8 : 9})
            score += w * (dat[col] - 1).sum()
            satScore += n * w * 8
        elif col == "q17":
            w = 3
            dat[col].replace({8 : 9})
            score += w * (dat[col] - 1).sum()
            satScore += n * w * 8
        elif col == "q18":
            w = 4
            dat[col].replace({8 : 9})
            score += w * (dat[col] - 1).sum()
            satScore += n * w * 8
        
    return 1000 * (score / satScore)

def CrossValVariance(modelEqu, modelGroup, dat, varsSplitOn=None):
    leftOutCols = [['Borough of Bronx, NY (NYG)', 'Broward County, FL (FT)', 'San Francisco, CA (SF)'],
                   ['Borough of Brooklyn, NY (NYH)', 'Chicago, IL (CH)', 'Los Angeles, CA (LO)'],
                   ['Borough of Manhattan, NY (NYI)', 'Miami-Dade County, FL (MM)', 'San Diego, CA (SA)'],
                   ['Borough of Queens, NY (NYJ)', 'Palm Beach County, FL (PB)', 'Philadelphia, PA (PH)'],
                   ['Borough of Staten Island, NY (NYK)', 'San Diego, CA (SA)', 'Los Angeles, CA (LO)']]

    variance = []
    if varsSplitOn is not None:
        varsSplit = {}
        for group in dat[varsSplitOn].unique():
            varsSplit[group] = []
            
    for lo in leftOutCols:
        md = smf.mixedlm(modelEqu, 
                         dat[~dat[modelGroup].isin(lo)],
                         groups=dat[~dat[modelGroup].isin(lo)][modelGroup])
        mdf = md.fit(reml=False)
        if varsSplitOn is None:
            pred = mdf.predict(dat[dat[modelGroup].isin(lo)])
            variance.append(pred)
        else:
            for group in dat[varsSplitOn].unique():
                pred = mdf.predict(dat[(dat[modelGroup].isin(lo))
                                       & (dat[varsSplitOn] == group)])
                varsSplit[group].append(pred)
    if varsSplitOn is not None:
        return pd.DataFrame(varsSplit).var()
    return np.var(variance)

def randomSampleStatistic(dat, size, statFunc):
    randomIdx = choices(range(dat.shape[0]),
                        k=size)
    stat = statFunc(dat.iloc[randomIdx, :])
    return stat

def bootstrap(dat, params, numSamples, statFunc, equ):
    
    for i in range(numSamples):
        print("Starting ", i, "sample")
        
        bsSample = (dat.groupby(["year", "sitename", "sex"])
                       .apply(lambda x : 
                                 randomSampleStatistic(x.drop(["year", "sitename", "sex"],
                                                              axis=1),
                                                       2000,
                                                       violenceScore))
                        .reset_index())
        
        modDat = (bsSample.merge(params,
                                 how="inner",
                                 on=["year", "sitename"])
                          .rename(columns={0 : "violenceScore"}))
        cvVar = CrossValVariance(equ, "sitename", modDat, varsSplitOn="sex")
        
        if i == 0:
            sampleStats = pd.DataFrame(bsSample.groupby(["year", "sex"])
                                               .apply(lambda x : statFunc(x[0])),
                                       columns=[0])
            crossValValsStat = cvVar
        else:
            sampleStats[i] = (bsSample.groupby(["year", "sex"])
                                      .apply(lambda x : statFunc(x[0])))
            crossValValsStat = crossValValsStat.append(cvVar)
        
        if ((i + 1) % 1000) == 0:
            sampleStats.to_csv(root + "sampleVarsCV.csv")
            crossValValsStat.to_csv(root + "OS_CV_Vars.csv")
            
    return sampleStats, crossValValsStat


sampleVarsCV, predictVar = bootstrap(bootDat,
                                     features,
                                     2, np.var,
                                     "violenceScore ~ sex*UnemploymentRate + sex*SNAP")

sampleVarsCV.to_csv(root + "sampleVarsCV.csv")
predictVar.to_csv(root + "OS_CV_Vars.csv")
