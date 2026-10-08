#import "../template.typ": *

If we know the perfect $p(x,t)$, so the join probability distribution of the data and the labels, we can compute the optimal classifier , wich is a optimal bayes classifier, that is the classifier that minimize the probability of error.

We are not able to know the perfect $p(x,t)$, so we have to estimate it from the data. We can use a parametric model $p(x,t|theta)$, where $theta$ are the parameters of the model.

#note()[
  In pratice we can only do an estimation of the estimed error, because we don't know all the universe of the data and the distribution function.
]

The main goal is to construct a model that is able to generalize well on unseen data expect overfitting the training data. The model should be able to learn the underlying distribution of the data and make predictions on new data.

== Estimation of the expected risk

We have an *upper bound* of the expected risk:
$
  R(omega) <= R_"emp"(omega) + phi (h/m)
$
$phi$ is a function that depends on the complexity of the model $omega$ and the number of training samples ($m$). This is a monotone decreasing function, having a lot of example, make the $phi$ smaller.\
For having a good generalization we need to have a big training set.

Complexity $h$ is a measure of the number of parameters of the model. The more complex the model is, the more parameters it has, and the more data we need to estimate them. If we have a lot of parameters and a small training set, we will overfit the training data.

//riguardare
If the complexity is high the emperical risk tend to be low.

#note()[
  This upper bound could be not so tight, the expected upper bound can be far from the real expected risk.

  In practice we can't use this upper bound because it becomes too loose, so we need to use other methods to estimate the expected risk.
]

= Supervised machine learning methods

== KNN

We can use the $k$ nearest neighbors to classify a new point. The class of the new point is determined by the *majority* class of the $k$ nearest neighbors.

It depends on the parameter $k$:
- if $k$ is too small we can have a *high variance* (sensitive to noisy data). For example if $k = 1$ the model will be very sensitive to the noise in the training data, and it will overfit the training data.

  #note()[
    $k=1$ is equal to the Voronoi diagram. Each point create a region of the space, and the new point will be classified according to the region it falls into.
  ]


- if $k$ is too big we can have a *high bias*. Neighbors can include points that are far away from the new point, and the model will not be able to capture the local structure of the data. Also the computation would be expensive.
// aggiungere immagine da slide

We need to find a good trade-off between bias and variance.

#warning()[
  It can suffer from the *curse of dimensionality*, because in high dimensional spaces the distance between points becomes less meaningful, the points are concentrated in the manifold, and the distance between points becomes less meaningful. The distance between points becomes more similar, and the model will not be able to capture the local structure of the data.
]

== Perceptron linear neural model

//aggiungere immagine
In a neural model we have a set of input features $x_1, x_2, ..., x_n$ and a set of weights $w_1, w_2, ..., w_n$.

This input are combined linearly with the weights to produce a single output:
$
  sum_(i=0)^n w_i x_i
$

The output of the model is a linear combination of the input features and the weights, passed through an *activation function*. We use this function to obtain an input that is in the range of [1,-1] (sigmoid function) for example it can be usefull for classification problems.

Sigmoid function is a good function because it is differentiable, and we can use the gradient descent to update the weights of the model. Also it is a smooth function, the value of the function is in the range of [0,1], and it is a monotone increasing function.

//aggiungere geometric representation
The slope of this line its depend on the $omega$ value, we can separate the space in two half-spaces, one for each class. The perceptron is a linear classifier, and it can only classify linearly separable data.

=== Perceptron learning

How we learn $w$? the weights. We need first of all a training set of data:
$
  T = [(x_k, t_k)]_(k=1)^n
$
The prediction of the model is:
$
  y_k = "sign"(w^t x)
$
where "sign" is the sign function, that return 1 if the value is positive, -1 if the value is negative, and 0 if the value is 0.


We can use for the training error a quadratic loss function:
$
  E(w) = 1/2 sum_(k=1)^n (underbrace(t_k, "true target") - underbrace(y_k, "prediction"))^2
$
//aggiungere immagine
The mian idea is to modify the weights in order to minimize the error function. In the image we can see a $2D$ example with two weights $w_1$ and $w_2$.

=== Gradient descent

//aggiungere matematica

What we try to do is tu find the minimo of the error function. In this case it is a parabolic function (quadratic error). We want to find the minimu by computing the gradient of the error function, and update the weights in the opposite direction of the gradient. The gradient is a vector that points in the direction of the steepest ascent of the function, so we want to move in the opposite direction to find the minimum:
$
  w_i = w_i + D w_i \
  D w_i = - h * ((partial E(w)) / (partial w_i))
