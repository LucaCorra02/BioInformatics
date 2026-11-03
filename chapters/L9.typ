#import "../template.typ": *

= From Unimodal to Multi-Modal PSN Integration

Single-omics analyses suffer from "blind-spot" limitations. Because of *patient heterogeneity*, patients with the same clinical diagnosis may respond very differently to the same therapy; *Precision Medicine* requires integrating multi-omics views to stratify patients and tailor personalized treatments.

== Taxonomies of Multi-Modal Data Integration

In the literature, dataset integration is first divided by *integration flow*:
- *Horizontal integration* (on *multiset / homogeneous datasets*): integrating the *same* data modality (e.g., mRNA) measured across different cohorts or conditions.
- *Vertical integration* (on *multimodal / heterogeneous datasets*): integrating *different* data modalities (e.g., methylation + mRNA + protein) measured on the *same* set of patients. Vertical integration is further split into *hierarchical-vertical* (multi-staged, modeling explicit regulatory cascades like $"methylation" arrow.r "mRNA" arrow.r "protein"$) and *parallel-vertical* (meta-dimensional analysis, treating views symmetrically).

For *parallel-vertical integration on Patient Similarity Networks*, methods are categorized into three families according to *when* the fusion happens:

#figure(
  caption: [Categorization of multi-modal PSN integration methods: (1) Early / Input-data integration, (2) Intermediate / Model (PSN) integration, and (3) Late / Output-data integration.],
)[
  #align(center)[
    #cetz.canvas(length: 1.2cm, padding: 0.2cm, {
      import cetz.draw: *

      // 1. Early Integration
      content((0, 4.2), anchor: "west", text(weight: "bold", size: 9pt, fill: teal.darken(20%))[
        1. Early (Input-Data) Integration:
      ])
      rect((0, 3.0), (2.2, 3.8), radius: 0.1, fill: gray.lighten(85%))
      content((1.1, 3.4), text(size: 8pt)[Views $X^1, dots, X^m$])
      line((2.2, 3.4), (3.4, 3.4), mark: (end: ">", fill: black))
      rect((3.4, 3.0), (6.4, 3.8), radius: 0.1, fill: teal.lighten(85%), stroke: teal)
      content((4.9, 3.4), text(size: 7pt)[*Fuse Data* (JIVE, intNMF, MOFA)])
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

== Early Integration (Input-Data Fusion & Joint Dimensionality Reduction)

In *Early Integration*, the multi-omics matrices $X^1, X^2, dots, X^m$ are projected into a *joint shared low-dimensional latent space* during pre-processing (often called *Multi-omics Joint Dimensionality Reduction, jDR*, decomposing each view as $X^i approx A^i times F$, where $F$ are shared sample factors and $A^i$ are view-specific metagene loadings). A single PSN is then built from the integrated latent coordinates.

The three main early-integration algorithms are *JIVE*, *intNMF*, and *MOFA*.

=== JIVE (Joint and Individual Variation Explained)

#informally()[
  The main idea is to see each data view divided in two _part_:
  - Some biological pattern can be shared over the differnt view of the data.
  - While other biological pattern are individual and specific for each view.
]

*JIVE* is a *PCA-based* extension that decomposes each data view $X_i$ ($i = 1, dots, k$) into three orthogonal components:
$
  X_i = J_i + A_i + epsilon_i
$
where:
- $J = [J_1^T, dots, J_k^T]^T$ is the low-rank *joint structure* shared across all views. Is the part of information shared across the views.
- $A_i$ is the low-rank *individual (view-specific) variation* unique to view $i$
- $epsilon_i$ is residual noise

To ensure identifiability, the joint and individual subspaces are constrained to be *mutually orthogonal* ($J A_i^T = 0$).

#note(title: "JIVE Iterative SVD Estimation Algorithm")[
  1. *Initialize*: $X^"Joint" = X = [X_1^T, dots, X_k^T]^T$.
  2. *Repeat until convergence*:
    - Estimate the joint matrix $J = [J_1^T, dots, J_k^T]^T$ by computing a *rank-$r$ truncated SVD* of $X^"Joint"$:
      $
        J = U Lambda V^T
      $
      where:
      - $U$: are the singular left vector, they indicate how the single feature combine to generate each principal component.
      - $Lambda$: It's a diagonal matrix where the value on the diagonal are sorted ($lambda_1>=lambda_2>=0$). They indicate the importance of each component.
      - $V$: The row of $V^t$ (collumn of $V$) are the new compressed coordinates of the patients in the new space

      With rank-$r$ we keep only the first $r$ components (the most important once).


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

