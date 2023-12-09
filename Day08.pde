import java.util.HashSet;
import java.util.Map;
import java.lang.Math;

class Day08 extends DayBase {
    private Day08ParsingData parsingData;
    
    Day08() {
        super();
        this.isImplemented = true;
    }

    void part1() {
        String goal = "ZZZ";
        String start = "AAA";

        println("Found " + this.parsingData.directions.length + " directions");
        println("Set start position '" + start + "'");

        Day08Path path = this.findGoal(start, goal, false, 20000, 4000);

        if (path != null) {
            println("Part 1: Found goal '" + path.goal + "' in " + path.stepsTaken + " steps");
        } else {
            println("Part 1: Failed to find goal '" + goal + "' from '" + start + "'");
        }
    }

    void part2() {
        String goal = "Z";
        ArrayList<String> starts = new ArrayList<String>();

        println("Found " + this.parsingData.directions.length + " directions");

        int i, j;
        Day08MapInstruction instruction;
        for (i = 0; i < this.parsingData.instructions.length; i++) {
            instruction = this.parsingData.instructions[i];

            if (instruction.id.endsWith("A")) {
                println("Found start position '" + instruction.id + "'");
                starts.add(instruction.id);
            }
        }

        int largestKnownPrime, prime, limit, found;
        boolean isDivisible;
        String start;

        Day08Path[] allPaths = new Day08Path[starts.size()];
        Day08Path path;

        HashMap<Integer, ArrayList<Integer>> lcmMap = new HashMap<Integer, ArrayList<Integer>>();
        ArrayList<Integer> lcmList;

        for (i = 0; i < allPaths.length; i++) {
            start = starts.get(i);
            println("Set start position '" + start + "'");

            path = this.findGoal(start, goal, true, 100000, 5000);
            allPaths[i] = path;

            if (path != null) {
                println("Found goal '" + path.goal + "' in " + path.stepsTaken + " steps.");
                this.processPath(path, i, lcmMap);
            } else {
                println("Failed to find '" + goal + "' from '" + start + "'");
            }
        }
        
        long[] allResults = new long[allPaths.length];
        for (i = 0; i < allPaths.length; i++) {
            path = allPaths[i];
            allResults[i] = path.stepsTaken;
        }

        long result;
        for (Map.Entry<Integer,ArrayList<Integer>> set : lcmMap.entrySet()) {
            lcmList = set.getValue();
            
            if (lcmList.size() == allPaths.length) {
                // println("Found common denominator " + allPaths);
                continue;
            }

            found = set.getKey();

            for (i = 0; i < allPaths.length; i++) {
                path = allPaths[i];
                result = allResults[i];
                prime = 1;
                
                for (j = 0; j < path.divisibleBy.size(); j++) {
                    prime = path.divisibleBy.get(j);
                    if (prime == found) { break; }
                }

                if (prime != found) {
                    //println("Path " + i + " steps " + path.stepsTaken + "->" + result + " NOT yet divisible by " + found + ", becoming " + (r * found));
                    allResults[i] = result * found;
                // } else {
                //     println("Path " + i + " steps " + path.stepsTaken + "->" + result + " already divisible by " + found);
                }
            }
        }

        long value = 0;
        for (i = 0; i < allResults.length; i++) {
            result = allResults[i];

            if (i == 0) {
                value = result;
            } else if (result != value) {
                println("Part 2: Failed to calculate the steps required to match all " + allPaths.length +
                    " paths, might be " + result + " or " + value);

                return;
            }
        }

        println("Part 2: Steps required to to match all " + allPaths.length + " paths is: " + value);
    }

    void processPath(Day08Path path, int index, HashMap<Integer, ArrayList<Integer>> lcmMap) {
        int largestKnownPrime = Primes.getLargestPrimeKnown();
        int limit = path.stepsTaken / 2;

        int prime, found;
        boolean isDivisible;
        ArrayList<Integer> lcmList;

        if (limit > largestKnownPrime) {
            println("Step halved " + limit + " exceed largest known prime " + largestKnownPrime + ", calculating more");
            Primes.sievePrimesUpTo(limit);
        }

        found = 0;
        print("Finding primes that " + path.stepsTaken + " is divisible by: [");

        limit = Primes.getKnownPrimeCount();

        for (int i = 0; i < limit; i++) {
            prime = Primes.getKnownPrimeAt(i);
            isDivisible = path.stepsTaken % prime == 0;

            if (isDivisible) {
                path.divisibleBy.add(prime);

                if (lcmMap.containsKey(prime)) {
                    lcmList = lcmMap.get(prime);
                } else {
                    lcmList = new ArrayList<Integer>();
                    lcmMap.put(prime, lcmList);
                }
                lcmList.add(index);
                
                if (found > 0) { print(","); }
                print(prime);
                found++;
            }
        }
        println("]");
    }

    void run() {
        this.parsingData.isParsingData = true;
    }

    boolean update(int x, int y) {
        if (!super.update(x, y)) {
            return false;
        }

        return true;
    }

    void onComplete() {
        this.part1();
        this.part2();
    }

