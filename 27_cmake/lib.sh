# Hilfsfunktionen für geskriptete asciinema-Demos
ulimit -c 0
export PS4=
_prompt() { printf '\033[1;34m%s\033[0m \033[1;32m$\033[0m ' "$(dirs +0)"; }
_type() { local s="$1" i; for ((i=0; i<${#s}; i++)); do printf '%s' "${s:i:1}"; sleep 0.03; done; }
# run <befehl> [pause] [sub]: tippt den Befehl, führt ihn aus, wartet.
# Mit "sub" läuft er in einer eigenen Shell (für Befehle, die abstürzen).
run() { _prompt; sleep 0.4; _type "$1"; sleep 0.3; printf '\n'
  if [ "$3" = sub ]; then bash -c "$1" 2> >(sed -u -E 's/^bash: line [0-9]+: +[0-9]+ +//'); sleep 0.3; else eval "$1"; fi
  sleep "${2:-1.5}"; }
# note <text>: getippter Kommentar
note() { _prompt; sleep 0.3; printf '\033[0;33m'; _type "# $1"; printf '\033[0m\n'; sleep "${2:-1.2}"; }
fin() { _prompt; sleep 2; printf '\n'; }
