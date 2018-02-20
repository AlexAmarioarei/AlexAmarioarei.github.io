#' @title Visualize the fit of a simple linear model
#'
#' @description Generates a plot illustrating the key concepts for a fitted simple linear model: linear trend, model-based confidence bands and normality around the mean.
#'
#' @param data a \code{data.frame} containing \code{X} and \code{Y} as variables.
#' @param nGrid number of cuts used to produce the XY grid.
#' @param zTop upper z-limit of the 3D bounding box.
#' @inheritParams graphics::persp
#' @param alpha desired level for the theoretical confidence intervals. If set to \code{0}, no confidence intervals are plotted.
#' @return
#' Nothing. The function is called to produce a plot.
#' @examples
#' # Generate data
#' X <- rnorm(100)
#' Y <- 0.5 + 1.5 * X + rnorm(100)
#' data <- data.frame(X = X, Y = Y)
#'
#' par(mar = rep(0, 4), oma = rep(0, 4))
#' visualizeFitLm(data = data)
#' visualizeFitLm(data = data, alpha = 0)
#' @author Eduardo García-Portugués (\email{edgarcia@est-econ.uc3m.es}), based on the original code from Arthur Charpentier (\url{http://freakonometrics.hypotheses.org/9593}).
#' @export
visualizeFitLm <- function(data, nGrid = 6, zTop = 0.5, theta = -30, phi = 20,
                           alpha = 0.05, main = NULL) {
  
  # Estimate lm
  n <- length(data$X)
  mod <- lm(Y ~ X, data = data)
  
  # Create and plot initial XY-grid
  sdX <- sd(data$X)
  sdY <- sd(data$Y)
  gX <- seq(min(data$X) - sdX, max(data$X) + sdX, length = nGrid)
  gY <- seq(min(data$Y) - sdY, max(data$Y) + sdY, length = nGrid)
  gridMat <- persp(gX, gY, matrix(0, nGrid, nGrid), zlim = c(0, zTop),
                   theta = theta, phi = phi, box = FALSE, border = gray(0.75))
  text(x = trans3d(median(gX), min(gY), 0, gridMat), labels = "x", pos = 1)
  text(x = trans3d(min(gX), median(gY), 0, gridMat), labels = "y", pos = 2)
  
  if (!is.null(main)){
    text(x = trans3d(mean(gX), max(gY), zTop, gridMat), labels = main, pos = 2, cex = 1.35)
  }
 
  
  # Compute regression curve
  lx <- 501
  x <- seq(gX[1], gX[nGrid], length = lx)
  zeros <- rep(0, lx)
  new <- data.frame(X = x)
  pred <- predict(mod, newdata = new, type = "response")
  pred[pred < gY[1]] <- NA
  pred[pred > gY[nGrid]] <- NA
  
  # Compute theoretical confidence bands
  sigma <- summary(mod)$sigma
  if (alpha > 0) {
    
    # Limits
    yDown <- qnorm(alpha/2, pred, sigma)
    yUp <- qnorm(1 - alpha/2, pred, sigma)
    yDownCut <- pmax(yDown, gY[1])
    yUpCut <- pmin(yUp, gY[nGrid])
    yDown[yDown < gY[1]] <- NA
    yUp[yUp > gY[nGrid]] <- NA
    
    # Plot confidence region
    polygon(trans3d(c(x, rev(x)), c(yDownCut, rev(yUpCut)), rep(0, 2 * lx),
                    gridMat), border = NA, col = "yellow", density = 40)
    lines(trans3d(x, yDown, zeros, gridMat), lty = 2)
    lines(trans3d(x, yUp, zeros, gridMat), lty = 2)
    
  }
  
  # Plot regression curve
  lines(trans3d(x, pred, zeros, gridMat), lwd = 2)
  
  # Plot data
  points(trans3d(data$X, data$Y, rep(0, n), gridMat), pch = 16, col = "brown3",
         cex = 0.75)
  
  # Plot densities
  mgig <- predict(mod, newdata = data.frame(X = gX))
  nGridDens <- 251
  z0 <- rep(0, nGridDens)
  y <- seq(gY[1], gY[nGrid], length = nGridDens)
  for (j in (nGrid - 1):2) {
    
    x <- rep(gX[j], nGridDens)
    z <- dnorm(y, mean = mgig[j], sd = sigma)
    polygon(trans3d(rep(x, 2), c(y, rev(y)), c(z, z0), gridMat),
            border = NA, col = "lightgrey", density = 40)
    lines(trans3d(x, y, z0, gridMat), col = "lightgrey", lty = 2)
    lines(trans3d(x, y, z, gridMat), col = "grey30")
    
  }
  
}