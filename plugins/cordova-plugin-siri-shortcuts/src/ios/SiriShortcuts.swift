import Intents
import IntentsUI
import UIKit
import MapKit
import CoreLocation
import ARKit

@objc(SiriShortcuts) class SiriShortcuts : CDVPlugin , UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    var activity: NSUserActivity?
    
    var qrCode:String!
    var command1:CDVInvokedUrlCommand!
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let qrcodeImg = info[.originalImage] as? UIImage {
            let detector:CIDetector=CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
            let ciImage:CIImage=CIImage(image:qrcodeImg)!
            var qrCodeLink=""
            
            let features=detector.features(in: ciImage)
            for feature in features as! [CIQRCodeFeature] {
                qrCodeLink += feature.messageString!
            }
            
            if qrCodeLink=="" {
                print("nothing")
            }else{
                print("message: \(qrCodeLink)")
                qrCode = qrCodeLink
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: qrCode)
                commandDelegate!.send(pluginResult, callbackId: command1.callbackId!)
            }
        }
        else{
            print("Something went wrong")
        }
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    @objc(present:) func present(_ command: CDVInvokedUrlCommand) {

        command1 = command
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        
        UIApplication.shared.keyWindow?.rootViewController?.present(imagePickerController, animated: true, completion: nil)
    
        
//        self.sendStatusOk(command)
        
    }
    
    
    @objc(remove:) func remove(_ command: CDVInvokedUrlCommand) {
        self.commandDelegate!.run(inBackground: {
            if #available(iOS 12.0, *) {
                // convert all string values to objects, such that they can be removed
                guard let stringIdentifiers = command.arguments[0] as? [String] else { return }
                var persistentIdentifiers: [NSUserActivityPersistentIdentifier] = []

                for stringIdentifier in stringIdentifiers {
                    persistentIdentifiers.append(NSUserActivityPersistentIdentifier(stringIdentifier))
                }

                NSUserActivity.deleteSavedUserActivities(withPersistentIdentifiers: persistentIdentifiers, completionHandler: {
                    self.sendStatusOk(command)
                })
            } else {
                self.sendStatusError(command)
            }
        })
    }

    @objc(removeAll:) func removeAll(_ command: CDVInvokedUrlCommand) {
        self.commandDelegate!.run(inBackground: {
            if #available(iOS 12.0, *) {
                NSUserActivity.deleteAllSavedUserActivities(completionHandler: {
                    self.sendStatusOk(command)
                })
            } else {
                self.sendStatusError(command)
            }
        })
    }

    func sendStatusOk(_ command: CDVInvokedUrlCommand) {
        self.send(status: CDVCommandStatus_OK, command: command)
    }

    func sendStatusError(_ command: CDVInvokedUrlCommand, error: String? = nil) {
        var message = error

        if message == nil {
            message = "Error while performing shortcut operation, user might not run iOS 12."
        }

        let pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: message
        )

        self.send(pluginResult: pluginResult!, command: command)
    }

    func send(status: CDVCommandStatus, command: CDVInvokedUrlCommand) {
        let pluginResult = CDVPluginResult(
            status: status
        )
        
        self.send(pluginResult: pluginResult!, command: command)
    }

    func send(pluginResult: CDVPluginResult, command: CDVInvokedUrlCommand) {
        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
    }
    
    
}






