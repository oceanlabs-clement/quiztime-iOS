//
//  ViewController.swift
//  quiztime
//
//  Created by Clement Gan on 24/12/2024.
//

import UIKit

class EmojiGuessingViewController: UIViewController {

    // Define categories
    let categories: [String: [(emoji: String, hint: String)]] = [
        "Fruits": [
            ("🍎", "A red or green fruit, often used for pies"),
            ("🍌", "A long, yellow fruit, often eaten as a snack"),
            ("🍍", "A tropical fruit with a spiky skin"),
            ("🍓", "A small red fruit with tiny seeds on the outside"),
            ("🍇", "A bunch of small, round, purple fruits"),
            ("🍊", "An orange citrus fruit"),
            ("🍒", "A small, round, red fruit"),
            ("🍑", "A sweet fruit with a fuzzy skin"),
        ],
        "Foods": [
            ("🍕", "A dish made of a flat dough base topped with cheese, tomatoes, and other ingredients"),
            ("🍔", "A sandwich consisting of a cooked patty, usually made from beef"),
            ("🍣", "A Japanese dish consisting of vinegared rice and raw fish"),
            ("🍦", "A sweet frozen dessert, often served in a cone"),
            ("🍩", "A fried dough pastry, often ring-shaped, with a hole in the center"),
            ("🍪", "A sweet baked treat, often with chocolate chips"),
            ("🌮", "A Mexican dish with a folded tortilla and various fillings"),
            ("🥗", "A healthy meal made of vegetables"),
        ],
        "Sports": [
            ("⚽", "A ball game played by two teams of eleven players each"),
            ("🏀", "A game where players try to score by shooting a ball through a hoop"),
            ("🏈", "A team sport played with an oval-shaped ball"),
            ("🏓", "A game played on a table where players hit a ball back and forth with paddles"),
            ("🏸", "A sport played with a shuttlecock and rackets"),
            ("🥍", "A team sport with a ball and a long-handled stick"),
            ("🎾", "A sport where players hit a ball over a net with rackets"),
            ("🏌️‍♂️", "A sport where players hit a ball into a hole using clubs"),
        ]
    ]

    // Variables
    var score = 0
    var currentQuestionIndex = 0
    var currentCategory: String = "Fruits"
    var timerValue = 40
    var timer: Timer?
    var gameMode: GameMode = .timed  // Default game mode is timed
    
    // UI Elements
    var hintLabel: UILabel!
    var scoreLabel: UILabel!
    var timerLabel: UILabel!
    var emojiButtons: [UIButton] = []
    var resultLabel: UILabel!
    var quitButton: UIButton!

    // Initializer to accept the gameMode from MenuViewController
    init(gameMode: GameMode) {
        self.gameMode = gameMode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadQuestion()
        navigationItem.hidesBackButton = true  // Hide back button on game screen
        
        if self.gameMode != .endless  {
            startTimer() // Start the timer when the game loads
        }
    }

    // Setup UI
    func setupUI() {
        // Background image for the game screen
        let backgroundImage = UIImageView(image: UIImage(named: "background_game"))
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.frame = view.bounds
        backgroundImage.alpha = 0.3
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)

