#import "../template.typ": *

= DNA

DNA, or *deoxyribonucleic acid*, is a long polymer that stores hereditary information. Its monomers are called *deoxyribonucleotides*. Each nucleotide has three parts:
- *Deoxyribose*: a five-carbon sugar. Compared with ribose, it lacks a hydroxyl group at the $2'$ carbon; this is the origin of the prefix *deoxy*.
- *Phosphate group*: attached to the $5'$ carbon of the sugar. At physiological pH, phosphate groups are negatively charged, so they give DNA an overall negative charge.
- *Nitrogenous base*: attached to the $1'$ carbon of the sugar. The base carries the information because its sequence varies along the DNA strand.

#align(center)[
  #image("../img/dexoxynucleotide.png", width: 60%)
]

== Nitrogenous Bases and Complementarity

DNA contains four nitrogenous bases:
- *Adenine (A)* and *guanine (G)* are *purines*, which have two fused rings.
- *Cytosine (C)* and *thymine (T)* are *pyrimidines*, which have one ring.

The bases pair specifically because of their shape and hydrogen-bonding patterns:
- adenine pairs with thymine (A--T) through two hydrogen bonds;
- guanine pairs with cytosine (G--C) through three hydrogen bonds.

These pairs are called *complementary base pairs*. Pairing one purine with one pyrimidine keeps the diameter of the double helix approximately constant. Complementarity also means that the sequence of one strand determines the sequence of the other, which is essential for faithful DNA replication.

== Polymerization of DNA

Nucleotides are joined by *3',5'-phosphodiester bonds*. The bond connects the $3'$ hydroxyl group of one deoxyribose to the phosphate group attached to the $5'$ carbon of the next nucleotide. The phosphate therefore acts as a bridge between two sugars and produces the sugar--phosphate backbone.

During replication, the incoming nucleotide is supplied as a deoxyribonucleoside triphosphate (dNTP). DNA polymerase uses the free $3'$ hydroxyl group of the growing strand to form the new bond and releases pyrophosphate (PPi). In this way, DNA is always synthesized in the $5' \to 3'$ direction.

#note()[
  A DNA strand has an intrinsic *polarity*. Its $5'$ end normally carries a free phosphate group, whereas its $3'$ end carries a free hydroxyl group. The two strands in a DNA double helix are *antiparallel*: one runs from $5'$ to $3'$, and the other from $3'$ to $5'$.
]

== DNA Structure: The Double Helix

The two complementary strands form the well-known *double helix*, usually a right-handed helix. The hydrophilic sugar--phosphate backbone faces the surrounding water, while the relatively hydrophobic bases are stacked inside the helix. Hydrogen bonds hold paired bases together, and base stacking also contributes substantially to the stability of the molecule.
#align(center)[
  #image("../img/dna-structure.png", width: 50%)
]

== DNA Organization and Chromatin

If all the DNA in one human cell were stretched out, it would be roughly $2$ meters long. It must therefore be folded and compacted to fit inside a nucleus only a few micrometres wide. This organization is hierarchical:
- *Double helix*: the approximately $2$-nm-wide DNA molecule. It's the basic unit of chromatin.

- *Nucleosome*: The DNA double helix wraps periodically around a histone octamer to form a nucleosome. Each nucleosome is composed of $147$ base pairs of DNA wrapped around a histone octamer, which consists of two copies each of histones H2A, H2B, H3, and H4. The DNA between neighbouring nucleosomes is called *linker DNA*, and histone H1 can help stabilize this region.

- *Chromatin*: a complex of DNA, histones, and other proteins. *Euchromatin* is generally less condensed and more accessible for transcription, whereas *heterochromatin* is generally more condensed and less transcriptionally active.

- *Loop domains and chromosomes*: chromatin forms loops anchored by structural proteins. During mitosis and meiosis, the DNA becomes much more condensed. A metaphase chromosome has two sister chromatids, each roughly $700$ nm wide, so the familiar X-shaped chromosome is approximately $1400$ nm wide. Thanks to this x shape the DNA can be easilly divided into two identical copies, which are then separated into two daughter cells.
#align(center)[
  #image("../img/chromatin.png", width: 80%)
]
== DNA and RNA

