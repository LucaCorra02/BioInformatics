#import "../template.typ": *

#import "../template.typ": *

= Patient Similarity Networks and Multi-View Data Integration

== Clinical Outcome Prediction: Inductive vs. Transductive Paradigms

A primary goal in biomedical machine learning is *clinical outcome prediction* (e.g., predicting drug response, prognosis, diagnosis, disease recurrence, or patient risk stratification) from multimodal and longitudinal biomedical data. However, real-world clinical and omics datasets present major methodological challenges:
- *High-Dimensional Small Sample Size (HDSSS)*: the number of measured features $m$ (e.g., tens of thousands of genes or epigenetic marks) is vastly larger than the number of available patients $n$ ($m >> n$).
- *Missing data*: clinical records and multi-omics cohorts suffer from both sporadic missing values and completely missing modalities (views).
- *Multimodality*: integrating heterogeneous sources (genomics, transcriptomics, proteomics, clinical laboratory tests, radiological imaging, and longitudinal records).
- *Interpretability and Explainability*: to achieve translational impact in clinical practice, predictive models cannot act as black boxes; clinicians require transparent explanations of *why* a specific prediction or risk score was assigned.

State-of-the-art methods for clinical outcome prediction follow two distinct learning paradigms:

1. *Inductive Supervised Models*:
  - *Induction* is the process of reasoning from observed training cases to infer *general rules* (a predictive model), which are subsequently applied to unseen test cases:
    $
      "Training Data" arrow.r "Learning Algorithm (Infer Rules)" arrow.r "General Model" arrow.r "Test Predictions"
    $
  - Classical examples include Support Vector Machines (SVMs), Random Forests (RFs), Gradient Boosting (XGBoost), Penalized Generalized Linear Models (`glmnet`), and Feedforward Neural Networks.
  - *$mr("Limitation")$*: inductive models treat each patient as an independent sample vector and *do not explicitly account for mutual relationships or similarities among individuals*.

2. *Transductive Semi-Supervised Models (Network-based)*:
  - *Transduction* is the process of reasoning directly from observed, specific training cases to specific test cases by observing all data (both labeled and unlabeled samples) beforehand.
  - In *Network Medicine*, transduction is realized through *Patient Similarity Networks (PSNs)* constructed from subjects' biomolecular and clinical profiles.
  - *$mg("Advantage")$*: transductive PSN models explicitly leverage both the *pairwise topological relationships among patients* and the distribution of *unlabeled data* during inference, offering a naturally visualizable and interpretable clinical framework.

#example()[
  *Intuitive comparison: Inductive ($k$-NN) vs. Transductive (Network-based) classification*
  Suppose we have a set of patients where only two extreme groups are labeled: red nodes ($A, B$) and green nodes ($C, D$), while all intermediate nodes ($1, dots, 14$) are unlabeled.
  - An *inductive $k$-NN classifier* looks only at the Euclidean distance to the *labeled* training points ($A, B, C, D$), completely ignoring the density and connectivity of the unlabeled points in between.
  - A *transductive network-based model* propagates labels step-by-step across the edges connecting all nodes (labeled and unlabeled), respecting the global geometry and community structure of the patient network.
]

== Case Study: Explainable Inductive ML for COVID-19 Risk Prediction

Before moving to transductive PSNs, a representative example of an explainable *inductive* workflow is the early assessment of *COVID-19 risk prediction* in Emergency Departments (Casiraghi et al., *IEEE Access*, 2020; Esposito et al., *Reports in Medical Imaging*, 2021).

- *Dataset and Clinical Task*: $301$ COVID-19 positive patients admitted to the Emergency Department, described by heterogeneous variables: patient demographics (age, sex), clinical symptoms and comorbidities (dyspnea, respiratory failure, hypertension, diabetes, neoplasia), biochemical/laboratory blood tests (CRP, lymphocytes, white blood cells, platelets, ALT, arterial oxygen saturation $"PaO"_2 / "FiO"_2$ and $"SpO"_2$), and qualitative Chest X-Ray (CXR) radiological severity scores.
- *Target*: binary stratification into *Low/Moderate Risk* ($214$ patients: treated at home or hospitalized without intubation/death) versus *Severe Risk* ($87$ patients: intubated or deceased).

=== Handling Missing Clinical Data (MCAR and Imputation)

Statistical testing (Jamshidian and Jalal's test for homoscedasticity and multivariate normality via the `MissMech` package) confirmed that missing values in the clinical cohort were *Missing Completely At Random (MCAR)*. Two main imputation strategies were compared:

1. *Multiple Imputation (e.g., MICE with Predictive Mean Matching `PMM-mice` or Random Forests `RF-mice`)*:
  - Instead of filling in a single value, the incomplete dataset is imputed $M$ times (e.g., $M = 5$) to generate $M$ distinct complete datasets.
  - Each of the $M$ imputed datasets is analyzed independently to obtain a model parameter estimate $hat(theta)_j$ and its within-imputation variance $W_j$ ($j = 1, dots, M$).
  - Finally, the $M$ estimates are combined into a single pooled result using *Rubin's Rules*, and statistical significance is assessed via the *Wald test*, accounting for both within-imputation and between-imputation variance.

2. *Non-parametric Single Imputation via `missForest`* (Stekhoven & Bühlmann, *Bioinformatics*, 2012):
  - Iteratively trains a Random Forest on observed values to predict missing values for both continuous and categorical (mixed-type) variables.
  - Empirically, `missForest` achieved the *lowest between-imputation variance* and preserved feature importance rankings consistently with `miceRF`.

=== Validation Pipeline and Explainability via Associative Trees

To avoid any data leakage during model evaluation, the inductive pipeline embeds all learning steps inside an *External 10-fold Stratified Cross-Validation*:
1. *Pre-screening via CXR cut-off*: on each training fold, ROC analysis determines an optimal Chest X-Ray (`Radio.Score`) threshold to immediately filter out clearly mild/moderate cases.
2. *Feature Selection via Boruta*: on the remaining uncertain cases in the training fold, the *Boruta* wrapper algorithm (using an internal 5-fold cross-validation) selects all statistically relevant features by comparing real feature importance against randomized "shadow features" in a Random Forest (identifying key drivers such as $"SpO"_2$, $"PaO"_2 / "FiO"_2$, white blood cells, lymphocytes, CRP, number of comorbidities, and age).
3. *Model Induction and Rule Extraction (Associative Trees)*:
  - A *Random Forest (RF)* classifier is trained on the selected features (outperforming XGBoost, SVMs, `glmnet`, and feedforward neural networks).
  - Because an ensemble of ratusan of trees is not directly readable by emergency physicians, *rule extraction* is performed: individual decision paths from the trees in the forest are extracted, simplified, pruned, and merged into a single *Associative Tree* (a hierarchical decision list of `IF-THEN-ELSE` rules: $"Condition"_1 arrow.r "Severe Risk"; "else Condition"_2 arrow.r dots$).
  - This provides doctors with an actionable, transparent clinical checklist.

== Unimodal Patient Similarity Networks and the P-Net Algorithm

=== From Biomarker Networks to Patient Similarity Networks

In *Network Medicine*, biological and clinical systems are modeled at multiple interconnected layers:
- *Biomolecular / Biomarker Networks (e.g., PPI networks)*:
  - *Nodes*: genes or proteins.
  - *Edges*: functional or physical similarity/interactions among biomarkers.
  - *Tasks*: identify and prioritize disease biomarkers, discover novel molecular interactions.
- *Patient Similarity Networks (PSNs)*:
  - *Nodes*: patients $V = {p_1, p_2, dots, p_n}$.
  - *Edges*: pairwise similarity between patients' biomolecular or clinical profiles.
  - *Tasks*: clinical outcome/phenotype prediction (e.g., recurrence vs. no recurrence after 5 years) and patient subtype stratification.

#note(title: "Formal Graph Notation")[
  - An *unweighted undirected graph* is a pair $G = (V, E)$, where $V$ is the vertex set ($|V| = n$) and $E subset.eq V times V$ is the edge set, represented by a binary symmetric adjacency matrix $A in {0, 1}^(n times n)$ with $A_(i j) = 1$ if $(i, j) in E$ and $0$ otherwise.
  - A *weighted undirected graph* is a triplet $G = (V, E, W)$, where $W in RR_(>= 0)^(n times n)$ is a real-valued symmetric *similarity (or affinity) matrix* whose entry $w_(i j)$ quantifies the connection strength between nodes $i$ and $j$.
]

