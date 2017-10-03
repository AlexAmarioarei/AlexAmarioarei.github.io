# means = your means. , contained in a vector, eg c(mean1, means2...) 
# SEs =  your standard errors, contained in a vector, 
# CI.hi = upper confidence intervals, in a vector, 
# CI.lo = lower confidence itnerval, in a vector
# categories = the names of the categories/groups, in the order that they appear
# x.axis.label = what should be plotted on the x axis
# y.axis.label = what should be plotted on the y axis
# adjust.y.max = allows you to adjust the y axis
# adjust.y.min
# adjust.x.spacing
#### The function STARTS here ####
plot.means <- function(means = NULL,
                       SEs = NULL,
                       CI.hi = NULL,
                       CI.lo = NULL,
                       categories = NULL,
                       x.axis.label = "Groups",
                       y.axis.label = "'y.axis.label' sets the axis label",
                       adjust.y.max = 0,
                       adjust.y.min = 0,
                       adjust.x.spacing = 5){
  
  
  # Error messages
  if(is.null(means)==T){
    stop("No means entered") } 
  
  if(is.null(SEs)==T & is.null(CI.lo) == T){
    stop("No standard errors entered") } 
  
  if(is.null(CI.lo) != T &  is.null(CI.hi)){
    stop("CI.lo entered but no CI.hi") } 
  
  if(is.null(CI.hi) != T &  is.null(CI.lo)){
    stop("CI.hi entered but no CI.lo") } 
  
  #check if both SE and and CI.is enter
  if(is.null(SEs) == F &  is.null(CI.hi) == F){
    stop("Both SEs and CI.hi entered; use eithe SEs or CIs") } 
  
  if(is.null(SEs) == F &  is.null(CI.lo) == F){
    stop("Both SEs and CI.lo entered; use eithe SEs or CIs") } 
  
  #Check if the number of means matches the number of SE
  n.means <- length(means)
  n.SEs    <- length(SEs)
  n.CI.lo  <- length(CI.lo)
  n.CI.hi  <- length(CI.hi)
  
  #CHeck standard errors against means
  if(n.means != n.SEs & is.null(CI.lo)==T){
    error.message <- paste("The number of means is",n.means,"but the number of standard errors is",n.SEs,sep = " ")
    stop(error.message) } 
  
  #Check CIs against CIs
  if(n.CI.lo != n.CI.hi){
    error.message <- paste("The number of CI.lo is",n.CI.lo,"but the number of standard errors is",n.CI.hi,sep = " ")
    stop(error.message) } 
  
  
  #assign arbitrary categories
  if(is.null(categories) == T) {
    categories <- paste("Group",1:n.means)
    print("Set categoris labls with 'categories=' ")
  }
  
  
  # calculate values for plotting limits 
  if(is.null(SEs)==F){
    y.max <- max(means+2*SEs) + adjust.y.max
    y.min <- min(means-2*SEs) - adjust.y.min
  }
  
  # calculate values for plotting limits 
  if(is.null(SEs)==T){
    y.max <- max(CI.hi) + adjust.y.max
    y.min <- min(CI.lo) - adjust.y.min
  }
  
  
  #determine where to plot points along x-axis
  x.values <- 1:n.means
  x.values <- x.values/adjust.x.spacing
  
  #set x axis min/max
  x.axis.min <- min(x.values)-0.05
  x.axis.max <- max(x.values)+0.05
  
  x.limits <- c(x.axis.min,x.axis.max)
  
  #Plot means
  plot(means ~ x.values,
       xlim = x.limits,
       ylim = c(y.min,y.max),
       xaxt = "n",
       xlab = "",
       ylab = "",
       cex = 1.25,
       pch = 16)
  
  #Add x labels
  axis(side = 1, 
       at = x.values,
       labels = categories
  )
  
  
  # Plot confidence intervals
  if(is.null(CI.hi) == FALSE & 
     is.null(CI.lo) == FALSE){
    #Plot upper error bar for CIs
    lwd. <- 2
    arrows(y0 = means,
           x0 = x.values,
           y1 = CI.hi,
           x1 = x.values,
           length = 0,
           lwd = lwd.)
    
    #Plot lower error bar
    arrows(y0 = means,
           x0 = x.values,
           y1 = CI.lo,
           x1 = x.values,
           length = 0,
           lwd = lwd.)
  }
  
  
  # Estimate CIs from SEs
  
  if(is.null(SEs) == FALSE & 
     is.null(CI.lo) == TRUE){
    lwd. <- 2
    arrows(y0 = means,
           x0 = x.values,
           y1 = means+2*SEs,
           x1 = x.values,
           length = 0,
           lwd = lwd.)
    
    #Plot lower error bar
    arrows(y0 = means,
           x0 = x.values,
           y1 = means-2*SEs,
           x1 = x.values,
           length = 0,
           lwd = lwd.) 
  }
  
  mtext(text = x.axis.label,side = 1,line = 2)
  mtext(text = y.axis.label,side = 2,line = 2)
  mtext(text = "Error bars = 95% CI",side = 3,line = 0,adj = 0)
  
  
  
}

#### The function ENDS here ####
#### The function ENDS here ####
#### The function ENDS here ####
#### The function ENDS here ####
#### The function ENDS here ####