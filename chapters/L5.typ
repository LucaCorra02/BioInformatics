#import "../template.typ": *

= Supervised machine learning

Usually during the training phase we have only a limited number of examples, and we want to learn a model that is able to generalize well on unseen data. The main goal is to minimize the *expected risk*, that is the expected error on unseen data.

== Loss function

Suppose that we have a dataset of $D$ examples, where for each input $x_i$ we have a corresponding target $t_i$:
$
  D = {(x_1, t_1), (x_2, t_2), ..., (x_n, t_n)}.
$
the main goal is to learn a function $g$ that maps inputs to targets, $g: X -> T$. We also want a function $g$ that garantees a good approximation $g(x_1) = t_1, dots, g(x_n) = t_n$. To achieve this, we need to define a *loss function* $L(g(x_i), t_i)$ that measures the *error of a prediction*. The empirical risk is the average loss on the training set:
$
  R_"emp"(g) = 1/n sum_(i=1)^n "Loss"(g(x_i), t_i).
$
The loss function is a *non-negative* function that quantifies the difference between the predicted value and the true target value. The choice of loss function depends on the specific problem and the type of data.

#example()[
  Suppose that $x in RR^d$ is a vector containing the expression levels of
  $d$ genes in one sample, and that $t in {0, 1}$ indicates whether the sample
  comes from a healthy or a diseased patient. We want to learn a classifier
  $g: RR^d -> {0, 1}$ from a dataset
  $D = {(x_i, t_i)}_(i=1)^n$.

  A *loss function* $L(g(x_i), t_i)$ measures the error of a prediction. The
  empirical risk is the average loss on the training set:
  $
    R_"emp"(g) = 1/n sum_(i=1)^n L(g(x_i), t_i).
  $
  The learning algorithm chooses the model parameters that minimize this
  quantity, possibly together with a regularization term. The loss does not
  necessarily range from $0$ to $1$: squared error, absolute error,
  cross-entropy, and zero-one loss have different scales. A lower loss means
  better agreement with the targets according to the chosen definition.
]

== Estimating the expected risk

In the previous section, we defined the empirical risk as the average loss on the training set. However, we are interested in the *expected risk*, which is the *expected loss on unseen data*.

*Learning* $f: R^d -> C$ is realized with:
- A learning algorithm $L$ that approximates the function $g$ that belongs to a set of functions $G$ (the hypothesis space):
  $
    g: R^d times Omega -> C
  $
  $Omega$ are the learning parameters that are optimized during the training phase.

- A training set $D = {(x_i, t_i)}_(i=1)^n$ of $n$ examples drawn from an unknown distribution $p(x, t)$.

  #note()[
    If we knew the true joint probability distribution $p(x, t)$ of the data and
    the labels, we could compute the optimal classifier. For zero-one loss, this
    is the *Bayes classifier*: the classifier that minimizes the probability of
    classification error.
  ]

In practice, we do *not know* the true distribution, so we have to estimate it
from the available data. We can use a parametric model $p(x, t | omega)$,
where $omega$ denotes the parameters of the model. We want to minimize:
- The emperical risk $R_"emp" (omega)$

- The *expected risk* $R(omega)$, which is the expected loss on unseen data:
$
  R(omega) = integral integral "Loss"(mr(g(x, omega)), t) * mb(p(x, t)) "dx" "dt".
$
where:
- $mr(g(x, omega))$ is the prediction of the model for input $x$ and parameters $omega$.
- $mb(p(x, t))$ is the density probability function of the data and the labels. It model in the real world how much it's likely to observe a certain input $x$ and its corresponding label $t$.

#warning()[
  Since the true distribution $p(x, t)$ is unknown, we cannot compute the expected risk directly. Instead, we use the *empirical risk as an approximation* (risk only on training data) and rely on statistical learning theory to provide *bounds* on the expected risk based on the empirical risk and the complexity of the model.
]

=== Upper bound on the expected risk

Since we are not able to compute the expected risk directly, we can use an upper bound on the expected risk based on the empirical risk and the complexity of the model. This is a fundamental concept in statistical learning theory:
$
  R(omega) <= R_"emp" (omega) + phi(h, m),
