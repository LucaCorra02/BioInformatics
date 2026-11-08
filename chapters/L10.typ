#import "../template.typ": *

= LLM - Introduction

*Large Language Models (LLMs)* are deep neural networks trained on massive corpora of sequential data. They are capable of capturing complex contextual relationships across tokens and generating new sequences conditioned on an input prompt. Formally, a language model estimates a *probability distribution* over a sequence of tokens $w_1, dots, w_n$ via the chain rule of conditional probabilities:
$
  P(w_1, dots, w_n) = product_(i=1)^n P(w_i | w_1, dots, w_(i-1)) = product_(i=1)^n P(w_i | w_(<i))
$
Because the core objective of an *autoregressive* LLM is to predict the next token $w_i$ given the preceding context $w_(<i)$, it naturally acts as a *generative model* by iteratively sampling the next token and appending it back to the input sequence.

#note()[
  LLMs are *not restricted to human natural language*. Because they operate on any discrete sequential domain where elements exhibit local and long-range dependencies, they can be directly applied to biological sequences—for instance, predicting the next nucleotide in a DNA/RNA sequence ($A, C, G, T$) or generating *de novo* amino acid sequences in *Protein Language Models (pLMs)*.
]

There are three main categories of Transformer-based LLM architectures:
- *Encoder-only (Autoencoding Models)*: such as the *BERT* family (and *ESM-2* for proteins). Encoders use *bidirectional self-attention* to build rich, context-aware *embeddings* of the input sequence, taking into account both left and right context simultaneously. They are ideal for sequence classification, token-level annotation, and representation learning, rather than open-ended generation.
- *Decoder-only (Autoregressive Models)*: such as *GPT*, *Claude*. Decoders use *causal masked self-attention* to predict the next token using strictly the preceding tokens as context.
- *Encoder-Decoder (Sequence-to-Sequence Models)*: such as the original Transformer, *T5*, or *BART*. Designed for conditional *sequence-to-sequence tasks* ($"seq" arrow.r "seq"$, e.g., machine translation). In computational biology, an Encoder-Decoder can encode a target receptor protein sequence and decode a novel binder protein or drug molecule that interacts with it.

== Architecture Overview

In the full Encoder-Decoder Transformer architecture, a stack of *Encoders* receives an input sequence of tokens $(x_1, dots, x_n)$ and maps it to a sequence of continuous contextual representations $bold(z) = (z_1, dots, z_n)$. Given $bold(z)$ (the last hidden representation layer), the *Decoder* stack generates an output sequence $(y_1, dots, y_m)$ one element at a time in an *autoregressive* manner (feeding previously generated symbols back as additional input at the next step).

#align(center)[
  #image("../img/transformer.png", width: 40%)
]

The two stacks are structured as follows:
- *The Encoder Stack*:
  - Composed of $N = 6$ identical layers. Each layer contains two sub-layers: a *Multi-Head Self-Attention* mechanism and a *Position-wise Feed-Forward Network (FFN)*.
  - Uses bidirectional *Self-Attention*: every token attends to every other token in the input sequence in a single parallelized matrix operation (*$O(n^2)$* time and memory complexity with respect to sequence length $n$). Queries ($Q$), Keys ($K$), and Values ($V$) are all projections of the same source sequence.
  - Every sub-layer is wrapped in a residual connection followed by Layer Normalization (`Add & Norm`) and produces outputs of dimension $d_"model" = 512$.

- *The Decoder Stack (Autoregressive Generation)*:
  - Composed of $N = 6$ identical layers, each containing *three* sub-layers.
  - *Masked Multi-Head Self-Attention*: prevents leftward information flow (*lookahead bias*). Future tokens at positions $> t$ are masked by adding $-infinity$ to their attention logits prior to the softmax. Since $e^(-infinity) = 0$, the model cannot "cheat" by peeking at future tokens during parallel training.
  - *Multi-Head Cross-Attention*: bridges the Decoder and the Encoder. The *Decoder provides the Queries ($Q$)* from its current hidden state, while the *Encoder's final representation $bold(z)$* acts as a static key-value database providing the *Keys ($K$)* and *Values ($V$)*.
  - *Position-wise Feed-Forward Network (FFN)*.

#note()[
  *Cross-Attention* dynamically *aligns the Decoder with the Encoder*, allowing the generation process to selectively attend to the most relevant segments of the source sequence at each decoding step, completely eliminating the static-context bottleneck of traditional RNN Encoder-Decoder models.
]

=== The Encoder Block

Each Encoder layer consists of two core modules wrapped in residual connections and layer normalization:
1. Multi-Head Self-Attention mechanism.
2. Position-wise Feed-Forward Neural Network (FFN).

