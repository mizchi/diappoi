## ge.js ##
# generated by src/core.coffee
class Game
  constructor: (conf) ->
    canvas =  document.getElementById conf.CANVAS_NAME
    @g = canvas.getContext '2d'
    @config = conf
    canvas.width = conf.WINDOW_WIDTH;
    canvas.height = conf.WINDOW_HEIGHT;
    @keys =
        left : 0
        right : 0
        up : 0
        down : 0
        space : 0
        one : 0
        two : 0
        three : 0
        four : 0
        five : 0
        six : 0
        seven : 0
        eight : 0
        nine : 0
        zero : 0
    @mouse = x : 0, y : 0
    @scenes =
      # "Opening": new OpeningScene()
      "Field": new FieldScene()
    @curr_scene = @scenes["Field"]

  enter: ->
    next_scene = @curr_scene.enter(@keys,@mouse)
    @curr_scene = @scenes[next_scene]
    @draw(@curr_scene)

  start: (self) ->
    setInterval ->
      self.enter()
    , 1000 / @config.FPS

  getkey: (self,which,to) ->
    switch which
      when 68,39 then self.keys.right = to
      when 65,37 then self.keys.left = to
      when 87,38 then self.keys.up = to
      when 83,40 then self.keys.down = to
      when 32 then self.keys.space = to
      when 17 then self.keys.ctrl = to

      when 48 then self.keys.zero = to
      when 49 then self.keys.one = to
      when 50 then self.keys.two = to
      when 51 then self.keys.three = to
      when 52 then self.keys.four = to
      when 53 then self.keys.five = to
      when 54 then self.keys.sixe = to
      when 55 then self.keys.seven = to
      when 56 then self.keys.eight = to
      when 57 then self.keys.nine = to

  draw: (scene) ->
    @g.clearRect(0,0,@config.WINDOW_WIDTH ,@config.WINDOW_HEIGHT)
    @g.save()
    scene.render(@g)
    @g.restore()

my =
  distance: (x1,y1,x2,y2)->
    xd = Math.pow (x1-x2) ,2
    yd = Math.pow (y1-y2) ,2
    return Math.sqrt xd+yd

  init_cv: (g,color="rgb(255,255,255)",alpha=1)->
    g.beginPath()
    g.strokeStyle = color
    g.fillStyle = color
    g.globalAlpha = alpha

  gen_map:(x,y)->
    map = []
    for i in [0..20]
        map[i] = []
        for j in [0..15]
            if Math.random() > 0.5
                map[i][j] = 0
            else
                map[i][j] = 1
    return map

  draw_line: (g,x1,y1,x2,y2)->
    g.moveTo(x1,y1)
    g.lineTo(x2,y2)
    g.stroke()

  color: (r=255,g=255,b=255,name=null)->
    switch name
        when "red" then return @color(255,0,0)
        when "green" then return @color(0,255,0)
        when "blue" then return @color(0,0,255)
        when "white" then return @color(255,255,255)
        when "black" then return @color(0,0,0)
        when "grey" then return @color(128,128,128)
    return "rgb("+~~(r)+","+~~(g)+","+~~(b)+")"

  draw_cell: (g,x,y,cell,color="grey")->
    g.moveTo(x , y)
    g.lineTo(x+cell , y)
    g.lineTo(x+cell , y+cell)
    g.lineTo(x , y+cell)
    g.lineTo(x , y)
    g.fill()

  render_rest_gage:( g, x , y, w, h ,percent=1) ->
    # frame
    g.moveTo(x-w/2 , y-h/2)
    g.lineTo(x+w/2 , y-h/2)
    g.lineTo(x+w/2 , y+h/2)
    g.lineTo(x-w/2 , y+h/2)
    g.lineTo(x-w/2 , y-h/2)
    g.stroke()

    # rest
    g.beginPath()
    g.moveTo(x-w/2 +1, y-h/2+1)
    g.lineTo(x-w/2+w*percent, y-h/2+1)
    g.lineTo(x-w/2+w*percent, y+h/2-1)
    g.lineTo(x-w/2 +1, y+h/2-1)
    g.lineTo(x-w/2 +1, y-h/2+1)
    g.fill()

