import MapKit

extension MKDirections {

    public class func promise(request:MKDirectionsRequest) -> Promise<MKDirectionsResponse> {
        return Promise { (fulfiller, rejecter) in
            MKDirections(request:request).calculateDirectionsWithCompletionHandler {
                if $1 != nil {
                    rejecter($1)
                } else {
                    fulfiller($0)
                }
            }
        }
    }

    public class func promise(request:MKDirectionsRequest) -> Promise<MKETAResponse> {
        return Promise { (fulfiller, rejecter) in
            MKDirections(request:request).calculateETAWithCompletionHandler {
                if $1 != nil {
                    rejecter($1)
                } else {
                    fulfiller($0)
                }
            }
        }
    }
}