=== intNMF (Integrative Non-Negative Matrix Factorization)
*intNMF* applies *Non-Negative Matrix* Factorization to approximate each non-negative data matrix $X_(n times p_i)^i$ ($i = 1, dots, m$, where $n$ is the number of patients and $p_i$ the number of features in view $i$) as the product of a *shared non-negative patient factor matrix* $W_(n times k) >= 0$ and a *view-specific non-negative loading matrix* $H_(k times p_i)^i >= 0$:
$
  X_(n times p_i)^i approx W_(n times k) H_(k times p_i)^i, quad i = 1, dots, m
$
- $H^i$ matrix it's specific for every visualization. Each row indicates a latent $k$ factor and how it's expressed.
- $W$ matrix indicates how of the $k$ factor it's expressed in a specific patients. It's shared across all the views.

These two matrix are constructed by minimizes the weighted *reconstruction error* across all $m$ views:
$
  Q = min_(W >= 0, H^i >= 0) sum_(i=1)^m theta^i norm(X^i - W H^i)_2^2
$
where $theta^i$ are user-defined weights representing the *a priori* importance of each view. The optimization problem is solved via *Non-negative Alternating Least Squares (ALS)*: only $W$ needs to be initialized, and the algorithm alternates between fixing $W$ to solve for each $H^i$ and fixing $H^i$ to update $W$ via constrained least squares.

=== MOFA (Multi-Omics Factor Analysis) and Variational Inference
*MOFA* is a probabilistic Bayesian Generalized Matrix Factorization model:
$
  X^((m)) = Z W^((m) T) + epsilon^((m)), quad m = 1, dots, M
$
where:
- $X^((m)) in RR^(N times D_m)$ is the data matrix of view $m$
- $Z in RR^(N times K)$ is the matrix of *shared latent factors* across all views
- $W^((m)) in RR^(D_m times K)$ are the view-specific *weights/loadings* (equipped with sparsity-inducing priors so a factor can capture either variation shared across multiple views or variation specific to a single view)
- $epsilon^((m))$ is view-specific noise (supporting Gaussian, Bernoulli, or Poisson likelihoods for continuous, binary, and count data).

*Mathematical Derivation of Variational Inference (VI) and ELBO in MOFA*: In Bayesian inference, given observed data $X$ and latent variables $Z$ (including parameters $theta$), Bayes' theorem gives the posterior distribution:
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

=== Similarity Network Fusion (SNF)

*Similarity Network Fusion (SNF)* is the reference *intermediate (model-based) integration* algorithm. Instead of merging raw feature matrices in input space, SNF constructs an independent Patient Similarity Network (PSN) for each data modality (view) and iteratively fuses them into a single consensus network through a non-linear *message-passing (diffusion) process*.

==== Unimodal Similarity Matrix Construction ($W$)
Suppose we have $n$ patients measured across $M$ data views (for simplicity, let $M = 2$, e.g., view $(1) =$ mRNA expression and view $(2) =$ DNA methylation). For each view, SNF computes a *pairwise patient similarity* matrix $W in RR^(n times n)$ using a *scaled exponential Euclidean (Gaussian) kernel*:
$
  W(i, j) = exp(- (rho(x_i, x_j)^2) / (mu epsilon_(i j)))
$
where $rho(x_i, x_j)$ is the Euclidean distance between patients $x_i$ and $x_j$ in that view, $mu$ is a hyperparameter, and $epsilon_(i j)$ is a local scaling factor (based on the average distance between $x_i, x_j$ and their $k$-nearest neighbors) that adapts the kernel width to local data density.

==== Global ($P$) and Local ($S$) Normalized Matrices
From each similarity matrix $W^((v))$, SNF derives two distinct normalized matrices that separate *global topology* from *reliable local neighborhoods*:

1. *Global Normalized Similarity Matrix ($P$)*: captures the full pairwise similarities across *all* patients in the graph, with diagonal self-similarities fixed to $1/2$ and off-diagonal entries normalized so each row sums to $1$:
  $
    P(i, j) = cases(
      (W(i, j)) / (2 sum_(k != i) W(i, k)) & quad "if " j != i,
      1 / 2 & quad "if " j = i
    )
  $
