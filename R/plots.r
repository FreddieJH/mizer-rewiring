# Plotting methods for the MizerSim class

# Copyright 2012 Finlay Scott and Julia Blanchard. Distributed under the GPL 2 or later
# Maintainer: Finlay Scott, CEFAS

# Biomass through time
# Pretty easy - user could do it themselves by hand for fine tuning if necessary
 
#' Plot the biomass of each species through time
#'
#' After running a projection, the biomass of each species can be plotted against time. The biomass is calculated within user defined size limits (see \code{\link{getBiomass}}).
#' This plot is pretty easy to do by hand. It just gets the biomass using the \code{\link{getBiomass}} method and plots using ggplot2. You can then fiddle about with colours and linetypes etc. Just look at the source code for details.
#' 
#' @param object An object of class \code{MizerSim}
#' @param min_w minimum weight of species to be used in the calculation
#' @param max_w maximum weight of species to be used in the calculation
#' @param min_l minimum length of species to be used in the calculation
#' @param max_l maximum length of species to be used in the calculation
#'
#' @return A ggplot2 object
#' @export
#' @docType methods
#' @rdname plotBiomass-methods
#' @examples
#' \dontrun{
#' data(species_params_gears)
#' data(inter)
#' params <- MizerParams(species_params_gears, inter)
#' sim <- project(params, effort=1, t_max=20, t_save = 2)
#' plotBiomass(sim)
#' plotBiomass(sim, min_l = 10, max_l = 25)
#' }
setGeneric('plotBiomass', function(object, ...)
    standardGeneric('plotBiomass'))
#' @rdname plotBiomass-methods
#' @aliases plotBiomass,MizerSim-method
setMethod('plotBiomass', signature(object='MizerSim'),
    function(object, ...){
	b <- getBiomass(object, ...)
	names(dimnames(b))[names(dimnames(b))=="sp"] <- "Species"
	bm <- melt(b)
	p <- ggplot(bm) + geom_line(aes(x=time,y=value, colour=Species, linetype=Species)) + scale_y_continuous(trans="log10", name="Biomass") + scale_x_continuous(name="Time") 
	print(p)
	return(p)
    })

#' Plot the total yield of each species through time
#'
#' After running a projection, the total yield of each species across all
#' fishing gears can be plotted against time. 
#' 
#' @param object An object of class \code{MizerSim}
#'
#' @return A ggplot2 object
#' @export
#' @docType methods
#' @rdname plotYield-methods
#' @examples
#' \dontrun{
#' data(species_params_gears)
#' data(inter)
#' params <- MizerParams(species_params_gears, inter)
#' sim <- project(params, effort=1, t_max=20, t_save = 2)
#' plotYield(sim)
#' }
setGeneric('plotYield', function(object, ...)
    standardGeneric('plotYield'))
#' @rdname plotYield-methods
#' @aliases plotYield,MizerSim-method
setMethod('plotYield', signature(object='MizerSim'),
    function(object, ...){
	y <- getYield(object, ...)
	names(dimnames(y))[names(dimnames(y))=="sp"] <- "Species"
	ym <- melt(y)
	p <- ggplot(ym) + geom_line(aes(x=time,y=value, colour=Species, linetype=Species)) + scale_y_continuous(trans="log10", name="Yield") + scale_x_continuous(name="Time") 
	print(p)
	return(p)
    })

#' Plot the total yield of each species by gear through time
#'
#' After running a projection, the total yield of each species by 
#' fishing gear can be plotted against time. 
#' 
#' @param object An object of class \code{MizerSim}
#'
#' @return A ggplot2 object
#' @export
#' @docType methods
#' @rdname plotYieldGear-methods
#' @examples
#' \dontrun{
#' data(species_params_gears)
#' data(inter)
#' params <- MizerParams(species_params_gears, inter)
#' sim <- project(params, effort=1, t_max=20, t_save = 2)
#' plotYieldGear(sim)
#' }
setGeneric('plotYieldGear', function(object, ...)
    standardGeneric('plotYieldGear'))
#' @rdname plotYieldGear-methods
#' @aliases plotYieldGear,MizerSim-method
setMethod('plotYieldGear', signature(object='MizerSim'),
    function(object, ...){
	y <- getYieldGear(object, ...)
	names(dimnames(y))[names(dimnames(y))=="sp"] <- "Species"
	ym <- melt(y)
	p <- ggplot(ym) + geom_line(aes(x=time,y=value, colour=Species, linetype=gear)) + scale_y_continuous(trans="log10", name="Yield") + scale_x_continuous(name="Time") 
	print(p)
	return(p)
    })