DNA and RNA are both nucleic acids, but they have different roles in the cell:
- *DNA*: stores genetic information and is usually double-stranded. It is relatively stable and serves as a *long-term information* archive.
- *RNA*: carries information from DNA to the ribosome, where it is translated into protein. It is usually single-stranded and can fold into many shapes; it can act as an *information carrier*.

DNA and RNA share a sugar-phosphate backbone and the bases adenine, guanine, and cytosine, but they have important differences:
- DNA contains *deoxyribose*, whereas RNA contains *ribose*. Ribose has a $2'$ hydroxyl group, which makes RNA more chemically reactive and more susceptible to alkaline hydrolysis.
- DNA uses thymine, whereas RNA generally uses *uracil (U)*. Uracil is similar to thymine but lacks thymine's $5$-methyl group.
- DNA is usually a stable double-stranded information archive. RNA is often single-stranded and can fold into many shapes.

= The Human Mitochondrial Genome

_Mitochondria_ produce ATP (the main energic molecula) through oxidative phosphorylation. They contain their own small genome, called *mitochondrial DNA* (mtDNA), which is separate from the much larger nuclear genome.

=== Somatic Cells (Cellule Somatiche)

Somatic cells are the cells that make up the body, including muscle, skin, liver, and neurons. Most contain many mitochondria, and therefore many copies of mtDNA. Cells with high energy demands can contain thousands of mitochondrial genomes.

#warning()[
  A mature *red blood cell* is an important exception: it loses its nucleus and mitochondria during maturation and produces ATP through anaerobic glycolysis.
]

=== Germ Cells and Maternal Inheritance (Cellule Germinali)

This type of cell is specialized for *sexual reproduction*. In humans, the female germ cells are called *oocytes* (egg cells), and the male germ cells are called *spermatozoa* (sperm cells):

- The egg cell contains a very large number of mitochondria because it must support the first divisions of the embryo.
- Sperm cells have a smaller number of mitochondria, concentrated in the midpiece to power movement.

In humans, paternal mitochondria are usually eliminated after fertilization, so mtDNA is transmitted almost exclusively through the mother. This is called *maternal* or *matrilineal inheritance*.

#note()[
  The sperm contributes its nuclear genome, but its mitochondria are located mainly in the tail and midpiece. They usually do *not* become part of the *embryo's persistent mitochondrial* population. If they enter the egg, they are marked for destruction. The embryo therefore receives its initial mtDNA population from the egg cytoplasm.
]

=== Main Features of Human mtDNA

Human mtDNA is a *circular, double-stranded molecule* of $16,569$ base pairs. It is compact and contains very few introns. Its $37$ genes encode:
- $13$ polypeptides that are components of the oxidative-phosphorylation machinery;
- $22$ transfer RNAs (tRNAs);
- $2$ ribosomal RNAs (12S and 16S rRNA).

The two strands differ in density and are called the *heavy strand (H)* and the *light strand (L)*. The H strand is relatively rich in guanine, while the L strand is relatively rich in cytosine. A cell may contain hundreds or thousands of mtDNA copies, depending on its type and energy requirements. Different copies within one cell can sometimes carry different variants, a condition known as *heteroplasmy*.

#align(center)[
  #image("../img/mtdna.png", width: 70%)
]

= DNA Replication

DNA replication is the process by which one parental DNA molecule is copied to produce two daughter DNA molecules. Each daughter molecule contains one original strand and one newly synthesized strand, so replication is described as *semiconservative*.

=== The Replication Machinery

Replication takes place at a moving structure called the *replication fork*. Several proteins work together:
- *Topoisomerases*: this enzyme is placed ahead of the replication fork to prevent the DNA from becoming too tightly wound (placed on the parental DNA).
- *Helicase* separates the two parental strands by breaking the hydrogen bonds between complementary bases.
- *Primase* makes a short RNA primer. The primer provides the free $3'$ hydroxyl group that DNA polymerase needs in order to begin.
- *DNA polymerase* adds complementary dNTPs to the growing strand, always in the $5' "to" 3'$ direction. It also proofreads in many organisms, which helps reduce copying errors.

