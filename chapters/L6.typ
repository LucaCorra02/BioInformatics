#import "../template.typ": *

= Deep Learning

Deep learning models are neural networks with multiple layers. They can learn complex hierarchical representations of data and have proven successful across a wide range of applications, including genomic medicine and computational biology.

The basic building block of a neural network is the *neuron* (inspired by the biological neuron and formalized in early models such as the *perceptron*), which computes a *weighted sum* of its inputs and applies a *nonlinear activation function*:
$
  "Weighted sum" & = z = sum_(i=1)^(n) w_i x_i + b \
    "Activation" & = y = f(z)
$
where $x_i$ are the inputs, $w_i$ are the synaptic weights, $b$ (often denoted as $w_0$) is the bias term, and $f$ is the activation function (e.g., step function, sigmoid, or ReLU).

The weights are learned during training by minimizing an error (or loss) function $E$ using *backpropagation* and an optimization algorithm, such as *stochastic gradient descent (SGD)*. During backpropagation, we compute the gradient of the loss function with respect to each weight $w_i$ using the chain rule, and update the weights according to a learning rate $eta$:
$
  (delta E) / (delta w_i) = mr((delta E) / (delta y)) * mb((delta y) / (delta z)) * mg((delta z) / (delta w_i))
$
where:
- $mr((delta E) / (delta y))$ quantifies the error with respect to the output of the specific neuron. If the neuron is in the output layer, it depends directly on the difference between the predicted and true values. If it is in a hidden layer, it is computed recursively as a weighted sum of the errors propagated backward from the neurons in the next layer.

- $mb((delta y) / (delta z))$ is the derivative of the activation function $f'(z)$. It measures how much the neuron's output changes in response to a change in its internal potential $z$.

- $mg((delta z) / (delta w_i))$ is the derivative of the weighted sum with respect to the weight $w_i$ (which equals the corresponding input $x_i$). It measures how much the pre-activation input $z$ changes with respect to that specific weight.

Once the gradient is computed, each weight is updated in the direction opposite to the gradient:
$
  Delta w_i = -eta (delta E) / (delta w_i), quad w_i <- w_i + Delta w_i
$

Deep fully connected neural networks (Multi-Layer Perceptrons, or MLPs) can suffer from the *vanishing-gradient* and *exploding-gradient* problems:
- *Vanishing gradient*: if the gradients become *too small* as they are propagated backward through many layers, the weights in the earlier layers are barely updated, and the model may fail to learn.
- *Exploding gradient*: if the gradients become *too large*, the weight updates become excessively large, leading to numerical instability and divergence during training.

#note()[
  The *ReLU* (Rectified Linear Unit) activation function is defined as $f(x) = max(0, x)$:

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
  ReLU helps *prevent saturation* for positive inputs. Its derivative is $1$ for positive values ($x > 0$) and $0$ for negative values ($x < 0$). Since the derivative $mb((delta y) / (delta z))$ is constantly equal to $1$ for positive inputs, it helps mitigate the vanishing-gradient problem. However, it can lead to the *dying ReLU* problem, where neurons become permanently inactive and stop learning if their inputs consistently fall into the negative region.
]

== CNN (Convolutional Neural Network)

In a Convolutional Neural Network (CNN), neurons in a layer are only locally connected to small regions of the previous layer, unlike in a fully connected neural network (FNN/MLP) where every unit is connected to all units in the preceding layer. Furthermore, *padding* can be applied to preserve the spatial dimensions of the feature maps and allow the network to properly process values near the borders of the input.

In the discrete one-dimensional case, the convolution of an input $x$ with a kernel (or filter) $w$ produces a feature map $s$ by sliding the kernel over the input and computing a weighted sum at each position:
$
  s(t) = (x * w)(t) = sum_(a=-infinity)^(infinity) x(a) w(t-a)
$

Since images and spatial data are typically represented as two-dimensional matrices, the 2D discrete convolution of an input $I$ with a kernel $K$ is written as a sum over rows and columns:
$
  S(i,j) = (I * K)(i,j) = sum_m sum_n I(m,n) K(i-m, j-n)
$

#note()[
  Convolution is *commutative*: $I * K = K * I$, meaning we can equivalently write:
  $
    S(i,j) = (K * I)(i,j) = sum_m sum_n I(i-m, j-n) K(m,n)
  $
  In the discrete mathematical definition, the kernel is effectively flipped relative to the input because as the indices $m$ and $n$ increase, the indices into the kernel $(i-m, j-n)$ decrease.
]

