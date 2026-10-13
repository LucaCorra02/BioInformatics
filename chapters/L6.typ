#import "../template.typ": *

= Deep Learning

Deep learning model are neural networks with multiple layers. They can learn complex representations of data and have been successful in many applications.

The basic building block of a neural network is the *neuron*, which computes a *weighted sum* of its inputs and applies a *nonlinear activation function*:
$
  "Weigheted sum" & = z = sum_(i=1)^(n) w_i x_i + b \
     "Activation" & = y = f(z)
$
The weights are learned during training using backpropagation and an optimization algorithm, such as stochastic gradient descent (SGD). During the backpropagation we compute the gradient of the loss function with respect to the weights and update them accordingly to a learning rate:
$
  (delta E) / (delta w) = mr((delta E) / (delta y)) * mb((delta y) / (delta z)) * mg((delta z) / (delta w_i))
$
where:
- $mr((delta E) / (delta y))$ = it quantifies the error on the output of this specific neuron. If the neuron is in the output layer, it is the difference between the predicted and true values. If it is in a hidden layer, it is computed as a weighted sum of the errors of the neurons in the next layer.

- $mb((delta y) / (delta z))$ = it is the derivative of the activation function. It quantifies how much the output of the neuron changes with respect to its input.

- $mg((delta z) / (delta w_i))$ = it is the derivative of the weighted sum with respect to the weight. It quantifies how much the input of the neuron changes with respect to its weight.

Deep learning models can suffer from the *vanishing-gradient* and
*exploding-gradient* problems:
- If the gradient becomes *too small*, the weights are barely updated and the model may fail to learn

- if it becomes *too large*, the updates can become unstable.




#note()[
  The *ReLU* activation function $f(x) = max(0, x)$

  #figure()[
    #align(center)[
      #cetz.canvas(length: 0.75cm, padding: 0.25cm, {
        import cetz.draw: *

        let origin = (4.0, 1.0)
        let x-end = (8.0, 1.0)
        let y-end = (4.0, 5.0)

        // Coordinate axes.
        line(origin, x-end, stroke: (paint: black, thickness: 0.8pt))
        line(origin, y-end, stroke: (paint: black, thickness: 0.8pt))
        line(x-end, (7.7, 1.12), stroke: (paint: black, thickness: 0.8pt))
        line(y-end, (3.88, 4.7), stroke: (paint: black, thickness: 0.8pt))

        // The two branches of ReLU: zero for x < 0 and y = x for x >= 0.
        line((1.0, 1.0), origin, stroke: (paint: teal, thickness: 2pt))
        line(origin, (7.0, 4.0), stroke: (paint: teal, thickness: 2pt))
        circle(origin, radius: 0.09, fill: teal, stroke: (paint: teal, thickness: 0.8pt))

        content((7.35, 0.55), text(size: 9pt)[$x$])
        content((3.45, 4.65), text(size: 9pt)[$f(x)$])
        content((3.7, 0.55), text(size: 8pt)[$0$])

        content((2.8, 3.8), text(size: 8pt)[$f(x) = x$])
        content((1.55, 1.25), text(size: 8pt)[$f(x) = 0$])
      })
    ]
  ]
  helps *reduce saturation* for positive inputs. Its derivative is $1$ for positive values and $0$ for negative values. Sinche the derivate $mb((delta y) / (delta z))$ is always $1$ for positive inputs, it helps mitigate the vanishing-gradient problem. However, it can lead to the *dying ReLU* problem, where neurons become inactive and stop learning if they consistently receive negative inputs.
]




== CNN (Convolutional Neural Network)

In a CNN, neurons in a layer are locally connected to small regions of the
previous layer, unlike in a fully connected neural network (FNN). Padding can
preserve the spatial dimensions of the feature maps and allow the network to
process pixels near the image borders.

In one dimension, the convolution of an input $x$ with a kernel $w$ is a
function $s$ obtained by sliding the kernel over the input and computing a
weighted sum:
$
  s(t) = (x * w)(t) = sum_{a=-infinity}^{infinity} x(a) w(t-a)
$

Since images are usually represented as two-dimensional matrices, the
convolution can be written as a sum over rows and columns:
$
  S(i,j) = (I*K)(i,j) = sum_m sum_n I(m,n) K(i-m, j-n)
