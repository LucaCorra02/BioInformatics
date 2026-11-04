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

The main exsisting methods for expleaining GNNs are feature attribution methods. They try to explain wich features contribute the most to a specific prediction. They fail to explicitly guide clinicians
on *how to achieve a different clinical outcome*, e.g. by identifying which factors may be responsible for changing an unfavorable prognosis into a favorable one.

Existing counterfactual GNN methods primarily focus on graph classification tasks. To our knowledge, no explainable methods have been explicitly designed to generate counterfactuals for vertex classification in PSNs; the exact task required for personalized diagnosis and outcome prediction.

In this work, we propose a Counterfactual Explanation Graph Neural Network (*CE-GNN*) framework explicitly designed for PSNs wich is able to integrating multi-omics data.

=== Pipeline

==== Miss-SNF + GNN

We use Miss-SNF to integrate the multi-omics data and create a single PSN graph. The final network $G$ is an integrated graph that synthesizes information from multiple omics data types.

The output is a graph $G = (V, E)$ where $V$ is the set of patients and $E$ is the set of edges representing bio-molecular similarities. We define a *labeling function* $phi: V -> {C_1, C_2, dots, C_m}$ to assing each patient to a specific disease class $m$. Usually $m=2$ for binary classification tasks, where $C_1$ and $C_2$ represent two opposite disease classes (e.g., healthy vs. diseased).

We use a *Siamese GNN* to create a patient embedding (initialy each patient has their features vector as embedding). The embedding space is constructed using a *contrastive loss function*:
$
  L(H) = Y_(i j) ||h_i - h_j||^2 + (1 - Y_(i j)) max(0, m - ||h_i - h_j||^2_2)
$
where:
- $h_i$ and $h_j$ are the *embeddings* of patients $v_i$ and $v_j$. They correspond to rows within the hidden representation matrix $H in R^(n times d)$.
- $Y_(i j)$ is a *binary indicator*: $Y_(i j) = 1$ if patients $v_i$ and $v_j$ belong to the same disease class ($phi(v_i) = phi(v_j)$), and $Y_(i j) = 0$ otherwise.

- $m$ represents a *margin* ensuring that dissimilar patient pairs $(h_i, h_j)$ that are separated by a Euclidean distance *greater than $m$* do not incur a loss penalty

#informally()[
  This loss forces the GNN to learn an embedding space where patients sharing the same clinical diagnosis or outcome are clustered closely together, while patients with differing outcomes are pushed apart.
]

=== Ranking

For each query node $v_i$ with hidden representation $h_i$, we retrieve a *counterfactual example, $v_(c i)$*, by selecting the *most
similar node* $v_j$ whose predicted class differs from that of $v_i$ ($phi(v_j) != phi(v_i)$). Similarity is measured using cosine similarity in the embedding space:
$
  v_(c i) = "argmax"_(v_j: phi(v_j) != phi_(v_i)) (h_i^t h_j) / (||h_i|| dot ||h_j||)
$
counterfactual hidden representation is $h_(c i)$. Where $f^(c i)$ denotes the feature vector associated with the counterfactual node $v_(c i)$ and $f^(i)$ denotes the feature vector associated with the original node $v_i$.

=== Counterfactual Generation

We define an *explanation as a minimal, interpretable set of feature-level edits* required to conceptually transform patient $v_i$
into $v_(c i)$, thereby *changing the model’s prediction*. This edit represent plausible interventions that could be applied to the patient to achieve a different clinical outcome.

Given the feature vectors $f^i = [f^i_1, dots, f^i_p] in R^p$ and $f^(c i) = [f^(c i)_1, dots, f^(c i)_p] in R^p$ the idea is to progressively modify the features of $f^i$ to match those of $f^(c i)$, untill the model prediction changes.

To achieve this, we apply the following steps:
1. *Feature norm*: To ensure a fair comparison of magnitudes across
different biological or clinical modalities, all features are first standardized (e.g., via z-score or softmax normalization).

2. *Feature ranking*: We rank the features based on we rank them based on their likelihood to drive a change in prediction.
  - *Absolute difference*: $|f^i - f^(c i)|$ between the target patient and their counterfactual, assuming the largest raw differences are the primary drivers.
  - *Statistical Significance*: Data-driven approach computing the ANOVA F-values to assess the correlation and importance of each individual feature against the clinical outcome
  - *Model-based importance*: A predictive approach that extracts intrinsic feature importance scores directly from an auxiliary trained Random Forest classifier to guide the substitution order based on learned predictive power.

