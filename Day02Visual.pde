class Day02Visual extends DayVisualPageView {
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

    private int tableX;
    private int tableY;
    private int tableWidth;
    
    private int gamesPerRow;
    private int gamesRowsPerPage;
    private int gamesPerPage;

    private Day02ParsingData parsingData;

    Day02Visual(ViewRect viewRect, Day02ParsingData parsingData) {
        super(viewRect);

        this.parsingData = parsingData;
        
        this.gamesPerRow = this.viewRect.width / this.gameCardWidth;
        this.gamesRowsPerPage = this.viewRect.height / this.gameCardHeight;
        this.gamesPerPage = this.gamesPerRow * this.gamesRowsPerPage;
        this.pageCount = this.parsingData.games.length / this.gamesPerPage +
            (this.parsingData.games.length % this.gamesPerPage > 0 ? 1 : 0);

        this.tableWidth = this.gamesPerRow * this.gameCardWidth;
        this.tableX = this.viewRect.middleX - this.tableWidth / 2;
        this.tableY = this.viewRect.y;
    }

    void draw() {
        super.draw();

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

    void update(int x, int y) {
        super.update(x, y);

        if (this.parsingData.isParsingData &&
            this.parsingData.gameIndex + 1 > (this.pageIndex + 1) * this.gamesPerPage) {
            this.pageIndex++;
        }
    }
}