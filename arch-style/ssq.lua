
ssq = {};


--------------------------------------------------
-- udp request
-- 
-- @param text  text to sent
-- @param host  Host address example.com
-- @param port  UDP port for request
-- 
-- @return  Response from request in hex
--------------------------------------------------
function ssq.request(text, host, port)
  local response = "";

  if not(host == '') and not(port == '') then
    local socket = require("socket");
    local ip = socket.dns.toip(host);
    local udp = socket.udp();
  
    udp:setpeername(ip, port);
    udp:settimeout(3);
  
    local sent, err = udp:send(text);
    
    if not err then
      local dgram, err = udp:receive();
      
      if dgram then
        response = util.tohex(dgram);
      end
    end
  end

  return response;
end


--------------------------------------------------
-- player request
-- 
-- @param host  Host address example.com
-- @param port  UDP port for request
-- 
-- @return  array with struct player and time
--------------------------------------------------
function ssq.getPlayerInfo(host, port)
  local token = ssq.request(util.fromhex('FFFFFFFF55FFFFFFFF'), host, port);
  local replace = '';
  local info = {};
  token, replace = string.gsub(token, 'FFFFFFFF41', 'FFFFFFFF55');
  
  local response = ssq.request(util.fromhex(token), host, port);

  if (string.len(response) > 14) then
    response = string.sub(response, 13, -1);
    local i = 1;
    
    while 1 do
      response = string.sub(response, 3, -1);
      local first, last = string.find(response, '([^0][0][0][^0])');
      local firstRecord = string.sub(response, 0, first);
      local time = string.sub(firstRecord, string.len(firstRecord) - 7, -1);
      local player = string.sub(firstRecord, 0, -17);
      
      local tmp = {
        player = util.fromhex(player),
        time = time
      }
      
      info[i] = tmp;

      response = string.gsub(response, firstRecord, '');

      i = i + 1;
      if string.len(response) == 0 then break; end
    end
  end
  
  return info;
end