3. *Iterative feature substitution*: Following the ranked order computed in the previous step, we *cumulatively* assign one by one the specific feature values of the counterfactual patient $v_(c i)$ to the feature vector of the target patient $v_i$.

4. After every individual feature swap, the modified feature vector is evaluated by the trained GNN. The iterative loop breaks when the GNN predicts a new class label. The precise subset of features responsible for inducing this label switch is recorded as the counterfactual explanation $s_i$

== Dataset

Because real-world clinical datasets lack a definitive ground truth for feature-level explanations, it is difficult to objectively evaluate explanation accuracy. Therefore, to validate whether the CE-GNN can successfully identify and extract significant counterfactual features, we apply our algorithm to *synthetic data* where the ground-truth features are known by design.

Examples belonging to two classes with a *pre-defined subset of discriminative features*. The synthetic dataset comprises $n = 300$ samples belonging to two distinct classes $C in {0, 1}$ and $p = 150$ features, partitioned into three distinct views to simulate the heterogeneity of multi-omics data sources used in PSN construction.Features of Class $0$ examples are distributed according to a 0-centered normal distribution $N (0, sigma)$ having different standard deviations $sigma$.

*ROSMAP* dataset. To evaluate the framework in a real-world clinical
context, we utilize a multi-omics Alzheimer’s disease dataset. The cohort comprises $351$ patients ($182$ individuals diagnosed with Alzheimer’s, $169$ controls). The dataset encompasses three distinct biological modalities: mRNA expression, miRNA expression, and DNA methylation data.

=== Metrics

We assess the performance of the explanation methods across two primary dimensions:
- Their ability to accurately identify the underlying drivers of a prediction
- Structural quality of the generated counterfactuals.

We compare the predicted subset of important features to the groundtruth important features. Since ground-truth features are known by design only for the synthetic dataset, this evaluation is restricted to the synthetic experiments. We frame this as a binary classification task, where a feature is either correctly or incorrectly identified as important, and utilize Precision, Recall,
Accuracy, and Macro-F1 metrics.

For the second dimension we measure Fidelity, Validity, Sparsity:
- *Validity*: Assesses the proportion of generated counterfactuals that successfully alter the initial prediction:
  $
    ("Number of successful prediction flips" / "total number of counterfactuals generated") * 100
  $
- *Fidelity*: measures how faithful the explanations are to the oracle considering their correctness:
  $
    1 / (|X|) sum_(x in X) (1[Phi(x) = y_x]- 1[Phi(x^') = y_(x)])
  $
  Where $1[Phi(x) = y_x]$ is equal to 1 if the classifier’s predicted class for the original sample $x$ is its true label $y_x$, and $1[Phi(x^′) = y_x]$ is equal to 1 if the classifier’s predicted class for the generated counterfactual $x^'$ is the label $y_x$. It ranges from $-1$ to $1$


- *Sparsity*: measures the conciseness of the explanation by quantifying the relative reduction in feature space:
  $
    1 / (|X|) sum_(x in X) (1 - "Number of important features" / "Total number of features")
  $

The model achieves the goal of generating a counterfactual explanation for most patients (validity: $91%$). This result can be improved, but the *sparsity is already very good* ($85.92$), because we do not need to change half of the features to change the prediction. This is beneficial from a clinical point of view because we can suggest that the doctor change only a few features of the patient to change the prediction.

Our model has a small bottom box-plot range: in most cases, we need to change only a few features to obtain a valid counterfactual explanation. However, in some cases, we need to change many features to obtain a valid counterfactual explanation.

=== Limitations

- We do not have perfect validity. For some patients, even if we change all the features, we cannot obtain a valid counterfactual explanation.

- We need to update the graph after each feature-ranking step. Currently, the graph is fixed.

- Instead of choosing the important feature heuristically, we could use an agent with a reward function capable of exploring the feature space and finding the best feature to change in order to obtain a valid counterfactual explanation.

#note()[
  Code is available at: https://github.com/haricalzi/PhD-Lectures/tree/main/Bioinformatics
]