$
where:
- *$h$*: is a measure of *model complexity*
- *$m$*: is the *number of training
  examples*
- *$phi(h, m)$*: it's a function that depends on the complexity ($h$) and the number of training examples ($m$). It is called the *generalization bound*.

  #note()[
    - *$h$* indicates the ability of the model to fit a wide range of functions. $phi(h, m)$ *increases* with $h$: more complex models have a higher risk of overfitting, they work well on the training data but may not generalize well to unseen data.

    - *$m$* indicates the number of training examples. $phi(h, m)$ *decreases* with $m$: more training examples provide more information about the underlying distribution, which helps to reduce the risk of overfitting.
  ]

#warning()[
  This upper bound *may not be tight*: it can be far from the actual expected risk. In practice, it is often too loose to be used directly, so we use empirical methods to estimate the generalization error.
]

= ML Model


== K-nearest neighbors

We can use the $k$ nearest neighbors (KNN) to classify a new point. The class of the new point is determined by the *majority class* among its $k$ nearest neighbors. The result depends on the parameter $k$:

- If $k$ is *too small*, the model can have *high variance* and be sensitive to noisy data. For example, when $k = 1$, the model is very sensitive to noise in the training data and can overfit.

  #note()[
    For $k=1$, the decision regions correspond to the *Voronoi diagram* of the
    training points. Each point defines a region of the space, and a new point
    is classified according to the region in which it falls.
  ]

- If $k$ is *too large*, the model can have *high bias*. The neighborhood can include points that are far from the new point, preventing the model from capturing the local structure of the data. A large value of $k$ can also increase the computational cost of finding the neighbors.

We need to find a good *trade-off* between bias and variance.

#figure(
  caption: [Classification of a new point with 3-nearest neighbors.],
)[
  #align(center)[
    #cetz.canvas(length: 1.15cm, padding: 0.2cm, {
      import cetz.draw: *

      // Coordinate system: x increases to the right and y upwards.
      rect((0, 0), (6, 6), stroke: (paint: black, thickness: 0.8pt))

      // Negative examples.
      for point in (
        (0.8, 5.7),
        (3.5, 5.5),
        (5.3, 5.3),
        (1.0, 4.6),
        (2.8, 4.7),
        (4.2, 4.6),
        (0.9, 1.5),
        (2.8, 3.2),
      ) {
        line((point.at(0) - 0.22, point.at(1)), (point.at(0) + 0.22, point.at(1)), stroke: (
          paint: navy,
          thickness: 2.5pt,
          cap: "round",
        ))
      }

      // Positive examples.
      for point in (
        (3.9, 4.0),
        (5.5, 4.6),
        (5.5, 1.7),
        (3.8, 1.3),
        (2.3, 0.5),
        (4.7, 0.5),
      ) {
        line((point.at(0) - 0.2, point.at(1) - 0.2), (point.at(0) + 0.2, point.at(1) + 0.2), stroke: (
          paint: maroon,
          thickness: 2.5pt,
          cap: "round",
        ))
        line((point.at(0) - 0.2, point.at(1) + 0.2), (point.at(0) + 0.2, point.at(1) - 0.2), stroke: (
          paint: maroon,
          thickness: 2.5pt,
          cap: "round",
        ))
      }

      // New point and the circle containing its three nearest neighbors.
      let new-point = (2.8, 2.8)
      circle(new-point, radius: 2.1, stroke: (paint: red, thickness: 1.4pt, dash: "dashed"))
      line((new-point.at(0) - 0.12, new-point.at(1)), (new-point.at(0) + 0.12, new-point.at(1)), stroke: (
        paint: black,
        thickness: 1pt,
      ))
      line((new-point.at(0), new-point.at(1) - 0.12), (new-point.at(0), new-point.at(1) + 0.12), stroke: (
        paint: black,
        thickness: 1pt,
      ))
      content((new-point.at(0) + 0.12, new-point.at(1) - 0.35), [x])
    })
  ]
]

#warning()[
  KNN can suffer from the *curse of dimensionality*. In high-dimensional
  spaces, *distances become less informative*: points tend to appear similarly far apart, and the model cannot reliably capture local structure.
]

