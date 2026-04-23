
<!-- README.md is generated from README.Rmd. Please edit that file -->

<center>

# Tools

</center>

While the
[CCAMLRGIS](https://github.com/ccamlr/CCAMLRGIS#ccamlrgis-r-package) R
package offers many geospatial tools, this page documents analytical
resources that have been developed by the Secretariat to address
specific CCAMLR needs. While these are described here, they may also be
found in the [CCAMLR Science
Toolbox](https://ccamlr-science.github.io/Toolbox/) which further offers
non-GIS analytical tools that have been developed over the years.

<center>

### Contents

</center>

------------------------------------------------------------------------

1.  [Fishery Distribution Metrics](#1-fishery-distribution-metrics)

    1.1. [Fishery Concentration Index](#11-fishery-concentration-index)

    1.2. [Fished Areas](#12-fished-areas)

2.  [Acoustic Survey Design](#2-acoustic-survey-design)

------------------------------------------------------------------------

### 1. Fishery Distribution Metrics

#### 1.1. Fishery Concentration Index

Introduced in [SC-CAMLR-44/BG/36
Rev. 2](https://meetings.ccamlr.org/en/sc-camlr-44/bg/36-rev-2), the
Fishery Concentration Index was designed to visualise temporal trends in
spatial concentration of catches. It is calculated as the sum of catches
divided by the area of the fished footprint (*e.g.*, in tonnes per
km$^2$), within a defined period and area. To compute the area of the
fished footprint, a fished path is considered as a straight line between
the start and end location of the fishing event, and is buffered by a
chosen distance (typically 10s of meters) to represent the area that was
fished along that path. This buffer distance can be adjusted depending
on the fishing gear used. Depending on the fishery, fished footprints
may be merged or not, prior to the calculation of the index
(sum(catch)/sum(area)). For instance, because the krill fishery is a
pelagic fishery with water and krill in motion, the trawl paths are
treated as non-overlapping and footprints are not merged.

#### 1.2. Fished Areas

------------------------------------------------------------------------

### 2. Acoustic Survey Design

*In development*