$
#note()[
  Convolution is commutative: $I * K = K * I$. In the discrete formula, the
  kernel is effectively flipped because it is evaluated at $(i-m, j-n)$.
]

=== Cross-correlation

Deep-learning libraries usually implement *cross-correlation* rather than
mathematical convolution, because the kernel is not flipped. In two dimensions,
it can be written as:
$
  S(i,j) = sum_m sum_n I(i+m, j+n) K(m,n)
$

#example()[
  Given the cross-correlation formula:
  $
    S(i) = sum_m I(i+m) K(m)
  $


  If we have:
  - I = [1,3,1,2,1]
  - K = [1,2,1]
  We want to compute S[0]. We need to move m from 0 to 2, since the kernel has length 3. So we have:
  $
    S[0] = I[0]*K[0] + I[1]*K[1] + I[2]*K[2] = 1*1 + 3*2 + 1*1 = 8
  $
  To compute $S[1]$, we shift the kernel to the right by $1$:
  $
    S[1] = I[1]*K[0] + I[2]*K[1] + I[3]*K[2] = 3*1 + 1*2 + 2*1 = 7
  $
  In the next step we move the kernel in the position 2, so we have:
  $
    S[2] = I[2]*K[0] + I[3]*K[1] + I[4]*K[2] = 1*1 + 2*2 + 1*1 = 6
  $
]

=== Sparse connectivity

In a classical FNN, each neuron is connected to every neuron in the previous
layer, resulting in many connections and parameters.

In a convolutional layer, we have *sparse connectivity*: each neuron is
connected only to a small local region of the input. This region depends on the
kernel size. Consequently, the layer has fewer connections and parameters,
while successive layers can combine local features into increasingly global
ones.

#note()[
  Sparse connectivity does not prevent global information from being captured.
  Through successive convolutional layers, the receptive field of a neuron
  can eventually cover the entire input.
]

=== Parameter sharing

In an FNN, the parameters are specific to individual connections, so the
number of parameters can be large.

In a convolutional layer, we have *parameter sharing*: the same kernel is
applied at every spatial position. If the kernel has size $3 times 3$, it has
9 weights per input channel (plus, usually, one bias per output channel), not
9 separate weights for every neuron.

This reduces the number of parameters and makes the detector translation
equivariant: shifting the input shifts the feature map.

=== Pooling layer

Pooling layers introduce a degree of local translation invariance and
abstraction. They reduce the spatial dimensions of a feature map and retain
an aggregated summary, such as a maximum or an average. Pooling is often
applied after a convolution and its activation function.

An activation function, usually ReLU, is typically applied after the
convolution and before pooling, although the exact ordering can vary by
architecture.

=== Architecture

In a CNN, we typically have:
- *Input layer*: the input image or another spatially structured tensor.
- *Convolutional layer*: kernels are applied to the input, producing feature
  maps.
- *Activation layer*: a nonlinear activation function, usually ReLU, is
  applied to the feature maps.
- *Pooling layer*: a pooling operation reduces the spatial dimensions.

Backpropagation, adapted to the convolution operation, computes the gradients
of the loss with respect to the kernel weights. An optimization algorithm then
uses these gradients to update the weights. Stochastic gradient descent (SGD)
uses one training example per update, whereas *mini-batch gradient descent*
uses a small batch. Mini-batch updates are usually more computationally
efficient and stable than single-example updates; training continues for
multiple iterations or epochs.

=== Regularization

These techniques are used to improve generalization and reduce overfitting.
Examples include *dropout* and *weight decay*.

Dropout randomly sets a fraction of the activations to zero during training.
It is usually applied to hidden layers, not generally to the final output
layer. At inference time, dropout is disabled and the activations are scaled
according to the training convention.

Dropout reduces the co-adaptation of neurons and can be interpreted as an
approximate ensemble of subnetworks that share parameters. Weight decay
instead penalizes large weights, typically by adding an L2 regularization term
to the loss.

= Prediction of Genetic Variants

One important problem is the prediction and interpretation of SNPs (single
nucleotide polymorphisms). SNPs are a common type of genetic variation. Many
are located in non-coding regions, where they can affect gene regulation and
gene expression.

SNPs are usually biallelic, although other types of variants also exist. Across
the human population, there are millions of known SNPs. A single individual
typically carries several million variants relative to a reference genome;
the exact number depends on the population and on the variant-calling
procedure.

