#import "../template.typ": *

= AI and Patient Similarity Networks for Clinical Medicine

== Clinical Outcome Prediction and Its Challenges

*Clinical outcome prediction* is a fundamental problem in computational biology and precision medicine. It encompasses several critical tasks, such as predicting drug response, disease prognosis, clinical diagnosis, patient subtype stratification, and disease recurrence, with the ultimate goal of discovering biomarkers and unraveling the biomolecular machinery underlying diseases.

However, applying Machine Learning to clinical and multi-omics data presents severe challenges:
- *Small sample size*: the number of available patients (training examples) in clinical cohorts is typically very small.

- *High data dimensionality*: omics profiles (e.g., gene expression, DNA methylation, somatic mutations) are represented as real-valued vectors in a very *high-dimensional space* where the number of features $d$ is much larger than the number of samples $n$ ($d >> n$), resulting in sparse data.

- *Multi-modal data integration*: patient profiles often combine heterogeneous data sources (multi-omics, clinical records, medical imaging, laboratory tests, demographic data) that are difficult to fuse.

- *Missing data*: clinical datasets frequently suffer from missing values—either sporadic missing entries or *entirely missing views* (modalities) for a subset of patients (partial datasets).

- *Limited, noisy, and uncertain labels*: labeled patient data are scarce and prone to *clinical uncertainty* or noise. Moreover, targets are not limited to binary labels (e.g., healthy vs. diseased), but can also be multi-class categories or continuous variables (e.g., survival time).

- *Interpretability*: clinical decisions require validation by human domain experts. Therefore, predictive models must be *interpretable* and *explainable*, allowing clinicians to understand *why* a specific prediction was made.

== Inductive vs. Transductive Learning

Classical Machine Learning approaches (such as Support Vector Machines, Neural Networks, Decision Trees, and Random Forests) follow an *inductive* paradigm: they take training data as input, learn a general predictive model, and apply it to unseen test instances without explicitly modeling the mutual relationships among patients.

In contrast, *Network Medicine* shifts the paradigm toward *transductive (semi-supervised)* graph-based learning by modeling *data as a network—specifically*, a *Patient Similarity Network (PSN)*, where each *node* represents a patient and each *edge* encodes the pairwise biomolecular or clinical similarity between two patients.

#note()[
  *Inductive vs. Transductive Learning*:
  - *Inductive supervised models*: learn a general mapping function (a predictive model) from labeled training biomarkers and use it to predict the outcome of new, unseen samples independently. They do not explicitly account for relationships among individuals and are often *not inherently explainable* ("black-box" models).

  - *Transductive semi-supervised (PSN-based) models*: do not necessarily output a standalone general function; instead, they leverage both labeled and unlabeled nodes jointly within the same graph to directly predict the labels of the unlabeled patients. Because predictions rely on the *topological neighborhood of similar patients*, PSNs are *inherently explainable* and can be inspected visually by using network visualization tools.
]

=== Biomolecular Networks vs. Patient Similarity Networks

In Systems Biology and Network Medicine, life and disease cannot be understood by characterizing single isolated components; instead, we must model the systemic interactions among components using graphs. Two complementary perspectives exist:

1. *Biomolecular Networks* (e.g., *Protein-Protein Interaction (PPI) networks*, *Metabolic networks*):
  - *Nodes*: biomolecules such as genes, proteins, enzymes, metabolites, or drugs.
  - *Edges*: physical, biochemical, or functional interactions. For instance, in a PPI network, two proteins are linked if they physically bind to form a protein complex
  - *Main tasks*: *Automated Function Prediction (AFP)* (predicting Gene Ontology terms of unannotated proteins), *Disease-Gene Prioritization* (ranking candidate genes with respect to a disease), *Drug Repositioning* (finding new therapeutic uses for existing drugs), and identifying unknown protein complexes/pathways via clustering.

2. *Patient Similarity Networks (PSNs)*:
  - *Nodes*: individual patients.
  - *Edges*: pairwise similarity scores between patients' biomolecular, clinical, or multi-omics profiles.
  - *Main tasks*:
    - *Patient subtype stratification* (unsupervised clustering / community detection): partitioning patients affected by the same disease into distinct molecular or clinical subtypes.
    - *Clinical outcome / phenotype prediction* (semi-supervised node classification or ranking): predicting prognosis, therapy response, or survival for unlabeled patients.

== Semi-Supervised Learning on Graphs and the RANKS / P-Net Framework

Given a weighted undirected graph $G = (mb(V), mr(E), mg(W))$:
- $mb(V)$: the set of nodes (e.g., proteins, genes, drugs, or patients), partitioned into a subset of *labeled nodes* $S$ (further containing positive _seed_ nodes $V_C subset S$ belonging to a target class $C$) and a subset of *unlabeled nodes* $U$, such that $V = S union U$.
- $mr(E)$: the set of edges representing functional *relationships* or similarities.
- $mg(W)$: the symmetric *similarity (or affinity) matrix*, where $w_(i j)$ quantifies the similarity between node $i$ and node $j$.

The goal of GSSL is either to assign discrete class labels to the unlabeled nodes $U$ (*node labeling / classification problem*) or to rank the nodes in $V$ according to their *likelihood* of belonging to the target class $C$ (*node ranking / prioritization problem*).

Methods in computational biology fall into two categories:
1. *Local learning strategies*: rely strictly on the immediate (1-hop) neighborhood of a node. The classic example is the *Guilt-By-Association (GBA)* principle, which infers a node's label directly from the labels of its direct neighbors. This method are fast, but they fail to capture the global topology of the graph.

2. *Global learning strategies*: propagate label information across the *entire network topology*. Examples include *Random Walks (RW)*, *Random Walk with Restart (RWR)*, ecc..


=== Random Walks, Random Walk with Restart, and Label Propagation

Given a graph starting point, we proceed to explore the graph by moving to a neighboring node at each step. The (random) sequence of visited nodes is called a *random walk* (RW).

#note()[
  We can see a random walk as a *Markov chain* over the graph's nodes, where the next node to visit depends only on the current node and not on the history of previously visited nodes
]

The algorithm is based on a set of matricies:
- *$W$ (Adjacency or Similarity Matrix)*: a square matrix where the element $w_(i j)$ represents the _weight_ or strength of the connection between node $i$ and node $j$. If there is no connection, $w_(i j) = 0$.
- *$D$ (Degree Matrix)*: a diagonal matrix where each diagonal element $d_(i i)$ is the sum of all the weights of the edges connected to node $i$ (i.e., the sum of row $i$ of the matrix $W$):
  $
    d_(i i) = sum_j w_(i j)
  $

- *$Q$ (Transition Matrix)*: defined as:
  $
    Q = D^(-1) W
  $
  This matrix transforms absolute weights into *transition probabilities*. The element $q_(i j)$ indicates the probability that a _random walker_, currently at node $i$, will move to node $j$. Since the rows are divided by the degree of the node, the sum of each row of $Q$ is exactly $1$.

  ==== Random Walk with Restart (RWR)

  Suppose this task: Given a graph with is adjacency matrix $W$ and a set of seed nodes $V_C$ belonging to a target class $C$, we want to rank all nodes in the graph according to their likelihood of belonging to class $C$.

  First, we define an initial probability vector $p^0$ such that:
  $
    p_i^0 = cases(
      1 / (|V_C|) "if" v in V_C,
      0 "otherwise"
    )
  $
  Then, we iteratively update the probability vector using this algorithm:

  #pseudocode(
    [$Q = D^(-1) W$  _transition matrix_],
    [$t = 0$],
    [*repeat*],
    indent(
      [$t = t +1$],
      [$p^t = (1 - theta) Q^T p^(t-1) + theta p^0$],
    ),
    [*until* convergence $||p^t - p^(t-1)|| < epsilon$],
    [*for each* $i in V$],
    indent(
      [$p_i^t = p_i^t / (sum_j p_j^t)$ _new wieghts normalized to sum to 1_],
    ),
    [*return* the probability vector $p^t$],
  )
  #note()[
    The random walk with restart, use a *restart probability* $theta in (0, 1)$ that allows the walker to jump back to the seed nodes $V_C$ at each step, preventing the walk from drifting too far from the known positives.
  ]

=== Label Propagation and Label Spreading

The goal of these algorithms is the same as RWR: to propagate label information from the labeled nodes $S$ to the unlabeled nodes $U$ across the graph topology.

