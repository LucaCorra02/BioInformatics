#import "../template.typ": *

= Prediction of Genetic Variants

== Introduction to Genetic Variation

A major challenge in genomic medicine and computational biology is the detection, prediction, and functional interpretation of *SNPs (Single Nucleotide Polymorphisms)* and, more generally, *SNVs (Single Nucleotide Variants)*. SNPs are the most common type of genetic variation among individuals, occurring on average every $100$ to $300$ bases along the human genome. Notably, protein-coding exons account for only about $1.5%$ of the human genome; the vast majority of variants are located in *non-coding regions*, where they do *not directly alter protein sequences* but can disrupt gene regulation, splicing, and expression.

Across the human population, the *1000 Genomes Project* catalogued over $84.7$ million SNPs. A single individual typically carries several million variants compared to a reference human genome, with the exact count depending on ancestry and the variant-calling pipeline used.

Part of the variability observed in the *phenotype* across individuals of the same species is explained by genetic variation, while the remaining variability arises from environmental factors and complex gene-environment interactions.

#note()[
  The *phenotype* is the set of observable characteristics or traits of an organism (including morphology, physiological properties, and disease susceptibility), and it is determined by the interplay between the *genotype* and the *environment*. The *genotype* is the genetic makeup of an individual, encoded in its DNA sequence. The *environment* encompasses all external factors that can influence the phenotype, such as diet, lifestyle, and exposure to toxins or pathogens.
]

Many human diseases (including rare Mendelian disorders and complex diseases such as cancer, Alzheimer's) are caused or influenced by *DNA alterations* (mutations). These variants can be:
- *Inherited (germline) variants*: present in germ cells (egg or sperm) and passed from parents to offspring; they are present in virtually all cells of the body and drive inherited genetic diseases.

- *Acquired (somatic) variants*: arise spontaneously in somatic cells during an individual's lifetime (e.g., due to DNA replication errors or environmental mutagens) and are not passed to offspring. Many diseases, most notably cancer, are driven by a combination of germline predisposition and somatic mutations.

In genomic medicine, three fundamental objectives are to:
1. *Detect genetic variants* across individuals and populations through high-throughput sequencing.
2. *Predict their potential pathogenicity* and functional impact on the phenotype.
3. *Identify precise, targeted therapies* tailored to the specific pathogenic variants and molecular mechanisms involved.

== Genomic, Precision, and Personalized Medicine

The problem of variant prioritization sits at the core of *Genomic, Precision, and Personalized Medicine*:
- *Genomics* is the study of the function and information structure encoded in the DNA sequences of living cells.
- *Personalized / Precision Medicine* refers to a medical model that uses the characterization of individuals' phenotypes and genotypes (e.g., molecular profiling, medical imaging, lifestyle data) to tailor the right therapeutic strategy for the right person at the right time, determine predisposition to disease, and deliver timely, targeted prevention.

Modern high-throughput *omics biotechnologies* allow researchers to massively measure biological data across multiple molecular layers:
- *Genome*: measured via microarrays, Next-Generation Sequencing (WGS, WES, Targeted Sequencing), and single-cell DNA-seq to detect SNPs, CNVs, and indels.
- *Epigenome*: measured via ChIP-seq, DNase-seq, and Whole-Genome Bisulfite Sequencing (WGBS) to profile DNA methylation, histone modifications, chromatin accessibility, and transcription-factor binding sites.
- *Transcriptome*: measured via RNA-seq and single-cell RNA-seq to quantify mRNA and non-coding RNA (e.g., miRNA) expression and alternative splicing.
- *Proteome and Metabolome*: measured via Mass Spectrometry (MS, LC-MS) and protein arrays to quantify protein expression, interactions, and metabolites (such as lipids).

#note()[
  *Data explosion in Genomic Medicine*: while traditional laboratory tests measure only a few dozen clinical variables, omics technologies generate datasets that are several orders of magnitude larger and more complex (over $1$ million molecular biology datasets publicly available, averaging around $10$ gigabases per dataset in whole-genome studies). Consequently, *Machine Learning (ML)* has become a primary tool to analyze omics big data, stratify patients (*precision diagnostics*), design targeted treatments (*precision therapeutics*), and guide genome-editing technologies. Ultimately, we need ML systems capable of interpreting the genome much like the molecular machinery inside the cell does.
]

== Variants in Coding and Non-Coding Regions

While protein-coding exons are currently the best-understood regions of the genome, disease-causing mutations are increasingly being discovered outside of coding regions. Indeed, genes alone do not account for the full complexity of cellular biology (for instance, many plants have more than twice the number of genes found in humans), and biological complexity is heavily driven by gene regulation.

Non-coding variants can disrupt cellular function in several ways:
- *Disrupting DNA sequence motifs* within proximal and distal regulatory elements (promoters, enhancers, silencers, insulators).
- *Disrupting post-transcriptional regulation*, such as altering microRNA (miRNA) binding sites.
- *Affecting mRNA splicing* through mutations located inside introns or near splice sites.
- *Causing indirect downstream effects* propagating from the regulatory changes above.