$
$h "or" eta$ is the learning rate, that is a parameter that controls the step size of the update. If it is too small we will have a slow convergence, if it is too big we can overshoot the minimum and diverge. Where:
$
  (partial E(w)) / (partial w_i) = partial / (partial w_i) 1/2 sum_(t_k in T) (t_k - y_k)^2) = sum_(t_k in T)(t_k - y_k)(-x_i)
$
#note()[
  $y_k$ depend on $w_i$, so we need to use the chain rule to compute the derivative of the error function with respect to the weights.
]

At the minimum the gradient is zero (because the tangent is horizontal) or aproximately zero.

=== Gradient descente algorithm

1. Initialize the weights $w_i$ randomly (or with small values)

2. Repat until a stop condition is met (for example a maximum number of iterations or a small error):
  1. Initialize the gradient $Delta w_i = 0$ for all $1<= i <=d$
  2. For each training example $(x_k, t_k)$:
    1. Compute the prediction $y_k = w x_k$
    2. For each weight $w_i$:
      1. Update the gradient $Delta w_i = - eta (t_k - y_k) x_i$
      2. Update the weight $w_i = w_i - Delta w_i$

Some possible stop conditions are:
- A maximum number of iterations is reached
- The error function is below a certain threshold
- Control if the update of the weight are below a certain threshold, if the update is too big we can stop the training because the model is not converging.

== Multiple class perception

We have multiple perceptrons, one for each class output classes. In this case the input are the same for all the perceptrons, but the weights are different for each perceptron. The output of each perceptron is a score for each class (a vector), and we can use a softmax function to convert the scores into probabilities.

//aggiungere immagine

#note()[
  The output is selected according to the winner takes all strategy, that is the class with the highest score is selected as the output class. This can be a problem if the scores are very close to each other, because we can have a high uncertainty in the prediction.
]

#warning()[
  Using perceptrons or multiple class perceptrons *we can only classify linearly separable data*. In the sense that we can separate the data with a hyperplane.

  If the data is not linearly separable we need to use a more complex model, like a neural network with multiple layers (deep learning).
]

== Multi-layer perceptron

We add the concept of the *hidden layer* (they are hidden because they are between the input and the output layer). The hidden layer is composed of multiple perceptrons, that are connected to the input layer and the output layer. Each perceptron in the hidden layer is connected to all the perceptrons in the input layer and the output layer.

There is a theorem that is called the *universal approximation theorem*, that states that a neural network with a single hidden layer can approximate any continuous function, given enough neurons in the hidden layer. This means that we can use a neural network to approximate any function, given enough data and computational resources.


#warning()[
  We can't apply the gradient descent algorithm to the multi-layer perceptron, because by strating from the output layer and going backward to the input layer, we fouund the hidden layer, and we don't know the target output for the hidden layer. We need to use a different algorithm called *backpropagation* to compute the gradient of the error function with respect to the weights in the hidden layer.
]

=== Backpropagation

The algorithm is based on the chain rule of calculus, and it allows us to compute the gradient of the error function with respect to the weights in the hidden layer.

#note()[
  To remeber, the chain rule states that if we have a function $f(g(x))$, then the derivative of $f$ with respect to $x$ is:
  $
    (partial f(g(x))) / (partial x) = (partial f(g(x))) / (partial g(x)) * (partial g(x)) / (partial x)
  $
  //see banjo paper in nature about deep learning inportance
]

The idea is to compute the gradient of the error function with respect to the output of each perceptron in the hidden layer, and then use this gradient to update the weights of the perceptrons in the hidden layer.

== Performance evaluation

The generalization capability of the model depend on:
- Network architecture (number of layers, number of neurons per layer, activation function)

- Number of training neurons (more neurons can lead to overfitting, less neurons can lead to underfitting)

- Regularization techniques: put on some contraints on the magnigtude og the weights. For example we can use L1 or L2 norm regularization, that penalize the weights that are too big. This can help to prevent overfitting and improve the generalization capability of the model.

- Stop conditions

In the pratice we need to find the optimal combination of these factors that are called *hyperparameters*, that are parameters that are not learned by the model (those are the weights), but are set by the user. We can use a validation set to evaluate the performance of the model and select the best hyperparameters.

== SVM Support vector machine

SVM is a linear classifier that finds the maximum margin. This margin is the maximum distance between the hyperplane and the closest points of the two classes. The points that are closest to the hyperplane are called *support vectors*, and they are the points that define the margin.

We want to choose the hyperplane that separates better the two classes.

=== Kernel trick

We can use a kernel function to map the data into a higher dimensional space, where the data is linearly separable. This is called the *kernel trick*, and it allows us to use SVMs for non-linear classification problems.