2. *Local Normalized Similarity Matrix ($S$ — Sparse Kernel)*: retains edges *only* for the $k$-nearest neighbors $N_i$ of each patient $i$, setting all weaker connections to $0$:
  $
    S(i, j) = cases(
      (W(i, j)) / (sum_(k in N_i) W(i, k)) & quad "if " j in N_i,
      0 & quad "otherwise"
    )
  $
  #note()[
    Weak similarity edges between distant patients are unreliable and noisy; only the strongest local connections ($j in N_i$) can be trusted to propagate information across networks.
  ]

==== Iterative Message Passing (Cross-Network Diffusion)
Starting from $P_(t=0)^((1)) = P^((1))$ and $P_(t=0)^((2)) = P^((2))$, SNF iteratively updates the global similarity matrix of each view by diffusing the global similarities of the *other* view through its own local neighborhood matrix $S$:
$
  P_(t+1)^((1)) & = S^((1)) times P_t^((2)) times (S^((1)))^T \
  P_(t+1)^((2)) & = S^((2)) times P_t^((1)) times (S^((2)))^T
$
*(If $M > 2$ views are present, $P_t^((2))$ is replaced by the average of the global matrices of all other views: $1/(M-1) sum_(v != m) P_t^((v))$).*

#note(title: "Intuitive Meaning of the SNF Update Equation")[
  Writing out the matrix multiplication for a single pair of patients $(i, j)$ in view $1$ reveals how the diffusion works:
  $
    P_(t+1)^((1))(i, j) = sum_(k in N_i) sum_(l in N_j) S^((1))(i, k) dot P_t^((2))(k, l) dot S^((1))(j, l)
  $
  Suppose that we want to know how two patient $i$ and $j$ are similar in the first view (mRNA):
  - Take a best-friend $k$ of the patient $i$ in the first view: $S^1(i,k)$
  - Take a best-friend $l$ of the patient $j$ in the first view: $S^1(j,l)$
  - Now we want to know how much this two patients are similar, we check the second view: $P^2(k,l)$. If the best friend of $i$ and $j$ in the first view are also similar in the second view, the link between $i$ and $j$ become even stronger in the first view




  This cross-diffusion has three key effects on the network topology:
  1. *Noise removal*: weak, isolated edges that are not supported by local neighborhoods in any view quickly vanish to zero
  2. *Edge reinforcement*: similarities supported consistently across multiple omics views reinforce each other and become stronger
  3. *Complementary signal preservation*: a very strong edge present in only *one* omics view is preserved if the local neighborhoods of the two patients are tightly connected.
]

==== Convergence and Final Consensus PSN
After $T$ iterations (until convergence, where the networks align into a shared topology), the final fused Patient Similarity Network is obtained by averaging the diffused global matrices:
$
  P^("fused") = 1 / 2 (P_T^((1)) + P_T^((2)))
$
The resulting integrated matrix $P^("fused")$ can then be used for unsupervised patient subtype stratification (e.g., via Spectral Clustering) or semi-supervised outcome prediction (as in *MP-Net*).

=== Late Integration (Output-Data / Consensus Fusion)

In *Late Integration*, unimodal PSNs are built and analyzed (clustered or classified) *completely independently* for each data modality. The separate outputs are then combined at the very end using consensus aggregation or meta-models:
- *PINSplus* (Perturbation Clustering for data INtegration and disease Subtyping): perturbs each omics data view by adding Gaussian noise to find stable patient partitions within each view, and then constructs a cross-view agreement matrix to identify consensus tumor subtypes.
- *SUMO*: builds unimodal patient similarity networks and performs *joint symmetric Non-Negative Matrix Tri-Factorization* on the multiplexed similarity matrices to extract consensus molecular subtypes.

= Deep Graph Representation Learning: Graph Neural Networks (GNNs)

== From Shallow Encoders to Deep Graph Neural Networks

=== Recap of Node Embedding: Encoder-Decoder Framework

The goal of node embedding is to map each node $v in V$ to a low-dimensional vector $bold(z)_v in RR^d$ such that *geometric similarity* in the embedding space *approximates topological similarity* in the original graph. This involves two key components:
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
- $bold(X) in RR^(m times |V|)$: a matrix of *node features* (e.g., gene expression profiles, categorical clinical attributes, molecular atom descriptors).