#note()[
  They use different propagation rules:
  - *RWR* use a idea of "movement" of a random walker: the walkers move according to the transition probabilities. The node labels are updated based on the probability of being visited by the random walker.

  - Label Propagation and Label Spreading use a idea of *"diffusion" of information*: the labels are diffused across the graph according to the similarity weights. The node labels are updated based on the weighted average of their neighbors' labels.
]

The example dataset are divided into two set $hat(Y) = (hat(Y_l), hat(Y_u))$: $hat(Y_l)$ are the labels of the labeled nodes $S$ and $hat(Y_u)$ are the labels of the unlabeled nodes $U$. The algorithms iteratively update the labels of the unlabeled nodes based on the labels of their neighbors, until convergence. The main difference between the two algorithms is how they handle the labeled nodes:

- *Label Propagation*: iteratively updates node label estimates via
  $
    hat(Y)^((t+1)) <- D^(-1) W hat(Y)^((t)) \
    hat(Y)_l^((t+1)) <- Y_l
  $
  the degree-matrix is use to divide the weightes of the neighbors (prediction labels value) of each node, so it is a *weighted average* of the neighbors' labels.

  #note()[
    This algorithm performs a *hard-clamping* of the labeled nodes, meaning that the labels of the labeled nodes are fixed and do not change during the propagation process. This can be problematic if the initial labels are noisy or incorrect, as it can propagate errors throughout the graph.
  ]

- *Label Spreading*: uses the symmetric normalized weight matrix (so that the propagation is symmetric):
  $
    cal(L) = D^(-1/2) W D^(-1/2)
  $
  it iterate until convergence, by updating the labels of the unlabeled nodes based on the labels of their neighbors, and the labels of the labeled nodes are also updated:
  $ hat(Y)^((t+1)) <- alpha cal(L) hat(Y)^((t)) + (1 - alpha) hat(Y)^((0)) $ with $alpha in [0, 1)$. This parameter controls the importance of the initial labels versus the propagated labels. The initial labels are weighted by $(1 - alpha)$, while the propagated labels are weighted by $alpha$.

  #note()[
    Unlike Label Propagation, it does *not* hard-clamp the initial labels, making it more robust to noisy labels.
  ]

  #example(title: "Label Propagation")[
    #figure(
      caption: [Evoluzione temporale della Label Propagation su un grafo a 5 nodi.],
    )[
      #align(center)[
        #cetz.canvas(length: 0.8cm, {
          import cetz.draw: *

          // Funzione di supporto per disegnare il grafo in un certo stato
          let draw-graph(offset-y, title, color1, color2, color3, color4, color5, note-text) = {
            group({
              // Titolo dello step
              content((3, offset-y + 2.5), text(weight: "bold", size: 12pt)[#title])

              // Coordinate dei nodi
              let n1 = (0, offset-y + 1)
              let n2 = (2, offset-y + 1.8)
              let n3 = (2, offset-y + 0.2)
              let n4 = (4, offset-y + 1)
              let n5 = (6, offset-y + 1)

              // Archi
              line(n1, n2, stroke: 1.5pt + gray)
              line(n1, n3, stroke: 1.5pt + gray)
              line(n2, n4, stroke: 1.5pt + gray)
              line(n3, n4, stroke: 1.5pt + gray)
              line(n4, n5, stroke: 1.5pt + gray)

              // Nodi
              circle(n1, radius: 0.4, fill: color1, stroke: 1.5pt + black)
              content(n1, text(weight: "bold")[S1]) // Seed 1 (Positivo)

              circle(n2, radius: 0.4, fill: color2, stroke: 1.5pt + black)
              content(n2, [U1])

              circle(n3, radius: 0.4, fill: color3, stroke: 1.5pt + black)
              content(n3, [U2])

              circle(n4, radius: 0.4, fill: color4, stroke: 1.5pt + black)
              content(n4, [U3])

              circle(n5, radius: 0.4, fill: color5, stroke: 1.5pt + black)
              content(n5, text(weight: "bold")[S2]) // Seed 2 (Negativo)

              // Nota a lato
              content((12, offset-y + 1), align(left, text(size: 9pt, style: "italic")[#note-text]))
            })
          }

          // Colori base
          let c-pos = red
          let c-neg = blue
          let c-unk = white

          // STEP 0: Inizializzazione
          draw-graph(
            8,
            "Step 0: Inizializzazione (t = 0)",
            c-pos,
            c-unk,
            c-unk,
            c-unk,
            c-neg,
            "I nodi S1 (+1, rosso) e S2 (-1, blu)\nhanno etichette note.\nI nodi U1, U2, U3 partono da 0 (bianco).",
          )

          // STEP 1: Prima propagazione
          // U1 è collegato a S1 e U3. Riceve (1 + 0)/2 = +0.5
          // U2 è collegato a S1 e U3. Riceve (1 + 0)/2 = +0.5
          // U3 è collegato a U1, U2 e S2. Riceve (0 + 0 - 1)/3 = -0.33
          draw-graph(
            4,
            "Step 1: Prima Diffusione e Hard Clamping (t = 1)",
            c-pos,
            c-pos.lighten(50%),
            c-pos.lighten(50%),
            c-neg.lighten(66%),
            c-neg,
            "L'inchiostro fluisce:\nU1 e U2 si tingono di rosso.\nU3 riceve il blu da S2.\nS1 e S2 vengono forzati (Clamped)\na rimanere puri.",
          )

          // STEP INF: Convergenza
          draw-graph(
            0,
            "Step ∞: Convergenza (Stato Stazionario)",
            c-pos,
            c-pos.lighten(30%),
            c-pos.lighten(30%),
            c-neg.lighten(30%),
            c-neg,
            "Il sistema si stabilizza.\nU1 e U2 sono classificati come Rossi.\nU3, pur ricevendo un po' di rosso,\nè dominato dal blu (vicinanza a S2).",
          )
        })
      ]
    ]
  ]

=== Global Semi-Supervised Learning cost function

All this semi-supervised learning algorithms try to minimize a *quadratic cost function* $C(hat(Y))$ that balances three terms:
$
  C(hat(Y)) = underbrace(||hat(Y)_l - Y_l||^2, "A: Consistency with initial labels") + mu underbrace(hat(Y)^T L hat(Y), "B: Smoothness over graph geometry") + mu epsilon underbrace(||hat(Y)||^2, "Regularization")
$
where:
- $mr("Term" A)$: ensures that the predicted labels of the labeled nodes $hat(Y)_l$ remain close to their initial labels $Y_l$. If the algorithm predicts $0$ for a labeled node that is actually positive, this term will incur a high cost.
- $mb("Term" B)$: The $L$ represents the graph Laplacian, which encodes the graph's topology. This term encourages *smoothness* in the predicted labels across the graph, meaning that connected nodes (with high similarity) should have similar predicted labels. If two connected nodes are assigned very different labels, this term will incur a high cost:
  $
    1/2 sum_(i, j = 1)^n W_(i j) (hat(y)_i - hat(y)_j)^2
  $
  if the two nodes are connected ($W_(i j) > 0$) and have different predicted labels ($hat(y)_i != hat(y)_j$), this term will be large, penalizing the algorithm for assigning dissimilar labels to similar nodes.

== Kernelized Score Functions (RANKS)

*RANKS* (*RAnking of Nodes with Kernelized Score Functions*) is a modular algorithmic framework that unifies *global* and *local* learning strategies:
1. *Global learning via a Graph Kernel ($K$)*: a kernel matrix $K$ is computed over the graph to capture global topological relationships (multi-step paths) between all pairs of nodes.
2. *Local learning via a Score Function ($S$)*: a local scoring rule aggregates the kernel similarities between a target node $v$ and the known positive seed nodes $V_C$.

The main target is to *rank an unlabeled node* $v$ according to its likelihood of belonging to the positive class $C$ based on its *topological proximity* to the positive seed nodes $V_C$ in the graph (for example a gene associated with a disease, or a patient with a specific clinical outcome).

To achieve this, RANKS works on a *kernelized graph* $G_K = (mb(V), mr(E), mg(K))$, where the original similarity matrix $W$ is replaced by a *graph kernel* $K$ that captures global topological relationships between nodes. Then, a *kernelized score function* $S(v, V_C)$ is applied to rank the nodes in $V$ according to their likelihood of belonging to class $C$.

#figure(
  caption: [Schematic view of a kernelized scoring procedure: positive seed nodes induce augmented connectivity, which is then used to score and rank unlabeled nodes.],
)[
  #align(center)[
    #cetz.canvas(length: 0.72cm, padding: 0.15cm, {
      import cetz.draw: *

      let edges = (
        (0, 1),
        (0, 2),
        (1, 2),
        (1, 3),
        (2, 3),
        (2, 4),
        (3, 5),
        (4, 5),
        (4, 6),
        (5, 7),
        (6, 7),
        (6, 8),
        (7, 9),
        (8, 9),
        (3, 4),
      )
      let nodes = (
        (0.4, 2.8),
        (1.8, 3.6),
        (2.9, 2.7),
        (4.2, 3.5),
        (4.8, 2.0),
        (5.8, 1.0),
        (3.8, 0.4),
        (2.3, 0.8),
        (1.0, 0.2),
        (6.2, 2.4),
      )
      let positive = (1, 2, 3)

      let point(origin, node) = (
        origin.at(0) + node.at(0),
        origin.at(1) + node.at(1),
      )

      let draw-network(origin, augmented: false, scored: false) = {
        // Original edges are black; red edges represent kernel augmentation.
        for edge in edges {
          let start = point(origin, nodes.at(edge.at(0)))
          let end = point(origin, nodes.at(edge.at(1)))
          line(
            start,
            end,
            stroke: if augmented and (edge.at(0) == 1 or edge.at(1) == 1 or edge.at(0) == 3 or edge.at(1) == 3) {
              1pt + red
            } else {
              0.8pt + black
            },
          )
        }

        for index in range(nodes.len()) {
          let pos = point(origin, nodes.at(index))
          let fill-col = if scored and index == 1 {
            blue
          } else if scored and index == 3 {
            red
          } else if scored and index == 8 {
            green
          } else if scored and index == 9 {
            yellow
          } else if positive.contains(index) {
            white
          } else {
            gray.lighten(45%)
          }
          circle(
            pos,
            radius: if positive.contains(index) or scored and (index == 1 or index == 3) { 0.14 } else { 0.11 },
            fill: fill-col,
            stroke: 0.7pt + black,
          )
        }
      }

      // Original network.
      content((0.2, 4.25), text(size: 8pt, weight: "bold")[Original network])
      draw-network((0, 0), augmented: false, scored: false)
      content((0.0, 3.55), text(size: 7pt)[Positive seeds])
      line((0.85, 3.58), (1.55, 3.58), stroke: 0.6pt + gray)

      // Kernelized network.
      content((8.0, 4.25), text(size: 8pt, weight: "bold")[Random-walk kernel])
      draw-network((7.7, 0), augmented: true, scored: false)
      content((12.0, 3.85), text(size: 7pt)[Augmented connectivity])
      line((11.8, 3.58), (11.0, 3.58), stroke: 0.6pt + gray)

      // Scored unlabeled nodes.
      content((0.2, -0.55), text(size: 8pt, weight: "bold")[Scoring of unlabeled nodes])
      draw-network((0, -4.5), augmented: false, scored: true)
      content((0.0, -0.95), text(size: 7pt)[Positive nodes])
      line((0.8, -0.98), (1.45, -0.98), stroke: 0.6pt + gray)

      // Ranking axis.
      content((8.1, -0.55), text(size: 8pt, weight: "bold")[Node ranking])
      line((9.4, -4.25), (9.4, -0.9), stroke: 0.8pt + black)
      line((9.25, -1.0), (9.55, -1.0), stroke: 0.8pt + black)
      line((9.25, -4.15), (9.55, -4.15), stroke: 0.8pt + black)
      content((10.2, -0.75), text(size: 7pt)[high rank])
      content((10.2, -4.45), text(size: 7pt)[low rank])
      circle((9.4, -1.55), radius: 0.1, fill: red, stroke: 0.6pt + black)
      circle((9.4, -2.35), radius: 0.1, fill: blue, stroke: 0.6pt + black)
      circle((9.4, -3.0), radius: 0.1, fill: green, stroke: 0.6pt + black)
      circle((9.4, -3.7), radius: 0.1, fill: yellow, stroke: 0.6pt + black)
      content((11.5, -1.55), text(size: 7pt)[connected with 4 positives])
      content((11.5, -2.75), text(size: 7pt)[connected with 2 positives])
      content((10.1, -3.5), text(size: 7pt)[...])
    })
  ]
]

