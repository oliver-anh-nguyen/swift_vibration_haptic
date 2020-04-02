//
//  ViewController.swift
//  Vibaration
//
//  Created by Anh Nguyen on 4/1/20.
//  Copyright © 2020 Anh Nguyen. All rights reserved.
//

import UIKit
import CoreHaptics
import AudioToolbox.AudioServices

public enum SystemSound: Int, CaseIterable {
    case newMail = 1000
    case mailSent = 1001
    case voicemail = 1002
    case receivedMessage = 1003
    case sentMessage = 1004
    case alarm = 1005
    case lowPower = 1006
    case smsReceived1 = 1007
    case smsReceived2 = 1008
    case smsReceived3 = 1009
    case smsReceived4 = 1010
    case smsReceived7 = 1012
    case smsReceived5 = 1013
    case smsReceived6 = 1014
    case tweetSent = 1016
    case anticipate = 1020
    case bloom = 1021
    case calypso = 1022
    case chooChoo = 1023
    case descent = 1024
    case fanfare = 1025
    case ladder = 1026
    case minuet = 1027
    case newsFlash = 1028
    case noir = 1029
    case sherwhoodForest = 1030
    case spell = 1031
    case suspense = 1032
    case telegraph = 1033
    case tiptoes = 1034
    case typewriters = 1035
    case update = 1036
    case ussd = 1050
    case simToolkitCallDropped = 1051
    case simToolkitGeneralBeep = 1052
    case simToolkitNegativeAck = 1053
    case simToolkitPositiveAck = 1054
    case simToolkitSms = 1055
    case tinkQuiet = 1057
    case ctBusy = 1070
    case ctCongestion = 1071
    case ctPathAck = 1072
    case ctError = 1073
    case ctCallWaiting = 1074
    case ctKeyTone2 = 1075
    case lock = 1100
    case unlockFailed = 1102
    case tink = 1103
    case tock = 1104
    case beepBeep = 1106
    case ringerChanged = 1107
    case photoShutter = 1108
    case shake = 1109
    case jblBegin = 1110
    case jblConfirm = 1111
    case jblCancel = 1112
    case beginRecord = 1113
    case endRecord = 1114
    case jblAmbiguous = 1115
    case jblNoMatch = 1116
    case beginVideoRecord = 1117
    case endVideoRecord = 1118
    case vcInvitationAccepted = 1150
    case vcRinging = 1151
    case vcEnded = 1152
    case ctCallWaiting2 = 1153
    case vcRingingQuiet = 1154
    case touchTone0 = 1200
    case touchTone1 = 1201
    case touchTone2 = 1202
    case touchTone3 = 1203
    case touchTone4 = 1204
    case touchTone5 = 1205
    case touchTone6 = 1206
    case touchTone7 = 1207
    case touchTone8 = 1208
    case touchTone9 = 1209
    case touchToneStar = 1210
    case touchTonePound = 1211
    case headsetStartCall = 1254
    case headsetRedial = 1255
    case headsetAnswerCall = 1256
    case headsetEndCall = 1257
    case headsetWait = 1258
    case headsetTransitionEnd = 1259
    case tockQuiet = 1306
}


class ViewController: UIViewController {
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorColor = UIColor.gray.withAlphaComponent(0.5)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let keys: [String] = SystemSound.allCases.map { "\($0)" }
    let values: [Int] = SystemSound.allCases.map { $0.rawValue }
    
    var sections: [(title: String, options: [String])] = [
        ("Haptic (iOS 13)", ["Haptic Transient", "Haptic Continuous", "Haptic Custom"]),
        ("Taptic Basic", ["Standard Vibration", "Alert Vibration"]),
        ("Taptic Engine", ["Peek", "Pop", "Cancelled", "Try Again", "Failed"]),
        ("Haptic Feedback - Notification", ["Success", "Warning", "Error"]),
        ("Haptic Feedback - Impact", ["Light", "Medium", "Heavy", "Soft (iOS 13)", "Rigid (iOS 13)"]),
        ("Haptic Feedback - Selection", ["Selection"])
    ]
    
    let feedbackGenerator: (notification: UINotificationFeedbackGenerator, impact: (light: UIImpactFeedbackGenerator, medium: UIImpactFeedbackGenerator, heavy: UIImpactFeedbackGenerator, soft: UIImpactFeedbackGenerator, rigid: UIImpactFeedbackGenerator), selection: UISelectionFeedbackGenerator) = {
        return (notification: UINotificationFeedbackGenerator(), impact: (light: UIImpactFeedbackGenerator(style: .light), medium: UIImpactFeedbackGenerator(style: .medium), heavy: UIImpactFeedbackGenerator(style: .heavy), soft: UIImpactFeedbackGenerator(style: .soft), rigid: UIImpactFeedbackGenerator(style: .rigid)), selection: UISelectionFeedbackGenerator())
    }()
    
    var engine: CHHapticEngine?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "Vibration Example"
        
