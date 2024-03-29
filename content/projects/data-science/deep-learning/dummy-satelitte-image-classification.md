+++
title = 'Dummy Satellite Image Classification'
date = 2024-03-28T17:29:05-03:00
type = 'blog'
+++

The objective of this project was to compare the difference between the `Adam`, `SGD` and
`RMSprop` optimizers in a task of image classification with neural networks trained using PyTorch.

- **Problem domain(s):** multi-class image classification.
- **Model architecture(s)**: Resnet (defined and trained from scratch).
- **Optimizer(s)**: Adam, Stochastic Gradient Descent and RMSProp.

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

## Performance

<table>
    <tr>
        <td><img src = "./images/learning_curves.png"></td>
        <td><img src = "./images/confusion_matrix.png"></td>
    </tr>
</table>

-----------------

![](./images/missclassifications_per_class.png)
