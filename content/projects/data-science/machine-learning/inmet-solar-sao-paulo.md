+++
title = 'Multi-ensemble based approach for Short-term Solar Radiation Forecasting'
description = "A"
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

## Data

### Data Source

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
            <td>$B$ - Barometric pressure</td>
            <td>hPa</td>
        </tr>
        <tr>
            <td>$D$ - Dew point</td>
            <td>°C</td>
        </tr>
        <tr>
            <td>$H$ - Humidity</td>
            <td>%</td>
        </tr>
        <tr>
            <td>$P$ - Precipitatoin</td>
            <td>mm</td>
        </tr>
        <tr>
            <td>$T$ - Temperature</td>
            <td>°C</td>
        </tr>
        <tr>
            <td>$R$ - Global solar radiation</td>
            <td>kJ/m²</td>
        </tr>
        <tr>
            <td>$W_s$ - Wind speed</td>
            <td>m/s</td>
        </tr>
        <tr>
            <td>$W_d$ - Wind direction</td>
            <td>°</td>
        </tr>
    </table>
    <img src="https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/sp-map.png" width=530px style="margin-left: 10px;">
</div>

{{< callout type="info" >}}
Although the data provide by INMET was quite noisy in the hourly granularity, other applications depending on greater data granularities may benefit from the data provided by INMET as the network of data collecting stations is rather extense and well distributed across the country.

