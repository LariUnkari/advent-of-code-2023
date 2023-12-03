class Day02 extends DayBase {
    private Day02ParsingData parsingData;

    private int pageButtonWidth = 100;
    private int pageButtonHeight = 30;
    private int pageButtonFontSize = 20;
    private ButtonColors buttonColors = new ButtonColors(color(191), color(255), color(63), color(0));
    private int buttonMargin = 10;

    private Button pageUpButton;
    private Button pageDownButton;
    private int buttonHoverIndex;
    private Button hoveredButton;

    private int gamesPerRow = 8;
    private int gamesRowsPerPage = 3;
    private int gamesPerPage;
    private int gamePageCount;
    private int gamePageIndex;

    Day02() {
        super();
        this.isImplemented = true;
    }

    void part1(Day02Game[] games, Day02Set maximums) {
        int sum = 0;

        for (Day02Game game : games) {
            if (game.isValid(maximums)) {
                sum += game.id;
            // } else {
            //     println("Game " + game.id + " is impossible");
            }
        }

        println("Part 1: sum of possible game ids: " + sum);
    }

    void part2(Day02Game[] games) {
        int sum = 0;
        int power;

        for (Day02Game game : games) {
            power = game.highest.reds * game.highest.greens * game.highest.blues;
            //println("Game " + game.id + " power is " + power);
            sum += power;
        }

        println("Part 2: sum of game powers: " + sum);
    }

    void init() {
        this.pageUpButton = new Button(640 - this.buttonMargin - this.pageButtonWidth, this.buttonMargin,
            this.pageButtonWidth, this.pageButtonHeight, this.buttonColors, this.pageButtonFontSize, "UP", true);
        this.pageDownButton = new Button(640 - 2 * (this.buttonMargin + this.pageButtonWidth), this.buttonMargin,
            this.pageButtonWidth, this.pageButtonHeight, this.buttonColors, this.pageButtonFontSize, "DOWN", true);

        this.buttonHoverIndex = -1;
        this.hoveredButton = null;
    }

    void run() {
        println("Running Day 02");
        this.gamesPerPage = this.gamesPerRow * this.gamesRowsPerPage;
        this.gamePageCount = this.input.length / this.gamesPerPage + (this.input.length % this.gamesPerPage > 0 ? 1 : 0);
        this.gamePageIndex = 0;

        this.parsingData = new Day02ParsingData(this.input.length);
        this.isParsingData = true;
    }

    void update(int x, int y) {
        this.buttonHoverIndex = -1;

        if (this.pageUpButton.containsPoint(x, y)) {
            this.buttonHoverIndex = 0;
        } else if (this.pageDownButton.containsPoint(x, y)) {
            this.buttonHoverIndex = 1;
        }

        if (this.buttonHoverIndex == 0) {
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
        } else if (this.hoveredButton != null) {
            this.hoveredButton.onMouseOut();
            this.hoveredButton = null;
        }

        if (!this.updateParsingInputData()) {
            return;
        }

        this.part1(this.parsingData.games, new Day02Set(12, 13, 14));
        this.part2(this.parsingData.games);
        this.finish();
    }

    void onMousePressed() {
        if (this.hoveredButton == null) {
            println("No button hovered!");
            return;
        }

        if (this.hoveredButton == this.pageUpButton) {
            println("Up a page!");
            if (this.gamePageIndex > 0) {
                this.gamePageIndex--;
            }
        } else if (this.hoveredButton == this.pageDownButton) {
            println("Down a page!");
            if (this.gamePageIndex < this.gamePageCount - 1) {
                this.gamePageIndex++;
            }
        }
    }

    void draw() {
        if (this.isParsingData && !this.isRunning) {
            return;
        }

        this.pageUpButton.drawButton();
        this.pageDownButton.drawButton();
        
        int posX, posY;
        Day02Game game;
        Day02Set set;

        int index = 0;
        for (int y = 0; y < this.gamesRowsPerPage; y++) {
            posY = 60 + y * 100;

            for (int x = 0; x < this.gamesPerRow; x++) {
                index = this.gamePageIndex * this.gamesPerPage + y * 10 + x;
                if (index >= this.parsingData.gameIndex) {
                    break;
                }

                game = this.parsingData.games[index];
                posX = 20 + x * 75;

                fill(255);
                textSize(12);
                textAlign(LEFT);
                text("Game " + game.id, posX, posY);
                
                noStroke();
                for (int s = 0; s < game.sets.length; s++) {
                    set = game.sets[s];

                    fill(255, 50, 50);
                    for (int c = 0; c < set.reds; c++) {
                        rect(posX + c * 3, posY + 5 + s * 12, 2, 2);
                    }
                    fill(0, 255, 0);
                    for (int c = 0; c < set.greens; c++) {
                        rect(posX + c * 3, posY + 8 + s * 12, 2, 2);
                    }
                    fill(100, 100, 255);
                    for (int c = 0; c < set.greens; c++) {
                        rect(posX + c * 3, posY + 11 + s * 12, 2, 2);
                    }
                }
            }

            if (index >= this.parsingData.gameIndex) {
                break;
            }
        }
    }

    void stepParsingInputData() {
        if (this.parsingData.gameIndex < this.parsingData.games.length) {
            Day02Game game = this.parseGame(this.input[this.parsingData.gameIndex]);
            //println("Game " + game.id + " highest dice counts: red=" + game.highest.reds + ", green=" + game.highest.greens + ", blue=" + game.highest.blues);

            this.parsingData.games[this.parsingData.gameIndex] = game;
            this.parsingData.gameIndex++;

            if (this.parsingData.gameIndex + 1 > (this.gamePageIndex + 1) * this.gamesPerPage) {
                this.gamePageIndex++;
            }

            return;
        }

        this.isParsingData = false;
    }

    Day02Game parseGame(String data) {
        Day02Set[] sets;

        int semicolonIndex = data.indexOf(":");
        int id = Integer.parseInt(data.substring(data.indexOf(" ") + 1, semicolonIndex));
        //println("Game: " + id);

        String[] setsPerGame = split(data.substring(semicolonIndex + 2), "; ");
        sets = new Day02Set[setsPerGame.length];

        String[] cubesPerColor;
        String[] cubeData;
        int reds, greens, blues;

        for (int i = 0; i < setsPerGame.length; i++) {
            reds = 0;
            greens = 0;
            blues = 0;

            cubesPerColor = split(setsPerGame[i], ", ");

            for (int j = 0; j < cubesPerColor.length; j++) {
                cubeData = split(cubesPerColor[j], " ");

                switch (cubeData[1]) {
                    case "red":
                        reds = Integer.parseInt(cubeData[0]);
                        break;
                    case "green":
                        greens = Integer.parseInt(cubeData[0]);
                        break;
                    case "blue":
                        blues = Integer.parseInt(cubeData[0]);
                        break;
                    default:
                        println("Invalid cube data on set[" + i + "] cubes[" + j + "]: " + cubesPerColor[j]);
                        break;
                }
            }

            //println("Set[" + i + "]: red=" + reds + ", green=" + greens + ", blue=" + blues);
            sets[i] = new Day02Set(reds, greens, blues);
        }

        return new Day02Game(id, sets);
    }
}

