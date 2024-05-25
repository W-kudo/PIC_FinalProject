import processing.serial.*;
Serial myPort;
int Data;
int byteX;
int byteY;
int second = 0;
int generateFrec;//粒の出現頻度を設定する
int R;
int G;
int B;
int rg = 30;//当たり判定の厳しさを設定
int TIME;
int time;
int LEVEL;
float HP = 120;//HPの設定
float HP_Max = 120;
float px = 500, py = 300, pr = 20;//プレイヤー初期位置の設定
String scene = "start";//まずはスタート画面を表示する
float speed1;
float speed2;

String MODE;

PImage img;//画像の変数

// 粒を表現する各クラスを定義
// 落ちてくる粒
class ParticleFall {
  float x;
  float y;
  float vx;
  float vy;
  float emerge;
}

//上がってくる粒
class ParticleRise {
  float X;
  float Y;
  float VX;
  float VY;
  float emerge;
}

// 右からくる粒
class ParticleRight {
  float x;
  float y;
  float vx;
  float vy;
  float emerge;
}

// 左からくる粒
class ParticleLeft {
  float X;
  float Y;
  float VX;
  float VY;
  float emerge;
}

// ParticleFall の可変長配列
ArrayList<ParticleFall> ps;

// ParticleRise の可変長配列
ArrayList<ParticleRise> Ps;

// ParticleRight の可変長配列
ArrayList<ParticleRight> qs;

// ParticleLeft の可変長配列
ArrayList<ParticleLeft> Qs;

void setup() {
  size(1000, 600);
  myPort = new Serial(this, "COM9", 9600);
  // 配列を初期化
  ps = new ArrayList<ParticleFall>();
  Ps = new ArrayList<ParticleRise>();
  qs = new ArrayList<ParticleRight>();
  Qs = new ArrayList<ParticleLeft>();
  textAlign(CENTER);
}

//粒径
int D;
//人混みキャラ目の径
int E;

void draw() {
  if (scene == "start") {
    start_scene();
  } else if (scene == "select") {
    select_scene();
  } else if (scene == "main") {
    main_scene();
  } else if (scene == "clear1") {
    clear_scene1();
  } else if (scene == "clear2") {
    clear_scene2();
  } else if (scene == "perfect") {
    perfect_scene();
  } else if (scene == "gameover") {
    gameover_scene();
  }
}

//以下、関数の設定
void PlayerMove() {
  R = 0;
  G = 255;
  B = 0;

  //輪郭
  stroke(0);
  fill(R, G, B);
  triangle(px-10, py+5, px-40, py-15, px-10, py-15);
  triangle(px+10, py+5, px+40, py-15, px+10, py-15);
  ellipse(px, py, pr*2, pr*2);
  //顔パーツ
  fill(0);
  ellipse(px+10, py, pr/2, pr/4);
  ellipse(px-10, py, pr/2, pr/4);
  ellipse(px, py+10, pr/4, pr/8);
  noFill();
  arc(px, py+1, 30, 30, PI/6, 5*PI/6);

  float byteX = map(rcv[1], 140, 100, -3, 3);
  float byteY = map(rcv[2], 140, 100, -3, 3);
  px += byteX;
  py += byteY;

  if (px < pr)px = pr;
  if (px > width-pr)px = width-pr;
  if (py < pr)py = pr;
  if (py > height-pr)py = height-pr;
}

void PlayerHit() {
  R = 255;
  G = 0;
  B = 0;

  //輪郭
  stroke(0);
  fill(R, G, B);
  triangle(px-10, py+5, px-40, py-15, px-10, py-15);
  triangle(px+10, py+5, px+40, py-15, px+10, py-15);
  ellipse(px, py, pr*2, pr*2);
  //顔パーツ
  fill(0);
  ellipse(px+10, py, pr/2, pr/4);
  ellipse(px-10, py, pr/2, pr/4);
  ellipse(px, py+10, pr/4, pr/8);
  noFill();
  arc(px, py+1, 30, 30, PI/6, 5*PI/6);

  float byteX = map(rcv[1], 140, 100, -3/30, 3/30);
  float byteY = map(rcv[2], 140, 100, -3/30, 3/30);
  px += byteX;
  py += byteY;

  if (px < pr)px = pr;
  if (px > width-pr)px = width-pr;
  if (py < pr)py = pr;
  if (py > height-pr)py = height-pr;
  HP --;//敵に当たったらHPが減っていく
}

