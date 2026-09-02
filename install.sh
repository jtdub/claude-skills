#!/usr/bin/env bash
#
# Install this repo's skills, agents, rules and top-level files into ~/.claude by symlink.
#
# Symlinks mean an edit in this repo takes effect immediately, and `git pull`
# updates your live Claude Code setup.
#
# Usage:
#   ./install.sh              link everything
#   ./install.sh --dry-run    print what would be linked, change nothing
#   ./install.sh --force      replace an existing symlink
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"

DRY_RUN=0
FORCE=0

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        --force)   FORCE=1 ;;
        -h|--help)
            sed -n '3,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "install.sh: unknown option '$arg'" >&2
            echo "Run './install.sh --help' for usage." >&2
            exit 2
            ;;
    esac
done

linked=0
skipped=0
skipped_symlink=0

link_entry() {
    local src="$1" dest="$2" name
    name="$(basename "$src")"

    if [ -L "$dest" ]; then
        local current
        current="$(readlink "$dest")"
        if [ "$current" = "$src" ]; then
            echo "  ok       $name (already linked)"
            return
        fi
        if [ "$FORCE" -eq 0 ]; then
            echo "  skip     $name (symlink points elsewhere: $current)" >&2
            skipped=$((skipped + 1))
            skipped_symlink=$((skipped_symlink + 1))
            return
        fi
        [ "$DRY_RUN" -eq 1 ] || rm "$dest"
    elif [ -e "$dest" ]; then
        echo "  skip     $name (a real file or directory is already there)" >&2
        skipped=$((skipped + 1))
        return
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        echo "  would link $name -> $src"
    else
        ln -s "$src" "$dest"
        echo "  linked   $name"
    fi
    linked=$((linked + 1))
}

install_dir() {
    local kind="$1"
    local src_dir="$REPO_DIR/$kind"
    local dest_dir="$CLAUDE_DIR/$kind"

    [ -d "$src_dir" ] || return 0

    # Skills are directories; agents and rules are .md files.
    local entries=()
    if [ "$kind" = "skills" ]; then
        for e in "$src_dir"/*/; do
            [ -d "$e" ] && entries+=("${e%/}")
        done
    else
        for e in "$src_dir"/*.md; do
            [ -f "$e" ] && entries+=("$e")
        done
    fi

    if [ "${#entries[@]}" -eq 0 ]; then
        return 0
    fi

    echo "$kind:"
    if [ "$DRY_RUN" -eq 0 ]; then
        mkdir -p "$dest_dir"
    fi

    for e in "${entries[@]}"; do
        link_entry "$e" "$dest_dir/$(basename "$e")"
    done
}

install_home() {
    local src_dir="$REPO_DIR/home"

    [ -d "$src_dir" ] || return 0

    local entries=()
    for e in "$src_dir"/*; do
        [ -f "$e" ] && entries+=("$e")
    done

    if [ "${#entries[@]}" -eq 0 ]; then
        return 0
    fi

    echo "home:"
    if [ "$DRY_RUN" -eq 0 ]; then
        mkdir -p "$CLAUDE_DIR"
    fi

    for e in "${entries[@]}"; do
        link_entry "$e" "$CLAUDE_DIR/$(basename "$e")"
    done
}

echo "Repo:   $REPO_DIR"
echo "Target: $CLAUDE_DIR"
[ "$DRY_RUN" -eq 1 ] && echo "Mode:   dry run, nothing will change"
echo

install_dir skills
install_dir agents
install_dir rules
install_home

echo
if [ "$DRY_RUN" -eq 1 ]; then
    echo "Dry run: $linked entries would be linked, $skipped skipped."
else
    echo "Done: $linked linked, $skipped skipped."
    echo "Start a new Claude Code session to pick them up."
fi

if [ "$skipped_symlink" -gt 0 ]; then
    echo "Re-run with --force to replace symlinks that point elsewhere." >&2
fi
if [ "$skipped" -gt "$skipped_symlink" ]; then
    echo "Remove or rename the real files listed above, then re-run. --force does not touch them." >&2
fi
