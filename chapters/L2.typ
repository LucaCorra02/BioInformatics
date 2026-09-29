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
  A DNA strand has an intrinsic polarity. Its $5'$ end normally carries a free phosphate group, whereas its $3'$ end carries a free hydroxyl group. The two strands in a DNA double helix are *antiparallel*: one runs from $5'$ to $3'$, and the other from $3'$ to $5'$.
]

== DNA Structure: The Double Helix

The two complementary strands form the well-known *double helix*, usually a right-handed helix. The hydrophilic sugar--phosphate backbone faces the surrounding water, while the relatively hydrophobic bases are stacked inside the helix. Hydrogen bonds hold paired bases together, and base stacking also contributes substantially to the stability of the molecule.
#align(center)[
  #image("../img/dna-structure.png", width: 50%)
]

== DNA Organization and Chromatin

If all the DNA in one human cell were stretched out, it would be roughly $2$ meters long. It must therefore be folded and compacted to fit inside a nucleus only a few micrometres wide. This organization is hierarchical:
- *Double helix*: the approximately $2$-nm-wide DNA molecule.
- *Nucleosome*: about 147 base pairs of DNA wrap around a histone octamer, made of two copies each of histones H2A, H2B, H3, and H4. The DNA between neighbouring nucleosomes is called *linker DNA*; histone H1 can help stabilize this region.
- *Chromatin*: a complex of DNA, histones, and other proteins. *Euchromatin* is generally less condensed and more accessible for transcription, whereas *heterochromatin* is generally more condensed and less transcriptionally active.
- *Loop domains and chromosomes*: chromatin forms loops anchored by structural proteins. During mitosis and meiosis, the DNA becomes much more condensed. A metaphase chromosome has two sister chromatids, each roughly $700$ nm wide, so the familiar X-shaped chromosome is approximately $1400$ nm wide.

#note(title: "A clarification about chromatin")[
  The older textbook description of a regular $30$-nm chromatin fibre is useful as a simplified model, but modern microscopy shows that chromatin is often arranged as irregular, dynamic domains rather than as one universal fibre. The important principle is that DNA is compacted by nucleosomes, loops, and chromosome-level organization.
]

== DNA and RNA

DNA and RNA share a sugar--phosphate backbone and the bases adenine, guanine, and cytosine, but they have important differences:
- DNA contains *deoxyribose*, whereas RNA contains *ribose*. Ribose has a $2'$ hydroxyl group, which makes RNA more chemically reactive and more susceptible to alkaline hydrolysis.
- DNA uses thymine, whereas RNA generally uses *uracil (U)*. Uracil is similar to thymine but lacks thymine's $5$-methyl group.
- DNA is usually a stable double-stranded information archive. RNA is often single-stranded and can fold into many shapes; it can act as an information carrier, structural molecule, catalyst, or regulator.

== The Human Mitochondrial Genome

Mitochondria produce ATP through oxidative phosphorylation. They contain their own small genome, called *mitochondrial DNA* (mtDNA), which is separate from the much larger nuclear genome.

=== Somatic Cells

Somatic cells are the cells that make up the body, including muscle, skin, liver, and neurons. Most contain many mitochondria, and therefore many copies of mtDNA. Cells with high energy demands can contain thousands of mitochondrial genomes. A mature red blood cell is an important exception: it loses its nucleus and mitochondria during maturation and produces ATP through anaerobic glycolysis.

=== Germ Cells and Maternal Inheritance

The egg cell contains a very large number of mitochondria because it must support the first divisions of the embryo. Sperm cells have a smaller number of mitochondria, concentrated in the midpiece to power movement. In humans, paternal mitochondria are usually eliminated after fertilization, so mtDNA is transmitted almost exclusively through the mother. This is called *maternal* or *matrilineal inheritance*.

#note(title: "Why is mtDNA usually inherited from the mother?")[
  The sperm contributes its nuclear genome, but its mitochondria are located mainly in the tail and midpiece. They usually do not become part of the embryo's persistent mitochondrial population; if they enter the egg, they are marked for destruction. The embryo therefore receives its initial mtDNA population from the egg cytoplasm.
]

=== Main Features of Human mtDNA

Human mtDNA is a circular, double-stranded molecule of $16,569$ base pairs. It is compact and contains very few introns. Its $37$ genes encode:
- $13$ polypeptides that are components of the oxidative-phosphorylation machinery;
- $22$ transfer RNAs (tRNAs);
- $2$ ribosomal RNAs (12S and 16S rRNA).

The two strands differ in density and are called the *heavy strand (H)* and the *light strand (L)*. The H strand is relatively rich in guanine, while the L strand is relatively rich in cytosine. A cell may contain hundreds or thousands of mtDNA copies, depending on its type and energy requirements. Different copies within one cell can sometimes carry different variants, a condition known as *heteroplasmy*.