==== Self-Attention (Scaled Dot-Product Attention)

Self-attention allows the model to *weigh the importance of different tokens in the input sequence* when encoding a specific token, resolving long-range dependencies *regardless of physical distance* in the sequence. It computes a context-aware representation for each token as a weighted sum of the values of all tokens in the sequence.

From a linear algebra perspective, given an input matrix $X in RR^(N times d_"model")$ (where $N$ is the number of tokens and $d_"model"$ is the embedding dimension), each token is linearly projected into three learned representations via weight matrices $W^Q, W^K in RR^(d_"model" times d_k)$ and $W^V in RR^(d_"model" times d_v)$:
- *Query ($Q = X W^Q in RR^(N times d_k)$)*: *_What am I looking for?_* it represents the current token's search intent.
- *Key ($K = X W^K in RR^(N times d_k)$)*: *_What do I offer?_* it acts as the semantic label/identifier of every token being compared against.
- *Value ($V = X W^V in RR^(N times d_v)$)*: *_What is my actual content?_* it holds the information payload to be aggregated based on the attention weights.

Typically, the projection dimensions are set to $d_k = d_v = d_"model" / h$, where $h$ is the number of attention heads (e.g., $512 / 8 = 64$). The *Scaled Dot-Product Attention* is computed as:
$
  "Attention"(Q, K, V) = "softmax"((mr(Q K^T)) / sqrt(d_k)) V
$
where:
- $mr(Q K^T) in RR^(N times N)$ computes the pairwise dot-product similarity between every Query and every Key. Entry $(i, j)$ quantifies how much token $i$ attends to token $j$.
- The row-wise $"softmax"$ function normalizes the scaled scores into a valid probability distribution $A in RR^(N times N)$ such that $sum_(j=1)^N A_(i, j) = 1$ for every token $i$.
- Multiplying the attention matrix $A$ by the Value matrix $V in RR^(N times d_v)$ yields a new contextualized embedding of dimension $d_v$ for each token $i$, computed as a convex combination (weighted sum) of the rows of $V$:
  $
    bold(z)_i = sum_(j=1)^N "Attention"(i, j) V_j
  $

#note(title: "Why scale by " + $sqrt(d_k)$ + "?")[
  If the key dimension $d_k$ is large, the variance of the dot products $Q K^T$ grows proportionally to $d_k$, producing large magnitude logits. Passing large values into the softmax pushes the function into saturated, flat regions where gradients are nearly zero (*vanishing gradient problem*), stalling backpropagation. Dividing by $sqrt(d_k)$ restores unit variance and prevents softmax saturation.
]

#example()[
  *Step-by-Step Numerical Trace of Self-Attention* \
  Assume a sequence of $N = 2$ tokens (e.g., `"Deep"` and `"Learning"`) and hidden dimensions $d_k = d_v = 2$. Suppose the projected matrices $Q, K, V$ are:
  $
    Q = mat(1, 0; 0, 2), quad K = mat(1, 1; 0, 2), quad V = mat(10, 20; 30, 40)
  $
  where Row 1 corresponds to `"Deep"` and Row 2 to `"Learning"`.

  *Step 1: Compute Similarity ($Q K^T$)* \
  $
    Q K^T = mat(1, 0; 0, 2) mat(1, 0; 1, 2) = mat(1, 0; 2, 4)
  $
  - Row 1 ($[1, 0]$) stores the raw affinity of Token 1 toward Token 1 and Token 2.
  - Row 2 ($[2, 4]$) stores the raw affinity of Token 2 toward Token 1 and Token 2.

  *Step 2: Scale by $sqrt(d_k)$ and Apply Row-wise Softmax* \
  Dividing by $sqrt(2) approx 1.41$ gives:
  $
    (Q K^T) / sqrt(d_k) approx mat(0.71, 0; 1.41, 2.83)
  $
  Applying softmax independently across each row yields the attention weight matrix $A$:
  $
    A = "softmax"((Q K^T) / sqrt(d_k)) approx mat(0.67, 0.33; 0.20, 0.80)
  $
  Token 1 allocates $67%$ of its attention to itself and $33%$ to Token 2, while Token 2 allocates $20%$ to Token 1 and $80%$ to itself.

  *Step 3: Aggregate Values ($A V$)* \
  Multiplying the $2 times 2$ attention weights by the $2 times 2$ Value matrix $V$ mixes the token features:
  $
    "Output" = mat(0.67, 0.33; 0.20, 0.80) mat(10, 20; 30, 40) = mat(16.6, 26.6; 26.0, 36.0)
  $
  Row 1 is $0.67 times [10, 20] + 0.33 times [30, 40] = [16.6, 26.6]$: Token 1 (`"Deep"`) has absorbed contextual features from Token 2 (`"Learning"`).
]

