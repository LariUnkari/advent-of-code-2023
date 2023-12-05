abstract class DayPages extends DayBase {
    protected int buttonHoverIndex;
    protected Button hoveredButton;

    protected Button pageUpButton;
    protected Button pageDownButton;

    protected int pageCount;
    protected int pageIndex;
    
    protected int pageLabelY = 10;
    protected int pageLabelWidth = 24;
    protected int pageLabelTitleFontSize = 12;
    protected int pageLabelNumberFontSize = 26;

    protected int pageButtonY = 10;
    protected int pageButtonMargin = 10;
    protected int pageButtonWidth = 100;
    protected int pageButtonHeight = 30;
    protected int pageButtonFontSize = 20;
    protected ButtonColors buttonColors = new ButtonColors(color(191), color(255), color(63), color(0));

    public DayPages(ViewRect viewRect) {
        super(viewRect);
    }

    void init() {
        super.init();
        println("Initializing page system");

        this.pageUpButton = new Button(this.viewRect.x + this.viewRect.width - this.pageButtonWidth, this.pageButtonY,
            this.pageButtonWidth, this.pageButtonHeight, this.buttonColors, this.pageButtonFontSize, "UP", true);
        this.pageDownButton = new Button(this.pageUpButton.x - 2 * this.pageButtonMargin - this.pageButtonWidth - pageLabelWidth,
            this.pageButtonY, this.pageButtonWidth, this.pageButtonHeight, this.buttonColors, this.pageButtonFontSize, "DOWN", true);

        this.buttonHoverIndex = -1;
        this.hoveredButton = null;

        this.pageIndex = 0;
        this.pageCount = 0;
    }

    boolean update(int x, int y) {
        this.updateButtons(x, y);
        return super.update(x, y);
    }

    void updateButtons(int x, int y) {
        this.buttonHoverIndex = -1;

        if (this.pageUpButton.containsPoint(x, y)) {
            this.buttonHoverIndex = 0;
        } else if (this.pageDownButton.containsPoint(x, y)) {
            this.buttonHoverIndex = 1;
        }

        if (this.buttonHoverIndex == -1) {
            if (this.hoveredButton != null) {
                this.hoveredButton.onMouseOut();
                this.hoveredButton = null;
            }
        } else if (this.buttonHoverIndex == 0) {
            if (this.pageDownButton.isMouseOver) {
                this.pageDownButton.onMouseOut();
            }
            if (!this.pageUpButton.isMouseOver) {
                this.pageUpButton.onMouseOver();
                this.hoveredButton = this.pageUpButton;
            }
        } else if (this.buttonHoverIndex == 1) {
            if (this.pageUpButton.isMouseOver) {
                this.pageUpButton.onMouseOut();
            }
            if (!this.pageDownButton.isMouseOver) {
                this.pageDownButton.onMouseOver();
                this.hoveredButton = this.pageDownButton;
            }
        }
    }

    void onMousePressed() {
        if (this.hoveredButton == null) {
            println("No button hovered!");
            return;
        }

        if (this.hoveredButton == this.pageUpButton) {
            if (this.pageIndex > 0) {
                println("Up a page!");
                this.pageIndex--;
            } else {
                println("Already at top of pages " + (this.pageIndex + 1) + "/" + this.pageCount);
            }
        } else if (this.hoveredButton == this.pageDownButton) {
            if (this.pageIndex < this.pageCount - 1) {
                println("Down a page!");
                this.pageIndex++;
            } else {
                println("Already at bottom of pages " + (this.pageIndex + 1) + "/" + this.pageCount);
            }
        }
    }

    void draw() {
        super.draw();
        this.pageUpButton.drawButton();
        this.pageDownButton.drawButton();
        int posX = this.pageUpButton.x - this.pageButtonMargin - this.pageLabelWidth / 2;
        fill(255);
        noStroke();
        textAlign(CENTER, TOP);
        textSize(this.pageLabelTitleFontSize);
        text("PAGE", posX, this.pageLabelY);
        textSize(this.pageLabelNumberFontSize);
        text(this.pageIndex, posX, this.pageLabelY + pageLabelTitleFontSize);
    }
}