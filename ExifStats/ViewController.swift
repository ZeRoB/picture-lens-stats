//
//  ViewController.swift
//  ExifStats
//
//  Created by Rob on 19.12.15.
//  Copyright © 2015 zero. All rights reserved.
//

import Cocoa
import ImageIO

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func openFolder(sender: AnyObject) {
        var lensDict = NSDictionary()
        if let myFolderURL = NSOpenPanel().selectFolderURL {
            print(myFolderURL)
            let fileManager = NSFileManager.defaultManager()
            //var picturesInfoDictionary:NSDictionary = NSDictionary()
            if let enumerator:NSDirectoryEnumerator = fileManager.enumeratorAtURL(myFolderURL, includingPropertiesForKeys: nil, options: .SkipsHiddenFiles, errorHandler: nil) {
                while let element = enumerator.nextObject() as? NSURL{
                    //print("File Exists at \(element.path!): \(fileManager.fileExistsAtPath(element.path!))")
                    if let imageSource = CGImageSourceCreateWithURL(element, nil) {
                        if let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as NSDictionary?{
                            //print(imageProperties)
                            //imageProperties.valueForKey("{TIFF}")?.valueForKey("Make")
                            //let exif = imageProperties.valueForKey("{Exif}") as! NSDictionary
                            //let focalLength = exif.valueForKey("FocalLength") as! NSNumber
                            //print(focalLength)
                            lensDict = addLensInfoTo(lensDict, imageProperties: imageProperties)
                        } else {
                            print("Could not load Image Properties")
                        }
                    } else {
                        print("Could not load Image: \(element)")
                    }
                }
            } else {
                print("Could not load Emuerator")
            }
        } else {
            print("File Selection was canceled")
        }
        print("Lens Dict: \(lensDict)")
    }
    
    func addLensInfoTo(lensDictionary: NSDictionary, imageProperties: NSDictionary) -> NSDictionary{
        let returnDict:NSMutableDictionary = NSMutableDictionary(dictionary: lensDictionary)
        //print("Pre: \(returnDict)")
        if let make: String = imageProperties.valueForKey("{TIFF}")!.valueForKey("Make") as? String {
            if let pictureCount:Int = returnDict.valueForKey("pictureCount") as? Int {
                returnDict.setValue(pictureCount+1, forKey: "pictureCount")
            } else {
                returnDict.setValue(1, forKey: "pictureCount")
            }
            
            if let makeDict:NSMutableDictionary = returnDict.valueForKey(make) as? NSMutableDictionary{
                if let lens: String = imageProperties.valueForKey("{ExifAux}")!.valueForKey("LensModel") as? String {
                    if let lensDict:NSMutableDictionary = makeDict.valueForKey(lens) as? NSMutableDictionary {
                        if let focalLength = imageProperties.valueForKey("{Exif}")!.valueForKey("FocalLength") as? NSNumber {
                            if let picturesWithFocalLength: Int = lensDict.valueForKey(focalLength.stringValue) as? Int{
                                lensDict.setValue(picturesWithFocalLength+1, forKey: focalLength.stringValue)
                            } else {
                                lensDict.setValue(1, forKey: focalLength.stringValue)
                            }
                        }
                    } else {
                        makeDict.setValue(NSMutableDictionary(), forKey: lens)
                    }
                } else {
                    print("No Lens Model for: \(make)")
                }
            } else {
                returnDict.setValue(NSMutableDictionary(), forKey: make)
            }
        }
        //print("Post: \(returnDict)")
        return returnDict
    }
}

extension NSOpenPanel {
    var selectFolderURL: NSURL? {
        let fileOpenPanel = NSOpenPanel()
        fileOpenPanel.title = "Select File"
        fileOpenPanel.allowsMultipleSelection = false
        fileOpenPanel.canChooseDirectories = true
        fileOpenPanel.canChooseFiles = false
        fileOpenPanel.runModal()
        return fileOpenPanel.URLs.first
    }
}