=== The P-Net Algorithm: Step-by-Step Pipeline

*P-Net* (Gliozzo et al., *Scientific Reports*, 2020) is a transductive, semi-supervised network algorithm for clinical outcome prediction on unimodal data (such as a single gene-expression view). It consists of *five main steps*:

==== Step 1 & 2: Data Collection, Cleaning, and Dimensionality Reduction
Each patient $p_i$ ($i = 1, dots, n$) is characterized by an $m$-dimensional feature vector (e.g., gene expression profile), forming a patient matrix $M in RR^(m times n)$ (or $n times m$). Since omics data is plagued by the *HDSSS* problem ($m >> n$), rigorous preprocessing is applied:
1. *Data filtering and cleaning*:
  - Discard features (genes) with *low variance* across patients (uninformative).
  - Discard redundant features by filtering out pairs with *high pairwise correlation*.
  - Discard features with an excessive fraction of missing values, and *impute* the remaining sporadic missing values.
2. *Dimensionality Reduction (DR)* to mitigate the curse of dimensionality:
  - *Supervised Feature Selection* (must be performed *strictly on the training set* to avoid data leakage!):
    - *Univariate methods*: statistical hypothesis tests (t-test, Wilcoxon), correlation tests, Mutual Information (MI), Maximal Information Coefficient (MIC).
    - *Multivariate methods*: Minimum Redundancy Maximum Relevance (mRMR), Recursive Feature Elimination/Addition (RFE), Genetic Algorithms, Random Forest importance / Boruta, or Lasso/Elastic-Net regularized generalized linear models.
  - *Unsupervised Feature Selection / Extraction*: univariate/multivariate unsupervised filters or latent space projections (guided by *Intrinsic Dimensionality*, see Section 1.4).

==== Step 3: PSN Construction and Graph Kernel Projection
1. *Initial Weighted PSN Construction ($W$)*: from the cleaned, reduced patient matrix $M$, compute the pairwise similarity matrix $W in RR^(n times n)$ between all pairs of patients using a suitable similarity metric:
  - *Inner product (Linear kernel)*: $W(x_i, x_j) = x_i^T x_j$
  - *Pearson correlation*: $W(x_i, x_j) = "corr"(x_i, x_j)$
  - *Scaled Euclidean (Gaussian / RBF kernel)*: $W(x_i, x_j) = exp(- norm(x_i - x_j)^2 / (2 sigma^2))$
2. *Projection into Kernel Space ($K$)*: to capture the *global topology* of the network rather than just direct 1-hop connections, the graph $W$ is projected into a high-dimensional Reproducing Kernel Hilbert Space (RKHS) via a *Graph Kernel*, specifically the *$p$-step Random Walk (RW) Kernel* (Smola & Kondor, 2003):
  - The *1-step Random Walk Kernel* Gram matrix $K in RR^(n times n)$ is defined as:
    $
      K_"1-step" = (a - 1) I + D^(-1/2) W D^(-1/2)
    $
    where $I$ is the $n times n$ identity matrix, $D = "diag"(d_(1 1), dots, d_(n n))$ is the diagonal degree matrix with $d_(i i) = sum_j W_(i j)$, and $a > 1$ (or $alpha > 1$) is a real parameter that balances the probability of staying at the starting node versus stepping to a neighbor.
  - The *$p$-step Random Walk Kernel* executes random walks of length $p$ by raising the 1-step matrix to the power $p$:
    $
      K = K_"p-step" = ((a - 1) I + D^(-1/2) W D^(-1/2))^p
    $

#note(title: "Why use a Graph Kernel on a PSN?")[
  In the original input space, two patients $x_i$ and $x_j$ might not be direct neighbors (e.g., low direct similarity $W_(i j)$). However, the non-linear mapping $phi: cal(X) arrow.r cal(H)$ induced by the $p$-step Random Walk Kernel computes inner products $K(x_i, x_j) = < phi(x_i), phi(x_j) >$ that account for *both direct neighbors ($p = 1$) and indirect multi-step paths ($p >= 2$)* across the entire graph. Thus, patients that belong to the same topological cluster become close neighbors in the Hilbert space $cal(H)$ even if they were not directly linked in the original network.
]

==== Step 4: Filtering Weak Similarities via Leave-One-Out (LOO)
Because raising the kernel matrix to the power $p$ densifies the graph (creating edges between almost all node pairs), weak kernel similarities introduce topological noise. P-Net applies an efficient *Leave-One-Out (LOO)* cross-validation procedure on the labeled training set to learn an optimal threshold (or top-$k$ cutoff) that zeroes out weak entries in $K$, producing a sparse *Filtered Kernel Matrix*.

==== Step 5: Patient Scoring via Kernelized Score Functions
Finally, each patient $i in V$ is assigned a continuous score $S: V arrow.r RR^+$ proportional to the likelihood of belonging to the target clinical phenotype/outcome class $C$ (where $V_C subset V$ denotes the subset of known *positive training patients* associated with phenotype $C$, and $V backslash V_C$ denotes the negative training patients).

By leveraging the *RANKS* framework (Valentini et al., *Bioinformatics*, 2016), P-Net combines the *global network topology* (encoded in the $i$-th row $K_i$ of the kernel matrix $K$, with elements $k_(i j)$) with *local neighborhood aggregation* through six possible *Kernelized Score Functions*:

#table(
  columns: (1.3fr, 2.7fr),
  align: (left + horizon, left + horizon),
  stroke: 0.5pt + gray,
  inset: 7pt,
  [*Score Name*], [*Mathematical Formulation*],
  [*1. Average ($S_"AV"$)*], [$ S_"AV" (i, K_i, V_C) = 1 / (|V_C|) sum_(j in V_C) k_(i j) $],
  [*2. Nearest Neighbor ($S_"NN"$)*], [$ S_"NN" (i, K_i, V_C) = max_(j in V_C) k_(i j) $],
  [*3. $k$-Nearest Neighbor ($S_"kNN"$)*],
  [$ S_"kNN" (i, K_i, V_C) = 1 / (|I_k (i)|) sum_(j in I_k (i)) k_(i j) $\ where $I_k (i) = {j | j in V_C and "rank"(k_(i j)) <= k}$],

  [*4. Total ($S_"TOT"$)*],
  [$
    S_"TOT" (i, K_i, V_C) = (sum_(j in V_C) k_(i j)) / (sum_(j in V_C) k_(i j) + sum_(j in V backslash V_C) k_(i j))
  $],

  [*5. Differential ($S_"Diff"$)*],
  [$ S_"Diff" (i, K_i, V_C) = sum_(j in V_C) k_(i j) - sum_(j in V backslash V_C) k_(i j) $],

  [*6. Differential Normalized ($S_"Dnorm"$)*],
  [$
    S_"Dnorm" (i, K_i, V_C) = (sum_(j in V_C) k_(i j) - sum_(j in V backslash V_C) k_(i j)) / (sum_(j in V_C) k_(i j) + sum_(j in V backslash V_C) k_(i j))
  $],
)

#note()[
  Notice that while $S_"AV"$, $S_"NN"$, and $S_"kNN"$ only measure similarity with respect to the positive patients $V_C$ (useful in one-class or positive-unlabeled settings), *Total ($S_"TOT"$)*, *Differential ($S_"Diff"$)*, and *Differential Normalized ($S_"Dnorm"$)* explicitly contrast the similarity to positive patients ($V_C$) against the similarity to negative patients ($V backslash V_C$).
]

== Guiding Dimensionality Reduction via Intrinsic Dimensionality (ID)

When dealing with *HDSSS* multi-omics views (e.g., mRNA, miRNA, DNA methylation, protein expression in TCGA cancer cohorts), choosing *how* to reduce dimensionality and *how many* features/dimensions $d$ to retain is non-trivial.

- *Intrinsic Dimensionality (ID)*: informally, the ID of a dataset is the minimum dimension of the latent space (manifold) onto which the data points can be projected via a smooth mapping without losing information (e.g., 3D points lying flat on a 2D sheet of paper have $"ID" = 2$).
- *Block-ID Analysis* (Gliozzo et al., *Artificial Intelligence in Medicine*, 2024): by subsampling blocks of features of increasing size $L$ and estimating their ID (using the *TWO-NN estimator* $hat(d)_"twonn"$), we can plot the block-ID curve as a function of block dimension:
  - In high-dimensional views like *mRNA* or *DNA methylation*, the block-ID curve rises and then hits a clear *plateau* at $L_p$ features (with cumulative mean ID value $"cum"(hat(d)_(L_p))$ and total standard deviation $sigma("cum"(hat(d)_(L_p)))$). A plateau indicates that adding more features beyond $L_p$ only introduces *redundancy and noise*.
  - In smaller views like *miRNA* or *protein*, the curve keeps growing without reaching a plateau, meaning all features carry non-redundant information.

