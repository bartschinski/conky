--------------------------------------------------------------------------------
--
--	created by Phillip Bartschinski <phillip@bartschinski.com>
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
	orange 			= {r = 221, g = 72, 	b = 20, 	a = 1},
	orange_light 	= {r = 221, g = 72, 	b = 20, 	a = 0.5},
	blue 			= {r = 0, 	g = 136, 	b = 204, 	a = 1},
	blue_light 		= {r = 0, 	g = 136, 	b = 204, 	a = 0.5},
	green 			= {r = 170, g = 187, 	b = 170, 	a = 1},
	green_light		= {r = 170, g = 187, 	b = 170, 	a = 0.5}
}

config_cpu = {
	color = 'blue',
	count = 2,
	thickness = 10
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
	width 	= 0,
	height 	= 0,
	start_circle = 90,
	end_circle	= 360,
	size_offset = 0
}

datetime = {
	year 	= 0,
	month	= 0,
	day 	= 0,
	hour 	= 0,
	min 	= 0,
	sec 	= 0
}


--------------------------------------------------
-- set the variables on the initialize
--------------------------------------------------
function set_init_param()
	if (config['width'] == 0) then
		config['width']		= conky_window.width / 2;
	end
	
	if (config['height'] == 0) then
		config['height']	= conky_window.height / 2;
	end
	
	config['size_offset'] = 0;
	
	datetime['year'] 	= tonumber(get_conky_val('time', '%Y'));
	datetime['month']	= tonumber(get_conky_val('time', '%m'));
	datetime['day'] 	= tonumber(get_conky_val('time', '%d'));
	datetime['hour'] 	= tonumber(get_conky_val('time', '%H'));
	datetime['min'] 	= tonumber(get_conky_val('time', '%M'));
	datetime['sec'] 	= tonumber(get_conky_val('time', '%S'));
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
-- @param schema	color schema name
--------------------------------------------------
function color_rgba(schema)
	return colors[schema]['r'] / 255, colors[schema]['g'] / 255, colors[schema]['b'] / 255, colors[schema]['a'];
end


--------------------------------------------------
-- parse the conky values
-- 
-- @param var	Variable
-- @param arg	Argument
--------------------------------------------------
function get_conky_val(var, arg) 
	return conky_parse('${'..var..' '..arg..'}');
end


--------------------------------------------------
-- calculate the grade to double
-- 
-- @param var	Variable
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
-- @param color_schema	color schema name
-- @param size			size of circle
-- @param start_grad	start grad value
-- @param end_grad		end grad value
-- @param thickness		thickness of circle line
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
-- @param color			color schema name
-- @param size_offset	spacing of next circle
-- @param conf			parameter value
-- @param thickness		thickness of circle line
--------------------------------------------------
function draw_std_circle(color, size_offset, conf, thickness)
	draw_arcs(color..'_light', get_max_size_of_arc() - size_offset, config['start_circle'], config['end_circle'], thickness);
	draw_arcs(color, get_max_size_of_arc() - size_offset, config['start_circle'], (((360 - 90) / 100) * tonumber(conf)) + 90, thickness);
end


--------------------------------------------------
-- draw the cpu circles
--------------------------------------------------
function draw_cpu()
	local i = 0;
	
    while i < config_cpu['count'] do
		draw_std_circle(config_cpu['color'], offset(config_cpu['thickness'] * 1.5), get_conky_val('cpu', 'cpu'..i), config_cpu['thickness']);
		i = i + 1;
	end
end


--------------------------------------------------
-- draw the memory circle
--------------------------------------------------
function draw_mem()
	draw_std_circle(config_mem['color'], offset(config_mem['thickness'] * (5 / 3)), get_conky_val('memperc', ''), config_mem['thickness']);
	draw_std_circle(config_mem['color_swap'], offset(config_mem['thickness'] * (5 / 3)), get_conky_val('swapperc', ''), config_mem['thickness']);
	offset(config_mem['thickness'])
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
	end
	
	cairo_surface_destroy(cs);
	cairo_destroy(display);

end