#' Plot the abundance spectra of each species and the background population
#'
#' After running a projection, the spectra of the abundance of each species and the background population can be plotted.
#' The abundance is averaged over the specified time range (a single value for the time range can be used).
#' The abundance can be in terms of numbers or biomass, depending on the \code{biomass} argument.
#' 
#' @param object An object of class \code{MizerSim}
#' @param time_range The time range (either a vector of values, a vector of min and max time, or a single value) to average the abundances over. Default is the final time step.
#' @param min_w Minimum weight to be plotted (useful for truncating the background spectrum). Default value is a tenth of the minimum size value of the community. 
#' @param biomass A boolean value. Should the biomass spectrum (TRUE) be plotted or the abundance in numbers (FALSE). Default is TRUE.
#'
#' @return A ggplot2 object
#' @export
#' @docType methods
#' @rdname plotSpectra-methods
setGeneric('plotSpectra', function(object, ...)
    standardGeneric('plotSpectra'))
#' @rdname plotSpectra-methods
#' @aliases plotSpectra,MizerSim-method
#' @examples
#' \dontrun{
#' data(species_params_gears)
#' data(inter)
#' params <- MizerParams(species_params_gears, inter)
#' sim <- project(params, effort=1, t_max=20, t_save = 2)
#' plotSpectra(sim)
#' plotSpectra(sim, min_w = 1e-6)
#' plotSpectra(sim, time_range = 10:20)
#' plotSpectra(sim, time_range = 10:20, biomass = FALSE)
#' }
setMethod('plotSpectra', signature(object='MizerSim'),
    function(object, time_range = max(as.numeric(dimnames(object@n)$time)), min_w =min(object@params@w)/10, biomass = TRUE, ...){
	time_elements <- get_time_elements(object,time_range)
	spec_n <- apply(object@n[time_elements,,,drop=FALSE],c(2,3), mean)
	background_n <- apply(object@n_pp[time_elements,,drop=FALSE],2,mean)
	y_axis_name = "Abundance"
	if (biomass){
	    spec_n <- sweep(spec_n,2,object@params@w,"*")
	    background_n <- background_n * object@params@w_full
	    y_axis_name = "Biomass"
	}
	# Make data.frame for plot
	plot_dat <- data.frame(value = c(spec_n), Species = dimnames(spec_n)[[1]], w = rep(object@params@w, each=nrow(object@params@species_params)))
	plot_dat <- rbind(plot_dat, data.frame(value = c(background_n), Species = "Background", w = object@params@w_full))
	# lop off 0s in background and apply min_w
	plot_dat <- plot_dat[(plot_dat$value > 0) & (plot_dat$w >= min_w),]
	p <- ggplot(plot_dat) + geom_line(aes(x=w, y = value, colour = Species, linetype=Species)) + scale_x_continuous(name = "Size", trans="log10") + scale_y_continuous(name = y_axis_name, trans="log10")
	print(p)
	return(p)
    })


#' Plot the feeding level of each species by size 
#'
#' After running a projection, plot the feeding level of each species by size.
#' The feeding level is averaged over the specified time range (a single value for the time range can be used).
#' 
#' @param object An object of class \code{MizerSim}
#' @param time_range The time range (either a vector of values, a vector of min and max time, or a single value) to average the abundances over. Default is the final time step.
#'
#' @return A ggplot2 object
#' @export
#' @docType methods
#' @rdname plotFeedingLevel-methods
setGeneric('plotFeedingLevel', function(object, ...)
    standardGeneric('plotFeedingLevel'))
#' @rdname plotFeedingLevel-methods
#' @aliases plotFeedingLevel,MizerSim-method
#' @examples
#' data(species_params_gears)
#' data(inter)
#' params <- MizerParams(species_params_gears, inter)
#' sim <- project(params, effort=1, t_max=20, t_save = 2)
#' #plotFeedingLevel(sim)
#' #plotFeedingLevel(sim, time_range = 10:20)
setMethod('plotFeedingLevel', signature(object='MizerSim'),
    function(object, time_range = max(as.numeric(dimnames(object@n)$time)), ...){
	feed_time <- getFeedingLevel(object, time_range=time_range, .drop=FALSE, ...)
	feed <- apply(feed_time, c(2,3), mean)
	plot_dat <- data.frame(value = c(feed), Species = dimnames(feed)[[1]], w = rep(object@params@w, each=nrow(object@params@species_params)))
	p <- ggplot(plot_dat) + geom_line(aes(x=w, y = value, colour = Species, linetype=Species)) + scale_x_continuous(name = "Size", trans="log10") + scale_y_continuous(name = "Feeding Level", lim=c(0,1))
	print(p)
	return(p)
    })

#' Plot M2 of each species by size 
#'
#' After running a projection, plot M2 of each species by size.
#' M2 is averaged over the specified time range (a single value for the time range can be used).
#' 
#' @param object An object of class \code{MizerSim}
#' @param time_range The time range (either a vector of values, a vector of min and max time, or a single value) to average the abundances over. Default is the final time step.
#'
#' @return A ggplot2 object
#' @export
#' @docType methods
#' @rdname plotM2-methods
setGeneric('plotM2', function(object, ...)
    standardGeneric('plotM2'))
