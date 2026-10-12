#import "../template.typ": *

= Deep Learning

//recuperare intro da slide

The main problem that deep learining address is the *vanish gradient* or the *exploding gradient*. For example, if the gradient is too small, the weights will not be updated and the model will not learn. In this case we can use the *ReLU* activation function, it reuturns the maximum between 0 and the input value. This way, the gradient will be 1 for positive values and 0 for negative values.

== CNN (Convolutional Neural Network)

We have local conections between neurons in a hidden layer (expect to FNN). By using padding pixel ce can accept variations in the input image.

Convulution is basically a vector $s$ that is obtained by multiplyng a kernel $w$ and $x$ wich is the input image. Since is a continuos function we can represent it as a sum:
$
  s(t) = (x * w)(t) = sum_{a=-infinity}^{infinity} x(a) w(t-a)
$

Since the immage are usually a 2D matrix, we can represent the convolution as a sum on the two dimensions (row and column):
$
  S(i,j) = (I*K)(i,j) = sum_m sum_n I(m,n) K(i-m, j-n)
$
#note()[
  The convulution is commutative, so we can flip the kernel, we can have the convultion in the opposite way $K(I * K) = J(K * I)$
]

=== Cross-correlation

The software library usually use *cross-correlation* instead of convolution, since the kernel is not flipped. The two approaches, but is more pratical use cross-correlation since we move on the right instead of the left:
$
  S(i,j) = (I*K)(i,j) = sum_m sum_n I(i+m, j+n) K(m,n)
$

#example()[
  Given the formula:
  $
    S(K * I)(i) = sum_m I(i+m) K(m)
  $


  If we have:
  - I = [1,3,1,2,1]
  - K = [1,2,1]
  We want to compute S[0]. We need to move m from 0 to 2, since the kernel has length 3. So we have:
  $
    S[0] = I[0]*K[0] + I[1]*K[1] + I[2]*K[2] = 1*1 + 3*2 + 1*1 = 8
  $
  We cant to compute S[1], we need to shift K to the right by 1, so we have:
  $
    S[1] = I[1]*K[0] + I[2]*K[1] + I[3]*K[2] = 3*1 + 1*2 + 2*1 = 7
  $
  In the next step we move the kernel in the position 2, so we have:
  $
    S[2] = I[2]*K[0] + I[3]*K[1] + I[4]*K[2] = 1*1 + 2*2 + 1*1 = 6
  $
]

// add convulution example from slides

=== Sparse connectivity

In the classical FNN each neuron is connected to all the neurons in the previous layer, we have a lot of connections and a lot of weights.

In convolution we have a *sparce connectivity*, since each neuron is connected only to a small region of the input image. This region depends on the *size of the kernel*. This way we have less weights and less connections, and we can learn more complex features.

//aggiunger immagine

#note()[
  The sparse connectivity does not exclude the gloabl connectivity. Since a node in the high layer is it like is connected to all the nodes in the input layer
]

=== Parameter sharing

If we consider a FNN the parameter are specifically for each connection, so we have a lot of parameters.

In convolution we have *parameter sharing*, since the same kernel is used for all the neurons in the layer. In the convulution we move the kernell across the input, so we have the same weights for all the neurons in the layer. If the kernel has size 3x3, we have 9 weights for all the neurons in the layer.

This way we have less parameters and less connections, and we can learn more complex features.

=== Pooling layer

They introduce an invariant transformation and abstraction. The polling layeri is used to reduce the dimensionality and capture the most important features. The pooling layer is usually used after a convolution layer.

After the pooling layer we applied a activation function, usually the ReLU. The pooling layer is used to reduce the dimensionality and capture the most important features.

=== Architecture

In a CNN we have:
- Input layer: the input image. or the vector
- Convolution layer: the convolution operation is applied to the input image, and the output is a feature map.
- Detection layer: the feature map is passed through an activation function, usually the ReLU.
- Pooling layer: the pooling operation is applied to the feature map, and the output is a pooled feature map.

Also CNN use the backpropagation algorithm (adpted to the convolution operation) to update the weights of the kernel. The backpropagation algorithm is used to minimize the loss function, and it is used to update the weights of the kernel.

We also use the stochastic gradient descent (SGD) algorithm to update the weights of the kernel. The SGD algorithm is used to minimize the loss function, and it is used to update the weights of the kernel. A less expensive algorithm is the *mini-batch* gradient descent, that uses a small batch of data to update the weights of the kernel. The weights are updated after each batch, and the process is repeated until the loss function converges.

=== Regularization

This techniques is used to get a more general model, and avoid overfitting. One of them are the *dropout* and the *weight decay*.

The dropout is a technique that randomly sets a fraction of the input neurons to 0 during training.
In this way we can simplify the computation and avoid overfitting. The droput is applied to the final layer of the network, and it is used to reduce the co-adaptation of the neurons.

