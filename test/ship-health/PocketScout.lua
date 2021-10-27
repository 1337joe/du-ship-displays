-- Dump of the element data for the pocket scout.

-- dump script:
-- local idList = core.getElementIdList()
-- table.sort(idList)
-- local display = "local elements = {}\n"
-- local tPos, rot
-- for index, key in pairs(idList) do
--     tPos = core.getElementPositionById(key)
--     forward = core.getElementForwardById(key)
--     up = core.getElementUpById(key)
--     display = display .. string.format([[
-- elements[%d] = {
--     name = "%s",
--     type = "%s",
--     position = {%f, %f, %f},
--     forward = {%f, %f, %f},
--     up = {%f, %f, %f},
--     hp = %f,
--     maxHp = %d
-- }
-- ]], key, core.getElementNameById(key), core.getElementTypeById(key),
--                 tPos[1], tPos[2], tPos[3], forward[1], forward[2], forward[3], up[1], up[2], up[3],
--                 core.getElementHitPointsById(key), core.getElementMaxHitPointsById(key))
-- end
-- display = display .. "return elements\n"
-- hpScreen.setHTML(display)
-- unit.exit()

local elements = {}
elements[1] = {
    name = "Dynamic Core Unit xs [1]",
    type = "Dynamic Core Unit",
    position = {0.125000, -3.125000, -1.115871},
    forward = {-0.000000, 1.000000, 0.000000},
    up = {-0.000000, -0.000000, 1.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[4] = {
    name = "Wing variant m [4]",
    type = "Wing Variant",
    position = {4.615999, -3.250000, -1.875002},
    forward = {-0.000000, 1.000000, 0.000000},
    up = {-0.000001, 0.000000, -1.000000},
    hp = 1604.000000,
    maxHp = 1604
}
elements[9] = {
    name = "Flat hover engine l [9]",
    type = "Flat Hover Engine",
    position = {0.125000, -2.000000, -2.059115},
    forward = {-0.000000, -0.000000, 1.000000},
    up = {-1.000000, 0.000000, -0.000000},
    hp = 1033.000000,
    maxHp = 1033
}
elements[10] = {
    name = "Atmospheric Airbrake m [10]",
    type = "Atmospheric Airbrake",
    position = {0.500000, -4.500000, -2.301984},
    forward = {-1.000000, 0.000000, -0.000000},
    up = {0.000000, -0.000000, -1.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[12] = {
    name = "Atmospheric Airbrake m [12]",
    type = "Atmospheric Airbrake",
    position = {0.500000, 1.250000, -2.301961},
    forward = {-1.000000, 0.000000, -0.000000},
    up = {0.000000, -0.000000, -1.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[13] = {
    name = "Atmospheric Airbrake m [13]",
    type = "Atmospheric Airbrake",
    position = {-0.250000, 1.250000, -2.299032},
    forward = {-1.000000, 0.000001, -0.000000},
    up = {0.000000, -0.000000, -1.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[21] = {
    name = "Emergency controller [21]",
    type = "Emergency Controller",
    position = {-0.581381, -1.477609, -1.000000},
    forward = {0.000000, 1.000000, 0.000000},
    up = {1.000000, -0.000000, 0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[22] = {
    name = "Remote Controller [22]",
    type = "Remote Controller",
    position = {-0.564122, -1.125000, -0.875000},
    forward = {0.000000, 1.000000, 0.000000},
    up = {1.000000, -0.000000, 0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[23] = {
    name = "Transponder [23]",
    type = "Transponder",
    position = {0.750000, -0.750000, -1.499028},
    forward = {-0.000000, 1.000000, -0.000000},
    up = {-0.000000, 0.000000, 1.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[25] = {
    name = "Uncommon Maneuver Atmospheric Engine s [25]",
    type = "Uncommon Maneuver Atmospheric Engine",
    position = {0.875274, -5.169556, -0.580842},
    forward = {0.000000, 1.000000, 0.000000},
    up = {0.992278, -0.000000, 0.124035},
    hp = 162.000000,
    maxHp = 162
}
elements[30] = {
    name = "Atmospheric Fuel Tank m [30]",
    type = "Atmospheric Fuel Tank",
    position = {0.124268, 1.125000, -1.350868},
    forward = {0.000000, -1.000000, 0.000000},
    up = {-1.000000, -0.000000, 0.000000},
    hp = 1315.000000,
    maxHp = 1315
}
elements[35] = {
    name = "Landing Gear xs [35]",
    type = "Landing Gear",
    position = {-1.125000, -3.500000, -2.581827},
    forward = {0.000000, 1.000000, 0.000000},
    up = {0.000000, 0.000000, 1.000000},
    hp = 63.000000,
    maxHp = 63
}
elements[36] = {
    name = "Landing Gear xs [36]",
    type = "Landing Gear",
    position = {1.375000, -3.500000, -2.581827},
    forward = {0.000000, 1.000000, 0.000000},
    up = {0.000000, 0.000000, 1.000000},
    hp = 63.000000,
    maxHp = 63
}
elements[38] = {
    name = "Landing Gear xs [38]",
    type = "Landing Gear",
    position = {0.125000, 6.000000, -2.591827},
    forward = {0.000000, 1.000000, 0.000000},
    up = {0.000000, 0.000000, 1.000000},
    hp = 63.000000,
    maxHp = 63
}
elements[40] = {
    name = "Headlight [40]",
    type = "Headlight",
    position = {0.125000, 6.348576, -2.250000},
    forward = {-0.000000, 1.000000, -0.000000},
    up = {-0.000000, 0.000000, 1.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[67] = {
    name = "Uncommon Maneuver Atmospheric Engine s [67]",
    type = "Uncommon Maneuver Atmospheric Engine",
    position = {-0.633877, -5.183932, -0.573384},
    forward = {-0.000000, 1.000000, -0.000000},
    up = {-0.992278, -0.000000, 0.124035},
    hp = 162.000000,
    maxHp = 162
}
elements[69] = {
    name = "Wing s [69]",
    type = "Wing",
    position = {0.125000, -5.375000, 1.384995},
    forward = {-0.000000, 1.000000, -0.000000},
    up = {1.000000, 0.000000, 0.000000},
    hp = 131.000000,
    maxHp = 131
}
elements[70] = {
    name = "Atmospheric Airbrake m [70]",
    type = "Atmospheric Airbrake",
    position = {-0.250000, -4.500000, -2.299032},
    forward = {-1.000000, 0.000000, -0.000000},
    up = {0.000000, -0.000000, -1.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[71] = {
    name = "Adjustor s [71]",
    type = "Adjustor",
    position = {-1.325434, -5.625000, -1.874938},
    forward = {1.000000, -0.000000, 0.000000},
    up = {-0.000000, 0.000000, 1.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[72] = {
    name = "Adjustor s [72]",
    type = "Adjustor",
    position = {1.575504, -5.625000, -1.874938},
    forward = {-1.000000, 0.000000, 0.000000},
    up = {0.000000, -0.000000, 1.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[73] = {
    name = "Adjustor s [73]",
    type = "Adjustor",
    position = {-1.075434, 2.875000, -2.124938},
    forward = {1.000000, -0.000000, 0.000000},
    up = {-0.000000, 0.000000, 1.000000},
    hp = 0.000000,
    maxHp = 50
}
elements[74] = {
    name = "Adjustor s [74]",
    type = "Adjustor",
    position = {1.325434, 2.875000, -2.124938},
    forward = {-1.000000, 0.000000, 0.000000},
    up = {0.000000, -0.000000, 1.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[77] = {
    name = "Adjustor s [77]",
    type = "Adjustor",
    position = {-0.250055, 5.500126, -2.325050},
    forward = {-0.000000, 0.000000, 1.000000},
    up = {0.000000, 1.000000, -0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[78] = {
    name = "Adjustor s [78]",
    type = "Adjustor",
    position = {0.500000, 5.500062, -2.325434},
    forward = {-0.000000, 0.000000, 1.000000},
    up = {0.000000, 1.000000, -0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[81] = {
    name = "Adjustor s [81]",
    type = "Adjustor",
    position = {1.125000, -5.624938, -2.325536},
    forward = {-0.000000, 0.000000, 1.000000},
    up = {0.000000, 1.000000, -0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[82] = {
    name = "Adjustor s [82]",
    type = "Adjustor",
    position = {-0.875000, -5.624938, -2.325434},
    forward = {-0.000000, 0.000000, 1.000000},
    up = {0.000000, 1.000000, -0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[83] = {
    name = "Adjustor s [83]",
    type = "Adjustor",
    position = {6.250690, -2.998980, -2.061459},
    forward = {-0.000000, 0.000000, 1.000000},
    up = {0.000000, 1.000000, -0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[84] = {
    name = "Adjustor s [84]",
    type = "Adjustor",
    position = {-6.000892, -3.000116, -2.059990},
    forward = {-0.000000, 0.000000, 1.000000},
    up = {0.000000, 1.000000, -0.000000},
    hp = 49.994750,
    maxHp = 50
}
elements[86] = {
    name = "Adjustor s [86]",
    type = "Adjustor",
    position = {6.250000, -2.999938, -1.700725},
    forward = {0.000000, 0.000000, -1.000000},
    up = {-0.000000, 1.000000, 0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[87] = {
    name = "Adjustor s [87]",
    type = "Adjustor",
    position = {-6.000694, -2.998991, -1.687975},
    forward = {0.000000, 0.000000, -1.000000},
    up = {-0.000000, 1.000000, 0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[89] = {
    name = "Programming board [89]",
    type = "Programming Board",
    position = {0.749999, -1.375000, -0.810607},
    forward = {0.000000, -0.000000, -1.000000},
    up = {-1.000000, 0.000000, 0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[90] = {
    name = "Transparent Screen xs [90]",
    type = "Transparent Screen",
    position = {0.134162, -0.749436, -0.124766},
    forward = {0.000000, -0.923880, -0.382683},
    up = {0.000000, -0.382683, 0.923880},
    hp = 50.000000,
    maxHp = 50
}
elements[91] = {
    name = "Databank [91]",
    type = "Databank",
    position = {-0.250233, -2.630520, -1.250000},
    forward = {0.000000, 1.000000, 0.000000},
    up = {0.000000, 0.000000, 1.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[92] = {
    name = "Adjustor s [92]",
    type = "Adjustor",
    position = {-1.085434, 3.375000, -2.125062},
    forward = {1.000000, 0.000000, -0.000000},
    up = {-0.000000, -0.000000, -1.000000},
    hp = 0.000000,
    maxHp = 50
}
elements[93] = {
    name = "Adjustor s [93]",
    type = "Adjustor",
    position = {1.335434, 3.375000, -2.125062},
    forward = {-1.000000, -0.000000, -0.000000},
    up = {0.000000, 0.000000, -1.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[99] = {
    name = "Wing variant m [99]",
    type = "Wing Variant",
    position = {-4.366000, -3.250000, -1.874998},
    forward = {0.000000, 1.000000, -0.000000},
    up = {0.000001, 0.000000, 1.000000},
    hp = 1604.000000,
    maxHp = 1604
}
elements[100] = {
    name = "Wing xs [100]",
    type = "Wing",
    position = {1.982000, 3.972845, -2.125000},
    forward = {-0.000000, 1.000000, 0.000000},
    up = {-0.000000, 0.000000, -1.000000},
    hp = 44.751100,
    maxHp = 50
}
elements[101] = {
    name = "Wing xs [101]",
    type = "Wing",
    position = {-1.732000, 3.972845, -2.125000},
    forward = {0.000000, 1.000000, -0.000000},
    up = {0.000000, 0.000000, 1.000000},
    hp = 0.000000,
    maxHp = 50
}
elements[102] = {
    name = "Adjustor xs [102]",
    type = "Adjustor",
    position = {-0.500028, 5.125027, -1.912299},
    forward = {0.000000, -0.000000, -1.000000},
    up = {1.000000, -0.000000, 0.000000},
    hp = 0.000000,
    maxHp = 50
}
elements[103] = {
    name = "Adjustor xs [103]",
    type = "Adjustor",
    position = {-0.375028, 5.375027, -1.912306},
    forward = {0.000000, -0.000000, -1.000000},
    up = {1.000000, -0.000000, 0.000000},
    hp = 1.904350,
    maxHp = 50
}
elements[104] = {
    name = "Adjustor xs [104]",
    type = "Adjustor",
    position = {0.625146, 5.375000, -1.912091},
    forward = {0.000000, -0.000000, -1.000000},
    up = {1.000000, 0.000000, -0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[105] = {
    name = "Adjustor xs [105]",
    type = "Adjustor",
    position = {0.750146, 5.125000, -1.911899},
    forward = {0.000000, -0.000000, -1.000000},
    up = {1.000000, 0.000000, -0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[106] = {
    name = "Adjustor s [106]",
    type = "Adjustor",
    position = {-0.075453, 5.622806, -1.499938},
    forward = {1.000000, -0.000000, 0.000000},
    up = {-0.000000, 0.000000, 1.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[107] = {
    name = "Adjustor s [107]",
    type = "Adjustor",
    position = {0.321866, 5.621327, -1.499938},
    forward = {-1.000000, 0.000000, 0.000000},
    up = {0.000000, -0.000000, 1.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[108] = {
    name = "Hovercraft seat controller [108]",
    type = "Hovercraft Seat Controller",
    position = {0.125000, -1.625000, -0.604827},
    forward = {0.000000, 1.000000, 0.000000},
    up = {0.000000, 0.000000, 1.000000},
    hp = 187.000000,
    maxHp = 187
}
elements[111] = {
    name = "Receiver xs [111]",
    type = "Receiver",
    position = {0.500000, -2.625000, -1.042812},
    forward = {-0.000000, 1.000000, 0.000000},
    up = {-0.000000, -0.000000, 1.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[112] = {
    name = "Emitter xs [112]",
    type = "Emitter",
    position = {0.500000, -2.875000, -1.188216},
    forward = {-0.000000, 1.000000, -0.000000},
    up = {-0.000000, 0.000000, 1.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[116] = {
    name = "Uncommon Maneuver Atmospheric Engine m [113]",
    type = "Uncommon Maneuver Atmospheric Engine",
    position = {0.125000, -5.470356, -1.079600},
    forward = {0.000000, 1.000000, 0.000000},
    up = {-0.000000, -0.000000, 1.000000},
    hp = 1933.000000,
    maxHp = 1933
}
elements[114] = {
    name = "Atmospheric Radar s [114]",
    type = "Atmospheric Radar",
    position = {0.125000, 3.273973, -1.408216},
    forward = {0.000000, -1.000000, 0.000000},
    up = {0.000000, 0.000000, 1.000000},
    hp = 88.000000,
    maxHp = 88
}
elements[115] = {
    name = "Hover engine m [115]",
    type = "Hover Engine",
    position = {0.125000, 4.245327, -2.154612},
    forward = {0.000000, 0.000000, 1.000000},
    up = {0.000000, 1.000000, -0.000000},
    hp = 462.000000,
    maxHp = 462
}
return elements
