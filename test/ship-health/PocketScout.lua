-- Dump of the element data for the pocket scout.

-- dump script:
-- local idList = core.getElementIdList()
-- table.sort(idList)
-- local display = "local elements = {}\n"
-- local tPos, rot
-- for index, key in pairs(idList) do
--     tPos = core.getElementPositionById(key)
--     rot = core.getElementRotationById(key)
--     display = display .. string.format([[
-- elements[%d] = {
--     name = "%s",
--     type = "%s",
--     position = {%f, %f, %f},
--     rotation = {%f, %f, %f},
--     hp = %f,
--     maxHp = %d
-- }
-- ]], key, core.getElementNameById(key), core.getElementTypeById(key), tPos[1], tPos[2], tPos[3], rot[1], rot[2], rot[3],
--                   core.getElementHitPointsById(key), core.getElementMaxHitPointsById(key))
-- end
-- display = display .. "return elements\n"
-- hpScreen.setHTML(display)
-- unit.exit()

local elements = {}
elements[1] = {
    name = "Dynamic core unit xs [1]",
    type = "Dynamic Core Unit",
    position = {16.125000, 12.875000, 14.884129},
    rotation = {0.000000, -0.000000, 0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[4] = {
    name = "Wing variant m [4]",
    type = "Wing variant",
    position = {20.615999, 12.750000, 14.124998},
    rotation = {-0.000000, 1.000000, 0.000000},
    hp = 1604.000000,
    maxHp = 1604
}
elements[9] = {
    name = "Flat hover engine l [9]",
    type = "Flat hover engine",
    position = {16.125000, 14.000000, 13.940885},
    rotation = {-0.500000, 0.500000, 0.500000},
    hp = 1033.000000,
    maxHp = 1033
}
elements[10] = {
    name = "Atmospheric airbrake m [10]",
    type = "Atmospheric Airbrake",
    position = {16.500000, 11.500000, 13.698016},
    rotation = {-0.707107, 0.707107, -0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[12] = {
    name = "Atmospheric airbrake m [12]",
    type = "Atmospheric Airbrake",
    position = {16.500000, 17.250000, 13.698039},
    rotation = {-0.707107, 0.707107, -0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[13] = {
    name = "Atmospheric airbrake m [13]",
    type = "Atmospheric Airbrake",
    position = {15.750000, 17.250000, 13.700968},
    rotation = {-0.707107, 0.707107, -0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[21] = {
    name = "Emergency controller [21]",
    type = "Emergency controller",
    position = {15.418619, 14.522391, 15.000000},
    rotation = {0.000000, 0.707107, 0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[22] = {
    name = "Remote controller [22]",
    type = "Remote Controller",
    position = {15.435878, 14.875000, 15.125000},
    rotation = {0.000000, 0.707107, 0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[23] = {
    name = "Transponder [23]",
    type = "Transponder",
    position = {16.750000, 15.250000, 14.500972},
    rotation = {-0.000000, -0.000000, 0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[25] = {
    name = "Maneuver Atmospheric Engine s [25]",
    type = "Uncommon Maneuver Atmospheric Engine",
    position = {16.932139, 10.449080, 15.386366},
    rotation = {0.000000, 0.634393, -0.000000},
    hp = 162.000000,
    maxHp = 162
}
elements[30] = {
    name = "Atmospheric fuel tank m [30]",
    type = "Atmospheric Fuel Tank",
    position = {16.124268, 17.125000, 14.649132},
    rotation = {-0.707107, -0.000000, 0.707107},
    hp = 1315.000000,
    maxHp = 1315
}
elements[35] = {
    name = "Landing gear xs [35]",
    type = "Landing Gear",
    position = {14.875000, 12.500000, 13.418173},
    rotation = {0.000000, 0.000000, 0.000000},
    hp = 63.000000,
    maxHp = 63
}
elements[36] = {
    name = "Landing gear xs [36]",
    type = "Landing Gear",
    position = {17.375000, 12.500000, 13.418173},
    rotation = {0.000000, 0.000000, 0.000000},
    hp = 63.000000,
    maxHp = 63
}
elements[38] = {
    name = "Landing gear xs [38]",
    type = "Landing Gear",
    position = {16.125000, 22.000000, 13.408173},
    rotation = {0.000000, 0.000000, 0.000000},
    hp = 63.000000,
    maxHp = 63
}
elements[40] = {
    name = "Headlight [40]",
    type = "Headlight",
    position = {16.125000, 22.348576, 13.750000},
    rotation = {-0.000000, -0.000000, 0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[67] = {
    name = "Maneuver Atmospheric Engine s [67]",
    type = "Uncommon Maneuver Atmospheric Engine",
    position = {15.317860, 10.449075, 15.386366},
    rotation = {0.000000, -0.634393, 0.000000},
    hp = 162.000000,
    maxHp = 162
}
elements[69] = {
    name = "Wing s [69]",
    type = "Wing",
    position = {16.125000, 10.625000, 17.384995},
    rotation = {-0.000000, 0.707107, -0.000000},
    hp = 131.000000,
    maxHp = 131
}
elements[70] = {
    name = "Atmospheric airbrake m [70]",
    type = "Atmospheric Airbrake",
    position = {15.750000, 11.500000, 13.700968},
    rotation = {-0.707107, 0.707107, -0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[71] = {
    name = "Adjustor s [71]",
    type = "Adjustor",
    position = {14.674566, 10.375000, 14.125062},
    rotation = {-0.000000, -0.000000, -0.707107},
    hp = 50.000000,
    maxHp = 50
}
elements[72] = {
    name = "Adjustor s [72]",
    type = "Adjustor",
    position = {17.575504, 10.375000, 14.125062},
    rotation = {0.000000, -0.000000, 0.707107},
    hp = 50.000000,
    maxHp = 50
}
elements[73] = {
    name = "Adjustor s [73]",
    type = "Adjustor",
    position = {14.924566, 18.875000, 13.875062},
    rotation = {-0.000000, -0.000000, -0.707107},
    hp = 0.000000,
    maxHp = 50
}
elements[74] = {
    name = "Adjustor s [74]",
    type = "Adjustor",
    position = {17.325434, 18.875000, 13.875062},
    rotation = {0.000000, -0.000000, 0.707107},
    hp = 50.000000,
    maxHp = 50
}
elements[77] = {
    name = "Adjustor s [77]",
    type = "Adjustor",
    position = {15.749945, 21.500126, 13.674950},
    rotation = {0.000000, 0.707107, 0.707107},
    hp = 50.000000,
    maxHp = 50
}
elements[78] = {
    name = "Adjustor s [78]",
    type = "Adjustor",
    position = {16.500000, 21.500062, 13.674566},
    rotation = {0.000000, 0.707107, 0.707107},
    hp = 50.000000,
    maxHp = 50
}
elements[81] = {
    name = "Adjustor s [81]",
    type = "Adjustor",
    position = {17.125000, 10.375062, 13.674464},
    rotation = {0.000000, 0.707107, 0.707107},
    hp = 50.000000,
    maxHp = 50
}
elements[82] = {
    name = "Adjustor s [82]",
    type = "Adjustor",
    position = {15.125000, 10.375062, 13.674566},
    rotation = {0.000000, 0.707107, 0.707107},
    hp = 50.000000,
    maxHp = 50
}
elements[83] = {
    name = "Adjustor s [83]",
    type = "Adjustor",
    position = {22.125000, 13.131260, 13.950422},
    rotation = {0.000000, 0.661803, 0.749678},
    hp = 50.000000,
    maxHp = 50
}
elements[84] = {
    name = "Adjustor s [84]",
    type = "Adjustor",
    position = {10.125000, 13.125062, 13.948819},
    rotation = {0.000000, 0.707107, 0.707107},
    hp = 49.994750,
    maxHp = 50
}
elements[86] = {
    name = "Adjustor s [86]",
    type = "Adjustor",
    position = {22.250000, 13.000062, 14.299275},
    rotation = {-0.707107, -0.000000, 0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[87] = {
    name = "Adjustor s [87]",
    type = "Adjustor",
    position = {10.000000, 13.006115, 14.298417},
    rotation = {-0.749678, -0.000000, 0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[89] = {
    name = "Programming board [89]",
    type = "Programming board",
    position = {16.749999, 14.625000, 15.189393},
    rotation = {-0.500000, -0.500000, 0.500000},
    hp = 50.000000,
    maxHp = 50
}
elements[90] = {
    name = "Transparent screen xs [90]",
    type = "Transparent Screen",
    position = {16.134162, 15.250564, 15.875234},
    rotation = {0.000000, -0.195090, 0.980785},
    hp = 50.000000,
    maxHp = 50
}
elements[91] = {
    name = "Databank [91]",
    type = "Databank",
    position = {15.749767, 13.369480, 14.750000},
    rotation = {0.000000, 0.000000, 0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[92] = {
    name = "Adjustor s [92]",
    type = "Adjustor",
    position = {14.914566, 19.375000, 13.874938},
    rotation = {0.707107, 0.707107, -0.000000},
    hp = 0.000000,
    maxHp = 50
}
elements[93] = {
    name = "Adjustor s [93]",
    type = "Adjustor",
    position = {17.335434, 19.375000, 13.874938},
    rotation = {0.707107, -0.707107, 0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[99] = {
    name = "Wing variant m [99]",
    type = "Wing variant",
    position = {11.634000, 12.750000, 14.125002},
    rotation = {-0.000000, 0.000000, -0.000000},
    hp = 1604.000000,
    maxHp = 1604
}
elements[100] = {
    name = "Wing xs [100]",
    type = "Wing",
    position = {17.982000, 19.972845, 13.875000},
    rotation = {-0.000000, 1.000000, 0.000000},
    hp = 44.751100,
    maxHp = 50
}
elements[101] = {
    name = "Wing xs [101]",
    type = "Wing",
    position = {14.268000, 19.972845, 13.875000},
    rotation = {-0.000000, 0.000000, -0.000000},
    hp = 0.000000,
    maxHp = 50
}
elements[102] = {
    name = "Adjustor xs [102]",
    type = "Adjustor",
    position = {15.499972, 21.125027, 14.087701},
    rotation = {0.500000, -0.500000, 0.500000},
    hp = 0.000000,
    maxHp = 50
}
elements[103] = {
    name = "Adjustor xs [103]",
    type = "Adjustor",
    position = {15.624972, 21.375027, 14.087694},
    rotation = {0.500000, -0.500000, 0.500000},
    hp = 1.904350,
    maxHp = 50
}
elements[104] = {
    name = "Adjustor xs [104]",
    type = "Adjustor",
    position = {16.625146, 21.375000, 14.087909},
    rotation = {0.500000, -0.500000, 0.500000},
    hp = 50.000000,
    maxHp = 50
}
elements[105] = {
    name = "Adjustor xs [105]",
    type = "Adjustor",
    position = {16.750146, 21.125000, 14.088101},
    rotation = {0.500000, -0.500000, 0.500000},
    hp = 50.000000,
    maxHp = 50
}
elements[106] = {
    name = "Adjustor s [106]",
    type = "Adjustor",
    position = {15.924547, 21.622806, 14.500062},
    rotation = {-0.000000, -0.000000, -0.707107},
    hp = 50.000000,
    maxHp = 50
}
elements[107] = {
    name = "Adjustor s [107]",
    type = "Adjustor",
    position = {16.321866, 21.621327, 14.500062},
    rotation = {0.000000, -0.000000, 0.707107},
    hp = 50.000000,
    maxHp = 50
}
elements[108] = {
    name = "Hovercraft seat controller [108]",
    type = "Hovercraft seat controller",
    position = {16.125000, 14.375000, 15.395173},
    rotation = {0.000000, 0.000000, 0.000000},
    hp = 187.000000,
    maxHp = 187
}
elements[111] = {
    name = "Receiver xs [111]",
    type = "Receiver",
    position = {16.500000, 13.375000, 14.957188},
    rotation = {0.000000, -0.000000, 0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[112] = {
    name = "Emitter xs [112]",
    type = "Emitter",
    position = {16.500000, 13.125000, 14.811784},
    rotation = {-0.000000, -0.000000, 0.000000},
    hp = 50.000000,
    maxHp = 50
}
elements[113] = {
    name = "Maneuver Atmospheric Engine m [113]",
    type = "Uncommon Maneuver Atmospheric Engine",
    position = {16.125000, 10.503138, 14.920400},
    rotation = {0.000000, -0.000000, -0.000000},
    hp = 1933.000000,
    maxHp = 1933
}
elements[114] = {
    name = "Atmospheric radar s [114]",
    type = "Atmospheric Radar",
    position = {16.125000, 19.273973, 14.591784},
    rotation = {0.000000, 0.000000, 1.000000},
    hp = 88.000000,
    maxHp = 88
}
elements[115] = {
    name = "Hover engine m [115]",
    type = "Hover engine",
    position = {16.125000, 20.245327, 13.845388},
    rotation = {0.000000, 0.707107, 0.707107},
    hp = 462.000000,
    maxHp = 462
}
return elements
