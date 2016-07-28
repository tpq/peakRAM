#' Calculate Peak RAM Used
#'
#' This function monitors the total and peak RAM used by any number of
#'  R expressions or functions.
#'
#' When working with big datasets, RAM conservation is critically
#'  important. However, it is not always enough to just monitor the
#'  size of the objects created. So-called "copy-on-modify" behavior,
#'  characteristic of R, means that some expressions or functions may
#'  require an unexpectedly large amount of RAM overhead. For example,
#'  replacing a single value in a matrix (e.g., with \code{'[<-'})
#'  duplicates that matrix in the backend, making this task
#'  require twice as much RAM as that used by the matrix itself.
#'  The \code{peakRAM} package makes it easy to monitor the total
#'  and peak RAM used so that developers can quickly identify and
#'  eliminate RAM hungry code.
#'
#' @param ... R expressions or function calls. Anonymous functions
#'  (e.g., \code{function() 1:1e7}) also accepted.
#' @return A \code{data.frame} tallying total and peak RAM use.
#'
#' @examples
#' peakRAM(function() 1:1e7,
#'         1:1e7,
#'         1:1e7 + 1:1e7,
#'         1:1e7 * 2)
#' @export
peakRAM <- function(...){

  args <- as.list(substitute(list(...)))[-1]
  numfunc <- length(args)

  # Initialize containers for output
  Function <- vector("character", numfunc)
  totaltime <- vector("numeric", numfunc)
  RAMused <- vector("numeric", numfunc)
  RAMpeak <- vector("numeric", numfunc)

  i <- 1
  for(arg in args){

    # Reset garbage collector and save baseline
    start <- gc(verbose = FALSE, reset = TRUE)

    evalTime <- system.time(result <- eval(arg))

    # Add handling for anonymous functions
    if(class(result) == "function"){

      evalTime <- system.time(output <- result())
      rm(result)

    }else{

      output <- result
      rm(result)
    }

    # Call garbage collector and save post-eval
    end <- gc(verbose = FALSE, reset = FALSE)
    rm(output)

    # Calculate total and peak RAM used
    Function[i] <- deparse(arg)
    totaltime[i] <- as.numeric(evalTime["elapsed"])
    RAMused[i] <- end[2, 2] - start[2, 2]
    RAMpeak[i] <- end[2, 6] - start[2, 6]

    i <- i + 1
  }

  data.frame("Function_Call" = Function,
             "Elapsed_Time_sec" = totaltime,
             "Total_RAM_Used_MiB" = RAMused,
             "Peak_RAM_Used_MiB" = RAMpeak,
             row.names = 1:numfunc)
}
