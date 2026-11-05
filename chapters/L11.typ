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