#example()[
  *Intuitive interpretation of the Random Walk Kernel in RANKS*:
  - In the *original network*, edges only connect patients (or biomolecules) that are directly similar (1-step connections).
  - Applying the *$q$-step Random Walk Kernel* creates a graph with *augmented connectivity*: it adds new indirect edges (weighted by the probability of $q$-step random walks) between nodes that were not directly connected in the original graph but share multi-step paths through intermediate neighbors.
  - Consequently, the kernel *enriches the notion of similarity* by incorporating global topological information. Unlabeled nodes that become strongly connected to multiple positive seed nodes in this augmented graph receive a high score from the local score function ($S_"AV"$, $S_"kNN"$, or $S_"NN"$) and are ranked at the top.
]



=== Mathematical Derivation of Kernelized Score Functions

Let $phi: cal(X) -> cal(H)$ be a mapping from the input node space $cal(X)$ to a Reproducing Kernel Hilbert Space (RKHS) $cal(H)$ induced by a positive semi-definite kernel $K(x_i, x_j) = ⟨phi(x_i), phi(x_j)⟩$.

In this new space, the nodes create a *point cloud*, the centroid of this cloud is the mean of the positive seed nodes $V_C$:
$
  "Centroid" = 1 / (|V_C|) sum_(j in V_C) phi(x_j)
$
Now, we want to measure the distance between an unknown node $x$ and the centroid of the positive class $V_C$ in this feature space. A natural choice is the *squared Euclidean distance*:
$
  D_"AV" (i, V_C) = norm(phi(x_i) - 1 / (|V_C|) sum_(j in V_C) phi(x_j))^2\
  "by using" (||a-b||^2 = ⟨a, a⟩ - 2⟨a, b⟩ + ⟨b, b⟩), ||a||^2 = <a,a>\
  <phi(x_i), phi(x_i)> - 2 <phi(x_i), 1 / (|V_C|) sum_(j in V_C) phi(x_j)> + <1 / (|V_C|) sum_(j in V_C) phi(x_j), 1 / (|V_C|) sum_(j in V_C) phi(x_j)> \
  <phi(x_i), phi(x_i)> - 2 / (|V_C|) sum_(j in V_C) <phi(x_i), phi(x_j)> + 1 / (|V_C|^2) sum_(k in V_C) sum_(j in V_C) <phi(x_k), phi(x_j)>
$
Replacing inner products with the kernel $K$, flipping the sign to turn distance into similarity, and dropping the last term (which is constant with respect to $i$) yields the *Average Score*:
$
  S_"AV" (i, V_C) = -K(x_i, x_i) + 2 / (|V_C|) sum_(j in V_C) K(x_i, x_j)
$
Assuming equal self-similarity $K(x_i, x_i)$ across nodes (or normalizing the kernel), this simplifies to the standard *Kernelized Score Functions* used in RANKS.

#note[
  The score to classfy a node $v$ depends only on the mean of the kernel similarities between $v$ and the positive seed nodes $V_C$.
]
We can define three main kernelized score functions for ranking nodes in RANKS:
- *Average Score ($S_"AV"$)*: averages the kernel similarity between node $v$ and all positive nodes in $V_C$:
  $
    S_"AV" (v, V_C) = 1 / (|V_C|) sum_(x in V_C) K(v, x)
  $
- *Nearest-Neighbor Score ($S_"NN"$)*: takes the maximum kernel similarity between $v$ and any positive node in $V_C$:
  $
    S_"NN" (v, V_C) = max_(x in V_C) K(v, x)
  $
- *$k$-Nearest-Neighbors Score ($S_"kNN"$)*: sums the kernel similarities over the positive nodes that belong to the $k$ nearest neighbors of $v$:
  $
    S_"kNN" (v, V_C) = sum_(x in "kNN"(v) inter V_C) K(v, x)
  $

==== The Random Walk Kernel