=== Regulatory Elements and Chromatin Structure

Gene transcription is tightly controlled by the physical and biochemical interplay between DNA regulatory elements, transcription factors, and chromatin architecture:

- *Promoters*: DNA sequences located immediately upstream ($5'$ region) of *Transcription Start Sites (TSSs)* that activate transcription via *RNA Polymerase II (RNAPII)*. Through the action of various *Transcription Factors (TFs)*, RNAPII binds to a consensus sequence forming the RNAPII transcription-initiation complex to start gene transcription. A variant in a promoter can impair this assembly; in extreme cases, little or no mRNA and protein are produced.

- *Enhancers*: short distal regulatory DNA regions that can be located thousands of base pairs away from the TSS. They are bound by DNA-binding proteins called *activators* and *increase gene transcription* through their interaction with RNAPII. To act over long genomic distances, enhancers form three-dimensional *DNA loops* (mediated by activators and co-factors) that bring them into close physical proximity with the target promoter. Variants within an enhancer can disrupt activator binding and impair transcription.

- *Silencers*: short DNA sequences that have the *opposite effect of enhancers*. They bind regulatory proteins called *repressors*, inhibiting promoters and causing a decrease in gene transcription. Like enhancers, silencers can be located near the TSS or thousands of base pairs away. A variant in a silencer can weaken this repression and lead to an abnormal increase in transcription.

- *Insulators*: boundary DNA sequences that *prevent inappropriate interactions* between distinct chromatin domains. For example, the transcriptional repressor *CTCF (CCCTC-binding factor)*.

- *Histone modifications*: in eukaryotic cells, DNA is wrapped around histone protein octamers to form *nucleosomes*, which further coil into *solenoids* and *chromatin fibers*. Chemical modifications to histone tails (e.g., methylation, acetylation) alter *chromatin accessibility*, determining whether regulatory sequences are physically exposed to TFs and RNAPII.

#note()[
  Insulators prevent the expansion of *heterochromatin* into *euchromatin*:
  - In *heterochromatin*, DNA is tightly packed around histones into dense chromatin fibers and is generally *inaccessible for transcription* (gene silencing).

  - In *euchromatin*, DNA is more loosely packed and open, making it accessible to the transcriptional machinery for active gene expression.
]

=== Post-transcriptional Regulation

Gene regulation continues after DNA is transcribed into RNA. *Messenger RNA (mRNA)* molecules interact with RNA-binding proteins and *non-coding RNAs (ncRNAs)*, such as *microRNAs (miRNAs)*. These ncRNAs base-pair with specific target motifs on the mRNA (typically in the $3'$ untranslated region) to regulate mRNA stability, promote degradation, control cellular localization, or inhibit translation into protein.

== International Consortia and Characterization Pipeline

To train machine learning models that predict the effects of non-coding variants, researchers rely on large-scale functional annotations generated by international consortia:
- *ENCODE (ENCyclopedia Of DNA Elements)*: aims to build a comprehensive catalogue of functional elements in the human genome across diverse cell lines, providing maps of Transcription Factor Binding Sites (TFBSs) and motifs, TSSs, histone marks, DNA methylation sites, and open chromatin regions.
- *FANTOM5 (Functional Annotation of the Mammalian Genome)*: uses *CAGE (Cap Analysis of Gene Expression)* to map active TSSs and quantify the activity of promoters and enhancers, identifying over $180,000$ promoters and nearly $44,000$ candidate enhancers across hundreds of human and mouse primary cell types.

=== Pipeline for the Characterization of Regulatory Variants

From a practical standpoint, characterizing regulatory variants from patient samples involves a two-stage workflow combining laboratory procedures and computational analysis:
1. *Laboratory procedure*:
  - *DNA extraction* from patient biological samples.
  - *DNA sequencing* using high-throughput sequencing platforms (e.g., Illumina).
2. *Computational analysis*:
  - *Sequence trimming*: removal of adapter sequences and low-quality bases
  - *Sequence alignment*: mapping reads against a reference human genome (e.g., using *Bowtie2*).
  - *Variant calling*: identifying genomic positions that differ from the reference genome.
  - *Association procedure*: statistically associating variants with traits or diseases, typically via *GWAS (Genome-Wide Association Studies)*.
  - *Variant annotation*: enriching called variants with overlapping functional and epigenomic features from databases
  - *Variant effects prediction*: applying machine learning tools to score and prioritize pathogenic variants (e.g  *DeepSEA*, *HyperSMURF*).

== Machine Learning Formulation

The prediction of pathogenic or deleterious genetic variants is formulated as a *supervised machine learning* problem:
- *$mb("Input")$*:
  - A set of genetic variants, such as SNVs (the training/testing *examples*).
  - A set of genomic, epigenomic, and evolutionary annotations associated with each variant (the *features*).
  - A set of binary labels ($"pathogenic"$ vs. $"neutral/control"$) associated with each variant (the *targets*).

  #example()[
    Possible example: A mutation on the 11 chromosome at position $11,000,000$ (GRCh38) with reference allele $"A"$ and alternative allele $"G"$.

    The example of features could include:
    - *Genomic features*: distance to the nearest TSS, overlap with a promoter or enhancer, ecc..
    - *Epigenomic features*: predicted chromatin accessibility, histone marks, TF binding sites, ecc..
    - *Evolutionary features*: A high score meaning that the variant is highly conserved across species, suggesting functional importance
  ]


