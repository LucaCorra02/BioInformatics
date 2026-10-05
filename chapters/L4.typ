#import "../template.typ": *

= Data in bioinformatics
Example of data in bioinformatics include:
- *Sequences*: DNA, RNA, and protein sequences are fundamental data types in bioinformatics. They can be represented as strings of characters, where each character corresponds to a nucleotide or amino acid.

- *Expression data*: usually represented as matrices. They represent the expression levels of genes or proteins across different conditions or samples. The quantity of transciptes a certain gene produce a different value in the matrix. The rows of the matrix represent genes or proteins, while the columns represent different samples or conditions.

- *Proteion Networks*: they represent the interactions between proteins in a biological system. They can be represented as graphs, where nodes represent proteins and edges represent interactions between them.

== DNA Sequences

DNA sequence are very long, if he consider the entire human genome we can find 3 billion base pairs.

RNA sequnce are usually shorter than DNA sequences, but they can still be quite long.

#note()[
  RNA sequence are *not stable* they can degradete to their nucleotides, while DNA sequences are more stable and can be preserved for longer periods of time.
]

Usually the RNA is converted to *complementary DNA* (cDNA) using reverse transcription, which allows for more stable storage and analysis of the genetic information. We can transform RNA into cDNA using the reverse process of transcription, wich usually involves some retro-transcription enzymes.

In order to analyze the RNA sequence it maybe too small to be sequenced directly, so it is often *amplified* using techniques such as polymerase chain reaction (PCR) or reverse transcription PCR (RT-PCR).


From a stem point we only able to analyze some small sequence length (less than 1 million). We need to *split the genome* in small part. To achive that we need to use some *algorithms* that are able to reconstruct the genome from the small parts, this is a very complex problem and it is still an open problem in bioinformatics.

=== Population Data

We are able to have a lot of data from the population, for example we can have the genome of a lot of people, this is very useful to understand the *genetic variation* in the population and to identify genetic factors that contribute to disease susceptibility or drug response.

Even if the genome of different people are very similar (indipendent from region and race), there are some differences expecially in the position of the nucleotides. This is collected in the *Single Nucleotide Polymorphisms* (SNPs).

Most of the type this variation is phisiological, variability is very important because it allows the evolution of the species, but some of this variation can be pathological and can lead to disease. The study of bad variation is very important to understand the disease and to develop new therapies.

== Gene expression

Gene expression is the proccess that measure the quantity of mRNA produced by a gene in a certain cell or tissue. The level of expression of a gene can vary depending on the cell type, developmental stage, and environmental conditions.

What is the level of expression of a certain gene? How much each gene are transcribed in a certain cell? To answer this question we have two different approaches: *microarray* and *RNA-seq*. Both of them are able to measure the expression level of genes in a certain cell or tissue.

=== Microarray

Microarray is a technique that allows to measure the expression level of thousands of genes simultaneously. It is based on the hybridization of cDNA to a microarray chip that contains thousands of probes, each corresponding to a specific gene. The intensity of the signal from each probe is proportional to the amount of cDNA that hybridizes to it, which reflects the expression level of the corresponding gene.

Then we can extract the RNA from a cell. If a specific gene is expressed in that cell, the RNA will be chained to the cDNA (usually is chained to one specific cDNA, but it can be chained to multiple cDNA). The cDNA is then labeled with a fluorescent dye, and then we can measure the intensity of the signal from each probe, which reflects the expression level of the corresponding gene.

Finally we can read the flourescent signal from the microarray chip using a scanner (laser), if there is no RNA the light will be very low, if there is a lot of RNA the light will be very high. The intensity of the signal from each probe is proportional to the amount of cDNA that hybridizes to it, which reflects the expression level of the corresponding gene. Each expression level is represented as a number, usually between 0 and 1:
- $0$: means no expression
- $1$: means maximum expression.

=== RNA-seq

