function _ag(){ input="${*}"; echo "${input:-$(cat)}" | source ~/sites/metta-helpers/env/bin/activate && alive embed "${*}" | python ~/sites/metta-helpers/src/main.py | tr -d '"'; };
shift
_ag "${*}"
