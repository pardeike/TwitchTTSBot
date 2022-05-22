import NIO
import NIOIRC
import IRC

// a simple way to get posted messages
typealias MessageReceiver = (_ message: String, _ user: IRCUserID) -> Void

// delegate that gives us things happening on our client connection
class ClientDelegate: IRCClientDelegate {
	
	let verbose = false // true
	let delegate: IRCClientDelegate? // for the original delegate
	let messageReceiver: MessageReceiver? // get posted messages
	
	init(_ delegate: IRCClientDelegate?, messageReceiver: MessageReceiver?) {
		self.delegate = delegate
		self.messageReceiver = messageReceiver
	}
	
	func client(_ client: IRCClient, registered nick : IRCNickName, with userInfo : IRCUserInfo) {
		if (verbose) { print(#function, nick.stringValue) }
		delegate?.client(client, registered: nick, with: userInfo)
	}
	
	func clientFailedToRegister(_ client: IRCClient) {
		if (verbose) { print(#function) }
		delegate?.clientFailedToRegister(client)
	}
	
	func client(_ client: IRCClient, received message: IRCMessage) {
		if (verbose) { print(#function, message.command.commandAsString) }
		delegate?.client(client, received: message)
	}
	
	func client(_ client: IRCClient, messageOfTheDay: String) {
		if (verbose) { print(#function, messageOfTheDay) }
		delegate?.client(client, messageOfTheDay: messageOfTheDay)
	}
	
	func client(_ client: IRCClient, notice message: String, for recipients: [ IRCMessageRecipient ]) {
		if (verbose) { print(#function, message, recipients.map { $0.stringValue }) }
		delegate?.client(client, notice: message, for: recipients)
	}
	
	func client(_ client: IRCClient, message: String, from user: IRCUserID, for recipients: [ IRCMessageRecipient ]) {
		if (verbose) { print(#function, message, user.stringValue, recipients.map { $0.stringValue }) }
		delegate?.client(client, message: message, from: user, for: recipients)
		messageReceiver?(message, user)
	}
	
	func client(_ client: IRCClient, changedUserModeTo mode: IRCUserMode) {
		if (verbose) { print(#function, mode.stringValue) }
		delegate?.client(client, changedUserModeTo: mode)
	}
	
	func client(_ client: IRCClient, changedNickTo nick: IRCNickName) {
		if (verbose) { print(#function, nick.stringValue) }
		delegate?.client(client, changedNickTo: nick)
	}
	
	func client(_ client: IRCClient, user: IRCUserID, joined: [ IRCChannelName ]) {
		if (verbose) { print(#function, user.stringValue, joined.map { $0.stringValue }) }
		delegate?.client(client, user: user, joined: joined)
	}
	
	func client(_ client: IRCClient, user: IRCUserID, left: [ IRCChannelName ], with: String?) {
		if (verbose) { print(#function, user.stringValue, left.map { $0.stringValue }, with ?? "") }
		delegate?.client(client, user: user, left: left, with: with)
	}
	
	func client(_ client: IRCClient, changeTopic: String, of channel: IRCChannelName) {
		if (verbose) { print(#function, changeTopic, channel.stringValue) }
		delegate?.client(client, changeTopic: changeTopic, of: channel)
	}
}