== Perceptron: a linear neural model

In a neural model, we have a set of input features $x_1, x_2, ..., x_d$ and a corresponding set of weights $w_1, w_2, ..., w_d$. The inputs are *combined linearly* with the weights:
$
  z = sum_(i=1)^d w_i x_i + underbrace(mr(b), "bias vector")
$
The result can be passed through an *activation function*. In the classical
perceptron, the activation is the *sign function*, which produces a *binary
decision*.

The *decision boundary* is determined by the weights and the bias. It is a *hyperplane* that separates the space into two half-spaces, one for each class.

#figure(
  caption: [Geometric representation of the function computed by a perceptron.],
)[
  #align(center)[
    #cetz.canvas(length: 0.9cm, padding: 0.25cm, {
      import cetz.draw: *

      // The line is the decision boundary w_0 + sum_i w_i x_i = 0.
      line((4.6, 5.6), (2.0, 0.5), stroke: (paint: black, thickness: 1.2pt))

      // Positive and negative examples.
      circle((1.0, 3.0), radius: 0.09, fill: black, stroke: none)
      circle((7.8, 3.1), radius: 0.09, fill: black, stroke: none)

      content((3.3, 6.0), [
        $w_0 + sum_(i=1)^n w_i x_i = 0$
      ])
      content((0.25, 3.8), [
        $[x_1^+, ..., x_n^+] in E_n$ \
        $w_0 + sum_(i=1)^n w_i x_i^+ > 0$ \
        $arrow.r y = 1$
      ])
      content((5.4, 2.35), [
        $[x_1^-, ..., x_n^-] in E_n$ \
        $w_0 + sum_(i=1)^n w_i x_i^- < 0$ \
        $arrow.r y = 0$
      ])
    })
  ]
]

In other neural models, a *sigmoid* activation can be used to obtain an output in the interval $[0, 1]$, which is useful for binary classification. The sigmoid function is differentiable, smooth, and monotonically increasing, so it can be used with gradient-based optimization.

#warning()[
  The perceptron is therefore a linear classifier and can *classify only linearly separable data*.
]

=== Perceptron learning

To *learn the weights*, we first need a training set:
$
  T = [(x_k, t_k)]_(k=1)^n.
$
For targets $t_k in {-1, 1}$, the prediction of the perceptron is
$
  y_k = "sign"(w^T x_k + b),
$
where `sign` returns $1$ for a positive value, $-1$ for a negative value, and
$0$ for zero. We can use the quadratic training error
$
  E(w, b) = 1/2 sum_(k=1)^n (t_k - y_k)^2.
$
The main idea is to *modify the weights* in order to minimize the error function. In a two-dimensional example, this error can be visualized as a surface over the two weights $w_1$ and $w_2$.

=== Gradient descent

Given a differentiable error function $E(omega)$, we can use *gradient descent* to find the weights that minimize the error. The gradient of the error function is a vector that points in the direction of *steepest ascent*. By moving in the opposite direction of the gradient, we can iteratively update the weights to reduce the error:
$
  w_i <- w_i + Delta w_i \
  Delta w_i = - eta (partial E(w)) / (partial w_i),
$
where $eta$ is the *learning rate*. If it is too small, convergence is slow; if
it is too large, the updates can overshoot the minimum and the algorithm can diverge.


#example()[
  If we consider a quadratic error function $E(w_1, w_2)$, the gradient descent algorithm iteratively updates the weights $w_1$ and $w_2$ in the direction of the negative gradient. The learning rate $eta$ controls the size of the steps taken in each iteration. The process continues until convergence, in this case the lower point on the paraboloid.

  $
    (partial E(w)) / (partial w_i)
    = partial / (partial w_i) 1/2 sum_(t_k n T) (t_k - y_k)^2
    = -sum_(k=1)^n (t_k - y_k) (partial y_k) / (partial w_i).
  $
  For a linear prediction $y_k = w^T x_k$, this becomes
  $
    (partial E(w)) / (partial w_i)
    = -sum_(k=1)^n (t_k - y_k) x_(k i).
  $

]