*Core Intuition (Neighborhood Aggregation)*: a node's representation is generated *by iteratively aggregating and transforming information* ("messages") *from its local graph neighborhood* using neural networks:
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
#note()[
  Because the neighbors $N(v)$ of a node have *no natural ordering*, the aggregation function $f$ must be *permutation invariant* (symmetric), such as an element-wise mean, sum, or maximum.
]

In the *Basic GNN approach*, we *average the neighbor messages* and apply a neural network layer:
1. *Initialize Layer 0* with node features:
  $
    bold(h)_v^0 = bold(x)_v, quad forall v in V
  $
2. *Iterative Layer-$k$ Update* (for $k = 1, dots, K$):
  $
    bold(h)_v^k = sigma(bold(W)_k sum_(u in N(v)) (bold(h)_u^(k-1)) / (|N(v)|) + bold(B)_k bold(h)_v^(k-1))
  $
  where:
  - $sum_(u in N(v)) bold(h)_u^(k-1) / (|N(v)|)$ is the *average of the neighbors' previous-layer embeddings*.

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
    max_(bold(W)_k, bold(B)_k) sum_(u in V) [ mg(-log Z_u) + sum_(n_i in mr(N_S (u))) bold(z)_(n_i)^T bold(z)_u ], quad "where " Z_u = sum_(v in V) exp(bold(z)_u^T bold(z)_v)
  $
  where:
  - $mr(N_S (u))$: is the group of neighboroud of node $u$. The algorithm want to maximize the sum of the similarity between node $u$ and it's neighbors
  - $mg(Z_u)$: it's a normalization factor. Compute the similarity between node $u$ and the rest node of the graph. Since is $-log Z_u$ we want to *minimize $Z_u$*: Move the vector for node $u$ away from the vectors of all the random nodes in the graph with which it has no connection.

2. *Supervised Training* (end-to-end for a downstream task like node classification, e.g., classifying a node as "human vs. bot" or "healthy vs. diseased"):
  We minimize the binary *Cross-Entropy Loss* over labeled training nodes:
  $
    cal(L) = - sum_(v in V_"train") [ y_v log(sigma(bold(z)_v^T bold(theta))) + (1 - y_v) log(1 - sigma(bold(z)_v^T bold(theta))) ]
  $
  where $y_v in {0, 1}$ is the true node class label, $bold(theta)$ is a vector of classification weights, and $sigma$ is the sigmoid function. The formula act in this way:
  - *Case A* (The node is positive, $y_v = 1$): The second half of the formula within the square brackets becomes zero (because $1 - 1 = 0$). Only $log(sigma(z_v^T theta))$ remains. To minimize the error, the GNN is compelled to push the sigmoid probability as close to $1$ as possible.
  - *Case B* (The node is negative, $y_v = 0$): The first half becomes zero (because it is multiplied by $0$). Only $log(1 - sigma(z_v^T theta))$ remains. The GNN is compelled to push the probability as close to $0$ as possible.

#note(title: "Why GNNs Have Inductive Capability")[
  Because the *exact same aggregation parameters $bold(W)_k$ and $bold(B)_k$ are shared across all nodes* in the graph, the number of model parameters is *sublinear in $|V|$* (in fact, independent of $|V|$). This gives GNNs full *inductive capability*:
  - *Generalizing to entirely unseen graphs*: e.g., train a GNN on a Protein-Protein Interaction (PPI) graph from model organism A, and directly generate embeddings on a newly sequenced PPI graph from organism B.
  - *Generating embeddings "on the fly" for dynamic graphs*: when a new node arrives in an evolving network (e.g., a new patient admitted to a hospital PSN), we simply construct its local computation graph and run a forward pass using the pre-trained matrices $bold(W)_k, bold(B)_k$ without retraining.
]

== State-of-the-Art GNN Architectures

Different GNN architectures differ in *how they aggregate and update messages* ("what goes inside the aggregation box").

=== Graph Convolutional Networks

*GCN* introduces two key modifications to the basic neighborhood aggregation rule:
$
  bold(h)_v^k = sigma(bold(W)_k sum_(u in N(v) union {v}) (bold(h)_u^(k-1)) / (sqrt(|N(u)| |N(v)|)))
