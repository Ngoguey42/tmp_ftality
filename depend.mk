MKGEN_SRCSBIN_BROWSER := _build/src/shared/bar.cmo _build/src/browser/main.cmo
MKGEN_SRCSBIN_TERMBYTE := _build/src/shared/bar.cmo _build/src/terminal/main.cmo
MKGEN_SRCSBIN_TERMNAT := _build/src/shared/bar.cmx _build/src/terminal/main.cmx
_build/src/browser/main.cmo : src/browser/main.ml _build/src/shared/bar.cmo | _build/src/browser/
_build/src/browser/main.cmx : src/browser/main.ml _build/src/shared/bar.cmx | _build/src/browser/
_build/src/shared/bar.cmo : src/shared/bar.ml | _build/src/shared/
_build/src/shared/bar.cmx : src/shared/bar.ml | _build/src/shared/
_build/src/terminal/main.cmi : src/terminal/main.mli | _build/src/terminal/
_build/src/terminal/main.cmo : src/terminal/main.ml _build/src/shared/bar.cmo _build/src/terminal/main.cmi | _build/src/terminal/
_build/src/terminal/main.cmx : src/terminal/main.ml _build/src/shared/bar.cmx _build/src/terminal/main.cmi | _build/src/terminal/