# generated by src/sprites.coffee
class Sprite
  constructor: (@x=0,@y=0,@scale=10) ->
  render: (g)->
    g.beginPath()
    g.arc(@x,@y, 15 - ms ,0,Math.PI*2,true)
    g.stroke()

  get_distance: (target)->
    xd = Math.pow (@x-target.x) ,2
    yd = Math.pow (@y-target.y) ,2
    return Math.sqrt xd+yd

  getpos_relative:(cam)->
    pos =
      vx : 320 + @x - cam.x
      vy : 240 + @y - cam.y
    return pos


  init_cv: (g,color="rgb(255,255,255)",alpha=1)->
    g.beginPath()
    g.strokeStyle = color
    g.fillStyle = color
    g.globalAlpha = alpha

  set_dir: (x,y)->
    rx = x - @x
    ry = y - @y
    if rx >= 0
      @dir = Math.atan( ry / rx  )
    else
      @dir = Math.PI - Math.atan( ry / - rx  )

class Animation extends Sprite
  constructor: (actor,target) ->
    super 0, 0
    @timer = 0

  render:(g,x,y)->
    @timer++


class Animation_Slash extends Animation
  constructor: () ->
    @timer = 0

  render:(g,x,y)->
    if  @timer < 5
      @init_cv(g,color="rgb(30,55,55)")
      tx = x-10+@timer*3
      ty = y-10+@timer*3
      g.moveTo( tx ,ty )
      g.lineTo( tx-8 ,ty-8 )
      g.lineTo( tx-4 ,ty-8 )
      g.lineTo( tx ,ty )
      g.fill()
      @timer++
      return @
    else
      return false


# generated by src/maps.coffee
class Map extends Sprite
  constructor: (@cell=32) ->
    super 0, 0, @cell
    # @_map = @gen_map()
    m = @load(maps.debug)

    # m = base_block
    # m = rjoin(m,m)
    # m = sjoin(m,m)

    @_map = m
    @rotate90()
    @set_wall()

  load : (text)->
    tmap = text.replaceAll(".","0").replaceAll(" ","1").split("\n")
    map = []

    max = 0
    for row in tmap
      if max < row.length
        max = row.length

    y = 0
    for row in tmap
      list = []
      for i in row+1
        list[list.length] = parseInt(i)

      while list.length < max
        list.push(1)
      map[y] = list
      y++

    return map

  compile:(data)->
    return ""

  rotate90:()->
    map = @_map
    res = []
    for i in [0...map[0].length]
      res[i] = ( j[i] for j in map)
    @_map = res


  set_wall:()->
    map = @_map
    x = map.length
    y = map[0].length
    map[0] = (1 for i in [0...map[0].length])
    map[map.length-1] = (1 for i in [0...map[0].length])
    for i in map
      i[0]=1
      i[i.length-1]=1

    return map

  gen_random_map:(x,y)->
    map = []
    for i in [0 ... x]
      map[i] = []
      for j in [0 ... y]
        if (i == 0 or i == (x-1) ) or (j == 0 or j == (y-1))
          map[i][j] = 1
        else if Math.random() < 0.2
          map[i][j] = 1
        else
          map[i][j] = 0
    return map

  get_point: (x,y)->
    return {x:~~((x+1/2) *  @cell ),y:~~((y+1/2) * @cell) }

  get_randpoint: ()->
    rx = ~~(Math.random()*@_map.length)
    ry = ~~(Math.random()*@_map[0].length)
    if @_map[rx][ry]
      return @get_randpoint()
    return @get_point(rx,ry )

  collide: (x,y)->
    x = ~~(x / @cell)
    y = ~~(y / @cell)
    return @_map[x][y]

  render: (g,cam)->
    pos = @getpos_relative(cam)
    for i in [0 ... @_map.length]
      for j in [0 ... @_map[i].length]
        if @_map[i][j]
          my.init_cv(g , color = "rgb(0,0,0)",alpha=0.5)
        else
          my.init_cv(g , color = "rgb(250,250,250)",alpha=0.5)
        g.fillRect(
          pos.vx + i * @cell,
          pos.vy + j * @cell,
          @cell , @cell)