    Day08Path findGoal(String start, String goal, boolean isGoalEndsWith, long stepsLimit, long debugStep) {
        if (!this.parsingData.mapInstructions.containsKey(start)) {
            println("ERROR: Unable to find START instruction '" + start + "'");
            return null;
        }
        if (!isGoalEndsWith && !this.parsingData.mapInstructions.containsKey(goal)) {
            println("ERROR: Unable to find GOAL instruction '" + goal + "'");
            return null;
        }

        Day08MapInstruction instruction = this.parsingData.mapInstructions.get(start);
        int directionIndex = 0;

        int i;
        char turn;
        String next;
        int stepsTaken;

        for (stepsTaken = 0; stepsTaken < stepsLimit; stepsTaken++) {
            turn = this.parsingData.directions[directionIndex];
            next = this.stepFollowInstructions(turn, instruction);
            
            if (next == null) {
                println("ERROR: Unable to find instruction '" + next + "' at Step[" + stepsTaken + "] Turn[" + directionIndex + "] '" + turn + "'");
                break;
            }
            
            // println("Step[" + stepsTaken + "] Turn[" + directionIndex + "] '" + turn + "' from '" + instruction.id + "' to '" + next + "'");

            if (isGoalEndsWith ? next.endsWith(goal) : next.equals(goal)) {
                return new Day08Path(start, next, stepsTaken + 1);
            }

            instruction = this.parsingData.mapInstructions.get(next);

            if (stepsTaken > 0 && stepsTaken % debugStep == 0) {
                println("Step[" + stepsTaken + "], still no goal '" + goal + "' in sight...");
            }

            directionIndex++;
            if (directionIndex >= this.parsingData.directions.length) {
                directionIndex = 0;
            }
        }

        println("Panicking out at " + stepsTaken + " steps taken");
        return null;
    }

    // void findLeastCommonMultiple(Day08Path[] paths) {
    //     int primeLimit = 1000;
        
    //     ArrayList<Integer> primes = new ArrayList<Integer>();
    //     primes.add(2);
    //     int p = 1;

    //     for (int i = 0; i < primeLimit; i++) {
    //         p = Primes.getNextFrom(p);
    //         primes.add(p);
    //     }
    // }

    String stepFollowInstructions(char turn, Day08MapInstruction instruction) {
        String next = turn == 'L' ? instruction.left : instruction.right;

        if (!this.parsingData.mapInstructions.containsKey(next)) {
            return null;
        }

        return next;
    }

    void stepParsingInputData() {
        if (this.parsingData.inputLineIndex >= this.parsingData.input.length) {
            this.parsingData.isParsingData = false;
            return;
        }
        
        String data = this.parsingData.input[this.parsingData.inputLineIndex];
        
        if (data.length() == 0) {
            this.parsingData.inputLineIndex++;
            return;
        }

        if (!this.parsingData.isParsingInstructions) {
            this.parsingData.directions = this.parseDirections(data);
            this.parsingData.isParsingInstructions = true;
            this.parsingData.inputLineIndex++;
            return;
        }

        int linesToParse = 100;
        int i;

        for (i = 0; i < linesToParse; i++) {
            if (data.length() > 0) {
                Day08MapInstruction instruction = this.parseMapLine(data);
                this.parsingData.mapInstructions.put(instruction.id, instruction);
                this.parsingData.instructions[this.parsingData.instructionIndex] = instruction;
                this.parsingData.instructionIndex++;
                //println("Parsed instruction " + instruction.id + " -> {left:" + instruction.left + ", right:" + instruction.right + "}");
            }

            this.parsingData.inputLineIndex++;
            if (this.parsingData.inputLineIndex < this.parsingData.input.length) {
                data = this.parsingData.input[this.parsingData.inputLineIndex];
                continue;
            }
            
            this.parsingData.isParsingData = false;
            break;
        }

        println("Parsed " + i + " instructions, totaling to " + this.parsingData.instructionIndex);
    }

    char[] parseDirections(String data) {
        return data.toCharArray();
    }

    Day08MapInstruction parseMapLine(String data) {
        String[] matches = match(data, "(\\w{3}) = \\((\\w{3}), (\\w{3})\\)");
        //println("Map line '" + data + "' matched to: " + join(Arrays.copyOfRange(matches, 1, matches.length), ","));
        return new Day08MapInstruction(matches[1], matches[2], matches[3]);
    }

    void createParsingData(String[] input) {
        this.parsingData = new Day08ParsingData(input);
    }

    ParsingData getParsingData() {
        return this.parsingData;
    }

    void createVisualization(ViewRect viewRect) {}

    DayVisualBase getVisualization() {
        return null;
    }
}

class Day08ParsingData extends ParsingData {
    public char[] directions;
    public Day08MapInstruction[] instructions;
    public HashMap<String, Day08MapInstruction> mapInstructions;
    public boolean isParsingInstructions;
    public int instructionIndex;
    public String goal;

    Day08ParsingData(String[] input) {
        super(input);
        this.directions = new char[0];
        this.instructions = new Day08MapInstruction[input.length - 2];
        this.mapInstructions = new HashMap<String, Day08MapInstruction>(this.instructions.length);
        this.isParsingInstructions = false;
        this.instructionIndex = 0;
        this.goal = "";
    }
}

class Day08MapInstruction {
    public String id;
    public String left;
    public String right;

    Day08MapInstruction(String id, String left, String right) {
        this.id = id;
        this.left = left;
        this.right = right;
    }
}

class Day08Path {
    public String start;
    public String goal;
    public int stepsTaken;
    public ArrayList<Integer> divisibleBy;

    Day08Path(String start, String goal, int stepsTaken) {
        this.start = start;
        this.goal = goal;
        this.stepsTaken = stepsTaken;
        this.divisibleBy = new ArrayList<Integer>();
    }
}