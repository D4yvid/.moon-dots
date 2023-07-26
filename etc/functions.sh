#!/bin/bash

log_prefix() {
  TIME=$(date)
  PREFIX="$@"

  printf "[%s] [%s]: " "$TIME" "$PREFIX"
}

log_info() {
  log_prefix "$([ ! -z "$SERVICE_NAME" ] && echo "$SERVICE_NAME/")INFO "
  printf "%s\n" "$@"
}

log_warn() {
  log_prefix "$([ ! -z "$SERVICE_NAME" ] && echo "$SERVICE_NAME/")WARN "
  printf "%s\n" "$@"
}

log_error() {
  log_prefix "$([ ! -z "$SERVICE_NAME" ] && echo "$SERVICE_NAME/")ERROR"
  printf "%s\n" "$@"
}

