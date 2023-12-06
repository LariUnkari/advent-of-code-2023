import java.util.Map;

class Day04 extends DayBase {
    private Day04ParsingData parsingData;
    private Day04Visual visualization;

    private boolean isCheckingMatches;
    private boolean isCheckingWins;

    Day04() {
        super();
        this.isImplemented = true;
        this.isCheckingMatches = false;
        this.isCheckingWins = false;
    }

    void part1() {
        int sum = 0;

        Day04Card card;
        for (int i = 0; i < this.parsingData.cards.length; i++) {
            card = this.parsingData.cards[i];
            sum += card.points;
        }

        println("Part 1: sum of card points is " + sum);
    }

    void part2() {
        int sum = 0;

        Day04Card card;
        for (int i = 0; i < this.parsingData.cards.length; i++) {
            card = this.parsingData.cards[i];
            sum += card.copies;
        }

        println("Part 2: sum of cards and their copies is " + sum);
    }

    void run() {
        this.parsingData.isParsingData = true;
    }

    void onComplete() {
        this.part1();
        this.part2();
    }

    boolean update(int x, int y) {
        if (!super.update(x, y)) {
            return false;
        }

        if (this.isCheckingMatches) {
            this.stepCheckMatches();
            return false;
        }

        if (this.isCheckingWins) {
            this.stepCheckWinChains();
            return false;
        }

        return true;
    }

    void stepCheckMatches() {
        if (this.parsingData.cardIndex >= this.parsingData.cards.length) {
            println("Finished checking matching numbers");
            this.parsingData.cardIndex = 0;
            this.isCheckingMatches = false;
            this.isCheckingWins = true;
            return;
        }

        Day04Card card = this.parsingData.cards[this.parsingData.cardIndex];
        card.checkMatches();
        println("Card " + card.id + " winCount: " + card.winCount + ", points: " + card.points);

        this.parsingData.cardIndex++;
    }

    void stepCheckWinChains() {
        if (this.parsingData.cardIndex >= this.parsingData.cards.length) {
            println("Finished checking winning card chains");
            this.isCheckingWins = false;
            return;
        }

        Day04Card card = this.parsingData.cards[this.parsingData.cardIndex];

        if (card.winCount > 0) {
            int endIndex = min(this.parsingData.cardIndex + card.winCount, this.parsingData.cards.length);

            Day04Card copyCard;
            for (int i = this.parsingData.cardIndex + 1; i <= endIndex; i++) {
                copyCard = this.parsingData.cards[i];
                copyCard.copies += card.copies;
                println("Card " + card.id + " added " + card.copies + " copies of card " + (i + 1) + ", totaling to " + copyCard.copies);
            }
        }
        
        this.parsingData.cardIndex++;
    }

    void stepParsingInputData() {
        int cardsParsed = 0;
        while (cardsParsed < 10) {
            if (this.parsingData.inputLineIndex >= this.parsingData.inputLineCount) {
                println("Finished parsing input data");
                this.parsingData.isParsingData = false;
                this.isCheckingMatches = true;
                //this.pageIndex = 0;
                return;
            }
            
            this.parsingData.cards[this.parsingData.inputLineIndex] = this.parseCard(this.parsingData.input[this.parsingData.inputLineIndex]);
            this.parsingData.cardCount++;
            this.parsingData.inputLineIndex++;
            cardsParsed++;
        }
    }

    Day04Card parseCard(String data) {
        String[] cardData = match(data, "Card\\s+(\\d+):\\s+(.*)");

        if (cardData == null) {
            return null;
        }

        int id = Integer.parseInt(cardData[1]);
        String[] numberData = split(cardData[2], " | ");
        String[] setNums = this.parseNumbers(numberData[0]);
        String[] winNums = this.parseNumbers(numberData[1]);

        println("Parsed card " + id + ", win:[" + join(setNums, ",") + "], set:[" + join(winNums, ",") + "]");

        return new Day04Card(id, int(setNums), int(winNums));
    }

    String[] parseNumbers(String data) {
        String[] numbers;
        String[][] matches = matchAll(data, "\\d+");

        if (matches == null) {
            return new String[0];
        }

        numbers = new String[matches.length];
        for (int i = 0; i < matches.length; i++) {
            numbers[i] = matches[i][0];
        }
        
        return numbers;
    }

    void createParsingData(String[] input) {
        this.parsingData = new Day04ParsingData(input);
    }

    ParsingData getParsingData() {
        return this.parsingData;
    }

    void createVisualization(ViewRect viewRect) {
        this.visualization = new Day04Visual(viewRect, this.parsingData);
    }

    DayVisualBase getVisualization() {
        return this.visualization;
    }
}

class Day04ParsingData extends ParsingData {
    public Day04Card[] cards;
    public int cardCount;
    public int cardIndex;

    Day04ParsingData(String[] input) {
        super(input);
        this.cards = new Day04Card[this.inputLineCount];
        this.cardCount = 0;
        this.cardIndex = 0;
    }
}

class Day04Card {
    public int id;
    public int[] setNumbers;
    public int[] winNumbers;

    public HashMap<Integer, Integer> matches;
    public int winCount;
    public int points;
    public int copies;

    Day04Card(int id, int[] setNumbers, int[] winNumbers) {
        this.id = id;
        this.setNumbers = setNumbers;
        this.winNumbers = winNumbers;
        this.matches = new HashMap<Integer, Integer>();
        this.winCount = 0;
        this.points = 0;
        this.copies = 1;
    }

    void checkMatches() {
        int key;

        for (int i = 0; i < this.winNumbers.length; i++) {
            this.matches.put(this.winNumbers[i], 0);
        }

        for (int j = 0; j < this.setNumbers.length; j++) {
            key = this.setNumbers[j];

            if (this.matches.containsKey(key)) {
                this.matches.put(key, 1);
                this.winCount++;
            }
        }

        this.points = round(pow(2, this.winCount - 1));
    }
}