
#' Translate JSON-based simmer problem definition into a simmer environment
#'
#' @param json_obj a string, URL or files
#'
#' @export
#' @import simmer
deserialise <- function(json_obj) {

  definition <- jsonlite::fromJSON(json_obj, simplifyDataFrame = FALSE)

  # create the environment
  env<-simmer()

  # setup trajectories
  trajectories <- list()


  for(traj_name in names(definition$trajectories)){
    # iterate over trajectory definition
    traj <- create_trajectory(name = traj_name)

    for(act in definition$trajectories[[traj_name]]){

      if(!act$activity %in% ls("package:simmer")){
        stop(paste0("Error loading requested activity function from simmer package: ", act$activty))
      }

      ## if branch: special case
      traj_func <- get(x=act$activity, pos = "package:simmer")

      if(act$activity == "branch"){
        sub_trajectories <- lapply(act$trajectories, function(x) trajectories[[x]])
        act$trajectories <- NULL
        act$activity <- NULL

        act <- lapply(act, process_value)

        act$traj <- traj
        act <- c(act, sub_trajectories)

        traj <- do.call(traj_func, act)

      } else {
        act$activity <- NULL
        ## translate args to functions
        act <- lapply(act, process_value)

        act$traj <- traj
        traj <- do.call(traj_func, act)

      }
    }

    trajectories[[traj_name]] <- traj

  }


  # add resources
  for(res_name in names(definition$env$resources)){
    res_args <- definition$env$resources[[res_name]]
    res_args$name <- res_name
    res_args$env <- env
    env <- do.call(add_resource, args = res_args)
  }

  # add generators
  for(gen_name in names(definition$env$generators)){
    gen_args <- definition$env$generators[[gen_name]]

    gen_args <- lapply(gen_args, process_value)
    gen_args$name_prefix <- gen_name
    gen_args$env <- env
    gen_args$trajectory <- trajectories[[gen_args$trajectory]]

    env <- do.call(add_generator, args = gen_args)
  }

  env
}


#' Process a value and translate to correct output
#'
#' For internal usage.
#'
#' @param value value to process
process_value<-function(value){
  if(grepl("(^%.*%$)", value)){
    func_string <- gsub("(^%)|(%$)", "", value)
    func <- eval(parse(text=func_string))
    if(!is.function(func)){
      func_body <- parse(text=func)
      func <- function() {}
      body(func) <- parse(text=func_body)
    }

    return(func)
  }

  if(grepl("(^\\$.*\\$$)", value)){
    obj_string <- gsub("(^\\$)|(\\$$)", "", value)
    obj <- eval(parse(text=obj_string))

    return(obj)
  }

  return(value)

}