Example of kernel functions are:
- Polynomial kernel: $K(x, y) = (x^T y + c)^d$, where $c$ is a constant and $d$ is the degree of the polynomial. The demension of the space is $d$.

- Gaussian kernel: $K(x, y) = exp(-||x - y||^2 / (2 sigma^2))$, where $sigma$ is a parameter that controls the width of the Gaussian. The dimension of the space is infinite.

With the kernel we obtain an optimal separation even where this point are not linearly separable in the original space.

= Estimate the generalization error

For every model we need to estimate the generalization error, that is the error that the model will make on unseen data. We can have two approaches:

- Theorical estimation: we can use the upper bound of the expected risk, that is a function of the complexity of the model and the number of training samples. This approach is not very accurate, because the upper bound can be very loose.

- Empirical estimation: we can use a validation set to estimate the generalization error. We can split the training set into a training set and a validation set, and use the validation set to evaluate the performance of the model. This approach is more accurate, but it requires more data.

== Empirical estimation of the generalization error

We usually have 4 classes of empirical estimation of the generalization error:

- Hold-out method: we split the training set into a training set and a validation set, and use the validation set to evaluate the performance of the model. This approach is simple, but it can be sensitive to the choice of the split.

- Cross-validation: we split the training set into $k$ folds, and use $k-1$ folds for training and the remaining fold for validation. We repeat this process $k$ times, and average the performance of the model on the validation sets. This approach is more robust than the hold-out method, but it can be computationally expensive.

- Bootstrap: we sample with replacement from the training set to create multiple training sets, and use the remaining data for validation. We repeat this process multiple times, and average the performance of the model on the validation sets. This approach is more robust than the hold-out method, but it can be computationally expensive.

== Hold-out method

The main idea is to split the dataset into two parts: a training set and a validation set. The training set is used to train the model, and the validation set is used to evaluate the performance of the model.

#warning()[
  The test set should be used only for the final evaluation of the model, and not for hyperparameter tuning or model selection.
]

The main idea is to assume that the dataset is a good representation of the underlying distribution, and that the training set and the validation set are drawn from the same distribution. This assumption is not always true, especially if the dataset is small or biased.

There are some problems with the hold-out method:

- If we have a small dataset, if we split the data we reduce the avaialable data for training. This is not good because we know that the generalization error is a function of the number of training samples, and if we reduce the number of training samples we increase the generalization error.

- The sample test can be constructed by random sampling, but it can be biased. For example the validation set can be composed by only simple examples, and the model will not be able to generalize well on complex examples. This is called *sampling bias*.

  #note()[
    In pratice the random sampling can be a good idea when we have a relatively large dataset, but it can be a problem when we have a small dataset. In this case we can use cross-validation or bootstrap to estimate the generalization error.
  ]

== Hold-out and repeat hold-out

//riguardare


=== Repeat hold-out

This is a more robust version of the hold-out method, where we repeat the hold-out method.

== K-fold cross-validation

We have multiple experiments but the idea is to subdivide the total number of examples in $k$ folds with the *same dimension and with no overlap*.

#note()[
  In this way we are sure that one example are in the test set only once. This not happen in the repeat hold-out method, where we can have the same example in the test set multiple times.
]

//aggiungere immagine

The grey test set is the validation set, and the white training set is the training set. Finnlay if we have $k$ folds we can compute the average of the performance of the model on the validation sets, and use this average as an estimate of the generalization error.

== Leave-one-out

In this case the number of folds is equal to the number of examples in the dataset. This means that we have $n$ folds, where $n$ is the number of examples in the dataset. Each fold contains a single example, and the remaining $n-1$ examples are used for training.

In this way we can obtain the largest possible training set, and we can use the remaining example for validation.

#note()[
  The errror estimate have a large variance, because the validation set is composed by a single example. So the performance can be the worst or the best.
]

#warning()[
  We can't never use the training set for generalization error estimation, because the model is trained on the training set, and it will have a low error on the training set. This is called *overfitting*.
]

== ROC Curver

The Roc curve is a graphical representation of the performance of a binary classifier as the discrimination threshold is varied. It is created by plotting the true positive rate (TPR) against the false positive rate (FPR) at various threshold settings.

ROC curve is a ranking methods that say that positive examples are ranked higher than negative examples. This means that the model is able to distinguish between positive and negative examples, and it is not affected by the class imbalance.

A good result is a curve that is close to the top left corner of the plot, which indicates a high true positive rate and a low false positive rate. If we compute the area under the curve (AUC), we can have a single number that summarize the performance of the model. The AUC is a value between 0 and 1, where 1 indicates a perfect classifier and 0.5 indicates a random classifier.

A bad result is a curve that is close to the diagonal line, which indicates a random classifier.

