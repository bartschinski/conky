
starbound = {};
starbound.server = {
  host = 'gontrix.de',
  port = 21026
}
starbound.gameInfo = {
    players = {},
    map = '',
    maxPlayers = '10',
    version = ''
}


--------------------------------------------------
-- get the map and max player
-- 
-- @return  map, maxPlayer  return the map name and max players
--------------------------------------------------
function starbound.getServerInfo()
  local text = util.fromhex('FFFFFFFF')..'TSource Engine Query'..util.fromhex('00');
  local response = ssq.request(text, starbound.server['host'], starbound.server['port']);
  local version = '';
  
  if not(response == '') then
    local first, last = string.find(response, '444C00');
    version = string.sub(response, last + 1, -9);
    version = util.fromhex(string.gsub(version, '00', ''));
  end;
  
  return version
end


--------------------------------------------------
-- get the server info with map max player and player list
-- 
-- @return  {players, map, maxPlayers}  return the map name, max players and player list
--------------------------------------------------
function starbound.getInfo()
  if conky_parse('${updates}') % 60 == 0 or starbound.gameInfo['version'] == '' then
    starbound.gameInfo['version'] = starbound.getServerInfo();
    starbound.gameInfo['players'] = ssq.getPlayerInfo(starbound.server['host'], starbound.server['port']);
  end
  
  return starbound.gameInfo;
end
