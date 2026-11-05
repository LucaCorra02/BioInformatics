#import "../template.typ": *

= Transformers pt 2

Only the last encoder blocked is connected to the decder, in a layer that is called the *cross-attention layer*. The cross-attention layer allows the decoder to attend to the encoder's output, which contains information about the input sequence. This enables the decoder to generate output that is conditioned on the input.

== Positional encoding

We add another vector to the input embeddings, called *positional encoding*. The most common function is used sinousodial functions dependent from the position and on a given dimensionality ($i$ goes from $0$ to $d_"model"-1$). We have different oscillations depending on the dimension, and the frequency of the oscillation is different for each dimension.


== Attention

We use three matrix, where $X in R^(n times d)$ is the inpunt matrix. We perfrom 3 linear transformations:
- Query $X W^Q$.
- Key $X W^T$.
- Value
$d^'$ is usually minor than $d$ and it is a hyperparameter. We construct the similarity matrix $A$ as:
$
  A = (Q) K^T in R (n times n)
$
If we call a row of $Q$ as $q_1$ and a column of $k$ $k_1$, we can see an element of $A$ ($a_1$) as a dot product between $q_1$ and $k_1$:
$
  a_(1,1) = q_1 dot k_1 = sum_(j=1)^(d^') q_(1,j) k_(j,1)
$

The dot product is a *measure of similarity* between the two vectors. We can use the softmax function to normalize the rows of $A$, so that they sum to 1. A simple way to do this is to apply the softmax function to each row of $A$:
$
  sigma(a_(i j)) = e^(a_(i j)) / sum_(k=1)^n e^(a_(i k))
$
This gives us a probability distribution over the keys for each query. In the value matrix, we have for all the token $n$ their feature value. We can then use this distribution to weight the values, and obtain the output of the attention mechanism:
$
  z_i = sum_(j=1)^n v_j sigma(a_(i j)) = sum_(j=1)^n v_j sigma(q_i dot k_j)
$
The semantic of $z_i$ ( the embedding of the word $i$) depend on the value of similarity. The brief formuala is:
$
  Z = sigma((Q K^T) / sqrt(d^1)) V
$
at the ened we obtain a new matrix $n times d^'$. In this attention we pay attantion inside the same sequence, each token pay attention to all the other tokens in the same sequence.

The scaling factor $1/sqrt(d^')$ is used to prevent the dot products from becoming too large, which can cause the softmax function to saturate and lead to vanishing gradients during training. By scaling the dot products, we ensure that the softmax function produces a more balanced distribution of attention weights, allowing the model to learn more effectively.

#note()[
  This technique can be applied to other sequnces, like amino acid sequences, where we can use the attention mechanism to learn the relationships between different amino acids in a protein sequence. We only need to change the tokenization and the embedding layer to work with amino acid sequences instead of words. The rest of the architecture can remain the same, allowing us to leverage the power of transformers for protein sequence analysis.
]

=== Muti-head attention

We can have multiple had attention. We can run different sel-attention in parallel ($h$ heads) where weach one has their own $W^Q, W^K, W^V$ matrices. The idea is that each attention focuses on different semantic aspects, we can caputre different types of relationships between the tokens. Finally we concatenate all the outputs of the different heads and apply a linear transformation to obtain the final output of the multi-head attention mechanism. The formula is:
$
  overline(Z) = ["concat"(Z_1, Z_2, ..., Z_h)] W^O
$
The dimension is $Z_i in R^(n times d^')$, so the concatenation of $h$ heads gives us a matrix of dimension $n times (h d^')$. The linear transformation $W^O$ is used to project this concatenated matrix back to the original embedding dimension $d$, so that it can be used as input to the next layer of the transformer.

== FNN
We have a dense fully connceted network wich is applied in parallel to each row of $overline(Z)$ matrix:
$
  "Parralel"_(i=1,dots,n) "FFNN"(overline(z_i) -> overline(z_i)^')
$
The FNN is composed of two linear transformations with a ReLU activation in between. The first linear transformation projects the input to a higher-dimensional space, and the second linear transformation projects it back to the original embedding dimension. This allows the model to learn complex, non-linear relationships between the tokens in the sequence.

The final step are redidual connections and layer normalization:
$
  Z^' = "Nomr"(overline(Z)^' + overline(Z) )
$
for each row we apply a normalization function, like layer normalization or batch normalization. The residual connection helps to mitigate the vanishing gradient problem and allows for better gradient flow during training. The layer normalization helps to stabilize the training process and improve convergence.

== Encoder stack
The ouput of each encoder, could be used as input for the next encoder, so we can stack multiple encoders on top of each other. We have a modern architecture with $6$ encoders. Each block perform and astraction of the previous block. The encoder stack allows the model to learn hierarchical representations of the input sequence, capturing both local and global dependencies between tokens. For example:
- Block 1 -> Local agreement
- Block 2 -> Phrase structure
- Block 3 -> Cause level dependencies

== Decoder

The decoder is similar to the encoder, but it has an additional layer called the *masked self-attention layer*. This layer allows the decoder to attend to the previously generated tokens in the output sequence, while preventing it from attending to future tokens. This is important for autoregressive generation, where the model generates one token at a time and conditions on the previously generated tokens.

=== Masked self-attention

The masked self-attention layer is implemented by applying a mask to the attention weights, which sets the weights for future tokens to zero:
$
  Z = sigma((Q K^T + M) / sqrt(d^1)) V
$
Where $M in R^(n times n)$ has $-infinity$ strictly above the diagonal and $0$ on the diagonal and below. This ensures that the model can only attend to the tokens that have already been generated, and not to any future tokens.
#warning()[
  Since the training task of the model is to predict the next token, the decoder during training is only allowed to attend to the previous tokens in the output sequence.

  During training because during this phase we also have the ground truth output sequence.
]

