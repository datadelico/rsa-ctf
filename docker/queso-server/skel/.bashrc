# Configurar PATH restringido
export PATH=/home/queso/bin
readonly PATH

# Anular comandos integrados
alias echo="echo Comando no permitido"
alias cd="echo Comando no permitido"
alias pwd="echo Comando no permitido"
alias export="echo Comando no permitido"
alias source="echo Comando no permitido"
alias unset="echo Comando no permitido"
alias alias="echo Comando no permitido"


# Prompt personalizado
PS1="queso@queso-server:\w$ "

cat flag.txt