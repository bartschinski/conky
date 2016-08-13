--------------------------------------------------------------------------------
--
--  created by Phillip Bartschinski <phillip@bartschinski.com>
--
--------------------------------------------------------------------------------


--------------------------------------------------
-- include cairo grafic libary
--------------------------------------------------
require 'cairo'


--------------------------------------------------
-- set the global variables for configuration
--------------------------------------------------
colors = {
  orange        = {r = 221, g = 72,   b = 20,   a = 1},
  orange_light  = {r = 221, g = 72,   b = 20,   a = 0.5},
  blue          = {r = 0,   g = 136,  b = 204,  a = 1},
  blue_light    = {r = 0,   g = 136,  b = 204,  a = 0.5},
  green         = {r = 170, g = 187,  b = 170,  a = 1},
  green_light   = {r = 170, g = 187,  b = 170,  a = 0.5}
}

config_cpu = {
  color = 'blue',
  count = 40,
  thickness = 5
}

config_mem = {
  color = 'blue',
  color_swap = 'green',
  thickness = 30
}

config_clock = {
  color = 'orange',
  thickness = 10
}

config = {
  width = 0,
  height = 0,
  start_circle = 90,
  end_circle = 360,
  size_offset = 0
}

datetime = {
  year  = 0,
  month = 0,
  day   = 0,
  hour  = 0,
  min   = 0,
  sec   = 0
}

font = {
  type  = 'Ubuntu',
  size  = 12,
  color = 'blue',
  face  = CAIRO_FONT_WEIGHT_NORMAL,
  slant = CAIRO_FONT_SLANT_NORMAL
}

udpServer = {
  ark = { host = 'gontrix.de', port = '27015' }
}

--------------------------------------------------
-- set the variables on the initialize
--------------------------------------------------
function set_init_param()
  if (config['width'] == 0) then
    config['width']    = conky_window.width / 2;
  end

  if (config['height'] == 0) then
    config['height']  = conky_window.height / 2;
  end

  config['size_offset'] = 0;

  datetime['year']   = tonumber(get_conky_val('time', '%Y'));
  datetime['month']  = tonumber(get_conky_val('time', '%m'));
  datetime['day']   = tonumber(get_conky_val('time', '%d'));
  datetime['hour']   = tonumber(get_conky_val('time', '%H'));
  datetime['min']   = tonumber(get_conky_val('time', '%M'));
  datetime['sec']   = tonumber(get_conky_val('time', '%S'));
end


--------------------------------------------------
-- return and calculate the circle offset
--------------------------------------------------
function offset(size_offset)
  config['size_offset'] = config['size_offset'] + size_offset;
  return config['size_offset'];
end


--------------------------------------------------
-- get the rgba in the cairo format
--
-- @param schema  color schema name
--------------------------------------------------
function color_rgba(schema)
  return colors[schema]['r'] / 255, colors[schema]['g'] / 255, colors[schema]['b'] / 255, colors[schema]['a'];
end


--------------------------------------------------
-- parse the conky values
--
-- @param var  Variable
-- @param arg  Argument
--------------------------------------------------
function get_conky_val(var, arg)
  return conky_parse('${'..var..' '..arg..'}');
end


--------------------------------------------------
-- calculate the grade to double
--
-- @param var  Variable
--------------------------------------------------
function calc_grad(grad)
  if grad == 0 then
    return 0;
  else
    return grad / 360 * 2 * math.pi;
  end
end


--------------------------------------------------
-- get the max sice of the circle
--------------------------------------------------
function get_max_size_of_arc()
  if config['height'] > config['width'] then
    return (config['width']) - 25;
  else
    return (config['height']) - 25;
  end
end


--------------------------------------------------
-- draw a circle with the config
--
-- @param color_schema  color schema name
-- @param size          size of circle
-- @param start_grad    start grad value
-- @param end_grad      end grad value
-- @param thickness     thickness of circle line
--------------------------------------------------
function draw_arcs(color_schema, size, start_grad, end_grad, thickness)
  cairo_arc(display, config['width'], config['height'], size, calc_grad(start_grad), calc_grad(end_grad));
  cairo_set_source_rgba(display, color_rgba(color_schema));
  cairo_set_line_width(display, thickness);
  cairo_stroke(display);
