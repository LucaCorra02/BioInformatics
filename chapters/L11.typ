#import "../template.typ": *

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

