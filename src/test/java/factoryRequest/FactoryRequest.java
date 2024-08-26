package factoryRequest;

import java.util.HashMap;
import java.util.Map;

public class FactoryRequest {
    public static IRequest make(String requestType){
        Map<String,IRequest> requestMap = new HashMap<>();
        requestMap.put("get", new RequestGET());
        requestMap.put("put", new RequestPUT());
        requestMap.put("post", new RequestPOST());
        requestMap.put("delete",new RequestDELETE());

        return requestMap.containsKey(requestType.toLowerCase())?
                requestMap.get(requestType.toLowerCase()):
                requestMap.get("get");
    }
}