For more information access the [Meteorological Station Map Explorer](https://mapas.inmet.gov.br/).
{{< /callout >}}

### Preprocessing

Despite the availability, several issues had to be circumvented during data cleaning. Some of them worth mentioning are listed below:

- **Missing values**: several meteorological station had major gaps due to availability problems. In some cases, all records from the station had to be discarted as the data would only introduce noise to the models during training. Despite not being documented, most of these issues with missing data must have originated from physical malfunction and/or damage in meteorological stations which remained unattended for several months.

- **Changes recording formatting**: changes in formatting, introduced by migration of services or maybe restandardization of storage utilities, were also experienced. Examples of these changes include the way `NULL` values were registered and date-time formatting changes.

- **Change in stations' geographical coordinates** which affected distance relations. This issue had to be solved by manually searching the most recent coordinates for each station and retroactively overwriting them in historical records.

Some of the preprocessing operations carried out in the dataset to prepare this dataset envolved:

- **PCA transforming** $B$, $D$, $H$ and $T$ down to one component. These particular features had 3 measures associated to them each hour: the maximum and minimum value within the hour as well as the instant measurement.
- **Removing observations with spurious values**, for example negative solar radiation or precipitation, temperatures inferior to 10°C as these are extremely rare in the area of study, solar radiation greater than 8000 kJ/m², etc.
- **Applying a data imputation technique** as an attempt to reconstruct at least part of the data lost due to data quality problems (see section [Data Imputation](#data-imputation)).
- **Filtered the stations based on number of observations** as only stations with relevant amount of years of observation were necessary to build the train and test sets. For this filtering, only stations with 7 years worth of valid observations were considered.
- **Reformatting datetime columns** in order standardize the observations and properly adjust the daylight saving time across the years (some of the years in records had an extra daylight saving hour which had to be accounted for; others didn't, which caused inconsistencies).
- **Adjusting of target variable**, which envolved first filtering the observations to select only a fixed window for the observations, *i.e.* only hourly observations between 7:00 and 18:00 (local time) were selected. 
- **Data normalization** using the [Robust Scaler](https://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.RobustScaler.html).
- **Applying temporal holdout split** to obtain the train and test sets. Out of the Jan/2001 to Jun/2021 period available when this project was developed, 2001-2018 (inclusve) was selected for training and the remaining data (2019-2021) for testing. After the split, the observations in both train and test sets were shuffled.


### Data Imputation

Given the amount of information lost in missing values, an imputation technique was introduced attempting to artificially reconstruct at least part of the missing data and improve training. As these phenomena are highly dependent on the geographical relation between data colecting points, specially the distance between the stations, the choice was to employ the [Inverse Distance Weighting](https://en.wikipedia.org/wiki/Inverse_distance_weighting) (IDW) for each of the features. The idea behind this is that closer reference values should have a greater influence in the interpolated value that reference points further apart.

The following pseudo-algorithm explains how the IDW imputation was carried out. When a station `s0` is undergoing IDW imputation we first select a set of `nearby_stations` based on the [Haversine Distance](https://en.wikipedia.org/wiki/Haversine_formula) between `s0` and `all_avaliable_stations`; then for every invalid value of `feature` at a timestamp `t` in `s0`, we look for valid values of `feature` on the same timestamp `t` across all selected `nearby_stations`. When the number valid observations in `nearby_stations` exceeds `min_required_stations_for_imputation`, `feature` is interpolated via IDW using the Haversine Distance as weight.

``` {filename="Inverse Distance Weighting as a mathod for data imputation"}
nearby_stations ← ∅

for s ∈ all_available_stations - s do
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

{{< callout type="info" >}}
For this project this process was conducted adopting a minimum of 3 valid values to interpolate, selecting nearby stations within a maximum distance of 120km.
{{< /callout >}}

The figure bellow depicts the same process. In this case, $A_{fn}^{(ts_i)}$ is undergoing IDW imputation using the nearby stations $B$, $C$ and $D$. As only the values in $B$ and $C$ for $f_n$ are available at $ts_i$, they will be the ones used to fill the missing $f_n$ value at $A^{(ts_i)}$.

![](https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/imputation.png)

## Modelling Strategy

The proposed ML-based forecasting system is composed of two stacked procedures described below. In each one of these procedures Supervised Leaning techniques have been applied in order to prepare the data and obtain models capable of estimating the solar radiation.

{{% steps %}}

### Site-specific Models

![](https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/overview_p1_borderless.png "Procedure 1: site-specific training schematic view. ")

The first step was to obtain site-specific models trained and tuned with historical meteorological data collected in each one of the collection sites of the area of study. The models and predictions in this procedure are said to be "site-specific" in the sense that, in this stage, no data is shared across stations; all training and tuning carried out in station `s0` is performed only with data from `s0`. This is only possible bacause all stations follow the same standards when recording meteorological data. The dataset use to train the models to predict $\hat{R}_{ts + 1}$, the ratiation for the next hour, followed the given format:

$$ (ts, B, D, H, P, T, R, W_s, W_d) \rightarrow \hat{R}_{ts + 1} $$

The Machine Learning algorithms used to train the site-specific models are shown below. For each one of the training algorithms hyperparameters search routines also were conducted and the fitted models were all combined into a [Stacking Regressor](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.StackingRegressor.html). At the end of this step we expect to produce one ensemble of trained models per training site.

- [Multi-layer Perceptron](https://scikit-learn.org/stable/modules/generated/sklearn.neural_network.MLPRegressor.html) (Dense Neural Network - NN)
- [Support Vector Machine](https://scikit-learn.org/stable/modules/generated/sklearn.svm.SVR.html) (SVM)
- [Extremely Randomized Trees](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.ExtraTreesRegressor.html) (Extra Trees - ET)
- [Extreme Gradient Boosting](https://xgboost.readthedocs.io/en/latest/python/python_api.html?highlight=xgbregressor#xgboost.XGBRegressor) (XGB)
- [Random Forests](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.RandomForestRegressor.html) (RF)

{{< callout type="info" >}}
During this stage two branches of execution for training and tuning routines were followed for each station: 1) using original data and 2) using imputed data. After the training and tuning of all models using the two distinct datasets, the best model was selected based on the RMSE.
{{< /callout >}}

### Generalization Model

![](https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/overview_p2_borderless.png "Procedure 2: generalization dataset construction and training scheme.")

In order to generalize the predictions we need to train and tune a single generalization model using as input the predictions of the site-specific models trained in the previous procedure. For this step a new dataset is constructed from the site-specific predictions with the addition of other data to train the generalization model. This new dataset was constructed incorporating for each station the 3-tuple $(d^n, E^n, \hat{R}_{ts_i + 1}^{n})$ in which:
- $d^n$ is the Haversine Distance from the generalized station to its $n$-th closest station.
- $E^n$ is the average between the RMSE and MAE of the estimator in the $n$-th closest station.
- $\hat{R}_{ts_i + 1}^{n}$ is the estimated value of $R$ at timestamp $ts$ produced by the $n$-th closest station.

**The ideia behind it is that the generalization model should be able to learn the relations envolving distance and "trustworthiness" (measured by the error $E$) of the closest nearby site-specific models when combining their predictions** to produce a generalized prediction. The dataset used to train the generalization model followed the given format ($La_i$ is the latitude and $Lo_i$ of the generalized prediction site):

$$
\bigg(ts_i, La_i, Lo_i,
\overbrace{d^1, E^1, \hat{R}^1}^{\text{station } 1}, \cdots,
\overbrace{d^n, E^n, \hat{R}^n}^{\text{station } n} \bigg)
\rightarrow {\psi_{ts + 1}} 
$$

To prevent noise in this new dataset, the minimum required number of tuples $(d^n, E^n, \hat{R}_{ts_i + 1}^{n})$ was set to 3. Since this dataset was set to accomomdate up to 7 3-tuples, when the number of available 3-tuples was smaller than 7, the remainig "slots" were filled with zeros.

{{< callout type="info" >}}
Note that the filter selecting only stations with 7 years of valid retroactive observations (mentioned in section [Preprocessing](#preprocessing)) was by-passed in this step as, despite not having available observations for the first procedure training, the observed values were still relevant when training and assessing the generalization model.
{{< /callout >}}

{{% /steps %}}

### Final Prediction Scheme

Putting everything together, the following picture ilustrates the whole process of generating a solar radiation prediction. For site-specific predictions, only the inferior portion of the figure can be considered.

![](https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/prediction_summary.png)

## Baselines

As a way to assess the models and have some comparative basis two baselines were used in this project. They are described in details in the followind sections.

### Empirical Model

The empirical model used in this project corresponds to the CPRG model, an hourly solar radation model based on decomposition which relates variables such as latitude, longitude, day of year and hour with the solar radiation intensity. The implementation can be found in [project repository](https://github.com/lfenzo/ml-solar-sao-paulo/blob/master/src/empirical_vs_ml/empirical_model.py), for further details check out [this article](https://dergipark.org.tr/en/pub/estubtda/issue/54537/650497).

### IDW-based interpolation

This method is very similar to the [Data Imputation](#data-imputation) technique used for the input data in the first procedure, however, instead of using IDW to interpolate values of missing features, we are interpolating predictions generated by the site-specific models. As in the generalization model, this baseline model also incorporates the measure of "trustworthiness" of site-specific models by adding to the waights the error from the estimators. As a reference, the following equation shows the calculation of a weight ($e_{s_i}$ is the best estimator for the site $s_i$; $s_0$ is the site for which the predictions are generated and $d$ is the Haversine Distance).

$$
w_i(s_0,s_i) = \dfrac{1}{d(s_0, s_1)^2} \bigg( \dfrac{\text{RMSE}(e_{s_i}) + \text{MAE}(e_{s_i})}{2} \bigg)^{-1}
$$

Once the weights are defined, the calculation bacomes a simple weighted sum:

$$
\psi_{ts+1} = \dfrac{\displaystyle \sum_{i=1}^k \bigg[ \overbrace{e_{s_i}(x_{s_i})}^{\hat{R}^i} \cdot w_i(s_0, s_i) \bigg]}{\displaystyle \sum_{i=1}^k w_i(s_0, s_i)}
$$

{{< callout type="info" >}}
Note that this method was only used as a baseline for the generalization model.
{{< /callout >}}

## Results

Given the configuration in the modelling strategy, the site-specific models and the generalization model were assessed sepately. Performance was measured using the [Root Mean Squared Error](https://en.wikipedia.org/wiki/Root-mean-square_deviation) (RMSE), [Mean Absolute Error](https://en.wikipedia.org/wiki/Mean_absolute_error) (MAE), the R^2 and the Mean Bias Error (MBE). The values in the tables in upcoming sub-sections correspond to the mean ($\bar{x}$) and standard deviation of metrics values in each meteorological station.

### Site-specific Models

<table border="1">
    <tr>
        <th rowspan="2" colspan="2">Metric</th>
        <th colspan="2">Method</th>
        <th rowspan="2"> $\underset{\text{EMP} - \text{ML}}{\Delta\%}$</th>
    </tr>
    <tr>
        <th>CPRG (baseline)</th>
        <th>ML</th>
    </tr>
    <tr>
        <td rowspan="2">RMSE</td>
        <td>$\bar{x}$</td>
        <td align="right">551.68</td>
        <td align="right">363.05</td>
        <td align="right">-34.19</td>
    </tr>
    <tr>
        <td>$\sigma$</td>
        <td align="right">136.97</td>
        <td align="right">43.09</td>
        <td align="right">-68.53</td>
    </tr>
    <tr>
        <td rowspan="2">MAE</td>
        <td>$\bar{x}$</td>
        <td align="right">462.23</td>
        <td align="right">232.34</td>
        <td align="right">-49.73</td>
    </tr>
    <tr>
        <td>$\sigma$</td>
        <td align="right">126.98</td>
        <td align="right">27.42</td>
        <td align="right">-78.40</td>
    </tr>
    <tr>
        <td rowspan="2">MBE</td>
        <td>$\bar{x}$</td>
        <td align="right">184.83</td>
        <td align="right">2.25</td>
        <td align="right">-98.78</td>
    </tr>
    <tr>
        <td>$\sigma$</td>
        <td align="right">36.26</td>
        <td align="right">21.31</td>
        <td align="right">-41.23</td>
    </tr>
    <tr>
        <td rowspan="2">R2</td>
        <td>$\bar{x}$</td>
        <td align="right">0.7284</td>
        <td align="right">0.8806</td>
        <td align="right">20.89</td>
    </tr>
    <tr>
        <td>$\sigma$</td>
        <td align="right">0.1370</td>
        <td align="right">0.0287</td>
        <td align="right">-79.04</td>
    </tr>
</table>

### Generalization Model

<table border="1">
    <tr>
        <th rowspan="2" colspan="2">Metric</th>
        <th colspan="3">Method</th>
        <th rowspan="2"> $\underset{\text{EMP} - \text{ML}}{\Delta\%}$</th>
        <th rowspan="2"> $\underset{\text{IDW} - \text{ML}}{\Delta\%}$</th>
    </tr>
    <tr>
        <th>CPRG (baseline)</th>
        <th>IDW (baseline)</th>
        <th>ML</th>
    </tr>
    <tr>
        <td rowspan="2">RMSE</td>
        <td>$\bar{x}$</td>
        <td align="right">535.66</td>
        <td align="right">507.73</td>
        <td align="right">392.33</td>
        <td align="right">26.74</td>
        <td align="right">22.73</td>
    </tr>
    <tr>
        <td>$\sigma$</td>
        <td align="right">128.78</td>
        <td align="right">99.86</td>
        <td align="right">58.72</td>
        <td align="right">51.38</td>
        <td align="right">41.19</td>
    </tr>
    <tr>
        <td rowspan="2">MAE</td>
        <td>$\bar{x}$</td>
        <td align="right">445.94</td>
        <td align="right">362.10</td>
        <td align="right">270.69</td>
        <td align="right">39.30</td>
        <td align="right">25.24</td>
    </tr>
    <tr>
        <td>$\sigma$</td>
        <td align="right">116.51</td>
        <td align="right">72.15</td>
        <td align="right">28.69</td>
        <td align="right">74.51</td>
        <td align="right">58.85</td>
    </tr>
    <tr>
        <td rowspan="2">MBE</td>
        <td>$\bar{x}$</td>
        <td align="right">183.81</td>
        <td align="right">0.52</td>
        <td align="right">25.25</td>
        <td align="right">86.97</td>
        <td align="right">-4755.76</td>
    </tr>
    <tr>
        <td>$\sigma$</td>
        <td align="right">36.89</td>
        <td align="right">172.55</td>
        <td align="right">29.76</td>
        <td align="right">19.32</td>
        <td align="right">82.75</td>
    </tr>
    <tr>
        <td rowspan="2">R2</td>
        <td>$\bar{x}$</td>
        <td align="right">0.7392</td>
        <td align="right">0.7581</td>
        <td align="right">0.8625</td>
        <td align="right">-16.68</td>
        <td align="right">-13.77</td>
    </tr>
    <tr>
        <td>$\sigma$</td>
        <td align="right">0.1344</td>
        <td align="right">0.1262</td>
        <td align="right">0.0361</td>
        <td align="right">-73.14</td>
        <td align="right">-71.39</td>
    </tr>
</table>

## Conclusion

## References

aa

![](https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/residuals_example.png)

![](https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/sp_rain.png)

![](https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/errors_by_site.png)

![](https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/src/visuals/perf_scatter/perf_scatter.png)