Another way to represent the expression level is to use a *heatmap*, where each gene is represented as a row and each sample is represented as a column. The color of each cell in the heatmap represents the expression level of the corresponding gene in the corresponding sample, with red indicating high expression and blue indicating low expression. this representation is very useful to visualize and compare the expression levels of genes across different samples (different patients, different tissues, different conditions, etc.).


== Protein expression

#note()[
  The expression protein depends on the expression of the gene, if a gene is expressed in a certain cell, the protein will be produced in that cell. The level of protein expression can also vary depending on the cell type, developmental stage, and environmental conditions.
]

At the end we have data represented as a matrix, where:
- rows: represent genes or proteins
- columns: represent different samples or conditions. Each columns can correspond to a di
- $L_(i,j)$: Each cell in the matrix represents the expression level of a specific gene $i$ or protein in a specific sample $j$ or condition.

== 3D structures

They represent the 3D structure of proteins, which is important for understanding their function and interactions with other molecules. They can be represented as 3D coordinates of atoms in the protein, which can be visualized using molecular visualization software.

#warning()[
  Some tecnologies are able to alter the 3D structure of proteins, for example the *crystalization*.
]

Nowdays ML methods are able to predict the 3D structure based on the sequence of the protein (for example `AlphaFold`).

== Interactions

Is important to study the intercations because the function of a specific cell depends on wow the proteins interact with each other.

#example()[
  For example, if we consider the transcription factor, it is a protein that binds to specific DNA sequences and regulates the transcription of genes (promoter). The function of the transcription factor depends on its interactions with other proteins, such as co-activators or co-repressors, which can modulate its activity and specificity.
]

== Example of use

We can use this kind of data to achive the *personalized medicine*, for example we can use the expression data to identify the genes that are differentially expressed between healthy and diseased tissues, which can help to identify potential therapeutic targets or biomarkers for disease diagnosis and prognosis.

Another use of gene expression data is to cluster this genes based on their expression patterns across different patients or conditions, which can help to identify co-regulated genes or pathways that are involved in specific biological processes or disease states.

We can also developed a *system biology*. Instread of studying a single gene or protein, we can study the interactions between genes and proteins in a biological system. We study the biological system as a whole block.

= Machine Learning in Bioinformatics

Machine learning alghorithms take in input a set of data and a set of output (example related to the input data) and produce a model that is able to predict the output based on the input data. The model is trained on the input data and the output data, and then it can be used to make predictions on new input data.

== Challenges

The main challenges in applying machine learning to bioinformatics include:
- *High-dimensional data*: Bioinformatics data is often high-dimensional, with many features. This can lead to overfitting and poor generalization performance if not properly addressed.

- *More or less labeled data*: In many cases, bioinformatics data is unlabeled or partially labeled, which can make it difficult to train supervised machine learning models. This can be addressed using unsupervised or semi-supervised learning techniques.

- Noisy data, structured data, and missing data: We can have sequence, graph and matrix data, and they can be noisy or incomplete.

- *Combination of different data types*: Bioinformatics data can come from multiple sources and modalities, such as genomic, transcriptomic, proteomic, and clinical data. Integrating these different data types can be challenging but can also provide a more comprehensive understanding of biological systems.

The majority of standard algorithms are not able to handle this kind of data, they are np-hard problems. We need to develop new algorithms that are able to handle this kind of data. In this case we use machine learning methods, that are able to learn from the data and make predictions or decisions based on it.

== Representation and Evaluation

We can represent the alghorithms in different ways:
- *Decision trees*: they are a simple and interpretable way to represent the decision-making process of a machine learning model. They can be used for both classification and regression tasks.

- *Set of rules*: we can learn rules from the data that can be used to make predictions or decisions. This can be done using techniques such as association rule mining or rule-based learning.

- *Bayesian networks*: they are a probabilistic graphical model that can be used to represent the relationships between variables in a biological system. They can be used for both prediction and inference tasks.