maps =
  filed1 : """

                                             .........
                                      ................... .
                                 ...........            ......
                              ....                      ..........
                           .....              .....        ...... .......
                   ..........              .........        ............ .....
                   ............          ...... . ....        ............ . ..
               .....    ..    ...        ..  ..........       . ..................
       ..     ......          .........................       . .......   ...... ..
      .....    ...     ..        .......  ...............      ....        ........
    ...... ......    .....         ..................... ..   ....         ........
    .........   ......  ...............  ................... ....            ......
   ...........    ... ... .... .   ..   .. ........ ............             . .....
   ...........    ...... ...       ....................           ......
  ............   .......... .    .......... ...... .. .       ...........
   .. ........ .......   ....   ...... .   ............      .... .......
   . ..............       .... .. .       ..............   ...... ..... ..
    .............          .......       ......       ......... . ...... .
    ..     .... ..         ... .       ....         .........   ...........
   ...       .......   ........       .. .        .... ....  ... ..........
  .. .         ......  .........      .............. ..  .....  ...    .....
  .....         ......................................      ....        ....
   .....       ........    ... ................... ....     ...        ....
     ....   ........        ...........................  .....        .....
     ...........  ..        ........ .............. ... .. .         .....
         ......                 .........................           .. ..
                                  .....................          .......
                                      ...................        ......
                                          .............
"""
  debug : """
                ....
             ...........
           ..............
         .... ........... .
        .......     ........
   .........    ..     ......
   ........   ......    .......
   .........   .....    .......
    .................. ........
        .......................
        ....................
              .............
                 ......
                  ...

"""
base_block = [
  [ 1,1,0,1,1 ]
  [ 1,0,0,1,1 ]
  [ 0,0,0,0,0 ]
  [ 1,0,0,0,1 ]
  [ 1,1,0,1,1 ]
  ]

rjoin = (map1,map2)->
  map1
  return map1.concat(map2)

sjoin = (map1,map2)->
  if not map1[0].length == map2[0].length
    return false
  y = 0
  buf = []
  for i in [0...map1.length]
    buf[i] = map1[i].concat(map2[i])
    y++
  return buf

String.prototype.replaceAll = (org, dest) ->
  return @split(org).join(dest)

# generated by src/char.coffee
class Status
  constructor: (params = {}, @lv = 1) ->
    @MAX_HP = params.hp or 30
    @hp = @MAX_HP
    @MAX_WT = params.wt or 10
    @wt = 0
    @MAX_SP = params.sp or 10
    @sp = @MAX_SP

    @exp = 0

    @atk = params.atk or 10
    @def = params.def or 1.0
    @res = params.res or 1.0
    @regenerate = params.regenerate or 3

