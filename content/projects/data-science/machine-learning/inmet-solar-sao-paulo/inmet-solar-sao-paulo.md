+++
title = 'Multi-ensemble based approach for Short-term Solar Radiation Forecasting'
date = 2024-03-28T17:29:05-03:00
type = 'blog'
tags = ['machine-learning', 'solar-energy']
math = true
+++

## Introduction

This project consists of the development and implemetation of a modeling approach for solar radiation forecasting (although mostly as a "regression as forecasting") from historical meteorological records using Machine Learning (ML) techniques. During the 12-month funding period, provided by [FAPESP](https://fapesp.br/) as a "Scientific Initiation" project, several activities such as literature review, data processing, model training and data analyses have been carried out resulting in a full ML pipeline. The data used in this project was collected by [INMET](https://portal.inmet.gov.br/), the National Meterology Institute in Brazil, consists of records of meteorological variables from which the models should learn; some of the treatments applied to the data, as well as other modeling decisions, are explained in futher details in following sections. 

This project was originally inspired by =THIS PAPER= which showcases a similar approach for solar radiation prediction in Australia, where energy trading markets would benefit from intelligent systems capable of forecasting energy offer from photovoltaic solar predictions. Unfortunatelly, such markets are not available in Brazil as most of the electric energy comes from hydroelectric dams.

{{< cards >}}
  {{< card link="https://github.com/lfenzo/Impostor.jl" icon="github" title="Implementation" >}}
  {{< card link="https://bv.fapesp.br/pt/bolsas/193480/previsao-de-irradiacao-solar-para-sistemas-fotovoltaicos-utilizando-machine-learning-uma-abordagem/" icon="link" title="Funding Agency link" >}}
  {{< card link="https://github.com/lfenzo/ml-solar-sao-paulo/blob/8fc0a0e3f9e1c349a054ac95076ecf5930daf1ce/doc/paper.pdf" icon="book-open" title="Paper" >}}
{{< /cards >}}


## Objective

The main objective of this project was to use Machine Learning techniques to train models in order to predict solar radiation intensity, which can in turn be used to estimate the electric energy yeld from solar panel module. The following sections 

## Approach

### Dataset

To achive the goal stablished in the section above, the dataset had to posses a set of certain characteristics such as 1) contain the solar radiation variable, 2) hourly (or finer) record granularity and 3) contain measures of meteorological variables in multiple locations.

