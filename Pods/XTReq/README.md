# XTReq

cocoapods 
```
pod 'XTReq'
```

```
#import "XTReq.h"
```

# XTRequest

Based on [XTFMDB](https://github.com/Akateason/XTFMDB) & AFNetworking
1.  share one manager .
2.  async and sync .
3.  GET / POST / PUT , fast append HTTP header / formdata / rawbody
4.  log result
5.  show hud
6. cancel all req
7. upload images
8. download
9. reachability

#  XTCacheRequest
1.  Persistent save the response of requests .
2.  three policy for how you save requests .
3.  can control save or not when server crashed or bug .

---

* FYI

## XTRequest
### async
```
[XTRequest GETWithUrl:kURLstr
            header:nil
            hud:YES
            parameters:nil
            taskSuccess:^(NSURLSessionDataTask *task, id json) {

        } fail:^{

    }] ;
```

### raw body
```
[XTRequest POSTWithURL:url
                header:
                param:
                rawBody:
                hud:
                success:
                fail: ] ;
```

### sync
```
id json = [XTRequest syncWithReqMode:
                                 url:
                              header:
                              parameters:] ;
```


---

## XTCacheRequest

prepare in appDidLaunch
```
[XTCacheRequest configXTCacheReqWhenAppDidLaunchWithDBName:@"yourDB"] ;

```


###  XTCacheRequest judgeResult designated MAIN FUNC
```
@param reqMode         XTRequestMode               get / post mode .
@param url             string
@param hud             bool
@param header          dic                         HTTP header if has .
@param param           dic                         param if has .
@param body            str                         post rawbody if has .
@param cachePolicy     XTReqPolicy                 req policy .
@param overTimeIfNeed   INT (seconds)               only in XTReqPolicyOverTime mode .
@param completion      (XTReqSaveJudgment(^)(BOOL isNewest, id json))completion
PARAM  isNewest          : isCacheOrNewest
PARAM  json              : respObj
RETURN XTReqSaveJudgment : judge If Need Cache
```


### XTReqPolicy
```
typedef NS_OPTIONS(NSUInteger, XTReqPolicy) {
XTReqPolicy_NeverCache_WaitReturn   = XTResponseCachePolicyNeverUseCache | XTResponseReturnPolicyWaitUtilReqDone ,      // DEFAULT
XTReqPolicy_AlwaysCache_WaitReturn  = XTResponseCachePolicyAlwaysCache | XTResponseReturnPolicyWaitUtilReqDone ,
XTReqPolicy_OverTime_WaitReturn     = XTResponseCachePolicyOverTime | XTResponseReturnPolicyWaitUtilReqDone ,

XTReqPolicy_NeverCache_IRTU         = XTResponseCachePolicyNeverUseCache | XTResponseReturnPolicyImmediatelyReturnThenUpdate ,
XTReqPolicy_AlwaysCache_IRTU        = XTResponseCachePolicyAlwaysCache | XTResponseReturnPolicyImmediatelyReturnThenUpdate ,
XTReqPolicy_OverTime_IRTU           = XTResponseCachePolicyOverTime | XTResponseReturnPolicyImmediatelyReturnThenUpdate ,
} ;

```


### Handling dirty data
### use XTReqSaveJudgment block 
* XTReqSaveJudgment_willSave
* XTReqSaveJudgment_NotSave

```
[XTCacheRequest cacheGET:kURLstr
                parameters:nil
                judgeResult:^XTReqSaveJudgment(id json) {
                    if (!json) {
                        return XTReqSaveJudgment_NotSave ; // dirty data will not save
                    }
                    else {
                        [self showInfoInAlert:[json yy_modelToJSONString]] ;
                        return XTReqSaveJudgment_willSave ;
                    }
}] ;
```