class Day02Set {
    public int reds;
    public int greens;
    public int blues;

    Day02Set(int reds, int greens, int blues) {
        this.reds = reds;
        this.greens = greens;
        this.blues = blues;
    }
}

class Day02Game {
    public int id;
    public Day02Set[] sets;

    public Day02Set minimums;
    public Day02Set highest;

    Day02Game(int id, Day02Set[] sets) {
        this.id = id;
        this.sets = sets;

        this.highest = new Day02Set(0, 0, 0);

        for (Day02Set set : sets) {
            if (set.reds > highest.reds) {
                highest.reds = set.reds;
            }
            if (set.greens > highest.greens) {
                highest.greens = set.greens;
            }
            if (set.blues > highest.blues) {
                highest.blues = set.blues;
            }
        }
    }

    public boolean isValid(Day02Set maximums) {
        if (this.highest.reds > maximums.reds) {
            return false;
        }
        if (this.highest.greens > maximums.greens) {
            return false;
        }
        if (this.highest.blues > maximums.blues) {
            return false;
        }

        return true;
    }
}

class Day02ParsingData {
    public Day02Game[] games;
    public int gameIndex;

    Day02ParsingData(int gameCount) {
        this.games = new Day02Game[gameCount];
        this.gameIndex = 0;
    }
}