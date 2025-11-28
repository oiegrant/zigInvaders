const std = @import("std");
const zig_pong = @import("zig_pong");
const raylib = @import("raylib");

const SHIELD_HEALTH: i32 = 10;

const Rectangle = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,

    pub fn intersects(self: Rectangle, other: Rectangle) bool {
        return self.x < other.x + other.width and
                self.x + self.width > other.x and
                self.y < other.y + other.height and
                self.y + self.height > other.y;
    }
};

const GameConfig = struct {
    screenWidth: i32,
    screenHeight: i32,

    playerWidth: f32,
    playerHeight: f32,

    bulletWidth: f32,
    bulletHeight: f32,
    shieldWidth: f32,
    shieldHeight: f32,

    invaderStartX: f32,
    invaderStartY: f32,
    invaderWidth: f32,
    invaderHeight: f32,
    invaderSpacingX: f32,
    invaderSpacingY: f32,
    invaderDirection: f32,
};

const Player = struct {
    positionX: f32,
    positionY: f32,
    height: f32,
    width: f32,
    speed: f32,

    pub fn init(positionX: f32, positionY: f32, height: f32, width: f32) @This() {
        return .{
            .positionX = positionX,
            .positionY = positionY,
            .height = height,
            .width = width,
            .speed = 5.0,
        };
    }

    pub fn update(self: *@This()) void {
        if(raylib.isKeyDown(raylib.KeyboardKey.right) or raylib.isKeyDown(raylib.KeyboardKey.d)) {
            self.positionX += self.speed;
        }
        if(raylib.isKeyDown(raylib.KeyboardKey.left) or raylib.isKeyDown(raylib.KeyboardKey.a)) {
            self.positionX -= self.speed;
        }
        if(self.positionX < 0){
            self.positionX=0;
        }
        if(self.positionX+self.width > @as(f32, @floatFromInt(raylib.getScreenWidth()))) {
            self.positionX = @as(f32, @floatFromInt(raylib.getScreenWidth())) - self.width;
        }
    }

    pub fn draw(self: *@This()) void {
        raylib.drawRectangle(@intFromFloat(self.positionX),
        @intFromFloat(self.positionY),
        @intFromFloat(self.width),
        @intFromFloat(self.height),
        raylib.Color.white);
    }

    pub fn getRect(self: @This()) Rectangle {
        return Rectangle{
            .x = self.positionX,
            .y = self.positionY,
            .width = self.width,
            .height = self.height,
        };
    }
};

const Bullet = struct {
    positionX: f32,
    positionY: f32,
    height: f32,
    width: f32,
    speed: f32,
    active: bool,

    pub fn init(positionX: f32, positionY: f32, height: f32, width: f32) @This() {
        return .{
            .positionX = positionX,
            .positionY = positionY,
            .height = height,
            .width = width,
            .active = false,
            .speed = 15.0,
        };
    }

    pub fn update(self: *@This()) void {
        if(!self.active){
            return;
        }
        self.positionY -= self.speed;

        if(self.positionY < 0){
            self.active = false;
        }
    }

    pub fn draw(self: *@This()) void {
        if(!self.active){
            return;
        }
        raylib.drawRectangle(@intFromFloat(self.positionX),
        @intFromFloat(self.positionY),
        @intFromFloat(self.width),
        @intFromFloat(self.height),
        raylib.Color.sky_blue);
    }

    pub fn getRect(self: @This()) Rectangle {
        return Rectangle{
            .x = self.positionX,
            .y = self.positionY,
            .width = self.width,
            .height = self.height,
        };
    }
};

const EnemyBullet = struct {
    positionX: f32,
    positionY: f32,
    height: f32,
    width: f32,
    speed: f32,
    active: bool,

    pub fn init(positionX: f32, positionY: f32, height: f32, width: f32) @This() {
        return .{
            .positionX = positionX,
            .positionY = positionY,
            .height = height,
            .width = width,
            .active = false,
            .speed = 5.0,
        };
    }

    pub fn update(self: *@This()) void {
        if(!self.active){
            return;
        }
        self.positionY += self.speed;

        if(self.positionY > @as(f32, @floatFromInt(raylib.getScreenHeight()))){
            self.active = false;
        }
    }

    pub fn draw(self: *@This()) void {
        if(!self.active){
            return;
        }
        raylib.drawRectangle(@intFromFloat(self.positionX),
        @intFromFloat(self.positionY),
        @intFromFloat(self.width),
        @intFromFloat(self.height),
        raylib.Color.yellow);
    }

    pub fn getRect(self: @This()) Rectangle {
        return Rectangle{
            .x = self.positionX,
            .y = self.positionY,
            .width = self.width,
            .height = self.height,
        };
    }
};

