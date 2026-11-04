#import "../template.typ": *

= Counterfactual Explanations

== Brief recap

=== Patient Similarity Networks (PSN)

Patient Similarity Networks are graphs in which each *node* represents a *patient* and each *edge* indicates the *similarity between two patients*. The definition of similarity may vary.

Usually we can have different views of the same data. We may have different PSNs that represent different views of the same data. For example, we may have a PSN that represents the similarity between patients based on their gene expression data, and another PSN that represents the similarity between patients based on their clinical data.

*SNF* (Similarity Network Fusion) is an algorithm that integrates multiple PSNs (different views of the same data) into a single graph (see past lectures for more details).
SNF-IM can also handle missing data.

=== Similarity Network Fusion (SNF)

*Similarity Network Fusion (SNF)* integrates heterogeneous omics data (e.g., mRNA expression, DNA methylation) in the space of samples (patients) rather than measurements. Instead of directly concatenating feature matrices, it *builds an individual Patient Similarity Network (PSN)* for each data type and iteratively fuses them.

Procedurally:
1. Initial *Similarity Matrices* ($W$): For each data view, the pairwise similarity between patients $x_i$ and $x_j$ is computed using a scaled exponential Euclidean kernel:
$
  W(i, j) = exp(- (rho(x_i, x_j)^2) / (mu epsilon_(i j)))
$
where $rho(x_i, x_j)$ is the Euclidean distance, $mu$ is a hyperparameter, and $epsilon_(i j)$ adapts the kernel to the local neighborhood density to eliminate scaling issues.

2. *Global* ($P$) and *Local* ($S$) Matrices: From $W$, SNF isolates global topology and local neighborhoods into two normalized matrices:
  1. *Global Matrix ($P$)*: encodes all pairwise similarities, normalized to sum to 1 per row (with self-similarities $P(i,i) = 1/2$ to avoid self-domination and numerical instability).
  2. *Sparse Local Matrix ($S$)*: encodes similarities *only* for the $K$-nearest neighbors ($N_i$), setting all other edges to $0$. This enforces the assumption that strong local similarities are far more reliable than remote ones.

3. *Iterative Cross-Diffusion* (Message Passing): Assuming two views (e.g., View 1 and View 2), SNF iteratively updates the global matrix of one view by diffusing information through the local structures of the other:
$
  P_(t+1)^((1)) & = S^((1)) times P_t^((2)) times (S^((1)))^T \
  P_(t+1)^((2)) & = S^((2)) times P_t^((1)) times (S^((2)))^T
$
#note()[
  Similarity information is propagated exclusively through common neighborhoods. If patients $i$ and $j$ share close friends (neighbors) in View 1, and those friends are highly similar in View 2, the overall similarity between $i$ and $j$ is heavily reinforced.
]

4. Final *Fused Network*: After $t$ iterations, the parallel diffusion processes converge, and the overall status matrix is computed as the average of the updated networks: $P^((c)) = (P_t^((1)) + P_t^((2))) / 2$. The resulting fused network organically drops unsupported weak edges (reducing noise) while capturing both shared and complementary similarities across all data types.

=== Miss-SNF

It enables Similarity Network Fusion (SNF) to handle missing data. It is based on the assumption that patients with similar profiles in one view are likely to be similar in other views as well. This allows for the imputation of missing similarities by leveraging information from other patients. We can have different strategies:
- *miss-SNF one*: On missing data, Self-loop similarity is set to 1, 0 for all the other. Missing similarities are imputed by averaging the similarities of the $K$-nearest neighbors in the other views.

- *miss-SNF equidistant*: small equal similarities are assigned to all the othert patients. For half of the patients, a patient is considered identical to itself, while for the other half it is considered identical to all the other patients.

== Explainable AI

#warning()[
  A neural network is a *black-box model*. In a real clinical setting, the explainability of the model is very important, the medical doctor can't rely only on the prediction of the model, but he needs to understand why the model made that prediction.
]

*Explainable AI* (XAI) is a research field concerned with making models interpretable. This is useful because it provides to a patient not only the raw prediction but also the reason behind it.

There are two kinds of explainability methods:
- *Intrinsic methods*: Explanations are part of the model. For example, if we use an *attention mechanism*, we can see which parts of the input are more important for the prediction. This is a very good approach, but it is not always possible to use.
- *Post-hoc methods*: Explanations are generated *after the model has been trained*. For example, we can use SHAP or LIME to understand which parts of the input are more important for the prediction. This is a very good approach, but it is not always possible to use.

There are also two *scopes* of explainability:
- *Instance level*: for a particular patient, we can understand why the model made a particular prediction. This is very important in a clinical context.
- *Model level*: we can understand how the model works in general. This is very important for determining whether the model is biased and understand the overall decision-making process of the model.