The $13$ protein-coding genes are distributed among the respiratory-chain complexes: *ND1*, *ND2*, *ND3*, *ND4*, *ND4L*, *ND5*, and *ND6* encode subunits of complex I; *CYB* encodes a subunit of complex III; *COX1*, *COX2*, and *COX3* encode subunits of complex IV; and *ATP6* and *ATP8* encode subunits of complex V (ATP synthase).

== DNA Replication

DNA replication is the process by which one parental DNA molecule is copied to produce two daughter DNA molecules. Each daughter molecule contains one original strand and one newly synthesized strand, so replication is described as *semiconservative*.

=== The Replication Machinery

Replication takes place at a moving structure called the *replication fork*. Several proteins work together:
- *Topoisomerases* temporarily cut and reseal DNA to relieve torsional stress and excessive supercoiling ahead of the fork.
- *Helicase* separates the two parental strands by breaking the hydrogen bonds between complementary bases.
- *Primase* makes a short RNA primer. The primer provides the free $3'$ hydroxyl group that DNA polymerase needs in order to begin.
- *DNA polymerase* adds complementary dNTPs to the growing strand, always in the $5' \to 3'$ direction. It also proofreads in many organisms, which helps reduce copying errors.

=== Leading and Lagging Strands

The parental strands are antiparallel, but DNA polymerase can extend a strand only from its $3'$ end. As a result, the two new strands are made differently:
- The *leading strand* is synthesized continuously in the same general direction as fork movement.
- The *lagging strand* is synthesized discontinuously, in short pieces called *Okazaki fragments*. Each fragment begins with an RNA primer. The primers are later removed, the gaps are filled with DNA, and DNA ligase joins the fragments into one continuous strand.

This arrangement does not violate the $5' \to 3'$ rule: both new strands are still synthesized in that direction, even though the lagging strand is made in separate fragments.

== RNA and Gene Expression

In eukaryotic cells, DNA is mainly kept in the nucleus, while translation occurs on ribosomes in the cytoplasm or on the surface of the rough endoplasmic reticulum. RNA molecules help transfer and interpret genetic information. The three classical RNA types have different jobs:
- *Messenger RNA (mRNA)* carries a temporary copy of the information in a protein-coding gene. Its sequence is read in groups of three bases called *codons*.
- *Ribosomal RNA (rRNA)* combines with proteins to build ribosomes. It is not merely structural: part of the ribosome's catalytic activity is performed by rRNA.
- *Transfer RNA (tRNA)* carries a specific amino acid. Its anticodon pairs with the appropriate codon in the mRNA, allowing the ribosome to add the correct amino acid.

=== Translation: Building a Protein

During *translation*, the ribosome moves along the mRNA from $5'$ to $3'$. Its three main binding sites are:
- the *A site* (aminoacyl site), where an incoming aminoacyl-tRNA binds;
- the *P site* (peptidyl site), which holds the tRNA carrying the growing peptide chain;
- the *E site* (exit site), through which an uncharged tRNA leaves.

The ribosome repeats the following cycle during elongation:
1. A charged tRNA enters the A site and pairs with the next codon.
2. The ribosome's catalytic centre forms a peptide bond. The amino group of the amino acid in the A site attacks the carbonyl group of the last amino acid in the chain, and the growing chain is transferred from the P-site tRNA to the A-site tRNA.
3. The ribosome moves one codon towards the mRNA's $3'$ end. The tRNA carrying the chain moves from A to P, and the empty tRNA exits.

Translation begins at a start codon, usually AUG, and ends when a stop codon enters the A site. Stop codons are recognized by release factors rather than by tRNAs.

=== Transcription of mRNA

*Transcription* is the synthesis of an RNA molecule using one DNA strand as a template. RNA polymerase locally opens the DNA and builds RNA in the $5' \to 3'$ direction:
- The *template* or *antisense strand* is read by RNA polymerase in the $3' \to 5'$ direction.
- The *coding* or *sense strand* has nearly the same sequence as the RNA transcript, except that DNA has thymine and RNA has uracil.

In eukaryotes, the initial RNA transcript is usually processed before it becomes mature mRNA. Typical processing includes addition of a $5'$ cap, addition of a poly-A tail, and removal of introns by splicing.

== Non-coding RNAs

An RNA is called *non-coding* when it is not translated into a protein. Non-coding RNAs can still be essential: they may provide structure, catalyze reactions, guide chemical modifications, or regulate gene expression. A useful functional division is:
- *Housekeeping ncRNAs*, which support basic cellular processes. Examples include rRNA, tRNA, snRNA involved in pre-mRNA splicing, and snoRNA involved in RNA modification.
- *Regulatory ncRNAs*, which control gene expression at epigenetic, transcriptional, or post-transcriptional levels. Examples include miRNA and siRNA, which can reduce expression of target mRNAs, as well as piRNA, lincRNA, circRNA, enhancer RNA, and natural antisense transcripts.

Regulatory ncRNAs are often grouped by length into *short ncRNAs* (less than $200$ nucleotides) and *long ncRNAs* (more than $200$ nucleotides). This threshold is a practical classification rather than a strict boundary, and function cannot be inferred from length alone.

== Proteins and Amino Acids