This leads to a principled, automated decision workflow for each view $bold(X)$:
1. *If Block-Analysis finds a plateau at $L_p$* (redundant/noisy features present):
  - *If using Feature Selection (FS)*: apply unsupervised FS (e.g., *Iterative RCUR*, *Feature Clustering*, or *Entropy Filtering*) to select $L_p$ representative features.
  - *If using Feature Extraction (FE) or (FS + FE)*: project the data (via *RPCA*, *Laplacian Eigenmaps*, *UMAP*, or *t-SNE*) to target dimension:
    $
      d = "cum"(hat(d)_(L_p)) + 3 times sigma("cum"(hat(d)_(L_p)))
    $
2. *If Block-Analysis does NOT find a plateau* (no redundancy; FS would discard salient biological information!):
  - *Skip Feature Selection (FS)* completely.
  - Perform Dimensionality Reduction *only via Feature Extraction (FE)*, projecting the view $bold(X)$ to target dimension guided by the global TWO-NN estimate:
    $
      d = hat(d)_"twonn" (bold(X)) + 3 times sigma(hat(d)_"twonn" (bold(X)))
    $

== From Unimodal to Multi-Modal PSN Integration

Single-omics analyses suffer from "blind-spot" limitations (like the parable of the blind men touching different parts of an elephant: epigenomics, transcriptomics, proteomics, and metabolomics each observe only one stage of the Central Dogma of Molecular Biology). Because of *patient heterogeneity*, patients with the same clinical diagnosis may respond very differently to the same therapy; *Precision Medicine* requires integrating multi-omics views to stratify patients and tailor personalized treatments.

=== Taxonomies of Multi-Modal Data Integration

In the literature (Adali et al., 2018; Wu et al., 2019; Ritchie et al., 2015), dataset integration is first divided by *integration flow*:
- *Horizontal integration* (on *multiset / homogeneous datasets*): integrating the *same* data modality (e.g., mRNA) measured across different cohorts or conditions.
- *Vertical integration* (on *multimodal / heterogeneous datasets*): integrating *different* data modalities (e.g., methylation + mRNA + protein) measured on the *same* set of patients. Vertical integration is further split into *hierarchical-vertical* (multi-staged, modeling explicit regulatory cascades like $"methylation" arrow.r "mRNA" arrow.r "protein"$) and *parallel-vertical* (meta-dimensional analysis, treating views symmetrically).

For *parallel-vertical integration on Patient Similarity Networks*, methods are categorized into three families according to *when* the fusion happens (Gliozzo et al., *Briefings in Bioinformatics*, 2022):

#figure(
  caption: [Categorization of multi-modal PSN integration methods: (1) Early / Input-data integration, (2) Intermediate / Model (PSN) integration, and (3) Late / Output-data integration.],
)[
  #align(center)[
    #cetz.canvas(length: 0.8cm, padding: 0.2cm, {
      import cetz.draw: *

      // 1. Early Integration
      content((0, 4.2), anchor: "west", text(weight: "bold", size: 9pt, fill: teal.darken(20%))[
        1. Early (Input-Data) Integration:
      ])
      rect((0, 3.0), (2.2, 3.8), radius: 0.1, fill: gray.lighten(85%))
      content((1.1, 3.4), text(size: 8pt)[Views $X^1, dots, X^m$])
      line((2.2, 3.4), (3.4, 3.4), mark: (end: ">", fill: black))
      rect((3.4, 3.0), (6.4, 3.8), radius: 0.1, fill: teal.lighten(85%), stroke: teal)
      content((4.9, 3.4), text(size: 8pt)[*Fuse Data* (JIVE, intNMF, MOFA)])
      line((6.4, 3.4), (7.6, 3.4), mark: (end: ">", fill: black))
      rect((7.6, 3.0), (10.0, 3.8), radius: 0.1, fill: blue.lighten(85%), stroke: blue)
      content((8.8, 3.4), text(size: 8pt)[Build Single PSN])
      line((10.0, 3.4), (11.2, 3.4), mark: (end: ">", fill: black))
      rect((11.2, 3.0), (14.2, 3.8), radius: 0.1, fill: orange.lighten(85%))
      content((12.7, 3.4), text(size: 8pt)[Classify / Cluster])

      // 2. Intermediate Integration
      content((0, 2.2), anchor: "west", text(weight: "bold", size: 9pt, fill: purple.darken(20%))[
        2. Intermediate (Model / PSN) Integration:
      ])
      rect((0, 1.0), (2.2, 1.8), radius: 0.1, fill: gray.lighten(85%))
      content((1.1, 1.4), text(size: 8pt)[Views $X^1, dots, X^m$])
      line((2.2, 1.4), (3.4, 1.4), mark: (end: ">", fill: black))
      rect((3.4, 1.0), (6.4, 1.8), radius: 0.1, fill: blue.lighten(85%), stroke: blue)
      content((4.9, 1.4), text(size: 8pt)[Build Unimodal PSNs])
      line((6.4, 1.4), (7.6, 1.4), mark: (end: ">", fill: black))
      rect((7.6, 1.0), (10.6, 1.8), radius: 0.1, fill: purple.lighten(85%), stroke: purple)
      content((9.1, 1.4), text(size: 8pt)[*Fuse PSNs* (SNF, netDx, MSNE)])
      line((10.6, 1.4), (11.5, 1.4), mark: (end: ">", fill: black))
      rect((11.5, 1.0), (14.2, 1.8), radius: 0.1, fill: orange.lighten(85%))
      content((12.85, 1.4), text(size: 8pt)[Classify / Cluster])

      // 3. Late Integration
      content((0, 0.2), anchor: "west", text(weight: "bold", size: 9pt, fill: maroon)[
        3. Late (Output-Data / Consensus) Integration:
      ])
      rect((0, -1.0), (2.2, -0.2), radius: 0.1, fill: gray.lighten(85%))
      content((1.1, -0.6), text(size: 8pt)[Views $X^1, dots, X^m$])
      line((2.2, -0.6), (3.4, -0.6), mark: (end: ">", fill: black))
      rect((3.4, -1.0), (6.4, -0.2), radius: 0.1, fill: blue.lighten(85%), stroke: blue)
      content((4.9, -0.6), text(size: 8pt)[Build Unimodal PSNs])
      line((6.4, -0.6), (7.6, -0.6), mark: (end: ">", fill: black))
      rect((7.6, -1.0), (10.4, -0.2), radius: 0.1, fill: orange.lighten(85%))
      content((9.0, -0.6), text(size: 8pt)[Classify/Cluster Each])
      line((10.4, -0.6), (11.3, -0.6), mark: (end: ">", fill: black))
      rect((11.3, -1.0), (14.2, -0.2), radius: 0.1, fill: red.lighten(85%), stroke: maroon)
      content((12.75, -0.6), text(size: 8pt)[*Fuse Outputs* (SUMO)])
    })
  ]
]

=== Early Integration (Input-Data Fusion & Joint Dimensionality Reduction)

In *Early Integration*, the multi-omics matrices $X^1, X^2, dots, X^m$ are projected into a *joint shared low-dimensional latent space* during pre-processing (often called *Multi-omics Joint Dimensionality Reduction, jDR*, decomposing each view as $X^i approx A^i times F$, where $F$ are shared sample factors and $A^i$ are view-specific metagene loadings). A single PSN is then built from the integrated latent coordinates.

The three main early-integration algorithms are *JIVE*, *intNMF*, and *MOFA*:

==== 1. JIVE (Joint and Individual Variation Explained — Lock et al., 2013)
*JIVE* is a PCA-based extension that decomposes each data view $X_i$ ($i = 1, dots, k$) into three orthogonal components:
$
  X_i = J_i + A_i + epsilon_i
$
where $J = [J_1^T, dots, J_k^T]^T$ is the low-rank *joint structure* shared across all views, $A_i$ is the low-rank *individual (view-specific) variation* unique to view $i$, and $epsilon_i$ is residual noise. To ensure identifiability, the joint and individual subspaces are constrained to be *mutually orthogonal* ($J A_i^T = 0$).