=== GNN XAI Taxonomy

We focus on the explainability of Graph Neural Networks (GNNs). The main categories are:
- *Generation-based methods*: These methods create *artificial graphs* that are similar to the original graph and observe how the model behaves on them.

- *Surrogate-based methods*: These methods create a simpler model that approximates the original model, such as a linear model, and observe how it behaves in a particular graph neighborhood (for example, around a specific patient).

- *Decomposition-based* methods: Propagates the final score backward layerby-layer to split the prediction score across input nodes and edges

- *Gradient-based methods*: These methods use the model's gradient to understand which parts of the input are more important for the prediction.

- *Perturbation-based methods*: Masks or removes parts of the input graph to observe how much the final prediction changes. In this category we found the *counterfactual explanations* methods, which are very promising and useful in a clinical context.

== Counterfactual Explanations

Counterfactual explanations answer *what-if questions*: They find the *minimum change* to the input that would change the prediction. This is very important in a clinical context because it can help doctors understand the minimum change that could be made to a patient to change the prediction. For example: _if your BMI were lower than 29, your predicted outcome would be survived instead of deceased_

These are new and very promising methods. They are useful for:
- Instance-level personalized explanations: identifying disease drivers for a specific patient.
- Actionability: a doctor can suggest a treatment that could change the prediction, such as surgery or a drug.

We have different methods for generating counterfactual explanations:
- *Search-based methods*: These methods find an existing example (is in the dataset) that is similar to the input but has a different prediction. This is a good approach, but it is not always possible to find a similar example.

- *Heuristic-based methods*: Modifies the input graph step-by-step using predefined rules until the model prediction changes.

- *Learning-based methods*: These methods train a model or optimize parameters to generate counterfactual examples. We can use an agent that learns which feature of a patient needs to be changed in order to maximize the reward function (RL approach).

Currently there are no methods that can generate counterfactual explanations multiomics PSNs data.

== CE-GNN

These are new methods for generating counterfactual explanations on GNNs. The task is node classification on a biomedical graph.

The input data consist of multi-omics data and a specific patient that we want to explain.

The procedure is as follows:
- We use Miss-SNF to integrate the multi-omics data and create a PSN graph. The nodes are patients, and the edges represent the similarity between patients.

- We use a GNN encoder to create a patient embedding. The embedding space is constructed using a contrastive loss function. The main idea is that patients with the same disease should be close to one another in the embedding space, while patients with different diseases should be far apart. We push patients from different classes apart up to a specific margin.

- We then use cosine similarity in the embedding space to find the patients most similar to the patient that we want to explain.

- We perform counterfactual feature ranking:
  - Absolute difference
  - Statistical significance
  -

  We obtain a ranking of the features of the counterfactual patients that are most important for the prediction of the patient that we want to explain.

- After each feature-ranking update, we use a GNN classifier to predict the class of the patient that we want to explain. We stop when the prediction changes. In this way, we can find the minimum change needed to change the patient's prediction.

The idea is to work on a particular set of features to improve the patient's clinical situation.

=== Dataset

The dataset is synthetic and has no ground truth. The ROSMAP dataset is also used; it is a real dataset based on Alzheimer's disease.

The metrics used are:
- Ground truth metrics, such as precision, recall, F1-score, accuracy, AUC-ROC, and AUC-PR. These metrics are used to evaluate the performance of the model.

- Quality of the generated counterfactuals, including validity, proximity, sparsity, and diversity.

Validity:
$
  ("Number of successful prediction flips" / "total number of counterfactuals generated") * 100
$

Fidelity: if the GNN has correctly predicted the patient and the label is flipped by the counterfactual explanation:
$
  1 / |X| sum_(x in X) (1[theta(x) = y_x])
$

The model achieves the goal of generating a counterfactual explanation for most patients (validity: 91%). This result can be improved, but the sparsity is already very good (85.92), because we do not need to change half of the features to change the prediction. This is beneficial from a clinical point of view because we can suggest that the doctor change only a few features of the patient to change the prediction.

=== Increasing the feature

The method was tested on the MLOmics dataset. A counterfactual explanation is generated for most patients, and the sparsity is also very good.

The box plot shows the features that need to be modified to obtain a valid counterfactual explanation. Our model has a small bottom box-plot range: in most cases, we need to change only a few features to obtain a valid counterfactual explanation. However, in some cases, we need to change many features to obtain a valid counterfactual explanation.

=== Limitations

- We do not have perfect validity. For some patients, even if we change all the features, we cannot obtain a valid counterfactual explanation.

- We need to update the graph after each feature-ranking step. Currently, the graph is fixed.

- Instead of choosing the important feature heuristically, we could use an agent with a reward function capable of exploring the feature space and finding the best feature to change in order to obtain a valid counterfactual explanation.
