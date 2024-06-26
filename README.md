
# covidsymptom R Package <a href='https://github.com/csss-resultat/covidsymptom'><img src='man/figures/hex3.png' width="15%" align="right"  /></a>

<!-- badges: start --->

[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/covidsymptom)](https://cran.r-project.org/package=covidsymptom)
![CRAN\_Badge](https://cranlogs.r-pkg.org/badges/grand-total/covidsymptom)
[![](https://img.shields.io/badge/devel%20version-1.0.0-blue.svg)](https://github.com/csss-resultat/covidsymptom)
[![](https://img.shields.io/badge/lifecycle-stable-green.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![](https://img.shields.io/github/last-commit/hugofitipaldi/covidsymptom.svg)](https://github.com/hugofitipaldi/covidsymptom/commits/master)

<!-- badges: end -->

The covidsymptom R package provides an easy way to import open data from
the COVID Symptom Study-Sweden. The package includes five datasets:

- `national_estimates` - daily estimated incidence of symptomatic
  COVID-19 in Sweden
- `county_estimates` - daily estimated incidence of symptomatic COVID-19
  in Swedish counties
- `postcode_estimates` - daily estimated incidence of symptomatic
  COVID-19 in smaller Swedish regions (2-digit postcodes)
- `csss_tests` - daily proportion of positive COVID-19 tests reported by
  CSSS users
- `symptoms` - daily prevalences of symptoms reported by CSSS users

## End of data collection

On 11 July 2022, we have completed the data collection phase of CSSS. We
would like to thank our participants for their contribution to the
research and our study since the start of the covid-19 pandemic. Without
their data, it would not have been possible for us to follow the spread
of infection in Sweden. We will continue to publish our results in
scientific articles and at scientific meetings and we will share these
results on the study’s website as soon as they have been reviewed and
published. You can read more about the end of data collection
<a href = https://www.covid19app.lu.se/artikel/vi-avslutar-var-datainsamling-0>
here</a> (Swedish). We are, therefore, working on the final version of
this package for CRAN.

## Table of Contents

- [Installation](#installation)
- [Update Data](#update-data)
- [Usage](#usage)
  - [National Estimates](#national-estimates)
  - [Counties’ Estimates](#counties-estimates)
  - [2-Digit Postcodes’ Estimates](#2-digit-postcodes-estimates)
  - [COVID-19 Tests Results](#covid-19-tests-results)
  - [Symptoms Prevalences](#symptoms-prevalences)
- [Dashboard](#dashboard)
- [About COVID Symptom Study -
  Sweden](#about-covid-symptom-study-sweden)

## Installation

Install the CRAN version:

``` r
install_packages("covidsymptom")
```

Development version of the package can be installed from Github with:

``` r
install.packages("remotes")
remotes::install_github("csss-resultat/covidsymptom")
```

## Update data

In order to respect CRAN best use practices, we will only push a new
version of the package with most recent data every one month. However,
data from COVID Symptom Study - Sweden is updated on a daily basis (see
end of data collection), thus the dev version of the package is also
updated daily. The function `update_csss_data()` (based on a similar
function from the <a href = https://github.com/RamiKrispin/coronavirus>
coronavirus package),</a> checks updates to the dataset and re-install
the package with the most recent data (dev version).

``` r
library(covidsymptom)
update_csss_data()
```

If you want to avoid updating the package to have the most recent data,
you can use the function `get_latest_data()` to import the latest
version available. Notice however that this won’t re-write the package
datasets.

``` r
library(covidsymptom)
national_estimates <- get_latest_data(data_level = "national")

head(national_estimates)
#> [1] "Your data is up-to-date"
```

## Usage

- National estimates

``` r
library(ggplot2)
library(dplyr)

covidsymptom::national_estimates %>%
  ggplot(aes(x = Datum, y = Uppskattning)) +
  geom_line(col = "#a60f61") +
  geom_point(col = "#a60f61", size = 0.5) +
  labs(x = "Date", y = "Predicted number of cases as % of the population",
       title = "Predicted Number of COVID-19 Cases by Date",
       subtitle = "")  +
  scale_y_continuous(limits = c(0, 1.3),
                     breaks = seq(0, 1, 0.2),
                     labels = paste0(format(seq(0, 1, 0.2), decimal.mark = ","), " %"), # add % sign to the labels
                     expand = c(0,0)) +
  scale_x_date(date_breaks = "30 days", date_labels = "%d %b, %Y") + # can be "1 day", "2 days", etc.
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), panel.grid.minor.x = element_blank()) +
  geom_ribbon(aes(ymin = Low_CI, ymax = High_CI), fill = "#a60f61", alpha = 0.09)
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

- Counties’ estimates

``` r
library(ggplot2)
library(dplyr)
library(lubridate)

counties_selection <- c("Skane", "Stockholm", "Vastra Gotaland", "Uppsala")

covidsymptom::county_estimates %>%
  filter(Lan %in% counties_selection) %>%
  ggplot(aes(x = Datum, y = Uppskattning, color = Lan)) +
      geom_line() +
      #geom_point(size = 0.5) +
      labs(x = "Datum", y = "Uppskattad förekomst", title = "% Uppskattad förekomst av symtomatisk covid-19", subtitle = "") +
      scale_x_date(date_breaks = "50 days") +
      theme_minimal() + 
      theme(axis.text.x = element_text(angle = 45, hjust = 1), panel.grid.minor.x = element_blank(),
            legend.position = "none", plot.title = element_text(hjust = 0.5)) + 
      geom_ribbon(aes(ymin = Low_CI, ymax = High_CI), color = "transparent", fill = "#a60f61", alpha = 0.09) +
      facet_wrap(. ~ Lan) 
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />

- 2-digit postcodes’ estimates

COVID Symptom Study - Sweden provides also predictions at
<a href = "https://sv.wikipedia.org/wiki/Postnummer_i_Sverige">2-digit
postcode levels</a>.

``` r
library(ggplot2)
library(dplyr)
library(lubridate)
library(gt)

stockholm_codes <- c('11', '12', '13', '14', '15', '16', '17', '18', '19', '76')

filtered_data <- covidsymptom::postcode_estimates %>%
  filter(Postnummer %in% stockholm_codes & Datum == as.Date("2021-01-31") & !is.na(Uppskattning))

min_pred <- min(filtered_data$Uppskattning)
max_pred <- max(filtered_data$Uppskattning)
pred_palette <- scales::col_numeric(c("#f9dee2", "#5E0B21"), domain = c(min_pred, max_pred), alpha = 0.75)


filtered_data %>%
  arrange(desc(Uppskattning)) %>%
  gt(.) %>%
  tab_header(
    title = md("**Predicted number of cases as % of the population**"),
    subtitle = "Stockholm's 2-digit regions"
  ) %>% 
  cols_width(starts_with("Datum") ~ px(95)) %>%
  tab_style(
    locations = cells_column_labels(columns = everything()),
    style     = list(
      cell_borders(sides = "bottom", weight = px(3)),
      cell_text(weight = "bold")
    )) %>% 
  cols_align("center") %>% 
  data_color(columns = vars(Uppskattning),
             colors = pred_palette) %>%
  tab_source_note(source_note = "Data: COVID Symptom Study Sweden") %>%
  tab_options(
    column_labels.border.top.width = px(3),
    data_row.padding = px(3),
    source_notes.font.size = 12,
    table.font.size = 12,
    heading.align = "center",
    row_group.background.color = "grey")
```

<a><img src='man/figures/gt.png'/></a>

``` r

stockholm_codes <- c('11', '12', '13', '14', '15', '16', '17', '18', '19')

covidsymptom::postcode_estimates %>%
  filter(Postnummer %in% stockholm_codes) %>%
  ggplot(aes(x = Datum, y = Uppskattning, color = Postnummer)) +
  geom_line() +
  #geom_point(size = 0.5) +
  labs(x = "Datum", y = "Uppskattad förekomst", title = "% Uppskattad förekomst av symtomatisk covid-19", subtitle = "") +
  scale_x_date(date_breaks = "90 days") +
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1), panel.grid.minor.x = element_blank(),
        legend.position = "none", plot.title = element_text(hjust = 0.5)) + 
  geom_ribbon(aes(ymin = Low_CI, ymax = High_CI), color = "transparent", fill = "#a60f61", alpha = 0.09) +
  facet_wrap(. ~ Postnummer, scales= "free")   
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

- covid-19 tests results

``` r
library(gganimate)
library(ggdark)

tests_df <- covidsymptom::csss_tests

a_plot <- ggplot(tests_df, aes(x=date, y=total_tests)) +
  geom_line() +
  geom_segment(aes(xend=max(date), yend = total_tests), linetype=2) +
  geom_point(size = 3) + 
  geom_text(aes(x = max(date), label = sprintf("%2.0f", total_tests)), hjust=0, color = "grey") +
  transition_reveal(date) + 
  view_follow(fixed_y = TRUE)+
  coord_cartesian(clip = 'off') + 
  labs(title = 'Reported antigen tests in the Covid Symptom Study Sweden', y = 'N# Antigen tests', x = "Date") +
  enter_drift(x_mod = -1) + exit_drift(x_mod = 1) +
  dark_theme_gray() +
  theme(plot.margin = margin(5.5, 40, 5.5, 5.5))

animate(a_plot, fps = 5)
```

<img src="man/figures/README-unnamed-chunk-7-1.gif" width="100%" />

- Symptoms prevalences

``` r
library(ggplot2)
library(dplyr)
library(ggrepel)

symptoms_df <- covidsymptom::symptoms %>%
  mutate(Vikt = factor(Vikt, levels = c("Positiv", "Negativ")))
symptoms_df[symptoms_df$Symptom == "Förlorat eller förändrat lukt-/smaksinne",]$Symptom <- "Förlorat eller förändrat\nlukt-/smaksinne"
data_ends <- symptoms_df %>% 
  filter(Datum == max(Datum)) 

symptoms_df %>%
  ggplot(aes(x = Datum, y = Andel, color = Symptom)) +
  geom_line() +
  theme_light(base_size = 11) +
  labs(x = "Datum", y = "Andel deltagare med symptom", title = "Covid19 symptom", subtitle = "", color = "") +
  scale_x_date(date_breaks = "60 days", date_labels = "%d %b, %Y", limits = as.Date(c("2020-04-015","2022-07-01"))) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), panel.grid.minor.x = element_blank(),
        plot.title = element_text(hjust = 0.5, face="bold"), legend.position = "none",
        strip.text = element_text(face="bold")) + 
 geom_label_repel(
   aes(label = Symptom, fill = Symptom), data = data_ends,
   fontface ="plain", color = "black", size = 3,
   xlim = as.Date(c("2022-03-20", "2022-07-01"))) +
  facet_wrap(~Vikt, scales = "free_y", ncol =1) 
```

<a><img src='man/figures/symptoms.png'/></a>

## Dashboard

A supporting dashboard is available
[here](https://csss-resultat.shinyapps.io/csss_dashboard/)

<img src="man/figures/dashboard.png" width="100%" />

## About COVID Symptom Study - Sweden

The COVID Symptom Study was a non-commercial project that used a free
smartphone app to facilitate real-time data collection of symptoms,
exposures, and risk factors related to COVID-19. The app was developed
by researchers at King’s College and Guys and St Thomas’ Hospitals in
London in partnership with health science company Zoe Global
Ltd. Baseline data and recurring daily questions are described in
<a href = https://www.science.org/doi/10.1126/science.abc0473> Drew et
al (Science, 2020)</a>. The app was launched in the UK and US March
2020. In Sweden, the study is based at Lund University and, as per a
collaboration agreement on 28 July 2020, Uppsala University. More about
the Swedish part of the study is described in
<a href = https://www.nature.com/articles/s41467-022-29608-7> Kennedy &
Fitipaldi, et al. (Nat Comms, 2022)</a> The app was launched in Sweden
on April 29, 2020 as part of a national research initiative on COVID-19.
\>4.5 million participants in the three countries used the app, ~220,000
of whom live in Sweden. On July 11, 2022, with over 500 million data
entries, in which Swedish participants contributed ~20 million of these,
the project officially ended the data collection phase.