==== Multi-Head Attention

Instead of computing attention once in $d_"model"$, *Multi-Head Attention* projects $Q, K, V$ into $h$ distinct lower-dimensional subspaces ($h$ heads, e.g., $h = 8$ or $12$) using *independent learned projection matrices* $(W_i^Q, W_i^K, W_i^V)$ for each head $i in {1, dots, h}$:
$
  "head"_i = "Attention"(X W_i^Q, X W_i^K, X W_i^V) in RR^(N times d_v)
$
- *Multiple Representational Subspaces*: each head has its own parameters and can specialize in different linguistic or biological relationships (e.g., Head 1 tracks local syntactic agreement or adjacent backbone bonds, while Head 2 captures long-range coreference or 3D tertiary contact between distant amino acids).
- *Zero Computational Overhead*: because each head operates on dimension $d_k = d_"model" / h$ (e.g., $512 / 8 = 64$), computing $h$ heads in parallel has the same asymptotic FLOP cost as single-head attention with full dimension $d_"model"$.

Finally, the outputs of all $h$ heads are *concatenated along the feature dimension* ($N times (h dot d_v) = N times d_"model"$) and linearly projected through an output weight matrix $W^O in RR^(d_"model" times d_"model")$:
$
  "MHA"(X) = "Concat"("head"_1, dots, "head"_h) W^O
$

==== Position-wise Feed-Forward Network (FFN) and Residual Connections

Because self-attention is a weighted linear combination of values, each token's contextualized vector is subsequently passed independently through an identical, non-linear *Position-wise Feed-Forward Network (FFN)* consisting of two linear transformations with a ReLU (or GELU) activation in between:
$
  "FFN"(x) = max(0, x W_1 + b_1) W_2 + b_2
$
The inner hidden layer typically expands the dimensionality by a factor of $4$ (e.g., $d_"ff" = 4 d_"model" = 2048$ in the base Transformer, or $768 times 4 = 3072$ in GPT-2 Small) before projecting back down to $d_"model"$. Intuitively, if Self-Attention is the *"information gathering"* step across tokens, the FFN acts as the non-linear *"feature reasoning"* step within each token.

#note(title: "Why Residual Connections (Add & Norm) Prevent Vanishing Gradients")[
  Every sub-layer $F(x)$ (both MHA and FFN) is wrapped in a *Residual (Skip) Connection* followed by Layer Normalization:
  $
    y = "LayerNorm"(x + F(x))
  $
  During backpropagation, by the chain rule, the derivative of the residual block $x + F(x)$ with respect to $x$ is:
  $
    (partial (x + F(x))) / (partial x) = 1 + F'(x)
  $
  The $+ 1$ term acts as a gradient superhighway: even if the weights inside $F'(x)$ shrink toward $0$ in deep stacks, the upstream gradient is multiplied by $1$ and flows backward unimpeded to earlier layers.
]

=== The Decoder Block

Unlike the Encoder, the Decoder generates sequences autoregressively *one token at a time* (in the inference phase). At each decoding step $t$, the top Decoder block outputs a hidden state $h_t in RR^(d_"model")$, which is multiplied by the vocabulary projection matrix $W_"vocab"$ (often tied to the input embedding matrix) to produce a probability distribution over the next token $y_t$ given past tokens $y_(<t)$ and the Encoder representation $bold(z)$:
$
  P(y_t | y_(<t), bold(z)) = "softmax"(W_"vocab" h_t + b_"vocab")
$

==== Cross-Attention (Dynamic Context Alignment)

In Encoder-Decoder models, *Cross-Attention* connects the two stacks by allowing the Decoder at step $t$ to dynamically query the entire sequence of Encoder states $bold(z) = (s_1, dots, s_n)$:
1. When generating token $t$, the Decoder's current state provides a single *Query vector* $Q in RR^(1 times d_k)$, while the Encoder's $n$ output states provide the *Key matrix* $K in RR^(n times d_k)$ and *Value matrix* $V in RR^(n times d_v)$.
2. The alignment score vector is computed via scaled dot-product: $"scores" = (Q K^T) / sqrt(d_k) in RR^(1 times n)$.
3. Applying $"softmax"$ yields the attention distribution $bold(a) in RR^(1 times n)$, and multiplying by $V$ produces the *dynamic context vector* $c_t = sum_(k=1)^n a_k V_k in RR^(1 times d_v)$ tailored specifically for decoding step $t$.

==== Causal Masked Self-Attention & The KV Cache

