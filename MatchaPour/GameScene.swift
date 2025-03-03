import SpriteKit

class GameScene: SKScene {

    private var teapot: SKSpriteNode!
    private var cup: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    private var gameOverLabel: SKLabelNode?
    private var tapToRestartLabel: SKLabelNode?
    private var startLabel: SKLabelNode?
    private var progressBar: SKShapeNode!  // New progress bar
    private var steamEmitter: SKEmitterNode?


    private var isPouring = false
    private var teaHeight: CGFloat = 0.0
    private let maxTeaHeight: CGFloat = 100.0

    private var score = 0
    private var pourSuccessful = false
    private var isGameOver = false
    private var isGameStarted = false

    override func didMove(to view: SKView) {
        showStartScreen()
    }

    private func showStartScreen() {
        removeAllChildren()
        isGameStarted = false
        isGameOver = false

        self.backgroundColor = SKColor(red: 0.9, green: 0.9, blue: 0.8, alpha: 1.0)

        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.fontSize = 48
        titleLabel.fontColor = .darkGray
        titleLabel.text = "Matcha Pour"
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 50)
        titleLabel.horizontalAlignmentMode = .center
        addChild(titleLabel)

        startLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        startLabel?.fontSize = 28
        startLabel?.fontColor = .darkGray
        startLabel?.text = "Tap to Start"
        startLabel?.position = CGPoint(x: size.width / 2, y: size.height / 2 - 20)
        startLabel?.horizontalAlignmentMode = .center
        addChild(startLabel!)
    }

    private func setupGame() {
        removeAllChildren()
        isGameOver = false
        score = 0
        teaHeight = 0

        self.backgroundColor = SKColor(red: 0.9, green: 0.9, blue: 0.8, alpha: 1.0)

        // Teapot setup
        teapot = SKSpriteNode(imageNamed: "teapot")
        teapot.position = CGPoint(x: size.width / 2, y: size.height - 150)
        teapot.setScale(0.2)
        addChild(teapot)

        // Cup setup
        cup = SKSpriteNode(imageNamed: "cup")
        cup.position = CGPoint(x: size.width / 2, y: 150)
        cup.setScale(0.2)
        addChild(cup)
        if let steam = SKEmitterNode(fileNamed: "SteamParticle.sks") {
            steam.position = CGPoint(x: cup.position.x, y: cup.position.y + 30)
            steam.particleAlpha = 0 // Start invisible
            addChild(steam)
            steamEmitter = steam
        }


        // Score label
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.fontSize = 25
        scoreLabel.fontColor = .darkGray
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 180)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)

        // Progress bar (on left side)
        let barWidth: CGFloat = 20
        let barHeight: CGFloat = maxTeaHeight + 20

        progressBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 10)
        progressBar.fillColor = SKColor(red: 0.7, green: 0.9, blue: 0.7, alpha: 1.0) // Matcha green
        progressBar.strokeColor = .clear
        progressBar.position = CGPoint(x: 30, y: cup.position.y)
        progressBar.setScale(1) // Ensure correct initial size
        progressBar.yScale = 0 // Start empty
        addChild(progressBar)

        // Goal line inside progress bar
        let goalLine = SKShapeNode(rectOf: CGSize(width: 20, height: 2))
        goalLine.fillColor = .red  // Color for the goal line
        goalLine.position = CGPoint(x: 0, y: maxTeaHeight / 2 - 10) // Position it near the top of the bar
        progressBar.addChild(goalLine)
    }



    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isGameStarted {
            isGameStarted = true
            setupGame()
            return
        }

        if isGameOver {
            setupGame()
            return
        }

        isPouring = true
        pourSuccessful = true

        run(SKAction.playSoundFileNamed("pourStartSoft.wav", waitForCompletion: false))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver || !isGameStarted { return }

        isPouring = false

        run(SKAction.playSoundFileNamed("pourStopSoft.wav", waitForCompletion: false))

        if pourSuccessful && teaHeight > 0 && teaHeight < maxTeaHeight {
            score += 1
            updateScoreLabel()
            resetCup()
        }
    }

    override func update(_ currentTime: TimeInterval) {
        if isGameOver || !isGameStarted { return }

        if isPouring {
            teaHeight += 1
            if teaHeight >= maxTeaHeight {
                teaHeight = maxTeaHeight
                gameOver()
            }
        } else {
            teaHeight -= 0.5
            if teaHeight < 0 {
                teaHeight = 0
            }
        }


        let fillPercentage = teaHeight / maxTeaHeight
        if fillPercentage >= 0.8 {
            steamEmitter?.particleAlpha = 1 // Show steam
        } else {
            steamEmitter?.particleAlpha = 0 // Hide steam
        }
        

        // Update progress bar
        progressBar.yScale = fillPercentage
    }

    private func updateScoreLabel() {
        scoreLabel.text = "Score: \(score)"
    }

    private func resetCup() {
        teaHeight = 0
        progressBar.yScale = 0
    }

    private func gameOver() {
        isGameOver = true

        gameOverLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gameOverLabel?.fontSize = 30
        gameOverLabel?.fontColor = .red
        gameOverLabel?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gameOverLabel?.horizontalAlignmentMode = .center
        gameOverLabel?.text = "Game Over! Score: \(score)"
        gameOverLabel?.alpha = 0
        addChild(gameOverLabel!)

        gameOverLabel?.run(SKAction.fadeIn(withDuration: 0.5))

        tapToRestartLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        tapToRestartLabel?.fontSize = 24
        tapToRestartLabel?.fontColor = .darkGray
        tapToRestartLabel?.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        tapToRestartLabel?.horizontalAlignmentMode = .center
        tapToRestartLabel?.text = "Tap to restart"
        tapToRestartLabel?.alpha = 0
        addChild(tapToRestartLabel!)

        tapToRestartLabel?.run(SKAction.fadeIn(withDuration: 0.5))

        // Gentle shake effect for all game objects
        let shakeAmount: CGFloat = 10
        let shakeDuration = 0.05

        let moveRight = SKAction.moveBy(x: shakeAmount, y: 0, duration: shakeDuration)
        let moveLeft = SKAction.moveBy(x: -shakeAmount, y: 0, duration: shakeDuration)

        let shakeSequence = SKAction.sequence([
            moveRight, moveLeft, moveRight, moveLeft
        ])

        // Apply shake to key game objects
        teapot.run(shakeSequence)
        cup.run(shakeSequence)
        scoreLabel.run(shakeSequence)
        gameOverLabel?.run(shakeSequence)
        tapToRestartLabel?.run(shakeSequence)
        progressBar.run(shakeSequence)
    }

}
