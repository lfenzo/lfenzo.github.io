+++
title = 'Multi-ensemble based approach for Short-term Solar Radiation Forecasting'
description = "This project focuses on developing a machine learning-based approach for solar radiation forecasting using historical meteorological data from INMET, Brazil's National Meteorology Institute. Implemented in Python, the project involves data processing, model training, and analysis, resulting in a full ML pipeline to predict solar radiation intensity. The goal was to estimate energy yield from solar panels, with data imputation and a stacked modeling strategy improving prediction accuracy."
date = 2024-03-28T17:29:05-03:00
type = 'docs'
tags = ['machine-learning', 'solar-energy']
math = true
+++

## Introduction

This project consists of the development and implemetation of a modeling approach for solar radiation forecasting (although mostly as a "regression as forecasting") from historical meteorological records using Machine Learning (ML) techniques. During the 12-month funding period, provided by [FAPESP](https://fapesp.br/) as a "Scientific Initiation" project, several activities such as literature review, data processing, model training and data analyses have been carried out resulting in a full ML pipeline. The data used in this project was collected by [INMET](https://portal.inmet.gov.br/), the National Meterology Institute in Brazil, consists of records of meteorological variables from which the models should learn; some of the treatments applied to the data, as well as other modeling decisions, are explained in futher details in following sections. 

This project was originally inspired by [this paper](https://www.sciencedirect.com/science/article/abs/pii/S0960148115305747?via%3Dihub) which showcases a similar approach for solar radiation prediction in Australia, where energy trading markets would benefit from intelligent systems capable of forecasting energy offer from photovoltaic solar predictions. Unfortunatelly, such markets are not available in Brazil as most of the electric energy comes from hydroelectric dams.

The implementation for this project was done in Python3 with common Data Science libraries such as [Pandas](https://pandas.pydata.org/), [Scikit-Learn](https://scikit-learn.org/stable/), [Matplotlib](https://matplotlib.org/), [Numpy](https://numpy.org/), [GeoPandas](https://geopandas.org/en/stable/) and others.

{{< cards >}}
  {{< card link="https://github.com/lfenzo/ml-solar-sao-paulo" icon="github" title="Implementation" >}}
  {{< card link="https://bv.fapesp.br/pt/bolsas/193480/previsao-de-irradiacao-solar-para-sistemas-fotovoltaicos-utilizando-machine-learning-uma-abordagem/" icon="link" title="Funding Agency link" >}}
  {{< card link="https://github.com/lfenzo/ml-solar-sao-paulo/blob/8fc0a0e3f9e1c349a054ac95076ecf5930daf1ce/doc/paper.pdf" icon="book-open" title="Paper" >}}
{{< /cards >}}

## Objective

The main objective of this project was to **use Machine Learning techniques to predict solar radiation intensity**, which can in turn be used to estimate the electric energy yeld from solar panel module. As this project was developed other sub-objectives were also divised to address this objective such as obtainig a data source, preprocessing the data and other operations related to training and testing of the methods. The sections to come highlight the work conducted in this project.

## Data

### Data Source

To achive the goal stablished in the section above, the dataset needed set of certain characteristics such as 1) contain the solar radiation variable, 2) hourly (or finer) record granularity and 3) contain measures of meteorological variables in multiple locations.

