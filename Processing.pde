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
int backButtonWidth = 100;
int backButtonHeight = 30;
int backButtonFontSize = 20;
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

boolean isSelectingInput;
boolean isStartingDaySolution;
boolean isRunningDaySolution;

void settings() {
    size(this.resHorizontal, this.resVertical);
    println("Resolution is " + this.resHorizontal + "x" + this.resVertical);

    this.middleX = this.resHorizontal / 2;
    this.middleY = this.resVertical / 2;

    this.hoveredButtonIndex = -1;
    this.hoveredButton = null;
    
    this.selectedDayIndex = -1;

    this.isSelectingInput = false;
    this.isStartingDaySolution = false;
    this.isRunningDaySolution = false;

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
    this.backButton = new Button(this.buttonX, this.buttonY, this.backButtonWidth, this.backButtonHeight,
        buttonColors, this.backButtonFontSize, "BACK", true);
    
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

    if (this.isStartingDaySolution || this.isRunningDaySolution) {
        drawDaySolution();
    } else if (this.isSelectingInput) {
        drawInputSelection();
    } else {
        drawDaySelection();
    }
}

void drawDaySelection() {
    for (int i = 0; i < this.dayButtons.length; i++) {
        this.dayButtons[i].drawButton();
    }
}

void drawInputSelection() {
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

void drawDaySolution() {
    this.backButton.drawButton();
    this.selectedDaySolution.draw();
}

void update(int x, int y) {
    this.hoveredButtonIndex = -1;

    if (this.isStartingDaySolution || this.isRunningDaySolution) {
        this.updateDaySolution(x, y);

        if (!this.isRunningDaySolution) {
            this.runDaySolution();
        }
    } else if (this.isSelectingInput) {
        this.updateInputSelection(x, y);
    } else {
        this.updateButtonGrid(x, y);
    }
}

void updateButtonGrid(int x, int y) {
    for (int i = 0; i < this.dayButtons.length; i++) {
        if (this.dayButtons[i].containsPoint(x, y)) {
            this.hoveredButtonIndex = i;
            break;
        }
    }

    if (this.hoveredButtonIndex < 0) {
        this.onNoButtonHovered();
    } else {
        this.onButtonHovered(this.dayButtons[this.hoveredButtonIndex]);
    }
}

void updateInputSelection(int x, int y) {
    if (this.backButton.containsPoint(x, y)) {
        this.hoveredButtonIndex = 0;
    } else if (this.runDayButton.containsPoint(x, y)) {
        this.hoveredButtonIndex = 1;
    } else if (this.defaultInputButton.containsPoint(x, y)) {
        this.hoveredButtonIndex = 2;
    } else if (this.customInputButton.containsPoint(x, y)) {
        this.hoveredButtonIndex = 3;
    }

    if (this.hoveredButtonIndex < 0) {
        this.onNoButtonHovered();
    } else {
        if (this.hoveredButtonIndex == 0) {
            this.onButtonHovered(this.backButton);
        } else if (this.hoveredButtonIndex == 1) {
            this.onButtonHovered(this.runDayButton);
        } else if (this.hoveredButtonIndex == 2) {
            this.onButtonHovered(this.defaultInputButton);
        } else {
            this.onButtonHovered(this.customInputButton);
        }
    }
}

void updateDaySolution(int x, int y) {
    this.selectedDaySolution.update(x, y);

    if (this.backButton.containsPoint(x, y)) {
        this.hoveredButtonIndex = 0;
    }

    if (this.hoveredButtonIndex < 0) {
        this.onNoButtonHovered();
    } else {
        this.onButtonHovered(this.backButton);
    } 
}

void clearHoveredButton() {
    this.hoveredButtonIndex = -1;
    this.onNoButtonHovered();
}

void onNoButtonHovered() {
    if (this.hoveredButton != null) {
        println("Button '" + this.hoveredButton.labelText + "' no longer hovered");
        this.hoveredButton.onMouseOut();
        this.hoveredButton = null;
    }
}

void onButtonHovered(Button button) {
    if (this.hoveredButton != null) {
        if (this.hoveredButton == button) {
            return;
        }

        println("Button '" + this.hoveredButton.labelText + "' no longer hovered");
        this.hoveredButton.onMouseOut();
    }

    this.hoveredButton = button;
    this.hoveredButton.onMouseOver();
    println("Button '" + this.hoveredButton.labelText + "' now hovered");
}

void mousePressed() {
    println("Mouse pressed at " + mouseX + "," + mouseY);

    if (this.selectedDaySolution != null) {
        this.selectedDaySolution.onMousePressed();
    }

    if (this.hoveredButton != null) {
        if (!this.hoveredButton.isEnabled) {
            println("Button[" + this.hoveredButtonIndex + "] '" + this.hoveredButton.labelText + "' clicked but it was disabled");
            return;
        }

        println("Button[" + this.hoveredButtonIndex + "] '" + this.hoveredButton.labelText + "' clicked!");

        this.hoveredButton.onMouseOut();
        this.hoveredButton = null;

        if (this.isStartingDaySolution || this.isRunningDaySolution) {
            this.stopDaySolution();
        } else if (this.isSelectingInput) {
            if (this.hoveredButtonIndex == 0) {
                // Back button
                this.isSelectingInput = false;
                this.selectedDayIndex = -1;
                this.selectedDaySolution = null;
            } else if (this.hoveredButtonIndex == 1) {
                // Run button
                this.startDaySolution();
            } else if (this.hoveredButtonIndex == 2) {
                // Default input button
                this.selectInput(0);
            } else if (this.hoveredButtonIndex == 3) {
                // Custom input button
                this.selectInput(1);
            }
        } else {
            this.selectDay(this.hoveredButtonIndex);
        }
    }
}

void selectDay(int index) {
    this.clearHoveredButton();

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

    this.isSelectingInput = true;
}

void selectInput(int index) {
    if (index == 0) {
        println("Run with default input!");
        this.selectedInput = this.defaultInput;
        this.runDayButton.isEnabled = true;
    } else {
        this.selectedInput = this.getClipboardInput();
    }

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

void startDaySolution() {
    this.clearHoveredButton();
    this.isSelectingInput = false;
    this.isStartingDaySolution = true;
}

void runDaySolution() {
    this.isRunningDaySolution = true;
    this.isStartingDaySolution = false;
    this.selectedDaySolution.start();
}

void stopDaySolution() {
    this.selectedDaySolution.stop();
    this.selectedDaySolution = null;
    this.isRunningDaySolution = false;
    this.isSelectingInput = true;
}

DayBase getDaySolution(int dayIndex) {
    switch (dayIndex) {
        case 0: return new Day01();
        case 1: return new Day02();
        default:
            println("Unsupported day index " + dayIndex + " provided!");
            break;
    }

    return new DayBase();
}