#' @rdname plotM2-methods
#' @aliases plotM2,MizerSim-method
#' @examples
#' data(species_params_gears)
#' data(inter)
#' params <- MizerParams(species_params_gears, inter)
#' sim <- project(params, effort=1, t_max=20, t_save = 2)
#' #plotM2(sim)
#' #plotM2(sim, time_range = 10:20)
setMethod('plotM2', signature(object='MizerSim'),
    function(object, time_range = max(as.numeric(dimnames(object@n)$time)), ...){
	m2_time <- getM2(object, time_range=time_range, .drop=FALSE, ...)
	m2 <- apply(m2_time, c(2,3), mean)
	plot_dat <- data.frame(value = c(m2), Species = dimnames(m2)[[1]], w = rep(object@params@w, each=nrow(object@params@species_params)))
	p <- ggplot(plot_dat) + geom_line(aes(x=w, y = value, colour = Species, linetype=Species)) + scale_x_continuous(name = "Size", trans="log10") + scale_y_continuous(name = "M2", lim=c(0,max(plot_dat$value)))
	print(p)
	return(p)
    })

#' Plot total fishing mortality of each species by size 
#'
#' After running a projection, plot the total fishing mortality of each species by size.
#' The total fishing mortality is averaged over the specified time range (a single value for the time range can be used).
#' 
#' @param object An object of class \code{MizerSim}
#' @param time_range The time range (either a vector of values, a vector of min and max time, or a single value) to average the abundances over. Default is the final time step.
#'
#' @return A ggplot2 object
#' @export
#' @docType methods
#' @rdname plotFMort-methods
setGeneric('plotFMort', function(object, ...)
    standardGeneric('plotFMort'))
#' @rdname plotFMort-methods
#' @aliases plotFMort,MizerSim-method
#' @examples
#' \dontrun{
#' data(species_params_gears)
#' data(inter)
#' params <- MizerParams(species_params_gears, inter)
#' sim <- project(params, effort=1, t_max=20, t_save = 2)
#' plotFMort(sim)
#' plotFMort(sim, time_range = 10:20)
#' }
setMethod('plotFMort', signature(object='MizerSim'),
    function(object, time_range = max(as.numeric(dimnames(object@n)$time)), ...){
	f_time <- getFMort(object, time_range=time_range, .drop=FALSE, ...)
	f <- apply(f_time, c(2,3), mean)
	plot_dat <- data.frame(value = c(f), Species = dimnames(f)[[1]], w = rep(object@params@w, each=nrow(object@params@species_params)))
	p <- ggplot(plot_dat) + geom_line(aes(x=w, y = value, colour = Species, linetype=Species)) + scale_x_continuous(name = "Size", trans="log10") + scale_y_continuous(name = "Total fishing mortality", lim=c(0,max(plot_dat$value)))
	print(p)
	return(p)
    })


#' Summary plot for \class{MizerObject}s
#'
#' After running a projection, produces 5 plots in the same window:
#' feeding level, abundance spectra, predation mortality and fishing
#' mortality of each species by size; and biomass of each species through
#' time.
#' This method just uses the other plotting methods and puts them
#' all in one window.
#' 
#' @param object An object of class \code{MizerSim}
#' @param ...  For additional arguments see the documentation for \code{plotBiomass}, \code{plotFeedingLevel},\code{plotSpectra},\code{plotM2} and \code{plotFMort}.
#' @return A viewport object
#' @export
#' @docType methods
#' @rdname plot-methods
#' @aliases plot,MizerSim,missing-method
#' @examples
#' \dontrun{
#' data(species_params_gears)
#' data(inter)
#' params <- MizerParams(species_params_gears, inter)
#' sim <- project(params, effort=1, t_max=20, t_save = 2)
#' plot(sim)
#' plot(sim, time_range = 10:20) # change time period for size-based plots
#' plot(sim, min_l = 10, max_l = 25) # change size range for biomass plot
#' }
setMethod("plot", signature(x="MizerSim", y="missing"),
    function(x, ...){
	p1 <- plotFeedingLevel(x,...)
	p2 <- plotSpectra(x,...)
	p3 <- plotBiomass(x,...)
	p4 <- plotM2(x,...)
	p5 <- plotFMort(x,...)
	grid.newpage()
	glayout <- grid.layout(3,2) # widths and heights arguments
	vp <- viewport(layout = glayout)
	pushViewport(vp)
	vplayout <- function(x,y)
	    viewport(layout.pos.row=x, layout.pos.col = y)
	print(p1+ theme(legend.position="none"), vp = vplayout(1,1))
	print(p3+ theme(legend.position="none"), vp = vplayout(1,2))
	print(p4+ theme(legend.position="none"), vp = vplayout(2,1))
	print(p5+ theme(legend.position="none"), vp = vplayout(2,2))
	print(p2+ theme(legend.position="right", legend.key.size=unit(0.1,"cm")), vp = vplayout(3,1:2))
    })