void DrawBackground() {
  //背景設定
  background(155, 255, 155);
  noStroke();
  fill(150);
  rect(0, 135, width, 330);
  rect(335, 0, 330, height);
  for (int i = 0; i < 6; i++) {
    fill(255);
    rect(235, 135+60*i, 100, 30);
  }
  for (int i = 0; i < 6; i++) {
    fill(255);
    rect(665, 135+60*i, 100, 30);
  }
  for (int i = 0; i < 6; i++) {
    fill(255);
    rect(335+60*i, 35, 30, 100);
  }
  for (int i = 0; i < 6; i++) {
    fill(255);
    rect(335+60*i, 465, 30, 100);
  }
}

//体力ゲージ
void HP() {
  stroke(0);
  strokeWeight(3);
  fill(255, 0, 0);
  rect(775, 45, 210, 40);
  fill(0, 137, 196);
  rect(775, 45, 210*(HP/HP_Max), 40);
}

//残り時間、LEVELを表現
void Status() {
  fill(0);
  textSize(30);
  text("LEVEL:", 65, 50);
  if (LEVEL == 2){
    MODE = "easy";
    textSize(50);
    fill(24,150,223);
    text(MODE, 220, 50);
  }else if(LEVEL == 3){
    MODE = "normal";
    textSize(50);
    text(MODE, 220, 50);
  }else if(LEVEL == 4){
    MODE = "hard";
    fill(255,0,0);
    textSize(50);
    text(MODE, 220, 50);
  }
  fill(0);
  text("Time:", 100, 130);
  time = 60 - (TIME / 60);
  fill(253, 8, 146);
  textSize(80);
  text(time, 250, 130);
  PFont font = createFont("Meiryo", 50);
  textFont(font);
  textSize(35);
  text("免疫", 800, 40);
}

void start_scene() {
  PFont font = createFont("Meiryo", 50);
  textFont(font);
  background(255);
  noStroke();
  fill(204);
  ellipse(132, 112, 200, 200);
  ellipse(832, 232, 200, 200);
  fill(154);
  ellipse(252, 72, 100, 100);
  ellipse(732, 282, 100, 100);
  fill(51, 51, 255);
  textSize(40);
  text("極めろ！", width/4, height/5);
  fill(51, 51, 255);
  textSize(70);
  text("ソーシャルディスタンス", width/2, height/3);
  fill(255, 153, 51);
  textSize(68);
  text("ソーシャルディスタンス", width/2, height/3);
  fill(0);
  textSize(30);
  text("Get ready, and Press f key.", width/2, height/2+90);
}

void select_scene() {
  background(122);
  fill(255);
  textSize(50);
  text("Slide DIP switch,and Press s to start!", width/2, height/2.5);
  textSize(40);
  text("easy: 2", width/2, height/2+60);
  textSize(40);
  text("normal: 3", width/2, height/2+120);
  textSize(40);
  text("hard: 4", width/2, height/2+180);
  PFont font = createFont("Meiryo", 50);
  textFont(font);
  fill(255);
  textSize(20);
  text("人混みを避けて、免疫を守り切ろう!", width/2, height/6);
  text("１分間耐え抜けばクリアです。", width/2, height/4);
}