const Invader =  struct {
    positionX: f32,
    positionY: f32,
    height: f32,
    width: f32,
    speed: f32,
    alive: bool,

    pub fn init(positionX: f32, positionY: f32, height: f32, width: f32) @This() {
        return .{
            .positionX = positionX,
            .positionY = positionY,
            .height = height,
            .width = width,
            .alive = true,
            .speed = 7.0,
        };
    }

    pub fn draw(self: @This()) void {
        if(!self.alive){
            return;
        }
        raylib.drawRectangle(@intFromFloat(self.positionX),
        @intFromFloat(self.positionY),
        @intFromFloat(self.width),
        @intFromFloat(self.height),
        raylib.Color.red);
    }

    pub fn update(self: *@This(), dx: f32, dy: f32) void {
        self.positionX += dx;
        self.positionY += dy;
    }

    pub fn getRect(self: @This()) Rectangle {
        return Rectangle{
            .x = self.positionX,
            .y = self.positionY,
            .width = self.width,
            .height = self.height,
        };
    }
};

const Shield = struct {
    positionX: f32,
    positionY: f32,
    height: f32,
    width: f32,
    health: i32,

    pub fn init(positionX: f32, positionY: f32, height: f32, width: f32) @This() {
        return .{
            .positionX = positionX,
            .positionY = positionY,
            .height = height,
            .width = width,
            .health = SHIELD_HEALTH
        };
    }

    pub fn draw(self: @This()) void {
        if(self.health <= 0){
            return;
        }
        const alpha = @as(u8, @intCast(@min(255,self.health*25)));
        raylib.drawRectangle(@intFromFloat(self.positionX),
        @intFromFloat(self.positionY),
        @intFromFloat(self.width),
        @intFromFloat(self.height),
        raylib.Color.init(0, 240, 240, @as(u8,alpha)));
    }

    pub fn getRect(self: @This()) Rectangle {
        return Rectangle{
            .x = self.positionX,
            .y = self.positionY,
            .width = self.width,
            .height = self.height,
        };
    }

};

fn resetGame(
    player: *Player,
    bullets: []Bullet,
    enemyBullets: []EnemyBullet,
    shields: []Shield,
    invaders: anytype,
    invaderdirection: *f32,
    score: *i32,
    config: GameConfig,
    ) void {
    score.* = 0;
    player.* = Player.init(
        @as(f32, @floatFromInt(config.screenWidth)) / 2 - config.playerWidth/2,
        @as(f32, @floatFromInt(config.screenHeight)) - 60.0,
        config.playerHeight,
        config.playerWidth);

    for (bullets) |*bullet| {
        bullet.active = false;
    }
    for (enemyBullets) |*bullet| {
        bullet.active = false;
    }
    for(shields, 0..) |*shield, i| {
        shield.* = Shield.init(
            @as(f32, @floatFromInt(config.screenWidth)) * @as(f32, @floatFromInt(i)) / 3 + config.shieldWidth/2,
            @as(f32, @floatFromInt(config.screenHeight)) - 120.0,
            config.shieldHeight,
            config.shieldWidth);
    }

    for(invaders, 0..) |*row, i| {
        for(row, 0..) |*invader, j| {
            const x = config.invaderStartX + @as(f32, @floatFromInt(j)) * config.invaderSpacingX;
            const y = config.invaderStartY + @as(f32, @floatFromInt(i)) * config.invaderSpacingY;
            invader.* = Invader.init(x, y, config.invaderHeight, config.invaderWidth);
        }
    }
    invaderdirection.* = config.invaderDirection;


}

