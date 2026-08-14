# ##### Install glab #####
install_commands+=(install_glab)
function install_glab() {
  log_info "Install glab..."
  local remote_version=$("${CURL_CMD[@]}" 'https://gitlab.com/api/v4/projects/gitlab-org%2Fcli/releases/permalink/latest' | jq -r '.tag_name')
  local local_version=$(command -v glab &>/dev/null && glab version | awk '{print $2}' | sed 's/^v//' || echo "0.0.0")

  if version_is_current "$remote_version" "$local_version"; then
    log_info "  is up to date..."
    return
  fi
  install_release_tree "https://gitlab.com/gitlab-org/cli/-/releases/$remote_version/downloads/glab_${remote_version#v}_${OS}_${ARCH}.tar.gz" tar.gz
}