$
Comparing GCN to the basic GNN formulation:
1. *More parameter sharing (single weight matrix)*: instead of having two separate matrices $bold(W)_k$ (for neighbors) and $bold(B)_k$ (for self-embedding), GCN includes $v$ itself in the summation ($u in N(v) union {v}$, equivalent to adding self-loops to the adjacency matrix $tilde(A) = A + I$) and shares the *exact same transformation matrix $bold(W)_k$* for both self and neighbor embeddings.
2. *Symmetric per-neighbor degree normalization*: instead of dividing by the simple average $|N(v)|$, each neighbor $u$'s message is normalized by the geometric mean of the degrees $sqrt(|N(u)| |N(v)|)$ (derived from the symmetric normalized Laplacian $tilde(D)^(-1/2) tilde(A) tilde(D)^(-1/2)$). This *down-weights high-degree hub neighbors*, preventing hubs from dominating the aggregation and empirically yielding superior performance.

#note()[
  A hub is a node with a significantly higher number of connections (degree) than the average node in the network.
]

=== GraphSAGE

*GraphSAGE* (*SAmple and aggreGatE*) generalizes the aggregation step and preserves the node's own identity via concatenation:
$
  bold(h)_v^k = sigma([ bold(W)_k dot "AGG"({bold(h)_u^(k-1), forall u in N(v)}), bold(B)_k bold(h)_v^(k-1) ])
$
Two main differences distinguish GraphSAGE from simple neighborhood aggregation:
1. *Concatenation ($[ dot , dot ]$) instead of summation*: rather than summing the neighbor aggregation and the self-embedding $bold(B)_k bold(h)_v^(k-1)$, GraphSAGE *concatenates* them into a single vector, ensuring the *node's own features are never washed out by its neighbors*.

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

=== Gated Graph Neural Networks & MPNNs

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

    A GRU (Gated Recurrent Unit) is a special type of "*memory cell*." It is called "gated" because it contains gates—mathematical mechanisms based on sigmoid functions that learn to *decide what to remember and what to forget*. When a GRU receives the previous state of a node along with new information from its neighbors, its gates effectively ask:
    - How much of this new information from the neighbors is actually useful?
    - How much of my previous state should I keep intact to maintain my identity, and how much can I discard because it has become obsolete?

#note(title: "Generalization: Message-Passing Neural Networks")[
  Gilmer unified almost all spatial GNN architectures (especially for quantum chemistry and molecular graphs) under the general *Message-Passing Neural Network (MPNN)* framework, which also natively incorporates *edge features* $bold(e)_(u, v)$:
  1. *Message step*:
    $
      bold(m)_v^k = sum_(u in N(v)) M_k (bold(h)_u^(k-1), bold(h)_v^(k-1), bold(e)_(u, v))
    $
  2. *Update step*:
    $
      bold(h)_v^k = U_k (bold(h)_v^(k-1), bold(m)_v^k)
    $
  where:
  - $M_k$ is any differentiable message function (e.g., an MLP)
  - $U_k$ is any state update function (e.g., a GRU or concatenation + non-linearity)
]

=== Graph Attention Networks

In GCN and mean-pooling GraphSAGE, all neighbors are weighted either equally or purely by their static node degree. However, *some neighbors are much more informative or important than others*.

*Graph Attention Networks (GATs)* augment GNNs with a *self-attention mechanism* that learns anisotropic, feature-dependent importance weights $alpha_(v, u)$ for every edge $(u, v)$:
$
  bold(h)_v^k = sigma(sum_(u in N(v) union {v}) alpha_(v, u) mr(bold(W)^k bold(h)_u^(k-1)))
$
where $mr(bold(W)^k bold(h)_u^(k-1))$ is the message that comes from neighbor $u$, and $alpha_(v, u)$ is the *learned attention coefficient* that determines how much weight to give to neighbor $u$ when updating node $v$'s embedding.

In the original GAT paper, the *attention coefficients $alpha_(v, u)$* are computed via a single-layer feedforward attention mechanism parameterized by a weight matrix $bold(Q)$ (or $bold(W)^k$) and a learnable attention vector $bold(a)$, normalized across $v$'s neighborhood via softmax:
$
  alpha_(v, u) = (exp("LeakyReLU"(bold(a)^T [bold(Q) bold(h)_v, bold(Q) bold(h)_u]))) / (sum_(u' in N(v) union {v}) exp("LeakyReLU"(bold(a)^T [bold(Q) bold(h)_v, bold(Q) bold(h)_(u')])))
$
where $[bold(Q) bold(h)_v, bold(Q) bold(h)_u]$ denotes concatenation of the linearly transformed representations of nodes $v$ and $u$.

== Subgraph and Whole-Graph Embeddings

