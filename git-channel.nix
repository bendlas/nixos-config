{ git, runCommand, cacert, url, rev, name ? "channel" }:

runCommand "git-${name}" {
  dummy = builtins.currentTime;
  buildInputs = [ git ];
  GIT_SSL_CAINFO = "${cacert}/etc/ssl/certs/ca-bundle.crt";
} ''
  mkdir -p $out
  cd $out
  git init
  echo git fetch --depth=1 "${url}" "${rev}"
  git fetch --depth=1 "${url}" "${rev}"
  git checkout FETCH_HEAD
  rm -r .git
''