#example()[
  *JIVE Iterative SVD Estimation Algorithm*:
  1. *Initialize*: $X^"Joint" = X = [X_1^T, dots, X_k^T]^T$.
  2. *Repeat until convergence*:
    - Estimate the joint matrix $J = [J_1^T, dots, J_k^T]^T$ by computing a *rank-$r$ truncated SVD* of $X^"Joint"$:
      $
        J = U Lambda V^T
      $
    - *For each view* $i = 1, dots, k$:
      - Subtract the joint structure to isolate view-specific residuals: $X_i^"Individual" = X_i - J_i$.
      - Estimate the individual structure $A_i$ by computing a *rank-$r_i$ truncated SVD* of the orthogonal projection:
        $
          X_i^"Individual" (I - V V^T)
        $
        *(Note: multiplying by the projection matrix $I - V V^T$ projects the rows onto the orthogonal complement of $V$, strictly enforcing the orthogonality constraint between $J$ and $A_i$!)*
      - Update the view's joint component: $X_i^"Joint" = X_i - A_i$.
    - Reassemble $X^"Joint" = [(X_1^"Joint")^T, dots, (X_k^"Joint")^T]^T$.
]

==== 2. intNMF (Integrative Non-Negative Matrix Factorization)
*intNMF* applies Non-Negative Matrix Factorization to approximate each non-negative data matrix $X_(n times p_i)^i$ ($i = 1, dots, m$, where $n$ is the number of patients and $p_i$ the number of features in view $i$) as the product of a *shared non-negative patient factor matrix* $W_(n times k) >= 0$ and a *view-specific non-negative loading matrix* $H_(k times p_i)^i >= 0$:
$
  X_(n times p_i)^i approx W_(n times k) H_(k times p_i)^i, quad i = 1, dots, m
$
It minimizes the weighted reconstruction error across all $m$ views:
$
  Q = min_(W >= 0, H^i >= 0) sum_(i=1)^m theta^i norm(X^i - W H^i)_2^2
$
where $theta^i$ are user-defined weights representing the *a priori* importance of each view. The optimization problem is solved via *Non-negative Alternating Least Squares (ALS)*: only $W$ needs to be initialized, and the algorithm alternates between fixing $W$ to solve for each $H^i$ and fixing $H^i$ to update $W$ via constrained least squares.

==== 3. MOFA (Multi-Omics Factor Analysis) and Variational Inference
*MOFA* is a probabilistic Bayesian Generalized Matrix Factorization model:
$
  X^((m)) = Z W^((m) T) + epsilon^((m)), quad m = 1, dots, M
$
where $X^((m)) in RR^(N times D_m)$ is the data matrix of view $m$, $Z in RR^(N times K)$ is the matrix of *shared latent factors* across all views, $W^((m)) in RR^(D_m times K)$ are the view-specific *weights/loadings* (equipped with sparsity-inducing priors so a factor can capture either variation shared across multiple views or variation specific to a single view), and $epsilon^((m))$ is view-specific noise (supporting Gaussian, Bernoulli, or Poisson likelihoods for continuous, binary, and count data).

*Mathematical Derivation of Variational Inference (VI) and ELBO in MOFA*:
In Bayesian inference, given observed data $X$ and latent variables $Z$ (including parameters $theta$), Bayes' theorem gives the posterior distribution:
$
  p(Z | X) = (p(X | Z) p(Z)) / (p(X)) = (p(X, Z)) / (integral p(X, Z) dif Z)
$
Computing the true posterior $p(Z | X)$ directly is *intractable* because the marginal likelihood (model evidence) $p(X) = integral p(X, Z) dif Z$ requires integrating over a high-dimensional latent space.

*Variational Inference (VI)* bypasses this by choosing a tractable family of distributions $cal(Q)$ and finding the distribution $q(Z) in cal(Q)$ that best approximates the true posterior $p(Z | X)$ by minimizing the *Kullback-Leibler (KL) divergence*:
$
  "KL"(q(Z) || p(Z | X)) = EE_(q(Z)) [ log (q(Z)) / (p(Z | X)) ]
$
Substituting $p(Z | X) = p(X, Z) / p(X)$ into the KL divergence and using the properties of logarithms:
$
  "KL"(q(Z) || p(Z | X)) & = EE_(q(Z)) [ log (q(Z)) / (p(X, Z) \/ p(X)) ] \
                         & = EE_(q(Z)) [ log q(Z) - log p(X, Z) + log p(X) ] \
                         & = log p(X) + EE_(q(Z)) [ log q(Z) - log p(X, Z) ]
$
(since $log p(X)$ does not depend on $Z$ and can be pulled outside the expectation $EE_(q(Z))$). Rearranging the equation to isolate the log marginal likelihood $log p(X)$ yields the fundamental identity of Variational Inference:
$
  log p(X) = underbrace(EE_(q(Z)) [log p(X, Z)] - EE_(q(Z)) [log q(Z)], "ELBO " cal(L)(q)) + "KL"(q(Z) || p(Z | X))
$
Since $log p(X, Z) = log(p(X | Z) p(Z)) = log p(X | Z) + log p(Z)$, we can also write the *Evidence Lower Bound (ELBO)* $cal(L)(q)$ in its two-term interpretable form:
$
  cal(L)(q) = underbrace(EE_(q(Z)) [log p(X | Z)], "Reconstruction quality") - underbrace("KL"(q(Z) || p(Z)), "Prior regularization")
$

#note(title: "Why Maximizing the ELBO Minimizes the KL Divergence")[
  Because the KL divergence is always non-negative ($"KL"(q(Z) || p(Z | X)) >= 0$), the ELBO is a *lower bound* on the log model evidence ($L(q) <= log p(X)$). Furthermore, since $log p(X)$ is constant with respect to the variational distribution $q(Z)$, *maximizing the tractable ELBO $L(q)$ is mathematically equivalent to minimizing the intractable KL divergence $"KL"(q(Z) || p(Z | X))$*.
  - The first term $EE_(q(Z))[log p(X | Z)]$ forces the latent variables $Z$ to *explain (reconstruct) the observed multi-omics data well*.
  - The second term $-"KL"(q(Z) || p(Z))$ acts as a regularizer that *prevents the variational posterior $q(Z)$ from drifting too far from the prior $p(Z)$*.
]

=== Intermediate Integration (Model / PSN Fusion)

In *Intermediate Integration*, a separate unimodal PSN is constructed for each data modality using an appropriate similarity measure; these networks are then fused into a single *integrated PSN* prior to clustering or classification.

1. *SNF (Similarity Network Fusion — Wang et al., Nature Methods, 2014)*:
  - Builds a pairwise patient similarity matrix for each view using a scaled exponential Euclidean (Gaussian) kernel:
    $
      W(i, j) = exp(- (rho(x_i, x_j)^2) / (mu epsilon_(i j)))
    $
  - Defines a *global normalized similarity matrix* $P$ (with $P(i, i) = 1/2$ to avoid numerical instability, and $P(i, j) = W(i, j) / (2 sum_(k != i) W(i, k))$ for $j != i$) and a *local normalized similarity matrix* $S$ restricted to the $k$-nearest neighbors $N_i$ ($S(i, j) = W(i, j) / (sum_(k in N_i) W(i, k))$ if $j in N_i$, and $0$ otherwise).
  - Performs *kernel alignment via iterative message passing (diffusion)* across views:
    $
      P_(t+1)^((1)) = S^((1)) times P_t^((2)) times (S^((1)))^T, quad P_(t+1)^((2)) = S^((2)) times P_t^((1)) times (S^((2)))^T
    $
    Element-wise, $P_(t+1)^((1))(i, j) = sum_(k in N_i) sum_(l in N_j) S^((1))(i, k) P_t^((2))(k, l) S^((1))(j, l)$, meaning similarity information between $i$ and $j$ in view $1$ is propagated only if their local neighborhoods $N_i$ and $N_j$ are similar in view $2$. After convergence, the fused network is used for spectral clustering or label propagation.

2. *NEMO (Neighborhood-based Multi-Omics clustering — Rappoport & Shamir, 2019)*:
  - Computes a relative similarity matrix per omics view based on radial basis kernels restricted to local neighborhoods, and averages them across views. Crucially, NEMO can handle *partial multi-omics datasets* (where some patients lack certain views) as long as every pair of patients shares at least one common measured omics layer.

