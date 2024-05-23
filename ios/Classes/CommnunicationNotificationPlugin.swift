import Intents
import UIKit
import UserNotifications

class CommunicationNotificationPlugin {
    
    func showNotification(_ notificationInfo: NotificationInfo) {
        if #available(iOS 15.0, *) {
            let uuid = UUID().uuidString
            let currentTime = Date().timeIntervalSince1970
            let identifier = "\(IosCommunicationConstant.prefixIdentifier):\(uuid):\(currentTime)"
            
            var content = UNMutableNotificationContent()
            
            content.title = notificationInfo.senderName
            content.subtitle = ""
            content.body = notificationInfo.content
            content.categoryIdentifier = identifier
            content.userInfo = ["data": notificationInfo.value]
            
            let senderThumbnail: String = notificationInfo.avatar
            
            guard let senderThumbnailUrl: URL = URL(string: senderThumbnail) else {
                return
            }
            
            let senderThumbnailFileName: String = senderThumbnailUrl.lastPathComponent // we grab the last part in the hope it contains the actual filename (any-picture.jpg)
            
            guard let senderThumbnailImageData: Data = try? Data(contentsOf: senderThumbnailUrl),
                  let senderThumbnailImageFileUrl: URL = try? downloadAttachment(data: senderThumbnailImageData, fileName: senderThumbnailFileName),
                  let senderThumbnailImageFileData: Data = try? Data(contentsOf: senderThumbnailImageFileUrl) else {
                
                return
            }
            
            var personNameComponents = PersonNameComponents()
            personNameComponents.nickname = notificationInfo.senderName
            
            let avatar = INImage(imageData: senderThumbnailImageData)
            
            let senderPerson = INPerson(
                personHandle: INPersonHandle(value: notificationInfo.value, type: .unknown),
                nameComponents: personNameComponents,
                displayName: notificationInfo.senderName,
                image: avatar,
                contactIdentifier: nil,
                customIdentifier: nil,
                isMe: false,
                suggestionType: .none
            )
            
            let mPerson = INPerson(
                personHandle: INPersonHandle(value: "", type: .unknown),
                nameComponents: nil,
                displayName: nil,
                image: nil,
                contactIdentifier: nil,
                customIdentifier: nil,
                isMe: true,
                suggestionType: .none
            )
            
            let intent = INSendMessageIntent(
                recipients: [mPerson],
                outgoingMessageType: .outgoingMessageText,
                content: content.body,
                speakableGroupName: nil,
                conversationIdentifier: notificationInfo.senderName,
                serviceName: nil,
                sender: senderPerson,
                attachments: []
            )
            
            intent.setImage(avatar, forParameterNamed: \.sender)
            
            let interaction = INInteraction(intent: intent, response: nil)
            interaction.direction = .incoming
            
            do {
                content = try content.updating(from: intent) as! UNMutableNotificationContent
            } catch {
                print("Error updating content from intent: \(error)")
            }
            
            // Bildirim isteği oluşturma
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
            
            // Aksiyonlar
            // let close = UNNotificationAction(identifier: "close", title: "Close", options: .destructive)
            // let category = UNNotificationCategory(identifier: identifier, actions: [close], intentIdentifiers: [])
            
            // UNUserNotificationCenter.current().setNotificationCategories([category])
            
            // Bildirim isteğini ekle
            UNUserNotificationCenter.current().add(request)
        }
        
        func downloadAttachment(data: Data, fileName: String) -> URL? {
            // Create a temporary file URL to write the file data to
            let fileManager = FileManager.default
            let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
            let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
            
            do {
                // prepare temp subfolder
                try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
                let fileURL: URL = tmpSubFolderURL.appendingPathComponent(fileName)
                
                // Save the image data to the local file URL
                try data.write(to: fileURL)
                
                return fileURL
            } catch let error {
                print("error \(error)")
            }
            
            return nil
        }
    }
}
