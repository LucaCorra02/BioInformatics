#import "../template.typ": *

= Data in bioinformatics

Bioinformatics works with several kinds of biological data. The most common
examples are:
- *Sequences*: DNA, RNA, and protein sequences are represented as strings of
  symbols. Each symbol denotes a nucleotide or an amino acid.
- *Gene-expression data*: these data are usually represented as matrices. The
  rows correspond to genes (or other measured features), the columns correspond
  to samples or experimental conditions, and each entry is an expression
  measurement.
- *Protein-interaction networks*: these data are represented as graphs. Nodes
  denote proteins and edges denote physical or functional interactions.

== DNA and RNA sequences

DNA sequences can be very long. The human haploid genome contains approximately
3.2 billion base pairs. RNA molecules are generally shorter than chromosomes,
although some transcripts can still be very long.

#note()[
  RNA is chemically less stable than DNA and is more susceptible to degradation
  by ribonucleases. For this reason, RNA samples require careful handling and
  are often converted into complementary DNA (cDNA) for library preparation
  and sequencing.
]

The conversion of RNA into cDNA is performed by *reverse transcription*, which
uses a reverse-transcriptase enzyme. This reaction is not the reverse of
transcription in a strict biochemical sense: transcription produces RNA from a
DNA template, whereas reverse transcription produces DNA from an RNA template.

Modern sequencing technologies read relatively short fragments, or *reads*,
rather than an entire chromosome in one operation. A sequencing experiment
therefore produces many overlapping reads. Computational methods align the
reads to a reference genome or assemble them from their overlaps. Genome
assembly is challenging because of repetitive regions, sequencing errors, and
uneven coverage; it is not generally an unsolved problem, but high-quality
assemblies remain difficult for some organisms and genomic regions.

=== Population data

Population genomics compares genomic data from many individuals. It can reveal
genetic variation and help identify variants associated with disease risk,
treatment response, or other phenotypes.

Genomes from different human populations are highly similar, but they differ at
many positions. A *single-nucleotide polymorphism* (SNP) is a variation at one
nucleotide position that is common enough to be considered polymorphic in a
population. Other types of variation include insertions, deletions, and
structural variants.

Most genetic variation is neutral or has a small effect. Some variants are
beneficial, while others are pathogenic or increase susceptibility to a
disease. Studying this variation helps us understand evolution and disease
mechanisms and can support the development of diagnostic tests and therapies.

== Gene expression

*Gene expression* is the process by which the information in a gene is used to
produce a functional product, such as an RNA molecule or a protein. In many
experiments, expression is estimated by measuring the abundance of mRNA
transcripts in a cell or tissue. Expression levels can vary with cell type,
developmental stage, environmental conditions, and disease state.

Two widely used approaches for measuring transcript abundance are
*microarrays* and *RNA sequencing* (RNA-seq).

=== Microarrays

A microarray measures the abundance of thousands of known transcripts at the
same time. The array contains many short DNA probes, each designed to
hybridize with a particular target sequence. RNA is extracted from the sample,
converted into labeled cDNA, and hybridized to the probes. A scanner measures
the fluorescence emitted by each spot. After background correction and
normalization, the intensity provides a relative estimate of the abundance of
the corresponding transcript.

Microarray measurements are not intrinsically restricted to the interval
$[0, 1]$. Their numerical scale depends on the scanner, preprocessing, and
normalization method. The values are usually interpreted comparatively, for
example to determine whether a gene is expressed more highly in one condition
than in another.

=== RNA-seq

In RNA-seq, RNA is converted into a sequencing library and read by a
high-throughput sequencing instrument. The reads are aligned to a reference
genome or transcriptome, or assembled when no suitable reference is available.
The number of reads assigned to a gene or transcript provides an estimate of
its abundance. Appropriate normalization is necessary because samples can
contain different total numbers of reads and genes can have different lengths.

Expression data are often visualized with a *heatmap*: rows represent genes,
columns represent samples, and colors represent normalized expression values.
The color scale is relative to the chosen transformation and does not
necessarily mean that red is always high expression or that blue is always low
expression.

== Protein expression

#note()[
  Protein abundance is influenced by gene expression, but it is not determined
  by it alone. Translation efficiency, protein degradation, post-translational
  modifications, and cellular localization can all change the amount and
  activity of a protein.
]

Protein-abundance data can also be represented as a matrix:
- rows represent proteins;
- columns represent samples, conditions, or time points;
- $L_(i,j)$ represents the measured abundance of protein $i$ in sample $j$.

== Three-dimensional structures

The three-dimensional structure of a protein is important for understanding its
function, binding sites, and interactions with other molecules. A structure can
be represented by the three-dimensional coordinates of its atoms, together with
information about atom types, bonds, and sometimes experimental uncertainty.
Structures can be determined experimentally, for example by X-ray
crystallography, nuclear magnetic resonance, or cryo-electron microscopy.

#warning()[
  The experimental structure is not necessarily identical to the structure
  adopted in every cellular condition. Crystal packing, temperature, ligand
  binding, and other experimental factors can influence the observed
  conformation.
]

Machine-learning methods can also predict structures from amino-acid sequences.
For example, AlphaFold predicts protein structures using information learned
from sequence and structural data. Predictions are useful hypotheses, but their
confidence can vary across different regions of a protein.

== Interactions

Studying interactions is important because the function of a cell depends on
coordinated relationships among proteins, nucleic acids, metabolites, and other
components. Interaction data can be represented as networks, in which nodes
represent biological entities and edges represent physical or functional
relationships.

#example()[
  A transcription factor binds specific DNA sequences near a gene and
  regulates transcription. Its activity can also depend on interactions with
  co-activators, co-repressors, chromatin-remodeling complexes, and signaling
  proteins. These interactions affect the specificity and strength of
  regulation.
]