=== Cross-correlation

Deep learning libraries usually implement *cross-correlation* rather than strict mathematical convolution, meaning the kernel slides over the input *without* being flipped. In two dimensions, it is defined as:
$
  S(i,j) = (I * K)(i,j) = sum_m sum_n I(i+m, j+n) K(m,n)
$

#example()[
  Consider the one-dimensional cross-correlation formula:
  $
    S(i) = sum_m I(i+m) K(m)
  $

  Suppose we have the following 1D input $I$ and kernel $K$:
  - $I = [1, 3, 1, 2, 1]$
  - $K = [1, 2, 1]$

  To compute $S[0]$, we let the index $m$ range from $0$ to $2$, since the kernel has length $3$:
  $
    S[0] = I[0] dot K[0] + I[1] dot K[1] + I[2] dot K[2] = 1 dot 1 + 3 dot 2 + 1 dot 1 = 8
  $
  To compute $S[1]$, we shift the kernel to the right by $1$ position (stride $1$):
  $
    S[1] = I[1] dot K[0] + I[2] dot K[1] + I[3] dot K[2] = 3 dot 1 + 1 dot 2 + 2 dot 1 = 7
  $
  In the next step, we shift the kernel to position $2$:
  $
    S[2] = I[2] dot K[0] + I[3] dot K[1] + I[4] dot K[2] = 1 dot 1 + 2 dot 2 + 1 dot 1 = 6
  $
]

=== Sparse connectivity

In a classical FNN (or MLP), every neuron is connected to every neuron in the previous layer, resulting in a very large number of connections and parameters, as well as high computational complexity.

In a convolutional layer, we achieve *sparse connectivity* (or sparse interactions) by making the kernel smaller than the input: each neuron is connected only to a small local region of the previous layer, whose size is determined by the kernel dimensions. Consequently, the layer requires far fewer parameters and operations, while stacking multiple layers allows the network to combine low-level local features into higher-level, increasingly global abstractions.

#note()[
  Sparse connectivity does not prevent the network from capturing global information. Through successive convolutional layers, the *receptive field* of a neuron in a deeper layer grows, eventually covering a large portion—or the entirety—of the original input.
]

=== Parameter sharing

In a standard FNN, each weight is used exactly once to compute the output of a layer, as it is tied to a specific connection between two neurons.

In a convolutional layer, we have *parameter sharing*: the exact same kernel weights are applied across all spatial positions of the input. For instance, if a 2D kernel has size $3 times 3$, the network learns only $9$ weights per input channel (plus typically one bias term per output channel), rather than learning a separate set of weights for every spatial location.

This drastically reduces memory usage and the total number of parameters, and makes the representation *equivariant to translation*: shifting the input shifts the resulting feature map in the same way.

=== Pooling layer

*Pooling layers* introduce a degree of local *translation invariance* and spatial abstraction. They reduce the spatial dimensions of a feature map by replacing the output at a given location with a summary statistic of the nearby outputs, such as the maximum value (*max pooling*) or the average value (*average pooling*) within a local window.

In a typical CNN block, a nonlinear activation function (usually ReLU, acting as a detector stage) is applied immediately after the linear convolution operation, and the pooling operation is applied afterward to downsample the resulting activations.

=== Architecture and Training

A typical CNN architecture is composed of a sequence of stages (or layers):
- *Input layer*: receives the raw input, such as an image, a 1D biological sequence, or another spatially structured tensor.
- *Convolutional layer* (convolution stage): applies a set of learnable kernels to the input to extract local features and produce feature maps (affine transformation).
- *Activation layer* (detector stage): applies a nonlinear activation function, usually ReLU, element-wise to the feature maps.
- *Pooling layer* (pooling stage): downsamples the feature maps to reduce spatial dimensions and provide invariance to small local shifts.

During training, *backpropagation* (adapted to account for weight sharing and pooling operations) computes the gradients of the loss function with respect to the kernel weights. An optimization algorithm then updates the parameters:
- Pure *Stochastic Gradient Descent (SGD)* computes the gradient and updates the weights using a single training example at a time.
- *Mini-batch gradient descent* computes the gradient over a small subset (mini-batch) of training examples at each step. Mini-batch updates are computationally much more efficient and provide more stable gradient estimates than single-example updates, enabling fast training of large deep networks over multiple iterations or epochs.

