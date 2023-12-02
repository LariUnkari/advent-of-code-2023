class ButtonColors {
    public color normal;
    public color highlighted;
    public color disabled;
    public color text;

    ButtonColors(color normal, color highlighted, color disabled, color text) {
        this.normal = normal;
        this.highlighted = highlighted;
        this.disabled = disabled;
        this.text = text;
    }
}

class Button {
    public int x;
    public int y;
    public int width;
    public int height;

    public String labelText;
    private int labelFontSize;
    private int labelX;
    private int labelY;

    private ButtonColors colors;

    public boolean isEnabled;
    private boolean isMouseOver;

    Button(int x, int y, int width, int height, ButtonColors colors, int labelFontSize, String labelText, boolean isEnabled) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        this.colors = colors;
        this.labelFontSize = labelFontSize;
        this.labelText = labelText;
        this.labelX = width / 2;
        this.labelY = height / 2;
        this.isEnabled = isEnabled;
        this.isMouseOver = false;
    }

    void drawButton() {
        this.drawButtonAt(this.x, this.y);
    }

    void drawButtonAt(int x, int y) {
        if (this.isEnabled) {
            fill(this.isMouseOver ? this.colors.highlighted : this.colors.normal);
        } else {
            fill(this.colors.disabled);
        }
        rect(x, y, this.width, this.height);
        fill(this.colors.text);
        textSize(this.labelFontSize);
        textAlign(CENTER, CENTER);
        text(this.labelText, x + this.labelX, y + this.labelY);
    }

    boolean containsPoint(int x, int y) {
        if (x >= this.x && x <= this.x + this.width && y >= this.y && y <= this.y + this.height) {
            return true;
        }

        return false;
    }
    
    void onMouseOver() {
        this.isMouseOver = true;
    }

    void onMouseOut() {
        this.isMouseOver = false;
    }
}