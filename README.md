# Replication: Incentivized Resume Rating: Eliciting Employer Preferences without Deception

Judd B. Kessler, Corinne Low, and Colin D. Sullivan — *American Economic Review (2019)*.

This [stats.camp](https://stats.camp) repository preserves official AEA deposit
**231422, version V1**, for replication and engine compatibility testing.
**Status: executed on 2026-10-16 and again on 2026-10-17 in the native stats.camp engine from scratch copies; the package runs end to end in the engine.**
The deposited datasets retain their original bytes and archive-relative paths.
Documentation is adapted for stats.camp.

## The study

Uses randomized hypothetical resumes rated by recruiting employers to study preferences over candidate demographics and human capital while separately measuring acceptance beliefs.

## Contents and entry points

Both original Penn and Pitt raw datasets are included. The README explains why Pitt resume bullet descriptions and experience locations were omitted by the authors. The script constructs derived data and produces tables and figures, including ordered-response models and nonlinear combinations.

The source archive contains **5 original files** totaling
**16,699,568 bytes**. The source ZIP is
3,569,355 bytes. Deposited data, reference outputs, and ancillary files are retained;
documentation is adapted for stats.camp.

Analysis entry point:

- [data/Code/KesslerLowSullivan-IRR-Analysis.do](data/Code/KesslerLowSullivan-IRR-Analysis.do)

Authors’ documentation, adapted for stats.camp:

- [data/README.txt](data/README.txt)

## Setup and current scope

Launch the deposited script from `data/`, which contains the `Data/` subdirectory expected by its relative globals. The commented-out `cd` instruction remains commented. Empty `data/Data/Clean/` and `data/Tables and Figures/` directories have been added with `.gitkeep` files to match the authors’ documented output layout; no script has been edited.

The 2026-10-16 runs used scratch copies, so the figures, logs and intermediate
datasets in this repository are still the authors' deposited reference material.

## Inspect in stats.camp

These links open the deposited files for inspection. They do not establish
that the preserved paths, dependencies, or commands are executable in the browser.

- [data/Code/KesslerLowSullivan-IRR-Analysis.do](https://stats.camp/app?open=https%3A%2F%2Fgithub.com%2Fstats-camp%2Freplication-incentivized-resume-rating.git&file=data%2FCode%2FKesslerLowSullivan-IRR-Analysis.do)

## Source integrity and attribution

- [Official deposit](https://www.openicpsr.org/openicpsr/project/231422/version/V1/view)
- [Deposit DOI](https://doi.org/10.3886/E231422V1)

Archive: `231422-V1.zip`. SHA-256:
`a6770a0b5776b37c1628544106936185ffc0701315e1a9139d4c662089085c89`.

All original file hashes were checked after extraction. `.gitattributes` disables
Git line-ending normalization. Empty folders are represented by `.gitkeep`
files. The root README and Git configuration are stats-camp additions.

The deposited `LICENSE.txt` is retained without modification. It supplies the original code/data terms; this mirror does not relicense the research.

The study, code, and data remain credited to Judd B. Kessler, Corinne Low, and Colin D. Sullivan; stats-camp maintains
this mirror and its preparation documentation.
