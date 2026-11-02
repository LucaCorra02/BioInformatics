#import "../template.typ": *

= LLM (introduction)

They are introduced to process text. Are able to assign probability to sequence of word. It also easy that we can have other type of sequence in other context, lilke DNA, mRNA. The same model (with some adaption) can be apply in other context.

They can be also *generatve model*: generate new text by sampling the next word.

This model are *pre-trained* on very large database of text, with the task of predicting the next token. There are three main architecture:
- Decoders: like GPT, Claude, Gemini. Decoders are able to predict the next word using the previous word as a context
- Encoders: BERT family. Encoder are able to provide an embedding of the text that take into account the semantic of a word (they are bidirectional instead of decoder)
- Mixed

== Encoder

They are also called mask languege model. Some words are not given in output but should be predicted by the model based on the sourinding context (left and right).

== Encoder-Decoder

This type of architecture can use for translaction task. In bio-informatics we could try to use a sequnce (a protein) and try to generate a new protein that interact with the protein in input.

Other task is given a non-coding RNA we try to synthitise a the target of the RNA in input.

== Decoder

Given a prompt (the starting input text) we can generate new text. The model are autogeneretive: the new text is used as context for new words.

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