In Decoder stacks (and Decoder-only LLMs like GPT), the self-attention sub-layer must prevent a token at position $i$ from attending to any *future token* at position $j > i$. Before applying the softmax, a *Causal Mask matrix* $M in RR^(N times N)$ is added to the scaled dot-product logits:
$
  "CausalAttention"(Q, K, V) = "softmax"((Q K^T) / sqrt(d_k) + M) V, quad \ "where " M_(i, j) = cases(
    0 & quad "if " i >= j " (past & current tokens)",
    -infinity & quad "if " i < j " (future tokens blocked)"
  )
$
explicitly:
$
  (Q K^T) / sqrt(d_k) + M = mat(
    q_1 k_1^T, -infinity, dots, -infinity;
    q_2 k_1^T, q_2 k_2^T, dots, -infinity;
    dots.v, dots.v, dots.down, dots.v;
    q_N k_1^T, q_N k_2^T, dots, q_N k_N^T
  )
$
When exponentiated inside the softmax, $e^(-infinity) = 0$, guaranteeing zero information leakage from future positions.

#warning(title: "Parallel Training vs. Sequential Inference (Prefill & KV-Cached Decoding)")[
  - *Training Phase (Massively Parallel)*: thanks to the causal mask $M$, an entire training sequence of length $T$ is processed in a *single forward pass* on GPUs. It acts as a batch of $T$ simultaneous prediction tasks where position $t$ predicts token $t+1$.
  - *Inference Phase (Two-Stage Autoregressive Generation with KV Cache)*: at test time, future tokens do not exist yet, so generation proceeds in two distinct hardware phases:
    1. *Prefill Phase (Compute-bound)*: the user prompt of length $N$ is processed in parallel, and the resulting Key and Value tensors ($K_"history", V_"history"$) at every layer are stored in GPU VRAM (*KV Cache*).
    2. *Decoding Phase (Memory-bound)*: to generate token $t+1$, the model feeds *only the single newest token* ($1 times d_"model"$), computes its single new vectors $q_(t+1), k_(t+1), v_(t+1)$, appends $k_(t+1), v_(t+1)$ to the cached matrices in VRAM, and computes $q_(t+1) K_"total"^T$. This avoids recomputing past states from scratch, reducing per-step attention complexity from $O(t^2)$ to $O(t)$.
]

== Adapting an LLM to Downstream Tasks & Decoding Strategies

=== Casting Tasks as Next-Token Generation (Prompting)

Many classification, reasoning, or biological design problems can be reformulated as conditional next-token prediction tasks via *Prompt Engineering* (*Zero-Shot* or *Few-Shot* in-context learning, without updating model weights).

#example()[
  In *Sentiment Analysis*, given the sentence `"I like Jackie Chan"`, we can predict its polarity by querying the probability assigned by the LLM to the label tokens conditioned on an instruction prefix:
  $
    P("positive" | "The sentiment of the phrase 'I like Jackie Chan' is:")
  $
  Similarly, in *conditional protein generation* (e.g., *ProGen*), we prepend a functional control tag (such as a Pfam family or Gene Ontology term) and let the model autoregressively decode the amino acid sequence:
  $
    P(a_1, a_2, dots, a_L | "[Pfam: Lysozyme; Stability: High]")
  $
]

== Decoding and Sampling Strategies

At each generation step $t$, the LLM outputs a vector of raw unnormalized scores (*logits*) $bold(u) in RR^(|V|)$ over the vocabulary $V$, which is converted into a probability distribution:
$ P(w | w_(<t)) = "softmax"(bold(u)) $
The procedure used to select the actual next token $w_t$ from this distribution is called *Decoding*:

1. *Greedy Search & Beam Search (Deterministic Maximizers)*:
  - *Greedy Search*: always selects the *single most probable token* $w_t = arg max_w P(w | w_(<t))$. While accurate and factual over short horizons, it lacks diversity, misses globally optimal sequences, and frequently degenerates into repetitive loops.
  - *Beam Search*: maintains the *top-$B$* most likely partial hypotheses (beams) at each step and expands them, pruning low-scoring branches.

2. *Pure Random Sampling*:
  Samples $w_t tilde P(w | w_(<t))$ directly from the full categorical distribution until an `<EOS>` (End-Of-Sequence) token is drawn:
  #pseudocode(
    [$i <- 1$],
    [*while* $w_(i-1) != "EOS"$ *do*],
    [  Compute distribution $P(w | w_1, dots, w_(i-1))$ via forward pass],
    [  Sample $w_i tilde P(w | w_1, dots, w_(i-1))$],
    [  $i <- i + 1$],
    [*end*],
  )
  #warning()[
    *The Long-Tail Trap*: pure random sampling is dangerous because thousands of nonsensical or out-of-context tokens sit in the *long tail* of the distribution. Even though each individual tail token has a tiny probability, their cumulative probability mass is non-negligible, causing the model to occasionally sample incoherent words (or invalid amino acid mutations) that derail subsequent autoregressive steps.
  ]

