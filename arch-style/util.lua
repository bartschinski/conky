
util = {};


--------------------------------------------------
-- convert hex to text
-- 
-- @param str   Hex code
-- 
-- @return  String from hex
--------------------------------------------------
function util.fromhex(str)
    return (str:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end))
end


--------------------------------------------------
-- convert text to hex
-- 
-- @param str   Text
-- 
-- @return  Hex code
--------------------------------------------------
function util.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end
