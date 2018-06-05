lmModelPlot <- function(x, y, xlim,ylim, meanPred, LwPred, UpPred, 
                         plotData, main=NULL){
  ## Based on code by Arthur Charpentier:
  ## http://freakonometrics.hypotheses.org/9593
  par(mfrow=c(1,1))
  n <- 2
  N <- length(plotData)#length(meanPred)
  zMax <- max(unlist(sapply(plotData, "[[", "z")))*1.5
  
  ylim[1] = min(ylim[1], LwPred) 
  ylim[2] = max(ylim[2], UpPred) 
  
  mat <- persp(xlim, ylim, matrix(0, n, n), 
               main=main,
               zlim=c(0, zMax), 
               theta=-30, 
               # ticktype="detailed",
               box=FALSE,
               border = "grey",
               expand = 0.5,
               xlab = "x",
               ylab = "y")
  
  C <- trans3d(x, UpPred, rep(0, N),mat)
  lines(C, lty=2, col = "black")
  C <- trans3d(x, LwPred, rep(0, N), mat)
  lines(C, lty=2, col = "black")
  C <- trans3d(c(x, rev(x)), c(UpPred, rev(LwPred)),
               rep(0, 2*N), mat)
  polygon(C, border = NA, col = adjustcolor("yellow", alpha.f = 0.5))
  C <- trans3d(x, meanPred, rep(0, N), mat)
  lines(C, lwd=2, col="black")
  C <- trans3d(x, y, rep(0,N), mat)
  points(C, lwd=2, col="red", pch = 18)
  for(j in N:1){
    xp <- plotData[[j]]$x
    yp <- plotData[[j]]$y
    z0 <- plotData[[j]]$z0
    zp <- plotData[[j]]$z
    C <- trans3d(c(xp, xp), c(yp, rev(yp)), c(zp, z0), mat)
    polygon(C, border=NA, col="light blue", density=40)
    C <- trans3d(xp, yp, z0, mat)
    lines(C, lty=2, col = "grey")
    C <- trans3d(xp, yp, zp, mat)
    lines(C, col=adjustcolor("blue", alpha.f = 0.5))
  }
  
}