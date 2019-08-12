import Intents
import IntentsUI
import UIKit
import MapKit
import CoreLocation
import ARKit

@objc(SiriShortcuts) class SiriShortcuts : CDVPlugin , UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var qrCode:String!
    var command1:CDVInvokedUrlCommand!
    var command2:CDVInvokedUrlCommand!
    var qrCodeLink = ""
    var i:Int!
    var qrCodeCIImage:CIImage!
    var qrcodeImg:UIImage!
    //    var base64String = ""
    func convertImageToBase64(image: UIImage) -> String {
        let imageData:NSData = image.pngData()! as NSData
        let imageStr = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        return imageStr
    }
    
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage! {
        let context = CIContext(options: nil)
        if context != nil {
            return context.createCGImage(inputImage, from: inputImage.extent)
        }
        return nil
    }
    
    func createQRCode(data:String){
        let data = data.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("H", forKey: "inputCorrectionLevel")
        qrCodeCIImage = filter?.outputImage
        
        let bottomImage = UIImage(ciImage: qrCodeCIImage)
        let topImage = UIImage(named: "maruhan-icon")
        
        let topImageSize = CGSize(width: 56, height: 56)
        let bottomImageSize = CGSize(width: 320, height: 320)// set this to what you need
        UIGraphicsBeginImageContextWithOptions(bottomImageSize, false, 0.0)
        
        bottomImage.draw(in: CGRect(origin: CGPoint(x: 0,y :0), size: bottomImageSize))
        topImage!.draw(in: CGRect(origin: CGPoint(x: bottomImageSize.width/2 - topImageSize.width/2,y :bottomImageSize.height/2 - topImageSize.height/2), size: topImageSize))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //        let cgImage = convertCIImageToCGImage(inputImage: ciImage!)
        let str = convertImageToBase64(image: newImage!)
        
//        UIImageWriteToSavedPhotosAlbum(newImage!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: str)
        commandDelegate!.send(pluginResult, callbackId: command1.callbackId!)
        
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            //            showAlertWith(title: "Save error", message: error.localizedDescription)
        } else {
            //            showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }
    
    //    func showAlertWith(title: String, message: String){
    //        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
    //        ac.addAction(UIAlertAction(title: "OK", style: .default))
    //        UIApplication.shared.keyWindow?.rootViewController?.present(ac, animated: true, completion: nil)
    //    }
    
    
    //    func createQRCode(data:String){
    //        let data = data.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
    //        let filter = CIFilter(name: "CIQRCodeGenerator")
    //        filter?.setValue(data, forKey: "inputMessage")
    //        filter?.setValue("H", forKey: "inputCorrectionLevel")
    //        qrCodeCIImage = filter?.outputImage
    //        let ciImage = qrImage(logo: UIImage(named: "output-onlinepngtools"))
    //
    //        //Use image name from bundle to create NSData
    //        let cgImage = convertCIImageToCGImage(inputImage: ciImage!)
    //        let str = convertImageToBase64(image: UIImage(cgImage: cgImage!))
    //
    ////        readQRCode(ciImage: ciImage!)
    //        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: str)
    //        commandDelegate!.send(pluginResult, callbackId: command1.callbackId!)
    //
    //    }
    
    func qrImage( logo: UIImage? = nil) -> CIImage? {
        let tintedQRImage = qrCodeCIImage
        //        let logo1 = logo?.cgImage
        return tintedQRImage?.combined(with: CIImage(image: logo!)!)
    }
    
    
    func readQRCode(ciImage:CIImage){
        i+=1
        
        var options: [String: Any]
        let context = CIContext()
        options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let detector:CIDetector=CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)!
        
        if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)){
            options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
        }else {
            options = [CIDetectorImageOrientation: 1]
        }
        
        let features=detector.features(in: ciImage)
        
        for feature in features as! [CIQRCodeFeature] {
            qrCodeLink += feature.messageString!
        }
        
        if qrCodeLink=="" {
            if i < 2{
                let ciImage = CIImage(image: qrcodeImg.noir!)
                readQRCode(ciImage: ciImage!)
            }
        }else{
            print("message: \(qrCodeLink)")
            qrCode = qrCodeLink
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: qrCode)
            commandDelegate!.send(pluginResult, callbackId: command2.callbackId!)
        }
        
    }
    
    
    @objc(generateqrcode:) func generateqrcode(_ command: CDVInvokedUrlCommand) {
        qrCodeLink = ""
        command1 = command
        createQRCode(data: command.arguments[0] as! String)
        
        //  self.sendStatusOk(command)
        
    }
    
    @objc(readqrcode:) func readqrcode(_ command: CDVInvokedUrlCommand) {
        qrCodeLink = ""
        command2 = command
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        
        UIApplication.shared.keyWindow?.rootViewController?.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        qrCodeLink = ""
        i=0
        qrcodeImg = info[.originalImage] as? UIImage
        readQRCode(ciImage: CIImage(image: qrcodeImg)!)
        
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
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

extension UIImage {
    var noir: UIImage? {
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }
}


extension CIImage {
    /// Inverts the colors and creates a transparent image by converting the mask to alpha.
    /// Input image should be black and white.
    var transparent: CIImage? {
        return inverted?.blackTransparent
    }
    
    /// Inverts the colors.
    var inverted: CIImage? {
        guard let invertedColorFilter = CIFilter(name: "CIColorInvert") else { return nil }
        
        invertedColorFilter.setValue(self, forKey: "inputImage")
        return invertedColorFilter.outputImage
    }
    
    /// Converts all black to transparent.
    var blackTransparent: CIImage? {
        guard let blackTransparentFilter = CIFilter(name: "CIMaskToAlpha") else { return nil }
        blackTransparentFilter.setValue(self, forKey: "inputImage")
        return blackTransparentFilter.outputImage
    }
    
    /// Applies the given color as a tint color.
    func tinted(using color: UIColor) -> CIImage?
    {
        guard
            let transparentQRImage = transparent,
            let filter = CIFilter(name: "CIMultiplyCompositing"),
            let colorFilter = CIFilter(name: "CIConstantColorGenerator") else { return nil }
        
        let ciColor = CIColor(color: color)
        colorFilter.setValue(ciColor, forKey: kCIInputColorKey)
        let colorImage = colorFilter.outputImage
        
        filter.setValue(colorImage, forKey: kCIInputImageKey)
        filter.setValue(transparentQRImage, forKey: kCIInputBackgroundImageKey)
        
        return filter.outputImage!
    }
}

extension CIImage {
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    /// Combines the current image with the given image centered.
    func combined(with image: CIImage) -> CIImage? {
        guard let combinedFilter = CIFilter(name: "CISourceOverCompositing") else { return nil }
        let centerTransform = CGAffineTransform(translationX: extent.midX - (image.extent.size.width/2), y: extent.midY - (image.extent.size.height/2))
        let img = self.resizeImage(image: UIImage(ciImage: image), targetSize: CGSize(width: 56.0, height: 56.0))
        combinedFilter.setValue(CIImage(image: img)!.transformed(by: centerTransform), forKey: "inputImage")
        combinedFilter.setValue(self, forKey: "inputBackgroundImage")
        return combinedFilter.outputImage!
    }
}




