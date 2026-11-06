#import "../template.typ": *

= LLM - Introduction

LLM are *large language model*. They are a type of neural network that are trained on a large corpus of text. They are able to understand the context of the text and generate new text based on the input. The main task is to predict the next word in a sequence of words.\
They can be also *generatve model*: generate new text by sampling the next word.

#note()[
  It's easy to understand that LLM are not only for text. They can be used for any type of sequence. For example, we can use LLM to predict the next nucleotide in a DNA sequence or the next amino acid in a protein sequence.
]

There are trhee type of LLM architecture:
- *Encoder*: Like BERT family. Encoder are able to provide an *embedding* of the text that take into account the semantic of a word (they are bidirectional instead of decoder)
- *Decoder*: like GPT, Claude, Gemini. Decoders are able to predict the next word using the previous word as a context
- *Encoder-Decoder*: This type of architecture can use for *translation task*. In bio-informatics we could try to use a sequence (a protein) and try to generate a new protein that interact with the protein in input.

== Architecture

The main idea its that we have a stack of *encoder* that gives a input sequence $x_1,dots, x_n$ maps them to a sequence of continuos representation $z=(z_1, dots, z_n)$. Given $z$ the decoder generate an output sequence $y_1, dots, y_m$ one elment at time (*auto-regressive model*: previously generated symbol used as additional input when generating text)

#align(center)[
  #image("../img/transformer.png", width: 40%)
]
Architecture stacks:
- *The Encoder (Source Processing):*
  - $N=6$ identical layers. Each layer has two sublayer (multi head attention and feed forwarding)

  - Uses *Self-Attention*. Every token attends to every other token in the input sequence in a single matrix multiplication ($O(n^2)$ complexity). Key, Value and Query come from the same phrase.

  - All sublayer produced $d_"model" = 512$ dimensions output

- *The Decoder (Auto-regressive Generation):*
  - Stack of $N=6$ identical layer
  - *Masked Self-Attention*: *Prevents leftward information flow*. Future tokens are masked by setting their values to $infinity$ before the softmax. Since $e^(-infinity) = 0$, the model cannot "cheat" by looking at future words during training.

  - *Cross-Attention*: Connects the two blocks. The *Decoder provides the Queries* ($Q$), while the *Encoder's final output* acts as the static database, providing the *Keys ($K$)* and *Values ($V$)*.
    #note()[
      Cross-Attention dynamically aligns the Decoder with the Encoder, allowing the generation process to *selectively attend to relevant segments* of the source sequence at each decoding step.
    ]

=== Encoder

Encoder is composed by a stack of $N$ identical layer. Each layer has two sublayer:
1. Multi-head self-attention mechanism
2. Feed-forward neural network

==== Self-Attention

Self-attention is a mechanism that allows the model to *weigh the importance of different tokens in the input sequence* when encoding a specific token. It computes a weighted sum of the input embeddings, where the weights are determined by the similarity between the token being encoded and all other tokens in the sequence.

We can see the self-attention as a matrix multiplication between the input sequence and a set of learned weight matrices. The input sequence $X in R^(N times d_"model")$ is transformed into three different representations:
- *Query ($Q$)* $Q = X W^Q in R^(N times d_k)$: Represents the token we are currently encoding.
- *Key ($K$)* $K = X W^K in R^(N times d_k)$: Represents the tokens we are comparing against.
- *Value ($V$)* $V = X W^V in R^(N times d_v)$: Represents the information we want to aggregate based on the attention scores

Each of these projections is learned during training. The dimensions of these projections are typically set to $d_"k" = d_"v" = d_"model" / h$, where $h$ is the number of attention heads. The attention scores are computed as:
$
  "Attention" = "softmax"((Q K^T) / sqrt(d_k)) V
$
where:
- $Q K^T$ computes the similarity between the query and all keys. It's a dot product that gives us a score for how much attention each token should pay to every other token. The result is a $N times N$ matrix of attention scores.

- The softmax function normalizes these scores into a probability distribution, ensuring that they sum to 1.

