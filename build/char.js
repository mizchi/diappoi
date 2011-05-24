(function() {
  var Battler, Enemy, Player, Status;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  };
  Status = (function() {
    function Status(params, lv) {
      if (params == null) {
        params = {};
      }
      this.lv = lv != null ? lv : 1;
      this.MAX_HP = params.hp || 30;
      this.hp = this.MAX_HP;
      this.MAX_WT = params.wt || 10;
      this.wt = 0;
      this.MAX_SP = params.sp || 10;
      this.sp = this.MAX_SP;
      this.exp = 0;
      this.atk = params.atk || 10;
      this.def = params.def || 1.0;
      this.res = params.res || 1.0;
      this.regenerate = params.regenerate || 3;
    }
    return Status;
  })();
  Battler = (function() {
    __extends(Battler, Sprite);
    function Battler(x, y, scale) {
      this.x = x != null ? x : 0;
      this.y = y != null ? y : 0;
      this.scale = scale != null ? scale : 10;
      Battler.__super__.constructor.call(this, this.x, this.y, this.scale);
      this.status = new Status();
      this.state = {
        alive: true,
        active: false
      };
      this.atack_range = 10;
      this.sight_range = 50;
      this.targeting = null;
      this.dir = 0;
      this.id = ~~(Math.random() * 100);
      this.animation = [];
    }
    Battler.prototype.add_animation = function(actor, target, animation) {
      return this.animation[this.animation.length] = animation;
    };
    Battler.prototype.render_animation = function(g, cam) {
      var n, _ref, _results;
      _results = [];
      for (n = 0, _ref = this.animation.length; (0 <= _ref ? n < _ref : n > _ref); (0 <= _ref ? n += 1 : n -= 1)) {
        if (!this.animation[n].render(g, cam)) {
          this.animation.splice(n, 1);
          this.render_animation(g, cam);
          break;
        }
      }
      return _results;
    };
    Battler.prototype.update = function() {
      this.cnt += 1;
      this.regenerate();
      return this.check_state();
    };
    Battler.prototype.check_state = function() {
      if (this.state.poizon) {
        this.status.hp -= 1;
      }
      if (this.status.hp < 1) {
        this.status.hp = 0;
        this.state.alive = false;
      }
      if (this.status.hp > this.status.MAX_HP) {
        this.status.hp = this.status.MAX_HP;
        return this.state.alive = true;
      }
    };
    Battler.prototype.regenerate = function() {
      var r;
      if (this.targeting) {
        r = 2;
      } else {
        r = 1;
      }
      if (!(this.cnt % (24 / this.status.regenerate * r)) && this.state.alive) {
        if (this.status.hp < this.status.MAX_HP) {
          return this.status.hp += 1;
        }
      }
    };
    Battler.prototype.act = function(target) {
      var d;
      if (target == null) {
        target = this.targeting;
      }
      if (this.targeting) {
        d = this.get_distance(this.targeting);
        if (d < this.atack_range) {
          if (this.status.wt < this.status.MAX_WT) {
            return this.status.wt += 1;
          } else {
            this.atack();
            return this.status.wt = 0;
          }
        } else {
          if (this.status.wt < this.status.MAX_WT) {
            return this.status.wt += 1;
          }
        }
      } else {
        return this.status.wt = 0;
      }
    };
    Battler.prototype.move = function(x, y) {};
    Battler.prototype.invoke = function(target) {};
    Battler.prototype.atack = function() {
      this.targeting.status.hp -= ~~(this.status.atk * (this.targeting.status.def + Math.random() / 4));
      return this.targeting.check_state();
    };
    Battler.prototype.set_target = function(targets) {
      if (targets.length === 0) {
        return this.targeting = null;
      } else if (targets.length > 0) {
        if (!this.targeting || !this.targeting.alive) {
          return this.targeting = targets[0];
        } else {
          return this.targeting;
        }
      }
    };
    Battler.prototype.change_target = function(targets) {
      var i, _ref, _ref2, _results;
      if (targets == null) {
        targets = this.targeting;
      }
      if (targets.length > 0) {
        if (_ref = !this.targeting, __indexOf.call(targets, _ref) >= 0) {
          return this.targeting = targets[0];
        } else if (targets.length === 1) {
          return this.targeting = targets[0];
        } else if (targets.length > 1) {
          if (this.targeting) {
            _results = [];
            for (i = 0, _ref2 = targets.length; (0 <= _ref2 ? i < _ref2 : i > _ref2); (0 <= _ref2 ? i += 1 : i -= 1)) {
              _results.push(targets[i] === this.targeting ? targets.length === i + 1 ? this.targeting = targets[0] : this.targeting = targets[i + 1] : void 0);
            }
            return _results;
          } else {
            this.targeting = targets[0];
            return this.targeting;
          }
        }
      } else {
        this.targeting = null;
        return this.targeting;
      }
    };
    Battler.prototype.get_targets_in_range = function(targets, range) {
      var buff, d, t, _i, _len;
      if (range == null) {
        range = this.sight_range;
      }
      buff = [];
      for (_i = 0, _len = targets.length; _i < _len; _i++) {
        t = targets[_i];
        d = this.get_distance(t);
        if (d < range && t.state.alive) {
          buff[buff.length] = t;
        }
      }
      return buff;
    };
    Battler.prototype._render_gages = function(g, x, y, w, h, rest) {
      my.init_cv(g, "rgb(0, 250, 100)");
      my.render_rest_gage(g, x, y + 15, w, h, this.status.hp / this.status.MAX_HP);
      my.init_cv(g, "rgb(0, 100, e55)");
      return my.render_rest_gage(g, x, y + 25, w, h, this.status.wt / this.status.MAX_WT);
    };
    Battler.prototype.render_targeted = function(g, cam, color) {
      var alpha, beat, ms, pos;
      if (color == null) {
        color = "rgb(255,0,0)";
      }
      my.init_cv(g);
      pos = this.getpos_relative(cam);
      beat = 24;
      ms = ~~(new Date() / 100) % beat / beat;
      if (ms > 0.5) {
        ms = 1 - ms;
      }
      this.init_cv(g, color = color, alpha = 0.7);
      g.moveTo(pos.vx, pos.vy - 12 + ms * 10);
      g.lineTo(pos.vx - 6 - ms * 5, pos.vy - 20 + ms * 10);
      g.lineTo(pos.vx + 6 + ms * 5, pos.vy - 20 + ms * 10);
      g.lineTo(pos.vx, pos.vy - 12 + ms * 10);
      return g.fill();
    };
    return Battler;
  })();
  Player = (function() {
    __extends(Player, Battler);
    function Player(x, y) {
      var status;
      this.x = x;
      this.y = y;
      Player.__super__.constructor.call(this, this.x, this.y);
      status = {
        hp: 120,
        wt: 20,
        atk: 10,
        def: 0.8
      };
      this.status = new Status(status);
      this.binded_skill = {
        one: new Skill_Heal(),
        two: new Skill_Smash(),
        three: new Skill_Meteor()
      };
      this.cnt = 0;
      this.speed = 6;
      this.atack_range = 50;
    }
    Player.prototype.update = function(enemies, map, keys, mouse) {
      this.mouse = mouse;
      Player.__super__.update.call(this);
      if (this.state.alive) {
        if (keys.space) {
          this.change_target();
        }
        this.set_target(this.get_targets_in_range(enemies, this.sight_range));
        this.move(map, keys, mouse);
        return this.act(keys, enemies);
      }
    };
    Player.prototype.act = function(keys, enemies) {
      Player.__super__.act.call(this);
      return this.invoke(keys, enemies);
    };
    Player.prototype.invoke = function(keys, enemies) {
      var i, list, _i, _len, _results;
      list = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"];
      _results = [];
      for (_i = 0, _len = list.length; _i < _len; _i++) {
        i = list[_i];
        _results.push(this.binded_skill[i] ? keys[i] ? this.binded_skill[i]["do"](this, enemies) : this.binded_skill[i].charge() : void 0);
      }
      return _results;
    };
    Player.prototype.set_dir = function(x, y) {
      var rx, ry;
      rx = x - 320;
      ry = y - 240;
      if (rx >= 0) {
        return this.dir = Math.atan(ry / rx);
      } else {
        return this.dir = Math.PI - Math.atan(ry / -rx);
      }
    };
    Player.prototype.move = function(cmap, keys, mouse) {
      var move;
      this.dir = this.set_dir(mouse.x, mouse.y);
      if (keys.right + keys.left + keys.up + keys.down > 1) {
        move = ~~(this.speed * Math.sqrt(2) / 2);
      } else {
        move = this.speed;
      }
      if (keys.right) {
        if (cmap.collide(this.x + move, this.y)) {
          this.x = (~~(this.x / cmap.cell) + 1) * cmap.cell - 1;
        } else {
          this.x += move;
        }
      }
      if (keys.left) {
        if (cmap.collide(this.x - move, this.y)) {
          this.x = (~~(this.x / cmap.cell)) * cmap.cell + 1;
        } else {
          this.x -= move;
        }
      }
      if (keys.up) {
        if (cmap.collide(this.x, this.y - move)) {
          this.y = (~~(this.y / cmap.cell)) * cmap.cell + 1;
        } else {
          this.y -= move;
        }
      }
      if (keys.down) {
        if (cmap.collide(this.x, this.y + move)) {
          return this.y = (~~(this.y / cmap.cell + 1)) * cmap.cell - 1;
        } else {
          return this.y += move;
        }
      }
    };
    Player.prototype.render = function(g) {
      var beat, c, color, k, m, ms, roll, v, _ref, _results;
      beat = 20;
      my.init_cv(g, "rgb(0, 0, 162)");
      ms = ~~(new Date() / 100) % beat / beat;
      if (ms > 0.5) {
        ms = 1 - ms;
      }
      g.arc(320, 240, (1.3 - ms) * this.scale, 0, Math.PI * 2, true);
      g.stroke();
      roll = Math.PI * (this.cnt % 20) / 10;
      my.init_cv(g, "rgb(128, 100, 162)");
      g.arc(320, 240, this.scale * 0.5, roll, Math.PI + roll, true);
      g.stroke();
      my.init_cv(g, "rgb(255, 0, 0)");
      g.arc(320, 240, this.atack_range, 0, Math.PI * 2, true);
      g.stroke();
      this._render_gages(g, 320, 240, 40, 6, this.status.hp / this.status.MAX_HP);
      if (this.targeting) {
        this.targeting.render_targeted(g, this, color = "rgb(0,0,255)");
      }
      this.render_mouse(g);
      c = 0;
      _ref = this.binded_skill;
      _results = [];
      for (k in _ref) {
        v = _ref[k];
        this.init_cv(g);
        m = ~~(v.MAX_CT / 24);
        g.fillText(v.name, 10 + 50 * c, 450);
        g.fillText((m - ~~((v.MAX_CT - v.ct) / 24)) + "/" + m, 10 + 50 * c, 460);
        _results.push(c++);
      }
      return _results;
    };
    Player.prototype.render_mouse = function(g) {
      my.init_cv(g, "rgb(200, 200, 50)");
      g.arc(this.mouse.x, this.mouse.y, this.scale, 0, Math.PI * 2, true);
      return g.stroke();
    };
    return Player;
  })();
  Enemy = (function() {
    __extends(Enemy, Battler);
    function Enemy(x, y) {
      var status;
      this.x = x;
      this.y = y;
      Enemy.__super__.constructor.call(this, this.x, this.y, this.scale = 5);
      status = {
        hp: 50,
        wt: 22,
        atk: 10,
        def: 1.0
      };
      this.status = new Status(status);
      this.atack_range = 30;
      this.sight_range = 80;
      this.speed = 6;
      this.dir = 0;
      this.cnt = ~~(Math.random() * 24);
    }
    Enemy.prototype.update = function(players, cmap) {
      Enemy.__super__.update.call(this);
      if (this.state.alive) {
        this.set_target(this.get_targets_in_range(players, this.sight_range));
        this.move(cmap);
        return this.act();
      }
    };
    Enemy.prototype.move = function(cmap) {
      var distance, nx, ny;
      if (this.targeting) {
        distance = this.get_distance(this.targeting);
        if (distance > this.atack_range) {
          this.set_dir(this.targeting.x, this.targeting.y);
          nx = this.x + ~~(this.speed * Math.cos(this.dir));
          ny = this.y + ~~(this.speed * Math.sin(this.dir));
        } else {

        }
      } else {
        if (this.cnt % 24 === 0) {
          this.dir = Math.PI * 2 * Math.random();
        }
        if (this.cnt % 24 < 8) {
          nx = this.x + ~~(this.speed * Math.cos(this.dir));
          ny = this.y + ~~(this.speed * Math.sin(this.dir));
        }
      }
      if (!cmap.collide(nx, ny)) {
        if (nx != null) {
          this.x = nx;
        }
        if (ny != null) {
          return this.y = ny;
        }
      }
    };
    Enemy.prototype.render = function(g, cam) {
      var alpha, beat, color, ms, nx, ny, pos, t;
      my.init_cv(g);
      pos = this.getpos_relative(cam);
      if (this.state.alive) {
        g.fillStyle = 'rgb(255, 255, 255)';
        beat = 20;
        ms = ~~(new Date() / 100) % beat / beat;
        if (ms > 0.5) {
          ms = 1 - ms;
        }
        g.arc(pos.vx, pos.vy, (1.3 + ms) * this.scale, 0, Math.PI * 2, true);
        g.fill();
        if (this.targeting) {
          my.init_cv(g, color = "rgb(255,0,0)");
          g.arc(pos.vx, pos.vy, this.scale * 0.7, 0, Math.PI * 2, true);
          g.fill();
        }
        my.init_cv(g, color = "rgb(50,50,50)", alpha = 0.3);
        g.arc(pos.vx, pos.vy, this.sight_range, 0, Math.PI * 2, true);
        g.stroke();
        nx = ~~(30 * Math.cos(this.dir));
        ny = ~~(30 * Math.sin(this.dir));
        my.init_cv(g, color = "rgb(255,0,0)");
        g.moveTo(pos.vx, pos.vy);
        g.lineTo(pos.vx + nx, pos.vy + ny);
        g.stroke();
        this._render_gages(g, pos.vx, pos.vy, 30, 6, this.status.wt / this.status.MAX_WT);
        if (this.targeting) {
          this.targeting.render_targeted(g, cam);
          this.init_cv(g, color = "rgb(0,0,255)", alpha = 0.5);
          g.moveTo(pos.vx, pos.vy);
          t = this.targeting.getpos_relative(cam);
          g.lineTo(t.vx, t.vy);
          return g.stroke();
        }
      } else {
        g.fillStyle = 'rgb(55, 55, 55)';
        g.arc(pos.vx, pos.vy, this.scale, 0, Math.PI * 2, true);
        return g.fill();
      }
    };
    return Enemy;
  })();
}).call(this);
