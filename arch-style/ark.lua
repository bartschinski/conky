
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
-- get the Player from ark server
-- 
-- @return  Players in array
--------------------------------------------------
function ark.getPlayers()
  local serverName = 'ark';
  local text = util.fromhex('FFFFFFFF55071FF903');
  local token = ssq.request(util.fromhex('FFFFFFFF55FFFFFFFF'), ark.server['host'], ark.server['port']);
  local replace = '';
  token, replace = string.gsub(token, 'FFFFFFFF41', 'FFFFFFFF55');
  
  local response = ssq.request(util.fromhex(token), ark.server['host'], ark.server['port']);
  response, replace = string.gsub(response, 'FFFFFFFF440100', '');
  response = string.sub(response, 13, -1);
    
  local players = {};
  local i = 1;
  
  while 1 do
    response = string.sub(response, 3, -1);
    local first, last = string.find(response, '([^0][0][0][^0])');
    local firstRecord = string.sub(response, 0, first);
    local f, l = string.find(firstRecord, '0000');
    
    if f == nil then break; end
    
    players[i] = util.fromhex(string.sub(firstRecord, 0, f - 1));
    response = string.gsub(response, firstRecord, '');
    
    i = i + 1;
    if string.len(response) == 0 then break; end
  end
  
  return players;
end


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
    ark.gameInfo['players'] = ark.getPlayers();
  end
  
  return ark.gameInfo;
end
