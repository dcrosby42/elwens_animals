local Comp = require 'ecs/component'

Comp.define("bounds", {'offx',0,'offy',0,'w',0,'h',0})
Comp.define("pos", {'x',0,'y',0,'r',0})
Comp.define("vel", {'dx',0,'dy',0,'angularvelocity',0,'lineardamping',0,'angulardamping',0})

Comp.define("tag", {})

Comp.define("timer", {'t',0, 'reset',0, 'countDown',true, 'loop',false, 'alarm',false,'event',''})

Comp.define("controller", {'id','','leftx',0,'lefty',0,})

Comp.define("viewport", {'targetName','','x',0,'y',0,'sx',1,'sy',1,'w',1024,'h',768})
Comp.define("viewportTarget", {'offx',0,'offy',0})

Comp.define("follow", { 'targetName', '', 'offx', 0, 'offy', 0 })

Comp.define("pic",  {'id','','centerx','','centery','','offx',0,'offy',0,'sx',1,'sy',1,'r',0,'color',{1,1,1,1},'drawbounds',false,'draworder',0})
Comp.define("anim", {'id','','centerx','','centery','','offx',0,'offy',0,'sx',1,'sy',1,'r',0,'color',{1,1,1,1},'drawbounds',false})

Comp.define("state",  {'value',''})

Comp.define("background", {'color',{0,0,0,1}})
Comp.define("label", {'text','Label', 'color', {0,0,0},'font',nil, 'width', nil, 'align',nil, 'height',nil,'valign',nil})

Comp.define("circle", {'offx',0,'offy',0,'radius',0, 'fill',true, 'color',{0,0,0}})
Comp.define("rect", {'offx',0,'offy',0,'w',0, 'h',0, 'color',{0,0,0}, 'style','fill','draw',true})

Comp.define('physicsWorld', {'gx',0,'gy',0,'allowSleep',true})
Comp.define('body', {'kind','', 'group',0,'dynamic',true,'mass','','bullet',false,'debugDraw',false})
Comp.define("force", {'fx',0,'fy',0,'torque',0,'impx',0,'impy',0,'angimp',0})
Comp.define('joint', {'kind','', 'toEntity','','lowerlimit','','upperlimit','','motorspeed','','maxmotorforce','','docollide',false})
Comp.define("rectangleShape", {'x',0,'y',0,'w',0,'h',0,'angle',0})
Comp.define("polygonShape", {'vertices',{}})
Comp.define("circleShape", {'x',0,'y',0,'radius',0})
Comp.define("chainShape", {'vertices',{},'loop',false})

Comp.define("lineStyle", {'draw',true, 'color',{1,1,1}, 'linewidth',1,'linestyle','smooth','closepolygon',true})

Comp.define("debug", {'value',''})

Comp.define("manipulator", {'id','','mode','','x',0,'y',0,'dx',0,'dy',0})

Comp.define("sound", {'sound','','loop',false,'state','playing','volume',1,'pitch',1,'playtime',0,'duration',''})

Comp.define("button", {'kind','tap', 'touchid','','holdtime',1,'eventtype','','shape','circle','radius',40,'w',80,'h',80})

Comp.define("touch", {'touchid','','startx',0,'starty',0,'lastx',0,'lasty',0})

Comp.define("fishspawner", {})
Comp.define("fish", {'kind','black','state','idle','targetspeed',0})

Comp.define("health", {'hp',10,'maxhp',10})

Comp.define("map", {'slices',{}})
Comp.define("slice", {'number',0})