A particularly effective kernel for capturing graph topology is the *$q$-step Random Walk Kernel* (Smola and Kondor, 2003):
- Let $W$ be the symmetric similarity matrix and $D$ the diagonal degree matrix with $d_(i i) = sum_j w_(i j)$.
- The unnormalized graph Laplacian is $L = D - W$, and the *symmetric normalized graph Laplacian* is:
  $ tilde(L) = D^(-1/2) mr(L) D^(-1/2) = D^(-1/2) mr((D - W)) D^(-1/2) = I - D^(-1/2) W D^(-1/2) $- The *1-step Random Walk Kernel* is defined as:
  $
    K_"rw" = a I - tilde(L) = (a - 1) I + D^(-1/2) W D^(-1/2)
  $
  where $a >= 1$ (typically $a >= 2$ to ensure positive semi-definiteness) is a parameter that controls the relative weight of self-connections (staying at the current node) versus moving to neighboring nodes.
- The * $q$-step Random Walk Kernel* is obtained by raising the 1-step kernel to the power $q$:$ K_"rw"^q = (a I - tilde(L))^q = ((a - 1) I + D^(-1/2) W D^(-1/2))^q $


== The P-Net Algorithm for Patient Similarity Networks

*P-Net* (Gliozzo et al., *Scientific Reports*, 2020) adapts the RANKS framework specifically to Patient Similarity Networks for clinical outcome prediction (like: prognosis, diagnosis, prediction of drug response, or survival).


The $P$-Net algorithm consists of the following steps:
1. *Patient matrix construction*: each patient $p_i$ is represented by a feature vector $(f_1, dots, f_m)$ (e.g., gene expression, clinical biomarkers), forming a patient-by-feature matrix $M$.
2. *Data cleaning and initial similarity matrix ($W$) construction*: after preprocessing, a *pairwise similarity metric* (e.g., Pearson correlation, cosine similarity) is computed between all pairs of patients to build the square similarity matrix $W$.
3. *Kernel matrix ($K$) construction*: a graph kernel (such as the $q$-step Random Walk Kernel) is applied to $W$ to obtain the kernel matrix $K$, capturing global relationships across the patient cohort.
4. *P-Net filtering (sparsification)*: while kernelization enriches the similarity representation, it also makes the *matrix dense* and introduces weak, noisy connections between distant patients. A filtering step removes edges whose kernel weights fall below a given threshold (or retains only top-$k$ neighbors), eliminating noise while preserving informative multi-step connections.
5. *Node (patient) scoring*: a kernelized score function ($S_"AV"$, $S_"kNN"$, or $S_"NN"$) is applied over the filtered kernel matrix to score and rank patients with respect to the clinical phenotype or outcome $C$ under study.

#figure[
  #align(center)[
    #image("../img/pndg.png", width: 70%)
  ]
]

#warning(title: "Trade-off in Graph Kernelization and Network Integration")[
  *Enriching* a graph via a multi-step kernel (or by integrating multiple biological networks, such as combining chemical structural similarity $N_"structSim"$, drug-target projections $N_"drugTarget"$, and chemical interactions $N_"drugChem"$ in drug repositioning) dramatically increases network connectivity and coverage, leading to statistically significant improvements in AUC and Precision-Recall. However, excessive densification can introduce topological noise, making proper pre-processing, normalization, and *network filtering* essential.
]

== Multi-Modal PSN Integration, Missing Data, and Dimensionality Reduction

When *multiple data modalities* (e.g., DNA methylation, mRNA expression, protein abundance, clinical data) are available for the same set of patients (*multimodal / heterogeneous datasets*, working in a *parallel-vertical integration flow*), integrative PSN methods are classified into three main paradigms:

1. *Input-data fusion (Early integration / concatenation-based methods)*:
  - First, the separate data matrices are transformed or embedded into a *joint shared low-dimensional latent space* during pre-processing using methods such as *JIVE / AJIVE* (PCA-based), *intNMF / iNMF* (Non-negative Matrix Factorization-based).
  - Second, a *single PSN* is computed on the integrated latent representation and used for downstream unsupervised clustering or supervised classification.

2. *Output-data integration (Late integration)*:
  - First, an independent *unimodal PSN* is built for each data modality using a modality-specific similarity measure.
  - Second, clustering or classification is performed separately on each unimodal PSN.
  - Third, the individual predictions or clusterings are combined at the end via consensus aggregation or meta-models (e.g., *SUMO*, *PINSPlus*).
3. *PSN-fusion (Intermediate / Model integration)*:
  - First, a separate *unimodal PSN* is constructed for each data modality.
  - Second, the unimodal networks are fused into a *single integrated PSN* via network-fusion algorithms—such as *SNF (Similarity Network Fusion)*, *NEMO*, *netDx*, or *MSNE*—prior to running downstream clustering or outcome prediction.

=== Similarity Network Fusion (SNF), MP-Net, and Miss-SNF

- *SNF (Similarity Network Fusion, Wang et al., Nature Methods, 2014)*[cite: 240]:
  For each data view $v$, SNF builds a patient similarity matrix $W^((v))(i, j) = exp(- rho(x_i, x_j)^2 / (mu epsilon_(i j)))$ and derives two normalized matrices[cite: 240]:
  1. A *global normalized similarity matrix* $P^((v))$ capturing similarities across all patients (with $P(i, i) = 1/2$, and $P(i, j) = W(i, j) / (2 sum_(k != i) W(i, k))$ for $j != i$)[cite: 240].
  2. A *local normalized similarity matrix* $S^((v))$ restricted only to the $k$-nearest neighbors $N_i$ of each patient ($S(i, j) = W(i, j) / (sum_(k in N_i) W(i, k))$ if $j in N_i$, and $0$ otherwise)[cite: 240].
  SNF then iteratively updates the global matrices through a non-linear *message-passing (diffusion) process* between views[cite: 240]:
  $
    P_(t+1)^((1)) = S^((1)) times P_t^((2)) times (S^((1)))^T, quad P_(t+1)^((2)) = S^((2)) times P_t^((1)) times (S^((2)))^T
  $
  At each iteration, two patients $i$ and $j$ become more similar in view $1$ if their local neighbors $k in N_i$ and $l in N_j$ in view $1$ are strongly connected in view $2$[cite: 240]. Weak edges unsupported across views disappear, while edges supported by all or single strong views are reinforced[cite: 240].
- *MP-Net*: extends *P-Net* to multi-omics data by using *SNF* as an integration module to fuse unimodal similarity matrices ($W_1, W_2, dots$) into an integrated similarity matrix $W$, followed by Random Walk kernelization, P-Net filtering, and kernelized node scoring[cite: 241, 249].
- *Handling Missing Data and Miss-SNF* (Gliozzo et al., *Bioinformatics*, 2025)[cite: 242, 244, 245]:
  - If only *sporadic feature values* are missing, standard imputation methods like *KNN* (for multi-omics) or *missForest* (for mixed data types) can be used[cite: 242].
  - However, in clinical practice it is common to have *partial datasets* where an entire omics modality (view) is completely missing for a subset of patients[cite: 242, 243, 244]. *Miss-SNF* modifies the SNF message-passing process (via variants such as *miss-SNF zero*, *miss-SNF one*, and *miss-SNF equidistant*) to partially reconstruct the missing pairwise similarities in an unmeasured view by propagating local and global topological information from the other available views[cite: 244, 245].

=== Addressing Small Sample Size via Intrinsic Dimensionality (ID)

To combat the *curse of dimensionality* ($d >> n$) without arbitrarily discarding informative biological signals, dimensionality reduction (via unsupervised *Feature Selection (FS)*, *Feature Extraction (FE)* such as RPCA, Laplacian Eigenmaps, UMAP, t-SNE, or *FS + FE*) can be guided by estimating the *Intrinsic Dimensionality (ID)* of each omics view (Gliozzo et al., *Artificial Intelligence in Medicine*, 2025)[cite: 246, 247, 248]:
- Informally, the *Intrinsic Dimensionality ($"id"$)* is the minimum dimension of the latent manifold onto which the data can be smoothly projected without information loss (analogous to points lying on a 2D sheet of paper embedded in a 3D space, where $"id" = 2$)[cite: 247].
- Using block-analysis and the *two-NN ID estimator* ($hat(d)_"twonn"$), one can detect whether a view contains redundant/noisy features (indicated by a plateau in the ID curve) and automatically set the target reduced dimension $d$ before applying multi-omics data fusion (Concat, MOFA+, SNF, uMKL)[cite: 248].