end


--------------------------------------------------
-- draw a standard circle pair
--
-- @param color         color schema name
-- @param size_offset   spacing of next circle
-- @param conf          parameter value
-- @param thickness     thickness of circle line
--------------------------------------------------
function draw_std_circle(color, size_offset, conf, thickness)
  draw_arcs(color..'_light', get_max_size_of_arc() - size_offset, config['start_circle'], config['end_circle'], thickness);
  draw_arcs(color, get_max_size_of_arc() - size_offset, config['start_circle'], (((360 - 90) / 100) * tonumber(conf)) + 90, thickness);
end


--------------------------------------------------
-- draw the cpu circles
--------------------------------------------------
function draw_cpu()
  local i = 1;

  while i <= config_cpu['count'] do
    draw_std_circle(config_cpu['color'], offset(config_cpu['thickness']), get_conky_val('cpu', 'cpu'..i), config_cpu['thickness']);
    i = i + 1;
  end
  
  drawText('CPU ('..get_conky_val('cpu', 'cpu0')..'%)', config_cpu['color'], 24, config['width'] + 10, config['height'] + (config['height'] - offset(0)) - config_cpu['thickness']);
end


--------------------------------------------------
-- draw the memory circle
--------------------------------------------------
function draw_mem()
  draw_std_circle(config_mem['color'], offset(config_mem['thickness'] * (5 / 3)), get_conky_val('memperc', ''), config_mem['thickness']);
  drawText('RAM ('..conky_parse('$mem')..' / '..conky_parse('$memmax')..')', config_mem['color'], 24, config['width'] + 10, config['height'] + (config['height'] - offset(0)) - config_mem['thickness'] * 0.6);
  
  draw_std_circle(config_mem['color_swap'], offset(config_mem['thickness'] * (5 / 3)), get_conky_val('swapperc', ''), config_mem['thickness']);
  drawText('SWAP ('..conky_parse('$swap')..' / '..conky_parse('$swapmax')..')', config_mem['color_swap'], 24, config['width'] + 10, config['height'] + (config['height'] - offset(0)) - config_mem['thickness'] * 0.6);
  
  offset(config_mem['thickness']);
end


--------------------------------------------------
-- draw clock in the middl
--------------------------------------------------
function draw_clock()
  local color = config_clock['color'];
  local hour = datetime['hour'];

  if (hour < 12) then
    color = color..'_light';
  else
    hour = hour - 12;
  end

  draw_arcs(color, get_max_size_of_arc() - offset(config_clock['thickness'] * (3 / 2)), -90, (360 / 12 * hour) - 90, config_clock['thickness']);
  draw_arcs(color, get_max_size_of_arc() - offset(config_clock['thickness'] * (3 / 2)), -90, (360 / 60 * datetime['min']) - 90, config_clock['thickness']);
  draw_arcs(color, get_max_size_of_arc() - offset(config_clock['thickness'] * (3 / 2)), -90, (360 / 60 * datetime['sec']) - 90, config_clock['thickness']);
end


--------------------------------------------------
-- draw text
--------------------------------------------------
function drawText(text, color, size, pos_x, pos_y)
  cairo_select_font_face(display, font['type'], font['face'], font['slant']);
  cairo_set_font_size(display, size)
  cairo_set_source_rgba(display, color_rgba(color))
  
  cairo_move_to(display, pos_x, pos_y)
  cairo_show_text(display, text)
  
  cairo_stroke(display)
end


--------------------------------------------------
-- convert text to hex
--------------------------------------------------
function fromhex(str)
    return (str:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end))
end


--------------------------------------------------
-- convert hex to text
--------------------------------------------------
function tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end


--------------------------------------------------
-- udp request
--------------------------------------------------
function udpRequest(text, serverName)
  local socket = require("socket");
  local ip = socket.dns.toip(udpServer[serverName]['host']);
  local udp = socket.udp();
  local response = "";

  udp:setpeername(ip, udpServer[serverName]['port']);
  udp:settimeout(3);

  local sent, err = udp:send(text);

  if not err then
    local dgram, err = udp:receive();
    
    if dgram then
      response = tohex(dgram);
    end
  end
  
  return response;
