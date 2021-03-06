# Binutils Wrapper hygiene
#
# See comments in cc-wrapper's setup hook. This works exactly the same way.

set -u

# Skip setup hook if we're neither a build-time dep, nor, temporarily, doing a
# native compile.
#
# TODO(@Ericson2314): No native exception
[[ -z ${strictDeps-} ]] || (( "$hostOffset" < 0 )) || return 0

bintoolsWrapper_addLDVars () {
    # See ../setup-hooks/role.bash
    local role_post role_pre
    getTargetRoleEnvHook

    if [[ -d "$1/lib64" && ! -L "$1/lib64" ]]; then
        export NIX_${role_pre}LDFLAGS+=" -L$1/lib64"
    fi

    if [[ -d "$1/lib" ]]; then
        export NIX_${role_pre}LDFLAGS+=" -L$1/lib"
    fi
}

# See ../setup-hooks/role.bash
getTargetRole
getTargetRoleWrapper

addEnvHooks "$targetOffset" bintoolsWrapper_addLDVars

# shellcheck disable=SC2157
if [ -n "@bintools_bin@" ]; then
    addToSearchPath _PATH @bintools_bin@/bin
fi

# shellcheck disable=SC2157
if [ -n "@libc_bin@" ]; then
    addToSearchPath _PATH @libc_bin@/bin
fi

# shellcheck disable=SC2157
if [ -n "@coreutils_bin@" ]; then
    addToSearchPath _PATH @coreutils_bin@/bin
fi

# Export tool environment variables so various build systems use the right ones.

export NIX_${role_pre}BINTOOLS=@out@

for cmd in \
    ar as ld nm objcopy objdump readelf ranlib strip strings size windres
do
    if
        PATH=$_PATH type -p "@targetPrefix@${cmd}" > /dev/null
    then
        upper_case="$(echo "$cmd" | tr "[:lower:]" "[:upper:]")"
        export "${role_pre}${upper_case}=@targetPrefix@${cmd}";
        export "${upper_case}${role_post}=@targetPrefix@${cmd}";
    fi
done

# If unset, assume the default hardening flags.
: ${NIX_HARDENING_ENABLE="fortify stackprotector pic strictoverflow format relro bindnow"}
export NIX_HARDENING_ENABLE

# No local scope in sourced file
unset -v role_pre role_post cmd upper_case
set +u