= Graph Representation Learning (GRL)

== Introduction to Graph Embeddings

In traditional machine learning on graphs—whether for node classification, link prediction, community detection, or network similarity—one had to perform tedious manual *feature engineering* for every task (computing node degree, PageRank scores, clustering coefficients, graph motifs, etc.)[cite: 136, 137, 138].

*Graph Representation Learning (GRL)* eliminates manual feature engineering by *automatically learning* low-dimensional vector representations (*embeddings*) of nodes (or edges/subgraphs) directly from the network structure[cite: 138, 139, 140, 294]:
$
  f: u in V -> bold(z)_u in RR^d quad "with" quad d << |V|
$
The goal is to project the original graph into a low-dimensional *Euclidean latent space* $RR^d$ such that the geometric proximity (e.g., dot product or cosine similarity) between embedded vectors reflects the topological similarity and link strength between nodes in the original network[cite: 140, 142, 294]. Once learned, these embedded vectors can be fed into any standard unsupervised algorithm (e.g., clustering for patient stratification, community detection, anomaly detection) or supervised inductive classifier (e.g., node label prediction, link prediction, clinical outcome prediction)[cite: 140, 175, 230, 231, 294].

#warning()[
  *Why is Graph Embedding Hard? (Graphs are Non-Euclidean)*[cite: 143, 144, 145, 294]:
  - *Images* have a fixed, regular *2D grid* structure, and *text or audio signals* have a regular *1D linear* structure, where spatial locality and sliding windows (convolutions) are naturally well-defined[cite: 143, 144].
  - *Graphs are non-Euclidean*: they have an arbitrary, irregular topology with no fixed notion of direction or coordinate grid, and *node numbering (ordering) is completely arbitrary* (related to the graph isomorphism problem)[cite: 144, 145, 294].
]

There are two main research lines in Graph Representation Learning[cite: 146, 147, 232, 294]:
1. *Random Walk-based Graph Embedding* (e.g., *DeepWalk*, *node2vec*, *Het-node2vec*): *linearizes* the graph topology by generating sequences ("sentences") of nodes through random walks, and then optimizes an embedding lookup table so that nodes co-occurring in short random walks are mapped close together in $RR^d$[cite: 146, 147, 174, 232, 294].
2. *Graph Neural Networks (GNNs)* (e.g., *Graph Convolutional Networks (GCNs)*, *Graph Attention Networks (GATs)*, *GraphSAGE*): fuse *graph topology* and *node/edge attributes*, iteratively propagating and aggregating feature messages between neighboring nodes in an *end-to-end* supervised or semi-supervised manner[cite: 146, 147, 232, 294].

#figure(
  caption: [Comparison between the two main GRL paradigms: (1) Two-step Graph Embedding based on topology and random walks, and (2) End-to-end Graph Neural Networks fusing topology and node attributes[cite: 147, 232].],
)[
  #align(center)[
    #cetz.canvas(length: 0.85cm, padding: 0.2cm, {
      import cetz.draw: *

      // --- 1. GRAPH EMBEDDING ---
      content((-0.6, 2.5), text(weight: "bold", fill: maroon)[1.])
      rect((0, 1.9), (2.4, 3.1), radius: 0.15, stroke: 0.8pt + black, fill: gray.lighten(90%))
      content((1.2, 2.5), text(size: 8.5pt)[*Topology* (Graph $G$)])

      line((2.4, 2.5), (3.6, 2.5), mark: (end: ">", fill: black), stroke: 0.8pt)

      rect((3.6, 1.9), (6.8, 3.1), radius: 0.15, stroke: 1pt + purple, fill: purple.lighten(90%))
      content((5.2, 2.5), align(center, text(
        size: 8.5pt,
        fill: purple.darken(20%),
      )[*Graph Embedding* (e.g., `node2vec`)]))

      line((6.8, 2.5), (8.0, 2.5), mark: (end: ">", fill: black), stroke: 0.8pt)

      rect((8.0, 1.9), (10.8, 3.1), radius: 0.15, stroke: 0.8pt + teal, fill: teal.lighten(90%))
      content((9.4, 2.5), align(center, text(size: 8.5pt)[*Embeddings* ($bold(z)_u in RR^d$)]))

      line((10.8, 2.5), (12.4, 2.5), mark: (end: ">", fill: black), stroke: (dash: "dashed", thickness: 0.8pt))
      content((11.6, 2.85), text(size: 7.5pt)[Features])

      rect((12.4, 1.9), (15.0, 3.1), radius: 0.15, stroke: 0.8pt + black)
      content((13.7, 2.5), text(size: 8.5pt)[*Task Results*])

      // --- 2. GRAPH NEURAL NETWORK ---
      content((-0.6, 0.4), text(weight: "bold", fill: maroon)[2.])
      rect((0, -0.2), (2.4, 1.0), radius: 0.15, stroke: 0.8pt + black, fill: orange.lighten(85%))
      content((1.2, 0.4), align(center, text(size: 8.5pt)[*Attributes* (Node Features)]))

      // Fusion arrows into GNN
      line((1.2, 1.9), (1.2, 1.3), (5.2, 1.3), (5.2, 1.0), mark: (end: ">", fill: black), stroke: 0.8pt)
      line((2.4, 0.4), (5.2, 0.4), mark: (end: ">", fill: black), stroke: 0.8pt)
      content((3.7, 0.1), text(size: 7.5pt)[Fusion])

      rect((5.2, -0.2), (8.8, 1.0), radius: 0.15, stroke: 1pt + blue.darken(20%), fill: blue.lighten(90%))
      content((7.0, 0.4), align(center, text(size: 8.5pt, fill: blue.darken(30%))[*Graph Neural Network* (GNN / GCN)]))

      line((8.8, 0.4), (12.4, 0.4), mark: (end: ">", fill: black), stroke: 0.8pt)
      content((10.6, 0.1), text(size: 7.5pt)[End-to-end])

      rect((12.4, -0.2), (15.0, 1.0), radius: 0.15, stroke: 0.8pt + black)
      content((13.7, 0.4), text(size: 8.5pt)[*Task Results*])
    })
  ]
]

== From Word2Vec to Unsupervised Graph Embedding

=== Word2Vec and the Skip-Gram Architecture

Before embedding graphs, random-walk methods draw direct inspiration from *Word2Vec* (Mikolov et al., *NIPS / ICLR*, 2013), an algorithm designed to learn continuous vector representations of words from linear text[cite: 149, 150, 153, 294].

Word2Vec relies on the *distributional hypothesis*: words that appear in similar surrounding contexts (i.e., have similar neighboring words within a sliding window) are semantically related and should be mapped to nearby points in Euclidean space[cite: 149, 154, 294].
- Given a source sentence (e.g., *"The quick brown fox jumps over the lazy dog"*), a sliding context window around each target word generates training pairs of $("target word", "context word")$, such as `("fox", "quick")`, `("fox", "brown")`, `("fox", "jumps")`, `("fox", "over")`[cite: 149].
- In the *Skip-Gram model*, a shallow *one-hidden-layer neural network* is trained to predict the surrounding context words given a target input word[cite: 150, 153, 294]:
  1. *Input layer*: the $i$-th word in a vocabulary of size $n$ (e.g., $n = 10,000$ words) is represented as a *one-hot encoded column vector* $bold(x)_i in {0, 1}^n$, having a single $1$ at index $i$ and $0$ elsewhere[cite: 150, 151, 294].
  2. *Hidden (Embedding) layer*: the input vector is multiplied by a learnable *embedding weight matrix* $W in RR^(n times p)$, where $p$ (or $d$, e.g., $p = 300$) is the embedding dimension[cite: 150, 151, 294]. Because $bold(x)_i$ is one-hot encoded, the product
    $
      bold(z)_i^T = bold(x)_i^T W in RR^(1 times p)
    $
    simply selects the *$i$-th row of $W$*[cite: 151]. Thus, $W$ acts as a *lookup table* where row $i$ is the $p$-dimensional embedding $bold(z)_i$ of word $i$, and the hidden layer consists of $p$ linear neurons (no nonlinear activation function)[cite: 150, 151, 294].
  3. *Output (Softmax) layer*: the hidden vector $bold(z)_i$ is multiplied by a second *context weight matrix* $U in RR^(p times n)$ (also denoted $W'$) to produce raw logits $bold(y) = U^T bold(z)_i in RR^n$[cite: 152, 153, 294]. A *softmax classifier* converts these scores into a probability distribution over all $n$ words in the vocabulary[cite: 150, 152, 294]:
    $
      P("word" j "in context" | "word" i) = "softmax"(y_j) = (exp(y_j)) / (sum_(k=1)^n exp(y_k)) = (exp(bold(z)_i^T bold(u)_j)) / (sum_(k=1)^n exp(bold(z)_i^T bold(u)_k))
    $

#note()[
  In Skip-Gram, the neural network prediction task is only a *proxy (pretext) task*: once training is complete, the output layer is discarded and the learned rows of the weight matrix $W$ are used as the Euclidean word embeddings[cite: 149, 151, 152, 294].
]