class Battler extends Sprite
  constructor: (@x=0,@y=0,@group=0) ->

    super @x, @y,@scale
    @status = new Status()
    @category = "battler"
    @state =
      alive : true
      active : false
    @scale =10
    @atack_range = 10
    @sight_range = 50
    @targeting = null
    @dir = 0
    @id = ~~(Math.random() * 100)

    @animation = []

  add_animation:(animation)->
    @animation[@animation.length] = animation

  render_animation:(g,x, y)->
    for n in [0...@animation.length]
      if not @animation[n].render(g,x,y)
        @animation.splice(n,1)
        @render_animation(g,x,y)
        break

  update:()->
    @cnt += 1
    @regenerate()
    @check_state()

  check_state:()->
    if @state.poizon
       @status.hp -= 1

    if @status.hp < 1
      @status.hp = 0
      @state.alive = false
      # @state.targeting = null

    if @status.hp > @status.MAX_HP
      @status.hp = @status.MAX_HP
      @state.alive = true

  regenerate: ()->
    if @targeting then r = 2 else r = 1

    if not (@cnt % (24/@status.regenerate*r)) and @state.alive
      if @status.hp < @status.MAX_HP
          @status.hp += 1

  act:(target=@targeting)->
    if @targeting
      d = @get_distance(@targeting)
      if d < @atack_range
        if @status.wt < @status.MAX_WT
          @status.wt += 1
        else
          @atack()
          @status.wt = 0
      else
        if @status.wt < @status.MAX_WT
          @status.wt += 1
    else
      @status.wt = 0

  move:(x,y)-> #abstract
  invoke: (target)->

  atack: ()->
    @targeting.status.hp -= ~~(@status.atk * ( @targeting.status.def + Math.random()/4 ))
    @targeting.add_animation(new Animation_Slash())
    @targeting.check_state()

  set_target:(targets)->
    if targets.length == 0
      @targeting = null
    # else if not @targeting and targets.length > 0
    else if targets.length > 0
      if not @targeting or not @targeting.alive
        @targeting = targets[0]
      else
        @targeting

  change_target:(targets=@targeting)->
    # TODO: implement hate control
    if targets.length > 0
      if not @targeting in targets # before target go out
        @targeting = targets[0]    #   focus anyone
      else if targets.length == 1  # one target in range
        @targeting = targets[0]    #   focus that target
      else if targets.length > 1   # over 2 target
        if @targeting              #   toggle target
          for i in [0...targets.length]
            if targets[i] is @targeting
              if targets.length == i+1
                @targeting = targets[0]
              else
                @targeting = targets[i+1]
        else
          @targeting = targets[0]
          return @targeting
    else                           # no target in range
      @targeting = null
      return @targeting

  get_targets_in_range:(targets, range= @sight_range)->

    enemies = []
    for t in targets
      if t.group != @group and t.category == "battler"
        enemies.push( t )

    buff = []
    for t in enemies
      d = @get_distance(t)
      if d < range and t.state.alive
        buff[buff.length] = t
    return buff

  get_leader:(targets, range= @sight_range)->
    for t in targets
      if t.state.leader and t.group == @group
        if (@get_distance(t) < @sight_range)
          return t
    return null


  _render_gages:(g,x,y,w,h,rest) ->
    # HP bar
    my.init_cv(g,"rgb(0, 250, 100)")
    my.render_rest_gage(g,x,y+15,w,h,@status.hp/@status.MAX_HP)

    # WT bar
    my.init_cv(g,"rgb(0, 100, e55)")
    my.render_rest_gage(g,x,y+25,w,h,@status.wt/@status.MAX_WT)

  render_targeted: (g,pos,color="rgb(255,0,0)")->
    my.init_cv(g)

    beat = 24
    ms = ~~(new Date()/100) % beat / beat
    ms = 1 - ms if ms > 0.5

    @init_cv(g,color=color,alpha=0.7)
    g.moveTo(pos.vx,pos.vy-12+ms*10)
    g.lineTo(pos.vx-6-ms*5,pos.vy-20+ms*10)
    g.lineTo(pos.vx+6+ms*5,pos.vy-20+ms*10)
    g.lineTo(pos.vx,pos.vy-12+ms*10)

    g.fill()

