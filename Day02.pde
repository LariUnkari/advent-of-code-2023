class Day02 extends DayPages {
    private Day02ParsingData parsingData;

    private int tableX;
    private int tableY;
    
    private int gamesPerRow;
    private int gamesRowsPerPage;
    private int gamesPerPage;

    private int gameCardWidth = 124;
    private int gameCardHeight = 160;
    private color colorGameValid = color(255);
    private color colorGameInvalid = color(255, 50, 50);
    private int gameFontSize = 20;
    private int gamePowerRowHeight = 16;
    private int gamePowerFontSize = 14;
    private int gameHighestRowHeight = 20;
    private int gameHighestFontSize = 14;
    private int gameCubesRowHeight = 16;
    private int gameCubesFontSize = 12;
    private int gameCubesSize = 10;
    private int setFontSize = 10;
    private int setCubeSize = 3;

    Day02(ViewRect viewRect) {
        super(viewRect);
        this.isImplemented = true;
    }

    void part1(Day02Game[] games, Day02Set maximums) {
        int sum = 0;

        for (Day02Game game : games) {
            game.isValid = this.isGameValid(maximums, game.highest);
            if (game.isValid) {
                sum += game.id;
            // } else {
            //     println("Game " + game.id + " is impossible");
            }
        }

        println("Part 1: sum of possible game ids: " + sum);
    }

    void part2(Day02Game[] games) {
        int sum = 0;

        for (Day02Game game : games) {
            game.power = game.highest.reds * game.highest.greens * game.highest.blues;
            //println("Game " + game.id + " power is " + power);
            sum += game.power;
        }

        println("Part 2: sum of game powers: " + sum);
    }

    void run() {
        this.gamesPerRow = this.viewRect.width / this.gameCardWidth;
        this.gamesRowsPerPage = this.viewRect.height / this.gameCardHeight;
        this.gamesPerPage = this.gamesPerRow * this.gamesRowsPerPage;

        this.pageCount = this.input.length / this.gamesPerPage + (this.input.length % this.gamesPerPage > 0 ? 1 : 0);

        this.tableX = this.viewRect.x + (this.viewRect.width - this.gamesPerRow * this.gameCardWidth) / 2;
        this.tableY = this.viewRect.y;

        this.parsingData = new Day02ParsingData(this.input.length);
        this.isParsingData = true;
    }

    void onComplete() {
        this.part1(this.parsingData.games, new Day02Set(12, 13, 14));
        this.part2(this.parsingData.games);
    }

    void draw() {
        super.draw();

        if (this.isParsingData && !this.isRunning) {
            return;
        }
        
        int posX, posY, midX, idX, idY, powY, hiX, hiY, cubRX, cubGX, cubBX, cubY, setX, setY;
        Day02Game game;
        Day02Set set;

        int index = 0;
        for (int y = 0; y < this.gamesRowsPerPage; y++) {
            posY = this.tableY + y * this.gameCardHeight;

            for (int x = 0; x < this.gamesPerRow; x++) {
                index = this.pageIndex * this.gamesPerPage + y * 10 + x;
                if (index >= this.parsingData.gameIndex) {
                    break;
                }

                game = this.parsingData.games[index];
                posX = this.tableX + x * this.gameCardWidth;
                midX = posX + this.gameCardWidth / 2;

                fill(0);
                stroke(game.isValid ? this.colorGameValid : this.colorGameInvalid);
                strokeWeight(2);
                rect(posX + 2, posY + 2, gameCardWidth - 4, gameCardHeight - 4);

                idX = posX + 5;
                idY = posY + 5;

                fill(255);
                noStroke();
                textSize(this.gameFontSize);
                textAlign(LEFT, TOP);
                text("Game " + game.id, idX, idY);

                powY = idY + this.gameFontSize + 2;
                cubRX = idX + 18;
                cubGX = cubRX + 34;
                cubBX = cubGX + 34;
                cubY = powY + this.gamePowerRowHeight + 1;
                hiX = idX + 2;
                hiY = cubY - 1;

                textAlign(CENTER, TOP);
                textSize(this.gamePowerFontSize);
                text("POWER  " + game.power, midX, powY);
                textAlign(LEFT, TOP);
                textSize(this.gameHighestFontSize);
                text("HI", hiX, hiY);

                fill(255, 50, 50);
                rect(cubRX, cubY, this.gameCubesSize, this.gameCubesSize);

                fill(0, 255, 0);
                rect(cubGX, cubY, this.gameCubesSize, this.gameCubesSize);

                fill(100, 100, 255);
                rect(cubBX, cubY, this.gameCubesSize, this.gameCubesSize);

                fill(255);
                textSize(this.gameCubesFontSize);
                textAlign(LEFT, TOP);
                text(game.highest.reds, cubRX + this.gameCubesSize + 4, cubY);
                text(game.highest.greens, cubGX + this.gameCubesSize + 4, cubY);
                text(game.highest.blues, cubBX + this.gameCubesSize + 4, cubY);

                setY = cubY + this.gameCubesRowHeight + 2;

                textSize(this.setFontSize);
                textAlign(CENTER, TOP);
                for (int s = 0; s < game.sets.length; s++) {
                    set = game.sets[s];
                    setX = idX + 5 + s * 18;

                    fill(255);
                    text(s + 1, setX + 6, setY);

                    fill(255, 50, 50);
                    for (int r = 0; r < set.reds; r++) {
                        rect(setX + 2, setY + this.setFontSize + r * 4, this.setCubeSize, this.setCubeSize);
                    }
                    fill(0, 255, 0);
                    for (int g = 0; g < set.greens; g++) {
                        rect(setX + 6, setY + this.setFontSize + g * 4, this.setCubeSize, this.setCubeSize);
                    }
                    fill(100, 100, 255);
                    for (int b = 0; b < set.blues; b++) {
                        rect(setX + 10, setY + this.setFontSize + b * 4, this.setCubeSize, this.setCubeSize);
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

            if (this.parsingData.gameIndex + 1 > (this.pageIndex + 1) * this.gamesPerPage) {
                this.pageIndex++;
            }

            return;
        }

        this.isParsingData = false;
    }

    Day02Game parseGame(String data) {
        int semicolonIndex = data.indexOf(":");
        int id = Integer.parseInt(data.substring(data.indexOf(" ") + 1, semicolonIndex));
        //println("Game: " + id);

        String[] setsPerGame = split(data.substring(semicolonIndex + 2), "; ");
        Day02Set[] sets = new Day02Set[setsPerGame.length];

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

    public boolean isGameValid(Day02Set maximums, Day02Set highest) {
        if (highest.reds > maximums.reds) {
            return false;
        }
        if (highest.greens > maximums.greens) {
            return false;
        }
        if (highest.blues > maximums.blues) {
            return false;
        }

        return true;
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

    public boolean isValid;
    public int power;
    public Day02Set highest;

    Day02Game(int id, Day02Set[] sets) {
        this.id = id;
        this.sets = sets;

        this.isValid = true;
        this.power = 0;
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

        //println("Game " + id + " highest cubes: R=" + this.highest.reds + ", G=" + this.highest.greens + ", B=" + this.highest.blues);
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