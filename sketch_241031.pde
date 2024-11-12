//Nama  : Yulian
//NIM   : 22.11.4605
//Kelas : 22-IF01

import processing.sound.*; // Import library sound

ArrayList<Cokroach> coks;
PImage img, cakeImg;
SoundFile backgroundMusic; // Untuk musik latar
SoundFile hitSound; // Untuk efek suara saat membunuh kecoa
int score = 0;
PVector cakePos;
boolean gameLost = false; // Menandakan apakah permainan kalah
int lastSpawnTime = 0; // Waktu spawn terakhir
PFont robotoFont;

void setup() {
  size(800, 800);
  coks = new ArrayList<Cokroach>();
  img = loadImage("kecoa.png");
  cakeImg = loadImage("cake.png"); // Gambar kue
  cakePos = new PVector(width / 2, height / 2); // Posisi kue di tengah

  robotoFont = loadFont("Roboto-Black-48.vlw");

  // Load sound files
  loadSounds(); // Memanggil fungsi untuk memuat suara

  // Mulai memutar musik latar jika berhasil dimuat
  if (backgroundMusic != null) {
    backgroundMusic.loop(); // Memutar musik latar secara berulang
  }

  // Tambah Cokroach secara otomatis
  spawnCokroach();
}

void draw() {
  background(255);
  
  // Gambar kue di tengah
  image(cakeImg, cakePos.x - cakeImg.width / 2, cakePos.y - cakeImg.height / 2);
  
  // Gambar semua Cokroach
  for (Cokroach c : coks) {
    c.live();
    
    // Cek apakah Cokroach menyentuh kue
    if (!gameLost && dist(c.pos.x, c.pos.y, cakePos.x, cakePos.y) < cakeImg.width / 2) { // Menggunakan setengah dari lebar kue
      gameLost = true; // Set permainan kalah
    }
  }
  
  // Cek apakah pemain kalah
  if (gameLost) {
    fill(255, 0, 0);
    textFont(robotoFont);
    textSize(48);
    text("Kamu Kalah!", width / 2 - 150, height / 2);
    noLoop(); // Hentikan permainan
  } else {
    // Tampilkan skor
    fill(51);
    textFont(robotoFont);
    textSize(16);
    text("Score: " + score, 50, 750); 
  }

  // Tambah Cokroach secara otomatis setiap 5 detik
  if (millis() - lastSpawnTime > 5000) {
    spawnCokroach();
    lastSpawnTime = millis(); // Update waktu spawn
  }
}

void loadSounds() {
  try {
    backgroundMusic = new SoundFile(this, "gameBoy.mp3");
    hitSound = new SoundFile(this, "pew.mp3");
  } catch (Exception e) {
    println("Error loading sound files: " + e.getMessage());
  }
}

void spawnCokroach() {
  float x, y;
  // Cek apakah posisi spawn berada di area kue
  do {
    x = random(width);
    y = random(height);
  } while (dist(x, y, cakePos.x, cakePos.y) < cakeImg.width / 2); // Pastikan tidak berada di area kue

  Cokroach newCokroach = new Cokroach(img, x, y);
  coks.add(newCokroach);
}

void mouseClicked() {
  if (mouseButton == LEFT) {
    // Periksa setiap Cokroach apakah diklik
    for (int i = coks.size() - 1; i >= 0; i--) {
      Cokroach c = coks.get(i);
      // Hitung jarak antara mouse dan posisi Cokroach
      if (dist(mouseX, mouseY, c.pos.x, c.pos.y) < 25) { // 25 bisa disesuaikan dengan ukuran Cokroach
        coks.remove(i); // Hapus Cokroach jika diklik
        if (hitSound != null) {
          hitSound.play(); // Putar sound effect saat Cokroach dibunuh
        }
        score++; // Tambah skor
        break; // Keluar setelah satu Cokroach dihapus
      }
    }
  }
}

class Cokroach {
  PVector pos;
  PVector vel;
  PImage img;
  float heading;

  Cokroach(PImage _img, float _x, float _y) {
    pos = new PVector(_x, _y);
    vel = PVector.random2D();
    heading = 0;
    img = _img;
  }

  void live() {
    pos.add(vel);

    if (pos.x <= 0 || pos.x >= width) vel.x *= -1;
    if (pos.y <= 0 || pos.y >= height) vel.y *= -1;

    heading = atan2(vel.y, vel.x);
    pushMatrix();
      imageMode(CENTER);
      translate(pos.x, pos.y);
      rotate(heading + 0.5 * PI);
      image(img, 0, 0);
    popMatrix();
  }
}