3. *netDx (Supervised PSN Integration — Pai et al., 2019)*:
  - A *supervised* model-integration algorithm for patient classification. For each data type (clinical, gene expression, metabolome, mutations) and each patient class (e.g., high risk vs. low risk), netDx uses cross-validation to score, select, and weight only the PSNs (features/pathways) that are *predictive of that specific class*. The selected PSNs are integrated into a single network, and unseen patients are classified based on their relative diffusion similarity to known classes.

4. *MSNE (Multiple Similarity Network Embedding — Xu et al., 2021)*:
  - Builds multiple unimodal similarity networks (e.g., mRNA, miRNA, methylation) and stacks them as a multi-layer network.
  - Performs *Random Walks with Lévy flights* across the networks (allowing the walker to either step to a neighbor within the same omics layer or *jump across layers* to another omics view for the same sample).
  - Feeds the sampled multi-view node sequences into a *Skip-Gram* model to learn low-dimensional patient embeddings for cancer subtyping.

=== Late Integration (Output-Data / Consensus Fusion)

In *Late Integration*, unimodal PSNs are built and analyzed (clustered or classified) *completely independently* for each data modality. The separate outputs are then combined at the very end using consensus aggregation or meta-models:
- *PINSplus* (Perturbation Clustering for data INtegration and disease Subtyping, Nguyen et al., 2018): perturbs each omics data view by adding Gaussian noise to find stable patient partitions within each view, and then constructs a cross-view agreement matrix to identify consensus tumor subtypes.
- *SUMO* (Subtyping Multi-Omics data, Sienkiewicz et al., 2022): builds unimodal patient similarity networks and performs *joint symmetric Non-Negative Matrix Tri-Factorization* on the multiplexed similarity matrices to extract consensus molecular subtypes.

= Deep Graph Representation Learning: Graph Neural Networks (GNNs)

== From Shallow Encoders to Deep Graph Neural Networks

=== Recap of Node Embedding: Encoder-Decoder Framework

The goal of node embedding is to map each node $v in V$ to a low-dimensional vector $bold(z)_v in RR^d$ such that geometric similarity in the embedding space approximates topological similarity in the original graph. This involves two key components:
1. *Encoder*: a function $"ENC": V arrow.r RR^d$ that maps node $v$ to its embedding:
  $
    "ENC"(v) = bold(z)_v in RR^d
  $
2. *Similarity Function (Decoder)*: specifies how vector relationships in $RR^d$ map to network relationships in $G$, typically via the dot product:
  $
    "similarity"(u, v) approx bold(z)_v^T bold(z)_u
  $

=== Limitations of "Shallow" Encoders

Methods like *DeepWalk* and *node2vec* use a *"shallow" encoder*, where $"ENC"(v)$ is simply an *embedding lookup* corresponding to the $v$-th column of a learnable matrix $bold(Z) in RR^(d times |V|)$:
$
  "ENC"(v) = bold(Z) bold(v), quad "where " bold(v) in {0, 1}^(|V|) "is a one-hot indicator vector"
$
While effective, shallow encoders suffer from three severe limitations:
1. *$O(|V|)$ parameter complexity*: there is *no parameter sharing* between nodes; every node has its own independent embedding vector, so the number of parameters grows linearly with the size of the graph $|V|$ (intractable for massive graphs).
2. *Inherently transductive*: shallow encoders can only generate embeddings for nodes that were present during training; it is *impossible to generate embeddings for new, unseen nodes* (or entirely new graphs) without retraining the lookup table.
3. *Failure to incorporate node features/attributes*: shallow encoders rely solely on graph topology and cannot natively leverage rich node features $bold(X)$ during the encoding process (features can only be concatenated *post hoc*).

== Fundamentals of Graph Neural Networks (GNNs)

=== Problem Setup and Neighborhood Computation Graphs

To overcome the limitations of shallow encoders, *Graph Neural Networks (GNNs)* define deep, feature-dependent encoders $"ENC"(v)$ that combine *graph topology* and *node attributes*.

Assume we are given a graph $G = (V, E)$ with:
- $V$: the vertex set.
- $bold(A)$: the binary (or weighted) adjacency matrix.
- $bold(X) in RR^(m times |V|)$: a matrix of *node features* (e.g., gene expression profiles, categorical clinical attributes, molecular atom descriptors, or structural topological indicators/one-hot vectors if no external features exist).

*Core Intuition (Neighborhood Aggregation)*: a node's representation is generated by iteratively aggregating and transforming information ("messages") from its local graph neighborhood using neural networks:
- Every target node $v in V$ defines its own *unique tree-structured computation graph* determined by unfolding its $K$-hop network neighborhood around $v$.
- Nodes have embeddings at each layer $k in {0, 1, dots, K}$:
  - The *Layer-0 embedding* of node $u$ is simply its input feature vector: $bold(h)_u^0 = bold(x)_u$.
  - A *Layer-$k$ embedding* $bold(h)_v^k$ aggregates information from nodes that are $k$ hops away from $v$ (functioning like a spatial center-surround convolutional filter over the graph).