- *$mr("Output")$*:
  - A continuous score or probability estimating the likelihood that a given unseen variant is pathogenic.

Depending on the clinical or research goal, the task is cast either as a *dichotomic (binary) classification problem* or as a *ranking problem*, commonly referred to as *variant prioritization*.

= DeepSEA

*DeepSEA* (*Deep learning-based Sequence Analyzer*, Zhou and Troyanskaya, *Nature Methods*, 2015) is a deep convolutional neural network (CNN) framework that learns a regulatory sequence code directly from large-scale chromatin-profiling data, enabling *de novo* prediction of the epigenetic effects of non-coding sequence alterations with single-nucleotide sensitivity.

== Problem Setup and Goals

Given a genetic variant and its surrounding genomic sequence context, DeepSEA addresses two interconnected goals:
1. *Predict large-scale epigenetic signals* across multiple human cell and tissue types directly from raw DNA sequence. Specifically, the cellular variables predicted are:
  - *Transcription-Factor (TF) binding* profiles ($690$ features).
  - *DNase I-hypersensitive sites (DHS)*, which measure open and accessible chromatin ($125$ features).
  - *Histone mark* profiles, which reflect chemical modifications to histones such as $"H3K4me3"$ ($104$ features).

2. *Predict variant functionality and prioritize deleterious* by comparing the predicted chromatin profiles between the reference allele and the mutated (alternative) allele. This means that DeepSEA can predict how a single-nucleotide variant (SNV) affects the binding of transcription factors, chromatin accessibility, and histone modifications, which are critical for gene regulation.


#note()[
  L'epigenetica riguarda tutte le *modificazioni chimico-fisiche che regolano l'espressione dei geni senza alterare la sequenza sottostante* del DNA (le lettere A, C, G, T). Nel nucleo cellulare, il DNA non è libero, ma è avvolto attorno a complessi proteici chiamati *istoni*, formando una struttura complessa detta *cromatina*.

  Quando un modello come `DeepSEA` prevede dei "cambiamenti nei segnali", non calcola direttamente il livello finale di espressione genica (es. "quante molecole di mRNA verranno prodotte"), ma stima la probabilità che la mutazione alteri tre parametri strutturali fondamentali:
  - *Accessibilità della cromatina (DNase I hypersensitivity)*: Misura quanto un tratto di DNA è fisicamente "aperto" (eucromatina) e quindi accessibile al macchinario trascrizionale. Una singola mutazione nucleotidica può innescare processi che fanno condensare o srotolare localmente la struttura.
  - *Legame dei Fattori di Trascrizione (TF binding)*: Proteine regolatrici che si agganciano a sequenze specifiche (motifs) per attivare o reprimere un gene. Una variante può creare un nuovo sito di aggancio o distruggerne uno esistente, alterando l'interazione fisica tra DNA e proteine
  - *Marcatori istonici (Histone marks)*: Aggiunte o rimozioni di gruppi chimici sulle code degli istoni, che agiscono come "semafori" per segnalare alla cellula l'attivazione o la repressione di una regione genomica.

  In sintesi, il modello prevede se una mutazione andrà a stravolgere l'"impalcatura" fisica tridimensionale e le "etichette" chimiche che indicano alla cellula se, quando e come leggere quel preciso frammento di DNA.
]

=== Sequence Motifs and Regulatory Perturbations

To predict epigenomic states from sequence alone, the classifier must learn the binding preferences of DNA-binding proteins both locally (*sequence motifs*) and at a broader spatial scale (*cis-regulatory modules*, where multiple TFs bind cooperatively).

#note()[
  We can visually represent the DNA as a sequence of nucleotides (A, C, G, T). Each cell has some transcription factor (TF) proteins that can alter the expression of a gene by binding to specific DNA sequences. This specific binding sequence is called a *motif*. Think of motifs as "locks" in the DNA, and TFs as "keys" that can fit into these locks. When a mutation occurs in the DNA, it can either create a new lock (*gain of motif*) or break an existing one (*loss of motif*), which can turn genes on or off inappropriately.
]



The *sequence logo* is a graphical representation of a motif's position weight matrix:
- The *total height* of a column at a given position represents its *information content* (conservation), measured in bits (up to $2$ bits for DNA).
- The *relative height* of each nucleotide letter ($"A", "C", "G", "T"$) within the column is proportional to its observed frequency at that position.

=== Classifier Input and Output Representation