=== Leading and Lagging Strands (Filo Guida e Filo Ritardato)

The parental strands are antiparallel, but DNA polymerase can extend a strand only from its $3'$ end. As a result, the two new strands are made differently:
- The *leading strand* is synthesized continuously in the same general direction as fork movement.

- The *lagging strand* is synthesized discontinuously, in short pieces called *Okazaki fragments*. Each fragment begins with an RNA primer. The primers are later removed, the gaps are filled with DNA, and DNA ligase joins the fragments into one continuous strand.

This arrangement does not violate the $5' \to 3'$ rule: both new strands are still synthesized in that direction, even though the lagging strand is made in separate fragments.

== RNA and Gene Expression

In eukaryotic cells, DNA is mainly kept in the nucleus, while translation occurs on ribosomes in the cytoplasm or on the surface of the rough endoplasmic reticulum. RNA molecules help *transfer and interpret genetic information*. The three classical RNA types have different jobs:

- *Messenger RNA (mRNA)*: It act as a *template* for protein synthesis. It carries a temporary copy of the information in a protein-coding gene. Its sequence is read in groups of three bases called *codons* (codoni), this triplets will compose a piece of a protein.

- *Ribosomal RNA (rRNA)* combines with proteins to build ribosomes. It is not merely structural: part of the ribosome's catalytic activity is performed by rRNA. It not transport information, but it is essential for the translation of mRNA into protein.

- *Transfer RNA (tRNA)* carries a specific amino acid. Its anticodon pairs with the appropriate codon in the mRNA, allowing the ribosome to add the correct amino acid. The anticodon is a sequence of three nucleotides that codes a specific aminoacid.

== Central Dogma

The process of transcription and translation is often described as the *central dogma of molecular biology*. It explains how information flows from DNA to RNA to protein:
- First the DNA sequence of a gene is *transcribed* into an RNA molecule. The gene's DNA sequence is copied into a complementary RNA sequence by RNA polymerase. In this way the information can leave the nucleus without risking damage to the original DNA.

- Then the RNA sequence is *translated* into a protein sequence.


=== Translation: Building a Protein

The translation operation is performed by the *ribosome*, which act as a tiny protein factory reading a long instruction tape (the mRNA) from beginning to end (the 5' to 3' direction). To build a protein, it uses a simple assembly line with three main workstations: A, P, and E.

- *A Site (Arrival)*: This is the docking station. A delivery molecule (the tRNA) arrives here carrying a single new building block (an amino acid) that matches the current instruction on the tape.

- *P Site (Protein holding)*: This is where the growing product is held. The tRNA in this station anchors the entire chain of building blocks that have already been assembled.

- *E Site (Exit)*: Once a tRNA has dropped off its cargo, it gets pushed to this exit door to leave the factory and go find more materials.

#note()[
  We can read the same mRNA with different ribosomes at the same time in parallel. This is called a *polysome* or *polyribosome*. It allows the cell to make many copies of a protein from one mRNA molecule.
]

The ribosome repeats the following cycle during elongation:
1. *Delivery*: A new, loaded tRNA lands in the empty A site.

2. *Linking*: The factory physically detaches the growing protein chain from the tRNA in the P site and glues it to the top of the new amino acid waiting in the A site. Now, the new tRNA in the A site is holding the entire chain.

3. *Shifting*: The factory slides exactly one step forward along the instruction tape. This mechanical shift pushes the now-empty tRNA into the E site so it can leave, and moves the tRNA holding the heavy chain into the P site. The A site is now empty and ready for the next delivery.

#align(center)[
  #image("../img/translaction.png", width: 60%)
]


Translation begins at a start codon, usually AUG, and ends when a stop codon enters the A site. Stop codons are recognized by release factors rather than by tRNAs.

=== Transcription of mRNA

The transcription is the process of copying a gene's DNA sequence into an RNA molecule. It is performed by *RNA polymerase*, which reads one strand of the DNA and synthesizes a complementary RNA strand. The RNA transcript is complementary to the DNA template strand and nearly identical to the coding strand, except that RNA has uracil (U) instead of thymine (T). RNA polymerase locally opens the DNA and builds RNA in the $5' "to" 3'$ direction:

