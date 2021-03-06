% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/update_csss_data.R
\name{update_csss_data}
\alias{update_csss_data}
\title{Update COVID Symptom Study Sweden (CSSS) data}
\usage{
update_csss_data(silence = FALSE)
}
\arguments{
\item{silence}{logical function to supress messages}
}
\value{
Updated data.frames
}
\description{
Update the package datasets on the global environment with the most recent data on the dev version
}
\details{
This function enables to refresh the package dataset to the most up-to-date data by re-installing the dev version of the package.
Changes will be available on the global environment
}
\examples{
update_csss_data()

}
\author{
Hugo Fitipaldi
}
