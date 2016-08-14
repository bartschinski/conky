
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