- Finally, we multiply the attention scores by the value matrix $V$. These matrix present on the rows the token and on the columns the embedding features. The result is a weighted sum of the values, where the weights are determined by the attention scores. For each token, we get a new embedding of dimension $d_v$:
$
  sum_(j=1)^N "Attention"(i,j) V_j
$

#note()[
  *Why scale by $sqrt(d_k)$?* If the hidden dimension $d_k$ is large, the dot products $Q K^T$ produce massive values. Passing huge numbers into a softmax function pushes it into extreme flat regions where the derivative is close to zero (*vanishing gradient problem*), stopping the network from learning. Scaling down prevents this saturation.
]

#example()[
  Let's trace the math with a simplified scenario. Assume a sequence of $N = 2$ tokens (e.g., the words "Deep" and "Learning") and a hidden dimension of $d_k = d_v = 2$.

  Suppose that after multiplying our input sequence $X$ by the learned weights $W^Q, W^K, W^V$, we obtain the following matrices:
  $
    Q = mat(1, 0; 0, 2), quad K = mat(1, 1; 0, 2), quad V = mat(10, 20; 30, 40)
  $
  Each row corresponds to a token (Row 1 = "Deep", Row 2 = "Learning").

  *Step 1: Compute Similarity ($Q K^T$)* \
  We compute the dot product between the queries and the transposed keys to measure how much each token relates to the others:
  $
    Q K^T = mat(1, 0; 0, 2) mat(1, 0; 1, 2) = mat(1, 0; 2, 4)
  $
  - Row 1 ($[1, 0]$) contains the raw scores for Token 1 looking at Token 1 and Token 2.
  - Row 2 ($[2, 4]$) contains the raw scores for Token 2 looking at Token 1 and Token 2.

  *Step 2: Scale and Softmax* \
  We scale the scores by $sqrt(d_k) = sqrt(2) approx 1.41$. To keep the math readable in this toy example, let's assume the scaled matrix is roughly:
  $
    (Q K^T) / sqrt(d_k) approx mat(0.7, 0; 1.4, 2.8)
  $
  Next, we apply the softmax function to each row independently. Softmax converts the raw scores into a valid probability distribution (where each row sums to 1):
  $
    "Attention Weights" approx mat(0.67, 0.33; 0.20, 0.80)
  $
  - Token 1 pays $67%$ of its attention to itself and $33%$ to Token 2.
  - Token 2 pays $20%$ of its attention to Token 1 and $80%$ to itself.

  *Step 3: Compute the Final Output* \
  Finally, we multiply the attention weights by the Value matrix $V$. This mixes the information of the tokens based on the computed attention distribution:
  $
    "Output" = mat(0.67, 0.33; 0.20, 0.80) mat(10, 20; 30, 40) = mat(16.6, 26.6; 26.0, 36.0)
  $
  The first row of the output is a weighted sum of the values: $0.67 times [10, 20] + 0.33 times [30, 40]$. The token "Deep" has now successfully integrated contextual information from the token "Learning".

]

==== Multi-head Attention

Instead of a single attention function, the model projects $Q, K, V$ into $h$ smaller sub-spaces (e.g., $h=8$ heads).
- *Multiple Perspectives*: Head 1 might focus on syntax (subject-verb agreement), while Head 2 maps semantic relationships (color-noun).
- *Zero Overhead*: Because the vector dimension is sliced ($512 / 8 = 64$ dimensions per head), calculating 8 heads in parallel requires the exact same computational cost as a single 512-dimensional head.

Outputs from all heads are concatenated back together and linearly projected via $W^O$.

#note()[
  Each Head have they own $W^Q, W^K, W^V$ matrices. This allows each head to learn different types of relationships between tokens.
]


==== Feed-forward neural network

Attention alone is just a linear combination of vectors. To extract abstract, complex patterns, *each token's new context-aware vector* is passed through an identical FFN independently (Position-wise).
$ "FFN"(x) = max(0, x W_1 + b_1) W_2 + b_2 $
If Attention is the "information gathering" phase, the FFN is the non-linear "reasoning" phase.

*Residual connections* stabilize deep network training by creating shortcut paths that allow gradients to flow unimpeded through the layers, effectively mitigating the vanishing gradient problem.

