#import "../template.typ": *

= Ai for patient

We can have some problems:
- Usually the number of patients is very low. The number of example in train are small.

- Also we have high dimensional data, for example gene expression data. This data can be represented as a real vector in a high dimensional space.

- Label are uncertain and limited, they can be noisy. Also this label can be not only a binary healthy/sick label, but also a continuous value, for example the survival time of a patient.

- Interpretation of the results is usually performed by a human expert. But is also important to have a model that is interpretable, so that we can understand why the model made a certain prediction.

Classical ml approaches are inductive, they learn a path through the data and they generate a predection model. But nowadays we can have different and more suitabl approach, that is the transductive approach.

== Network model prespective

We have a *graph* where each nodes represents a patient and the edges represent the similarity between patients. We can try to model a *patient-similarity network*.

#note()[
  Inductive: this algorithms learn a model from the training data and then use this model to make predictions on new data.

  Transductive: they not otuput a model, but they output a prediction for the unlabeled data without produced a specific model.
]

This method are called *transductive learning*, is a semi-supervised learning method, where we have a small set of labeled data and a large set of unlabeled data. The goal is to learn a model that can predict the label of the unlabeled data based on the labeled data. The main advantage is taht is approaches is inherently interpretable, because we can use the visualization of the graph to understand the relationships between patients and how they are related to the labels.

The main network are:
- *PPI*: Protein-Protein Interaction network, where nodes are proteins and edges are interactions between proteins. This network is usually very large and sparse. In this case the notion of similarity fall into the notion of *functional similarity*, where two proteins are similar if they have similar functions.\
The main task its to analyze the desies that are associated with a certain protein. We can also try to predict novel interactions between proteins (new edges), or to predict the function of a protein based on the function of its neighbors.


- *PSN*: Patient Similarity Network, where nodes are patients and edges are similarity between patients. This network is usually small and dense. An example of task are:
  - *Patiant subtype stratification*: we have a group of patients and we want to cluster them into the same disease but with different subtypes.

== Patient similarity network for outcome prediction

In this task we have a set of data. We can have various types of data, for example gene expression data, clinical data, etc. *For each type* of data we can build a graph by measuring a *similarity metric* between patients. For example we can use the Pearson correlation coefficient to measure the similarity between gene expression profiles of patients. We can also use other similarity metrics, such as the Jaccard index or the cosine similarity.

Then we *integrate* the different graphs into a single graph, this is usefull because we can have different types of data that can provide complementary information about the patients.

After that we can use different machine learning algorithms to predict the outcome of patients based on the integrated graph. For example we can use graph convolutional networks (GCNs) or graph attention networks (GATs) to learn a representation of the patients in the graph and then use this representation to predict the outcome. Another possible task is to cluster patients into subtypes based on the integrated graph.

=== P-Net algorithm

This algorithm is based on a PSM network. This consist:
- *Patient structure*: Each patient is caracterized by a set of features, for example gene expression data, clinical data, etc. We can represent each patient as a vector in a high dimensional space. We can construct a *patient matrix*, where each row represents a patient and each column represents a feature.

- *Similarity matrix*: it's a square matrix, where each entry correponds to the similarity between two patients.

  //riguardare come centrano i kernell
  #note()[
    *Kernel* represent a measure of similarity between two objects. There are linear kernel like dot product, polynomial kernel, etc.
  ]

The main idea is to introduce a *kernel* to measure the similarity between patients. after the kernelization we apply a *score function*, it represent a local learning strategy. The score of a node $v$ is computed based on the scores of its neighbors. The score function can be defined in different ways:
- Avarage score: we consider the avarage score of the neighborood node that are labaled with the same label of the node $v$:
$
  S_"AV" (v, V_C) = 1 / (|V_C|) sum_(x in V_C) k(v,x)
$

//aggiungere disegno con nodi colorati

#warning()[
  By creating a kernel version of the graph we enrich the definition of similarity but we also introduce noise.
]



