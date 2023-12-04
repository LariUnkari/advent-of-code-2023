class ViewRect {
    public int x;
    public int y;
    public int width;
    public int height;
    public int middleX;
    public int middleY;

    public ViewRect(int x, int y, int width, int height) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        this.middleX = x + width / 2;
        this.middleY = y + height / 2;
    }
}