#note()[
  When $y_k$ depends on the weights, the *chain rule* is needed to compute the
  derivative of the error with respect to each weight.
]

At a differentiable minimum, the gradient is zero, or approximately zero up to
the desired numerical tolerance.

=== Gradient descent algorithm

The algorithm for gradient descent can be summarized as follows:

1. Initialize the weights $w_i$ randomly or with small values.

2. Repeat until a *stopping condition* is met:
  1. Initialize the gradient $Delta w_i = 0$ for all $1 <= i <= d$.
  2. For each training example $(x_k, t_k)$:
    1. Compute the prediction $y_k = w x_k$.
    2. For each weight $w_i$, accumulate the gradient contribution: $ Delta w_i <- - eta (t_k - y_k) x_(k i) $

    3. Update each weight with $w_i <- w_i - Delta w_i$.

#note()[
  Possible *stopping conditions* include:
  - a maximum number of iterations is reached;
  - the error function falls below a chosen threshold;
  - the norm of the gradient or of the weight update falls below a chosen
    threshold.
]


== Multiclass perceptron

For *multiclass classification*, we can use *one perceptron for each class*.

The input is the same for all perceptrons, but each one has its own weights. The
output of each perceptron is a score for one class. We can select the class with the highest score, or use a softmax function to convert the scores into
class probabilities.

#note()[
  The *winner-takes-all* strategy selects the class with the highest score. If the scores are very close, the prediction has high uncertainty.
]

#warning()[
  A multiclass perceptron still produces *linear decision boundaries*. If the
  data is not linearly separable, a more complex model, such as a multilayer
  neural network, is needed.
]

== Multilayer perceptron

A multilayer perceptron adds one or more *hidden layers*. They are called
hidden because they are between the input and output layers. Each neuron in a
hidden layer receives inputs from the preceding layer and sends its output to
the next layer.

#theorem(title: "Universal approximation theorem")[
  The *universal approximation theorem* states that a neural network with one
  hidden layer can approximate *any continuous function* on a suitable compact
  domain, given an appropriate activation function and sufficiently many neurons.

  This does not mean that training is easy or that little data is enough: the required architecture, data, and computational resources depend on the problem.
]

Gradient descent can also be used for a multilayer perceptron. However, the
gradient for the weights in the hidden layers must be computed indirectly,
because there are no target values for hidden neurons (we only have target values for the output layer). The required algorithm is called *backpropagation*.

=== Backpropagation

Backpropagation is based on the *chain rule* of calculus. It computes the
gradient of the error with respect to the weights in the output layer and then
propagates this information backward through the hidden layers.

#note()[
  If we have a composition $f(g(x))$, the chain rule states that
  $
    (partial f(g(x))) / (partial x)
    = (partial f(g(x))) / (partial g(x))
    * (partial g(x)) / (partial x).
  $
  Backpropagation applies this rule repeatedly to the sequence of layers.
]

The computed gradients are then used by gradient descent to update the weights
of every layer.

== Performance evaluation

The generalization capability of a model depends on:
- the network *architecture*, including the number of layers, the number of
  neurons per layer, and the activation functions;
- the number of training neurons and the amount of *training data*. Too much model capacity can lead to overfitting, while too little can lead to underfitting;
- *regularization* techniques, which constrain the magnitude of the weights.

  #example()[
    For example, L1 and L2 regularization penalize large weights and can help
    prevent overfitting
  ]

- the *stopping conditions* used during training.

#note()[
  In practice, we need to find a good combination of these factors. They are
  called *hyperparameters*: unlike the weights, they are not learned directly
  from the training examples. A validation set can be used to compare models
  and select suitable hyperparameters.
]

== Support vector machines

An SVM is a linear classifier that finds a separating *hyperplane* with *maximum
margin*. The margin is the distance between the hyperplane and the closest
points of the two classes. These closest points are called *support vectors*,
because they determine the position of the maximum-margin hyperplane.

#align(center)[
  #image("../img/svm.png", width: 40%)
]

=== Kernel trick

A kernel function implicitly maps the data into a *higher-dimensional* feature
space, where it may become linearly separable. This is called the *kernel
trick* and allows SVMs to model *nonlinear* decision boundaries.