=== Cross-attention

We obtaint the query matrix wich is the output of the decoder. The key and value matrices are obtained from the output of the encoder. The cross-attention layer allows the decoder to attend to the encoder's output, which contains information about the input sequence. This enables the decoder to generate output that is conditioned on the input.

The query matrix is obtained by multiplyng the output of the decoder masked self-attention and a learnable weight matrix $W^Q$:
$
  Q^D = Z_"mdec" W^D_Q
$
The sequence of the decoder could be different in lenght form the endoceer input, for example $Z$ could be $m times d$.\
The other two matrices comes form the output of the decoder. The attention matricies is a similarity between the $n$ token of the encoder and the $m$ token of the decoder.

The embeddings of the decoder dependes on the embeddings of the encoder. We take into account the similairty between the same token in the encoder and the decoder

== Output training, decoding

We need to projecting the otuput of the decoder:
$
  P = sigma(Z^(' D) W^P)
$
where $W^P$ is a learnable weight matrix that projects the decoder output to the vocabulary size and $Z^(' D)$ is the output of the decoder after the cross-attention layer and the feedforward neural network. The softmax function is applied to obtain a probability distribution over the vocabulary for each token in the output sequenc, the final result is $P in R^(m times v)$

=== Loss function

Once we have this probability distribution, we need to have a loss function. We use classical stocastich gradient descent in order to learn the weights of the model. The loss function is the cross-entropy loss between the predicted probability distribution and the ground truth output sequence. The cross-entropy loss measures the difference between the predicted and true distributions, and is defined as:
$
  L = - sum_(i=1)^m sum_(j=1)^v y_(i,j) log(p_(i,j))
$
where $y_(i j)$ is the correct label and $p_(i j)$ is the predicted probability for that label. In practice we not perform this double sum, because for each token we have only one correct label ($y_(i j)$ is a one hot vector). So we can simplify the loss function to the probability of the token in position $i$ being the correct label:
$
  - log (p_(i, "correct"))
$
Once we have a probabilty distribution on the vocabulary, we can choose the next word by sampling from this distribution or by taking the word with the highest probability. By the strategy of sampling we can have different outputs with different diversity and precision.

Another approach is *beam search*: For choosing the next word, we can keep track of the top $k$ most likely sequences at each step $t$, and *expand them* in the next step:
$
  max_(w_1, dots, w_m) product_(i=1)^m p(w_i | w_(<i))
$
This allows us to explore multiple possible sequences and choose the one with the highest overall probability. The beam search algorithm is a trade-off between exploration and exploitation, as it allows us to explore multiple possible sequences while still focusing on the most promising ones.

= Application of LLM to the analysis of protein sequences

Protein are seqeunces of amino acids, we can apply in a similar way LLM to protein sequences. There is some agreement between protein and natural language:
- A sentence can be seen as a full amino acid sequence that compose a protein

- Motif and domanins: small sequence important for sam function. A domanin is a part of a protein that is able to do a specific function. A motif is a small sequence that is important for the function of the protein. In natural language we have words and phrases that are important for the meaning of the sentence.

- Text made of sentnce correpond to a quaternary structure of a protein.

- A typo in a text could change the meaning of a text. This is also true with mutations, a change of amino acid could change the function of a protein.

There are also some differences between protein and natural language:
- A word in a text has specific boundaries. In a protein is difficult to define the boundaries of a domain or a motif. A domain could be composed of multiple motifs, and a motif could be part of multiple domains.

- We have 20 amino acids in the vocabulary, in text is much larger.

== BERT

Is a transformer encoder only transformer. The input is a sequence of tokens, and the output is a sequence of embeddings.

Given an input sequence of token we would like to predict the missing tokens. Some elements have been masked during the training ($approx 15$%). The main task is to predict the missing tokens given the context of the other tokens, we say that the encoder is *bidirectional*. The model is trained to minimize the cross-entropy loss between the predicted and true tokens.

Another pre-trained task is to predict if two sequences are related or not (if the first sentence imply the second sentence). The model is trained to minimize the binary cross-entropy loss between the predicted and true labels.


Finally we obtain a token embedding for each token in the input sequence. We can use these embeddings for various downstream tasks, such as classification, regression, or generation. The embeddings capture the semantic meaning of the tokens and their relationships to each other, allowing us to leverage the power of transformers for protein sequence analysis.

== GPT

Most of the popular LLM nowdays are decoder only. They are generative models. Given a sequence (prompt) we would like to predict the next token. The decoder is autoregressive, meaning that it generates one token at a time, conditioning on the previously generated tokens. For this scope they used masked self-attention, so that the model can only attend to the previously generated tokens in the output sequence.

#example()[
  In biomolecular the prompt may can been the first part of a protein sequence, and the model can generate the rest of the sequence aminoacids by aminoacids.
]

== Protain Language models

We can pre-train model with a very large example. Using a self-supervides approach (we are not labeling the data, we are use protein sequences as they are). We have three family:
- Encoder only
- Decoder only
- Encoder-decoder
=== Encoder based protein language models
One of the first is the *ESM-1b model*, which is a transformer encoder trained on a large dataset of protein sequences. The model is trained to predict the masked amino acids in the input sequence, and can be used for various downstream tasks, such as protein classification, structure prediction, and function prediction.

We have a downstream ML model trained on the embedding vector for downstram task, like:
- Structure prediction: predict whic residues site are closed to each other in the $3D$ structur but using only a sequence.
- Mutation effect prediction: predict the effect of a mutation on the function of a protein. We can use the embedding vector to predict the effect of a mutation on the function of a protein. We give in input the narual protien and the modified protein and we can train the model to learn what is the effect of the mutation (classification problem or regression problem).
- Remoto homology: we have to protein that are different in sequence, we can predict if they are related even if they are different in sequence. We obtain the embedding of the protein and we train a classifier that distinguish between related and unrelated proteins. It is a supervised task.

=== Decoder based protein language models

Some examples are:
- *ProtoGPT2*: It is trained os sequences of amino acids and it is able to generate novo sequencies that are similar to natural protein. Also they are able to explore more evolutionary space, we can explore protein that haven't been seen during the natural evolution (even are similar to existing ones).

==== Conditional generation
Given a context we also appens a condition to the input sequence (like a label or a property of the protein). The model is trained not only on the context but also on the specific function of the protein. We generare a protein with a specific function.

We need to pre-train this model because we need to given a positive and correct example. But during the instance phase we could specify an arbitrary function and the model will generate a protein with that function.

An example is generating enzyme that are able to generate the dioxic carbon in the atmosphere. Wich is responsible for the global warming.

=== Encoder and Decoder

We have an encoder that is trained to learn the embedding of the protein sequence. The decoder is trained to generate a drug that is able to bind to a specific protein. For example the input can be a protein responsible for a disease, and the output is a drug that can bind to that protein and inhibit its function. The model is trained on a large dataset of protein-drug pairs, and can be used for drug discovery and design.

Another task is given to encoder chemical reactants and the decoder generate enzyme that is able to catalyze the reaction.


== Open challenges
The interpretability of the model is still an open challenge. We should try to understand what the model has learned and how it makes its predictions. In medical applications this is very important because if we generate a molecule that act as a drug we need to understand how it works and if it is safe for human use.