When this project was developed the only data source available with such attributes was provided by the Brazillian National Institute of Meteorology (INMET) through its [website](https://portal.inmet.gov.br/). The data, provided free of charge, is collected through several meteorological stations across the country on an hourly basis and transmitted to INMET for processing and storage. In order to limit the scope, only stations from the State of São Paulo, totallying 56 data collection sites, were seleted with **records ranging from January 2001 to July 2021**. The meteorological variables collected as well as the location of each meteorological station are shown below.

<br>

<style>
.container {
    display: flex;
    flex-wrap: wrap;
    justify-content: space-between;
}

.image {
    flex: 2; /* Adjust this value to control the width of the image relative to the table */
    padding: 5px; /* Adjust spacing between the image and the table */
}

.table {
    flex: 1;
}

@media (max-width: 500) {
    .container {
        flex-direction: column;
    }
    .image, .table {
        width: 100%;
        margin-right: 0;
    }
}
</style>

<div class="container">
    <table class="table">
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
    <figure class="image">
        <img src="https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/sp-map.png">
        <figcaption>Geographical location of meteorological stations in the State of São Paulo.</figcaption>
    </figure>
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

- **PCA transforming** $B$, $D$, $H$ and $T$ down to one component. These particular features had 3 measures associated to them in each hour: the maximum and minimum value within the hour as well as the instant measurement.
- **Removing observations with spurious values**, for example negative solar radiation or precipitation, temperatures inferior to 10°C as these are extremely rare in the area of study, solar radiation greater than 8000 kJ/m², etc.
- **Applying a data imputation technique** as an attempt to reconstruct at least part of the data lost due to data quality problems (see section [Data Imputation](#data-imputation)).
- **Filtering the stations based on number of observations** as only stations with relevant amount of years of observation were necessary to build the train and test sets. For this filtering, only stations with 7 years worth of valid observations were considered.
- **Reformatting datetime columns** in order standardize the observations and properly adjust the daylight saving time across the years (some of the years in records had an extra daylight saving hour which had to be accounted for; others didn't, which caused inconsistencies).
- **Adjusting of target variable**, which envolved first filtering the observations to select only a fixed window for the observations, *i.e.* only hourly observations between 7:00 and 18:00 (local time) were selected. After the operations of normalizing daylight saving time and selecting the proper time window, the solar radiation could safely be shifted in one hour ahead to get the associated value for the next hour.
- **Data normalization** using the [Robust Scaler](https://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.RobustScaler.html).
- **Applying temporal holdout split** to obtain the train and test sets. Out of the Jan/2001 to Jun/2021 period available when this project was developed, 2001-2018 (inclusve) was selected for training and the remaining data (2019-2021) for testing. After the split, the observations in the training set were shuffled.


### Data Imputation

Given the amount of information lost in missing values, an imputation technique was introduced attempting to artificially reconstruct at least part of the missing data and improve training. As these phenomena are highly dependent on the geographical relation between data colecting points, specially the distance between the stations, the choice was to employ the [Inverse Distance Weighting](https://en.wikipedia.org/wiki/Inverse_distance_weighting) (IDW) for each of the features. The idea behind this is that **closer reference values should have a greater influence in the interpolated value that reference points further apart**.

The following pseudo-algorithm explains how the IDW imputation was carried out. When a station `s0` is undergoing IDW imputation we first select a set of `nearby_stations` based on the [Haversine Distance](https://en.wikipedia.org/wiki/Haversine_formula) between `s0` and `all_avaliable_stations`; then for every invalid value of `feature` at a timestamp `t` in `s0`, we look for valid values of `feature` on the same timestamp `t` across all selected `nearby_stations`. When the number valid observations in `nearby_stations` exceeds `min_required_stations_for_imputation`, `feature` is interpolated via IDW using the Haversine Distance as weight.

``` {filename="Inverse Distance Weighting as a mathod for data imputation"}
nearby_stations ← ∅

for s ∈ all_available_stations - s do
    if distance(s, s0) ⩽ maximum_imputation_distance then
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
For this project this process was conducted adopting a minimum of 3 valid values to interpolate, selecting nearby stations within a maximum distance of 120km. In other words:
- `maximum_imputation_distance = 120`
- `min_required_stations_for_imputation = 3`
{{< /callout >}}

The figure bellow presents a graphical representation of the same process. In this case, $A_{fn}^{(ts_i)}$ is undergoing IDW imputation using the nearby stations $B$, $C$ and $D$. As only the values in $B$ and $C$ for $f_n$ are available at $ts_i$, they will be the ones used to fill the missing $f_n$ value at $A^{(ts_i)}$. If we adopted `min_required_stations_for_imputation = 3`, as described below the pseudo-algorithm above, then $A_{fn}^{(ts_i)}$ would not have been imputed.

![](https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/imputation.png)

## Modelling Strategy

The proposed ML-based forecasting system is composed of two stacked procedures described below. In each one of these procedures Supervised Leaning techniques have been applied in order to prepare the data and train the models.

{{% steps %}}

### Site-specific Models

![](https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/overview_p1_borderless.png "Procedure 1: site-specific training schematic view. ")

The first step was to obtain site-specific models trained and tuned with historical meteorological data collected in each one of the collection sites of the area of study. The models and predictions in this procedure are said to be "site-specific" in the sense that, in this stage, no data is shared across stations; all training and tuning carried out in station `s0` is performed only with data from `s0`. This is only possible bacause all stations follow the same standards when recording meteorological data. The dataset used to train the models to predict $\hat{R}_{ts + 1}$, the radiation for the next hour followed the given format:

$$ (ts, B, D, H, P, T, R, W_s, W_d) \rightarrow \hat{R}_{ts + 1} $$

The Machine Learning algorithms used to train the site-specific models are shown below. For each one of the training algorithms hyperparameters search routines also were conducted and the fitted models were all combined into a [Stacking Regressor](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.StackingRegressor.html). **At the end of this step we expect to produce one ensemble of trained models per meteorological station**.

- [Multi-layer Perceptron](https://scikit-learn.org/stable/modules/generated/sklearn.neural_network.MLPRegressor.html) (Dense Neural Network - NN)
- [Support Vector Machine](https://scikit-learn.org/stable/modules/generated/sklearn.svm.SVR.html) (SVM)
- [Extremely Randomized Trees](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.ExtraTreesRegressor.html) (Extra Trees - ET)
- [Extreme Gradient Boosting](https://xgboost.readthedocs.io/en/latest/python/python_api.html?highlight=xgbregressor#xgboost.XGBRegressor) (XGB)
- [Random Forests](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.RandomForestRegressor.html) (RF)

{{< callout type="info" >}}
During this stage two branches of execution for training and tuning routines were followed for each station: 1) using original data and 2) using imputed data. After the training and tuning of all models using the two distinct datasets, the best model was selected based on RMSE.
{{< /callout >}}

### Generalization Model

![](https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/overview_p2_borderless.png "Procedure 2: generalization dataset construction and training scheme.")

In order to generalize the predictions we need to train and tune a single generalization model using as input the predictions of the site-specific models trained in the previous procedure. For this step a new dataset is constructed from the site-specific predictions incorporating additional information. This new dataset was constructed incorporating for each station the 3-tuple $(d^n, E^n, \hat{R}_{ts_i + 1}^{n})$ in which:
- $d^n$ is the Haversine Distance from the generalized station to its $n$-th closest station.
- $E^n$ is the average between the RMSE and MAE of the estimator in the $n$-th closest station.
- $\hat{R}_{ts_i + 1}^{n}$ is the estimated value of $R$ at timestamp $ts$ produced by the $n$-th closest station.

The ideia behind it is that **the generalization model should be able to learn the relations involving distance and "trustworthiness" (measured by the error $E$) of the closest nearby site-specific models when combining their predictions** to produce a generalized prediction. The dataset used to train the generalization model followed the given format ($La_i$ is the latitude and $Lo_i$ of the generalized prediction site):

$$
\bigg(ts_i, La_i, Lo_i,
\overbrace{d^1, E^1, \hat{R}^1}^{\text{station } 1}, \cdots,
\overbrace{d^n, E^n, \hat{R}^n}^{\text{station } n} \bigg)
\rightarrow {\psi_{ts + 1}} 
$$

To prevent noise in this new dataset, the minimum required number of tuples $(d^n, E^n, \hat{R}_{ts_i + 1}^{n})$ was set to 3. Since this dataset was set to accomomdate up to 7 of these 3-tuples, when the number of available 3-tuples was inferior to 7, the remainig "slots" were filled with zeros.

{{< callout type="info" >}}
Note that:

1. The filter selecting only stations with 7 years of valid retroactive observations (mentioned in section [Preprocessing](#preprocessing)) was by-passed in this step as, despite not having available observations for the first procedure training, the observed values were still relevant when training and assessing the generalization model.
1. When generating the dataset rows associated to a prediction site $s_i$, all predictions from this site coming from the previous stage were discarded as the distance between $s_i$ and $(La_i, Lo_i)$ is 0; so the set of selected models always considers the closest stations except the one exactly at $s_i$.
{{< /callout >}}

{{% /steps %}}

### Final Prediction Scheme

Putting everything together, the following picture ilustrates the whole process of generating a solar radiation prediction. For site-specific predictions, only the inferior portion of the figure can be considered.

![](https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/prediction_summary.png)

## Baselines

As a way to assess the models and have some comparative basis two baselines were used in this project. They are described in details in the followind sections.

### Empirical Model

The empirical model used in this project corresponds to the CPRG model, a decomposition-based solar radiation model capable of performing hourly predictions by relating variables such as latitude, longitude, day of year and hour with the solar radiation intensity. The implementation can be found in the [project repository](https://github.com/lfenzo/ml-solar-sao-paulo/blob/master/src/empirical_vs_ml/empirical_model.py), for further details check out [this article](https://dergipark.org.tr/en/pub/estubtda/issue/54537/650497).

### IDW-based Interpolation

This method is very similar to the [Data Imputation](#data-imputation) technique used for the data imputation in the first procedure, however, instead of using IDW to interpolate values of missing features, we are interpolating predictions generated the site-specific models. As in the generalization model, this baseline model also incorporates the measure of "trustworthiness" of site-specific models by adding to the weights the error from the estimators. As a reference, the following equation shows the calculation of a weight of the model associated to a station $s_i$ with respect to the station $s_0$ ($e_{s_i}$ is the best estimator for the site $s_i$ and $d$ is the Haversine Distance).

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

Given the configuration in the modelling strategy, the site-specific models and the generalization model were evaluated sepately. In both cases performance was measured using the [Root Mean Squared Error](https://en.wikipedia.org/wiki/Root-mean-square_deviation) (RMSE), [Mean Absolute Error](https://en.wikipedia.org/wiki/Mean_absolute_error) (MAE), the [Coefficient of Determination](https://en.wikipedia.org/wiki/Coefficient_of_determination) (R²) and the Mean Bias Error (MBE). The values in the tables in upcoming sub-sections correspond to the mean ($\bar{x}$) and standard deviation of metrics values in each meteorological station comparing the results of the proposed method (ML) against its baselines.

### Site-specific Models

Performance in the site-specific models was measured using the test set of each station, which corresponded data records from 2019 to 2021. The numbers presented below are the mean and standard deviantion values of the performance metrics considering the ensemble of best models obtained in each location after hyperparameter tuning.

<br>

<style>
.container {
 display: flex;
 flex-wrap: wrap; /* Allows the items to wrap as needed */
}

.table {
 flex: 1; /* Takes up the available space */
 margin-right: 20px; /* Adds some space between the table and the images */
}

.image-container {
 flex-wrap: wrap; /* Allows the images to wrap as needed */
 flex: 1; /* Takes up the available space */
}

img {
 max-width: 100%; /* Ensures images are responsive */
 height: auto; /* Maintains aspect ratio */
}

@media (max-width: 500px) {
 .container {
    flex-direction: column; /* Stacks children vertically */
 }
}
</style>

<div class="container">
    <table class="table">
        <tr>
            <th rowspan="2" colspan="2">Metric</th>
            <th colspan="2">Method</th>
            <th rowspan="2">$\underset{\text{EMP} - \text{ML}}{\Delta\%}$</th>
        </tr>
        <tr>
            <th>CPRG<br>(baseline)</th>
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
    <figure class="image-container">
        <img src="https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/src/visuals/perf_scatter/perf_scatter.png" width="100%">
        <figcaption>MAE per station. Each point in the scatter plot above represents a meteorological station in the first procedure.</figcaption>
    </figure>
</div>

{{< callout type="info" >}}
Out of the 39 models (each associated to a station) in the site-specific step, **20 had their performance improved by using the IDW-imputed data.**
{{< /callout >}}

Some interesting insights were noted during the assessment in this stage. One of them was the presence of a bias in the estimators causing them to procude worse predictions along the year. This behavior, showed in the left picture below where the residual errors are plotted as a function of the day of the year in the test set, shows that higher errors are procuded in the months of November through February, which correspond to the summer rain season in this particular region. Conversely, the winters in Southeastern Brazil are characterized by the lower volume of precipitation and less variation in overall climate conditions which introduced less noise in the data consumed by the models resulting in more accurate predictions.

<div class="container">
  <figure class="image">
    <img src="https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/residuals_example.png">
    <figcaption>Example of the bias with respect to the period of the year. In this image the station A711 is used as an example.</figcaption>
  </figure>
  <figure class="image">
    <img src="https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/sp_rain.png">
    <figcaption>Global solar radiation (boxplot) in relation to the precipitation (monthly average over the period of available data).</figcaption>
  </figure>
</div>

Another interesting fact was observed plotting the performance with respect to the geographical location of stations. Site-specific models located predominantly in the northwest of the State of São Paulo (see figure below) presented slightly better metrics then the ones in the Southeast. Again, this is due to the variability in climate conditions, this time influenced by the proximity of such locations to the Atlantic Ocean. Continentality of these locations make climate conditions less prone to abrupt variations; besides that, estimators also benefit from overall less precipitation as these regions are also mostly drier than other regions of the State.

<figure>
    <img src="https://raw.githubusercontent.com/lfenzo/ml-solar-sao-paulo/master/img/errors_by_site.png">
    <figcaption>RMSE in each model in the procedure 1. Sites marked as X were not used for training for not meeting the minimun required amount of retroactive data. See the Preprocessing section for details.</figcaption>
</figure>

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

{{< callout type="info" >}}
Note that the values of the CPRG model are different from the ones in the previous procedure (even though the method is the same) as a greater number of stations were used during performance assessment for the second procedure.
{{< /callout >}}

## Conclusions

Some interesting conclusions from this project:

1. Both site-specific models and the generalization model were able to outperform their baselines. The difference in performance metrics between the approaches suggests that the higher cost in terms of complexity is rewarded as more accurate predictions.

1. The inverse distance weighting based imputation performend during preprocessing showed to be a promising approach as an Imputation method for geographical data as more than then the half of models in P1 had their performance improved by using it. Although this technique played a relatively small role in the project, given its impact, it is fair to say that it deserves its own investigation to address further questions such as the optimal distance for imputation, how different features respond to it and its limitations and drawbacks.

1. The bias uncovered by residual plots may be attenuated by having models specialized in certain periods of the year. In this cases, models responsible for summertime predictions may benefit from additional techniques to reduce the excessive noise present 