#figure(
  caption: [Architecture of the Skip-Gram neural network used in Word2Vec and adapted for Random Walk graph embeddings (`DeepWalk` / `node2vec`)[cite: 150, 153, 164].],
)[
  #align(center)[
    #cetz.canvas(length: 0.85cm, padding: 0.2cm, {
      import cetz.draw: *

      // Input one-hot vector
      content((0.6, 4.3), text(size: 8.5pt, weight: "bold")[Input $bold(x)_i$])
      content((0.6, 3.85), text(size: 7.5pt)[(One-hot, $|V| times 1$)])
      for idx in range(6) {
        let y = 0.5 + idx * 0.5
        let val = if idx == 3 { "1" } else { "0" }
        let fill-col = if idx == 3 { teal.lighten(70%) } else { white }
        rect((0.2, y), (1.0, y + 0.5), stroke: 0.7pt + black, fill: fill-col)
        content((0.6, y + 0.25), text(size: 8pt)[#val])
      }
      content((0.6, 0.2), text(size: 7.5pt)[Node $u_i$])

      // Matrix W
      rect((2.2, 0.6), (4.8, 3.4), stroke: 0.9pt + orange.darken(20%), fill: orange.lighten(88%))
      rect((2.2, 2.0), (4.8, 2.5), stroke: 1pt + red.darken(10%), fill: orange.lighten(55%))
      content((3.5, 2.25), text(size: 7.5pt, weight: "bold")[Row $i$: $bold(z)_i = f(u_i)$])
      content((3.5, 1.2), align(center, text(size: 8.5pt)[*Matrix $W$* ($|V| times d$) Lookup Table]))

      line((1.0, 2.25), (2.2, 2.25), mark: (end: ">", fill: black), stroke: 0.8pt)
      line((4.8, 2.25), (6.0, 2.25), mark: (end: ">", fill: black), stroke: 0.8pt)

      // Hidden layer z_i
      content((6.4, 4.3), text(size: 8.5pt, weight: "bold")[Hidden $bold(z)_i$])
      content((6.4, 3.85), text(size: 7.5pt)[(Embedding, $RR^d$)])
      rect((6.0, 1.0), (6.8, 3.1), radius: 0.3, stroke: 1pt + teal, fill: teal.lighten(85%))
      for idx in range(4) {
        let y = 1.3 + idx * 0.45
        circle((6.4, y), radius: 0.16, stroke: 0.6pt + teal.darken(30%), fill: white)
      }
      content((6.4, 0.6), text(size: 7.5pt)[$d$ neurons])

      line((6.8, 2.05), (8.0, 2.05), mark: (end: ">", fill: black), stroke: 0.8pt)

      // Context Matrix W' / U
      rect((8.0, 0.9), (10.6, 3.2), stroke: 0.9pt + green.darken(30%), fill: green.lighten(88%))
      content((9.3, 2.05), align(center, text(size: 8.5pt)[*Context Matrix $U$* ($d times |V|$)]))

      line((10.6, 2.05), (11.8, 2.05), mark: (end: ">", fill: black), stroke: 0.8pt)

      // Output Softmax
      content((12.4, 4.3), text(size: 8.5pt, weight: "bold")[Output $" softmax"$])
      content((12.4, 3.85), text(size: 7.5pt)[$Pr(n_j | f(u_i))$])
      for idx in range(6) {
        let y = 0.5 + idx * 0.5
        rect((11.8, y), (13.0, y + 0.5), stroke: 0.7pt + black, fill: gray.lighten(92%))
        content((12.4, y + 0.25), text(size: 7.5pt)[$y_(#{ 6 - idx })$])
      }
    })
  ]
]

=== From Linear Text to Graphs: Neighborhood Strategies and Linearization

To transfer the Skip-Gram paradigm from text to networks, we view *nodes as words* and define a notion of *node neighborhood $N_S (u)$* (generated by a sampling strategy $S$) that plays the role of the surrounding context window in a sentence[cite: 156, 159, 160, 294].

Different strategies $S$ can be used to define the neighborhood $N_S (u)$ of a node $u$[cite: 156, 157, 294]:
- Direct $k$-hop neighbors (nodes at shortest-path distance $<= k$ from $u$)[cite: 157, 294].
- Nodes lying along the shortest path between pairs of nodes[cite: 157].
- *Nodes visited along a $k$-step random walk starting from $u$*[cite: 157, 158, 159, 294].

#example()[
  *Graph Linearization via Random Walks*[cite: 159, 160, 294]:
  Suppose we start a short random walk from node $10$ in a graph $G$[cite: 159, 160, 294]:
  - Walk 1 (red): $(10 -> 15 -> 16)$ $==>$ generates Skip-Gram training pairs $(10, 15)$ and $(10, 16)$[cite: 159, 160, 294].
  - Walk 2 (blue): $(10 -> 11 -> 5)$ $==>$ generates training pairs $(10, 11)$ and $(10, 5)$[cite: 159, 160, 294].
  - Walk 3 (green): $(10 -> 9 -> 8)$ $==>$ generates training pairs $(10, 9)$ and $(10, 8)$[cite: 159, 160, 294].

  By simulating multiple random walks across the network, we *linearize the non-Euclidean graph* into a corpus of node sequences ("sentences"), allowing us to apply One-Hot Encoding and the Skip-Gram architecture exactly as in Word2Vec[cite: 146, 159, 160, 294].
]

== Optimization Objective and DeepWalk

=== Feature Learning as Maximum Likelihood Optimization

Given a graph $G = (V, E)$, our goal is to learn an embedding mapping $f: V -> RR^d$ (parameterized as a $|V| times d$ lookup table) that maximizes the log-probability of observing a node's network neighborhood $N_S (u)$ conditioned on its feature representation $f(u)$[cite: 161, 162, 163, 294]:
$
  max_f sum_(u in V) log Pr(N_S (u) | f(u))
$

To make this optimization problem mathematically tractable, two fundamental assumptions are introduced[cite: 162, 163, 294]:
1. *Conditional independence*: given the embedding $f(u)$ of the source node $u$, the probabilities of observing individual neighborhood nodes $n_i in N_S (u)$ factorize independently[cite: 162, 163, 294]:
  $
    Pr(N_S (u) | f(u)) = product_(n_i in N_S (u)) Pr(n_i | f(u))
  $
2. *Symmetry in feature space*: a source node and a neighborhood node have a symmetric effect on each other in the embedding space. Therefore, the conditional probability of every source-neighborhood pair $(u, n_i)$ is modeled as a *softmax* over the dot product of their embeddings[cite: 162, 163, 294]:
  $
    Pr(n_i | f(u)) = (exp(f(n_i) dot f(u))) / (sum_(v in V) exp(f(v) dot f(u)))
  $

Substituting both assumptions into the objective function yields[cite: 163, 294]:
$
  max_f sum_(u in V) log product_(n_i in N_S (u)) Pr(n_i | f(u)) & = max_f sum_(u in V) sum_(n_i in N_S (u)) log (exp(f(n_i) dot f(u))) / (sum_(v in V) exp(f(v) dot f(u))) \
  & = max_f sum_(u in V) [ -|N_S (u)| log Z_u + sum_(n_i in N_S (u)) f(n_i) dot f(u) ]
$
(often written compactly per neighborhood scaling as $max_f sum_(u in V) [ -log Z_u + sum_(n_i in N_S (u)) f(n_i) dot f(u) ]$)[cite: 163, 294], where
$
  Z_u = sum_(v in V) exp(f(u) dot f(v))
$
is the per-node *partition function* (normalization constant)[cite: 163, 294].
- Intuitively, maximizing the second term $sum_(n_i in N_S (u)) f(n_i) dot f(u)$ pulls the embedding $f(u)$ close to the embeddings $f(n_i)$ of its neighbors (maximizing their dot-product similarity)[cite: 294].
- Minimizing the first term $log Z_u$ pushes $f(u)$ away from all arbitrary non-neighboring nodes $v in V$ in the graph[cite: 294]. Because computing $Z_u$ over all $|V|$ nodes is expensive ($O(|V|)$), it is approximated in practice using *Hierarchical Softmax* (via a binary tree over $V$, as in DeepWalk) or *Negative Sampling* (as in node2vec), and optimized via *Stochastic Gradient Ascent / Descent (SGD)*[cite: 162, 163, 165, 173].

=== DeepWalk: First-Order Unbiased Random Walks

The first strategy to sample $N_S (u)$ is *DeepWalk* (Perozzi et al., *ACM SIGKDD*, 2014), which uses *unbiased first-order random walks* (where at each step the walker moves to any connected neighbor with probability proportional only to the edge weight)[cite: 165, 294].

#example()[
  *Algorithm: DeepWalk $(G, w, d, gamma, t)$*[cite: 165]
  - *Inputs*: graph $G(V, E)$, context window size $w$, embedding dimension $d$, number of walks per vertex $gamma$, walk length $t$[cite: 165].
  - *Output*: matrix of vertex representations $Phi in RR^(|V| times d)$[cite: 165].
  1. Initialize $Phi$ by sampling uniformly from $cal(U)^(|V| times d)$[cite: 165].
  2. Build a binary tree $T$ from $V$ (for Hierarchical Softmax)[cite: 165].
  3. *for* $i = 1$ *to* $gamma$ *do*[cite: 165]:
    - $cal(O) = "Shuffle"(V)$[cite: 165]
    - *for each* $v_i in cal(O)$ *do*[cite: 165]:
      - $cal(W)_(v_i) = "RandomWalk"(G, v_i, t)$[cite: 165]
      - $"SkipGram"(Phi, cal(W)_(v_i), w)$[cite: 165]
]

