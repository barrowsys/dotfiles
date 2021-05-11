#!/bin/bash
###############################################################
# THIS FILE IS LICENSED UNDER THE FOLLOWING TERMS             #
#                                                             #
# this code may not be used for any purpose. be gay, do crime #
#                                                             #
# THE FOLLOWING MESSAGE IS NOT A LICENSE                      #
#                                                             #
# <barrow@tilde.team> wrote this file.                        #
# by reading this message, you are reading "TRANS RIGHTS".    #
# this file and the content within it is the queer agenda.    #
# if we meet some day, and you think this stuff is worth it,  #
# you can buy me a beer, tea, or something stronger.          #
# -Ezra Barrow                                                #
###############################################################

SID="$HOME/bin/yakuake/sessionid.tmp"
touch "$SID"
CALC_SESSION=$(cat $SID)
CALC_TERM=`qdbus org.kde.yakuake /yakuake/sessions org.kde.yakuake.terminalIdsForSessionId $CALC_SESSION`
CALC_TITLE=`qdbus org.kde.yakuake /yakuake/tabs org.kde.yakuake.tabTitle $CALC_SESSION`
if [[ $CALC_TITLE != "Calculator" ]]; then
	$HOME/bin/yakuake/setup.sh
	CALC_SESSION=$(cat $SID)
fi
qdbus org.kde.yakuake /yakuake/MainWindow_1 org.qtproject.Qt.QWidget.hide
qdbus org.kde.yakuake /yakuake/sessions org.kde.yakuake.raiseSession $CALC_SESSION
qdbus org.kde.yakuake /yakuake/window org.kde.yakuake.toggleWindowState