While previous methods generate *node-level embeddings* $bold(z)_u$, many biomedical tasks (such as *molecular property prediction*, where an entire chemical compound is a graph of atoms and bonds, or classifying a patient's pathway subnetwork) require a single *embedding vector* $bold(z)_S in RR^d$ for an entire *subgraph (or whole graph) $S$*.

Three main approaches exist in the literature:

1. *Approach 1: Sum or Average Pooling*:
  Run a standard GNN on the graph and simply sum (or average) the final node embeddings belonging to subgraph $S$:
  $
    bold(z)_S = sum_(v in S) bold(z)_v
  $

2. *Approach 2: Virtual Node*: Introduce a special *virtual super-node* connected via *directed edges to all nodes in the subgraph $S$*, and run a standard GNN. The final embedding of the virtual node serves as the subgraph embedding $bold(z)_S$.

3. *Approach 3: Hierarchical Differentiable Pooling*: Instead of flat summation (which loses hierarchical structural motifs inside the graph), `DiffPool` learns to *hierarchically coarsen (cluster) the nodes* across layers:
  - Step 1: Run a GNN on the input graph to obtain node embeddings.
  - Step 2: Use a parallel GNN to learn a *soft clustering assignment matrix* (via softmax weights) that groups nodes into clusters, forming a smaller *"coarsened" super-node graph*.
  - Step 3: Run another GNN layer on the coarsened graph.
  - Step 4: Repeat until the entire graph is pooled into a single representation for graph classification.

= Applications of Graph Representation Learning to Network Medicine

== Software Platforms for GRL and the GRAPE Library

To address the massive scalability challenges of biomedical graphs (which often contain millions of nodes and tens of millions of heterogeneous edges), AnacletoLab developed *GRAPE* (*Graph Representation leArning, Predictions and Evaluation*).

GRAPE is architected around two tightly integrated software modules:
1. *Ensmallen* (written in *Rust* with Python bindings for extreme speed and low memory footprint):
  - Loads massive graphs into *quasi-succinct data structures* (requiring orders of magnitude less RAM than standard libraries).
  - Performs heavily parallelized *1st- and 2nd-order random walks* (`DeepWalk`, `node2vec`, `Het-node2vec`), triple sampling, and on-the-fly mini-batch generation for `CBOW`, `SkipGram`, `GloVe`, and `TransE`.
  - Provides automated retrieval of over $80,000$ graphs from the scientific literature and executes *Graph Quality Control* (detecting topological anomalies such as singletons, stars, cliques, chains, circles, and node isomorphisms).
2. *Embiggen* (Python / TensorFlow / Scikit-Learn integration):
  - Implements TensorFlow-based node embedding models, Graph Convolutional Networks (GCNs), and Scikit-Learn classifiers for downstream tasks.
  - Provides standardized, reproducible evaluation pipelines for *Node-label prediction*, *Edge prediction (Link prediction)*, and *Edge-label prediction*, along with visualization tools for embeddings and graph properties.

== Biomedical Network Models and Knowledge Graphs

Real-world biomedical networks are *rarely simple homogeneous graphs*, in Network Medicine are categorized into four structural levels:

1. *Homogeneous Network*: all nodes and all edges are treated equally as a single type, even if they biologically represent different entities.

2. *Multiplex Network*: consists of multiple layers ($L_1, L_2, dots$) sharing the *exact same set of nodes* (e.g., the same set of proteins or patients), where *each layer represents a different type of interaction or similarity*, and vertical dashed edges link each node to its counterparts across layers.

3. *Heterogeneous Multi-Layered Network (HMLN)*: consists of multiple layers where *each layer contains a distinct type of biological entity* (e.g., Layer 1: Diseases, Layer 2: Genes/Proteins, Layer 3: Chemicals/Drugs), with *intra-layer edges* representing within-domain similarity (disease-disease, gene-gene, chemical-chemical) and *inter-layer edges* representing cross-domain associations (gene-disease, drug-gene, drug-disease).
  - *General GRL Learning Framework on HMLNs*: takes the intra-layer similarity matrices and observed sparse inter-layer association matrices as input, learns *low-dimensional latent embeddings* for diseases, genes, and chemicals, and performs *matrix completion or supervised link prediction* to reconstruct complete association matrices.
4. *Biomedical Knowledge Graphs (KGs / Meta-Graphs)*:
  - Defined as "a resource that *integrates* one or more expert-derived *sources of information into a graph* where nodes represent biomedical entities and edges represent semantic relationships between two entities

    #example()[
      A landmark example is *HetioNet* a meta-graph integrating heterogeneous entity types (*Gene*, *Compound*, *Disease*, ecc..) connected by typed semantic edges (e.g., `Compound-treats-Disease`, `Compound-palliates-Disease`, `Compound-causes-SideEffect`, `Compound-binds/upregulates/downregulates-Gene, ecc`)

      Another major example is the *COVID-19 Knowledge Graph*, which integrates ontologies (*GO*, *Mondo*, *HP*, *ChEBI*) with *UniProt*, *IntAct*, *STRING*, *DrugCentral*, *PharmGKB*, *TTD*, *ChEMBL*, and *CORD-19* literature to support drug repurposing against SARS-CoV-2.
    ]

