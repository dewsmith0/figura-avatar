#!/usr/bin/env bash
@ 2>/dev/null # 2>nul & ECHO OFF & GOTO WIN


#    ,-------------------------------------+ #
#   /    ____     ___     _____    __  __  | #
#  /    / __ )   /   |   / ___/   / / / /  | #
# |    / __  |  / /| |   \__ \   / /_/ /   | #
# |   / /_/ /  / ___ |  ___/ /  / __  /    | #
# |  /_____/  /_/  |_| /____/  /_/ /_/    /  #
# |                                      /   #
# +-------------------------------------'    #

# I'm no bash programmer, so bear with me here.

#* :==:==:==:==:==:==:==:==:==:==:==:==:==:==:==:==:==:==:==:==:==:==:==:==:==:==:==:==:==:==:==: *#
clear
set -o pipefail

#* :==:==:==:==:==:==:==:==:==:==:==:==:==:==:=CONFIG=:==:==:==:==:==:==:==:==:==:==:==:==:==:==: *#
declare REPO="https://github.com/GrandpaScout/FiguraRewriteVSDocs/"
declare TEMP=".gitdownload"

#* :==:==:==:==:==:==:==:==:==:==:==:==:==:==VERIFY GIT==:==:==:==:==:==:==:==:==:==:==:==:==:==: *#
if ! which git &>/dev/null; then
  while true; do
    clear
    echo "Git is not installed on your machine."
    echo "Would you like to download it?"
    echo ""
    read -p "[Y/N] " -n 1 -r choice_1
    case "$choice_1" in
      [Yy])
        clear
        echo "Git is not installed on your machine."
        echo "Would you like to download it?"
        echo ""
        echo "Once you are done downloading it, start this script again."
        if which xdg-open &>/dev/null; then
          read -p "Press any key to continue and exit . . . " -n 1 -rs
          xdg-open "https://git-scm.com/downloads"
        elif which start &>/dev/null; then
          read -p "Press any key to continue and exit . . . " -n 1 -rs
          start "" "https://git-scm.com/downloads"
        else
          echo "Download git at <https://git-scm.com/downloads>"
          read -p "Press any key to exit . . . " -n 1 -rs
        fi
        break;;
      [Nn])
        clear
        echo "Git is not installed on your machine."
        echo "Would you like to download it?"
        echo ""
        echo "This script cannot run without git installed."
        read -p "Press any key to exit . . . " -n 1 -rs
        break;;
      *) echo -e "\a";;
    esac
  done
  exit 1
fi

#* :==:==:==:==:==:==:==:==:==:==:==:==:=CHECK GIT DOWNLOAD=:==:==:==:==:==:==:==:==:==:==:==:==: *#
if [[ -d $TEMP ]]; then
  echo "The \"$TEMP\" folder is used to store downloaded files from git."
  echo "Make sure that folder is gone before running this script."
  read -p "Press any key to exit . . . " -n 1 -rs
  exit 1
fi

#* :==:==:==:==:==:==:==:==:==:==:==:==:==:=GET BRANCHES=:==:==:==:==:==:==:==:==:==:==:==:==:==: *#
echo "Git has been found."
echo "Getting branches..."

