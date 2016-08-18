
ark = {};
ark.server = {
  host = 'gontrix.de',
  port = 27015
}
ark.gameInfo = {
    players = {},
    map = '',
    maxPlayers = '0'
}


--------------------------------------------------
-- get the map and max player
-- 
-- @return  map, maxPlayer  return the map name and max players
--------------------------------------------------
function ark.getServerInfo()
  local text = util.fromhex('FFFFFFFF')..'TSource Engine Query'..util.fromhex('00');
  local response = ssq.request(text, ark.server['host'], ark.server['port']);
  local map = '';
  local maxPlayer = 0;
  
  if not(response == '') then
    local first, last = string.find(response, '([^0][0][0][^0])');
    map = string.sub(response, first + 3, -1);
    first, last = string.find(map, '([^0][0][0][^0])');
    map = util.fromhex(string.sub(map, 0, first));
    
    maxPlayer = response;
    first, last = string.find(maxPlayer, '4E554D4F50454E505542434F4E4E3A');
    maxPlayer = string.sub(maxPlayer, last + 1, -1);
    first, last = string.find(maxPlayer, '2C');
    maxPlayer = util.fromhex(string.sub(maxPlayer, 0, first - 1));
  end;
  
  return map, maxPlayer
end


--------------------------------------------------
-- get the server info with map max player and player list
-- 
-- @return  {players, map, maxPlayers}  return the map name, max players and player list
--------------------------------------------------
function ark.getInfo()
  if conky_parse('${updates}') % 60 == 0 or ark.gameInfo['map'] == '' then
    ark.gameInfo['map'], ark.gameInfo['maxPlayers'] = ark.getServerInfo();
    ark.gameInfo['players'] = ssq.getPlayerInfo(ark.server['host'], ark.server['port']);
  end
  
  return ark.gameInfo;
end
