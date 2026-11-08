#import "../template.typ": *

= Large Language Models for Protein Design and Modeling

== Proteins as a Language: The Analogy and Its Limits

Over the last few years, Large Language Models (LLMs) such as GPT-4 have revolutionized Natural Language Processing (NLP), showing an unprecedented ability to generate, translate, and reason over human text. Because proteins are *linear chains of amino acids*, they share deep structural and functional parallels with written language. This raises a fundamental question in computational biology: *can the same Transformer architectures learn to read, understand, and write biological proteins?*

=== The Linguistic Analogy

We can map the hierarchical organization of human language directly onto the structural hierarchy of proteins:

#table(
  columns: (1fr, 1.5fr),
  align: (left + horizon, left + horizon),
  stroke: 0.5pt + gray,
  inset: 7pt,
  [*Natural Language*], [*Protein Language*],
  [Letters of the alphabet], [*20 canonical amino acids* (the basic building blocks)],
  [Words & syntactic structures],
  [*Motifs & domains* (short conserved sequence patterns and independent functional/structural units)],

  [*A complete sentence*], [*A full amino acid sequence* (polypeptide chain)],
  [*A text composed of multiple sentences*],
  [*Quaternary structure* (complexes formed by multiple interacting protein chains)],

  [*A typo alters the meaning of a sentence*],
  [*A single point mutation causes disease* (e.g., a single amino acid substitution in hemoglobin causes sickle-cell anemia)],
)

Despite these strong similarities, biological sequences *differ* from human text in four crucial ways:
1. *No clear word boundaries*: in written text, words are cleanly separated by spaces and punctuation. In a protein sequence, there are no spaces; we rarely know *a priori* where a functional motif or domain starts and ends, and motifs can overlap or span discontinuous regions.
2. *A much smaller alphabet*: human vocabularies contain tens of thousands of words, whereas standard proteins are written using an alphabet of only *20 canonical amino acids* (without punctuation marks).
3. *Post-translational modifications (PTMs)*: after a protein is translated, chemical groups (such as methylation, phosphorylation, or glycosylation) are attached to specific residues, adding a layer of biological complexity that is not explicitly written in the raw primary sequence.
4. *Different evolutionary dynamics*: human grammar is shaped by social convention within a single species, whereas protein "grammar" is governed by physical laws (thermodynamics, 3D folding) and *natural selection*, and must generalize across millions of different species.

#note()[
  Even with these differences, the structural parallels (especially the presence of *short-range motifs* and *long-range dependencies* between distant amino acids) are strong enough to justify adapting NLP architectures to proteins.
]

== Transformers, BERT, and GPT

=== The Transformer Architecture and Self-Attention

The Transformer is the foundational building block of modern LLMs and relies on four key properties:
- *Self-supervised learning*: trains on massive unlabeled corpora by predicting masked or upcoming tokens, requiring no manual human annotations.
- *Attention-based context*: uses *Self-Attention* to relate every element in a sequence to every other element directly, regardless of their distance along the sequence.
- *Massive parallelism*: unlike RNNs (which process tokens sequentially one step at a time), Transformers process the entire sequence simultaneously on GPUs.
- *Transferability*: a single pre-trained foundation model can be fine-tuned for a wide variety of downstream tasks.

Architecturally, the original Transformer consists of two stacks of $N$ blocks:
1. *Encoder ($times N$ blocks)*: receives the input tokens, applies bidirectional *Self-Attention* and a *Feed-Forward Network (FFN)*, and outputs a contextualized *encoded representation* that feeds into every block of the Decoder.
2. *Decoder ($times N$ blocks)*: receives the output tokens generated so far, applies *Masked Self-Attention*, *Cross-Attention* (attending to the Encoder output), and an *FFN* to output next-token probabilities.

#note(title: "Why Self-Attention is Crucial for Proteins")[
  In the sentence `"The protein folds because it is stable"`, self-attention allows the word `"folds"` to weigh and blend information from every other word in the sentence. In a protein, two amino acids that sit *hundreds of positions apart* along the 1D linear sequence may fold right next to each other in 3D space to form an active site or a stabilizing bond. *Self-attention* naturally *captures these long-range 3D contacts directly from the 1D sequence*.
]

=== BERT vs. GPT

From the original Transformer, two specialized families emerged:

1. *BERT (Bidirectional Encoder Representations from Transformers)*:
  - *Architecture*: an *Encoder-only* stack (`Self-Attention` + `FFN`).
  - *Bidirectional context*: unlike left-to-right models, BERT reads the *entire sequence at once* in both directions (left and right context simultaneously).
  - *Pre-training tasks*:
    - *Masked Language Modeling (MLM)*: randomly masks $approx 15%$ of the input tokens with a `[MASK]` token and trains the network (via Cross-Entropy loss) to predict the original masked tokens from the surrounding bidirectional context.
    - *Next Sentence Prediction (NSP)*: given two sequences separated by `[SEP]` and prefixed with a `[CLS]` token, predicts via binary cross-entropy whether the second sequence naturally follows the first. Usually these prhases are implications.
  - *Output and use case*: produces a rich *contextual embedding vector* for each token (and an aggregated sequence vector at `[CLS]`), ready for downstream classification, regression, similarity search, or fine-tuning.

2. *GPT (Generative Pre-trained Transformer)*:
  - *Architecture*: a *Decoder-only* stack (`Masked Self-Attention` + `FFN`).
  - *Autoregressive & Left-to-Right*: uses causal masked self-attention so each token can only attend to *previous tokens* (left context only). It predicts a probability distribution over the vocabulary for the next token, one step at a time.
  - *Generative loop*: by sampling a token from the predicted distribution, appending it to the input sequence, and repeating the process, GPT writes completely new, coherent sequences.
  - *Scaling*: scaled from $1.5$B parameters (GPT-2) to $175$B (GPT-3) and well over $100$B+ parameters (GPT-4).

== Protein Language Models (pLMs): The Three Families

By replacing the natural language vocabulary with the alphabet of amino acids and training on massive, unlabeled protein databases such as *UniProt* and *UniParc*, researchers developed *Protein Language Models (pLMs)*. Through self-supervised learning, these models learn residue-residue interactions via self-attention and long-range structural context by stacking deep Transformer layers.

Just like in NLP, pLMs are divided into *three architectural families*:
1. *Encoder-based models* (for protein representation and property prediction).
2. *Decoder-based models* (for *de novo* and conditional protein generation).
3. *Encoder-Decoder models* (for biomolecular translation between proteins, drugs, and chemical reactions).

=== Encoder-Based Protein Language Models

Encoder-only pLMs (modeled after BERT) take an *amino acid sequence as input*, pass it through a deep bidirectional Transformer encoder, and output a dense *embedding vector* (per residue or per whole protein) that is fed into downstream machine learning models.

Representative Encoder pLMs include:
- *ESM (Evolutionary Scale Modeling)*: a 33-layer Transformer encoder trained via Masked Language Modeling on $250$ million protein sequences. Even without any multiple sequence alignments (MSAs) or structural supervision, the *internal representations* learned by ESM naturally *capture evolutionary relationships*, secondary/tertiary structure, and biophysical properties of amino acids.
- *TAPE (Tasks Assessing Protein Embeddings)*: a standardized benchmark and embedding suite evaluating protein transfer learning across structure prediction, contact map estimation, remote homology, and stability/fluorescence landscapes.
- *ProteinBERT*: a specialized architecture that jointly pre-trains on raw amino acid sequences alongside *Gene Ontology (GO)* functional annotations, learning a unified representation of sequence and biological function.

==== Applications of Encoder pLMs

Once pre-trained, the embeddings extracted from Encoder pLMs enable four major downstream tasks:
1. *3D Structure and Contact Prediction*: predicting which amino acid residues sit close to each other in the folded 3D structure (contact maps) and secondary structure elements using *only* the primary sequence as input.
2. *Mutational Effect Prediction*: estimating how a single amino acid substitution (missense mutation) alters protein stability, binding affinity, or pathogenicity. By feeding both the wild-type (natural) sequence and the mutated sequence into the encoder, a downstream classifier or regressor (or zero-shot log-odds score) predicts the functional impact of the variant.
3. *Remote Homology Detection & Fold Classification*: identifying distant evolutionary relatives that share the same 3D fold and function even when their raw sequence similarity has diverged beyond recognition by traditional alignment tools (like BLAST).
4. *In Silico Antibody Evolution*: using ESM likelihoods to suggest high-probability point mutations in human antibodies. In wet-lab experiments, ESM-guided evolution successfully improved antibody binding affinity and neutralization potency against *Ebola* and *SARS-CoV-2* with very few experimental rounds.

=== Decoder-Based Generative Protein Language Models

Decoder-only pLMs (modeled after GPT) are trained autoregressively to *predict the next amino acid* given the preceding sequence prefix. During inference, they generate novel proteins *one residue at a time*:

#figure(
  caption: [Autoregressive residue-by-residue protein generation in a Decoder pLM.],
)[
  #align(center)[
    #cetz.canvas(length: 0.85cm, padding: 0.2cm, {
      import cetz.draw: *

      // Step 1
      let seq1 = ("M", "K", "T", "A")
      for (i, aa) in seq1.enumerate() {
        rect((i * 1.0, 1.8), (i * 1.0 + 0.8, 2.6), fill: gray.lighten(85%), stroke: 0.8pt + gray)
        content((i * 1.0 + 0.4, 2.2), text(weight: "bold", size: 9.5pt)[#aa])
      }
      line((4.0, 2.2), (4.8, 2.2), mark: (end: ">", fill: black))
      rect((4.8, 1.7), (7.2, 2.7), fill: teal.darken(10%), stroke: 1pt + black, radius: 0.1)
      content((6.0, 2.2), text(fill: white, weight: "bold", size: 9.5pt)[Decoder])
      line((7.2, 2.2), (8.0, 2.2), mark: (end: ">", fill: black))
      rect((8.0, 1.8), (9.0, 2.6), fill: orange.lighten(20%), stroke: 1pt + orange.darken(20%))
      content((8.5, 2.2), text(weight: "bold", size: 9.5pt)[Y ?])

      content((4.5, 1.15), text(
        size: 8.5pt,
        style: "italic",
        fill: gray.darken(40%),
      )[Predicted residue "Y" is sampled, appended to the prompt, and the loop repeats:])

      // Step 2
      let seq2 = ("M", "K", "T", "A", "Y")
      for (i, aa) in seq2.enumerate() {
        let col = if i == 4 { orange.lighten(30%) } else { gray.lighten(85%) }
        rect((i * 1.0, 0.0), (i * 1.0 + 0.8, 0.8), fill: col, stroke: 0.8pt + gray)
        content((i * 1.0 + 0.4, 0.4), text(weight: "bold", size: 9.5pt)[#aa])
      }
      line((5.0, 0.4), (5.8, 0.4), mark: (end: ">", fill: black))
      rect((5.8, -0.1), (8.2, 0.9), fill: teal.darken(10%), stroke: 1pt + black, radius: 0.1)
      content((7.0, 0.4), text(fill: white, weight: "bold", size: 9.5pt)[Decoder])
      line((8.2, 0.4), (9.0, 0.4), mark: (end: ">", fill: black))
      rect((9.0, 0.0), (9.8, 0.8), fill: orange.darken(10%), stroke: 1pt + black)
      content((9.4, 0.4), text(fill: white, weight: "bold", size: 9.5pt)[...])
    })
  ]
]

==== Unconditional De Novo Generation: ProtGPT2 and DARK
- *ProtGPT2*: based on the GPT-2 architecture ($738$M parameters) and trained on $approx 50$ million sequences from UniProtKB. ProtGPT2 generates *de novo protein sequences* that exhibit natural amino acid propensities, fold into stable globular structures, and—most importantly—explore *uncharted regions of the evolutionary sequence space* that natural evolution has not yet sampled. The generated proteins may have the same function as natural proteins, but they can differ in sequence and structure, opening the door to *novel protein engineering*.

- *DARK*: a $110$M-parameter decoder trained on *synthetic* (rather than natural) sequences to design stable, well-ordered *de novo* protein structures validated via *AlphaFold2*.

#note()[
  Generation and representation are *not mutually exclusive*: both ProtGPT2 and DARK can also repurpose the hidden vectors from their final decoder layer as fixed-size embeddings for downstream predictive tasks.
]

==== Conditional Generation: Designing Proteins for a Target Function (ProGen & IgLM)

Unconditional models like ProtGPT2 generate plausible proteins at random, but in bioengineering we usually want to design a protein with a *specific desired function*.

#example()[
  We want to desing a specific enzyme that degrades environmental pollutants or captures atmospheric $"CO"_2$, or an antibody targeting a specific virus
]

1. *ProGen*:
  - A $1.2$B-parameter conditional Transformer decoder trained on $280$M protein sequences prepended with *functional control tags ($f$)*: such as *Gene Ontology (GO) terms*, *Pfam protein family IDs*, taxonomic organism tags, or catalytic/binding properties.
  - Instead of modeling $P(a_1, dots, a_L)$ unconditionally, ProGen learns *the conditional distribution*:
    $
      P(a_1, dots, a_L | f) = product_(i=1)^L P(a_i | a_(<i), f)
    $
  - *Point of control*: at inference time, researchers specify a functional tag $f$ (e.g., `"kinase activity"` or `"lysozyme"`), optionally along with an *$N$-terminal sequence context*, and the decoder generates brand-new protein sequences tailored to perform that exact function. Wet-lab experiments confirmed that ProGen-designed artificial lysozymes folded properly and matched the catalytic activity of natural enzymes even with low sequence identity to any known protein.

