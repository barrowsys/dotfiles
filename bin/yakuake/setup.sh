#!/bin/bash
###############################################################
# THIS FILE IS LICENSED UNDER GPL-3.0-only                    #
# THE FOLLOWING MESSAGE IS NOT A LICENSE                      #
#                                                             #
# <barrow@tilde.team> wrote this file.                        #
# by reading this message, you are reading "TRANS RIGHTS".    #
# this file and the content within it is the queer agenda.    #
# if we meet some day, and you think this stuff is worth it,  #
# you can buy me a beer, tea, or something stronger.          #
# -Ezra Barrow                                                #
###############################################################

CALC_PREAMBLE=$(cat <<EOF
from datetime import datetime, timedelta
def now():
    return datetime.now()
print('== Quick Reference ==')
print('now() = datetime.now()')
print('datetime(year=2021, month=1, day=7, hour=17)')
print('timedelta(hours=1, minutes=3, seconds=5)')
#print('reset: ctrl-d')
print('                     ')
EOF
)

CALC_COMMAND=$(cat <<EOF
while true; do
    clear
    python3 -i -c "$CALC_PREAMBLE"
done
EOF
)

SID="$HOME/bin/yakuake/sessionid.tmp"
CALC_SESSION=$(qdbus org.kde.yakuake /yakuake/sessions addSession)
echo $CALC_SESSION >$SID
CALC_TERM=$(qdbus org.kde.yakuake /yakuake/sessions terminalIdsForSessionId $CALC_SESSION)
qdbus org.kde.yakuake /yakuake/sessions org.kde.yakuake.setSessionClosable $CALC_SESSION false
qdbus org.kde.yakuake /yakuake/tabs org.kde.yakuake.setTabTitle $CALC_SESSION "Calculator"
qdbus org.kde.yakuake /yakuake/sessions org.kde.yakuake.runCommandInTerminal $CALC_TERM "$CALC_COMMAND"

# # Show window
# qdbus org.kde.yakuake /yakuake/MainWindow_1 org.qtproject.Qt.QWidget.hide
# qdbus org.kde.yakuake /yakuake/window org.kde.yakuake.toggleWindowState

# Check session exists
# qdbus org.kde.yakuake /yakuake/sessions org.kde.yakuake.terminalIdsForSessionId 23
# qdbus org.kde.yakuake /yakuake/sessions org.kde.yakuake.sessionIdForTerminalId 24
