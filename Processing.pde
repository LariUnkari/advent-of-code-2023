import java.awt.HeadlessException;
import java.awt.Toolkit;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.DataFlavor;
import java.awt.datatransfer.UnsupportedFlavorException;
import java.io.IOException;

int resHorizontal = 640;
int resVertical = 360;

int middleX;
int middleY;

int dayButtonWidth = 60;
int dayButtonHeight = 60;
int dayButtonFontSize = 30;
int inputLabelFontSize = 20;
int inputButtonWidth = 120;
int inputButtonHeight = 40;
int inputButtonFontSize = 20;
int runButtonWidth = 80;
int runButtonHeight = 80;
int runButtonFontSize = 30;
ButtonColors buttonColors = new ButtonColors(color(191), color(255), color(63), color(0));

int buttonMargin = 10;

DayBase[] daySolutions;
Button[] dayButtons;

int buttonX, buttonY;

int hoveredButtonIndex;
Button hoveredButton;

int selectedDayIndex;
DayBase selectedDaySolution;
String[] defaultInput;
String[] customInput;
String[] selectedInput;

int inputMenuDayX, inputMenuDayY, inputLabelY;
Button defaultInputButton;
Button customInputButton;
Button runDayButton;
Button backButton;

void settings() {
    size(this.resHorizontal, this.resVertical);
    println("Resolution is " + this.resHorizontal + "x" + this.resVertical);

    this.middleX = this.resHorizontal / 2;
    this.middleY = this.resVertical / 2;

    this.hoveredButtonIndex = -1;
    this.hoveredButton = null;
    
    this.selectedDayIndex = -1;

    this.daySolutions = new DayBase[25];
    this.dayButtons = new Button[25];

    int i;
    DayBase day;
    for (int y = 0; y < 5; y++) {
        for (int x = 0; x < 5; x++) {
            i = y * 5 + x;

            day = getDaySolution(i);
            this.daySolutions[i] = day;

            this.buttonX = this.middleX + (x - 2) * (buttonMargin + this.dayButtonWidth) - this.dayButtonWidth / 2;
            this.buttonY = this.middleY + (y - 2) * (buttonMargin + this.dayButtonHeight) - this.dayButtonHeight / 2;
            
            this.dayButtons[i] = new Button(this.buttonX, this.buttonY, this.dayButtonWidth, this.dayButtonHeight,
                buttonColors, this.dayButtonFontSize, nf(i + 1, 2), day.isImplemented);
        }
    }

    this.buttonX = this.buttonMargin;
    this.buttonY = this.buttonMargin;
    this.backButton = new Button(this.buttonX, this.buttonY, this.inputButtonWidth, this.inputButtonHeight,
        buttonColors, this.inputButtonFontSize, "BACK", true);
    
    this.inputMenuDayX = this.middleX - this.dayButtonWidth / 2;
    this.inputMenuDayY = this.middleY - (2 * this.dayButtonHeight + this.dayButtonHeight / 2);
    this.inputLabelY = this.inputMenuDayY + this.dayButtonHeight + this.inputLabelFontSize + this.buttonMargin;

    this.buttonX = this.middleX - this.inputButtonWidth / 2;
    this.buttonY = this.inputLabelY + this.inputLabelFontSize + this.buttonMargin;
    this.defaultInputButton = new Button(this.buttonX, this.buttonY, this.inputButtonWidth, this.inputButtonHeight,
        buttonColors, this.inputButtonFontSize, "default", true);

    this.buttonY += this.inputButtonHeight + this.buttonMargin;
    this.customInputButton = new Button(this.buttonX, this.buttonY, this.inputButtonWidth, this.inputButtonHeight,
        buttonColors, this.inputButtonFontSize, "clipboard", true);

    this.buttonX = this.middleX - this.runButtonWidth / 2;
    this.buttonY += this.inputButtonHeight + 3 * this.buttonMargin;
    this.runDayButton = new Button(this.buttonX, this.buttonY, this.runButtonWidth, this.runButtonHeight,
        buttonColors, this.runButtonFontSize, "RUN", true);
}

void draw() {
    this.update(mouseX, mouseY);

    background(0);

    if (this.selectedDayIndex < 0) {
        Button button;
        for (int i = 0; i < this.dayButtons.length; i++) {
            this.dayButtons[i].drawButton();
        }
    } else {
        this.backButton.drawButton();
        this.dayButtons[this.selectedDayIndex].drawButtonAt(inputMenuDayX, this.inputMenuDayY);

        fill(255);
        textSize(this.inputLabelFontSize);
        textAlign(CENTER, CENTER);
        text("Select input", this.middleX, this.inputLabelY);
        this.defaultInputButton.drawButton();
        this.customInputButton.drawButton();
        this.runDayButton.drawButton();
    }
}

void update(int x, int y) {
    if (this.selectedDayIndex < 0) {
        this.updateButtonGrid(x, y);
    } else {
        this.updateInputSelection(x, y);
    }
}

