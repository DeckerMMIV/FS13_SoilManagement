
(-- This is a Work-In-Progress --)

Making cross-cutting code changes and then document them, so all people can understand what have changed and how to use the changes, is not an easy task.

I will here attempt to show how other scripters can create and add their own mod-plugins to work with SoilMod's plugin facility.

One way I will do it, is to create some 'sample plugin' scripts in this folder, to show what script-parts are required, and what to call in correct sequence. Hopefully this should give scripters some idea of how plugins for SoilMod works.





(-- TODO: Somehow explain the changes for the Utils. functions, that SoilMod overwrites --)

Utils.cutFruitArea()
    <default setup, including coordinates calculated>
    'fruitDesc' filled with values
    'dataStore' filled with "useful" values
    'setup phase'-plugins gets called
    'before phase'-plugins gets called
    <default cutting>
    'after phase'-plugins gets called
    <default return arguments>
end


Utils.updateCultivatorArea()
    <default setup, including coordinates calculated>
    'dataStore' filled with "useful" values
    'setup phase'-plugins gets called
    'before phase'-plugins gets called
    <default cultivating>
    'after phase'-plugins gets called
    <default return arguments>
end


Utils.updatePloughArea()
    <default setup, including coordinates calculated>
    'dataStore' filled with "useful" values
    'setup phase'-plugins gets called
    'before phase'-plugins gets called
    <default ploughing>
    'after phase'-plugins gets called
    <default return arguments>
end


Utils.updateSowingArea()
    <default setup, including coordinates calculated>
    'fruitDesc' filled with values
    'dataStore' filled with "useful" values
    'setup phase'-plugins gets called
    'before phase'-plugins gets called
    <default sowing>
    'after phase'-plugins gets called
    <default return arguments>
end


Utils.updateSprayArea()
    <coordinates calculated>
    'spray-filltype'-plugins gets called, for the filltype
    <default spraying>
    <default return arguments>
end