#note()[
  *Role of the number of walks $gamma$*: if $gamma$ is too small (e.g., $gamma = 1$), only a single random trajectory is sampled from each vertex, which fails to capture the true structure of the node's neighborhood due to stochastic variance. A sufficiently large $gamma$ is required so that multiple random walks thoroughly explore the local and global neighborhood of every node[cite: 165, 294].
]

== node2vec: Biased Second-Order Random Walks

=== Interpolating Between BFS (Micro-View) and DFS (Macro-View)

*node2vec* (Grover and Leskovec, *KDD*, 2016) generalizes DeepWalk by observing that a flexible notion of neighborhood $N_S (u)$ should smoothly interpolate between two classic extreme graph search strategies[cite: 148, 166, 167, 168, 294]:
1. *Breadth-First Search (BFS)*: explores only the immediate local neighborhood of $u$ ($N_"BFS" (u) = {s_1, s_2, s_3}$)[cite: 166]. It provides a *local microscopic view* of the neighborhood, which is ideal for characterizing *structural equivalence* (nodes that play similar structural roles in the network, such as hubs or bridges, even if they are far apart)[cite: 166, 167, 172, 180, 294].
2. *Depth-First Search (DFS)*: explores paths moving progressively farther away from $u$ ($N_"DFS" (u) = {s_4, s_5, s_6}$)[cite: 166]. It provides a *global macroscopic view* of the neighborhood, which is essential for capturing *homophily* (nodes that belong to the same densely connected community or cluster)[cite: 166, 167, 172, 180, 294].

=== Biased 2nd-Order Random Walk Parameterization

To interpolate between BFS and DFS, node2vec replaces first-order Markovian walks with a *biased second-order random walk ($"RW"_2$)* that remembers the previous node visited[cite: 169, 180, 294].
Suppose the walk just traversed edge $(r, v)$ (so at time $t-1$ it was at node $r$, and at time $t$ it is currently at node $v$) and must choose the next node $x$ at time $t+1$[cite: 169, 170, 180].

The transition probability $P(X(t+1) = x | X(t) = v, X(t-1) = r)$ is proportional to the unnormalized transition weight[cite: 180]:
$
  pi_(v x) = alpha_(p, q) (r, x) dot w_(v, x)
$
where $w_(v, x)$ is the static edge weight between $v$ and $x$, and the search bias $alpha_(p,q)(r, x)$ depends on the *shortest-path distance $d_(r x) in {0, 1, 2}$* between the previous node $r$ and the candidate next node $x$, governed by two parameters $p$ and $q$[cite: 168, 169, 170, 180, 294]:
$
  alpha_(p, q) (r, x) = cases(
    1 / p & quad "if " d_(r x) = 0 quad ("return back to the previous node " x = r),
    1 & quad "if " d_(r x) = 1 quad ("move to a neighbor at the same distance from " r),
    1 / q & quad "if " d_(r x) = 2 quad ("move outwards to a node farther from " r),
  )
$

#figure(
  caption: [Illustration of the biased 2nd-order random walk in `node2vec`. The walk just transitioned from $r$ (or $u$) to $v$ (or $w$) and evaluates candidate next steps based on shortest-path distance $d_(r x)$[cite: 169, 170, 171, 180].],
)[
  #align(center)[
    #cetz.canvas(length: 1.0cm, padding: 0.25cm, {
      import cetz.draw: *

      let pos-u = (0.0, 0.5)
      let pos-r = (1.8, 0.5)
      let pos-v = (3.8, 1.8)
      let pos-x1 = (2.2, 3.0)
      let pos-x2 = (5.8, 2.8)
      let pos-x3 = (5.5, 0.5)

      // Edges
      line(pos-u, pos-r, stroke: 1.2pt + black)
      line(pos-r, pos-v, stroke: 1.5pt + black)
      line(pos-r, pos-x1, stroke: 1.2pt + black)
      line(pos-v, pos-x1, stroke: 1.2pt + black)
      line(pos-v, pos-x2, stroke: 1.2pt + black)
      line(pos-v, pos-x3, stroke: 1.2pt + black)

      // Biased transition arrows from v
      // Back to r (d = 0)
      line((3.3, 1.3), (2.3, 0.65), mark: (end: ">", fill: blue), stroke: 1.4pt + blue)
      content((3.15, 0.65), text(fill: blue.darken(15%), size: 9pt, weight: "bold")[$alpha = 1 / p$])
      content((2.2, -0.15), text(fill: blue.darken(20%), size: 8pt)[Closer to $r$ ($d_(r, r) = 0$)])

      // To x1 (d = 1)
      line((3.35, 2.25), (2.65, 2.75), mark: (end: ">", fill: red), stroke: 1.4pt + red)
      content((3.35, 2.7), text(fill: red.darken(15%), size: 9pt, weight: "bold")[$alpha = 1$])
      content((2.2, 3.65), text(fill: red.darken(20%), size: 8pt)[Same distance to $r$ ($d_(r, x_1) = 1$)])

      // To x2 (d = 2)
      line((4.3, 2.15), (5.25, 2.65), mark: (end: ">", fill: orange.darken(10%)), stroke: 1.4pt + orange.darken(10%))
      content((4.9, 1.95), text(fill: orange.darken(25%), size: 9pt, weight: "bold")[$alpha = 1 / q$])
      content((6.2, 3.45), text(fill: orange.darken(25%), size: 8pt)[Farther from $r$ ($d_(r, x_2) = 2$)])

      // To x3 (d = 2)
      line((4.25, 1.35), (5.05, 0.75), mark: (end: ">", fill: orange.darken(10%)), stroke: 1.4pt + orange.darken(10%))
      content((4.4, 0.75), text(fill: orange.darken(25%), size: 9pt, weight: "bold")[$alpha = 1 / q$])

      // Nodes
      circle(pos-u, radius: 0.38, fill: gray.lighten(75%), stroke: 1.2pt + black)
      content(pos-u, text(size: 10pt)[$u$])

      circle(pos-r, radius: 0.42, fill: blue.lighten(80%), stroke: 1.4pt + blue.darken(20%))
      content(pos-r, text(size: 10pt, weight: "bold")[$r$ ($s_1$)])

      circle(pos-v, radius: 0.42, fill: green.lighten(65%), stroke: 1.5pt + black)
      content(pos-v, text(size: 10pt, weight: "bold")[$v$ ($w$)])

      circle(pos-x1, radius: 0.42, fill: red.lighten(80%), stroke: 1.4pt + red.darken(20%))
      content(pos-x1, text(size: 10pt, weight: "bold")[$x_1$ ($s_2$)])

      circle(pos-x2, radius: 0.42, fill: orange.lighten(80%), stroke: 1.4pt + orange.darken(20%))
      content(pos-x2, text(size: 10pt, weight: "bold")[$x_2$ ($s_3$)])

      circle(pos-x3, radius: 0.42, fill: orange.lighten(80%), stroke: 1.4pt + orange.darken(20%))
      content(pos-x3, text(size: 10pt, weight: "bold")[$x_3$])
    })
  ]
]