void main_scene() {
  DrawBackground();
  Status();
  HP();
  second ++;
  TIME ++;
  
  //プレイヤーの動き設定
  PlayerMove();

  //人混みの設定
  ParticleFall p = new ParticleFall();
  ParticleRise P = new ParticleRise();
  ParticleRight q = new ParticleRight();
  ParticleLeft Q = new ParticleLeft();

  p.emerge = 1;
  q.emerge = 1;
  P.emerge = 1;
  Q.emerge = 1;

  //落ちてくる粒の出現位置を決める(1000,600)
  p.x = random(300, 700);
  p.y = -50;
  p.vx = 0;
  p.vy = 0;

  //上がってくる粒の出現位置を決める(1000,600)
  P.X = random(300, 700);
  P.Y = 650;
  P.VX = 0;
  P.VY = 0;

  //右からくる粒の出現位置を決める(1000,600)
  q.x = 1050;
  q.y = random(100, 500);
  q.vx = 0;
  q.vy = 0;

  //左からくる粒の出現位置を決める(1000,600)
  Q.X = -50;
  Q.Y = random(100, 500);
  Q.VX = 0;
  Q.VY = 0;

  //60÷generateFrec [秒]毎に粒が出現
  if (second % generateFrec == 0) {
    ps.add(p);
    Ps.add(P);
    qs.add(q);
    Qs.add(Q);
  }

  //粒の描画
  for (int i = 0; i < ps.size(); i++) {

    // i 番目の粒を取得
    ParticleFall pi = ps.get(i);
    ParticleRise Pi = Ps.get(i);
    ParticleRight qi = qs.get(i);
    ParticleLeft Qi = Qs.get(i);

    //i番目を動かす

    fill(255);
    pi.x += pi.vx;
    pi.y += pi.vy;
    pi.vx += random(-speed1, +speed1);
    pi.vy += +speed2;
    ellipse(pi.x, pi.y, D, D);
    strokeWeight(3);
    ellipse(pi.x+5, pi.y, E, E);
    ellipse(pi.x-5, pi.y, E, E);

    Pi.X += Pi.VX;
    Pi.Y += Pi.VY;
    Pi.VX += random(-speed1, +speed1);
    Pi.VY += -speed2;
    ellipse(Pi.X, Pi.Y, D, D);
    strokeWeight(3);
    ellipse(Pi.X+5, Pi.Y, E, E);
    ellipse(Pi.X-5, Pi.Y, E, E);

    qi.x += qi.vx;
    qi.y += qi.vy;
    qi.vx += -speed2;
    qi.vy += random(-speed1, +speed1);
    ellipse(qi.x, qi.y, D, D);
    strokeWeight(3);
    ellipse(qi.x+5, qi.y, E, E);
    ellipse(qi.x-5, qi.y, E, E);

    Qi.X += Qi.VX;
    Qi.Y += Qi.VY;
    Qi.VX += +speed2;
    Qi.VY += random(-speed1, +speed1);
    ellipse(Qi.X, Qi.Y, D, D);
    strokeWeight(3);
    ellipse(Qi.X+5, Qi.Y, E, E);
    ellipse(Qi.X-5, Qi.Y, E, E);

    pi.emerge -= 0.0010;
    qi.emerge -= 0.0010;
    Pi.emerge -= 0.0010;
    Qi.emerge -= 0.0010;

    if (pi.x-rg <= px && px <= pi.x+rg && pi.y-rg <= py && py <= pi.y+rg) {
      PlayerHit();
    } else if (Pi.X-rg <= px && px <= Pi.X+rg && Pi.Y-rg <= py && py <= Pi.Y+rg) {
      PlayerHit();
    } else if (qi.x-rg <= px && px <= qi.x+rg && qi.y-rg <= py && py <= qi.y+rg) {
      PlayerHit();
    } else if (Qi.X-rg <= px && px <= Qi.X+rg && Qi.Y-rg <= py && py <= Qi.Y+rg) {
      PlayerHit();
    }
  }

  //一定時間経過後、粒を削除
  for (int i = ps.size() - 1; i >= 0; i--) {
    ParticleFall pi = ps.get(i);
    if (pi.emerge <= 0) {
      ps.remove(i);
    }
  }

  for (int i = Ps.size() - 1; i >= 0; i--) {
    ParticleRise Pi = Ps.get(i);
    if (Pi.emerge <= 0) {
      Ps.remove(i);
    }
  }

  for (int i = qs.size() - 1; i >= 0; i--) {
    ParticleRight qi = qs.get(i);
    if (qi.emerge <= 0) {
      qs.remove(i);
    }
  }

  for (int i = Qs.size() - 1; i >= 0; i--) {
    ParticleLeft Qi = Qs.get(i);
    if (Qi.emerge <= 0) {
      Qs.remove(i);
    }
  }
  if (time == 0 && 80 <= HP && HP < 120) {
    scene = "clear1";
  } else if (time == 0 && 0 < HP && HP < 80) {
    scene = "clear2";
  } else if (time == 0 && HP == 120) {
    scene = "perfect";
  } else if (HP == 0) {
    scene = "gameover";
  }
}

