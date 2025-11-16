+++
title = 'Dogs vs. Cats Image Classification'
type = 'docs'
sidebar.exclude = true
+++

**Goal:** Build a binary image classifier with Transfer Learning to distinguish between dog and cat images.

![](https://raw.githubusercontent.com/lfenzo/dl-dogs-vs-cats/refs/heads/master/img/examples.jpeg)

{{< cards >}}
  {{< card link="https://github.com/lfenzo/dl-dogs-vs-cats" icon="github" title="Source Code" >}}
  {{< card link="https://www.kaggle.com/c/dogs-vs-cats" icon="database" title="Kaggle Dataset" >}}
{{< /cards >}}


**Background**

This dataset was originally released as part of a Kaggle competition hosted by Microsoft Research in 2013. It became a classic benchmark for beginner and intermediate deep learning practitioners due to its simplicity and effectiveness in demonstrating convolutional neural networks (CNNs) in image classification tasks.

**Highlights**
- Implemented using PyTorch and Torchvision
- Transfer Learning with pre-trained ResNet-50 weights
- Used Cross Entropy Loss and evaluated with F1 Score
- Achieved 98% weighted F1 Score in test set

**Processing & Treatments**
- Images were resized and normalized using standard ImageNet preprocessing
- Data was split into training and validation sets with stratification
- Applied basic data augmentation (e.g., random flips and crops) to increase robustness