3. *Top-$k$ Sampling (Static Truncation)*:
  Sorts the vocabulary tokens by descending probability, retains *only the $k$ most probable tokens* $V^((k))$, zeroes out the rest, and re-normalizes the probabilities to sum to $1$.
  - *Limitation*: a fixed $k$ cannot adapt to the shape (entropy) of the distribution. If the distribution is *peaked* (only 2 words make sense), $k = 50$ includes 48 bad tail tokens; if the distribution is *flat/uniform* (100 words are equally plausible), $k = 50$ unfairly cuts off half of the valid options.

4. *Top-$p$ / Nucleus Sampling (Dynamic Truncation)*:
  Solves the rigidity of Top-$k$ by dynamically selecting the *smallest set of top-ranked tokens $V^((p)) subset V$ whose cumulative probability mass exceeds a threshold $p$* (e.g., $p = 0.90$):
  $
    sum_(w in V^((p))) P(w | w_(<t)) >= p
  $
  The distribution is then re-normalized over $V^((p))$. Thus, the size of the sampling pool automatically shrinks when the model is confident and expands when multiple continuations are plausible.

=== Temperature Scaling ($T$)

Instead of truncating the support of the distribution, *Temperature ($T > 0$)* reshapes the probability distribution by dividing the raw logits $bold(u)$ before applying the softmax:
$
  P_T (w_i | w_(<t)) = ("exp"(u_i \/ T)) / (sum_(j in V) "exp"(u_j \/ T))
$
- *$T = 1$*: leaves the original softmax distribution unchanged.
- *Low Temperature ($T arrow.r 0^+$, e.g., $T = 0.2$)*: amplifies differences between logits, *sharpening* the distribution so almost all probability mass concentrates on the top token (approaching deterministic greedy decoding; ideal for factual tasks or conservative protein design).
- *High Temperature ($T > 1$)*: dampens differences between logits, *flattening* the distribution toward a uniform distribution (increasing entropy, diversity, and "creativity" to explore novel sequence states).

== Training Lifecycle of an LLM: Pre-Training, Fine-Tuning & Alignment

Building a modern LLM involves three distinct stages:
1. *Self-Supervised Pre-Training*
2. *Domain Continued Pre-Training / Supervised Fine-Tuning (SFT)*
3. *Preference Alignment (RLHF)*.

=== Self-Supervised Pre-Training & Teacher Forcing

During pre-training, the Transformer is trained on massive unlabeled corpora (billions of web pages or millions of genomes/proteins from UniProt) using *Self-Supervised Learning*: the *labels are intrinsic* to the sequence itself, as every token $w_(t+1)$ serves as the ground-truth target for the prefix $w_(1..t)$.

At each position $t$, the network outputs a predicted probability vector $hat(bold(y))_t = "softmax"(bold(u)_t) in [0, 1]^(|V|)$, which is compared against the one-hot ground-truth vector $bold(y)_t$ ($y_t [w] = 1$ if $w = w_(t+1)$, and $0$ otherwise) via the *Categorical Cross-Entropy (Negative Log-Likelihood) Loss*:
$
  cal(L)_"CE" (hat(bold(y))_t, bold(y)_t) = - sum_(w in V) y_t [w] log hat(y)_t [w] = - log hat(y)_t [w_(t+1)] = - log P_theta (w_(t+1) | w_1, dots, w_t)
$

#figure(
  caption: [Behavior of the Negative Log-Likelihood loss $cal(L) = -log P$ as a function of the probability $P$ assigned to the true next token $w_(t+1)$. When $P = 1$, the loss is $0$; as $P arrow.r 0^+$, the penalty explodes to $+infinity$.],
)[
  #align(center)[
    #cetz.canvas(length: 0.9cm, padding: 0.2cm, {
      import cetz.draw: *

      // Axes
      line((0, 0), (7.5, 0), mark: (end: ">", fill: black), stroke: 1pt + black)
      line((0, 0), (0, 4.5), mark: (end: ">", fill: black), stroke: 1pt + black)

      content((7.5, -1.05), anchor: "east", text(
        size: 8.5pt,
      )[Predicted probability for true token $P(w_(t+1)) arrow.r$])
      content((-0.3, 4.3), anchor: "east", text(size: 8.5pt)[Loss $-log(P)$])

      // Ticks
      line((6.5, -0.1), (6.5, 0.1), stroke: 1pt + black)
      content((6.5, -0.35), text(size: 8pt)[$1.0$])
      line((0.65, -0.1), (0.65, 0.1), stroke: 1pt + black)
      content((0.65, -0.35), text(size: 8pt)[$0.1$])
      content((-0.25, 0), text(size: 8pt)[$0$])

      // Curve -ln(x) scaled: x in [0.05, 1.0] mapped to X = 6.5 * x, Y = -ln(x) * 1.3
      let pts = ()
      for i in range(5, 101, step: 5) {
        let p = i / 100.0
        let x = 6.5 * p
        let y = -calc.ln(p) * 1.3
        pts.push((x, y))
      }
      line(..pts, stroke: 1.8pt + teal)

      // Highlight point at P = 0.1 -> -ln(0.1) = 2.30
      let px = 0.65
      let py = 2.3025 * 1.3
      line((px, 0), (px, py), stroke: (dash: "dashed", paint: gray))
      line((0, py), (px, py), stroke: (dash: "dashed", paint: gray))
      circle((px, py), radius: 0.12, fill: orange, stroke: 1pt + black)
      content((px + 0.2, py + 0.2), anchor: "west", text(
        size: 8pt,
        weight: "bold",
        fill: orange.darken(20%),
      )[$(P = 0.1, "Loss" = 2.30)$])
    })
  ]
]