void clear_scene1() {//(1000, 600)
  background(155, 255, 155);
  img = loadImage("clear.png");
  image(img, 70, 150, width/4, height/2);
  image(img, 680, 150, width/4, height/2);
  fill(0);
  textSize(80);
  text("Great!", width/2, height/5);
  textSize(50);
  text("Score: ", width/2, height/2-80);
  textSize(80);
  text(HP + "/120", width/2, height/2);
  textSize(50);
  text("Thank you for playing...", width/2, height-120);
  textSize(30);
  text("press e", width/2, height-60);
}

void clear_scene2() {//(1000, 600)
  background(155, 255, 155);
  img = loadImage("clear2.png");
  image(img, 70, 150, width/4, height/2);
  image(img, 680, 150, width/4, height/2);
  fill(0);
  textSize(80);
  text("CLEAR!", width/2, height/5);
  textSize(50);
  text("Score: ", width/2, height/2-80);
  textSize(80);
  text(HP + "/120", width/2, height/2);
  textSize(50);
  text("Thank you for playing...", width/2, height-120);
  textSize(30);
  text("press e", width/2, height-60);
}

void perfect_scene() {
  background(155, 255, 155);
  img = loadImage("yuriko-smile.jpg");
  image(img, 0, 0, width, height);
  img = loadImage("perfect.png");
  image(img, 40, 150, width/4, height/2);
  image(img, 720, 150, width/4, height/2);
  fill(0);
  textSize(80);
  fill(253, 8, 146);
  text("Congratulations!!", width/2, 100);
  textSize(80);
  text("Full Score!", width/2, 300);
  textSize(30);
  text("Thank you for playing...", width/2, height-100);
}

void gameover_scene() {
  background(215, 45, 68);
  fill(0);
  textSize(80);
  text("GAME OVER...", width/2, height/3);
  img = loadImage("gameover.png");
  image(img, 400, 250, width/5, height/2);
}

void keyPressed() {
  if (scene == "start" && key == 'f') {
    scene = "select";
  }
  if (scene == "select" && rcv[0] == 2 && key == 's') {
    scene = "main";
    generateFrec = 90;
    D = 20;
    E = 5;
    speed1 = 0.03;
    speed2 = 0.003;
    LEVEL = 2;
  }
  if (scene == "select" && rcv[0] == 3 && key == 's') {
    scene = "main";
    generateFrec = 70;
    D = 25;
    E = 7;
    speed1 = 0.05;
    speed2 = 0.005;
    LEVEL = 3;
  }
  if (scene == "select" && rcv[0] == 4 && key == 's') {
    scene = "main";
    generateFrec = 50;
    D = 40;
    E = 10;
    speed1 = 0.07;
    speed2 = 0.007;
    LEVEL = 4;
  }
  if (scene == "clear1" && key == 'e') {
    scene = "start";
  }
  if (scene == "clear2" && key == 'e') {
    scene = "start";
  }
  if (scene == "perfect" && key == 'e') {
    scene = "start";
  }
  if (scene == "gameover" && key == 'e') {
    scene = "start";
  }
}

int rcv[] = new int[3];
boolean findHeader = false;
int HEADER = 0x00;

void serialEvent(Serial myPort) {
  if (myPort.available() > 0) {
    if (findHeader == true) {             //ヘッダーを受信
      if (myPort.available() > 3) {      //3つのデータが届いたら、
        for (int i = 0; i < 3; i++) {    //受信データを配列に格納
          rcv[i] = myPort.read();
        }
        findHeader = false;
        println("SW:" + rcv[0] + "," + "X:" + rcv[1] + "," + "Y:" + rcv[2]);
      }
    } else {
      if (myPort.read() == HEADER) {
        findHeader = true;
      }
    }
  }
}
