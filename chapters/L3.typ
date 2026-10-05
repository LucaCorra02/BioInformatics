#import "../template.typ": *

= Molecular evolution

Changes in DNA can lead to changes in proteins. Since proteins are able to control many aspects of cellular function, changes in protein structure can have a large impact on the fitness of an organism.

As we can see from the genetic code @gencode, if a single *nucleotide* in a codon is *changed*, a *different amino acid* may be incorporated into the protein. This can result in a protein that functions differently or not at all:
- If the amino acid change is in a critical part of the protein, it may cause the protein to misfold or lose its function entirely.
  #example()[
    If a mutation changes a codon in the middle of a coding sequence into a _stop codon_, the protein may be truncated and non-functional. This is called a *nonsense mutation*.
  ]

- Alternatively, the change can lead to a stronger or more stable protein structure, which may be beneficial to the organism.

  #note()[
    Since the genetic code is redundant, some changes in DNA do not lead to changes in the protein. These are called *silent mutations* because the corresponding amino acid does not change.

    This redundancy acts as a form of *error tolerance*, allowing some mutations to occur without affecting the organism's fitness.
  ]


#figure()[
  #align(center)[
    #image("../img/gencode-table.png", width: 50%)
  ]]<gencode>

Cells have mechanisms that can detect and repair DNA damage. However, these mechanisms are not always perfect, and some mutations can escape repair.

== Choice of mutations

The process of *evolution* is driven by the accumulation of heritable changes over time. If a change leads to a protein that is more effective at performing its function, the organism may have a selective advantage over others.

The effects of a mutation can influence whether it is retained in a population:
- Changes that result in *lower fitness* (e.g., less effective proteins) are generally less likely to be passed on to the next generation because their carriers are less likely to survive or reproduce.

- A change in a *somatic cell* (a cell that makes up the body) is not normally passed on to the next generation. However, *it can be inherited* by the daughter cells produced during the division of that somatic cell. Such changes can contribute to cancer or other diseases that affect the organism's health and survival.

  #example()[
    Cells in our skin continuously reproduce. In cancer cells, the cell cycle is usually not properly controlled, so the cells can *replicate uncontrollably*. This can lead to the formation of tumors.

    A tumor is a mass of cells that have lost the ability to control their growth and division. These cells can invade nearby tissues and spread to other parts of the body.
  ]

  For this reason, it is important to classify some gene mutations and determine whether they are *physiological* or *pathological*.

#warning()[
  *Only mutations* that occur in the *germline cells* (the cells that give rise to eggs and sperm) *can* normally *be passed* on to the next generation. These mutations can have long-term effects on the evolution of a species.

  However, mutations in somatic cells can also have a strong impact on the organism's health and survival.
]

== Conservation of DNA

As shown in the figure below @dna-composition, the DNA of an organism is composed of *coding* and *non-coding* regions.

*Coding regions*: Some parts of DNA sequences are *highly conserved* across different species, especially when they contain essential information. They are often associated with *genes* that encode proteins. These regions are important for the survival of the organism. In humans protein-coding sequences account for roughly $1-2%$ of the genome, although the broader genomic regions associated with genes occupy a larger fraction.

*Non-Coding regions*: The rest of the genome is composed of non-coding regions, which can be more variable and less conserved. This part not contains the information to produce proteins, but it can have other important functions, such as regulating gene expression or maintaining the structure of chromosomes. They were traditionally called *junk DNA*.

#note()[
  A *change* in the *promoter region*, a non-coding region with a regulatory function, can alter the *expression of a gene* and therefore the amount or timing of production of the protein it encodes. This can have a significant impact on the organism's phenotype.

  So studying the non-coding regions is also important.
]


#figure()[
  #align(center)[
    #image("../img/dna-composition.png", width: 50%)
  ]]<dna-composition>


=== Types of mutations

We can have different types of mutations:
- *Single substitutions*: A single nucleotide is replaced by another. This can lead to a change in the amino acid sequence of the protein, or it can be silent.

- *Insertions*: One or more nucleotides are added to the DNA sequence. If the number of inserted nucleotides is not a multiple of three, this can lead to a *frameshift mutation*, which changes the reading frame of the codons and may result in a substantially different amino acid sequence.

  #note()[
    This type of mutation can have a large impact on the protein's function. It can be more disruptive than a single-nucleotide substitution, although its effect depends on its location and length.
  ]

- *Deletions*: One or more nucleotides are removed from the DNA sequence. As with insertions, a deletion whose length is not a multiple of three can cause a frameshift and result in a loss of nucleotides.

- Some *mutations* also involve the translocation of an entire section *of a chromosome* to another location. Such mutations can affect many genes and can have a large impact on the organism's fitness.



== Transcription regulation

// Riguardare da slide e video

Transcription factors are proteins that bind to specific DNA sequences and regulate gene transcription by helping determine whether a gene is turned on or off. They are related to many diseases, including cancer.

Understanding how transcription factors work leads to the creation of new drugs that can target specific transcription factors and modulate their activity.

#note()[
  The number of gene is not the primary determinant of the complexity of an organism. The *regulation of gene expression* is a key factor in determining the complexity of an organism.
]

Transcription factors regulate the activity of RNA polymerase, the enzyme that synthesizes RNA from a DNA template. In eukaryotes, RNA polymerase generally requires transcription factors to recognize and bind the promoter efficiently, and to recruit or position the polymerase at the correct location and time.

The situation is more complex because genes can also be regulated by *enhancers*. These are regulatory regions that can interact with a gene's promoter to increase its transcription. Enhancers are often located far from the genes they regulate, either upstream or downstream. They can act through *DNA looping*, which brings the enhancer-bound activator proteins into close proximity to the promoter region.

We have:
- *Promoter*: regulatory region located near the gene that serves as a binding site for transcription factors and RNA polymerase.

- *Enhancer*: a regulatory region that can enhance the transcription of a gene by interacting with its promoter and recruiting transcription factors and RNA polymerase.

- *Silencer*: a regulatory DNA region that can inhibit the transcription of a gene, often by binding repressor proteins.

//riguardare
Different genes can be regulated by some common transcription factors, which can lead to coordinated expression of genes that are involved in the same biological process.


