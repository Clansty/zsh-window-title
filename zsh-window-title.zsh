# zsh-window-title
# https://github.com/olets/zsh-window-title
# A zsh plugin for informative terminal window titles
# Copyright © 2021 Henry Bley-Vroman

'builtin' 'typeset' -g __zwt_dir && \
	__zwt_dir=${0:A:h}

'builtin' 'typeset' -g +r ZWT_VERSION >/dev/null && \
	ZWT_VERSION=1.0.2 && \
	'builtin' 'typeset' -gr ZWT_VERSION

'builtin' 'typeset' -gi +r __zsh_window_title_debug_default >/dev/null && \
	__zsh_window_title_debug_default=0 && \
	'builtin' 'typeset' -gir __zsh_window_title_debug_default

'builtin' 'typeset' -gi +r __zsh_window_title_directory_depth_default >/dev/null && \
	__zsh_window_title_directory_depth_default=2 && \
	'builtin' 'typeset' -gir __zsh_window_title_directory_depth_default

'builtin' 'typeset' -gi +r __zwt_debug_default >/dev/null && \
	__zwt_debug_default=0 && \
	'builtin' 'typeset' -gir __zwt_debug_default


# zwt CLI subcommands

__zwt:debugger() {
	'builtin' 'emulate' -LR zsh

	(( ZWT_DEBUG )) && 'builtin' 'print' $funcstack[2]
}

__zwt:help() {
	'builtin' 'emulate' -LR zsh
	__zwt:debugger

	'command' 'man' zwt 2>/dev/null || 'command' 'man' $__zwt_dir/man/man1/zwt.1
}

__zwt:restore-defaults() {
	'builtin' 'emulate' -LR zsh
	__zwt:debugger

	ZSH_WINDOW_TITLE_DEBUG=$__zsh_window_title_debug_default
	ZSH_WINDOW_TITLE_DIRECTORY_DEPTH=$__zsh_window_title_directory_depth_default
	ZWT_DEBUG=$__zwt_debug_default
}

__zwt:version() {
	'builtin' 'emulate' -LR zsh
	__zwt:debugger

	'builtin' 'print' zwt $ZWT_VERSION
}


# zsh-window-title subcommands

__zsh-window-title:debugger() {
	'builtin' 'emulate' -LR zsh

	(( ZSH_WINDOW_TITLE_DEBUG )) && 'builtin' 'print' $funcstack[2]
}

__zsh-window-title:add-hooks() {
	'builtin' 'emulate' -LR zsh
	__zsh-window-title:debugger

	# update window title before drawing the prompt
	add-zsh-hook precmd __zsh-window-title:precmd

	# update the window title before executing a command
	add-zsh-hook preexec __zsh-window-title:preexec
}

__zsh-window-title:init() {
	'builtin' 'emulate' -LR zsh

	'builtin' 'typeset' -gi ZWT_DEBUG=${ZWT_DEBUG:-$__zwt_debug_default}

	'builtin' 'typeset' -gi ZSH_WINDOW_TITLE_DEBUG=${ZSH_WINDOW_TITLE_DEBUG:-$__zsh_window_title_debug_default}

	__zsh-window-title:debugger

	'builtin' 'typeset' -gi ZSH_WINDOW_TITLE_DIRECTORY_DEPTH=${ZSH_WINDOW_TITLE_DIRECTORY_DEPTH:-$__zsh_window_title_directory_depth_default}

	__zsh-window-title:precmd

	'builtin' 'autoload' -U add-zsh-hook

	__zsh-window-title:add-hooks
}

__zsh-window-title:precmd() {
	'builtin' 'emulate' -LR zsh
	__zsh-window-title:debugger

	local title=$(print -P "%$ZSH_WINDOW_TITLE_DIRECTORY_DEPTH~")

	if [[ -n $SSH_CONNECTION ]]; then
		title+=" - $HOST"
	fi

	'builtin' 'echo' -ne "\033]0;$title\007"
}

__zsh-window-title:preexec() {
	'builtin' 'emulate' -LR zsh
	__zsh-window-title:debugger

	local title=$(print -P "%$ZSH_WINDOW_TITLE_DIRECTORY_DEPTH~ - ${1[(w)1]}")

	if [[ -n $SSH_CONNECTION ]]; then
		title+=" - $HOST"
	fi

	'builtin' 'echo' -ne "\033]0;$title\007"
}

zwt() {
	'builtin' 'emulate' -LR zsh
	__zwt:debugger

	while (($# )); do
		case $1 in
			"--help"|\
			"-h"|\
			"help")
				__zwt:help
				return
				;;
			"restore-defaults")
				__zwt:restore-defaults
				return
				;;
			"--version"|\
			"-v"|\
			"version")
				__zwt:version
				return
				;;
			*)
				shift
				;;
		esac
	done
}

__zsh-window-title:init
