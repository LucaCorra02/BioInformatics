#import "../template.typ": *

// lezione con Phd lab

Con i grafi possiamo trattare oltre che i dati anche le loro relazioni, per questo è cosi importante in bioinformatica.

== PSN

Sono dei grafi in cui un nodo è un paziente e gli archi indica la similarità tra questi pazienti. La definizione di similarità può essere variabile.

SNF: si tratta di un algoritmo che permette di integrare più PSN (viste diverse degli stessi dati) in un unico grafo. In questo modo possiamo integrare più dati e quindi più informazioni.

Con i dati clinici reali capita molto spesso che ci siano dei dati mancanti. Esiste un estensione di SNF chiamata SNF-IM che permette di gestire anche i dati mancanti.

== SNF (Similarity Network Fusion)

Partiamo da viste diverse. Ad esempio una matrice su cui le righe sono i pazienti e le colonne sono i geni.

Funzionamento:
- Creiamo delle matrice di similarità per ogni vista.

- Da questa matrice andiamo a creare un grafo in cui i nodi sono i pazienti e gli archi rappresentano la similarità tra questi pazienti.

- Sfruttanto le similirità tra i vari grafi andiamo a creare un grafo unico che rappresenta tutte le viste.

Molto importante perchè ci permette di lavorare con un numero di arbitrario di viste. Il grafo finale è utile, in quanto tiene conto di tutte le informazioni delle singole viste.

=== Miss-SNF

//riguardare
Per dati mancanti.

Modalità più usata è miss-SNF equality: per metà un paziente è uguale a se stesso e per l'altra metà uguale a tutti gli altri. Grazie al meccanismo di propagazione di SNF la similirità di un paziente con dati mancanti viene stimata in base alle informazioni provenienti dagli altri pazienti.

= Explainable AI

#warning()[
  Una rete neurale è un modello black box. In un contesto reale clinico è molto importante l'explainability del modello.
]

*Explainable AI* (XAI) è un campo di ricerca che si occupa di rendere i modelli interpretabili. This is usefull to give a patiant not only the raw prediction but also the reason behind it.

There are two kind of explainability:
- *Intrisic Methods*. Explenations are part of the model. For example if we have an attention mechanism we can see which part of the input is more important for the prediction. This is a very good approach but it is not always possible to use it.

- *Post-hoc Methods*: Explenations are generated after the model has been trained. For example we can use SHAP or LIME to understand which part of the input is more important for the prediction. This is a very good approach but it is not always possible to use it.


There are also two scope of explainability:
- Instance level: for a particolar patient we can understand why the model made a particular prediction. This is very important in a clinical context.

- Model level: we can understand how the model works in general. This is very important to understand if the model is biased or not.

== GNN XAI Taxonomy

We will focus on the explainability of Graph Neural Networks (GNNs). We have:
- Generation-based methods: Creates artificial graphs that are similar to the original graph and see how the model behaves on them. This is a very good approach but it is not always possible to use it.

- Surrogate-based methods: Creates a simpler model that approximates the original model (like a linear model) and see how the model behaves on a particular neighborhood of the graph (a specific patient)

- Decomposition-based methods: Decomposes the model into smaller parts and see how each part contributes to the final prediction. This is a very good approach but it is not always possible to use it.

- Gradient-based methods: Uses the gradient of the model to understand which part of the input is more important for the prediction.

- Perturbation-based methods: Perturbs the input and see how the model behaves on the perturbed input. After that we observed how the model behaves on the original input and we can understand which part of the input is more important for the prediction.

== Conterfactual Explanations

It answet to* what-if questions*. It finds the *minumum change* to the input that would change the prediction. This is very important in a clinical context because it can help the doctor to understand what is the minimum change that can be done to the patient to change the prediction.

They are new method and very promising. They usefull for:
- Instance level personalized explanations: identify disease drivers for a specific patient.
- Acionability: the doctro can suggest a treatment to the patient that can change the prediction. For example a surgery or a drug.

//riguardare
We have different methods to generate counterfactual explanations:
- Search-based methods: Find an exesting example that is similar to the input and has a different prediction. This is very good but it is not always possible to find a similar example.

- Heuristic-based methods: Modifies the input graph

- Learning-based methods: Train a model or optimize parameters to generate counterfactual examples. We can use an agent that learns the feature that we need to change in a patient to maximaze the reward function

== CE-GNN

New methods for do the counterfactual explanations on GNNs. The task is a node classification task on a biomedical graph.

Input-data are multi-omics data and a specific patient that we want to explain.

Then:
- We use mis-SNF to integrate the multi-omics data and create a PSN graph. The nodes are the patients and the edges are the similarity between the patients.

- We use a GNN encoder to create an embedding patient. The embedding space is constucted by using a contrastive loss function. The main idea is that patients with the same disease should be close in the embedding space and patients with different diseases should be far away in the embedding space. We push away patients with different class up to a specific margin

- After that we use a cosine similarity in the embedding space to find the most similar patients to the patient that we want to explain.

- We contrefactual feature ranking:
  - Absolute difference
  - Statstical significance
  -

  We obtain a rank of the feature of the conterfactual patients that are more important for the prediction of the patient that we want to explain.

- After every feature ranked update we use a GNN classifier to predict the class of the patient that we want to explain. We stop when the prediction changes. In this way we can find the minimum change that we need to do to the patient to change the prediction.

The idea is to work on a particular set of feature to improve the clinal situation of the patient.

=== Dataset

The dataset is syntetich and have no ground truth. Also the ROSMAP dataset is used, this is a real dataset base un alzheimer disease.

For the metrics used we have:
- Ground thrut: lilke precision, recall, F1-score, accuracy, AUC-ROC, AUC-PR. These metrics are used to evaluate the performance of the model.

- Qualityof generated counterfactuals: like validity, proximity, sparsity, diversity. Where:
- Validity:
$
  ("Number of successful prediction flips" / "total number of counterfactuals generated") * 100
$
- Fidelty: if we have 1 the GNN have corectly predicted the patient and we have a label flipped with the contrefactual explanation:
$
  1 / |X| sum_(x in X) (1[theta(x) = y_x])
$
//riguardare

The model reach the goal of generating a contrafactual explanation for most of the patients (validity: 91%), that can be improve and not good. But the sparsity is very good (85.92) beacause we don't need to change half of the features to change the prediction. This is good from a clinical point of view because we can suggest to the doctor to change only a few features of the patient to change the prediction.

=== Increasing the feature

Test on MLOmics dataset. The contrefactual explanation is generated for most of the patients. Also the sparsity is very good.

The box plot shows the feature that we need to modify to get a valid counterfactual explanation. Our model have a small bottom blolx plot, in most of the cases we need to change only a few features to get a valid counterfactual explanation. But in some cases we need to change a lot of features to get a valid counterfactual explanation (this is shown by a tail on the top of the box plot).

=== Limitations

- We don't have a perfect validity. For same patient even if we change all the features we don't get a valid counterfactual explanation.

- We will need to update the graph every feature ranking. Now the graph is fixed.

- Choose the important feature not in a eurytstich way but using an agent with a reward function that is able to explore the feature space and find the best feature to change to get a valid counterfactual explanation.