#note()[
  The idea is that we add a `AddNorm Layer`, the input $x$ and the result vector form the attention $f(x)$ are summed up $(f(x)+x)$. This is usefull in the back-propagation step because the derivate will be *$F'(X)+1$*. The $+1$ is usefull because if the weights $F'(x)$ tend to zero the gradient is multiplied by $1$, so it arrived clean and continues to the previous layer.
]

=== Decoder




==== Cross-Attention

Cross-Attention links *encoder* and *decoder*. The decoder is allow to look back at the entire past states of the encoder and *dynamically* select with parts are relevant at each specific generation step:

1. The decoder at step $t$ computes how relevant each past encoder state $s_k$ (*internal last state* for each word in the input sequence) is with respect to its current internal state $h_t$ (dot product):
  $
    "score" = theta(s_k, h_t)
  $
  #note()[
    These scores *change dynamically* for every new word generated, allowing the model to shift its focus and attend to different segments of the input sequence as needed.
  ]


2. The score are normalized into a probability distribution using a *soft-max* function.
3. The new dynamic context is the weighted sum of all encoder states:
  $
    c_t = sum^n_(k=1) a_k s_k
  $

#note()[
  Instead of a *single static vector*, the model computes a specific context *$c_t$* *for every single word *it generates, eliminating the fading memory problem completely.
]

==== Causal Masked Self-Attention

The foundational mechanism of Decoder-only architectures (such as the GPT family) is *Causal Masked Self-Attention*. While BERT's Encoder employs bidirectional attention where every token can look at the entire sequence, a generative language model must remain *blind to future tokens during training* to accurately simulate autoregressive inference.

During the attention layer computation, the raw alignment scores are generated via the scaled dot-product of Queries and Keys ($(Q K^T) / sqrt(d_k)$). Before passing these scores to the Softmax function, a causal attention mask matrix ($M$) is added:

$ "Attention"(Q, K, V) = "softmax"((Q K^T) / sqrt(d_k) + M)V $

The mask $M$ is a *lower-triangular matrix* defined as:
- $M_(i,j) = 0$ for $i >= j$ (the token can attend to past tokens and itself).
- $M_(i,j) = -infinity$ for $i < j$ (the token is blocked from attending to future tokens).

When the Softmax functionexponentiates these values, $e^(-infinity)$ drops to $0$, mathematically eliminating any information leakage (*information lookahead bias*) from right to left.

During evaluation, when our model is only adding one new word after each iteration, it* would be inefficient to recalculate self-attention along earlier paths* for tokens that have already been processed.
#note()[
  Every self-attention layer *holds on to its respective key and value* vectors for each token.
]

#warning()[
  *Parallel Training vs. Sequential Inference:* \
  Although text generation in production is strictly sequential ($O(T)$ steps, writing one token at a time), the causal mask allows the pre-training phase to be massively parallelized on GPUs. A single training sequence of length $T$ is processed in a single forward pass, effectively acting as a batch of $T$ distinct sub-sequences where each position $t$ learns to predict the target token $t+1$.
]







== Adapting an LLM to task

We can have may task that can turn into the task of generate the next word.

#example()[
  In sentyment analysis we have a phrase: "I like Jackie Chan".

  We want to predict the probability that this phrase is positive. By using an LLM we can try to predict the final label:
  $
    P("postive" | "The sentyment of the phrase: I like Jackie Chan is: ")
  $
]

A LLM generate not directly the next word, but a distibution of probability over the next word. The task of choosing a specific word by the distribution is calles *Decoding*. We can use various type of sampling:
- *Random Sampling*: We cycle while the word selected is != EOF. We extracted the next word by considering the probability $p(w_i | w_(<i))$ given the prevoius word in sequence.
  #pseudocode(
    [$i <- 1$],
    [$w_i$],
  )
  #warning()[
    This is not a good idea. Because we can have a small probability to extract words that are not so usefull: they are in the tail of the distribuction.

    If we consider a gaussian we can have a chance by extracting randomly that we extract a word sitten in the tail
  ]