end


--------------------------------------------------
-- display image
--------------------------------------------------
function displayImage(name, scale, pos_x, pos_y)
    local image = cairo_image_surface_create_from_png(name);
    cairo_scale(display, scale, scale);
    cairo_set_source_surface(display, image, pos_x / scale, pos_y / scale);
    cairo_paint(display);
    cairo_surface_destroy(image);
    cairo_scale(display, 1.0 / scale, 1.0 / scale);
end

--------------------------------------------------
-- get the Player from ark server
--------------------------------------------------
function getArkPlayers()
  local serverName = 'ark';
  local text = fromhex('FFFFFFFF55071FF903');
  local token = udpRequest(fromhex('FFFFFFFF55FFFFFFFF'), serverName);
  local replace = '';
  token, replace = string.gsub(token, 'FFFFFFFF41', 'FFFFFFFF55');
  
  local response = udpRequest(fromhex(token), serverName);
  response, replace = string.gsub(response, 'FFFFFFFF440100', '');
  response = string.sub(response, 13, -1);
    
  local players = {};
  local i = 1;
  
  while 1 do
    response = string.sub(response, 3, -1);
    local first, last = string.find(response, '([^0][0][0][^0])');
    local firstRecord = string.sub(response, 0, first);
    local f, l = string.find(firstRecord, '0000');
    
    players[i] = fromhex(string.sub(firstRecord, 0, f - 1));
    response = string.gsub(response, firstRecord, '');
    
    i = i + 1;
    if string.len(response) == 0 then break; end
  end
  
  return players;
end

gameConf = {
  ark = {
    players = {},
    map = '',
    maxPlayers = '0'
  }
}


function getArkInfo()
  local text = fromhex('FFFFFFFF')..'TSource Engine Query'..fromhex('00');
  local response = udpRequest(text, 'ark');
  
  local first, last = string.find(response, '([^0][0][0][^0])');
  local map = string.sub(response, first + 3, -1);
  first, last = string.find(map, '([^0][0][0][^0])');
  map = fromhex(string.sub(map, 0, first));
  
  local maxPlayer = response;
  first, last = string.find(maxPlayer, '4E554D4F50454E505542434F4E4E3A');
  maxPlayer = string.sub(maxPlayer, last + 1, -1);
  first, last = string.find(maxPlayer, '2C');
  maxPlayer = fromhex(string.sub(maxPlayer, 0, first - 1));
  
  return map, maxPlayer
end

function displayArkServer()
  local height = offset(0) + 200;

  if conky_parse('${updates}') % 60 == 0 then
    gameConf['ark']['map'], gameConf['ark']['maxPlayers'] = getArkInfo();
    gameConf['ark']['players'] = getArkPlayers();
  end
  
  
  displayImage('ark.png', 0.25, config['width'], height);
  
  drawText('Player', config_mem['color_swap'], 24, config['width'] + 150, height + 50);
  
  local countPlayer = 0;
  
  for index, player in pairs(gameConf['ark']['players']) do
    drawText(player, config_mem['color_swap'], 20, config['width'] + 150, height + 50 + (30 * index));
    countPlayer = countPlayer + 1;
  end
  
  drawText(gameConf['ark']['map'], config_mem['color_swap'], 24, config['width'], height + 90);
  drawText(countPlayer..' / '..gameConf['ark']['maxPlayers'], config_mem['color_swap'], 24, config['width'], height + 120);
end


--------------------------------------------------
-- main function call from conky
--------------------------------------------------
function conky_main()
  if conky_window == nil then
    return;
  end

  cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height);
  display = cairo_create(cs);

  set_init_param();

  if tonumber(conky_parse('${updates}')) > 5 then
    draw_cpu();
    draw_mem();
    draw_clock();
    
    displayArkServer();
  end

  cairo_surface_destroy(cs);
  cairo_destroy(display);

end
