#import "../template.typ": *

= Counterfactual Explanations

== Brief recap

== Patient Similarity Networks (PSN)

Patient Similarity Networks are graphs in which each node represents a patient and each edge indicates the similarity between two patients. The definition of similarity may vary.

SNF is an algorithm that integrates multiple PSNs (different views of the same data) into a single graph. In this way, we can integrate more data and therefore use more information.

With real clinical data, missing values are very common. An extension of SNF called SNF-IM can also handle missing data.

== SNF (Similarity Network Fusion)

We start with different views. For example, one view may be a matrix whose rows are patients and whose columns are genes.

The procedure is as follows:
- We create a similarity matrix for each view.

- From each similarity matrix, we create a graph whose nodes are patients and whose edges represent the similarity between patients.

- By exploiting the similarities between the different graphs, we create a single graph that represents all the views.

This is important because it allows us to work with an arbitrary number of views. The final graph is useful because it takes into account all the information from the individual views.

=== Miss-SNF

This method is designed for missing data.

The most commonly used approach is Miss-SNF equality: for half of the patients, a patient is considered identical to itself, while for the other half it is considered identical to all the other patients. Thanks to SNF's propagation mechanism, the similarity of a patient with missing data is estimated from information obtained from the other patients.

= Explainable AI

#warning()[
  A neural network is a black-box model. In a real clinical setting, the explainability of the model is very important.
]

*Explainable AI* (XAI) is a research field concerned with making models interpretable. This is useful because it provides a patient with not only the raw prediction but also the reason behind it.

There are two kinds of explainability methods:
- *Intrinsic methods*: Explanations are part of the model. For example, if we use an attention mechanism, we can see which parts of the input are more important for the prediction. This is a very good approach, but it is not always possible to use.

- *Post-hoc methods*: Explanations are generated after the model has been trained. For example, we can use SHAP or LIME to understand which parts of the input are more important for the prediction. This is a very good approach, but it is not always possible to use.

There are also two scopes of explainability:
- Instance level: for a particular patient, we can understand why the model made a particular prediction. This is very important in a clinical context.

- Model level: we can understand how the model works in general. This is very important for determining whether the model is biased.

== GNN XAI Taxonomy

We focus on the explainability of Graph Neural Networks (GNNs). The main categories are:
- Generation-based methods: These methods create artificial graphs that are similar to the original graph and observe how the model behaves on them. This is a very good approach, but it is not always possible to use.

- Surrogate-based methods: These methods create a simpler model that approximates the original model, such as a linear model, and observe how it behaves in a particular graph neighborhood (for example, around a specific patient).

- Decomposition-based methods: These methods decompose the model into smaller parts and determine how each part contributes to the final prediction. This is a very good approach, but it is not always possible to use.

- Gradient-based methods: These methods use the model's gradient to understand which parts of the input are more important for the prediction.

- Perturbation-based methods: These methods perturb the input and observe how the model behaves on the perturbed input. We then compare this behavior with the behavior on the original input to determine which parts of the input are more important for the prediction.

== Counterfactual Explanations

Counterfactual explanations answer *what-if questions*. They find the *minimum change* to the input that would change the prediction. This is very important in a clinical context because it can help doctors understand the minimum change that could be made to a patient to change the prediction.

These are new and very promising methods. They are useful for:
- Instance-level personalized explanations: identifying disease drivers for a specific patient.
- Actionability: a doctor can suggest a treatment that could change the prediction, such as surgery or a drug.

We have different methods for generating counterfactual explanations:
- Search-based methods: These methods find an existing example that is similar to the input but has a different prediction. This is a good approach, but it is not always possible to find a similar example.

- Heuristic-based methods: These methods modify the input graph.

- Learning-based methods: These methods train a model or optimize parameters to generate counterfactual examples. We can use an agent that learns which feature of a patient needs to be changed in order to maximize the reward function.

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