#figure(
  caption: [A 2-layer GNN computation graph for target node $A$. At Layer 0, inputs are node features $bold(x)_u$. Each grey box aggregates messages from a node's neighbors and applies a neural network transformation to produce the next layer's embedding, culminating in $bold(z)_A = bold(h)_A^2$.],
)[
  #align(center)[
    #cetz.canvas(length: 0.85cm, padding: 0.2cm, {
      import cetz.draw: *

      // Left: Input Graph
      content((1.5, 4.3), text(weight: "bold", size: 9pt)[Input Graph $G$])
      let pA = (1.0, 2.2)
      let pB = (2.2, 3.5)
      let pC = (2.6, 2.0)
      let pD = (0.3, 0.7)
      let pE = (1.8, 0.5)
      let pF = (3.3, 0.9)

      line(pA, pB, stroke: 1pt + black)
      line(pA, pC, stroke: 1pt + black)
      line(pA, pD, stroke: 1pt + black)
      line(pB, pC, stroke: 1pt + black)
      line(pC, pE, stroke: 1pt + black)
      line(pC, pF, stroke: 1pt + black)
      line(pE, pF, stroke: 1pt + black)

      circle(pA, radius: 0.32, fill: yellow.darken(10%), stroke: 1.5pt + black)
      content(pA, text(weight: "bold", size: 8.5pt)[A])
      circle(pB, radius: 0.3, fill: red.lighten(20%), stroke: 1pt + black)
      content(pB, text(weight: "bold", size: 8.5pt, fill: white)[B])
      circle(pC, radius: 0.3, fill: green.darken(10%), stroke: 1pt + black)
      content(pC, text(weight: "bold", size: 8.5pt, fill: white)[C])
      circle(pD, radius: 0.3, fill: blue.lighten(20%), stroke: 1pt + black)
      content(pD, text(weight: "bold", size: 8.5pt, fill: white)[D])
      circle(pE, radius: 0.3, fill: purple.lighten(20%), stroke: 1pt + black)
      content(pE, text(weight: "bold", size: 8.5pt, fill: white)[E])
      circle(pF, radius: 0.3, fill: fuchsia.lighten(20%), stroke: 1pt + black)
      content(pF, text(weight: "bold", size: 8.5pt)[F])

      // Right: Computation Graph for Node A
      content((9.5, 4.3), text(weight: "bold", size: 9pt)[Computation Graph for Target Node A])
      content((5.5, -0.3), text(size: 8pt, weight: "bold")[Layer 2])
      content((8.8, -0.3), text(size: 8pt, weight: "bold")[Layer 1])
      content((12.8, -0.3), text(size: 8pt, weight: "bold")[Layer 0 (Features)])

      // Target A and Box 2
      circle((4.8, 2.0), radius: 0.32, fill: yellow.darken(10%), stroke: 1.5pt + black)
      content((4.8, 2.0), text(weight: "bold", size: 8.5pt)[A])
      content((4.0, 2.0), text(weight: "bold", size: 9.5pt)[$bold(z)_A$])
      rect((5.6, 1.4), (6.6, 2.6), fill: gray.lighten(70%), stroke: 1pt + black)
      content((6.1, 2.0), text(size: 7.5pt)[AGG\ + NN])
      line((5.6, 2.0), (5.12, 2.0), mark: (end: ">", fill: black))

      // Layer 1 nodes: B, C, D
      let l1B = (8.3, 3.4)
      let l1C = (8.3, 2.0)
      let l1D = (8.3, 0.6)

      line((8.0, 3.4), (6.6, 2.3), stroke: (dash: "dotted", thickness: 1pt), mark: (end: ">", fill: black))
      line((8.0, 2.0), (6.6, 2.0), stroke: (dash: "dotted", thickness: 1pt), mark: (end: ">", fill: black))
      line((8.0, 0.6), (6.6, 1.7), stroke: (dash: "dotted", thickness: 1pt), mark: (end: ">", fill: black))

      circle(l1B, radius: 0.28, fill: red.lighten(20%), stroke: 1pt + black)
      content(l1B, text(size: 8pt, fill: white, weight: "bold")[B])
      circle(l1C, radius: 0.28, fill: green.darken(10%), stroke: 1pt + black)
      content(l1C, text(size: 8pt, fill: white, weight: "bold")[C])
      circle(l1D, radius: 0.28, fill: blue.lighten(20%), stroke: 1pt + black)
      content(l1D, text(size: 8pt, fill: white, weight: "bold")[D])

      // Layer 1 Boxes
      rect((9.1, 3.1), (9.8, 3.7), fill: gray.darken(20%), stroke: 0.8pt + black)
      line((9.1, 3.4), (8.58, 3.4), mark: (end: ">", fill: black))

      rect((9.1, 1.7), (9.8, 2.3), fill: gray.darken(20%), stroke: 0.8pt + black)
      line((9.1, 2.0), (8.58, 2.0), mark: (end: ">", fill: black))

      rect((9.1, 0.3), (9.8, 0.9), fill: gray.darken(20%), stroke: 0.8pt + black)
      line((9.1, 0.6), (8.58, 0.6), mark: (end: ">", fill: black))

      // Layer 0 nodes (inputs to B: A, C; inputs to C: A, B, E, F; inputs to D: A)
      let l0 = (
        (11.8, 3.8, "A", yellow.darken(10%), black, (9.8, 3.55)),
        (11.8, 3.1, "C", green.darken(10%), white, (9.8, 3.25)),
        (11.8, 2.5, "A", yellow.darken(10%), black, (9.8, 2.2)),
        (11.8, 2.0, "B", red.lighten(20%), white, (9.8, 2.05)),
        (11.8, 1.5, "E", purple.lighten(20%), white, (9.8, 1.9)),
        (11.8, 1.0, "F", fuchsia.lighten(20%), black, (9.8, 1.75)),
        (11.8, 0.4, "A", yellow.darken(10%), black, (9.8, 0.6)),
      )
      for (x, y, lbl, col, tcol, dst) in l0 {
        line((x - 0.22, y), dst, stroke: (dash: "dotted", thickness: 0.8pt), mark: (end: ">", fill: black))
        circle((x, y), radius: 0.22, fill: col, stroke: 0.8pt + black)
        content((x, y), text(size: 7pt, fill: tcol, weight: "bold")[#lbl])
        content((x + 0.65, y), text(size: 7.5pt)[$bold(x)_#lbl$])
      }
    })
  ]
]

=== The Basic GNN Mathematical Formulation

In general, the embedding at layer $k+1$ is computed by combining the embeddings of the neighbors $N(v)$ with the node's own embedding from layer $k$:
$
  bold(h)_v^((k+1)) = f("COMB"({bold(h)_u^((k)) | u in N(v)}, bold(h)_v^((k))))
$
Because the neighbors $N(v)$ of a node have *no natural ordering*, the aggregation function must be *permutation invariant* (symmetric), such as an element-wise mean, sum, or maximum.

In the *Basic GNN approach*, we average the neighbor messages and apply a neural network layer:
1. *Initialize Layer 0* with node features:
  $
    bold(h)_v^0 = bold(x)_v, quad forall v in V
  $
2. *Iterative Layer-$k$ Update* (for $k = 1, dots, K$):
  $
    bold(h)_v^k = sigma(bold(W)_k sum_(u in N(v)) (bold(h)_u^(k-1)) / (|N(v)|) + bold(B)_k bold(h)_v^(k-1))
  $
  where:
  - $sum_(u in N(v)) bold(h)_u^(k-1) / |N(v)|$ is the *average of the neighbors' previous-layer embeddings*.
  - $bold(W)_k$ is a *trainable weight matrix* for neighborhood transformation at layer $k$.
  - $bold(B)_k$ is a *trainable weight matrix* for the node's own previous-layer embedding $bold(h)_v^(k-1)$ (acting as a *self-embedding* transformation).
  - $sigma$ is a non-linear activation function (e.g., $"ReLU"$ or $tanh$).
3. *Final Output Embedding* after $K$ layers of neighborhood aggregation:
  $
    bold(z)_v = bold(h)_v^K
  $

=== Training a GNN (Unsupervised vs. Supervised) and Inductive Capability

To train the shared aggregation matrices $bold(W)_k$ and $bold(B)_k$ ($k = 1, dots, K$) via Stochastic Gradient Descent (SGD) on batches of node computation graphs, we feed the final embeddings $bold(z)_v$ into a loss function $cal(L)(bold(z)_v)$:

1. *Unsupervised Training* (using only the graph structure):
  We optimize the exact same log-likelihood objective used in `DeepWalk` / `node2vec` (or graph factorization / negative sampling) so that nodes co-occurring in random walks $N_S (u)$ have similar GNN embeddings:
  $
    max_(bold(W)_k, bold(B)_k) sum_(u in V) [ -log Z_u + sum_(n_i in N_S (u)) bold(z)_(n_i)^T bold(z)_u ], quad "where " Z_u = sum_(v in V) exp(bold(z)_u^T bold(z)_v)
  $

2. *Supervised Training* (end-to-end for a downstream task like node classification, e.g., classifying a node as "human vs. bot" or "healthy vs. diseased"):
  We minimize the binary *Cross-Entropy Loss* over labeled training nodes:
  $
    cal(L) = - sum_(v in V_"train") [ y_v log(sigma(bold(z)_v^T bold(theta))) + (1 - y_v) log(1 - sigma(bold(z)_v^T bold(theta))) ]
  $
  where $y_v in {0, 1}$ is the true node class label, $bold(theta)$ is a vector of classification weights, and $sigma$ is the sigmoid function.

#note(title: "Why GNNs Have Inductive Capability")[
  Because the *exact same aggregation parameters $bold(W)_k$ and $bold(B)_k$ are shared across all nodes* in the graph, the number of model parameters is *sublinear in $|V|$* (in fact, independent of $|V|$). This gives GNNs full *inductive capability*:
  - *Generalizing to entirely unseen graphs*: e.g., train a GNN on a Protein-Protein Interaction (PPI) graph from model organism A, and directly generate embeddings on a newly sequenced PPI graph from organism B.
  - *Generating embeddings "on the fly" for dynamic graphs*: when a new node arrives in an evolving network (e.g., a new patient admitted to a hospital PSN), we simply construct its local computation graph and run a forward pass using the pre-trained matrices $bold(W)_k, bold(B)_k$ without retraining.
]

== State-of-the-Art GNN Architectures

Different GNN architectures differ in *how they aggregate and update messages* ("what goes inside the aggregation box").

=== 1. Graph Convolutional Networks (GCNs — Kipf & Welling, ICLR 2017)

Kipf and Welling's *GCN* introduces two key modifications to the basic neighborhood aggregation rule:
$
  bold(h)_v^k = sigma(bold(W)_k sum_(u in N(v) union {v}) (bold(h)_u^(k-1)) / (sqrt(|N(u)| |N(v)|)))
$
Comparing GCN to the basic GNN formulation:
1. *More parameter sharing (single weight matrix)*: instead of having two separate matrices $bold(W)_k$ (for neighbors) and $bold(B)_k$ (for self-embedding), GCN includes $v$ itself in the summation ($u in N(v) union {v}$, equivalent to adding self-loops to the adjacency matrix $tilde(A) = A + I$) and shares the *exact same transformation matrix $bold(W)_k$* for both self and neighbor embeddings.
2. *Symmetric per-neighbor degree normalization*: instead of dividing by the simple average $|N(v)|$, each neighbor $u$'s message is normalized by the geometric mean of the degrees $sqrt(|N(u)| |N(v)|)$ (derived from the symmetric normalized Laplacian $tilde(D)^(-1/2) tilde(A) tilde(D)^(-1/2)$). This *down-weights high-degree hub neighbors*, preventing hubs from dominating the aggregation and empirically yielding superior performance.