        self.sections.append(("Audio System", self.keys))
        
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        self.view.addSubview(tableView)
        
        self.initHaptic()
        
        for value in SystemSound.allCases {
            print(value)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        feedbackGenerator.selection.prepare()
        feedbackGenerator.notification.prepare()
        feedbackGenerator.impact.light.prepare()
        feedbackGenerator.impact.medium.prepare()
        feedbackGenerator.impact.heavy.prepare()
        feedbackGenerator.impact.soft.prepare()
        feedbackGenerator.impact.rigid.prepare()
    }

    func initHaptic() {
        // check device support
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }

    func destroyHaptics() {
        // The engine stopped; print out why
        engine?.stoppedHandler = { reason in
            print("The engine stopped: \(reason)")
        }

        // If something goes wrong, attempt to restart the engine immediately
        engine?.resetHandler = { [weak self] in
            print("The engine reset")

            do {
                try self?.engine?.start()
            } catch {
                print("Failed to restart the engine: \(error)")
            }
        }
    }
    
    deinit {
        self.destroyHaptics()
    }
    
    func playHaptic(event: CHHapticEvent) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = sections[section].title
        return title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.text = sections[indexPath.section].options[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let hapticTransient = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0)
                self.playHaptic(event: hapticTransient)
                break
            case 1:
                let hapticContinuous = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 0, duration: 1)
                self.playHaptic(event: hapticContinuous)
                break
            case 2:
                let intensity = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5) // The feel of  haptic event, from dull to sharp
                let sharpness = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5) // How strong the haptic is
                // Some advanced parameters
                let attackTime = CHHapticEventParameter(parameterID: .attackTime, value: 0.5) // When to increase the intensity of the haptic.
                let decayTime = CHHapticEventParameter(parameterID: .decayTime, value: 0.5) // When the intensity of the haptic goes down.
                let releaseTime = CHHapticEventParameter(parameterID: .releaseTime, value: 0.5) // If you want the haptic to "fade", when
                let sustainTime = CHHapticEventParameter(parameterID: .sustained, value: 0.5) // If you want to sustain the haptic for its entire duration.

                let hapticCustom = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness, attackTime, decayTime, releaseTime, sustainTime], relativeTime: 0, duration: 1)
                self.playHaptic(event: hapticCustom)
                break
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                // Standard vibration
                let standard = SystemSoundID(kSystemSoundID_Vibrate) // 4095
                AudioServicesPlaySystemSoundWithCompletion(standard, {
                    print("did standard vibrate")
                })
            case 1:
                // Alert vibration
                let alert = SystemSoundID(1011)
                AudioServicesPlaySystemSoundWithCompletion(alert, {
                    print("did alert vibrate")
                })
            default:
                break
            }
        case 2:
            switch indexPath.row {
            case 0:
                // Peek
                let peek = SystemSoundID(1519)
                AudioServicesPlaySystemSoundWithCompletion(peek, {
                    print("did peek")
                })
            case 1:
                // Pop
                let pop = SystemSoundID(1520)
                AudioServicesPlaySystemSoundWithCompletion(pop, {
                    print("did pop")
                })
            case 2:
                // Cancelled
                let cancelled = SystemSoundID(1521)
                AudioServicesPlaySystemSoundWithCompletion(cancelled, {
                    print("did cancelled")
                })
            case 3:
                // Try Again
                let tryAgain = SystemSoundID(1102)
                AudioServicesPlaySystemSoundWithCompletion(tryAgain, {
                    print("did try again")
                })
            case 4:
                // Failed
                let failed = SystemSoundID(1107)
                AudioServicesPlaySystemSoundWithCompletion(failed, {
                    print("did failed")
                })
            default:
                break
            }
        case 3:
            // UINotificationFeedbackGenerator
            switch indexPath.row {
            case 0:
                // Success
                feedbackGenerator.notification.notificationOccurred(.success)
            case 1:
                // Warning
                feedbackGenerator.notification.notificationOccurred(.warning)
            case 2:
                // Error
                feedbackGenerator.notification.notificationOccurred(.error)
            default:
                break
            }
        case 4:
            // UIImpactFeedbackGenerator
            switch indexPath.row {
            case 0:
                // Light
                feedbackGenerator.impact.light.impactOccurred()
            case 1:
                // Medium
                feedbackGenerator.impact.medium.impactOccurred()
            case 2:
                // Heavy
                feedbackGenerator.impact.heavy.impactOccurred()
            case 3:
                // Soft
                feedbackGenerator.impact.soft.impactOccurred()
            case 4:
                // Rigid
                feedbackGenerator.impact.rigid.impactOccurred()
            default:
                break
            }
        case 5:
            // UISelectionFeedbackGenerator
            switch indexPath.row {
            case 0:
                // Selection
                feedbackGenerator.selection.selectionChanged()
            default:
                break
            }
        case 6:
            let value = self.values[indexPath.row]
            AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(value)) {
                print("did failed")
            }
            break
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}