#example[
  Random walk algorithm visited the graph in a random way (the path between nodes is random). Using this approach we can compute some task, like predicting the label of a patient.

  We can have a kernelize version of the random walk algorithm. Where:
  - $W$: is the similarity between different patients.
  - $D$: Is derived from W by summing the weight that conects a node $i$ to all the other nodes, it is a diagonal matrix. //aggiungere disegno

  $hat(L)$ it's a normalized version of the Laplacian matrix, where $hat(L) = D^(-1/2)L D^(-1/2)$.

  The final expression is:
  $
    (alpha-1)I + D^(-1/2) W D^(-1/2)
  $
  if $alpha$ has a value between 0 and 1, if is a high valule we ....

  Consider now that we have a graph and a similarity mehtod:
  - the white edges are patients that have similar features.
  - the grey one are patients whit different or unabaled features.

  When we apply a kernel we obtain an erreach graph. The red edges are the edges obtained by using random walk kernel. This algorithm create a direct edge between patients that are not directly connected but are connected through other patients. Random walk kernell *enreach the definition of similarity*.

  After this operation we can apply a filter to remove the edges that have a weights below a certain threshold. this can remove noise connection.

  Then we apply a score function to predict the label of a patient. The score function is based on the labels of the neighbors of a patient. We can use different score functions, for example we can use the average label of the neighbors, or we can use a weighted average where the weights are based on the similarity between patients.
]

== Graph representation learning of patient similarity networks

The main idea is to create a embedded vector. We not use directly the graph as previously, but we use a representation of the graph in a low dimensional space.

There are two main approaches to learn a representation of the graph:
- *Random walk based methods*: First we generate the graph embedding by performing random walks on the graph. Hten we cluster the embedded vectors to obtain a representation of the graph. The main idea is that nodes that are close to each other in the graph will have similar embedded vectors.

- *Graph neural networks (GNNs)*: //riguardare

//aggiungere disegno

=== Random walk based methods

If we have a network data we can extract node feature directly from the graph structure. We not need to do a feature engineering.

For each node we extract a feature by exploring the graph structure. We want to create a function:
$
  f: u -> R^d
$
where this vector is a low dimensional representation of the node $u$. This is called *node embedding*. A good node embedding should preserve the graph structure, so that nodes that are close to each other in the graph will have similar embedded vectors.

#warning()[
  Graph are not *Euclidian*. Node numbering is arbitrary. The main problem is find a way to convert them.
]

To get a good graph representation we can:
- *Linearize* the graph: We create a sentence for each node using random walks.

- *Use graph neural networks* to learn a representation of the graph. We can use different types of GNNs, such as Graph Convolutional Networks (GCNs), Graph Attention Networks (GATs), etc.

== Node2vec Unsupervised graph representation learning

=== Word2Vec

Word2Vec is a way to get embedding from text. Text is seen as a sequence of words. Each word is associated with a vector representation of it.

Word that have a similar surrounding will have similar vector representation. This assumption is based on the *distributional hypothesis*, which states that words that occur in similar contexts tend to have similar meanings.

We can train a neural network by using pairs of close words. The neural network will learn to predict the surrounding words given a word. After training we can use the weights of the neural network as the vector representation of the words.

Approaches to learn word embeddings include:
- Words are represented in a *one hot encoding* way. A one in a specific position of the vector represent the presence of a word in the vocabulary (size $R^n times 1$). We create a matric of learnable weights, where each row represent a word in the vocabulary and each column represent a dimension of the embedding space $W in R^(n times p)$

- by using a neural network wiht a single hidden later with $p = 300$ neural units we can learn a vector representation of the words. The logits (raw predictions) of the neural network are then multiplied by a output matrix $U in (p times n)$

- The output of the neurla network is a probability distribution over the vocabulary. The neural network will learn to predict the surrounding words given a word.

//aggiungere imamgine

#warning()[
  The main isseu is that even if the word has a linear structure this is not the case for graphs. Graph are not linear, they are not Euclidian. The main problem is find a way to convert them.
]

=== from text to graph

We could consider the surrounding words of a word as the *neighbors* of a node in a graph. We can define the neighborhood in different ways:
- Neighborhood based on the graph structure: we can consider the neighbors of a node as the nodes that are directly connected or node that are connected through a path of length $k$.