Examples of kernel functions include:
- polynomial kernel:
  $K(x, y) = (x^T y + c)^d$, where $c$ is a constant and $d$ is the degree;

- Gaussian kernel:
  $K(x, y) = exp(-(||x - y||^2) / (2 sigma^2))$, where $sigma$ controls the
  width of the Gaussian. The associated feature space can be infinite
  dimensional.

Using a kernel, we can obtain a linear separation in the feature space even
when the points are not linearly separable in the original space.

= Estimating the generalization error

For every model, we need to estimate the generalization error: the error that
the model makes on unseen data. For this purpose, we can use two main approaches:
- *Theoretical estimation*: use an *upper bound* on the expected risk based on
  model complexity and the number of training examples. This approach is often
  not very accurate because the bound can be loose.
- *Empirical estimation*: use *held-out data* to estimate the error. This approach is usually more informative, but it requires enough data for both training and evaluation.

== Empirical estimation methods

The main empirical methods are:
- *Hold-out*: split the data into a training set and a validation set.
- *Repeated hold-out*: repeat the hold-out procedure with different random
  splits and average the results.
- *Cross-validation*: divide the data into folds and use each fold for
  validation in turn.
- *Bootstrap*: sample with replacement to create multiple training sets and
  evaluate on the observations not selected in each sample.

== Hold-out method

The hold-out method *splits the dataset* into a *training set* and a *validation
set*. The training set is used to train the model, while the validation set is
used to evaluate its performance.

#warning()[
  The test set *should* be used only for the final evaluation of the model, not
  for hyperparameter tuning or model selection.
]

The method *assumes* that the training and validation sets are *representative*
of, and drawn from, the same *underlying distribution*. This assumption may not
hold when the dataset is small or biased.

There are two main $mr("problems")$:
- With a *small dataset*, splitting the data reduces the number of training examples. Since the generalization error usually decreases as the number of training examples increases, this can worsen the estimate and the model.

- A random split can be *biased*. For example, the validation set may contain mostly simple examples, so the measured performance may not represent the performance on more difficult examples. This is called *sampling bias*.

  #note()[
    Random hold-out can work well for a relatively large dataset. With a small
    dataset, cross-validation or bootstrap methods can use the available data
    more effectively.
  ]

== Repeated hold-out

In the repeated hold-out method, the hold-out procedure is *repeated $K$ times* with different random splits. Each *experimet is independent*.\
During each experiment, the dataset is randomly split into a training set and a validation set. The model is trained on the training set and evaluated on the validation set.

#figure(
  caption: [Repeated hold-out: a different random test set is selected at each experiment.],
)[
  #align(center)[
    #cetz.canvas(length: 0.48cm, padding: 0.2cm, {
      import cetz.draw: *

      let left = 5.0
      let right = 18.0
      let height = 0.72
      let rows = (6.0, 4.45, 2.9)
      let partitions = (
        (0.0, 1.0, 2.0, 2.5, 3.4, 4.1, 5.0, 6.2, 7.1, 8.0, 9.0, 10.3, 11.2, 12.2, 13.0),
        (0.0, 0.7, 1.3, 2.1, 3.7, 4.9, 6.1, 7.4, 8.6, 9.6, 10.9, 12.0, 13.0),
        (0.0, 0.8, 1.9, 2.6, 3.8, 4.8, 6.0, 7.0, 8.3, 9.8, 10.8, 12.0, 13.0),
      )
      let test-cells = ((1, 4, 8, 12), (0, 2, 6, 10), (1, 5, 9, 11))

      line((left, 7.55), (right, 7.55), stroke: (paint: black, thickness: 0.8pt))
      line((left, 7.55), (left, 7.1), stroke: (paint: black, thickness: 0.8pt))
      line((right, 7.55), (right, 7.1), stroke: (paint: black, thickness: 0.8pt))
      line((left + 0.25, 7.55), (right - 0.25, 7.55), stroke: (paint: black, thickness: 1.0pt))
      polygon((left + 0.05, 7.55), 3, angle: 90deg, radius: (0.22, 0.14), fill: black, stroke: none)
      polygon((right - 0.05, 7.55), 3, angle: 270deg, radius: (0.22, 0.14), fill: black, stroke: none)
      content((8.0, 8.0), text(size: 9pt)[Total number of examples])

      for (row, y) in rows.enumerate() {
        content((1.0, y + 0.18), text(size: 8pt)[Experiment #(row + 1)])
        let cuts = partitions.at(row)
        for index in range(cuts.len() - 1) {
          let x0 = left + cuts.at(index)
          let x1 = left + cuts.at(index + 1)
          let is-test = test-cells.at(row).contains(index)
          rect(
            (x0, y),
            (x1, y + height),
            fill: if is-test { luma(82%) } else { white },
            stroke: (paint: black, thickness: 0.7pt),
          )
        }
      }
      content((20.35, 6.8), text(size: 8pt)[Test examples])
      line((18.25, 6.82), (17.25, 6.42), stroke: (paint: black, thickness: 0.8pt))
      polygon((17.25, 6.42), 3, angle: 225deg, radius: (0.16, 0.1), fill: black, stroke: none)
    })
  ]
]