== Examples of use

These data can support *personalized medicine*. For example, genomic variants,
expression profiles, and clinical information can be combined to identify
biomarkers, predict disease risk, select a treatment, or anticipate an
individual's response to a drug.

Gene-expression data can be used to identify genes that are differentially
expressed between healthy and diseased tissues. These genes may suggest
biological mechanisms, therapeutic targets, or diagnostic and prognostic
biomarkers. Genes can also be clustered according to their expression patterns
across samples, helping identify co-regulated genes and biological pathways.

In *systems biology*, we study a biological system as a whole rather than
considering only one gene or protein. Integrating sequences, expression,
protein measurements, structures, interaction networks, and clinical data can
provide a more complete description of the system.

= Machine learning in bioinformatics

Machine-learning algorithms learn a model from data. In supervised learning,
the input data are paired with target outputs; the model learns a relationship
that can be used to make predictions for new inputs. In other settings, the
algorithm identifies structure in unlabeled data or learns from feedback.

== Challenges

Bioinformatics datasets present several challenges:
- *High dimensionality*: there may be many measured features and relatively few
  samples, which increases the risk of overfitting.
- *Limited labels*: biological labels can be expensive, noisy, or unavailable.
  Unsupervised and semi-supervised methods can help exploit unlabeled data.
- *Noise and missing values*: measurements can contain experimental noise,
  batch effects, missing entries, or sequencing errors.
- *Structured data*: sequences, graphs, matrices, and three-dimensional
  structures require representations that preserve their relevant structure.
- *Integration of data types*: genomic, transcriptomic, proteomic, structural,
  and clinical data differ in scale, resolution, and measurement error.
- *Data leakage and confounding*: information from the test set or from
  correlated samples must not accidentally enter training, and technical
  effects must be distinguished from biological effects.

These challenges do not imply that standard algorithms are always unusable, nor
are they all NP-hard problems. Instead, the choice of representation, model,
preprocessing, and validation strategy must reflect the biological data and the
question being studied.

== Representation and evaluation

Machine-learning models can use different representations:
- *Decision trees*: interpretable models that recursively split the data and
  can be used for classification and regression.
- *Rule sets*: collections of if-then rules that make predictions or describe
  associations in the data.
- *Bayesian networks*: probabilistic graphical models that represent
  dependencies among variables and support prediction and inference.
- *Neural networks*: flexible models that learn nonlinear relationships through
  layers of parameterized transformations.

Model performance must be evaluated on data that were not used to fit the
model. A validation set can be used for model selection, while a final test set
should be kept separate for an unbiased estimate of generalization. Common
metrics include:
- *accuracy*: the fraction of correct predictions;
- *precision*: the fraction of predicted positives that are actually positive;
- *recall*: the fraction of actual positives that are detected;
- *F1 score*: the harmonic mean of precision and recall;
- *area under the ROC curve (AUROC)*: a threshold-independent summary of the
  ranking of positive examples above negative examples.

The appropriate metric depends on the biological cost of false positives and
false negatives. Cross-validation can estimate performance when the dataset is
small, but related samples must be kept in the same split to avoid overly
optimistic results.

== Types of learning

The main types of machine learning are:
- *Supervised learning*: the model is trained with labeled input-output pairs.
  It is commonly used for classification and regression.
- *Unsupervised learning*: the model receives no target labels and learns
  patterns such as clusters, low-dimensional representations, or anomalies.
- *Semi-supervised learning*: the model uses a smaller labeled dataset together
  with a larger unlabeled dataset.
- *Reinforcement learning*: an agent interacts with an environment and learns a
  policy by maximizing cumulative rewards. It is mainly suited to sequential
  decision-making problems.

=== Supervised learning

Let $f: X -> Y$ be the unknown target function that maps an input from the
space $X$ to an output in the space $Y$. A training set consists of pairs
$(x_i, y_i)$, where $x_i in X$ and $y_i in Y$. A learning algorithm uses these
examples to construct a hypothesis $g: X -> Y$ that approximates $f$ and
generalizes to unseen inputs.

If $Y$ is a discrete set of labels, the task is called *classification*. If
$Y$ is continuous, the task is called *regression*. In practice, the training
examples may contain measurement noise, so requiring $g(x_i) = y_i$ for every
training example is not always appropriate.

=== Unsupervised learning

In unsupervised learning, the input data have no corresponding target labels.
The goal is to discover useful structure, such as groups of similar samples,
low-dimensional representations, or unusual observations.

#informally()[
  Imagine points in a space and ask which points are similar to one another.
  Algorithms such as k-means, hierarchical clustering, and DBSCAN use
  different definitions of similarity to identify groups.
]

#note()[
  Similarity may be measured with Euclidean distance, cosine similarity, or
  Jaccard similarity, among other choices. The metric and its scaling can
  substantially affect the clusters and their biological interpretation.
]

== Loss function

#example()[
  Suppose that $x in RR^d$ is a vector containing the expression levels of
  $d$ genes in one sample, and that $t in {0, 1}$ indicates whether the sample
  comes from a healthy or diseased patient. We want to learn a classifier
  $g: RR^d -> {0, 1}$ from a dataset
  $D = {(x_i, t_i)}_(i=1)^n$.

  A *loss function* $L(g(x_i), t_i)$ measures the error of a prediction. The
  empirical risk is the average loss on the training set:
  $
    R_"emp"(g) = 1/n sum_(i=1)^n L(g(x_i), t_i).
  $
  The learning algorithm chooses model parameters that minimize this quantity,
  possibly together with a regularization term. The loss does not necessarily
  range from $0$ to $1$: squared error, absolute error, cross-entropy, and
  zero-one loss have different scales. Lower loss means better agreement with
  the targets according to the chosen definition.
]