The main idea is to have an *ensemble* of models, and each model is trained on a different subset of the data. The dropout is used to randomly select a subset of the neurons to be dropped out during training. This way we can have a more general model, and avoid overfitting.

= Prediction of Genetic Variants

The main problem is the SNPs (Single Nucleotide Polymorphisms) prediction. The SNPs are the most common type of genetic variation, and they are associated with many diseases. The SNPs are usually located in the non-coding regions of the genome, and they can affect the gene expression.

SNP occur on avarage every 300 nucleotides, and they are usually biallelic. We have an order of billion SNPs in the human genome. A single human can have milion of nucleotide with a variation.

The variability in the *phenotype* is due to the variability in the SNPs.

#note()[
  Phenotype is the set of *observable characteristics* of an individual, and it is determined by the genotype and the environment. The genotype is the set of genes that an individual has, and it is determined by the DNA sequence. The environment is the set of external factors that can affect the phenotype, such as diet, lifestyle, and exposure to toxins.
]

A lot of desies are associated by DNA alteration. They can be inherited or acquired. The inherited diseases are caused by mutations in the germline cells, and they can be passed from parents to offspring. The acquired diseases are caused by mutations in the somatic cells, and they cannot be passed from parents to offspring.

It is crucial to:
- *detect genetic variants*: this mutation are studied by a big genetic project, the 1000 Genomes Project. The project aims to identify genetic variants in the human genome

- *predict their effect on the phenotype*: this is usefull to understand the genetic basis of diseases, and to develop new therapies and treatments for diseases.

- *understand their role in the development of diseases*: this is usefull to develop new therapies and treatments for diseases. If we found a genetic variant that is associated with a disease, we can try to study specific molecules that can interact with the protein encoded by the gene, and we can try to develop new drugs that can target the protein.

=== Variants

Variant can occured in coding and non-coding regions of the genome. The regulatory elements are usually located in the non-coding regions of the genome, and they can affect the gene expression. This type of mutation can be pathogenic.

=== Histone modification

Reminding that promoters are the region that can activate and disativate the transcription of a gene, and enhancers are the region that can increase the transcription of a gene. It could happen that a variant in the promoter can affect the transcription, we can have no mRNA produced and no protein produced.

Enanchers can be located far away from the TSS (Transcription Start Site), and they can affect the transcription of a gene by interacting with the promoter. Also variant in the enancher can disativate the transcription of a gene

Silencer have the opposite effect of enhancers, they can decrease the transcription of a gene. Also variant in the silencer can increase the transcription of a gene.

Insulator are the region that can block the interaction between enhancers and promoters, and they can isolate an enhancer or a silencer by putting a barrier between them. Also variant in the insulator can affect the transcription of a gene.

#note()[
  Insulator prevent the expansion of heterochromatin to euchromatin. In the heterochromatin the DNA is tightly packed around histones, and it is transcriptionally inactive. In the euchromatin the DNA is loosely packed around histones, and it is transcriptionally active.
]

//aggiungere immagine da slide

== Machine learning formulation
- Input:
  - A set of genetic variants (example)
  - A set of annotation associated with the genetic variants (features)
  - A set of labels associated with the genetic variants (labels)

We can to predict the effect of the genetic variants on the phenotype, and we can to understand their role in the development of diseases. It's a sort of classification problem, that it's called *prioritization problem*.

//aggiungere Characteriation of regulatory variants immagine

= DeepSEA

Deep neural netwrok for prediction epegenetic features and pathogenic variant from DNA sequence.

By considering non coding region variants, we want to predict the effect on the phenotype variation. We also want to predict if this variant is pathogenic or not.

//guardare che non ho capito

*Motif* is a sequence of nucleotides wich can be bind to a promoter region. We can have:
- Gain of motif: the variant create a new motif that can bind to a promoter region, and it can increase the transcription of a gene.

- Loss of motif: the variant destroy a motif that can bind to a promoter region, and it can decrease the transcription of a gene.

#note()[
  If we have a mutation in the promoter region we can alter the expression of the gene, and we can have a gain or loss of function.
]

The *logo representation* of a motif is a graphical representation of the nucleotide frequency at each position in the motif. The height of each letter represents the frequency of the nucleotide at that position, and the width of each letter represents the information content of the nucleotide at that position.

//rguardare
=== Post-transcriptional regulation

Messages RNA can bind to ncRNA and can build a traslation.

== Goal

Given a sequence un DNA centered in a correspondance of a specific variant. We also have sourranding context.

We want to:
- Predict TF binding, histone modification in multiple cell and tissue types
- Predict variant functionality

it's a supervised learning and it's a multi label classification problem.