To train the epigenomic classifier, the human genome is partitioned into consecutive $200 "bp"$ bins (windows):
- *Input*: a *$1000 "bp"$ DNA sequence* centered on the $200 "bp"$ target window. The sequence is represented via *one-hot encoding* as a binary matrix of size $4 times 1000$, where:
  - The $4$ *rows* correspond to the nucleotides $"A", "C", "G", "T"$
  - Each *column* has a single $1$ at the row corresponding to the nucleotide present at that position:
    $
      x_i = mat(
        delim: "[",
        0, 1, 0, 0, dots, 0;
        0, 0, 0, 0, dots, 1;
        1, 0, 1, 1, dots, 0;
        0, 0, 0, 0, dots, 0;
      ) quad arrow.l.r.double quad " rows: " ("A", "C", "G", "T")^T, " columns: positions " 1, dots, 1000
    $
- *Output*: a binary vector of *$919$ classes* corresponding to the $919$ epigenetic features (measured by ENCODE and Roadmap Epigenomics across dozens of cell and tissue types). For a given $200 "bp"$ window, class $k$ has label $1$ if an experimental peak for epigenetic feature $k$ falls within that $200 "bp"$ bin, and $0$ otherwise.

#note()[
  From a machine learning standpoint, predicting all $919$ epigenetic features simultaneously from the same input sequence is a *multi-task / multi-label supervised classification problem*.
]


== Neural Network Architecture

An epigenomic sequence classifier requires three essential properties:
1. The ability to learn both local sequence patterns (*motifs*) and broader spatial combinations (*cis-regulatory modules*).
2. Support for *nonlinear decision boundaries* (to model complex interactions between motifs).
3. The ability to leverage *multi-task learning* across multiple related prediction tasks (sharing internal representations across different TFs, histone marks, and cell types).

=== From Naive Dense Layers to Convolutional and Pooling Layers

Suppose we want a first hidden layer to scan an input DNA sequence of length $L$ (represented as a $4 times L$ matrix) to *detect motifs of width $s$* (e.g., $s = 6$):

- A single hidden node $h_(1,1)$ connected to the first $s$ positions of the sequence (plus a bias term) can learn weights that fire (via a ReLU activation) when "motif 1" appears at starting position $1$.

- Since a motif of width $s$ can start at any of the $W = L
  - s + 1$ valid positions along the sequence, and we want to detect *$D$ distinct motifs* (where $D$ is the hidden layer depth), afirst hidden layer contains $D times W$ hidden nodes:
  $
    mat(
      delim: "[",
      h_(1,1), h_(1,2), dots, h_(1,W);
      h_(2,1), h_(2,2), dots, h_(2,W);
      dots.v, dots.v, dots.down, dots.v;
      h_(D,1), h_(D,2), dots, h_(D,W);
    )_(D times W)
  $

#note()[
  In this way, we are using a *fully connected dense layer* to scan the input sequence for $D$ distinct motifs at all $W$ possible starting positions.
]

*$mr("Problem with unshared weights")$*: if every node $h_(d, j)$ had its own independent weight vector, the layer would have an enormous number of parameters and would be forced to re-learn the exact same motif independently at every starting position $j in {1, dots, W}$.

We can use the *convolutional layer solution*: by enforcing *parameter sharing* across each *row* $d in {1, dots, D}$, all $W$ nodes in row $d$ share the exact same $4 times s$ weight kernel. Thus, each kernel slides across the $4 times L$ input matrix to detect the *same motif* at any starting position, producing a $D times W$ feature map while drastically reducing the number of parameters.

#note()[
  The kernel is a small matrix of weights ($4 times s$). Each kernel represents a *single motif detector*, and the same kernel is applied across the entire input sequence. After the training process, the learned weights in the kernel can be interpreted as a *position weight matrix (PWM)* for the corresponding motif. When the motif is present in the input sequence, the convolution operation produces a high activation in the corresponding feature map, indicating that the motif has been detected at that position
]



