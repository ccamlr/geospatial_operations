
<!-- README.md is generated from README.Rmd. Please edit that file -->

<center>

# CCAMLR Geospatial Operations

</center>

This repository contains R scripts and resources used by the CCAMLR
Secretariat to generate spatial objects, as well as examples of their
use. Many of the operations rely on the [CCAMLRGIS R
package](https://CRAN.R-project.org/package=CCAMLRGIS) which functions
may be accessed and reviewed
[here](https://github.com/ccamlr/CCAMLRGIS/tree/master#ccamlrgis-r-package).

<center>

### Contents

</center>

------------------------------------------------------------------------

1.  [Geospatial Rules](#1-geospatial-rules)
2.  [Building Polygons](#2-building-polygons)
3.  [Dataset](#3-dataset)
4.  [Tools](#4-tools)

------------------------------------------------------------------------

### 1. Geospatial Rules

The following rules, as endorsed by the Scientific Committee in 2023
([SC-CAMLR-42](https://meetings.ccamlr.org/sc-camlr-42), paragraph
2.30), will be applied throughout. The rules will be updated if
requested by the Scientific Committee.

1)  geographical information system (GIS) objects use the EPSG
    [6932](https://epsg.org/crs_6932/WGS-84-NSIDC-EASE-Grid-2-0-South.html)
    projection (*South Pole Lambert Azimuthal Equal-Area projection*),

2)  lines of more than 0.1 degree of longitude be densified,

3)  polygon vertices be given clockwise in decimal degrees with at least
    five decimal places,

4)  vertices be added where polygons meet (see
    [WG-FSA-2023](https://meetings.ccamlr.org/wg-fsa-2023) Figure 1),

5)  inland vertices be used for polygons that are bound by any coastline
    (continent and islands),

6)  polygons be clipped to all coastlines (continent and islands) based
    on the most recent available coastline data,

7)  the coastline be based on the latest available coastline data, as
    obtained from the SCAR Antarctic Digital Database (ADD) and other
    sources where needed (e.g., www.naturalearthdata.com),

8)  analyses cite CCAMLR geospatial data (i.e., shapefiles) as CCAMLR.
    (Year). Geographical data layer: (Layer name). Version (Version),
    URL: (URL),

9)  all maps cite data sources and projection used.

------------------------------------------------------------------------

### 2. Building Polygons

This section provides access to a basic example of the steps that must
be followed when building polygons while adhering to the Geospatial
Rules. This workflow is available
[here](https://github.com/ccamlr/geospatial_operations/blob/main/Documentation/Building_Polygons.md#building-polygons).

------------------------------------------------------------------------

### 3. Dataset

This section describes the geospatial workflow used by the CCAMLR
Secretariat to build and maintain spatial objects for use by CCAMLR
Members and the public. It provides methodological details, examples and
R scripts to act as a transparent portal to the processes established by
the Secretariat. While these resources are available
[here](https://github.com/ccamlr/geospatial_operations/blob/main/Documentation/Dataset.md#dataset),
individuals looking for the corresponding data should access these from
here: <https://github.com/ccamlr/data>

------------------------------------------------------------------------

### 4. Tools

This section provides access to several numerical tools that are used by
the Secretariat when conducting geospatial analyses. Some are in
development while others have been used for a while, and all can be
accessed
[here](https://github.com/ccamlr/geospatial_operations/blob/main/Documentation/Tools.md#tools).
It is worth noting that other ‘non-GIS’ tools are available in the
[CCAMLR Science Toolbox](https://ccamlr-science.github.io/Toolbox/)