- *Teacher Forcing*: during training, if we fed the model's *own predicted token* $hat(w)_(t+1)$ as input to step $t+2$, a single early mistake would compound and derail the entire remaining sequence (*exposure bias*). Instead, we use *Teacher Forcing*: we compute the loss on the model's prediction $hat(bold(y))_t$, but at step $t+1$ we always feed the *true ground-truth history* $(w_1, dots, w_(t+1))$ from the training corpus.

  #note()[
    Because the entire ground-truth sequence is known beforehand, Teacher Forcing enables parallel training across all $T$ positions simultaneously via the causal mask.
  ]


- *Distributional Learning*: a natural prefix (e.g., `"The cat is on the..."`) has many valid continuations (`"mat"`, `"roof"`, `"sofa"`). By minimizing the average cross-entropy loss across billions of training contexts via Stochastic Gradient Descent, the model weights converge to output the true underlying conditional probability distribution of the data.

=== Continued Pre-Training and Supervised Fine-Tuning (SFT)

Once a base LLM is pre-trained on general data, we specialize it for specific domains or tasks (typically using open-weight models like LLaMA, Mistral, or ProtGPT2, since proprietary models restrict weight access):
1. *Continued Pre-Training (Domain Adaptation)*: taking the pre-trained base model and continuing self-supervised next-token prediction on a domain-specific unlabeled corpus (e.g., biomedical PubMed articles or a specific family of thermostable enzymes) to shift its internal knowledge distribution.
2. *Supervised Fine-Tuning (SFT / Instruction Tuning)*: adapting some (e.g., via *Adapters / LoRA*, updating only $1$–$3%$ of weights while freezing the backbone) or all parameters on curated labeled pairs of $("Instruction/Prompt" x, "Target Output" } y)$, teaching the model to follow task formatting or generate sequences matching desired functional tags.


== Evaluation of LLMs: Perplexity and Scaling Laws

=== Mathematical Derivation of Perplexity (PPL)

#informally()[
  *Perplexity (PPL)* measures how "surprised" or uncertain a language model is when predicting a test sequence. Intuitively, a perplexity of $k$ means that at each step, the model is as uncertain as if it had to choose *uniformly at random* among *$k$ equally likely* tokens.
]

Given a test sequence of $N$ tokens $W = (w_1, w_2, dots, w_N)$, its joint probability under model parameters $theta$ is given by the chain rule:
$
  P_theta (w_1, w_2, dots, w_N) = product_(i=1)^N P_theta (w_i | w_(<i))
$
Because multiplying ratusan of probabilities in $[0, 1]$ causes numerical *floating-point underflow* and depends heavily on sequence length $N$ (longer sequences always have smaller raw probabilities), we define *Perplexity* as the *inverse geometric mean* of the predicted token probabilities (normalized by length $N$):
$
  "PPL"_theta (W) = P_theta (w_1, w_2, dots, w_N)^(-1 / N) = root(N, 1 / (product_(i=1)^N P_theta (w_i | w_(<i)))) = (product_(i=1)^N P_theta (w_i | w_(<i)))^(-1 / N)
$
Using the identity $a = exp(ln a)$ (or base-$2$ exponentiation $2^(log_2 a)$), we convert the product into a sum of log-probabilities, linking Perplexity directly to the average *Negative Log-Likelihood (NLL) / Cross-Entropy Loss* $L_"CE"$:
$
  "PPL"_theta (W) &= exp(ln[(product_(i=1)^N P_theta (w_i | w_(<i)))^(-1 / N)]) \
  &= exp(-1/N ln(product_(i=1)^N P_theta (w_i | w_(<i)))) \
  & mb("using" ln(product) = sum(ln)) \
  &= exp(underbrace(- 1 / N sum_(i=1)^N ln P_theta (w_i | w_(<i)), "Average NLL / Cross-Entropy " cal(L)_"CE")) = exp(cal(L)_"CE") = e^(cal(L)_"CE")