#figure(
  caption: [ kernell has a $s=3$ dimension $[w_1, w_2, w_3]$ and it remain the same for the entire input sequence. The activation of $h_(1,1)$ is the result of appling the weights on the first three bases(ACG)],
)[
  #align(center)[
    #cetz.canvas(length: 1cm, {
      import cetz.draw: *

      // --- Input DNA Sequence ---
      let seq = ("A", "C", "G", "T", "A", "C")
      let start-x = 0
      let y-in = 0

      content((start-x - 1.2, y-in + 0.4), anchor: "east", text(size: 10pt)[*Sequenza\ Input*])

      for (i, base) in seq.enumerate() {
        rect((start-x + i, y-in), (start-x + i + 0.8, y-in + 0.8), stroke: 1pt + black)
        content((start-x + i + 0.4, y-in + 0.4), text(weight: "bold", size: 12pt)[#base])
      }

      // --- Shared Weights Annotations ---
      // Highlight Window 1 (Solid Teal)
      let pad = 0.1
      rect(
        (start-x - pad, y-in - pad),
        (start-x + 2.8 + pad, y-in + 0.8 + pad),
        stroke: (paint: teal, thickness: 1.5pt),
        radius: 0.1,
      )

      // Weights from Window 1 to h1
      line((start-x + 0.4, y-in + 0.8 + pad), (start-x + 1.4, 2.5), stroke: (paint: teal, thickness: 1.2pt))
      line((start-x + 1.4, y-in + 0.8 + pad), (start-x + 1.4, 2.5), stroke: (paint: teal, thickness: 1.2pt))
      line((start-x + 2.4, y-in + 0.8 + pad), (start-x + 1.4, 2.5), stroke: (paint: teal, thickness: 1.2pt))

      // Weight labels for h1
      content((start-x + 0.65, 1.8), text(fill: teal.darken(20%), size: 10pt)[$w_1$])
      content((start-x + 1.2, 1.8), text(fill: teal.darken(20%), size: 10pt)[$w_2$])
      content((start-x + 2.1, 1.8), text(fill: teal.darken(20%), size: 10pt)[$w_3$])

      // Highlight Window 2 (Dashed Orange)
      let pad2 = 0.2
      rect(
        (start-x + 1 - pad2, y-in - pad2),
        (start-x + 3.8 + pad2, y-in + 0.8 + pad2),
        stroke: (paint: orange, thickness: 1.5pt, dash: "dashed"),
        radius: 0.1,
      )

      // Weights from Window 2 to h2
      line((start-x + 1.4, y-in + 0.8 + pad2), (start-x + 2.4, 2.5), stroke: (
        paint: orange,
        thickness: 1.2pt,
        dash: "dashed",
      ))
      line((start-x + 2.4, y-in + 0.8 + pad2), (start-x + 2.4, 2.5), stroke: (
        paint: orange,
        thickness: 1.2pt,
        dash: "dashed",
      ))
      line((start-x + 3.4, y-in + 0.8 + pad2), (start-x + 2.4, 2.5), stroke: (
        paint: orange,
        thickness: 1.2pt,
        dash: "dashed",
      ))

      // Weight labels for h2
      content((start-x + 1.65, 1.3), text(fill: orange.darken(20%), size: 10pt)[$w_1$])
      content((start-x + 2.2, 1.3), text(fill: orange.darken(20%), size: 10pt)[$w_2$])
      content((start-x + 3.15, 1.3), text(fill: orange.darken(20%), size: 10pt)[$w_3$])

      // --- Hidden Layer Nodes ---
      let y-out = 2.9
      content((start-x - 1.2, y-out), anchor: "east", text(size: 10pt)[*Feature\ Map*])

      circle((start-x + 1.4, y-out), radius: 0.4, stroke: 1.5pt + teal, fill: teal.lighten(80%))
      content((start-x + 1.4, y-out), [$h_(1,1)$])

      circle((start-x + 2.4, y-out), radius: 0.4, stroke: 1.5pt + orange, fill: orange.lighten(80%))
      content((start-x + 2.4, y-out), [$h_(1,2)$])

      circle((start-x + 3.4, y-out), radius: 0.4, stroke: 1pt + black, fill: gray.lighten(90%))
      content((start-x + 3.4, y-out), [$h_(1,3)$])

      content((start-x + 4.5, y-out), [$dots$])

      // Add explanation arrow for sliding
      bezier(
        (start-x + 1.4, y-in - 0.4),
        (start-x + 2.4, y-in - 0.4),
        (start-x + 1.9, y-in - 0.8),
        stroke: (thickness: 1.2pt, paint: gray),
        mark: (end: ">", fill: gray),
      )
      content((start-x + 1.9, y-in - 1.1), text(
        size: 9pt,
        fill: gray.darken(30%),
        weight: "bold",
      )[Kernel goes on])
    })
  ]
]

To detect *multiple distinct motifs simultaneously* and account for wider sequence context (such as *cis-regulatory modules*), the architecture employs multiple kernels and successive layers:

- *Multiple Kernels (Depth $D$)*: A single convolutional layer applies *$D$ different kernels in parallel*. Since each kernel is specialized to recognize one specific motif, this produces a *feature map* of depth $D$ (size $D times W$). This allows the network to search for $D$ distinct biological motifs simultaneously across the entire DNA sequence.

- *Pooling layer*: applied on top of the convolutional layer. It takes the *maximum activation* (result of $h_(i,j)$), over non-overlapping windows (e.g., $4$ adjacent positions) along the spatial dimension, independently for each of the $D$ channels. This reduces the spatial representation from $D times W$ to $D times (W / 4)$. Biologically, this means the pooled unit fires if its specific motif is detected *anywhere* within that $4$-bp local window, providing local translation invariance and summarizing patterns at a higher spatial scale.

- *Subsequent convolutional layers*: a second convolutional layer with $D'$ new kernels of width $s'$ is stacked on top of the pooled $D times (W / 4)$ matrix. Crucially, each new kernel spans across *all* $D$ channels from the previous layer. This enables the network to learn *higher-order combinations of different motifs* (e.g., detecting if Motif 1 and Motif 5 appear close to each other), which biologically correspond to *cis-regulatory modules*. The new spatial width of this layer will be $W' = (W / 4) - s' + 1$.


