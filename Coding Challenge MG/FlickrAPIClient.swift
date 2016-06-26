//
//  FlickrAPIClient.swift
//  Coding Challenge MG
//
//  Created by Michael Gasparik on 16/06/16.
//  Copyright © 2016 Michael Gasparik. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import AlamofireImage

class FlickrAPIClient {
    static func fetchResults(searchItem : String!, page : Int, completionBlock:(response : PhotosMeta) -> (), errorBlock:(error : NSError) -> ()) -> Request?{
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        //We need to escape our searchterm, just in case the user inputs any trouble-making characters (e.g. Space)
        if let escapedString = searchItem.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()){
            let urlString = Config.API.APISearchURL + "&page=\(page)&text=" + escapedString
            return Alamofire.request(.GET, urlString).responseObject() { (response: Response<PhotosResponse, NSError>) in
                
                if let error = response.result.error {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    errorBlock(error: error)
                    return
                }
                
                if let stat = response.result.value?.stat{
                    switch stat {
                    case "ok":
                        print("Results processed OK")
                    case "fail":
                        let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Something went wrong"])
                        errorBlock(error: APIError)
                        return
                    default:
                        let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Uknown API response"])
                        errorBlock(error: APIError)
                        return
                    }
                }else{
                    let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Uknown API response"])
                    errorBlock(error: APIError)
                    return
                }
                                    //TODO: return the whole response for checking stat
                if let photos = response.result.value?.photosMeta {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    completionBlock(response: photos)
                }
            }
        }
        return nil
    }
    
    //Get the big image when displaying the detail view.
    static func getNetworkImage(photo: Photo, completion: (UIImage? -> Void), errorBlock:(error : NSError) -> ()) -> () {
        
        if let imageUrl = photo.getImageUrl("b"){
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            Alamofire.request(.GET, imageUrl).responseImage { (response) -> Void in
                if let error = response.result.error {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    errorBlock(error: error)
                }
                guard let image = response.result.value else { return }
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                completion(image)
            }
        }
//        return nil
    }
}