#import "../template.typ": *

Gli LLM interpretano e analizzano l'interazioni tra sequenze di proteine distanti anni luce dalla linea evolutiva corrente, posso quindi essere utilizzati per creare l'uso di proteine sintetiche, che non esistono in natura, ma che possono essere progettate per avere proprietà specifiche.


Another application is AlphaFOld: given a sequence of amino acids, we want to predict the 3D structure of the protein that will be formed by that sequence. This is a very important problem in biology, because the 3D structure of a protein determines its function. AlphaFold uses deep learning to predict the 3D structure of proteins with high accuracy, and it has been a breakthrough in the field of structural biology. Since this operation in the past it was very expensive and time-consuming (months of labolatory work)

La multihead è necessaria in quanto altrimenti non potremmo modellare un token con diversi significati in base al contesto in cui è inserito. Ad esempio, la parola "apple" può significare sia il frutto che l'azienda, e la multihead permette di catturare queste diverse sfumature di significato.

Il risultato delle varie teste di attention vien poi combinato tramite una rete neurale feedforward, che permette di ottenere una rappresentazione finale del token che tiene conto di tutti i diversi significati catturati dalle varie teste di attention.

= Non-Coding RNA LLM

An RNA is composed of 4 nucleotides: A, C, G, U. Analizing all of them are impossible, we have too many possible combinations. Have the sampe problem of the protein space even if the combination are less (proteins have 20 amino acids, RNA has 4 nucleotides).

The solution is to treat the RNA sequence as a language, and use LLM to analyze it. The LLM can learn the grammar of the RNA language, and can generate new RNA sequences that are likely to be functional.

#note()[
  A single sequence of RNA can fold into many different structures, and the structure determines the function.
]

RNA comes from DNA, and proteins are made from mRNA. RNA that are not messanger have some function, and they are called non-coding RNA. Non-coding RNA can be used to regulate gene expression, and they can also be used as therapeutic targets.

== Project interaction

The goal is to predict the interation of two non-coding RNA sequences. Given two sequences of RNA, we want to predict if they will interact with each other, and if so, what will be the structure of the complex that they will form.

Methods:
- We use a model to generate the embeddings of the two sequences.
- We concatenate the embeddings of the two sequences, and feed them to a neural network that will predict the interaction.
- We train a neural network to predict the interaction based on the embeddings of the two sequences.

=== RNA-FM Model
//riguardare

ncRNA are trained on the RNA-FM model, which is a transformer model that has been trained on a large dataset of RNA sequences. They are only a encoder model. The maximum input sixe is $1022$ Nucleotides, and the output is a vector of size $640$ that represents the embedding of the input sequence.

birNA-NERT is different because it as two different component expect of RNA-FM:
- ALbi: given a sequence of RNA with an arbitrary length, it generates a fixed-size embedding of the sequence.
- Dual tokenization: We use a model where each nucleatide is represented by an embedding. And we also use BPE, a set of nucleotides will be encoded as a single token. This allows the model to capture the local context of the sequence, and to generate embeddings that are more informative.

birNA-BERT create embedding more clustered and differientiated that RNA-FM.

We use both of them and we can compare it. We use a single nuclueotide tokenization because we have a small sequence lenght. This affect the performance of the model, because the sel-attention scale quadratically with the input length, and we have a small sequence length.

These model use the same architecture of BERT (classical encoder only transformer).

==== Max and AVG pooling

If we have a lenght of $3$ nucleotides `AUG`, we have a token for each nucleotide. He have a embedding matriz of size $3 times 640$.

We can use the maximum pooling to get the maximum value of the row. THe same with the avarage pooling. This is usefull if we have a sequence of different lenght, we can use the pooling to get a fixed size embedding of the sequence. By pooling on the row, we have the same size embedding for all the token even if the sequence lenght is different. If we pull on the column, we have a fixed size embedding for each nucleotide, but we have a different size embedding for each sequence.

#note()[
  We use both in this project we concatanate them
]

For the project we need to choose a dataset. There is interaction with multiple rna-type.

Random negative are easy to classify

=== Data agumentation

For each given pair we perfomed:
- Original pair
- Reverse pair (B,A)
- sequence flipping (A^F, B^F)
- combined (B^f, A^f)
A^f is read backwords (3' to 5') not the reverse complement. The reverse complement is the sequence that is complementary to the original sequence, and it is read in the opposite direction (5' to 3'). The reverse complement is used in DNA, but not in RNA.

We performed an avarage of this data agumentation, and we have a final dataset of $4$ times the original dataset.
