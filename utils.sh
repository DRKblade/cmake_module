readonly SELF=${0##*/} 
declare -rA COLORS=( 
  [RED]=$'\033[0;31m' 
  [GREEN]=$'\033[0;32m' 
  [BLUE]=$'\033[0;34m' 
  [PURPLE]=$'\033[0;35m' 
  [CYAN]=$'\033[0;36m' 
  [WHITE]=$'\033[0;37m' 
  [YELLOW]=$'\033[0;33m' 
  [BOLD]=$'\033[1m' 
  [OFF]=$'\033[0m' 
)
PROJECT=$(grep -oP 'project\(\K[\w]+' CMakeLists.txt)
VERSION=$(grep -oP 'project\(.*? VERSION \K[0-9.]+' CMakeLists.txt)

archive() {
  path=./build/$PROJECT-$VERSION
  git archive --prefix $PROJECT/ --output $path.tar --format tar HEAD &&
  git archive --prefix $PROJECT/ --output $path.tar.gz --format tar.gz HEAD &&
  echo "Archive generated to $path"
}

usage() { 
  echo " 
  Builds and installs $PROJECT.
 
  ${COLORS[GREEN]}${COLORS[BOLD]}Usage:${COLORS[OFF]} 
      ${COLORS[CYAN]}${SELF}${COLORS[OFF]} [options]

  ${COLORS[GREEN]}${COLORS[BOLD]}Options:${COLORS[OFF]}
      ${COLORS[GREEN]}-A, --auto${COLORS[OFF]}
          Use defaults for every options
      ${COLORS[GREEN]}-a, --archive${COLORS[OFF]}
          Copy the local git repo to archive files
      ${COLORS[GREEN]}-t, --tests${COLORS[OFF]}
          Build unit tests into './build/test'
      ${COLORS[GREEN]}-T, --coverage${COLORS[OFF]}
          Generate code coverage for the project (implies -t)
      ${COLORS[GREEN]}-I, --noinstall${COLORS[OFF]}
          Execute 'sudo make install' and install $PROJECT
      ${COLORS[GREEN]}-d, --debug${COLORS[OFF]}
          Print debug messages
      ${COLORS[GREEN]}-P, --purge${COLORS[OFF]}
          Delete './build' directory before building
      ${COLORS[GREEN]}-p, --use-PREFIX${COLORS[OFF]}
          Set cmake variable CMAKE_INSTALL_PREFIX to \$PREFIX
      ${COLORS[GREEN]}-c, --cmake-option <options>${COLORS[OFF]}
          Add other cmake options
      ${COLORS[GREEN]}-h, --help${COLORS[OFF]}
          Show this help message
"
}

msg_err() {
  echo -e "${COLORS[RED]}${COLORS[BOLD]}** ${COLORS[OFF]}$*\n"
  exit 1
}

msg() {
  echo -e "${COLORS[GREEN]}${COLORS[BOLD]}** ${COLORS[OFF]}$*\n"
}

branch_switches() {
  case "$1" in
    -A|--auto)
      [[ -z "$INSTALL" ]] && INSTALL=ON;
      [[ -z "$BUILD_TESTS" ]] && BUILD_TESTS=OFF;
      ;;
    -a|--archive)
      archive; ;;
    -I|--noinstall)
      INSTALL=OFF; ;;
    -t|--test)
      BUILD_TESTS=ON; ;;
    -d|--debug)
      LG_DBUG=ON; ;;
    -T|--coverage)
      BUILD_TESTS=ON;
      GEN_COVERAGE=ON; ;;
    -P|--purge)
      PURGE_BUILD_DIR=ON; ;;
    -p|--use-PREFIX)
      USE_PREFIX=ON; ;;
    -c|--cmake-options)
      CMAKE_OPTIONS=$2; ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      [[ ${#1} -le 2 ]] && {
        usage
        msg_err "Unknown switch '$1'"
      }

      joined_param=$1
      shift
      branch_switches "${joined_param:0:2}" $@
      branch_switches "-${joined_param:2}" $@
      ;;
  esac
}

parse_options() {
  while [[ "$1" == -* ]]; do
    branch_switches $@
    shift
  done
}

ask_options() {
  if [[ -z "$BUILD_TESTS" ]]; then
    read -r -p "$(msg "Build and run unit tests? [y/N]: ")" -n 1 p && echo
    [[ "${p^^}" != "Y" ]] && BUILD_TESTS="OFF" || BUILD_TESTS="ON"
  fi
}

install() {
  if [[ -z "$INSTALL" ]]; then
    read -r -p "$(msg "Execute 'sudo make install'? [y/N]: ")" -n 1 p && echo
    [[ "${p^^}" != "Y" ]] && INSTALL="OFF" || INSTALL="ON"
  fi
  if [[ "$INSTALL" == ON ]]; then
    if ! command -v sudo > /dev/null; then
      msg "Skipping unsupported command: sudo"
      make install || msg_err "Failed to install executables"
    else
      sudo make install || msg_err "Failed to install executables"
    fi
  fi
}

build() {
  [[ -d ./build ]] && {
    if [[ "$PURGE_BUILD_DIR" == ON ]]; then
      msg "Removing existing build dir"
      rm -rf ./build >/dev/null || msg_err "Failed to remove existing build dir"
    else
      msg "A build dir already exists"
    fi
  }

  mkdir -p ./build || msg_err "Failed to create build dir"
  cd ./build || msg_err "Failed to enter build dir"

  if [[ "$USE_PREFIX" == ON ]]; then
    msg 'Setting CMAKE_INSTALL_PREFIX variable to $PREFIX'
    USE_PREFIX_OPTION="-DCMAKE_INSTALL_PREFIX='$PREFIX'"
  fi

  [[ -z "$DEBUG_SCOPES" ]] || msg "Using debug scopes: $DEBUG_SCOPES"
  [[ -z "$LOG_LEVEL" ]] && LOG_LEVEL=0

  msg "Executing CMake command"
  cmake -DBUILD_TESTS=${BUILD_TESTS} \
        -DGEN_COVERAGE=${GEN_COVERAGE} \
        -DLG_DBUG=${LG_DBUG} \
        -DCMAKE_CXX_FLAGS="-Wall -Wextra" \
        ${USE_PREFIX_OPTION} \
        -${CMAKE_OPTIONS} \
        .. || msg_err "Failed to compile project..."

  msg "Building project"
  make || msg_err "Failed to build project"

  # Call tests from inside the test directory so that file dependencies work
  if [[ "$BUILD_TESTS" == ON ]]; then
    ctest -V || msg_err 'Unit tests failed'
    [[ "$GEN_COVERAGE" == ON ]] && {
      msg "Generating code coverage report"
      make cov_init &&
      make lcov
      [[ -f "../.codecov-token" ]] && {
        export CODECOV_TOKEN=$(gpg -d ../.codecov-token)
        [[ -n "$CODECOV_TOKEN" ]] && make codecov_upload
      } || msg 'Skipping codecov upload'
    }
  fi

  install

  msg "Build complete!"
  exit 0
}