2. *IgLM (Immunoglobulin Language Model)*:
  - Applies the same conditional-generation paradigm to *antibody engineering*. Trained on $approx 0.5$ billion antibody heavy and light-chain sequences, IgLM conditions generation on the *species of origin* (e.g., human, mouse) and *chain type* to design diverse, human-compatible therapeutic antibody libraries against chosen targets.

=== Encoder-Decoder Models (Biomolecular Translation)

Just as an NLP Encoder-Decoder translates a sentence from Italian to English, biomolecular Encoder-Decoder models *translate between different molecular modalities*:

1. *Translating Target Proteins into Drug Ligands*:
  - *Input to Encoder*: the amino acid sequence of a *disease-related* target *protein* (receptor).
  - *Output from Decoder*: a novel small-molecule *drug* (ligand) capable of binding and inhibiting that target protein, generated character-by-character in *SMILES* (Simplified Molecular-Input Line-Entry System) chemical notation.
  - *Reverse translation*: the architecture can also be run in reverse—starting from a given chemical ligand in the Encoder to generate a candidate *protein binder* in the Decoder, opening a direct path toward *in silico de novo* drug discovery.

2. *Designing Catalyzing Enzymes from Chemical Reactants*:
  - Adapting IBM's chemical-reaction Transformers (originally built to predict reaction products from reactants), the Encoder reads the *chemical reactants* of a desired biochemical reaction, and the Decoder generates the amino acid sequence of a *catalyzing enzyme* capable of driving that reaction.
  - *Applications*: extends beyond pharmacology into green chemistry and environmental health (such as designing novel enzymes to break down plastic waste, toxic industrial pollutants, or greenhouse gases).

== Recent Advances (Beyond 2023): ESM-2, ProGen2/3, and ESM3

Following the 2023 review, Protein Language Models have scaled dramatically in both parameter count and multimodality:
- *ESM-2*: scaled the bidirectional ESM encoder family up to *$15$ billion parameters*. Paired with a folding head (*ESMFold*), ESM-2 achieved atomic-level, single-sequence 3D structure prediction (without needing slow Multiple Sequence Alignments), representing the encoder line's answer to GPT-scale training.
- *ProGen2 & ProGen3*: scaled conditional autoregressive protein generation from $1.2$B parameters up to *$6.4$B (ProGen2)* and *$46$B parameters (ProGen3)*, trained on over a billion genomic and metagenomic sequences.
- *ESM3*: a frontier *multimodal generative language model* scaled up to *$98$ billion parameters*. Unlike previous models that only read 1D sequences, ESM3 tokenizes and unifies *three distinct modalities*: *1D sequence*, *3D atomic structure* and *biological function* into a single shared discrete token space. By conditioning on structural and functional coordinates, ESM3 was used to generate a functional *novel green fluorescent protein (esmGFP)* equivalent to simulating over $500$ million years of natural evolution.

== Open Challenges and Future Directions

Despite their breakthroughs, pLMs face three major open challenges before they can be safely and routinely deployed in clinical and industrial pipelines:

=== The Interpretability and Explainability Problem

When a pLM designs a novel therapeutic protein or drug molecule for human use, *black-box predictions are unacceptable*: we need both *global explanations* (understanding the general biophysical rules learned by the model) and *local explanations* (why a specific residue or drug atom was chosen for a specific patient or target). Three complementary directions are currently used:
- *Post-hoc model-agnostic methods*: applying *LIME*, *Anchors*, or *SHAP* (Shapley Additive Explanations) after training to quantify how much each input amino acid or motif contributes to the final prediction.
- *Attention visualization*: interactive inspection tools like *exBERT* and *BertViz* reveal that specific attention heads autonomously learn to track 3D contact maps, binding sites, and evolutionary conservation across layers.
- *Automated neuron interpretation ("A model explaining a model")*: following OpenAI's approach of using GPT-4 to inspect and explain the activation patterns of individual neurons inside another LLM, researchers are beginning to map internal pLM neurons to human-readable biological concepts.

=== The Computational Cost of Scale and Model Compression
Training pLMs with $15$B to $98$B parameters requires massive GPU clusters and high-bandwidth VRAM that most academic and hospital laboratories do not possess.
- *Model Compression*: techniques such as *Pruning* (removing redundant weights), *Quantization* (reducing floating-point precision, e.g., from `FP32`/`FP16` down to `INT8` or `INT4`), and *Knowledge Distillation* (training a compact student model to mimic a massive teacher pLM) have been shown in benchmark experiments to shrink model size by up to *$100 times$* while incurring only an *$approx 1%$ drop in predictive accuracy* at best.