=== Full DeepSEA Hierarchy

The complete DeepSEA network stacks three convolutional-pooling blocks followed by fully connected layers:
1. *Input layer*: $4 times 1000$ one-hot encoded DNA sequence.
2. *Convolutional layer 1 + ReLU + Max Pooling 1*: scans the raw sequence to detect individual *sequence motifs*.
3. *Convolutional layer 2 + ReLU + Max Pooling 2*: combines nearby motifs to detect local motif clusters and *cis-regulatory modules*.
4. *Convolutional layer 3 + ReLU + Max Pooling 3*: captures broader, long-range regulatory sequence context across hundreds of base pairs.
5. *Fully connected layer* (with ReLU activations): integrates high-level spatial features across the entire sequence window.
6. *Multitask output layer*: a sigmoid output layer with *$919$ units* that simultaneously predicts the probability of each epigenetic feature.

== Predicting Functional Variants with DeepSEA

After predicting epigenetic states, DeepSEA can be used to predict the functional impact of non-coding variants. This is achieved through a *two-step pipeline*:

1. *Chromatin effect extraction via DeepSEA*:
  For a given DNA variant, *two* $1000 "bp"$ sequences centered on the variant are constructed—one carrying the *reference allele* and one carrying the *alternative (mutated) allele*. Both sequences are fed into the trained DeepSEA network to obtain two vectors of $919$ predicted probabilities: $P("reference")$ and $P("alternative")$. From these, two sets of chromatin perturbation features are computed for each of the $919$ epigenetic classes:
  - *Absolute difference features* ($919$ features):
    $
      |P("reference") - P("alternative")|
    $
  - *Relative difference (log-odds) features* ($919$ features):
    $
      |log (P("reference")) / (P("alternative"))|
    $

2. *Variant pathogenicity classification via Boosted Logistic Regression*:
  The $919$ absolute differences and $919$ relative differences ($1838$ epigenetic features in total) are concatenated with *$4$ evolutionary conservation scores* (resilient mutation are very important). The resulting *$1842$ features* are standardized and fed into a *Boosted Logistic Regression classifier* to output the final probability that the variant is functional/pathogenic.

=== Summary: Strengths and Limitations of DeepSEA

- *$mg("Strengths")$*:
  - Predicts *de novo* how unseen sequence variants (SNPs, insertions, deletions) perturb regulatory elements with single-nucleotide resolution.
  - Naturally accounts for the surrounding sequence context of motifs.
  - Exploits *parameter sharing* via convolutional layers and *multitask learning* across $919$ outputs to improve hidden-layer representations.
- *$mr("Limitations")$*:
  - *Cannot generalize to unseen cell or tissue types*: since the $919$ output classes are fixed during training, the model cannot predict epigenetic states for a cell type not included in the training set.
  - *AUC-ROC is misleading for genome-wide evaluation*: across the whole genome, true epigenetic peaks (positive examples) and true pathogenic variants are vastly outnumbered by negative background regions. Under severe class imbalance, the False Positive Rate remains artificially small even when the absolute number of false positives is huge, making *Precision-Recall curves (AUPRC)* a much more reliable evaluation metric than AUC-ROC.

= HyperSMURF: Imbalance-Aware Variant Prediction

== The Class Imbalance Problem in Genomics

*Next-Generation Sequencing* (NGS) enables the investigation of genetic variation across the entire human genome to detect mutations associated with both *Mendelian diseases* (rare, monogenic disorders such as Cystic Fibrosis or Huntington's disease) and *complex diseases* (polygenic disorders such as Alzheimer's, Parkinson's, or cancer). However, genome-wide prediction of deleterious non-coding variants faces two fundamental obstacles:
1. The vast majority of genetic variation in the human genome is *physiological (neutral)*: deleterious or disease-associated variants represent a tiny minority immersed in a "sea of neutral variants".
2. This creates a *massive class imbalance* between positive examples (pathogenic variants) and negative examples (neutral variants)—for instance, a ratio of approximately $1 : 36,000$ in non-coding Mendelian diseases.

#note(title: "Why classical ML algorithms fail")[
  Standard machine learning algorithms aim to minimize overall classification error, which implicitly assumes *balanced class* distributions. When trained on highly imbalanced genomic data, they become heavily *biased toward the majority (neutral) class*, achieving high overall accuracy by simply predicting almost every variant as neutral while failing to detect the rare pathogenic variants.
]

== The HyperSMURF Method

*HyperSMURF* (*Hyper-ensemble of SMOTE Undersampled Random Forests*) is an imbalance-aware supervised ensemble method specifically designed to detect rare pathogenic variants in the non-coding genome.