void updateButtonGrid(int x, int y) {
    this.hoveredButtonIndex = -1;

    for (int i = 0; i < this.dayButtons.length; i++) {
        if (this.dayButtons[i].containsPoint(x, y)) {
            this.hoveredButtonIndex = i;
            break;
        }
    }

    if (this.hoveredButtonIndex >= 0) {
        if (this.hoveredButton != null) {
            this.hoveredButton.onMouseOut();
        }

        this.hoveredButton = this.dayButtons[this.hoveredButtonIndex];
        this.hoveredButton.onMouseOver();
    } else {
        if (this.hoveredButton != null) {
            this.hoveredButton.onMouseOut();
        }

        this.hoveredButton = null;
    }
}

void updateInputSelection(int x, int y) {
    this.hoveredButtonIndex = -1;

    if (this.backButton.containsPoint(x, y)) {
        this.hoveredButtonIndex = 3;
    } else if (this.runDayButton.containsPoint(x, y)) {
        this.hoveredButtonIndex = 0;
    } else if (this.defaultInputButton.containsPoint(x, y)) {
        this.hoveredButtonIndex = 1;
    } else if (this.customInputButton.containsPoint(x, y)) {
        this.hoveredButtonIndex = 2;
    }

    if (this.hoveredButtonIndex >= 0) {
        if (this.hoveredButton != null) {
            this.hoveredButton.onMouseOut();
        }

        if (this.hoveredButtonIndex == 0) {
            this.hoveredButton = this.runDayButton;
        } else if (this.hoveredButtonIndex == 1) {
            this.hoveredButton = this.defaultInputButton;
        } else if (this.hoveredButtonIndex == 2) {
            this.hoveredButton = this.customInputButton;
        } else {
            this.hoveredButton = this.backButton;
        }

        this.hoveredButton.onMouseOver();
    } else {
        if (this.hoveredButton != null) {
            this.hoveredButton.onMouseOut();
        }

        this.hoveredButton = null;
    }
}

void mousePressed() {
    println("Mouse pressed at " + mouseX + "," + mouseY);

    if (this.hoveredButton != null) {
        if (this.hoveredButton.isEnabled) {
            println("Button[" + this.hoveredButtonIndex + "] '" + this.hoveredButton.labelText + "' clicked!");

            this.hoveredButton.onMouseOut();
            this.hoveredButton = null;

            if (this.selectedDayIndex < 0) {
                this.selectDay(this.hoveredButtonIndex);
            } else {
                if (this.hoveredButtonIndex == 0) {
                    this.runDay();
                } else if (this.hoveredButtonIndex <= 2) {
                    this.selectInput(this.hoveredButtonIndex - 1);
                } else {
                    this.selectedDayIndex = -1;
                    this.selectedDaySolution = null;
                }
            }
        } else {
            println("Button[" + this.hoveredButtonIndex + "] '" + this.hoveredButton.labelText + "' clicked but it was disabled");
        }
    }
}

void selectDay(int index) {
    this.selectedDayIndex = index;
    this.selectedDaySolution = this.daySolutions[index];

    this.selectedInput = null;
    this.runDayButton.isEnabled = false;

    String inputPath = "./inputs/Day" + nf(index + 1, 2) + ".txt";
    println("Searching for default input at " + inputPath);
    String[] inputStrings = loadStrings(inputPath);

    if (inputStrings.length > 0) {
        println("Found input of " + inputStrings.length + " lines!");
        this.defaultInput = inputStrings;
    }
}

void selectInput(int index) {
    if (index == 0) {
        println("Run with default input!");
        this.selectedInput = this.defaultInput;
        this.runDayButton.isEnabled = true;
        return;
    }

    this.selectedInput = this.getClipboardInput();
    if (this.selectedInput.length > 0) {
        this.runDayButton.isEnabled = true;
        this.selectedDaySolution.setInput(this.selectedInput);
    }
}

String[] getClipboardInput() {
    println("Get user input from clipboard");

    String[] input = new String[0];

    try {
        Toolkit toolkit = Toolkit.getDefaultToolkit();
        Clipboard clipboard = toolkit.getSystemClipboard();
        String data = (String)clipboard.getData(DataFlavor.stringFlavor);
        input = data.split("\n");
        println("Clipboard data length: " + data.length() + ", line count: " + input.length + "\n" + data);
    } catch (UnsupportedFlavorException e) {
        println("Unsupported flavor");
    } catch (IOException e) {
        println("IO exception");
    }

    return input;
}

void runDay() {
    this.selectedDaySolution.run();
}

DayBase getDaySolution(int dayIndex) {
    DayBase dayObject = null;

    switch (dayIndex) {
        case 0: dayObject = new Day01(); break;
        default:
            println("Unsupported day index " + dayIndex + " provided!");
            dayObject = new DayBase();
            break;
    }

    return dayObject;
}