- *Return parameter $p$*: controls the probability of immediately backtracking to the previous node $r$[cite: 168, 170, 180, 294].
  - Setting a *low value of $p$* ($p < min(1, q)$) yields a high weight $1/p$, encouraging the walk to backtrack and remain strictly local around the starting node (*BFS-like behavior*)[cite: 171, 180, 294].
  - Setting a *high value of $p$* reduces $1/p$, preventing immediate backtracking[cite: 294].
- *In-out ("walk away") parameter $q$*: controls the ratio between moving *inwards* (BFS) versus moving *outwards* (DFS)[cite: 168, 170, 180, 294].
  - If *$q > 1$* (so $1/q < 1$), the walk is biased toward nodes close to $r$, yielding a *BFS-like microscopic view* (capturing *structural equivalence*, e.g., $p = 1, q = 2$)[cite: 172, 180, 294].
  - If *$q < 1$* (so $1/q > 1$), the walk is biased to explore outward nodes far from $r$, yielding a *DFS-like macroscopic view* (capturing *homophily / community structure*, e.g., $p = 1, q = 0.5$)[cite: 171, 172, 180, 294].

=== Summary of the node2vec Workflow

The complete `node2vec` pipeline operates in three parallelizable steps with *linear time complexity*[cite: 173, 174]:
1. Precompute the modified 2nd-order transition probabilities $pi_(v x)$ according to parameters $(p, q)$[cite: 173, 180].
2. Simulate $r$ biased random walks of fixed length $l$ starting from each node $u in V$ to generate the node neighborhoods $N_S (u)$[cite: 173].
3. Optimize the Skip-Gram log-likelihood objective via Stochastic Gradient Descent (SGD) to obtain the node embeddings, which can then be used for any downstream unsupervised (clustering, community detection) or supervised (node/edge classification) task[cite: 173, 174, 175, 176].

= Heterogeneous Graph Representation Learning: Het-node2vec

== Homogeneous vs. Heterogeneous Networks

Standard algorithms like DeepWalk and node2vec are designed for *homogeneous graphs*, where all nodes and all edges are treated as belonging to a single uniform type[cite: 177]. However, most real-world biological and medical networks are *heterogeneous*[cite: 177]:
- *Multiplex networks*: the same set of nodes connected across multiple layers representing different relationship types[cite: 177].
- *Multi-layered networks*: distinct layers of different node types connected both within layers (intra-layer edges) and across layers (inter-layer edges)[cite: 177].
- *Heterogeneous multigraphs / Biomedical Knowledge Graphs* (such as *HetioNet*, Himmelstein & Baranzini, 2015): integrate many distinct types of nodes (e.g., *Genes*, *Compounds/Drugs*, *Diseases*, *Side Effects*, *Pathways*, *Anatomy*, *Symptoms*, *Molecular Functions*) and multiple semantic edge types (e.g., *treats*, *causes*, *binds*, *upregulates*, *associates*, *interacts*)[cite: 177, 187].

== Het-node2vec: Node and Edge Type-Aware Random Walks

*Het-node2vec* (Valentini et al., *arXiv*, 2021; implemented in the *GRAPE* library, Cappelletti et al., *Nature Computational Science*, 2023) extends node2vec to *heterogeneous multigraphs* $G = (V, E, phi, psi)$, where[cite: 179, 186, 233]:
- $phi: V -> Sigma_V$ maps each node $v in V$ to its *node type* $phi(v) in Sigma_V$[cite: 186].
- $psi: E -> Sigma_E$ maps each edge $e in E$ to its *edge type* $psi(e) in Sigma_E$[cite: 186].

Het-node2vec introduces a 2nd-order random walk that is *node-type and edge-type aware* by adding two new stochastic *switching parameters* on top of $p$ and $q$[cite: 181, 184, 187]:
- *Node-switching parameter $s$* (introduced in *HeNHoE-2vec* — Heterogeneous Nodes, Homogeneous Edges): controls the propensity of the random walk to switch from the current node type $phi(v)$ to a different node type $phi(x) != phi(v)$ (multiplying the transition weight by $1/s$)[cite: 182, 184, 187].
- *Edge-switching parameter $e$* (introduced in *HoNHeE-2vec* — Homogeneous Nodes, Heterogeneous Edges): controls the propensity of the random walk to switch from the previous edge type $psi(r, v)$ to a different edge type $psi(v, x) != psi(r, v)$ (multiplying the transition weight by $1/e$)[cite: 183, 184, 187].

=== The Complete HeNHeE-2vec (Het-node2vec) Transition Rule

Combining both switching mechanisms yields *HeNHeE-2vec* (Heterogeneous Nodes, Heterogeneous Edges)[cite: 184, 186]. Given a walk at node $v$ coming from node $r$, the unnormalized transition probability to move to neighbor $x$ is[cite: 186]:
$
  P(X(t+1) = x | X(t) = v, X(t-1) = r) = pi_(v x) = gamma_(p, q, s, e) (r, v, x) dot w_(v, x)
$
where the bias factor $gamma_(p, q, s, e)$ is defined by checking whether the edge type changes ($psi(r, v) == psi(v, x)$) and whether the node type changes ($phi(x) == phi(v)$), combined with the shortest-path topological distance $d_(r, x) in {0, 1, 2}$[cite: 184, 186]:

1. *Same edge type ($psi(r, v) = psi(v, x)$) and same node type ($phi(x) = phi(v)$)*[cite: 186]:
  $
    gamma = cases(
      1 / p & "if " d_(r, x) = 0,
      1 & "if " d_(r, x) = 1,
      1 / q & "if " d_(r, x) = 2,
    )
  $
2. *Same edge type ($psi(r, v) = psi(v, x)$) and different node type ($phi(x) != phi(v)$)* (penalized by $1/s$)[cite: 182, 186]:
  $
    gamma = cases(
      1 / (p s) & "if " d_(r, x) = 0,
      1 / s & "if " d_(r, x) = 1,
      1 / (q s) & "if " d_(r, x) = 2,
    )
  $
3. *Different edge type ($psi(r, v) != psi(v, x)$) and same node type ($phi(x) = phi(v)$)* (penalized by $1/e$)[cite: 183, 186]:
  $
    gamma = cases(
      1 / (p e) & "if " d_(r, x) = 0,
      1 / e & "if " d_(r, x) = 1,
      1 / (q e) & "if " d_(r, x) = 2,
    )
  $
4. *Different edge type ($psi(r, v) != psi(v, x)$) and different node type ($phi(x) != phi(v)$)* (penalized by $1/(s e)$)[cite: 184, 186]:
  $
    gamma = cases(
      1 / (p s e) & "if " d_(r, x) = 0,
      1 / (s e) & "if " d_(r, x) = 1,
      1 / (q s e) & "if " d_(r, x) = 2,
    )
  $

#note()[
  *Attention Mechanism Interpretation*[cite: 181, 185, 187]:
  Parameters $s$ and $e$ act as a topological *attention mechanism* that concentrates the random walk on specific semantic parts of a heterogeneous biomedical knowledge graph[cite: 181, 185]:
  - *Low values of $s$* ($s < 1 ==> 1/s > 1$) encourage the walker to jump across *different types of nodes* (inter-layer exploration), whereas high values of $s$ keep the walk within a single node type[cite: 185, 187].
  - *Low values of $e$* ($e < 1 ==> 1/e > 1$) encourage the walker to traverse *different types of edges* (multi-relational exploration)[cite: 185, 187].
]