- High probability: more accurate, coherent and factual. But we lose in diversity: if we try to pick always the most probabile word we can have a lot of repetition. A strategy can use *top-k sampling*: we sort the words by likelihood, keeping only the tip most probable word. Then we re-normalize the original probability to have another probability distribution. If we choose a high $k$ we can obtain more diversity.

  There is a problem with a fixed top k. In output we can obtain different distribution shape, but a static k may cover different amounts of probability mass. For example if we have a uniform like distribution.

  To achive this problem we use *top-p vocabulary*. We select the smallet test of word that summing the probabolity will arrive to a certain treshold:
  $
    V(p) = sum_(w in V^p) P(w | w_t) >= p
  $

- Middle-probability: we have more diversity but less accurancy

=== temperature

Another sampling tecquinique is *temperature*: instead of truncating the distribution we reashape it. A system with a high temperature is flexible and can explore more probabile state (the LLM is more creative).

In order to obtain an output probabiity we use softmax function. Instead of computing the softmax on the raw score for each word (logits) we divide by temperature:
$
  y = "softmax"(u / t)
$
When $t$ is close to $1$ the distribution dosen't change much. The lowe $t$ is the larger the score being passed to the softmax. We focus in this case on the most probabile token.

== Pre-training

First we pre-train a transformer model on a very large dataset. In this phase the model learn generale knowlege. After that to specilize the model we apply it to new task by find-tuning it.

=== Self-supervised training

We train our LLM to predecit the next word:
- We take corpus of text
- At eact step $t$ we would like to predict the next word. In this way we not have problem of missing label, because the label are intrinsic into text.

In bioinformatics this concept is also true for nucleotide. Because we also have the entire sequence.

Cross entropy loss:
$
  L_"CE" = - sum_(w in V) y_t[w] log hat(y_t)[w]
$
since the distribution of the correct word is 1 for the real next word and zero for all the other word in the vocabulary we can re-write it as:
$
  L_"CE"(hat(y)_t, y_t) = -log hat(y)_t [(w_t+1)]
$
//aggiungere disegno
When we have values that are close to zero, the loss will be infinity. We have a big penalization for incorrect prediction.

//riguardare
*Teacher forcing*: instead of using what is predected by our model, in the training phase, we use the correct word. If we only use the prediction, we can have a sequence composed by an error. So we ignore tha model prediction for token $w_t+1$ and we append the correct $w_(t+1)$ token to th seqeunce generated

Training a LLM:
- Input encoding:
- Deep Network:
- The neural network retunrs a vector of raw score (for each vocabulary token). Then we use softmax probability.
- After that we can apply cross-entropy loss.
- The next token is obtaining by sampling by this probabolotu.

LLM are mainily training on the web

== Find-tuning

We start form the LLM obatin by the pre-train, after that we find-tuning it for a specific context domain.

Fintunnign means: taking a pretrained model and futher adapting some or all of its parameters to some new data. This operation is not always possible, for example if the model is closed or big (like GPT) this is impossible. We need open modle like lama.

//riguardare
Continued pretraing

== Evaluation of LLM

== Perplexity // riguardare questa parte

#informally()[
  It give us.....
]


If we have a set of $n$ token, the prexplexity is the inverse geometric mean of the probabability that have been assign to the $n$ token:
$
  "Perp"_theta....
$
The probability of a sequence of token get smaller by the increasing of the text size. It depend on the leght of the text.

Perpexlity is normalize by the number of words, it ranges in [1, infinity].

Consider a sequnce of words, we can decompose this into a conditional probabiliti chain:
$
  P(w_1,w_2,dots,w_n) = P(w_1)P(w_2|w_1)P(w_n|w_1,dots,w_(n-1)) = product_(i=1)^n P(W_i | W_(<i))
$
this is the conditionally likelihhod, but usually we use the log-lkelihood. Because we have a sum and not a product of error, we can prevent underflow:
$
  log product_(i=1)^n P(W_i | W_(<i)) = sum_(i=1)^n log(P(W_i | W_(<i)))
$
minimazie the negative log-likelihood is equal to minimaze the cross-entropy loss:
$
  "Min"_(theta) "NLL" = - 1/N ..
$
the *perplexity is the exponentation of the avarage NLL*:
$
  2^(-1/N sum_(i=1)^n log(P(W_i | W_(<i)))) = sqrt(1 / (P(w_i | w(<i))))
