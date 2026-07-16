# ##### Install Terraform deps #####
install_commands+="install_glab "
function install_glab() {
    log_info "Install glab..."
    local remote_version=$($CURL_CMD 'https://gitlab.com/api/v4/projects/gitlab-org%2Fcli/releases/permalink/latest' | jq -r '.tag_name')
    local local_version=$(command -v glab &>/dev/null && glab version | awk '{print $2}' | sed 's/^v//' || echo "0.0.0")
    local normalized_remote_version=${remote_version#v}
    local download_url="https://gitlab.com/gitlab-org/cli/-/releases/$remote_version/downloads/glab_${normalized_remote_version}_${OS}_${ARCH}.tar.gz"
    if [[ "$normalized_remote_version" == "$local_version" ]]; then
        log_info "  is up to date..."
        return
    fi
    log_info "  installing..."
    local temp_dir=$(mktemp -d)
    mkdir -p $temp_dir
    $CURL_CMD -o $temp_dir/download.tar.gz $download_url
    tar -C $temp_dir -xzf $temp_dir/download.tar.gz
    [[ "$OS" == "linux" ]] && find "$temp_dir" -type f -perm /u=x,g=x,o=x -exec sh -c 'rm -f $0/$(basename $1)' $LOCAL_BIN {} \; -exec mv {} "$LOCAL_BIN" \;
    [[ "$OS" == "darwin" ]] && find "$temp_dir" -type f -perm +0111 -exec sh -c 'rm -f $0/$(basename $1)' $LOCAL_BIN {} \; -exec mv {} "$LOCAL_BIN" \;
    rm -rf $temp_dir
    log_info "  installed..."
}
