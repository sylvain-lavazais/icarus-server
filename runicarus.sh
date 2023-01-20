echo ====================
echo ==  ICARUS SERVER ==
echo ====================

echo Server Name : $SERVERNAME
echo Game Port   : $PORT
echo Query Port  : $QUERYPORT
echo Steam UID   : $STEAM_USERID
echo Steam GID   : $STEAM_GROUPID
echo Branch      : $BRANCH

echo ====================
echo Setting User ID...

groupmod -g "${STEAM_GROUPID}" steam \
  && usermod -u "${STEAM_USERID}" -g "${STEAM_GROUPID}" steam

export WINEPREFIX=/home/steam/icarus
export WINEARCH=win64
export WINEPATH=/game/icarus

echo Initializing Wine...
sudo -u steam wineboot --init > /dev/null 2>&1

echo Changing wine folder permissions...
chown -R "${STEAM_USERID}":"${STEAM_GROUPID}" /home/steam

echo ==============================================================
echo Updating/downloading game through steam
echo ==============================================================
sudo -u steam /home/steam/steamcmd/steamcmd.sh \
    +@sSteamCmdForcePlatformType windows \
    +force_install_dir /game/icarus \
    +login anonymous \
    +app_update 2089300 -beta "${BRANCH}" validate \
    +quit

echo ==============================================================
echo Setting Steam Async Timeout value in Engine.ini to echo $STEAM_ASYNC_TIMEOUT
echo ==============================================================
configPath='/home/steam/.wine/drive_c/icarus/Saved/Config/WindowsServer'
if [[ ! -e ${configPath}/Engine.ini ]]; then
  mkdir -p ${configPath}
  touch ${configPath}/Engine.ini
fi

if ! grep -Fxq "[OnlineSubsystemSteam]" ${configPath}/Engine.ini
then
    echo '[OnlineSubsystemSteam]' >> ${configPath}/Engine.ini
    echo 'AsyncTaskTimeout=' >> ${configPath}/Engine.ini
fi

sedCommand='/AsyncTaskTimeout=/c\AsyncTaskTimeout='${STEAM_ASYNC_TIMEOUT}
sed -i ${sedCommand} ${configPath}/Engine.ini

echo ==============================================================
echo Starting Server - Buckle up prospectors!
echo ==============================================================
sudo -u steam wine /game/icarus/Icarus/Binaries/Win64/IcarusServer-Win64-Shipping.exe -Log -UserDir='C:\icarus' -SteamServerName="${SERVERNAME}" -PORT="${PORT}" -QueryPort="${QUERYPORT}"