$
#note()[
  If base-$2$ logarithms are used to measure cross-entropy $H(W)$ in bits per token:
  $
    "PPL"(W) = 2^(H(W))
  $
]

Key properties of Perplexity:
- *Range*: $"PPL" in [1, +infinity)$. A perfect model that assigns probability $1.0$ to every true token achieves $"PPL" = 1^((-1/N)) = 1$.
- *Equivalence to Training Loss*: because $e^(dot)$ is a strictly monotonically increasing function, *minimizing Perplexity is mathematically equivalent to minimizing Cross-Entropy Loss (NLL) and maximizing the data likelihood*.

#example(title: "Perplexity under Complete Uncertainty (Uniform Distribution)")[
  Suppose a model has no idea which token comes next over a vocabulary of size $K$, assigning a uniform probability $P(w_i | w_(<i)) = 1 / K$ at every step $i = 1, dots, N$. Its perplexity is:
  $
    "PPL" = ((1 / K)^N)^(-1 / N) = (1 / K)^(-1) = K
  $
  Thus, maximum uncertainty yields a perplexity equal to the vocabulary size $K$:
  - For a *DNA nucleotide model* ($K = 4$: $"A", "C", "G", "T"$), a random guessing model has $"PPL" = 4$.
  - For a *canonical amino acid protein model* ($K = 20$), a random model has $"PPL" = 20$.
]

#warning(title: "Perplexity is strictly tokenization-dependent")[
  We *cannot directly compare the perplexity of two models* that use different vocabularies or tokenizers (e.g., a character-level model vs. a 50,000-token BPE model), because predicting a single character over a tiny alphabet is statistically much easier (lower PPL) than predicting a full word over a huge vocabulary.
]

=== Neural Scaling Laws and Parameter Counting

Empirical studies demonstrated that the test Cross-Entropy loss $L$ of a Transformer scales predictably as a *power law* with respect to three fundamental factors: the number of *non-embedding model parameters $N$*, the *training dataset size $D$* (in tokens), and the *compute budget $C$* (in FLOPs):
$
  L(N, D) = E + A / N^alpha + B / D^beta
$
where:
- $E$ is the irreducible entropy of natural data
- $alpha, beta$ are empirical scaling exponents. To train a *compute-optimal* LLM for a fixed FLOP budget $C approx 6 N D$, model size $N$ and dataset size $D$ must be scaled up in tandem.

= From Input Tokens to Contextual Representations

Formally, the Transformer solves sequence-to-sequence ($a = [a_1, dots, a_n] arrow.r t = [t_1, dots, t_m]$) and autoregressive modeling tasks through five architectural pillars:
1. *Input Representation*: Subword Tokenization, Embedding Lookup, and Positional Encoding.
2. *Self-Attention*: $O(1)$ path-length contextualization across arbitrary sequence distances.
3. *Encoder Block*: Bidirectional feature extraction (`MHA` + `FFN` + `Add & Norm`).
4. *Decoder Block*: Masked causal self-attention + Encoder-Decoder cross-attention.
5. *Output Projection and Optimization*.

== Why Attention Replaces Recurrence (RNNs vs. Transformers)

In *Recurrent Neural Networks (RNNs)*, the hidden state $h_t = f(theta_(h h)^T h_(t-1) + theta_(x h)^T x_t)$ is computed sequentially step-by-step. This sequential bottleneck introduces two critical flaws:
1. *No Parallelization*: step $t$ cannot be computed until step $t-1$ finishes.
2. *Path Length $O(|i - j|)$ and Vanishing/Exploding Gradients*: for token $i$ to interact with token $j$, information must traverse $|i - j|$ recurrent steps. During *Backpropagation Through Time (BPTT)*, repeatedly multiplying by $theta_(h h)$ causes gradients to either vanish ($< 1$) or explode ($> 1$), inducing severe *recency bias*.

*Self-Attention resolves both issues*: every pair of positions $(i, j)$ interacts directly in a *path length of $O(1)$* via dot-product similarity.

