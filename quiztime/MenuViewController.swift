//
//  MenuViewController.swift
//  quiztime
//
//  Created by Clement Gan on 24/12/2024.
//

import UIKit

// Enum for Game Modes
enum GameMode {
    case timed
    case endless
}

class MenuViewController: UIViewController {

    // UI Elements
    var logoImageView: UIImageView!
    var startGameButton: UIButton!
    var scoreHistoryButton: UIButton!
    var gameModeButton: UIButton!
    
    // Variable to store selected game mode
    var selectedGameMode: GameMode = .timed

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // Setup the UI components for the Menu Screen
    func setupUI() {
        // Background image for the menu screen
        let backgroundImage = UIImageView(image: UIImage(named: "background_game"))
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.frame = view.bounds
        backgroundImage.alpha = 0.3
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)

        // Logo Image (centered)
        logoImageView = UIImageView(image: UIImage(named: "image_logo_menu"))
        logoImageView.frame = CGRect(x: (view.frame.width - 300) / 2, y: 100, width: 300, height: 300)
        logoImageView.contentMode = .scaleAspectFit
        view.addSubview(logoImageView)

        // Start Game Button (lower down on the screen)
        startGameButton = UIButton(type: .system)
        startGameButton.setTitle("Start Game", for: .normal)
        startGameButton.frame = CGRect(x: (view.frame.width - 300) / 2, y: logoImageView.frame.maxY + 120, width: 300, height: 50)
        startGameButton.layer.cornerRadius = 25
        startGameButton.layer.borderWidth = 2
        startGameButton.layer.borderColor = UIColor.white.cgColor
        startGameButton.setTitleColor(.white, for: .normal)
        startGameButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        startGameButton.addTarget(self, action: #selector(startGameTapped), for: .touchUpInside)
        view.addSubview(startGameButton)

        // Score History Button (lower down on the screen)
        scoreHistoryButton = UIButton(type: .system)
        scoreHistoryButton.setTitle("Score History", for: .normal)
        scoreHistoryButton.frame = CGRect(x: (view.frame.width - 300) / 2, y: startGameButton.frame.maxY + 10, width: 300, height: 50)
        scoreHistoryButton.layer.cornerRadius = 25
        scoreHistoryButton.layer.borderWidth = 2
        scoreHistoryButton.layer.borderColor = UIColor.white.cgColor
        scoreHistoryButton.setTitleColor(.white, for: .normal)
        scoreHistoryButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        scoreHistoryButton.addTarget(self, action: #selector(showScoreHistory), for: .touchUpInside)
        view.addSubview(scoreHistoryButton)

        // Game Mode Button (lower down on the screen)
        gameModeButton = UIButton(type: .system)
        gameModeButton.setTitle("Select Game Mode", for: .normal)
        gameModeButton.frame = CGRect(x: (view.frame.width - 300) / 2, y: view.frame.height - 100, width: 300, height: 50)
        gameModeButton.layer.cornerRadius = 25
        gameModeButton.layer.borderWidth = 2
        gameModeButton.layer.borderColor = UIColor.white.cgColor
        gameModeButton.setTitleColor(.white, for: .normal)
        gameModeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        gameModeButton.addTarget(self, action: #selector(showGameModeSelection), for: .touchUpInside)
        view.addSubview(gameModeButton)
    }

    // Start Game Button action
    @objc func startGameTapped() {
        // Pass the selected game mode to the game screen
        let gameVC = EmojiGuessingViewController(gameMode: selectedGameMode)
        self.navigationController?.pushViewController(gameVC, animated: true)
    }

    // Show Score History action
    @objc func showScoreHistory() {
        // Retrieve score history from UserDefaults
        let history = UserDefaults.standard.array(forKey: "scoreHistory") as? [[String: Any]] ?? []
        var historyText = "Score History:\n\n"
        for entry in history {
            if let score = entry["score"] as? Int, let time = entry["time"] as? Int {
                historyText += "Score: \(score), Time: \(time)s\n"
            }
        }

        // Show the history in an alert
        let alert = UIAlertController(title: "Score History", message: historyText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // Show Game Mode Selection
    @objc func showGameModeSelection() {
        let alert = UIAlertController(title: "Select Game Mode", message: "Choose your preferred game mode", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Timed Mode", style: .default, handler: { _ in
            self.selectedGameMode = .timed
        }))
        alert.addAction(UIAlertAction(title: "Endless Mode", style: .default, handler: { _ in
            self.selectedGameMode = .endless
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