Some of the variability in the *phenotype* is due to genetic variation,
including variation at SNPs, while other variability is due to environmental
and other biological factors.

#note()[
  Phenotype is the set of *observable characteristics* of an individual, and it is determined by the genotype and the environment. The genotype is the set of genes that an individual has, and it is determined by the DNA sequence. The environment is the set of external factors that can affect the phenotype, such as diet, lifestyle, and exposure to toxins.
]

Many diseases are associated with alterations in DNA. These alterations can be
inherited or acquired. Inherited variants are present in the germline and can
be passed from parents to offspring. Acquired variants arise in somatic cells
and are generally not passed to offspring.

It is important to:
- *detect genetic variants*: projects such as the 1000 Genomes Project
  catalogue genetic variation in human populations;

- *predict their effects on the phenotype*: this helps us understand the
  genetic basis of disease and develop new therapies;

- *understand their role in disease*: if a variant is associated with a
  disease, we can investigate its molecular mechanism and identify possible
  therapeutic targets.

=== Variants

Variants can occur in both coding and non-coding regions of the genome.
Regulatory elements are often located in non-coding regions and can affect gene
expression. A variant in such an element can therefore be pathogenic, although
its effect depends on its genomic context and biological consequences.

=== Histone modification

Promoters are regulatory regions near transcription start sites (TSSs) that
help initiate transcription, whereas enhancers can increase transcription
from a distance. A variant in a promoter can alter transcription; in an
extreme case, little or no mRNA and protein may be produced.

Histone modifications can change chromatin accessibility and thereby influence
whether regulatory regions are available to the transcriptional machinery.

Enhancers can be located far from the TSS and can regulate a gene through
three-dimensional interactions with its promoter. A variant in an enhancer can
alter this regulation.

Silencers have the opposite effect of enhancers: they decrease transcription.
A variant in a silencer can weaken this repression and consequently increase
transcription.

Insulators are regulatory regions that can block interactions between enhancers
and promoters, thereby isolating a regulatory element from a gene. A variant
in an insulator can disrupt this boundary and affect transcription.

#note()[
  Insulators can also help prevent the spread of heterochromatin into
  euchromatin. In heterochromatin, DNA is tightly packed and generally less
  accessible for transcription. In euchromatin, DNA is more open and generally
  more accessible for transcription.
]

== Machine learning formulation
- Input:
  - a set of genetic variants (examples);
  - a set of annotations associated with the variants (features);
  - a set of labels associated with the variants (targets).

The goal is to predict the effects of genetic variants on the phenotype and to
understand their role in disease. This can be formulated as a classification
or ranking task, often called *variant prioritization*.

= DeepSEA

DeepSEA is a deep neural network for predicting epigenetic features from DNA
sequence and for estimating the effects of sequence variants.

For variants in non-coding regions, the model can estimate changes in
regulatory signals, such as transcription-factor binding and chromatin
accessibility. These predictions can provide evidence about possible effects
on phenotype, but they do not by themselves establish that a variant is
pathogenic.

*Motif* is a short sequence pattern recognized by a DNA-binding protein, such
as a transcription factor. A motif need not be located in a promoter; it can
also occur in an enhancer or another regulatory region. Two possibilities are:
- *gain of motif*: a variant creates or strengthens a motif that can be
  recognized by a transcription factor, potentially changing transcription;

- *loss of motif*: a variant disrupts or weakens a motif, potentially
  changing transcription in the opposite direction.

#note()[
  A mutation in a promoter can alter gene expression and can result in a gain
  or loss of regulatory activity.
]

The *sequence-logo representation* of a motif is a graphical representation of
the nucleotide distribution at each position. The total height of a column
represents its information content, while the relative height of each letter
represents the frequency of that nucleotide at that position.
=== Post-transcriptional regulation

Messenger RNA (mRNA) can interact with non-coding RNAs (ncRNAs), such as
microRNAs, which can affect mRNA stability, degradation, localization, or
translation.

== Goal

Given a DNA sequence centered on a specific variant, together with its
surrounding context, we want to:

- predict transcription-factor binding and histone modifications in multiple
  cell and tissue types;
- predict the functional effect of the variant.

This is a supervised-learning problem and, when several regulatory features
are predicted simultaneously, it is a multi-label classification problem.