- Neighborhood base in the random walk: we can perform a random walk of $k$ step on the graph, and consider the nodes that are visited during the random walk as the neighbors of a node.

  //aggiungere disegno
  #example()[
    if we start from node 10 we can consider a 2 step random walk. The possible path can be:
    - 10 -> 15 -> 16
    - 10 -> 11 -> 5
    - 10 -> 9 -> 8
  ]

  #note()[
    In this way we *linearize the graph*, we obtain a sequence of nodes that can be used to train a neural network. In this sense we are now in the same  situation of the word2vec algorithm.
  ]
  After we have this sequence of nodes we can use the same approach of word2vec:
  - Represent this sequence of nodes as a one hot encoding vector.
  - Create a neural network with a single hidden layer with $p$ neural units by using a skip-gram approach. The neural network will learn to predict the surrounding nodes given a node. After training we can use the weights of the neural network as the vector representation of the nodes.


=== Node2Vec

Input:
- $G = (V,E)$

We want to learn a function $f:u-> R^d$ were $f$ is a lookup table that maps each node to a vector in a low dimensional space. We want to learn a representation of the graph that preserves the graph structure.

We want to maximaxe a probability of observing a node $u$ given its neighborhood $N_S(u)$ across all nodes in the graph:
$
  max f sum_(u in V) log Pr(N_S(u)|f(u))
$
we are maximizing the *likelihood* of observing the neighborhood of a node given its vector representation. If we expand the formula we have:
$
  max f Pr(N_S(u)|f(u)) & = product_(n_i in N_S(u)) Pr(n_i|f(u)) \
                        & "since" log "is a monotonic function" \
                        & max f log(product_(n_i in N_S(u)) Pr(n_i|f(u))) \
                        & max f sum_(n_i in N_S(u)) log Pr(n_i|f(u))
$

#note()[
  We are assuming that nodes in the neighborhood are *conditionally independent* given the vector representation of the node. This is a strong assumption, but it allows us to simplify the problem and make it tractable:
  $
    Pr(N_S(u)|f(u)) = product_(n_i in N_S(u)) Pr(n_i|f(u))
  $
  we are stating that if we know the vector representation of a node $u$, then the probability of observing a node in its neighborhood is independent of the other nodes in the neighborhood.

  we also make the assumption that there is a simmetry between future space and node space, in this wat the softmax function can be used to compute the probability of observing a node given its vector representation:
  $
    Pr(n_i|f(u)) = exp(f(n_i) dot f(u)) / sum_(v in V) exp(f(v) dot f(u))
  $
]
//aggiungere formula finale

$
  max f sum_(u in V) [ - log Z_u + sum_(n_i in N_S(u)) f(n_i) dot f(u) ]
$
- By naximing $f$ we want to maximize the similarity between a node $u$ ande the vector representation of its neighbors

- $log Z_u$  is a sum of the similarity between a node $u$ and all the other nodes in the graph. We want to minimize this term, because we want to maximize the similarity between a node and its neighbors, and minimize the similarity between a node and all the other nodes in the graph.

=== How to determine the neighborhood of a node

A first strategy is to use a simple (first order) random walk

//aggiungere algoritmo
If $gamma$ is too low, we will explore only a random walk for each vertex, so this is not rapresentative of the graph structure. We need a higher value of $gamma$ to explore the graph structure by multiple random walks.

=== Node2Vec: biased random walk

This is a evolution of the previous algorithm. Because it is able to determinad the neighborhood of a node in a more flexible way. It use a second order random walk, by exploring a BFS and a DFS strategy:
- BFS: we explore the graph by levels, we explore the neighbors of a node before exploring the neighbors of the neighbors. This is useful to capture the local structure of the graph.

- DFS: we explore the graph by depth. Is useful to have a macroscopic view of the graph structure (more global view).

we have a *biased random walk*: given a node $u$ its generate a random walk by using two parameters $p$ and $q$:
- $p$: return parameter, it controls the likelihood of immediately revisiting a node in the walk.

- $q$: in-out parameter, it allows the search to differentiate between inward and outward nodes. If $q > 1$ the random walk is biased towards nodes close to $u$, if $q < 1$ the random walk is biased towards nodes further away from $u$.

//aggiungere immagine di visita

This parameters control the transition probabilities of the random walk. We can tune to mimic a BFS or a DFS strategy:
- if we want to mimic a BFS strategy we set $p$ low and $q$ high (inverse because we use $1/p$, $1/q$), so that the random walk will explore the neighbors of a node before exploring the neighbors of the neighbors.

- if we want to mimic a DFS strategy we set $p$ high and $q$ low, so that the random walk will explore the neighbors of the neighbors before exploring the neighbors of a node.