The results are *averaged* to provide a more stable estimate of the generalization error:
$
  E = 1/K sum_(i=1)^K E_i
$

== K-fold cross-validation

In $k$-fold cross-validation, the examples are divided into $k$ folds of
approximately *equal size*, with *no overlap*. We train the model $k$ times. At
each iteration, one fold is used as the validation set and the other $k-1$
folds are used for training.
#figure(
  caption: [K-fold cross-validation: each fold is used once as the test set.],
)[
  #align(center)[
    #cetz.canvas(length: 0.48cm, padding: 0.2cm, {
      import cetz.draw: *

      let left = 5.0
      let right = 18.0
      let height = 0.82
      let width = (right - left) / 5
      let ys = (6.2, 4.65, 3.1, 1.55)

      line((left, 7.65), (right, 7.65), stroke: (paint: black, thickness: 0.8pt))
      line((left, 7.65), (left, 7.2), stroke: (paint: black, thickness: 0.8pt))
      line((right, 7.65), (right, 7.2), stroke: (paint: black, thickness: 0.8pt))
      line((left + 0.25, 7.65), (right - 0.25, 7.65), stroke: (paint: black, thickness: 1.0pt))
      polygon((left + 0.05, 7.65), 3, angle: 90deg, radius: (0.22, 0.14), fill: black, stroke: none)
      polygon((right - 0.05, 7.65), 3, angle: 270deg, radius: (0.22, 0.14), fill: black, stroke: none)
      content((8.1, 8.1), text(size: 9pt)[Total number of examples])

      for (row, y) in ys.enumerate() {
        content((1.0, y + 0.22), text(size: 8pt)[Experiment #(row + 1)])
        for fold in range(5) {
          let x0 = left + fold * width
          let x1 = x0 + width
          rect(
            (x0, y),
            (x1, y + height),
            fill: if fold == row { luma(82%) } else { white },
            stroke: (paint: black, thickness: 0.8pt),
          )
        }
      }
      content((20.35, 1.2), text(size: 8pt)[Test examples])
      line((18.25, 1.25), (17.35, 1.75), stroke: (paint: black, thickness: 0.8pt))
      polygon((17.35, 1.75), 3, angle: 135deg, radius: (0.16, 0.1), fill: black, stroke: none)
    })
  ]
]

The average validation performance is used as an
estimate of the generalization error:
$
  E = 1/k sum_(i=1)^k E_i
$


#note()[
  Every *example is used as a validation example exactly once*. This differs
  from repeated hold-out, where the same example can be selected for validation multiple times.
]

== Leave-one-out cross-validation

Leave-one-out cross-validation is the special case in which the *number of
folds equals the number of examples*. For a dataset with $N$ examples, we perform $N$ iterations. In each iteration, *one example* is used as the *validation set* and the remaining *$N-1$ examples* are used for *training*.

This method provides the largest possible training set at each iteration, but the *estimate* can have *high variance* because each validation set contains only
one example.

#warning()[
  We should *not use* the *training error* *as an estimate* of the generalization
  error. The model has been fitted to the training set, so its error on that
  set is optimistically low. This is a typical effect of overfitting.
]