=== Regularization

Regularization techniques are employed to improve generalization on unseen data and reduce *overfitting*. Common strategies include *weight decay* ($L_1$ and $L_2$ norm regularization) and *dropout*:
- *Weight decay* penalizes large parameter values by adding a regularization term (such as the $L_2$ norm or $L_1$ norm of the weights) to the loss function, encouraging simpler models.
- *Dropout* randomly sets a fraction of neuron activations to zero during each training step. It is typically applied to hidden layers rather than the final output layer. At inference (test) time, dropout is disabled and the activations are scaled appropriately to account for the full network being active.

Dropout prevents the *co-adaptation* of neurons (forcing units to learn robust features independently) and can be interpreted as training an approximate *ensemble of exponentially many subnetworks* that share parameters.

= Prediction of Genetic Variants

A major challenge in genomic medicine and computational biology is the prediction and functional interpretation of *SNPs (Single Nucleotide Polymorphisms)*. SNPs are the most common type of genetic variation among individuals. Notably, the vast majority of SNPs are located in *non-coding regions* of the genome, where they do not directly alter protein sequences but can affect gene regulation and gene expression.

SNPs are typically biallelic (having two possible alleles at a specific locus), although other types of structural and sequence variants also exist. Across the human population, tens of millions of SNPs have been catalogued. A single individual typically carries several million variants compared to a reference human genome; the exact count depends on the individual's ancestry and the variant-calling pipeline used.

Part of the variability observed in the *phenotype* across individuals is explained by genetic variation (including SNPs), while the remaining variability arises from environmental factors and gene-environment interactions.

#note()[
  The *phenotype* is the set of observable characteristics or traits of an individual (including morphology, physiological properties, and disease susceptibility), and it is determined by the interplay between the *genotype* and the *environment*. The *genotype* is the genetic makeup of an organism, encoded in its DNA sequence. The *environment* encompasses all external factors that can influence the phenotype, such as diet, lifestyle, and exposure to toxins or pathogens.
]

Many human diseases are associated with alterations in the DNA sequence. These variants can be:
- *Inherited (germline) variants*: present in germ cells (egg or sperm) and passed from parents to offspring, present in virtually all cells of the body.
- *Acquired (somatic) variants*: arise spontaneously in somatic cells during an individual's lifetime (e.g., due to replication errors or environmental mutagens, as in cancer) and are not passed to offspring.

In genomic medicine, three key objectives are to:
- *Detect genetic variants*: large-scale sequencing initiatives, such as the *1000 Genomes Project*, catalogue genetic variation across diverse human populations.
- *Predict their effects on the phenotype*: assessing the functional impact of variants helps uncover the genetic basis of complex traits and diseases, guiding the development of new therapies.
- *Understand their role in disease*: when a variant is associated with a pathology, characterizing its underlying molecular mechanism allows researchers to identify potential therapeutic targets.

=== Variants in Coding and Non-Coding Regions

Genetic variants can occur in both coding and non-coding regions of the genome. While coding variants can directly alter the amino acid sequence of a protein, *regulatory elements* are predominantly located in non-coding regions and control when, where, and how much a gene is expressed. Consequently, a non-coding variant falling within a regulatory element can be pathogenic, though its exact impact depends heavily on the genomic context and cell type.

=== Regulatory Elements and Histone Modifications

Gene transcription is tightly controlled by interactions between DNA regulatory elements and chromatin structure:
- *Promoters*: regulatory regions located immediately upstream of *Transcription Start Sites (TSSs)* where the transcription machinery (including RNA polymerase and general transcription factors) assembles to initiate transcription. A variant in a promoter can disrupt transcription initiation; in extreme cases, little or no mRNA and protein are produced.
- *Histone modifications*: chemical modifications to histone proteins (around which DNA is wrapped) alter *chromatin accessibility*, determining whether regulatory DNA regions are physically accessible to transcription factors and the transcriptional machinery.
- *Enhancers*: distal regulatory elements that can be located far from the TSS (upstream, downstream, or within introns) and boost transcription rates by physically interacting with the promoter via three-dimensional chromatin looping. Variants within an enhancer can impair or alter this activation.
- *Silencers*: regulatory elements that have the opposite effect of enhancers. They bind transcriptional repressors to decrease or silence gene transcription. A variant in a silencer can weaken this repression, potentially leading to an abnormal increase in transcription.
- *Insulators*: boundary elements that block inappropriate interactions between enhancers and promoters of neighboring genes, isolating regulatory domains. A variant in an insulator can disrupt this boundary, causing aberrant gene activation or repression.