class Player extends Battler
  constructor: (@x,@y,@group=0) ->
    super(@x,@y,@group)
    status =
      hp : 120
      wt : 20
      atk : 10
      def: 0.8
    @status = new Status(status)

    @binded_skill =
      one: new Skill_Heal()
      two: new Skill_Smash()
      three: new Skill_Meteor()
    @state.leader =true
    @cnt = 0
    @speed = 6
    @atack_range = 50
    @mosue =
      x: 0
      y: 0

  update: (enemies, map, keys,@mouse)->
    super()
    if @state.alive
      if keys.space
        @change_target()
      @set_target(@get_targets_in_range(enemies,@sight_range))
      @move(map, keys,mouse)
      @act(keys,enemies)

  act: (keys,enemies)->
     super()
     @invoke(keys,enemies)

  invoke: (keys,enemies)->
    list = ["zero","one","two","three","four","five","six","seven","eight","nine"]
    for i in list
      if @binded_skill[i]
        if keys[i]
          @binded_skill[i].do(@,enemies,@mouse)
        else
          @binded_skill[i].charge()

  set_dir: (x,y)->
    rx = x - 320
    ry = y - 240
    if rx >= 0
      @dir = Math.atan( ry / rx  )
    else
      @dir = Math.PI - Math.atan( ry / - rx  )

  move: (cmap , keys, mouse)->
    @dir = @set_dir(mouse.x , mouse.y)
    if keys.right + keys.left + keys.up + keys.down > 1
      move = ~~(@speed * Math.sqrt(2)/2)
    else
      move = @speed

    if keys.right
      if cmap.collide( @x+move , @y )
        @x = (~~(@x/cmap.cell)+1)*cmap.cell-1
      else
        @x += move

    if keys.left
      if cmap.collide( @x-move , @y )
        @x = (~~(@x/cmap.cell))*cmap.cell+1
      else
        @x -= move

    if keys.up
      if cmap.collide( @x , @y-move )
        @y = (~~(@y/cmap.cell))*cmap.cell+1
      else
        @y -= move

    if keys.down
      if cmap.collide( @x , @y+move )
        @y = (~~(@y/cmap.cell+1))*cmap.cell-1
      else
        @y += move


  render: (g,cam)->
    pos = @getpos_relative(cam)

    beat = 20
    my.init_cv(g,"rgb(0, 0, 162)")
    ms = ~~(new Date()/100) % beat / beat
    ms = 1 - ms if ms > 0.5
    g.arc(pos.vx,pos.vy, ( 1.3 - ms ) * @scale ,0,Math.PI*2,true)
    g.stroke()

    roll = Math.PI * (@cnt % 20) / 10

    my.init_cv(g,"rgb(128, 100, 162)")
    g.arc(320,240, @scale * 0.5,  roll ,Math.PI+roll,true)
    g.stroke()

    my.init_cv(g,"rgb(255, 0, 0)")
    g.arc(pos.vx,pos.vy, @atack_range ,  0 , Math.PI*2,true)
    g.stroke()
    @_render_gages(g,pos.vx,pos.vy,40,6,@status.hp/@status.MAX_HP)
    @targeting.render_targeted(g, pos ,color="rgb(0,0,255)") if @targeting
    @render_mouse(g)

    @render_animation(g, pos.vx , pos.vy )
    c = 0
    for k,v of @binded_skill
      @init_cv(g)
      m = ~~(v.MAX_CT/24)
      g.fillText(v.name ,10+50*c,450 )
      g.fillText((m-~~((v.MAX_CT-v.ct)/24))+"/"+m ,10+50*c,460 )
      c++;

  render_mouse: (g)->
    my.init_cv(g,"rgb(200, 200, 50)")
    g.arc(@mouse.x,@mouse.y,  @scale ,0,Math.PI*2,true)
    g.stroke()

class Enemy extends Battler
  constructor: (@x,@y,@group=1) ->
    super(@x,@y,@group)
    @scale = 5
    status =
      hp : 50
      wt : 22
      atk : 10
      def: 1.0
    @status = new Status(status)
    @atack_range = 30
    @sight_range = 80

    @speed = 6
    @dir = 0
    @cnt = ~~(Math.random() * 24)

  update: (objs, cmap)->
    super()
    if @state.alive
      @set_target(@get_targets_in_range(objs,@sight_range))
      @move(cmap,objs)
      @act()

  move: (cmap,objs)->
    # if target exist , trace
    if @targeting
      distance = @get_distance(@targeting)
      if distance > @atack_range
        @set_dir(@targeting.x,@targeting.y)
        nx = @x + ~~(@speed * Math.cos(@dir))
        ny = @y + ~~(@speed * Math.sin(@dir))
      else
        # stay here

    else # if not target isnt exist , move freely
      leader =  @get_leader(objs)
      if leader
        distance = @get_distance(leader)
        if distance > 30
          @set_dir(leader.x,leader.y)
          nx = @x + ~~(@speed * Math.cos(@dir))
          ny = @y + ~~(@speed * Math.sin(@dir))
        else
          if @cnt % 24 ==  0
            @dir = Math.PI * 2 * Math.random()
          if @cnt % 24 < 3
            nx = @x + ~~(@speed * Math.cos(@dir))
            ny = @y + ~~(@speed * Math.sin(@dir))

      else
        if @cnt % 24 ==  0
          @dir = Math.PI * 2 * Math.random()
        if @cnt % 24 < 8
          nx = @x + ~~(@speed * Math.cos(@dir))
          ny = @y + ~~(@speed * Math.sin(@dir))

    if not cmap.collide( nx,ny )
      @x = nx if nx?
      @y = ny if ny?


  render: (g,cam)->
    my.init_cv(g)
    pos = @getpos_relative(cam)
    if @state.alive

      color = ""
      if @group == 0
        color = "rgb(255,255,255)"
      else if @group == 1
        color = "rgb(55,55,55)"
      @init_cv(g,color=color)

      beat = 20
      ms = ~~(new Date()/100) % beat / beat
      ms = 1 - ms if ms > 0.5
      g.arc( pos.vx, pos.vy, ( 1.3 + ms ) * @scale ,0,Math.PI*2,true)
      g.fill()



      # active circle
      if @targeting
          my.init_cv(g , color = "rgb(255,0,0)")
          g.arc(pos.vx, pos.vy , @scale*0.7 ,0,Math.PI*2,true)
          g.fill()

      # sight circle
      my.init_cv(g , color = "rgb(50,50,50)",alpha=0.3)
      g.arc( pos.vx, pos.vy, @sight_range ,0,Math.PI*2,true)
      g.stroke()

      nx = ~~(30 * Math.cos(@dir))
      ny = ~~(30 * Math.sin(@dir))
      my.init_cv(g,color="rgb(255,0,0)")
      g.moveTo( pos.vx , pos.vy )
      g.lineTo(pos.vx+nx , pos.vy+ny)
      g.stroke()

      @_render_gages(g , pos.vx , pos.vy ,30,6,@status.wt/@status.MAX_WT)
      if @targeting
        @targeting.render_targeted(g,pos)
        @init_cv(g,color="rgb(0,0,255)",alpha=0.5)
        g.moveTo(pos.vx,pos.vy)
        t = @targeting.getpos_relative(cam)
        g.lineTo(t.vx,t.vy)
        g.stroke()
    else
        g.fillStyle = 'rgb(55, 55, 55)'
        g.arc(pos.vx,pos.vy, @scale ,0,Math.PI*2,true)
        g.fill()

    @render_animation(g, pos.vx , pos.vy )