# Get Standard branches from the repo.
declare -i n=0
declare branchL=
declare branchU=
declare -a branch=(1)
declare -A branchN=
while read -r line; do
  [[ $line =~ refs/heads/(.+) ]]
  declare lineBranch="${BASH_REMATCH[1]}"
  case $lineBranch in
    "latest") branchL="$lineBranch";;
    "upcoming") branchU="$lineBranch";;
    *)
      branchN["$lineBranch"]="true"
      branch[${#branch[@]}]="$lineBranch";;
  esac
done < <(git ls-remote "$REPO" "refs/heads/*")

# Get current branch if the docs are already installed.
declare branchC=
declare branchC_full=
declare current_branch=
if [[ -r "./.vscode/docs/figura/.version" ]] && [[ $(< ./.vscode/docs/figura/.version) =~ ^([^[:space:]]+)\ ([^[:space:]]+) ]]; then
  current_branch="${BASH_REMATCH[1]}"
  if [[ ${branchN["$current_branch"]} ]]; then
    branchC="$current_branch"
  else
    branchC="latest"
  fi
  branchC_full="$current_branch ${BASH_REMATCH[2]}"
fi

#* :==:==:==:==:==:==:==:==:==:==:==:==:=BRANCH SELECT MENU=:==:==:==:==:==:==:==:==:==:==:==:==: *#
declare selected=
declare selected_branch=
declare select_failed=
declare select_empty=
while true; do
  clear
  echo "Type your selection and press enter to select a branch."
  echo "Type nothing and press enter twice to quit."
  echo ""
  echo "If you are not sure which one to select, choose [L]."
  echo "Do not select [U] if you do not know what you are doing."
  echo ""
  if [[ $branchC ]]; then echo "[C] Currently installed branch ($branchC) [$branchC_full]"; fi
  if [[ $branchL ]]; then echo "[L] Latest branch ($branchL)"; fi
  if [[ $branchU ]]; then echo "[U] Experimental branch ($branchU)"; fi
  for i in ${!branch[@]}; do
    if (( $i == 0 )); then continue; fi
    echo "[$i] ${branch[$i]}"
  done

  echo ""
  unset selected

  if [[ $select_failed ]]; then
    read -p "[Error: Invalid branch number]> " -r selected
  elif [[ $select_empty ]]; then
    read -p "[Press enter again to quit]> " -r selected
  else
    read -p "> " -r selected
  fi

  # If selection is empty, prepare to exit on next empty selection.
  if [[ ! $selected ]]; then
    if [[ $select_empty ]]; then exit 1; fi
    select_failed=
    select_empty="true"
    continue
  fi

  # Determine if selection was valid.
  if [[ $selected =~ ^[Cc]$ && branchC ]]; then
    selected_branch="$branchC"
  elif [[ $selected =~ ^[Ll]$ && branchL ]]; then
    selected_branch="$branchL"
  elif [[ $selected =~ ^[Uu]$ && branchU ]]; then
    selected_branch="$branchU"
  elif [[ $selected =~ ^([0-9]+)$ ]]; then
    if (( $selected != 0 )) && [[ ${branch["$selected"]} ]]; then
      selected_branch="${branch["$selected"]}"
    else
      select_failed="true"
      select_empty=
      continue
    fi
  else
    select_failed="true"
    select_empty=
    continue
  fi

#* :==:==:==:==:==:==:==:==:==:==:==:=CONFIRM BRANCH SELECTION=:==:==:==:==:==:==:==:==:==:==:==: *#
  select_failed=
  select_empty=

  clear
  echo "Type your selection and press enter to select a branch."
  echo "Type nothing and press enter twice to quit."
  echo ""
  echo "If you are not sure which one to select, choose [L]."
  echo "Do not select [U] if you do not know what you are doing."
  echo ""
  if [[ $branchC ]]; then echo "[C] Currently installed branch ($branchC) [$branchC_full]"; fi
  if [[ $branchL ]]; then echo "[L] Latest branch ($branchL)"; fi
  if [[ $branchU ]]; then echo "[U] Experimental branch ($branchU)"; fi
  for i in ${!branch[@]}; do
    if (( $i == 0 )); then continue; fi
    echo "[$i] ${branch[$i]}"
  done
  echo ""
  echo "Selected \"$selected_branch\". Is this correct?"
  echo ""
  read -p "[Y/N] " -n 1 -r choice_2
  case "$choice_2" in
    [Yy]) break;;
    *) continue;;
  esac
done

#* :==:==:==:==:==:==:==:==:==:==:==:==:==:==MOVE FILES==:==:==:==:==:==:==:==:==:==:==:==:==:==: *#
clear
echo "Moving files..."
# Do a shallow clone of the selected branch only.
# This stops git from downloading a ton of files it will never use.
#
# `--depth 1` Removes history as it is useless to this operation.
# `--single-branch` Removes other branches as they are useless to this operation.
# `--branch "BRANCH"` Picks the single branch that git should get.
git clone --quiet --depth 1 --single-branch --branch "$selected_branch" "$REPO" "./$TEMP"

declare folder_name="${PWD##*/}"

if [[ -d "./.vscode" ]]; then
  rm -rf --preserve-root "./.vscode/docs" &>/dev/null
  rm -f --preserve-root "./.vscode/avatar.schema.json" &>/dev/null

  mv "./$TEMP/src/.vscode/docs" "./.vscode/docs" &>/dev/null
  mv "./$TEMP/src/.vscode/avatar.schema.json" "./.vscode/avatar.schema.json" &>/dev/null
else
  mv "./$TEMP/src/.vscode" "./.vscode" &>/dev/null
fi

glob_exists() {
  [[ -e "$1" ]]
}
shopt -q dotglob
declare -i was_set=$?
shopt -s dotglob

if ! glob_exists *.code-workspace; then
  mv "./$TEMP/src/avatar.code-workspace" "./$folder_name.code-workspace" &>/dev/null
fi

if (( $was_set != 0 )); then
  shopt -u dotglob
fi

if [[ ! -e ./.luarc.json ]]; then
  mv "./$TEMP/src/.luarc.json" "./.luarc.json" &>/dev/null
fi

rm -rf --preserve-root "./$TEMP" &>/dev/null

echo ""
echo "Done."
echo ""
read -p "Press any key to finish . . . " -n 1 -rs
exit 0





