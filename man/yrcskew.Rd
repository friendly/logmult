\name{yrcskew}
\alias{yrcskew}
\alias{print.yrcskew}
\title{Fitting Yamaguchi RC_SK Skew-Symmetric Association Model}
\description{
  Fit a skew-symmetric association model proposed in Yamaguchi (1990) to describe asymmetry of square
  tables. This model can be combined with symmetric association models like a quasi-symmetry (the default)
  or symmetric (homogeneous) RC(M) models.
}
\usage{
yrcskew(tab, nd.symm = NA, nd.skew = 1, diagonal = FALSE,
        weighting = c("marginal", "uniform", "none"),
        se = c("none", "jackknife", "bootstrap"),
        nreplicates = 100, ncpus = getOption("boot.ncpus"),
        family = poisson, weights = NULL,
        start = NA, etastart = NULL, tolerance = 1e-8,
        iterMax = 15000, trace = FALSE, verbose = TRUE, ...)
}
\arguments{
  \item{tab}{ a two-way table, or an object (such as a matrix) that can be coerced into a table;
    if present, dimensions above two will be collapsed.}
  \item{nd.symm}{ the number of dimensions to include in the \emph{symmetric} RC(M) association. Cannot exceed
    \code{2 * min(nrow(tab) - 1, ncol(tab) - 1)}.
    If \code{NA}, a quasi-symmetric association is used instead of a RC(M) model.}
  \item{nd.skew}{ the number of dimensions to include in the \emph{skew-symmetric} RC(M) association.}
  \item{diagonal}{ should the model include parameters specific to each diagonal cell? This amounts to
    taking quasi-independence, rather than independence, as the baseline model.}
  \item{weighting}{ what weights should be used when normalizing the scores.}
  \item{se}{ which method to use to compute standard errors for parameters.}
  \item{nreplicates}{ the number of bootstrap replicates, if enabled.}
  \item{ncpus}{ the number of processes to use for jackknife or bootstrap parallel computing. Defaults to
    the number of cores (see \code{\link[parallel]{detectCores}}), with a maximum of 5, but falls back to 1
    (no parallelization) if package \code{parallel} is not available.}
  \item{family}{ a specification of the error distribution and link function
     to be used in the model. This can be a character string naming
     a family function; a family function, or the result of a call
     to a family function. See \code{\link{family}} details of family functions.}
  \item{weights}{ an optional vector of weights to be used in the fitting process.}
  \item{start}{either \code{NA} (the default) to use reasonable starting values, \code{NULL} to use
     random starting values, or a vector of starting values for the parameters in the model.}
  \item{etastart}{ starting values for the linear predictor; set to \code{NULL} to use either default
     starting values (if \code{start = NA}), or random starting values (in all other cases).}
  \item{tolerance}{ a positive numeric value specifying the tolerance level for
     convergence; higher values will speed up the fitting process, but beware of numerical
     instability of estimated scores!}
  \item{iterMax}{ a positive integer specifying the maximum number of main iterations to perform;
     consider raising this value if your model does not converge.}
  \item{trace}{ a logical value indicating whether the deviance
     should be printed after each iteration.}
  \item{verbose}{ a logical value indicating whether progress indicators should be printed,
     including a diagnostic error message if the algorithm restarts.}
  \item{\dots}{ more arguments to be passed to \code{\link{gnm}}}
}
\details{
  The original presented by Yamaguchi (1990), called \dQuote{row-column-effect skew-symmetric
  association (logbilinear) model with full quasi-symmetry (QS+RC_SK)}, combines a skew-symmetric association
  with a quasi-symmetry baseline; it is the variant fitted by default by this function. If \code{nd.symm} is
  set to a positive integer value, though, variants using a RC(M) model to describe the \emph{symmetric association}
  are used, with our without diagonal-specific parameters (depending on the value of the \code{diagonal} argument);
  among them is the HM_RC+RC_SK variant, when \code{nd.symm} is 1.

  These models follow the equation:
  \deqn{ log F_{ij} = q_{ij} + \delta_{i<j} \nu_i (\nu_j - \nu_i) - \delta_{i>j} \nu_j (\nu_i - \nu_j) }
  where \eqn{F_{ij}} is the expected frequency for the cell at the intersection of row i and column j of
  \code{tab}, and \eqn{q_{ij}} a quasi-symmetric or a RC(M) association. See reference for detailed information
  about the degrees of freedom and the identification constraints applied to the scores.

  Please note that contrary to other association models, this model is sensitive to reorderings of rows and columns.
  You have to take care of passing a table whose categories follow a hierarchical order with a substantive meaning.

  Another model presented in the paper, the homogeneous symmetric and skew-symmetric associations models (HM_(S+SK))
  is not currently supported.

  Actual model fitting is performed using \code{\link{gnm}}, which implements the Newton-Raphson algorithm.
  This function simply ensures correct start values are used, in addition to allowing for identification
  of scores even with several dimensions, computation of their jackknife or bootstrap standard errors, and plotting.
  The default starting values for main parameters are taken from the model without association parameters
  (\dQuote{base model}); association parameters start with random starting values. In some complex
  cases, using \code{start = NULL} to get completely random starting values can be more efficient, but it is also
  less stable and can converge to non-optimal solutions.
}
\value{
  A \code{yrcskew} object, which is a subclass of an \code{rc.symm} object (see\code{\link{rc}}) unless
    \code{nd.symm} is \code{NA}. In addition to this class, it contains a \code{assoc.yrcskew} component
    holding information about the \emph{skew-symmetric} association:
  \item{phi }{The intrisic association parameters, one per dimension.}
  \item{row }{Row scores, normalized so that their (weighted) sum is 0, their (weighted)
    sum of squares is 1, and their (weighted) cross-dimensional correlation is null.}
  \item{col }{Column scores, normalized so that their (weighted) sum is 0, their (weighted)
    sum of squares is 1, and their (weighted) cross-dimensional correlation is null.}
  \item{row.weights }{The row weights used for the identification of scores, as specified by the
    \code{weighting} argument.}
  \item{col.weights }{The column weights used for the identification of scores, as specified by the
    \code{weighting} argument.}
  \item{covmat }{The variance-covariance matrix for phi coefficients and normalized row and column
    scores. Only present if \code{se} was not \dQuote{none}.}
  \item{adj.covmats }{An array stacking on its third dimension one variance-covariance matrix for
    the adjusted scores of each layer in the model (used for plotting). Only present if \code{se}
    was not \dQuote{none}.}
  \item{covtype }{The method used to compute the variance-covariance matrix (corresponding to the
    \code{se} argument.}
}
\section{Warning}{
  This family of model sometimes converges to a non-optimal solution, in which case the reported scores
  are wrong. To protect yourself from this problem, you are advised to run the models several times to find out which
  convergence point is the true one. Furthermore, when model converges slowly, restarting the fitting procedure may produce
  much better random starting values.
}
\references{
    Yamaguchi, K. (1990). Some Models for the Analysis of Asymmetric Association in Square Contingency Tables with
      Ordered Categories. \emph{Sociol. Methodology} 20, 181-212.
}
\author{
Milan Bouchet-Valat
}
\seealso{
  \code{\link{plot.yrcskew}}, \code{\link{gnm}}
}
\examples{
  ## Yamaguchi (1990), Table 5, p. 202, and Table 6B, p. 205
  data(ocg1973)

  # Simple symmetric RC(1) model ("Null skew-symmetry")
  rc.model <- rc(ocg1973, diagonal=TRUE, symmetric=TRUE, weighting="none")
  # Reported phi is slightly different, coefficients agree
  rc.model

  # Note model does not always converge, several attempts may be needed
  # Here we set known starting values to be sure it works
  set.seed(5)
  model <- yrcskew(ocg1973, nd.symm=1, nd.skew=1, diagonal=TRUE, weighting="none")

  # We do not get the same results as the author, but the smaller deviance
  # indicates a better fit in our version (!)
  model
}