pub fn main() !void {
    const screenHeight = 600;
    const screenWidth = 800;
    const maxBullet = 20;
    const bulletHeight = 4.0;
    const bulletWidth = 10;
    const maxEnemyBullets = 20;
    const enemyShootDelay = 60.0;
    const enemyShootChance = 20.0;
    var enemyShootTimer: i32 = 0;
    const invaderRows = 5;
    const invaderCols = 10;
    const invaderWidth = 40.0;
    const invaderHeight = 30.0;
    const invaderStartX = 100.0;
    const invaderStartY = 50.0;
    const invaderSpacingX = 60.0;
    const invaderSpacingY = 50.0;
    const invaderMoveDelay = 20;
    const invaderDropDistance = -10;
    var invaderDirection: f32 = 1.0;
    var moveTimer: i32 = 0;
    const numShields = 3;
    const shieldHeight = 30;
    const shieldWidth = 120;
    var score: i32 = 0;
    var gameOver: bool = false;
    var gameWon: bool = false;
    const playerWidth = 50.0;
    const playerHeight = 30.0;

    const config = GameConfig {
        .screenWidth = screenWidth,
        .screenHeight = screenHeight,
        .playerWidth = playerWidth,
        .playerHeight = playerHeight,
        .bulletWidth = bulletWidth,
        .bulletHeight = bulletHeight,
        .shieldWidth = shieldWidth,
        .shieldHeight = shieldHeight,
        .invaderWidth = invaderWidth,
        .invaderHeight = invaderHeight,
        .invaderStartY = invaderStartY,
        .invaderStartX = invaderStartX,
        .invaderSpacingY = invaderSpacingY,
        .invaderSpacingX = invaderSpacingX,
        .invaderDirection = invaderDirection,
    };

    raylib.initWindow(screenWidth, screenHeight, "zig pong");
    defer raylib.closeWindow(); // defer runs this method at the end of current "{}" scope
    raylib.setTargetFPS(60);

    var player = Player.init(
        @as(f32, @floatFromInt(screenWidth)) / 2 - playerWidth/2,
        @as(f32, @floatFromInt(screenHeight)) - 60.0,
        playerHeight,
        playerWidth);

    var shields: [numShields]Shield = undefined;
    for(&shields, 0..) |*shield, i| {
        shield.* = Shield.init(
            @as(f32,  @floatFromInt(screenWidth)) * @as(f32, @floatFromInt(i)) / 3 + shieldWidth/2,
            @as(f32, @floatFromInt(screenHeight)) - 120.0,
            shieldHeight,
            shieldWidth);
    }

    var bullets: [maxBullet]Bullet = undefined;

    for(&bullets) |*bullet| {
        bullet.* = Bullet.init(0,0,bulletWidth,bulletHeight);
    }

    var invaderBullets: [maxEnemyBullets]EnemyBullet = undefined;

    for(&invaderBullets) |*bullet| {
        bullet.* = EnemyBullet.init(0,0,bulletWidth,bulletHeight);
    }

    var invaders: [invaderRows][invaderCols]Invader = undefined;
    for(&invaders, 0..) |*row, i| {
        for(row, 0..) |*invader, j| {
            const x = invaderStartX + @as(f32, @floatFromInt(j)) * invaderSpacingX;
            const y = invaderStartY + @as(f32, @floatFromInt(i)) * invaderSpacingY;
            invader.* = Invader.init(x, y, invaderHeight, invaderWidth);
        }
    }

    //GAME LOOP
    while(!raylib.windowShouldClose()){
        raylib.beginDrawing();
        defer raylib.endDrawing();
        raylib.clearBackground(.dark_brown);

        if(gameOver) {
            raylib.drawText("GAME OVER", 10, 50 , 40 , raylib.Color.red);
            raylib.drawText(raylib.textFormat("FINAL SCORE %d", .{score}), 10, 100, 30, .white);
            raylib.drawText(raylib.textFormat("Press ENTER to play again ESC to quit", .{score}), 10, 150, 30, .white);
            if(raylib.isKeyPressed(raylib.KeyboardKey.enter)) {
                gameOver = false;
                resetGame(&player, &bullets, &invaderBullets, &shields, &invaders, &invaderDirection, &score, config);
            }
            continue;
        }

        if(gameWon) {
            raylib.drawText("YOU WIN!!!", 10, 50 , 40 , raylib.Color.red);
            raylib.drawText(raylib.textFormat("FINAL SCORE %d", .{score}), 10, 100, 30, .white);
            raylib.drawText(raylib.textFormat("Press ENTER to play again ESC to quit", .{score}), 10, 150, 30, .white);
            if(raylib.isKeyPressed(raylib.KeyboardKey.enter)) {
                gameWon = false;
                resetGame(&player, &bullets, &invaderBullets, &shields, &invaders, &invaderDirection, &score, config);
            }
            continue;
        }

        //UPDATE
        player.update();

        //player fire bullets
        if(raylib.isKeyPressed(raylib.KeyboardKey.space)) {
            for(&bullets) |*bullet| {
                if(!bullet.active){
                    bullet.positionX = player.positionX + player.width/2 - bullet.width/2;
                    bullet.positionY = player.positionY - bullet.height;
                    bullet.active = true;
                    break;
                }
            }
        }

        for(&bullets) |*bullet| {
            bullet.update();
        }

        for(&invaderBullets) |*bullet| {
            bullet.update();
        }

        enemyShootTimer+=1;
        if(enemyShootTimer>enemyShootDelay){
            enemyShootTimer = 0;
            for(&invaders) |*row| {
                for(row) |*invader| {
                    if(invader.alive and raylib.getRandomValue(0,100) < enemyShootChance) {
                        for(&invaderBullets) |*bullet| {
                            if(!bullet.active) {
                                bullet.positionX = invader.positionX + invader.width/2 - bullet.width/2;
                                bullet.positionY = invader.positionY + invader.height;
                                bullet.active = true;
                                break;
                            }
                        }
                       break;
                    }
                }
            }
        }


        //Enemy Movement
        moveTimer += 1;
        if(moveTimer >= invaderMoveDelay){
            moveTimer = 0;

            var hit_edge = false;
            for(&invaders) |*row| {
                for(row) |*invader| {
                    if(invader.alive){
                        const nextX = invader.positionX + (invader.speed * invaderDirection);
                        if( nextX < 0 or (nextX + invaderWidth > @as(f32, @floatFromInt(screenWidth))) ) {
                            hit_edge = true;
                            break;
                        }
                    }
                }
                if(hit_edge) break;
            }

            if(hit_edge){
                invaderDirection *= -1;

                //drop in height
                for(&invaders) |*row| {
                    for(row) |*invader| {
                        invader.update(invader.speed * invaderDirection, -invaderDropDistance);
                    }
                }

            } else {
                for(&invaders) |*row| {
                    for(row) |*invader| {
                        invader.update(invader.speed * invaderDirection, 0);
                    }
                }
            }
        }

        //bullet collision detection
        for(&bullets) |*bullet| {
            if(bullet.active){
                const bulletRect: Rectangle = bullet.getRect();

                for(&shields) |*shield| {
                    if(shield.health>0 and bulletRect.intersects(shield.getRect())) {
                        shield.health -= 1;
                        bullet.active = false;
                        break;
                    }
                }

                for(&invaders) |*row| {
                    for(row) |*invader| {
                        if(invader.alive and bulletRect.intersects(invader.getRect())){
                            bullet.active = false;
                            invader.alive = false;
                            score += 100;
                            break;
                        }
                    }
                }
            }
        }

        for(&invaderBullets) |*bullet| {
            if(bullet.active){
                const bulletRect: Rectangle = bullet.getRect();
                if(player.getRect().intersects(bulletRect)){
                    bullet.active = false;
                    gameOver = true;
                }

                for(&shields) |*shield| {
                    if(shield.health>0 and bulletRect.intersects(shield.getRect())) {
                        shield.health -= 1;
                        bullet.active = false;
                        break;
                    }
                }
            }
        }

        gameWon = true;
        for(&invaders) |*row| {
            for(row) |*invader| {
                if(invader.alive){
                    gameWon = false;
                    break;
                }
            }
        }

        invaderplayercollcheck: for(&invaders) |*row| {
            for(row) |*invader| {
                if(invader.alive){
                    if(invader.getRect().intersects(player.getRect())){
                        gameOver = true;
                        break :invaderplayercollcheck;
                    }
                }
            }
        }



        //DRAW
        player.draw();

        for(&bullets) |*bullet| {
            bullet.draw();
        }
        for(&invaderBullets) |*bullet| {
            bullet.draw();
        }
        for(&invaders) |*row| {
            for(row) |*invader| {
                invader.draw();
            }
        }

        for (&shields) |*shield| {
            shield.draw();
        }

        raylib.drawText(raylib.textFormat("Score %d", .{score}), 10, 5, 20, .white);
    }
}