- *Neural networks*: they are a powerful and flexible way to represent complex relationships between variables in a biological system.

To evaluate the performance of a machine learning model (also use during the train process), we can use different metrics, such as: accuracy, precision, recall, F1 score, and area under the receiver operating characteristic (ROC) curve. These metrics can be used to assess the model's ability to make accurate predictions on new data.

== Types of Learning

There is different types of learning in machine learning, each with its own strengths and weaknesses. The main types of learning are:
- *Supervised learning*: In supervised learning, the model is trained on a labeled dataset, where the input data is paired with the corresponding output labels. The goal is to *learn a mapping* from the input data to the output labels, so that the model can make accurate predictions on new, unseen data. Supervised learning is commonly used for classification and regression tasks.

- *Unsupervised learning*: In unsupervised learning, the model is trained on an unlabeled dataset, where the input data does not have corresponding output labels. The goal is to *learn the underlying structure* or patterns in the data, such as clusters or latent representations. Unsupervised learning is commonly used for clustering, dimensionality reduction, and anomaly detection tasks.

- *Semi-supervised learning*: In semi-supervised learning, the model is trained on a combination of labeled and unlabeled data. The goal is to leverage the unlabeled data to improve the model's performance on the labeled data. Semi-supervised learning is commonly used when labeled data is scarce or expensive to obtain.

- *Reinforcement learning*: In reinforcement learning, the model learns to make decisions by interacting with an environment and receiving feedback in the form of rewards or penalties. The goal is to learn a policy that maximizes the cumulative reward over time. Reinforcement learning is commonly used for sequential decision-making tasks, such as game playing, robotics, and autonomous systems.

=== Supervised Learning

The learning algorithms should induce a representation of a function that maps the input data to the output labels starting from a set of training examples. The goal is to learn a function that can generalize well to new, unseen data

Consider $f: X->Y$: the target function that we want to learn, and $X$ is the input space and $Y$ is the output space. The *hypothesis* function $g$ is learned from a set of training examples, which consist of input-output pairs $(x_i, y_i)$, where $x_i in X$ and $y_i in Y$.

If $Y$ is a discrete set of labels, the task is called *classification*, while if $Y$ is a continuous set of values, the task is called *regression*.

=== Unsupervised Learning

We want to *learn the underlying structure* or patterns in the data, such as clusters or latent representations. The goal is to find a representation of the data that captures its essential characteristics and can be used for downstream tasks, such as clustering, dimensionality reduction, or anomaly detection.

#informally()[
  We have some points in a space and we want to find some clusters of points that are similar to each other. We can use different algorithms to find the clusters, such as k-means, hierarchical clustering, or DBSCAN.
]

#note()[
  In the process of gropu the points we can use different metrics to measure the similarity between points, such as Euclidean distance, cosine similarity, or Jaccard similarity. The choice of metric can have a significant impact on the resulting clusters and their interpretability.
]

== Loss function

#example()[
  In input we have a couple (x,t) where $x in R^d$ is a vecotr of $d$ number. Each number represent the expression level of a gene in a certain sample. $t$ is a label that represent the desire of the patient, for example if the patient is sick or healthy.


  We want to find a function $f: R^d -> {0,1}$ that maps the input vector $x$ to the output label $t$. Throught a learning algorithm $L$ and a set of data $D = {(x_i, t_i)}_{i=1}^n$ we want to find a hypothesis function $g: R^d -> {0,1}$ that approximates the target function $f$. For each data we want:
  $
    g(x_i) = t_i, forall i = 1, ..., n
  $

  The objective is to *minimize* the *empirical risk*, which is the average loss over the training examples:
  $
    R_"emp" = 1/n sum_(i=1)^n L(g(x_i), t_i)
  $
  The loss function measures the discrepancy between the predicted output $g(x_i)$ and the true output $t_i$. Thir risk goes from 0 to 1, where 0 means perfect prediction and 1 means worst prediction.
]

//guardare slide loss function