When this project was developed the only data source available with such attributes was provided by the Brazillian National Institute of Meteorology (INMET) through its [website](https://portal.inmet.gov.br/). The data, provided free of charge, is collected through several meteorological stations across the country on an hourly basis and transmitted to INMET for processing and storage. In order to limit the scope, only stations from the State of São Paulo, totallying 56 data collection sites, were seleted with **records ranging from January 2001 to July 2021**. The meteorological variables collected as well as the location of each meteorological station are shown below.

<br>

<div style="display: flex; flex-direction: row; align-items: center;">
    <table>
        <tr>
            <th>Meteorologic variable</th>
            <th>Unit</th>
        </tr>
        <tr>
            <td>Barometric pressure</td>
            <td>hPa</td>
        </tr>
        <tr>
            <td>Dew point</td>
            <td>°C</td>
        </tr>
        <tr>
            <td>Humidity</td>
            <td>%</td>
        </tr>
        <tr>
            <td>Precipitatoin</td>
            <td>mm</td>
        </tr>
        <tr>
            <td>Temperature</td>
            <td>°C</td>
        </tr>
        <tr>
            <td>Global solar radiation</td>
            <td>kJ/m²</td>
        </tr>
        <tr>
            <td>Wind speed</td>
            <td>m/s</td>
        </tr>
        <tr>
            <td>Wind direction</td>
            <td>°</td>
        </tr>
    </table>
    <img src="https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/sp-map.png" alt="Description of image" width=570px style="margin-left: 10px;">
</div>

Despite the availability, several issues had to be circumvented during data preparation. Some of them worth mentioning are listed below:

- **Missing values**: several meteorological station had major gaps due to availability problems. In some cases, all records from the station had to be discarted as the data would only introduce noise to the models during training. Despite being not documented, most of these issues with missing data must have originated from phisical malfunction and/or damage in meteorological stations which remained unattended for several months.

- **Changes recording formatting**: changes in formatting, introduced by migration of services or maybe restandardization of storage utilities, were also experienced. Examples of these changes include the way `NULL` values were registered and date-time formatting changes.

- **Change in stations' geographical coordinates** 

{{< callout type="info" >}}
Although the data provide by INMET was quite noisy in the hourly granularity, other applications depending on greater data granularities may benefit from the data provided by INMET as the network of data collecting stations is rather extense and well distributed across the country.

For more information access the [Meteorological Station Map Explorer](https://mapas.inmet.gov.br/).
{{< /callout >}}

### Data Imputation

Given the amount of information lost in missing values, an imputation technique was introduced attempting to artificially reconstruct at least part of the missing data and improve training. As these phenomena are highly dependent on the geographical relation between data colecting points, specially the distance between the stations, the choice was to employ the [*Inverse Distance Weighting*](https://en.wikipedia.org/wiki/Inverse_distance_weighting) (IDW) for each of the features.

The following pseudo-algorithm explains how the IDW imputation was carried out. When a station `s0` is undergoing IDW imputation we first select a set of `nearby_stations` based on the [Haversine Distance](https://en.wikipedia.org/wiki/Haversine_formula) between `s0` and `all_avaliable_stations`; then for every invalid value of `feature` at a timestamp `t` in `s0`, we look for valid values of `feature` on the same timestamp `t` across all selected `nearby_stations`. When the number valid observations in `nearby_stations` exceeds `min_required_stations_for_imputation`, `feature` is interpolated via IDW using the Haversine Distance as weight.

``` {filename="Inverse Distance Weighting as a mathod for data imputation"}
nearby_stations ← ∅
for s ∈ all_available_stations do
    if distance(s, s0) ⩽ maximum_imputting_distance then
        nearby_station ∪ {s}
    end
end
if |nearby_stations| ⩾ min_required_stations_for_imputation then
    for t ∈ {min(s0.timestamp), ···, max(s0.timestamp)} do
        if s0.feature at t is NULL then
            s0.feature at t ← interpolate(s0, nearby_stations, feature)
        end
    end
end
```

The figure bellow depicts the same process. In this case, $A_{fn}^{(ts_i)}$ is undergoing IDW imputation using the nearby stations $B$, $C$ and $D$. As only the values in $B$ and $C$ for $f_n$ are available at $ts_i$, they will be the ones used to fill the missing $f_n$ value at $A^{(ts_i)}$.

![](https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/imputation.png)

{{< callout type="info" >}}
For this project this process was conducted adopting a minimum of 3 valid values to interpolate, selecting nearby stations within a maximum distance of 120km.
{{< /callout >}}

### Modelling Strategy



### Final Prediction Scheme

![](https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/prediction_summary.png)

### Baseline

## Results

## Conclusion

## References










This repository contains the implementation of the scientific project *Multi-ensemble Machine Learning based approach for Short-term Solar Radiation Forecasting*.

The objective of this project was to employ Machine Leaning techniques in order to obtain models capable of forecasting solar radiation 60 minutes in the future from meteorological records such as temperature, humidity, precipitation, etc, obtained in meteorological stations in the State of São Paulo, Brazil. The top-left image below depicts the data collection sites in the area of study.

<table>
    <tr>
        <td><img src = "https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/sp-map.png"></td>
        <td><img src = "https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/residuals_example.png"></td>
    </tr>
    <tr>
        <td><img src = "https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/sp_rain.png"></td>
        <td><img src = "https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/errors_by_site.png"></td>
    </tr>
</table>

The proposed objective was divided in 2 procedures:

- Obtain site-specific models trained and tuned with historical meteorological data collected in each one of the collection sites in the area of study. Predictions are site-specific to each collection sites.

- Obtain a single generalization model trained and tuned with the predictions of the site-specific models in the previous procedure. Predictions correspond to generalizations in the geographical space of predictions generated by models obtained in the first procedure. For this procedure a new dataset would have to be constructed from the local predictions in order to train the generalization model

![](https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/overview_p1.png "title-1") ![](https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/overview_p2.png "title-2")

In order to assess the predictions produced by the generalization model a variation of Inverse Distance Weighting was introduced taking into account not only the distance from the reference prediction sites the predicted site but also the errors of the estimators which produced the predictions to be interpolated. The predictions of both site-specific models and the generalization model were also compared to the CPRG hourly radiation prediction empirical model in terms of performance of the predictions.

 Approach

The data collected are preprocessed on a per station configuration. Among the employed procedures this preprocessing pipeline features the automated download of all data used during training of the models and an imputation method to artificially reconstruct part of the missing data in the obtained datasets.

The data pipeline is composed of the following procedures:

1. Automated data Download and Extraction, performed by [`data/file_downloader.py`](https://github.com/lfenzo/ml-solar-sao-paulo/blob/master/src/data/file_downloader.py)
1. Selection of the files relative to the area of study, performed by [`data/file_filter.py`](https://github.com/lfenzo/ml-solar-sao-paulo/blob/master/src/data/file_filter.py)
1. Concatenation header information processing of the selected files, performed by [`data/file_concatenator.py`](https://github.com/lfenzo/ml-solar-sao-paulo/blob/master/src/data/file_concatenator.py)
1. Filtering, cleaning and standardization of the data for every data collection site, performed by [`data/preprocessing.py`](https://github.com/lfenzo/ml-solar-sao-paulo/blob/master/src/data/preprocessing.py)

The executions of the script mentioned above are scheduled by the script [`data_pipeline.py`](https://github.com/lfenzo/ml-solar-sao-paulo/blob/master/src/data/data_pipeline.py) which stores the resulting set of datasets in the appropriate directory inside `mixer/` considering the presence or absence of the `idw` execution flag.

All the script mentioned above accept arguments from the command-line, for further information use:

```
python <script.py> --help
```

 Data Imputation

The imputation was performed for every feature in every station using Inverse Distance Weighting. For an imputed station A, a set of nearby stations (B, C and D) is obtained and for every timestamp in A available values in B, C and D are interpolated in order to artificially reconstruct the missing values of A.

![](https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/imputation.png)

This process was conducted adopting a minimum of 3 valid values to interpolate, selecting nearby stations within a maximum distance of 120Km.

 Model Training and Tuning

The Machine Learning algorithms used to train the estimators are shown below. For each one of the training algorithms hyperparameters search routines were conducted in order to obtain the best models from the selected hyperparameter search space in each algorithm.

1. [Multi-layer Perceptron (Dense Neural Network)](https://scikit-learn.org/stable/modules/generated/sklearn.neural_network.MLPRegressor.html)
1. [Support Vector Machine ](https://scikit-learn.org/stable/modules/generated/sklearn.svm.SVR.html)
1. [Extremely Randomized Trees (Extra Trees)](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.ExtraTreesRegressor.html)
1. [Extreme Gradient Boosting](https://xgboost.readthedocs.io/en/latest/python/python_api.html?highlight=xgbregressor#xgboost.XGBRegressor)
1. [Random Forests](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.RandomForestRegressor.html)
1. [Stacking Regressor](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.StackingRegressor.html)

The training pipeline was designed to be fully automated and fault-tolerant: in case of the interruption of the training process by any reason, the next run of the script [`training_pipeline.py`](https://github.com/lfenzo/ml-solar-sao-paulo/blob/master/src/training_pipeline.py) is able to detect the last fitted estimator and restart the training process where is was stopped.
Once all the training and tuning processes are complete, the generalized prediction in a given site is schematically depicted below:


In the above image, 𝜓(*ts* + 1) corresponds to the generalized prediction in relation to a timestamp *ts*. The two equations shown in the picture correspond to two input format for the generalization model and the site-specific models.

 Implementation

The content of this repository in `src/` is organized as follows