- RNA polymerase binds to a specific DNA sequence called the *promoter*, which signals the start of a gene. It unwinds the DNA and begins synthesizing RNA.

- The *template* or *antisense strand* is the DNA strand that is read by RNA polymerase in the $3' "to" 5'$ direction. It act as a physical template for the RNA transcript, so the RNA sequence is complementary to it.

- The *coding* or *sense strand* has nearly the same sequence as the RNA transcript, except that DNA has thymine and RNA has uracil.

As the RNA polymerase moves along the DNA, it adds nucleotides to the growing RNA strand. The RNA transcript is released when the polymerase reaches a termination signal in the DNA.

#note()[
  This operation is useful because it allows the cell to make many RNA copies of a gene without altering the original DNA. The RNA can then be translated into protein or perform other functions in the cell.
]

== Non-coding RNAs

An RNA is called *non-coding* when it is not translated into a protein (instead of mRNA). Non-coding RNAs can still be essential: they may provide structure, catalyze reactions, guide chemical modifications, or regulate gene expression.

A useful functional division is:
- *Housekeeping ncRNAs*, which support *basic cellular processes*. Examples include rRNA, tRNA, snRNA involved in pre-mRNA splicing, and snoRNA involved in RNA modification.

- *Regulatory ncRNAs*, which control *gene expression* at epigenetic, transcriptional, or post-transcriptional levels. Examples include miRNA and siRNA, which can reduce expression of target mRNAs, as well as piRNA, lincRNA, circRNA, enhancer RNA, and natural antisense transcripts.

  Regulatory ncRNAs are often grouped by length into *short ncRNAs* (less than $200$ nucleotides) and *long ncRNAs* (more than $200$ nucleotides). This threshold is a practical classification rather than a strict boundary, and function cannot be inferred from length alone.

== The Genetic Code

The genetic code is the set of rules that defines how the sequence of nucleotides in a *gene* is translated into the sequence of amino acids in a protein. Each amino acid is specified by a sequence of three nucleotides, called a *codon*. The genetic code is nearly universal, meaning that it is used by almost all organisms on Earth.

A gene structure is composed of:
- *Transcibed region*: The part of the gene that is copied into RNA. It includes both coding and non-coding sequences. Trought a process called *splicing*, the non-coding sequences (introns) are removed from the RNA transcript, and the coding sequences (exons) are joined together to form the *mature mRNA* that will be translated into protein.

  In the mauture mRNA we can have an *untranslated region* (UTR) at the 5' end and another UTR at the 3' end. These regions are not translated into protein, but they can contain regulatory elements that influence mRNA stability, localization, and translation efficiency.

  #note()[
    The *splice* is importan because *it allows a single gene to produce multiple protein (mRNA)* isoforms through alternative splicing. In some case we can decided to include or exclude certain exons, which can change the protein's function or localization.
  ]

- *Promoter region*: This region it's not transcribed into RNA. It sort a *switch* that controls when and where the gene is expressed. In other words, it decide when a transcription factor binds to the promoter, it can either activate or repress transcription.

#warning()[
  Note that only the *exon* regions of a gene will composed the coding sequence that composed the mRNA template for translation a specific protein. The introns and UTRs are not translated into protein, but they can have important regulatory roles.
]

= Proteins and Amino Acids

Proteins are polymers made of amino acids. Cells commonly use $20$ standard amino acids, arranged in sequences specified by the genetic information. Protein sequences can be written using three-letter abbreviations, such as Met for methionine, or one-letter codes, such as M.

== General Structure of an Amino Acid

Most amino acids share the same basic structure. An $alpha$-carbon is bonded to four groups:
1. an *amino group* (NH2) (Gruppo amminico);
2. a *carboxyl group* (COOH) (Gruppo carbossilico);
3. a *hydrogen atom*;
4. a variable side chain, written $R$.

#align(center)[
  #image("../img/aminoacid.png", width: 50%)
]

#note()[
  The side chain is what gives each amino acid its characteristic chemical behaviour. In a cell, amino acids are usually present as zwitterions, with a positively charged amino group and a negatively charged carboxyl group.
]