Proteins are polymers made of amino acids. Cells commonly use $20$ standard amino acids, arranged in sequences specified by the genetic information. Protein sequences can be written using three-letter abbreviations, such as Met for methionine, or one-letter codes, such as M.

=== General Structure of an Amino Acid

Most amino acids share the same basic structure. An $alpha$-carbon is bonded to four groups:
1. an amino group (NH2);
2. a carboxyl group (COOH);
3. a hydrogen atom;
4. a variable side chain, written $R$.

The side chain is what gives each amino acid its characteristic chemical behaviour. In a cell, amino acids are usually present as zwitterions, with a positively charged amino group and a negatively charged carboxyl group.

=== Chemical Properties

Side chains can be grouped in several overlapping ways:
- *Hydrophobic* side chains tend to avoid water and are often buried inside soluble proteins. Examples include leucine, isoleucine, valine, and phenylalanine.
- *Polar* side chains can form hydrogen bonds with water or other groups. Examples include serine, threonine, and tyrosine.
- *Charged* side chains carry a net charge at a given pH. Lysine, arginine, and sometimes histidine are basic; aspartate and glutamate are acidic.
- *Small* side chains, especially glycine and alanine, occupy little space. Glycine is particularly flexible because its side chain is only a hydrogen atom.

=== Four Levels of Protein Structure

Protein structure is described at four related levels:
- *Primary structure*: the linear sequence of amino acids connected by covalent peptide bonds. It is determined by the coding sequence of the gene through the mRNA.
- *Secondary structure*: local patterns such as the $alpha$-helix and $beta$-sheet. Hydrogen bonds between backbone carbonyl and amide groups stabilize these patterns; side chains are not the main source of these bonds.
- *Tertiary structure*: the complete three-dimensional shape of one polypeptide chain. It is stabilized by the hydrophobic effect, hydrogen bonds, ionic interactions, van der Waals forces, and sometimes disulfide bonds between cysteine residues.
- *Quaternary structure*: the arrangement of two or more polypeptide chains into one functional complex. For example, haemoglobin has two $alpha$ subunits and two $beta$ subunits.

Not every protein has quaternary structure. A newly synthesized chain must fold into a suitable *native conformation* to function, although some proteins require molecular chaperones or remain partly disordered.

== The Genetic Code

During translation, the ribosome reads mRNA three nucleotides at a time. Each triplet is a codon. Because RNA has four possible bases and a codon has three positions, there are:

$$4^3 = 4 \times 4 \times 4 = 64$$

possible codons. The standard genetic code assigns these codons to $20$ amino acids and to stop signals. It is *degenerate* or *redundant* because several codons can specify the same amino acid:
- leucine, arginine, and serine each have six codons;
- proline, valine, threonine, alanine, and glycine each have four codons;
- many synonymous codons differ mainly at their third position. Flexible pairing at this position is called *wobble* and helps explain why some nucleotide substitutions are silent.

The special codons are:
- *AUG*: the usual start codon. It specifies methionine and establishes the reading frame at the beginning of translation;
- *UAA*, *UAG*, and *UGA*: stop codons. They do not specify amino acids; they signal release of the completed polypeptide.

For completeness, the standard code can be read by grouping codons according to their first two bases:
- *UU*: UUU and UUC encode phenylalanine (Phe); UUA and UUG encode leucine (Leu).
- *UC*: UCU, UCC, UCA, and UCG encode serine (Ser).
- *UA*: UAU and UAC encode tyrosine (Tyr); UAA and UAG are stop codons.
- *UG*: UGU and UGC encode cysteine (Cys); UGA is a stop codon; UGG encodes tryptophan (Trp).
- *CU*: CUU, CUC, CUA, and CUG encode leucine (Leu).
- *CC*: CCU, CCC, CCA, and CCG encode proline (Pro).
- *CA*: CAU and CAC encode histidine (His); CAA and CAG encode glutamine (Gln).
- *CG*: CGU, CGC, CGA, and CGG encode arginine (Arg).
- *AU*: AUU, AUC, and AUA encode isoleucine (Ile); AUG encodes methionine (Met) and usually starts translation.
- *AC*: ACU, ACC, ACA, and ACG encode threonine (Thr).
- *AA*: AAU and AAC encode asparagine (Asn); AAA and AAG encode lysine (Lys).
- *AG*: AGU and AGC encode serine (Ser); AGA and AGG encode arginine (Arg).
- *GU*: GUU, GUC, GUA, and GUG encode valine (Val).
- *GC*: GCU, GCC, GCA, and GCG encode alanine (Ala).
- *GA*: GAU and GAC encode aspartate (Asp); GAA and GAG encode glutamate (Glu).
- *GG*: GGU, GGC, GGA, and GGG encode glycine (Gly).

#note(title: "A final distinction")[
  A codon belongs to an mRNA sequence. The corresponding triplet on the DNA coding strand contains T instead of U, while the triplet on the DNA template strand is complementary and runs in the opposite direction.
]

== DNA v.s RNA


