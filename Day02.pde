class Day02 extends DayBase {
    private Day02ParsingData parsingData;
    private Day02Visual visualization;

    Day02() {
        super();
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
        this.parsingData.isParsingData = true;
    }

    void onComplete() {
        this.part1(this.parsingData.games, new Day02Set(12, 13, 14));
        this.part2(this.parsingData.games);
    }

    void stepParsingInputData() {
        if (this.parsingData.gameIndex < this.parsingData.games.length) {
            Day02Game game = this.parseGame(this.parsingData.input[this.parsingData.gameIndex]);
            //println("Game " + game.id + " highest dice counts: red=" + game.highest.reds + ", green=" + game.highest.greens + ", blue=" + game.highest.blues);
            this.parsingData.games[this.parsingData.gameIndex] = game;
            this.parsingData.gameIndex++;
            return;
        }

        this.parsingData.isParsingData = false;
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

    void createParsingData(String[] input) {
        this.parsingData = new Day02ParsingData(input);
    }

    ParsingData getParsingData() {
        return this.parsingData;
    }

    void createVisualization(ViewRect viewRect) {
        this.visualization = new Day02Visual(viewRect, this.parsingData);
    }

    DayVisualBase getVisualization() {
        return this.visualization;
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

class Day02ParsingData extends ParsingData {
    public Day02Game[] games;
    public int gameIndex;

    Day02ParsingData(String[] input) {
        super(input);
        this.games = new Day02Game[input.length];
        this.gameIndex = 0;
    }
}