#note()[
  Insulators also act as barriers that prevent the spread of *heterochromatin* into *euchromatin*:
  - In *heterochromatin*, DNA is tightly packed around histones and is generally inaccessible for transcription (gene silencing).
  - In *euchromatin*, DNA is more loosely packed and open, making it accessible to the transcriptional machinery for active gene expression.
]

=== Post-transcriptional Regulation

Regulation also occurs after DNA is transcribed into RNA. *Messenger RNA (mRNA)* can interact with RNA-binding proteins and *non-coding RNAs (ncRNAs)*, such as *microRNAs (miRNAs)*, which bind to specific target sites on the mRNA to regulate its stability, degradation, cellular localization, or translation efficiency into protein.

== Machine Learning Formulation

The problem of interpreting genetic variants can be framed as a supervised machine learning task:
- *Input*:
  - A set of genetic variants (training/testing *examples*).
  - A set of genomic and epigenomic annotations or raw sequence contexts associated with each variant (*features*).
  - A set of known functional or clinical outcomes associated with the variants (*labels / targets*).

The goal is to predict the functional or phenotypic effects of unseen genetic variants and assess their potential role in disease. Depending on the setup, this is formulated as a binary/multi-class *classification* task or a *ranking* task, commonly referred to as *variant prioritization*.

= DeepSEA

*DeepSEA* (Deep learning-based Sequence Analyzer) is a deep convolutional neural network designed to predict epigenetic and regulatory features directly from raw DNA sequences, and to estimate the functional effects of non-coding sequence variants (Zhou and Troyanskaya, *Nature Methods*, 2015).

For variants located in non-coding regions, DeepSEA estimates quantitative changes in regulatory signals—such as *transcription-factor (TF) binding*, *DNase I hypersensitivity* (chromatin accessibility), and *histone marks*—by comparing predictions for the reference sequence and the mutated (alternative) sequence. While these predictions provide strong functional evidence about how a variant perturbs regulatory activity, they do not by themselves prove clinical pathogenicity, which requires further biological and clinical integration.

=== Sequence Motifs

A *motif* is a short, recurring DNA sequence pattern that is specifically recognized and bound by a DNA-binding protein, such as a transcription factor. Motifs are not restricted to promoters; they frequently occur within enhancers, silencers, and other regulatory regions. When a genetic variant occurs within or near a regulatory region, two main mechanistic outcomes are possible:
- *Gain of motif*: a variant creates a new binding site or strengthens an existing weak motif, increasing the binding affinity of a transcription factor and potentially altering transcription.
- *Loss of motif*: a variant disrupts or weakens an existing motif, reducing or abolishing transcription factor binding and altering transcription in the opposite direction.

#note()[
  A single nucleotide mutation in a promoter or enhancer can significantly alter gene expression by causing either a gain or a loss of regulatory binding activity.
]

The *sequence logo* is a standard graphical representation of a sequence motif that illustrates the nucleotide conservation at each position:
- The *total height* of a stack at a given position represents the *information content* (conservation) of that position, measured in bits.
- The *relative height* of each letter (A, C, G, T) within a stack represents the observed *frequency* (or probability) of that specific nucleotide at that position.

== Goal of DeepSEA

Given a DNA sequence window (e.g., $1000$ base pairs) centered on a specific genetic variant, thereby capturing both the variant and its surrounding genomic context, the goals are to:
1. Accurately predict large-scale epigenetic profiles—specifically *transcription-factor binding*, *chromatin accessibility*, and *histone modifications*—across multiple human cell and tissue types directly from the DNA sequence.
2. Predict the *functional effect of the variant* by evaluating the difference in predicted probabilities between the reference allele and the alternative allele.

From a machine learning perspective, predicting the presence or absence of hundreds of regulatory features simultaneously from a DNA sequence is formulated as a *supervised multi-label classification problem* (where each output neuron predicts the probability of a specific epigenetic event in a specific cell type).