# generated by src/skills.coffee
class Skill
  constructor: (ct=1, @lv=1) ->
    @MAX_CT = ct * 24
    @ct = @MAX_CT
  do:(actor)->
  charge:(actor)->
    @ct += 1 if @ct < @MAX_CT

class Skill_Heal extends Skill
  constructor: (@lv=1) ->
    super(15 , @lv)
    @name = "Heal"

  do:(actor)->
    target = actor
    if @ct >= @MAX_CT
      target.status.hp += 30
      target.check_state()
      @ct = 0
      console.log "do healing"
    else
      # console.log "wait "+((@MAX_CT-@ct)/24)

class Skill_Smash extends Skill
  constructor: (@lv=1) ->
    super(8 , @lv)
    @name = "Smash"

  do:(actor)->
    target = actor.targeting
    if target
      if @ct >= @MAX_CT
        target.status.hp -= 30
        target.check_state()
        @ct = 0
        console.log "Smash!"

class Skill_Meteor extends Skill
  constructor: (@lv=1) ->
    super(20 , @lv)
    @name = "Meteor"
    @range = 120

  do:(actor,targets)->
    if @ct >= @MAX_CT
      targets_on_focus = actor.get_targets_in_range(targets=targets , @range)
      if targets_on_focus.length
        console.log targets_on_focus.length
        for t in targets_on_focus
          t.status.hp -= 20
          t.check_state()
        @ct = 0
        console.log "Meteor!"


class Skill_ThrowBomb extends Skill
  constructor: (@lv=1) ->
    super(ct=10 , @lv)
    @name = "Throw Bomb"
    @range = 120
    @effect_range = 30

  do:(actor,targets,mouse)->
    if @ct >= @MAX_CT
      targets_on_focus = actor.get_targets_in_range(targets=targets , @range)
      if targets_on_focus.length
        console.log targets_on_focus.length
        for t in targets_on_focus
          t.status.hp -= 20
          t.check_state()
        @ct = 0
        console.log "Meteor!"
# generated by src/scenes.coffee
class Scene
  constructor: (@name) ->

  enter: (keys,mouse) ->
    return @name

  render: (g)->
    @player.render(g)
    g.fillText(
        @name,
        300,200)


class OpeningScene extends Scene
  constructor: () ->
    super("Opening")
    @player  =  new Player(320,240)

  enter: (keys,mouse) ->
    if keys.right

      return "Filed"
    return @name

  render: (g)->
    @player.render(g)
    g.fillText(
        "Opening",
        300,200)

  render:()->