        // Score label (top-left, larger and bold)
        scoreLabel = UILabel()
        scoreLabel.text = "Score: 0"
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 32)  // Bigger and bold
        scoreLabel.textColor = .white
        scoreLabel.textAlignment = .left
        scoreLabel.frame = CGRect(x: 20, y: 60, width: view.frame.width, height: 40)
        view.addSubview(scoreLabel)

        // Timer label (top-right, larger and bold)
        timerLabel = UILabel()
        timerLabel.text = "Time: 30"
        timerLabel.font = UIFont.boldSystemFont(ofSize: 32)  // Bigger and bold
        timerLabel.textColor = .white
        timerLabel.textAlignment = .right
        timerLabel.frame = CGRect(x: view.frame.width - 160, y: 60, width: 140, height: 40)
        view.addSubview(timerLabel)

        // Hint label (multi-line support)
        hintLabel = UILabel()
        hintLabel.text = "Guess the emoji!"
        hintLabel.font = UIFont.boldSystemFont(ofSize: 24)  // Bigger and bold
        hintLabel.textColor = .white
        hintLabel.textAlignment = .center
        hintLabel.numberOfLines = 0  // Allows multiple lines
        hintLabel.lineBreakMode = .byWordWrapping
        hintLabel.frame = CGRect(x: 20, y: timerLabel.frame.maxY + 30, width: view.frame.width - 40, height: 80)
        view.addSubview(hintLabel)

        // Result label (feedback after each guess)
        resultLabel = UILabel()
        resultLabel.text = ""
        resultLabel.font = UIFont.boldSystemFont(ofSize: 24)
        resultLabel.textColor = .white
        resultLabel.textAlignment = .center
        resultLabel.frame = CGRect(x: 0, y: hintLabel.frame.maxY + 20, width: view.frame.width, height: 40)
        view.addSubview(resultLabel)

        // Emoji buttons (Multiple choices)
        let buttonWidth: CGFloat = 120
        let buttonHeight: CGFloat = 120
        let padding: CGFloat = 20

        for i in 0..<4 {
            let button = UIButton(type: .system)
            let row = i / 2
            let col = i % 2

            button.frame = CGRect(x: CGFloat(col) * (buttonWidth + padding) + (view.frame.width - 2 * (buttonWidth + padding)) / 2,
                                  y: CGFloat(row) * (buttonHeight + padding) + resultLabel.frame.maxY + 30,
                                  width: buttonWidth, height: buttonHeight)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 40)
            button.tag = i
            button.addTarget(self, action: #selector(emojiButtonTapped(_:)), for: .touchUpInside)

            // Apply rounded style
            button.layer.cornerRadius = 15
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.2
            button.layer.shadowOffset = CGSize(width: 3, height: 3)
            button.layer.shadowRadius = 5
            button.clipsToBounds = true

            // Gradient background for answer buttons
            applyGradient(to: button)

            view.addSubview(button)
            emojiButtons.append(button)
        }

        // Quit button at the bottom center of the game screen
        quitButton = UIButton(type: .system)
        quitButton.setTitle("Quit", for: .normal)
        quitButton.frame = CGRect(x: 0, y: view.frame.height - 120, width: 200, height: 50)
        quitButton.center.x = view.center.x
        quitButton.layer.cornerRadius = 25
        quitButton.layer.borderWidth = 2
        quitButton.layer.borderColor = UIColor.white.cgColor
        quitButton.setTitleColor(.white, for: .normal)
        quitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)  // Increased font size
        quitButton.addTarget(self, action: #selector(quitButtonTapped), for: .touchUpInside)
        view.addSubview(quitButton)
    }

    // Apply gradient to answer button
    func applyGradient(to button: UIButton) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = button.bounds
        gradientLayer.colors = [
            UIColor.red.cgColor,
            UIColor.orange.cgColor,
            UIColor.yellow.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        button.layer.insertSublayer(gradientLayer, at: 0)
    }

    // Load a new question
    func loadQuestion() {
        resultLabel.text = ""
        
        currentCategory = ["Fruits", "Foods", "Sports"].shuffled().first ?? "Fruits"
        let currentCategoryQuestions = categories[currentCategory]!

        // Get the current hint and correct emoji
        let (correctEmoji, hint) = currentCategoryQuestions[currentQuestionIndex]

        // Set the hint label
        hintLabel.text = hint

        // Get all emojis for this category
        var allEmojis = currentCategoryQuestions.map { $0.emoji }

        // Ensure that the correct emoji is included
        var choices = [correctEmoji]

        // Remove the correct emoji from the options to avoid duplicates
        allEmojis.removeAll { $0 == correctEmoji }

        // Pick 3 random emojis from the list (excluding the correct one)
        let randomEmojis = allEmojis.shuffled().prefix(3)

        // Add the random emojis to the choices
        choices.append(contentsOf: randomEmojis)

        // Shuffle the final choices so the correct one is not always in the same position
        choices.shuffle()

        // Set the emojis on the buttons
        for (index, emoji) in emojiButtons.enumerated() {
            emoji.setTitle(choices[index], for: .normal)
        }
    }

    // Emoji button tapped
    @objc func emojiButtonTapped(_ sender: UIButton) {
        // Get the tapped emoji
        let selectedEmoji = sender.title(for: .normal)!

        // Check if the selected emoji is correct
        let correctEmoji = categories[currentCategory]![currentQuestionIndex].emoji

        // Provide feedback
        if selectedEmoji == correctEmoji {
            resultLabel.text = "Correct!"
            score += 10
        } else {
            resultLabel.text = "Wrong! The correct emoji is \(correctEmoji)"
        }

        // Update score
        scoreLabel.text = "Score: \(score)"

        // Move to next question
        currentQuestionIndex += 1

        if currentQuestionIndex < categories[currentCategory]!.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.loadQuestion()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showGameOver()
            }
        }
    }

    // Start the timer
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    // Update the timer
    @objc func updateTimer() {
        timerValue -= 1
        timerLabel.text = "Time: \(timerValue)"

        if timerValue <= 0 {
            timer?.invalidate()
            showGameOver()
        }
    }

    // Show Game Over screen
    func showGameOver() {
        let alert = UIAlertController(title: "Game Over", message: "Your final score is \(score). Time: \(40 - timerValue)s", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Play Again", style: .default, handler: { _ in
            self.resetGame()
        }))
        present(alert, animated: true, completion: nil)
    }

    // Reset the game
    func resetGame() {
        score = 0
        currentQuestionIndex = 0
        timerValue = 40
        scoreLabel.text = "Score: \(score)"
        timerLabel.text = "Time: \(timerValue)"
        loadQuestion()
        
        if self.gameMode != .endless {
            startTimer()
        }
    }

    // Quit Button Tapped
    @objc func quitButtonTapped() {
        let alert = UIAlertController(title: "Are you sure you want to quit?", message: "You will lose your progress if you exit.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Exit", style: .destructive, handler: { _ in
            if self.gameMode != .endless { self.saveGameData() }
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }

    // Save the game data
    func saveGameData() {
        // Save the score and time to UserDefaults
        let finalScore = score
        let finalTime = 40 - timerValue
        let history = UserDefaults.standard.array(forKey: "scoreHistory") as? [[String: Any]] ?? []
        let newHistory = ["score": finalScore, "time": finalTime] as [String: Any]
        let updatedHistory = history + [newHistory]
        UserDefaults.standard.set(updatedHistory, forKey: "scoreHistory")
    }

    // Show Score History
    @objc func showScoreHistory() {
        let history = UserDefaults.standard.array(forKey: "scoreHistory") as? [[String: Any]] ?? []
        var historyText = "Score History:\n\n"
        for entry in history {
            if let score = entry["score"] as? Int, let time = entry["time"] as? Int {
                historyText += "Score: \(score), Time: \(time)s\n"
            }
        }

        let alert = UIAlertController(title: "Score History", message: historyText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
