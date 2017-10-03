#' @title Visualize the fit of a multiple linear model
#'
#' @description Generates a plot illustrating the key concepts for a fitted multiple linear model: linear trend, model-based confidence bands and normality around the mean.
#'
#' @param data a \code{data.frame} containing \code{X}, \code{Y} and \code{Z} as variables.
#' @param nGrid (approximate) number of cuts used to produce the XYZ grid. Computed to match the effective \code{nticks} in \code{\link[graphics]{persp}}.
#' @inheritParams visualizeFitLm
#' @inheritParams graphics::persp
#' @param basalScatter Add the projections of points in the XY plane?
#' @param lmLaterals Add the projections of points in the XZ and YZ planes, with a (marginal) regression line?
#' @return
#' Nothing. The function is called to produce a plot.
#' @examples
#' # Generate data
#' X <- rnorm(100, sd = 1.5)
#' Y <- rnorm(100, sd = 1.5)
#' Z <- 0.5 - 0.25 * X + 0.15 * Y + rnorm(100)
#' data <- data.frame(X = X, Y = Y, Z = Z)
#'
#' par(mar = rep(0, 4), oma = rep(0, 4))
#' visualizeFitLm3D(data = data, lmLaterals = FALSE)
#' visualizeFitLm3D(data = data, phi = 10, lmLaterals = FALSE)
#'
#' # Illustrate marginal regression lines
#' set.seed(212542)
#' n <- 100
#' x <- rnorm(n, sd = 2)
#' y <- rnorm(n, mean = x, sd = 3)
#' z <- 1 + 2 * x - y + rnorm(n, sd = 1)
#' summary(lm(z ~ x))
#' summary(lm(z ~ y))
#' summary(lm(z ~ x + y))
#' data <- data.frame(X = x, Y = y, Z = z)
#' par(mar = rep(0, 4), oma = rep(0, 4))
#' visualizeFitLm3D(data = data, alpha = 0, theta = -45, phi = 20)
#' @author Eduardo García-Portugués (\email{edgarcia@est-econ.uc3m.es}).
#' @export
visualizeFitLm3D <- function(data, nGrid = 5, theta = -30, phi = 20,
                             alpha = 0.05, basalScatter = TRUE,
                             lmLaterals = TRUE) {
  
  # Estimate lm
  mod <- lm(Z ~ X + Y, data = data)
  n <- length(data$X)
  
  # Create and plot initial XYZ-grid
  sdX <- sd(data$X)
  sdY <- sd(data$Y)
  sdZ <- sd(data$Z)
  gX <- seq(min(data$X) - sdX, max(data$X) + sdX, length = nGrid)
  gY <- seq(min(data$Y) - sdY, max(data$Y) + sdY, length = nGrid)
  gZ <- seq(min(data$Z) - sdZ, max(data$Z) + sdZ, length = nGrid)
  
  # Compute regression surface
  x <- pretty(gX, nGrid)
  y <- pretty(gY, nGrid)
  x <- c(gX[1], x[x > gX[1] & x < gX[nGrid]], gX[nGrid])
  y <- c(gY[1], y[y > gY[1] & y < gY[nGrid]], gY[nGrid])
  lx <- length(x)
  ly <- length(y)
  xy <- expand.grid(x = x, y = y)
  new <- data.frame(X = xy$x, Y = xy$y)
  pred <- predict(mod, newdata = new, type = "response")
  gZ <- seq(min(c(gZ, pred)), max(c(gZ, pred)), length = nGrid)
  
  # Compute theoretical confidence bands
  if (alpha > 0) {
    
    sigma <- summary(mod)$sigma
    zDown <- qnorm(alpha/2, pred, sigma)
    zUp <- qnorm(1 - alpha/2, pred, sigma)
    gZ <- seq(min(c(gZ, zDown)), max(c(gZ, zUp)), length = nGrid)
    
  }
  
  # Plot data and regression
  # require(plot3D)
  panelFirst <- function(pmat) {
    
    # Plot points projection in the basal plane
    if (basalScatter) {
      
      XY <- trans3D(data$X, data$Y, rep(gZ[1], n), pmat = pmat)
      scatter2D(XY$x, XY$y, pch = 16, cex = 0.5, add = TRUE,
                colkey = FALSE, col = 1)
      
    }
    
    # Plot points projection in the basal plane
    if (lmLaterals) {
      
      XZ <- trans3D(data$X, rep(gY[nGrid], n), data$Z, pmat = pmat)
      scatter2D(XZ$x, XZ$y, pch = 16, cex = 0.5, add = TRUE,
                colkey = FALSE, col = 1)
      mod <- lm(Z ~ X, data = data)
      lines(trans3D(gX, rep(gY[nGrid], nGrid),
                    mod$coefficients[1] + mod$coefficients[2] * gX, pmat),
            col = 3, lwd = 2)
      
      YZ <- trans3D(rep(gX[nGrid], n), data$Y, data$Z, pmat = pmat)
      scatter2D(YZ$x, YZ$y, pch = 16, cex = 0.5, add = TRUE,
                colkey = FALSE, col = 1)
      mod <- lm(Z ~ Y, data = data)
      lines(trans3D(rep(gX[nGrid], nGrid), gY,
                    mod$coefficients[1] + mod$coefficients[2] * gY, pmat),
            col = 3, lwd = 2)
      
    }
    
  }
  gridMat <- scatter3D(data$X, data$Y, data$Z, pch = 16, theta = theta, phi = phi,
                       bty = "g", axes = FALSE, colkey = FALSE, col = "brown3",
                       xlim = range(gX), ylim = range(gY), zlim = range(gZ),
                       panel.first = panelFirst, nticks = nGrid, cex = 0.75)
  text(x = trans3d(median(gX), gY[1], gZ[1], gridMat), labels = "x1", pos = 1)
  text(x = trans3d(gX[1], median(gY), gZ[1], gridMat), labels = "x2", pos = 2)
  text(x = trans3d(gX[1], gY[nGrid], median(gZ), gridMat), labels = "y", pos = 2)
  
  # Plot confidence region
  M <- mesh(x, y)
  if (alpha > 0) {
    
    surf3D(x = M$x, y = M$y, z = matrix(zUp, nrow = lx, ncol = ly), col = "yellow",
           alpha = 0.1, add = TRUE, border = "yellow2")
    surf3D(x = M$x, y = M$y, z = matrix(zDown, nrow = lx, ncol = ly), col = "yellow",
           alpha = 0.1, add = TRUE, border = "yellow2")
    
  }
  surf3D(x = M$x, y = M$y, z = matrix(pred, nrow = lx, ncol = ly), col = "lightblue",
         alpha = 0.2, border = gray(0.5), add = TRUE)
  
}

#' # Generate data
# X <- rnorm(100, sd = 1.5)
# Y <- rnorm(100, sd = 1.5)
# Z <- 0.5 - 0.25 * X + 0.15 * Y + rnorm(100)
# data <- data.frame(X = X, Y = Y, Z = Z)
# 
# par(mar = rep(0, 4), oma = rep(0, 4))
# visualizeFitLm3D(data = data, lmLaterals = FALSE)
# visualizeFitLm3D(data = data, phi = 10, lmLaterals = FALSE)

# # Illustrate marginal regression lines
# set.seed(212542)
# n <- 100
# x <- rnorm(n, sd = 2)
# y <- rnorm(n, mean = x, sd = 3)
# z <- 1 + 2 * x - y + rnorm(n, sd = 1)
# summary(lm(z ~ x))
# summary(lm(z ~ y))
# summary(lm(z ~ x + y))
# data <- data.frame(X = x, Y = y, Z = z)
# par(mar = rep(0, 4), oma = rep(0, 4))
# visualizeFitLm3D(data = data, alpha = 0, theta = -45, phi = 20)