class FieldScene extends Scene
  constructor: () ->
    super("Field")
    @map = new Map(32)

    start_point = @map.get_randpoint()
    @player  =  new Player(start_point.x ,start_point.y, 0)

    @objs = [@player]
    @max_object_count = 11
    @fcnt = 0

  enter: (keys,mouse) ->
    obj.update(@objs, @map,keys,mouse) for obj in @objs

    if @objs.length < @max_object_count and @fcnt % 24*3 == 0
      group = 0
      if Math.random() > 0.15
        group = 1
      else
        group = 0

      rpo = @map.get_randpoint()
      @objs.push( new Enemy(rpo.x, rpo.y, group) )
    else  # check dead
      for i in [0 ... @objs.length]
        if not @objs[i].state.alive
          @objs.splice(i,1)
          break
    @fcnt++
    return @name

  render: (g)->
    cam = @player
    # cam = @objs[@objs.length-1]

    @map.render(g, cam)
    obj.render(g,cam) for obj in @objs

    my.init_cv(g)
    g.fillText(
        "HP "+@player.status.hp+"/"+@player.status.MAX_HP,
        15,15)

    mouse_x =@player.x+@player.mouse.x-320
    mouse_y =@player.y+@player.mouse.y-240

    g.fillText(
        "p: "+(@player.x+@player.mouse.x-320)+"."+(@player.y+@player.mouse.y-240)
        15,25)

    if @player.targeting
      g.fillText(
          "p: "+@player.targeting.status.hp+"."+@player.targeting.status.MAX_HP
          15,35)

    # e = @enemies[0]
    # g.fillText(
    #     "Enemy Pos :"+e.x+"/"+e.y+":"+~~(e.dir/Math.PI*180)
    #     15,35)



vows = require 'vows'
assert = require 'assert'

keys =
   left : 0
   right : 0
   up : 0
   down : 0
mouse =
  x : 320
  y : 240

vows.describe('Game Test').addBatch
  'combat test':
    topic: "atack"
    'test': ()->
        map = new Map(32)
        # console.log map._map
    # topic: "select two targets"
    # 'select two': ()->
    #   p = new Player(320,240)
    #   enemies = ( new Enemy( ~~(Math.random()*640),~~(Math.random()*480)) for i in [1..30])
    #   for i in [0..100]
    #     targets_inrange =  p.get_targets_in_range(enemies)
    #     e.update([p]) for e in enemies
    #     p.set_target(targets_inrange)
    #     # p.change_target(targets_inrange)
    #     if p.targeting
    #       # console.log(p.targeting.id+ ":" +p.targeting.status.hp)
    #       p.atack()
    #     else
    #       # console.log "no"

    # topic: "select update method"
    # 'update': ()->
    #   p = new Player(320,240)
    #   enemies = ( new Enemy( ~~(Math.random()*640),~~(Math.random()*480)) for i in [1..100])
    #   for i in [1..10]
    #     p.update(enemies,keys,mouse)
    #     e.update([p]) for e in enemies
    #   console.log p.status
    #   console.log enemies[0].targeting

    # topic: "battle collide"
    # 'many vs many': ()->
    #   players = [new Player(320,240) , new Player(320,240) ]
    #   enemies = (new Enemy 320,240  for i in [1..3])

    #   for i in [1..100]
    #     p.update(enemies, keys,mouse) for p in players
    #     e.update(players) for e in enemies
    #   console.log p.status
    #   console.log enemies[0].status


    #   players = new Player(320,240)
    #   for i in [1..100]
    #     p.move(map)
    #     p.update(enemies, keys,mouse) for p in players
    #     e.update(players) for e in enemies
    #   console.log p.status
    #   console.log enemies[0].status
    # topic: "scene"
    # 'test2': ()->
    #   player = new Player(320,240)
    #   enemy = new Enemy ~~(Math.random()*640) ,~~(Math.random()*480)

    #   p.update(enemies, keys,mouse)
    #   p.move(map)
    #   p.act(map)
    #   for e in enemies
    #     e.update(players)
    #     e.move(map)
.export module