$
- We return a probability scale
- Provides the sense of how mmany choises the model is uncertain about

#example()[
  Suppose that we have an uncertain prediction. If we have $k$ token the uniform distribution is $1/k$ for all over the keys. The perplexity is:
  $
    "PPL" = ((1/k)^n)^(-1/n) = K
  $
  the perpelxity when we have a complete uncertainy is $K$. With neuclotids $k=4$ if we have an uncertian model the PPL=$4$ wich is a very bad prediction.
]

#note()[
  We can comparte different perplexity because it depends on the domain and how we consider the token. A good perplexity is when we have a 1 to each token.

  Perplecity is sensible at tokezination process.
]

A lowe perplecity mean a good model. *Mimimazing the perplexity is the same as maximizing probability*

=== Scaling Laws
Having a very big model usually gives us a better result, alto having a lot of data improve the loss.
//aggiungere formule

This law tell to us that we need very big and very big training data to get a very good LLM.

We can also try to estimate the number of the non-embeddng parameters. The weights of the network inside the LLM:
$
  N approx 2 underbrace(d, "single layer" \ "dim") "n_layer" ( 2 d_"attn" + d_"ff") \
  approx 12 n_"layer" d^2
$
(assuming $d_"attn" = d_"ff" / 4 = d$).

= Transformer

The mainly task achived by the transformer is a sequence to sequence task. In input we have a sequence of $n$ token and we want to try to predict a sequence of lenght $m$:
$
  a = [a_1,a_2,dots,a_n] -> t = [t_1,t_2, dots, t_m]
$

This task include, text generation, translation task ecc.

The architectur is compose by:
1. Input representation: token, embeddings and positional encoding.
2. Self-attention: is a meccanism wich can understand the semantic of the different tokens
3. Encoder block
4. Decoder block: It include the mask attention and cross-attention
5. Output and training

== Attention

RNN are recurent neural netwrok that recive an inpunt $x_t$ and a previous hiddent state (an embedding) $h_t$ to compute the next hidden state. We need to compute sequentionaly the different encodng representation. A dependency between the positions $i$ and $j$ travers $|i-j|$, if $i$ and $j$ are distant we can have gradient decatu or exploding decay

Attention resolve the problem. Is a mechanism for helping ...

#example()[
  Given a sequence of token embedding:
  $
    x_1, x_2, x_3, x_5, x_6, x_7, x_8
  $
  produce $a_i = a$ weighted sum of $x_1$ trhought $x_7$ weighted by their similarity to $x_i$:
  $
    "score"(x_i,x_j) = x_i dot x_j
  $
  then we transform this score into a probability distribution. The representation of the next layer correpond to the sum of the embeddeng representation weighted by the similarity:
  $
    a_i = sum_(j <= i) a_(i j) x_j
  $
]
the embedding of this th next layer it attends on a specific token in the input sequence.

== Input representation

We need to perform a tokenizaion process: we transform out sequence in a sequence of token. We could consider as token the single letter of the alphabets. Or even we consider each word as a token.

The tokenizer, must choose a vocabolary. If we consider an entire language as a vocabolory we have a lot of words. As opposite we can chose as a token the characters but we need a lot of memory because we obtaind a vector for every token (a word with 5 character need 5 vector).

We can use sereval algorithms that act like a mdium approach, the most famous is the *byte pair encoding*:
- We start form charcters.
- We merge the commonest pair by counting it frequency in the text corpus. We replace the most frequence once by the new simbol
- We repeat the process untile we reach a target vocabulary size.

Word that are so frequent have their specific token. Word that are not so frequent use *sub-tokenization* and divided in well known token.

//aggiungere esempio
#example()[

]


$
  e: A -> E, space E subset R^d
$
the embedding is a map to token to vector. This function will be learned by the backpropagation

The input matrix is a matrix that is composed $X in R^(n times d)$. Inizitally the embedding associated are usualli sampled from a random distribution (or one hot encoded). This act as a look-up table.

== Encoder block

Is composet by two main block:
- Multi-head attention
- FNN
this two block are wrapped in two residual connection to solve the vanishing gradient problem

=== Self-attention