=== 2. GraphSAGE (Hamilton et al., NeurIPS 2017)

*GraphSAGE* (*SAmple and aggreGatE*) generalizes the aggregation step and preserves the node's own identity via concatenation:
$
  bold(h)_v^k = sigma([ bold(W)_k dot "AGG"({bold(h)_u^(k-1), forall u in N(v)}), bold(B)_k bold(h)_v^(k-1) ])
$
Two main differences distinguish GraphSAGE from simple neighborhood aggregation:
1. *Concatenation ($[ dot , dot ]$) instead of summation*: rather than summing the neighbor aggregation and the self-embedding $bold(B)_k bold(h)_v^(k-1)$, GraphSAGE *concatenates* them into a single vector, ensuring the node's own features are never washed out by its neighbors.
2. *Generalized differentiable aggregation function ($"AGG"$)*: any differentiable function mapping a set of vectors to a single vector can be used:
  - *Mean aggregator*: takes the element-wise weighted average of neighbors:
    $
      "AGG"_"mean" = sum_(u in N(v)) (bold(h)_u^(k-1)) / (|N(v)|)
    $
  - *Pool aggregator*: transforms each neighbor vector through a non-linear Multi-Layer Perceptron (with weights $bold(Q)$) and applies a symmetric element-wise pooling operator $gamma$ (such as element-wise `max` or `mean`):
    $
      "AGG"_"pool" = gamma({sigma(bold(Q) bold(h)_u^(k-1) + bold(b)), forall u in N(v)})
    $
  - *LSTM aggregator*: applies a high-capacity *LSTM* sequence model to a *random permutation* $pi(N(v))$ of the neighbors (forcing the LSTM to become order-invariant):
    $
      "AGG"_"LSTM" = "LSTM"([bold(h)_u^(k-1), forall u in pi(N(v))])
    $

=== 3. Gated Graph Neural Networks (GGNNs — Li et al., 2016) & MPNNs

Standard GCNs and GraphSAGE are typically shallow (*only 2 to 3 layers deep*). If we try to stack $10+$ or $20+$ layers to propagate information across large graph diameters, two problems arise:
- *Overfitting* due to too many layer-specific parameters.
- *Vanishing or exploding gradients* during backpropagation (along with over-smoothing).

*Gated Graph Neural Networks (GGNNs)* solve this by borrowing two ideas from modern Recurrent Neural Networks (RNNs), enabling models with $> 20$ layers:
1. *Parameter sharing across layers*: the *exact same weight matrix $bold(W)$ and neural network module* are reused at every propagation step $k$ (does not depend on $k$).
2. *Recurrent state update via a Gated Recurrent Unit (GRU)*:
  - *Step 1 (Message aggregation)*: gather the sum of neighbor messages using the shared matrix $bold(W)$:
    $
      bold(m)_v^k = bold(W) sum_(u in N(v)) bold(h)_u^(k-1)
    $
  - *Step 2 (Recurrent GRU update)*: update the node's hidden state $bold(h)_v^k$ using a GRU cell that takes the node's previous state $bold(h)_v^(k-1)$ as the recurrent hidden state and the neighbor message $bold(m)_v^k$ as the current input:
    $
      bold(h)_v^k = "GRU"(bold(h)_v^(k-1), bold(m)_v^k)
    $

#note(title: "Generalization: Message-Passing Neural Networks (MPNNs — Gilmer et al., ICML 2017)")[
  Gilmer et al. unified almost all spatial GNN architectures (especially for quantum chemistry and molecular graphs) under the general *Message-Passing Neural Network (MPNN)* framework, which also natively incorporates *edge features* $bold(e)_(u, v)$:
  1. *Message step*:
    $
      bold(m)_v^k = sum_(u in N(v)) M_k (bold(h)_u^(k-1), bold(h)_v^(k-1), bold(e)_(u, v))
    $
  2. *Update step*:
    $
      bold(h)_v^k = U_k (bold(h)_v^(k-1), bold(m)_v^k)
    $
  where $M_k$ is any differentiable message function (e.g., an MLP) and $U_k$ is any state update function (e.g., a GRU or concatenation + non-linearity).
]

=== 4. Graph Attention Networks (GATs — Veličković et al., ICLR 2018)

In GCN and mean-pooling GraphSAGE, all neighbors are weighted either equally or purely by their static node degree. However, *some neighbors are much more informative or important than others*.

*Graph Attention Networks (GATs)* augment GNNs with a *self-attention mechanism* that learns anisotropic, feature-dependent importance weights $alpha_(v, u)$ for every edge $(u, v)$:
$
  bold(h)_v^k = sigma(sum_(u in N(v) union {v}) alpha_(v, u) bold(W)^k bold(h)_u^(k-1))
$
In the original GAT paper, the *attention coefficients $alpha_(v, u)$* are computed via a single-layer feedforward attention mechanism parameterized by a weight matrix $bold(Q)$ (or $bold(W)^k$) and a learnable attention vector $bold(a)$, normalized across $v$'s neighborhood via softmax:
$
  alpha_(v, u) = (exp("LeakyReLU"(bold(a)^T [bold(Q) bold(h)_v, bold(Q) bold(h)_u]))) / (sum_(u' in N(v) union {v}) exp("LeakyReLU"(bold(a)^T [bold(Q) bold(h)_v, bold(Q) bold(h)_(u')])))
$
where $[bold(Q) bold(h)_v, bold(Q) bold(h)_u]$ denotes concatenation of the linearly transformed representations of nodes $v$ and $u$.

== Subgraph and Whole-Graph Embeddings

