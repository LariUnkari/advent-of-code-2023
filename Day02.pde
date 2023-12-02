
class Day02 extends DayBase {
    Day02() {
        super();
        this.isImplemented = true;
    }

    void run() {
        println("Running Day 02");
        Day02Game[] games = this.getGames();
        this.part1(games, new Day02Set(12, 13, 14));
        this.part2(games);
        this.stop();
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

    Day02Game[] getGames() {
        Day02Game[] games = new Day02Game[this.input.length];

        Day02Game game;
        for (int i = 0; i < this.input.length; i++) {
            game = this.parseGame(this.input[i]);
            //println("Game " + game.id + " highest dice counts: red=" + game.highest.reds + ", green=" + game.highest.greens + ", blue=" + game.highest.blues);
            games[i] = game;
        }

        return games;
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