HyperSMURF addresses extreme class imbalance by combining three core strategies:
1. *Balancing training data through differential sampling*:
  - *Partitioning of the majority class*: the huge set of negative (neutral) examples $cal(N)$ is randomly partitioned into $n$ disjoint subsets $cal(N)_1, cal(N)_2, dots, cal(N)_n$.
  - *Oversampling of the minority class via SMOTE*: for each partition, the small set of positive (deleterious) examples $cal(P)$ is augmented by generating synthetic positive examples using *SMOTE (Synthetic Minority Oversampling Technique)*.
  - *Undersampling of the majority class*: each negative subset $cal(N)_i$ is randomly subsampled to match a target size proportional to the oversampled positives, yielding a balanced training set $cal(T)_i$ for each partition.

2. *Data coverage improvement and variance reduction*:
  Unlike simple undersampling (which discards most negative examples and loses critical information about the neutral background), partitioning $cal(N)$ across $n$ learners ensures that a large fraction of the negative data is covered across the ensemble, while ensembling reduces model variance.

3. *Hyper-ensembling (ensemble of ensembles)*:
  Each balanced dataset $cal(T)_i$ is used to train a *Random Forest (RF)*—which is itself an ensemble of decision trees. Combining $n$ distinct Random Forests forms a *hyper-ensemble*, enhancing both the accuracy and the diversity of the base learners.

#note(title: "How SMOTE works")[
  Given a *minority-class* example $x in cal(P)$, SMOTE finds its $k$ nearest neighbors within the minority class $cal(P)$. To generate a synthetic positive example, it randomly selects one of these $k$ nearest neighbors $x_"nn"$ and creates a new point via random linear interpolation along the line segment connecting $x$ and $x_"nn"$ in feature space:
  $
    x_"new" = x + lambda (x_"nn" - x), quad lambda in [0, 1]
  $
  Given a positive $x$ mutation, SMOTE find the closest $k$ positive mutations in the feature space and generates a new synthetic mutation by randomly interpolating between $x$ and one of its $k$ neighbors.
]

=== Pseudocode of the HyperSMURF Algorithm

- *Inputs*:
  - $cal(P)$: set of positive examples (deleterious/pathogenic variants).
  - $cal(N)$: set of negative examples (neutral/non-deleterious variants), with $|cal(N)| >> |cal(P)|$.
  - $n$: number of partitions of the negative set (and number of Random Forests in the hyper-ensemble).
  - $k$: number of nearest neighbors for SMOTE oversampling.
  - $f$: oversampling factor for SMOTE (for each positive example, $f$ synthetic examples are generated).
  - $u$ (or fixed ratio): undersampling factor controlling the number of negative examples sampled per partition.

#example()[
  *HyperSMURF Training and Inference Algorithm*:
  1. *Initialization and partitioning of $cal(N)$*:
    - Compute the total number of positive examples after oversampling: $n_"ex" := (f + 1) |cal(P)|$ (or set target negative size to $u dot (f + 1) |cal(P)|$).
    - Partition the negative set into $n$ disjoint subsets:
      $
        {cal(N)_1, cal(N)_2, dots, cal(N)_n} := "Do.partition"(cal(N), n)
      $
  2. *Iterative training over partitions* (for $i = 1$ to $n$):
    - *SMOTE oversampling*: generate $f |cal(P)|$ synthetic positive examples:
      $
        cal(P)_S := "SMOTE"(cal(P), k, f)
      $
    - *Undersampling of non-deleterious variants*: subsample negative examples from the $i$-th partition $cal(N)_i$:
      $
        cal(N)'_i := "Undersample"(cal(N)_i, u dot n_"ex")
      $
    - *Training set assembly*: combine original positives, synthetic positives, and subsampled negatives:
      $
        cal(T)_i := cal(P) union cal(P)_S union cal(N)'_i
      $
    - *Random Forest training*: train the $i$-th Random Forest model on the balanced set $cal(T)_i$:
      $
        M_i := "RF"(cal(T)_i)
      $
  3. *Output of training*: a hyper-ensemble of $n$ Random Forest models $cal(M) = {M_1, M_2, dots, M_n}$.
  4. *Prediction on a test variant $x$*: the final *HyperSMURF score* is computed by averaging the positive-class probability predictions across all $n$ Random Forests:
    $
      "Hy"_"score"(x) := 1 / n sum_(i=1)^n P(x "is positive" | M_i)
    $
]

== Experimental Setup and Comparative Results

HyperSMURF was evaluated on two major genome-wide benchmarks for non-coding variant prediction:

1. *Mendelian diseases dataset*:
  - *Positives*: $406$ manually curated non-coding regulatory SNV mutations known to cause Mendelian diseases.
  - *Negatives*: $\sim 14$ million neutral non-coding variants (derived from CADD-like human-chimpanzee ancestral genome comparisons).
  - *Features ($26$ genomic attributes)*: downloaded from public databases (UCSC, ENCODE, NCBI), comprising evolutionary conservation scores, transcriptional and regulation features, GC content, epigenomic marks (histone modifications, DNase I accessibility)