#example()[
  *Simplified Parameter-Free Self-Attention* \
  Given a sequence of input token embeddings $bold(x)_1, bold(x)_2, dots, bold(x)_n$, we can compute a contextualized representation $bold(a)_i$ for position $i$ as a weighted sum of all embeddings up to $i$, weighted by their dot-product similarity to $bold(x)_i$:
  $
    "score"(bold(x)_i, bold(x)_j) = bold(x)_i dot bold(x)_j, quad alpha_(i j) = ("exp"("score"(bold(x)_i, bold(x)_j))) / (sum_(k <= i) "exp"("score"(bold(x)_i, bold(x)_k))), quad bold(a)_i = sum_(j <= i) alpha_(i j) bold(x)_j
  $
  Introducing the learnable projection matrices $(W^Q, W^K, W^V)$ makes this mechanism flexible and asymmetric.
]

== Input Representation: Tokenization, Embeddings, and Positional Encoding

=== Subword Tokenization: Byte-Pair Encoding (BPE) & WordPiece

Before feeding a sequence into a Transformer, raw text (or biological strings) must be segmented into discrete units from a finite vocabulary $V$:
- *Word-level tokenization* creates an enormous vocabulary $|V|$ and fails completely on unseen *Out-Of-Vocabulary (OOV)* words.
- *Character-level tokenization* has a tiny vocabulary (no OOVs), but produces extremely long sequences where individual characters carry almost no semantic meaning, exploding the $O(n^2)$ attention memory cost.

Modern LLMs use a *learning-based middle ground: Subword Tokenization* (such as *Byte-Pair Encoding (BPE)* in GPT or *WordPiece* in BERT). The core principle is that *frequent words are kept as single whole tokens, while rare or unknown words are decomposed into frequent meaningful subwords* (roots, prefixes, suffixes, or conserved peptide motifs):
1. *Initialization*: start with an initial vocabulary $V$ consisting of all individual base characters in the corpus.
2. *Iterative Pair Merging*: count all adjacent symbol pairs $(A, B)$ in the corpus and merge the pair with the highest frequency (in *BPE*) or the highest likelihood score $"Score"(A, B) = "Freq"(A, B) / ("Freq"(A) dot "Freq"(B))$ (in *WordPiece*) into a new single symbol $A B$, adding it to $V$.
3. *Termination*: repeat until the target vocabulary size $|V|$ is reached (e.g., $30,522$ in BERT or $50,257$ in GPT-2).

#example(title: "Byte-Pair Encoding (BPE) Step-by-Step Trace")[
  Suppose our training corpus contains the words `{"low": 5, "lower": 2, "newest": 6, "widest": 3}`:
  - *Initial character vocabulary*: `{"l", "o", "w", "e", "r", "n", "s", "t", "i", "d"}`.
  - *Iteration 1*: the most frequent adjacent character pair is `("e", "s")` (appearing $6 + 3 = 9$ times in `newest` and `widest`). We merge them into the new subword token `"es"`.
  - *Iteration 2*: the pair `("es", "t")` now appears $9$ times. We merge it into `"est"`.
  - *Iteration 3*: the pair `("l", "o")` appears $5 + 2 = 7$ times, merged into `"lo"`, and then `("lo", "w")` is merged into `"low"`.
  - *At Inference Time*: if the model encounters the unseen word `"lowest"` (OOV), it does not fail; it splits it into known subwords `["low", "est"]`, preserving both the root semantics (`"low"`) and the superlative suffix (`"est"`)!
]

=== Token Embeddings and Positional Encoding

1. *Token Embedding Lookup*: given a vocabulary $A$ (of size $|V|$), the embedding layer defines a learnable lookup mapping $e: A arrow.r E subset RR^d$ parameterized by an embedding matrix $bold(E) in RR^(|V| times d_"model")$. A sequence of $n$ token IDs is mapped to a matrix $X_"emb" in RR^(n times d_"model")$, whose weights are optimized jointly via backpropagation.

2. *Positional Encoding*: because Self-Attention processes all tokens in parallel without recurrence or convolution, it is inherently *permutation-equivariant* (without positional information, it collapses to a Bag-of-Words and cannot distinguish `"The dog bites the man"` from `"The man bites the dog"`). To inject sequence order, a *Positional Encoding vector* $"PE"_"pos" in RR^(d_"model")$ is added element-wise to each token embedding:
  $
    X_"input" = X_"emb" + "PE"
  $
  In the original Transformer, $"PE"$ uses deterministic *sine and cosine functions of varying wavelengths* across even ($2 i$) and odd ($2 i + 1$) embedding dimensions:
  $
    "PE"_("pos", 2 i) = sin("pos" / 10000^((2 i) / d_"model")), quad "PE"_("pos", 2 i + 1) = cos("pos" / 10000^((2 i) / d_"model"))
  $
  This formulation keeps values bounded in $[-1, 1]$ and allows the model to easily attend to relative positions since $"PE"_("pos"+k)$ can be written as a linear function of $"PE"_"pos"$.