=== Chemical Properties

Side chains can be grouped in several overlapping ways:
- *Hydrophobic* side chains tend to avoid water and are often buried inside soluble proteins. Examples include leucine, isoleucine, valine, and phenylalanine.
- *Polar* side chains can form hydrogen bonds with water or other groups. Examples include serine, threonine, and tyrosine.
- *Charged* side chains carry a net charge at a given pH. Lysine, arginine, and sometimes histidine are basic; aspartate and glutamate are acidic.
- *Small* side chains, especially glycine and alanine, occupy little space. Glycine is particularly flexible because its side chain is only a hydrogen atom.

== Protein Structure

To do their jobs proteins cannot just remain as straight, floppy chains. The newly built string of amino acids has to fold into a highly specific 3D shape, known as its *native conformation*.


Think of protein folding as a 4-step origami process:
1. *Primary Structure* (The Sequence): This is the basic, one-dimensional string of amino acids linked together by strong, covalent peptide bonds. Dictated directly by the mRNA, this simple sequence already holds all the chemical instructions needed to tell the protein exactly how to fold later on.

2. *Secondary Structure* (Local Folds): The protein backbone starts to interact and fold onto itself. This happens because of hydrogen bonds forming between the backbone atoms (specifically the -C=O and -NH groups), completely ignoring the variable side chains (the R groups) for now. It usually takes two main shapes:
  - $alpha$-helix: The chain coils into a right-handed spring, with the side chains sticking outward.
  - $beta$-sheet: Different parts of the chain line up side-by-side (either parallel or anti-parallel) to form a flat, zigzagging pleated sheet.

3. *Tertiary Structure* (The Overall 3D Shape): The entire chain now folds into its final, compact *three-dimensional shape*. Unlike the previous step, this folding is driven entirely by how the different side chains (R groups) interact with each other, even if they are far apart on the original string. This shape is locked in place by:
  - _The hydrophobic effect_: "Water-fearing" amino acids hide by clumping together in the inner core of the protein, away from the watery environment.
  - _Ionic and hydrogen bonds_: These form between polar or oppositely charged side chains.
  - _Disulfide bridges_: Super-strong covalent bonds linking two Cysteine amino acids together.

4. *Quaternary Structure* (The Team-Up): Not every protein reaches this stage. It only happens when two or more independent, fully-folded protein chains (called subunits) assemble into one giant functional machine.

#align(center)[
  #image("../img/aminoacidstructure.png", width: 60%)
]

#note()[
  The functions of a protein mostly depend on its tertiary and quaternary structures.
]

== Protein Function

The function of a protein may include:
- *Information processing*: Proteins can act as receptors, channels, and enzymes that help cells sense and respond to their environment. For example, Cell cycle life regulation.

- *Metabolism*: Proteins can catalyze chemical reactions, transport molecules, and store energy. For example, enzymes that break down food molecules.

- *Cell structure*: Proteins can provide mechanical support, shape, and movement to cells and tissues.



== The Codon Table

During translation, the ribosome reads mRNA *three nucleotides* at a time. Each triplet is a codon. Because RNA has four possible bases and a codon has three positions, there are:
$
  4^3 = 4 times 4 times 4 = 64
$
possible codons. The standard genetic code assigns these codons to $20$ amino acids and to stop signals. It is *degenerate* or *redundant* because several codons can specify the same amino acid:
- leucine, arginine, and serine each have six codons;
- proline, valine, threonine, alanine, and glycine each have four codons;
- many synonymous codons differ mainly at their third position. Flexible pairing at this position is called *wobble* and helps explain why some nucleotide substitutions are silent.

The special codons are:
- *AUG*: the usual start codon. It specifies methionine and establishes the reading frame at the beginning of translation;
- *UAA*, *UAG*, and *UGA*: stop codons. They do not specify amino acids; they signal release of the completed polypeptide.

#note(title: "A final distinction")[
  A codon belongs to an mRNA sequence. The corresponding triplet on the DNA coding strand contains T instead of U, while the triplet on the DNA template strand is complementary and runs in the opposite direction.
]