2. *Complex diseases (GWAS) dataset*:
  - *Positives*: $2,115$ regulatory disease-associated SNVs from the NHGRI *GWAS Catalog*.
  - *Negatives*: $\sim 1.4$ million neutral non-coding variants.
  - *Features ($1,842$ attributes)*: the exact $1,842$ sequence-derived epigenetic perturbation and conservation features extracted directly by *DeepSEA* (Zhou & Troyanskaya, 2015).

=== Cytoband-Aware Cross-Validation and Performance

To prevent *data leakage* caused by genomic proximity (variants located close to each other on the same chromosome share linkage disequilibrium, similar GC content, and overlapping epigenomic annotations), evaluation was performed using *10-fold cytoband-aware cross-validation*: all variants falling within the same chromosomal cytogenetic band are strictly kept within the same fold (never split between training and test sets). In this way, the model is forced to generalize to unseen genomic regions rather than memorizing local patterns  from nearby variants.


#note()[
  Because of the extreme class imbalance, methods were compared using *Precision-Recall curves* and the *Area Under the Precision-Recall Curve (AUPRC)* rather than AUROC.

  The AUROC metric is misleading in this context because, under extreme imbalance, the False Positive Rate remains artificially small even when the absolute number of false positives is huge.

  AUPRC (Area Under Precision curve) measures how well the model balances precision and recall across thresholds. In other words, it measures *how well the model is at catching true positives without having too many false positives*.
]


=== Integration in the Genomiser Pipeline

The *ReMM / HyperSMURF* pathogenicity score for non-coding variants is embedded in *Genomiser*, the state-of-the-art clinical pipeline for identifying causative mutations in whole-genome sequencing (WGS) data of patients with rare Mendelian diseases.

Genomiser combines two orthogonal sources of evidence:
1. *Variant filtration and pathogenicity scoring*: starting from $\sim 4.2$ million variants in a patient's WGS, variants are filtered by quality, inheritance mode, and allele rarity in population databases (down to $\sim 30"k"$ rare variants). Coding variants are scored with tools like *PolyPhen*, while non-coding regulatory variants are scored using *ReMM / HyperSMURF*.
2. *Phenotype similarity (Monarch Initiative)*: the patient's clinical phenotype profile (encoded via Human Phenotype Ontology terms) is compared against known gene-phenotype associations across human and model organisms (mouse, zebrafish).

Finally, Genomiser combines the variant pathogenicity score and the gene-phenotype similarity score to rank candidate causative variants, successfully pinpointing the true disease-causing mutation among the top candidates.

== Hyperparameter Tuning and ParSMURF (HPC Extension)

=== Impact of Hyperparameters

While effective, HyperSMURF's learning process depends on several hyperparameters divided into two levels:
- *Hyper-ensemble parameters*:
  - $n$: number of partitions / Random Forests in the hyper-ensemble.
  - $f$: SMOTE oversampling factor for the positive class.
  - $u$: undersampling factor for the negative class (ratio of negatives to positives in each balanced training set).
- *Base ensemble (Random Forest) parameters*:
  - $t$: number of decision trees in each Random Forest.
  - $m$: number of randomly selected features considered at each tree split ($m_"try"$).
  - $k$: number of nearest neighbors in SMOTE.

These parameters strongly impact data coverage, the balance between deleterious and neutral variants, the informativeness of synthetic positive examples, the diversity of the base learners, and computational runtime.

An experimental tuning study on the Mendelian dataset (training $100$ HyperSMURF configurations via internal cytoband-aware cross-validation on the CINECA Marconi HPC cluster) demonstrated that tuning significantly boosts performance on an independent test set compared to default parameters ($n=100, f=2, u=3$):
- *Best tuned model* ($n=300, f=1, u=10$): increased test *AUPRC* from $0.3568$ (default) to $0.4156$, and $"AUROC"_(50)$ (ranking within the top 50 predictions) from $0.8600$ to $0.9220$.

=== Computational Bottlenecks and ParSMURF

- *Computational drawback*: training and testing a single HyperSMURF model on millions of variants requires from $2$ to $20$ hours on high-end Xeon processors with $128 { "GB"}$ of RAM, and scales poorly when using thousands of deep-learning sequence features (such as the $1,842$ DeepSEA features) or performing extensive grid/random search for hyperparameter tuning.
- *ParSMURF* (Petrini et al., *GigaScience*, 2020): to overcome this limitation, *ParSMURF* introduces a high-performance computing (HPC) parallel architecture based on a *hybrid multi-process and multi-thread implementation*:
  - *Coarse-grained parallelism (MPI processes)*: the $n$ partitions of the hyper-ensemble are distributed across multiple cluster nodes via *MPI (Message Passing Interface)*. Each MPI process handles a subset of the partitions independently.
  - *Fine-grained parallelism (Multi-threading)*: within each computing node, local pools of threads parallelize the SMOTE $k$-NN search and the training/evaluation of the decision trees inside each Random Forest.

This flexible HPC design enables rapid hyperparameter auto-tuning and makes it feasible to scale hyper-ensemble learning to massive multi-omics datasets characterized by extreme class imbalance.