While previous methods generate *node-level embeddings* $bold(z)_u$, many biomedical tasks (such as *molecular property prediction*, where an entire chemical compound is a graph of atoms and bonds, or classifying a patient's pathway subnetwork) require a single embedding vector $bold(z)_S in RR^d$ for an entire *subgraph (or whole graph) $S$*.

Three main approaches exist in the literature:

1. *Approach 1: Sum or Average Pooling* (Duvenaud et al., *ICML*, 2016 — Molecular Fingerprints):
  Run a standard GNN on the graph and simply sum (or average) the final node embeddings belonging to subgraph $S$:
  $
    bold(z)_S = sum_(v in S) bold(z)_v
  $
2. *Approach 2: Virtual Node* (Li et al., *ICLR*, 2016):
  Introduce a special *"virtual super-node"* connected via directed edges to all nodes in the subgraph $S$, and run a standard GNN. The final embedding of the virtual node serves as the subgraph embedding $bold(z)_S$.
3. *Approach 3: Hierarchical Differentiable Pooling (`DiffPool` — Ying et al., NeurIPS 2018)*:
  Instead of flat summation (which loses hierarchical structural motifs inside the graph), `DiffPool` learns to *hierarchically coarsen (cluster) the nodes* across layers:
  - Step 1: Run a GNN on the input graph to obtain node embeddings.
  - Step 2: Use a parallel GNN to learn a *soft clustering assignment matrix* (via softmax weights) that groups nodes into clusters, forming a smaller *"coarsened" super-node graph*.
  - Step 3: Run another GNN layer on the coarsened graph.
  - Step 4: Repeat until the entire graph is pooled into a single representation for graph classification. *(Hard clustering variants also exist, e.g., Cangea et al., 2018; Gao et al., 2018).*

= Applications of Graph Representation Learning to Network Medicine

== Software Platforms for GRL and the GRAPE Library

Several open-source frameworks support Graph Representation Learning, including *PyTorch Geometric (PyG)*, *Deep Graph Library (DGL)*, *OpenNE*, *CogDL*, *Dive into Graphs (DIG)*, *GraphVite*, *Graph-Learn*, and *Paddle Graph Learning (PGL)*.

To address the massive scalability challenges of biomedical graphs (which often contain millions of nodes and tens of millions of heterogeneous edges), AnacletoLab developed *GRAPE* (*Graph Representation leArning, Predictions and Evaluation*, Cappelletti et al., *Nature Computational Science*, 2023).

GRAPE is architected around two tightly integrated software modules:
1. *Ensmallen* (written in *Rust* with Python bindings for extreme speed and low memory footprint):
  - Loads massive graphs into *quasi-succinct data structures* (requiring orders of magnitude less RAM than standard libraries).
  - Performs heavily parallelized *1st- and 2nd-order random walks* (`DeepWalk`, `node2vec`, `Het-node2vec`), triple sampling, and on-the-fly mini-batch generation for `CBOW`, `SkipGram`, `GloVe`, and `TransE`.
  - Provides automated retrieval of over $80,000$ graphs from the scientific literature and executes *Graph Quality Control* (detecting topological anomalies such as singletons, stars, cliques, chains, circles, and node isomorphisms).
2. *Embiggen* (Python / TensorFlow / Scikit-Learn integration):
  - Implements TensorFlow-based node embedding models, Graph Convolutional Networks (GCNs), and Scikit-Learn classifiers for downstream tasks.
  - Provides standardized, reproducible evaluation pipelines for *Node-label prediction*, *Edge prediction (Link prediction)*, and *Edge-label prediction*, along with visualization tools for embeddings and graph properties.

== Biomedical Network Models and Knowledge Graphs

Real-world biomedical networks are rarely simple homogeneous graphs. Following Bohyun et al. (2020) and Himmelstein et al. (2015, 2019), network models in Network Medicine are categorized into four structural levels:

1. *Homogeneous Network*: all nodes and all edges are treated equally as a single type, even if they biologically represent different entities.
2. *Multiplex Network*: consists of multiple layers ($L_1, L_2, dots$) sharing the *exact same set of nodes* (e.g., the same set of proteins or patients), where each layer represents a different type of interaction or similarity, and vertical dashed edges link each node to its counterparts across layers.
3. *Heterogeneous Multi-Layered Network (HMLN)*: consists of multiple layers where *each layer contains a distinct type of biological entity* (e.g., Layer 1: Diseases, Layer 2: Genes/Proteins, Layer 3: Chemicals/Drugs), with *intra-layer edges* representing within-domain similarity (disease-disease, gene-gene, chemical-chemical) and *inter-layer edges* representing cross-domain associations (gene-disease, drug-gene, drug-disease).
  - *General GRL Learning Framework on HMLNs*: takes the intra-layer similarity matrices and observed sparse inter-layer association matrices as input, learns *low-dimensional latent embeddings* for diseases, genes, and chemicals, and performs *matrix completion or supervised link prediction* to reconstruct complete association matrices.
4. *Biomedical Knowledge Graphs (KGs / Meta-Graphs)*:
  - Defined by Nicholson and Greene (2020) as *"a resource that integrates one or more expert-derived sources of information into a graph where nodes represent biomedical entities and edges represent semantic relationships between two entities."*
  - A landmark example is *HetioNet* (Himmelstein & Baranzini, 2015, 2017), a meta-graph integrating heterogeneous entity types (*Gene*, *Compound*, *Disease*, *Anatomy*, *Symptom*, *Side Effect*, *Pharmacologic Class*, *Biological Process*, *Pathway*, *Cellular Component*, *Molecular Function*) connected by typed semantic edges (e.g., `Compound-treats-Disease`, `Compound-palliates-Disease`, `Compound-causes-SideEffect`, `Compound-binds/upregulates/downregulates-Gene`, `Disease-associates-Gene`, `Disease-localizes-Anatomy`, `Disease-presents-Symptom`).
  - Another major example is the *COVID-19 Knowledge Graph* (`kg-covid-19`, Reese et al., 2020), which integrates ontologies (*GO*, *Mondo*, *HP*, *ChEBI*) with *UniProt*, *IntAct*, *STRING*, *DrugCentral*, *PharmGKB*, *TTD*, *ChEMBL*, and *CORD-19* literature to support drug repurposing against SARS-CoV-2.

=== Major Databases Populating Biomedical Knowledge Graphs

Biomedical KGs are populated via manual curation, automated text-mining, and high-throughput experimental pipelines from reference databases:
- *Genes, Proteins, and PPIs*: *BioGRID* (genetic/proteomic interactions), *STRING* (known and predicted PPIs), *UniProt* (protein sequences and functional annotations), *IntAct* (molecular interactions), *InterPro* (protein families/domains), *Entrez-Gene* (NCBI gene annotations), *Human Protein Atlas (HPA)*.
- *Drugs, Chemicals, and Targets*: *DrugBank* (drugs and targets), *ChEMBL* (bioactive molecules), *PharmGKB* (pharmacogenomics: drug-gene-variant-phenotype), *Comparative Toxicogenomics Database (CTD)* (chemical-gene-disease mappings), *SIDER* (drug side effects), *TTD* (Therapeutic Target Database), *SuperTarget*, *CARD* (Comprehensive Antibiotic Resistance Database).
- *Diseases, Variants, and Pathways*: *OMIM* (Mendelian genotype-phenotype associations), *COSMIC* (somatic cancer mutations), *KEGG* and *Reactome* (metabolic and signaling pathways), *Gene Ontology (GO)* (Biological Process, Molecular Function, Cellular Component).

== Multi-Scale Applications of GRL in Network Medicine

Graph Representation Learning is applied across *four interconnected scales* in Network Medicine (Yi et al., *Briefings in Bioinformatics*, 2022):

=== 1. Molecular Scale: Analysis of Chemical Compounds and Proteins
- *Graph representation*: molecules and proteins are modeled as *molecular graphs* where *nodes are atoms* (or amino acid residues / surface patches) and *edges are chemical bonds* (or spatial 3D proximity).
- *Tasks and representative methods*:
  - *Molecular representation learning (Fingerprints)*: neural graph fingerprints via GCNs (Duvenaud et al., 2015), 3D rotation-invariant adaptive GCNs (`3DMol-Net`, Li et al., 2021), and geometric deep learning on protein molecular surfaces to decipher interaction fingerprints (`MaSIF`, Gainza et al., *Nature Methods*, 2020).
  - *Molecular property prediction*: predicting quantum chemical properties, toxicity, and solubility via *Message-Passing Neural Networks (MPNNs)* (Gilmer et al., 2017) and spatial graph embeddings.

=== 2. Multi-Omics Scale: Genomics, Proteomics, and Transcriptomics
- *Genomics graph analysis*: single-cell RNA-seq cell-network embedding (Li et al., 2017), disease-gene prioritization via random walks on heterogeneous multigraphs (Li & Li, 2012), and hybrid localized spectral graph convolutional filtering on gene-relation networks for *breast cancer subtype classification* (Rhee et al., 2018).
- *Proteomics graph analysis*: multi-modal attributed network embedding integrating PPI topology and sequence attributes for *Automated Protein Function Prediction* (`Graph2GO`, Fan et al., 2020), and denoising PPI networks via *Variational Graph Auto-Encoders (VGAE)* to detect protein complexes (Yao et al., 2020).
- *Transcriptomics graph analysis*: predicting *miRNA-disease* and *lncRNA-disease* associations using multi-view multichannel attention GCNs (Tang et al., 2021) and convolutional/variational autoencoders (Sheng et al., 2021).

=== 3. Pharmaceutical Scale: Drug Discovery and Repositioning
- *Drug-Target Interaction (DTI) prediction*: predicting novel bindings between drugs and proteins by deep-mining heterogeneous biomedical linked networks (Zong et al., 2017; `DTIGEMS+`, Thafar et al., 2020; end-to-end heterogeneous GRL, Peng et al., 2021).
- *Drug-Disease association (Drug Repurposing)*: embedding MeSH headings and drug-disease networks via GRL and GCNs (`MeSHHeading2vec`, Guo et al., 2021; Sun et al., 2019).
- *Drug-Drug Interaction (DDI) & Polypharmacy Side Effects*: modeling multi-relational drug-protein-side-effect networks with GCNs to predict whether taking two drugs simultaneously causes adverse polypharmacy side effects (*Decagon*, Zitnik, Agrawal & Leskovec, *Bioinformatics*, 2018), or combining KG embeddings with CNN-LSTMs / Attention GCNs (`AGCN`, Park et al., 2020).

=== 4. Healthcare & Clinical Scale: Knowledge Graphs and EHRs
- *Electronic Health Records (EHRs) and Clinical KGs*: learning health knowledge graphs from EHRs (Rotmensch et al., 2017), modeling the graphical structure of EHR visits, diagnoses, and treatments via *Graph Convolutional Transformers* (Choi et al., *AAAI*, 2020) and GNNs for disease prediction (Sun et al., 2021), and identifying disease treatment mechanisms across the *multiscale interactome* connecting drugs, proteins, biological functions, and diseases (Ruiz, Zitnik & Leskovec, *Nature Communications*, 2021).
