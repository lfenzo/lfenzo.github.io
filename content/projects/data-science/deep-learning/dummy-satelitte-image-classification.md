+++
title = 'Dummy Satellite Image Classification'
description = "A simple project using computer vision techniques with deep learning to classify satellite images."
date = 2024-03-28T17:29:05-03:00
type = 'blog'
tags = ['deep-learning']
+++

## Introduction

This project is the equivalent of a "hello world" program in the computer vison realm targetting a very simple image classification task in which each image is associated to a label. During this project, apart from implementing the data preparation, training and evaluation routines; 3 different optimizers (namely the `Adam`, `SGD` and `RMSprop` optimizers) were tested during the project. Implementation was carried out with PyTorch and Torchvision

- **Problem domain(s):** multi-class single-label image classification.
- **Model architecture(s)**: [ResNet](https://arxiv.org/abs/1512.03385) (defined and trained from scratch).
- **Optimizer(s)**: Adam, Stochastic Gradient Descent (SGD) and RMSProp.

<br>

{{< cards >}}
  {{< card link="https://github.com/lfenzo/dummy-satellite-image-classification" icon="github" title="Source Code" >}}
  {{< card link="https://www.kaggle.com/datasets/mahmoudreda55/satellite-image-classification?resource=download" icon="database" title="Dataset Source" >}}
{{< /cards >}}

## Dataset

Data used in this project corresponds to Remote Sensing (RS) images stored as `.jpg` files with relatively
low resolution. Each of the images is associated to exactly one of the following 4 classes:
- green area
- cloudy
- desert
- water

The figure below depicts examples for these images as well as their respective classes:

![](https://raw.githubusercontent.com/lfenzo/dummy-satellite-image-classification/main/images/training_samples.png)

The data can be freely downloaded in the following [Kaggle dataset link](https://www.kaggle.com/datasets/mahmoudreda55/satellite-image-classification?resource=download).

## Approach

## Results

### Performance

![](https://raw.githubusercontent.com/lfenzo/dummy-satellite-image-classification/main/images/learning_curves.png)

### Confusion Matrix
![](https://raw.githubusercontent.com/lfenzo/dummy-satellite-image-classification/main/images/confusion_matrix.png)

### Misclassification Examples
![](https://raw.githubusercontent.com/lfenzo/dummy-satellite-image-classification/main/images/missclassifications_per_class.png)