== ROC curve

The Receiver Operating Characteristic (ROC) curve represents the performance
of a binary classifier as its discrimination threshold varies. It plots the *True Positive Rate* (TPR) against the *False Positive Rate* (FPR) for different
thresholds:
$
  "TPR" = "TP" / ("TP" + "FN"), quad "FPR" = "FP" / ("FP" + "TN")
$

The ROC curve can also be interpreted as a *ranking evaluation*: it measures how
well the classifier ranks positive examples above negative examples.
The *Area Under the Curve* (AUC) summarizes this behavior in a single value between $0$ and $1$:
- *AUC = 1*: Perfect ranking.
- *AUC = 0.5*: Random ranking (corresponds to the diagonal line).
- *AUC < 0.5*: Worse than random (inverting the predictions would yield a better model).

#figure(
  caption: [Interpretation of different AUC values through ROC curves.],
)[
  #align(center)[
    #cetz.canvas(length: 0.7cm, padding: 0.2cm, {
      import cetz.draw: *

      let draw-roc-panel(origin, title, auc, curve, curve-paint) = {
        let ox = origin.at(0)
        let oy = origin.at(1)
        let size = 3.6

        // Axes: the horizontal axis is FPR and the vertical axis is TPR.
        line((ox, oy), (ox + size, oy), stroke: (paint: black, thickness: 0.8pt))
        line((ox, oy), (ox, oy + size), stroke: (paint: black, thickness: 0.8pt))
        line((ox + size, oy), (ox + size - 0.18, oy + 0.08), stroke: (paint: black, thickness: 0.8pt))
        line((ox, oy + size), (ox + 0.08, oy + size - 0.18), stroke: (paint: black, thickness: 0.8pt))

        // The diagonal is the random-classifier reference.
        line((ox, oy), (ox + size, oy + size), stroke: (paint: gray, thickness: 0.7pt, dash: "dashed"))

        // A cubic Bézier curve gives the ROC its characteristic smooth shape.
        let start = curve.at(0)
        let ctrl-1 = curve.at(1)
        let ctrl-2 = curve.at(2)
        let end = curve.at(3)
        bezier(
          (ox + start.at(0) * size, oy + start.at(1) * size),
          (ox + end.at(0) * size, oy + end.at(1) * size),
          (ox + ctrl-1.at(0) * size, oy + ctrl-1.at(1) * size),
          (ox + ctrl-2.at(0) * size, oy + ctrl-2.at(1) * size),
          stroke: (paint: curve-paint, thickness: 1.8pt),
        )

        content((ox + 0.2, oy + size + 0.45), text(size: 9pt)[#title])
        content((ox + 1.2, oy - 0.65), text(size: 8pt)[FPR])
        content((ox - 0.6, oy + 1.4), text(size: 8pt)[TPR], angle: 90deg)
        content((ox + 1.1, oy + size + 0.05), text(size: 8pt)[AUC = #auc])
        content((ox - 0.12, oy - 0.25), text(size: 7pt)[0])
        content((ox + size - 0.08, oy - 0.25), text(size: 7pt)[1])
        content((ox - 0.3, oy - 0.05), text(size: 7pt)[0])
        content((ox - 0.3, oy + size - 0.05), text(size: 7pt)[1])
      }

      draw-roc-panel(
        (1.5, 1.0),
        [Perfect classifier],
        [1],
        ((0, 0), (0.02, 0.72), (0.16, 0.98), (1, 1)),
        teal,
      )
      draw-roc-panel(
        (7.0, 1.0),
        [Random classifier],
        [0.5],
        ((0, 0), (0.20, 0.12), (0.80, 0.88), (1, 1)),
        orange,
      )
      draw-roc-panel(
        (12.5, 1.0),
        [Worse than random],
        [0],
        ((0, 0), (0.72, 0.02), (0.98, 0.16), (1, 1)),
        maroon,
      )
    })
  ]
]

A *good* ROC curve is bowed towards the top-left corner, indicating a high TPR and a
low FPR across various thresholds. A curve close to the diagonal corresponds to performance close to
*random classification*.