== Multi-Scale Applications of GRL in Network Medicine

Graph Representation Learning is applied across *four interconnected scales* in Network Medicine.

=== Molecular Scale: Analysis of Chemical Compounds and Proteins

*Graph representation*: molecules and proteins are modeled as *molecular graphs* where *nodes are atoms* (or amino acid residues / surface patches) and *edges are chemical bonds* (or spatial 3D proximity).

- *Tasks and representative methods*:
  - *Molecular representation learning (Fingerprints)*: neural graph fingerprints via GCNs, 3D rotation-invariant adaptive GCNs, and geometric deep learning on protein molecular surfaces to decipher interaction fingerprints.
  - *Molecular property prediction*: predicting quantum chemical properties, toxicity, and solubility via *Message-Passing Neural Networks (MPNNs)* and spatial graph embeddings.

=== Multi-Omics Scale: Genomics, Proteomics, and Transcriptomics
At this scale, GRL accelerates relational omics data analysis by modeling biomolecular interactions

- *Genomics Graph Analysis*:
  - *Graph Structure*: Nodes can represent individual cells (in scRNA-seq) or genes and diseases. Edges represent transcriptional similarity between cells or heterogeneous functional associations.
  - *Task*: Node classification (e.g., clustering single cells by type, or classifying breast cancer subtypes based on gene-relation networks) and link prediction (e.g., prioritizing which genes are implicated in a disease via random walks).

- *Proteomics Graph Analysis*:
  - *Graph Structure*: Nodes represent proteins, enriched with node attributes like protein sequence data. Edges represent Protein-Protein Interactions (PPIs) based on physical binding or functional similarity.
  - *Task*: Node classification to infer automated protein functions (e.g., `Graph2GO`), and link prediction/denoising via Variational Graph Auto-Encoders (VGAE) to detect true protein complexes hidden in noisy, false-positive PPI networks.

- *Transcriptomics Graph Analysis*:
  - *Graph Structure*: A bipartite or heterogeneous graph where nodes are non-coding RNAs (miRNAs, lncRNAs) and diseases. Edges represent known experimental associations.
  - *Task*: Link prediction. The GNN (often using attention mechanisms or autoencoders) learns to predict novel, unobserved associations between a specific non-coding RNA dysregulation and a disease.

=== Pharmaceutical Scale: Drug Discovery and Repositioning
GRL integrates chemical information, target interactions, and clinical side effects to accelerate drug discovery.

- *Drug-Target Interaction (DTI) Prediction*:
  - *Graph Structure*: A heterogeneous bipartite network where nodes are drugs (chemical compounds) and target proteins. Edges represent binding affinities or known physical interaction.
  - *Task*: Link prediction. Deep mining these networks predicts novel binding targets for existing drugs, which is crucial for early-stage drug discovery (e.g., `DTIGEMS+`).

- *Drug-Disease Association (Drug Repurposing)*:
  - *Graph Structure*: Nodes are drugs and diseases (often encoded using Medical Subject Headings, MeSH. Edges represent treatment indications.
  - *Task*: Link prediction. The model embeds the network to recommend safe, existing approved drugs for new disease indications without designing a new molecule from scratch.

- *Drug-Drug Interaction (DDI) & Polypharmacy Side Effects*:
  - *Graph Structure*: A multi-relational network where nodes are drugs and proteins. Edges between drugs represent specific adverse side effects caused by their co-administration (polypharmacy).
  - *Task*: Edge-label prediction (or multi-relational link prediction). The GNN (e.g., *Decagon*) predicts not just *if* two drugs interact, but *which specific adverse side effect* (the edge label) will occur when a patient takes both drugs simultaneously.
