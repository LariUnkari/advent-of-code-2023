int resHorizontal = 640;
int resVertical = 360;

int middleX;
int middleY;

void settings() {
    size(this.resHorizontal, this.resVertical);
    println("Resolution is " + this.resHorizontal + "x" + this.resVertical);

    this.middleX = this.resHorizontal / 2;
    this.middleY = this.resVertical / 2;
}

void draw() {
    background(0);
    noStroke();
    fill(255);
    int radius = 20;
    ellipse(this.middleX , this.middleY, radius * 2, radius * 2);
}