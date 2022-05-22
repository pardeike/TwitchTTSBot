import NIO
import IRC
import Speech
import Combine

// usage: TwitchTTSBot CHANNEL TOKEN
// get TOKEN by logging in with chosen account and then going to https://twitchapps.com/tmi/
//
if CommandLine.arguments.count - 1 != 2  {
	print("usage: TwitchTTSBot CHANNEL TOKEN")
	exit(-1)
}

// general stuff
var subs: Set<AnyCancellable> = []
let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
var queue = DispatchQueue(label: "speak-queue", qos: .background)
var cooldownCache: [String: Date] = [:]
let cooldownInterval = TimeInterval(10)
let args = Array(CommandLine.arguments[1...])

// arguments
let channelName = args[0]
let token = args[1]

// basics
let account = IRCAccount(host: "irc.twitch.tv", nickname: channelName, serverPassword: token)
let channel = IRCChannelName("#\(channelName)")!

/*
// download more voices via System Preferences
print("Available british english premium voice identifiers:")
AVSpeechSynthesisVoice.speechVoices()
	// .filter { $0.language.contains("en-GB") && $0.identifier.hasSuffix(".premium") }
	.forEach { voice in
		print("Name: \(voice.name) Language: \(voice.language) Identifier: \(voice.identifier)")
	}
*/

// voice conf
let voice = AVSpeechSynthesisVoice(identifier: "com.apple.speech.synthesis.voice.kate.premium")
let rate = 1.5
let synth = AVSpeechSynthesizer()

// speak helper
func speak(user: String? = nil, msg: String, rate specificRate: Double? = nil) {
	queue.async {
		let str = user != nil ? "\(user!) said \(msg)" : msg
		let utterance = AVSpeechUtterance(string: str)
		utterance.voice = voice
		utterance.rate = Float(specificRate ?? rate)
		synth.speak(utterance)
		print(str)
		while (synth.isSpeaking) { usleep(500_000) }
	}
}

// message helper
func sendMessage(_ client: IRCClient, _ msg: String) {
	client.sendMessage(msg, to: IRCMessageRecipient.channel(channel))
}

// observe service state
let service = IRCService(account: account, eventLoopGroup: eventLoopGroup)
service.$state.sink { state in
	switch state {
			
		case .suspended:
			break
			
		case .offline:
			speak(msg: "Offline", rate: 2)
			
		case .connecting(_):
			speak(msg: "Connecting", rate: 2)
			
		case .online(let client):
			speak(msg: "Online", rate: 2)
			client.delegate = ClientDelegate(client.delegate!) { msg, user in
				
				if msg == "!speak" {
					sendMessage(client, "I speak your messages if you end them with an exclamation mark")
					return
				}
				if (msg.hasSuffix("!")) {
					let nick = user.nick.stringValue
					let lastUsed = cooldownCache[nick] ?? Date.distantPast
					let coolDown = lastUsed.distance(to: Date())
					if coolDown >= cooldownInterval {
						cooldownCache[nick] = Date()
						speak(user: user.nick.stringValue, msg: msg)
					} else {
						let secs = Int(cooldownInterval - coolDown + 0.99)
						sendMessage(client, "@\(nick) please wait another \(secs) second\(secs == 1 ? "" : "s")")
					}
				}
			}
			client.send(IRCCommand.JOIN(channels: [ channel ], keys: nil))
	}
}.store(in: &subs)
service.resume()

// don't end process
RunLoop.main.run()
