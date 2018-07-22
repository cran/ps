
format_regexp <- function() {
  "<ps::ps_handle> PID=[0-9]+, NAME=.*, AT="
}

parse_ps <- function(args) {
  out <- processx::run("ps", args)$stdout
  strsplit(out, "\n")[[1]][[2]]
}

parse_time <- function(x) {
  x <- utils::tail(c(0, 0, 0, as.numeric(strsplit(x, ":")[[1]])), 3)
  x[1] * 60 * 60 + x[2] * 60 + x[3]
}

wait_for_status <- function(ps, status, timeout = 5) {
  limit <- Sys.time() + timeout
  while (ps_status(ps) != status && Sys.time() < limit) Sys.sleep(0.05)
}

get_tool <- function(prog) {
  if (ps_os_type()[["WINDOWS"]]) prog <- paste0(prog, ".exe")
  exe <- system.file(package = "ps", "bin", .Platform$r_arch, prog)
  if (exe == "") {
    pkgpath <- system.file(package = "ps")
    if (basename(pkgpath) == "inst") pkgpath <- dirname(pkgpath)
    exe <- file.path(pkgpath, "src", prog)
    if (!file.exists(exe)) return("")
  }
  exe
}

px <- function() get_tool("px")

skip_in_rstudio <- function() {
  if (Sys.getenv("RSTUDIO") != "") skip("would crash RStudio")
}

has_processx <- function() {
  requireNamespace("processx", quietly = TRUE) &&
    package_version(getNamespaceVersion("processx")) >= "3.1.0.9005"
}

skip_if_no_processx <- function() {
  if (!has_processx()) skip("Needs processx >= 3.1.0.9005 to run")
}