/// HTTP status
enum Status {
  continueStatus,
  switchingProtocols,
  processing,
  earlyHints,

  ok,
  created,
  accepted,
  nonAuthoritative,
  noContent,
  resetContent,
  partialContent,
  multiStatus,
  alreadyReported,
  imUsed,

  multipleChoices,
  movedPermanently,
  found,
  seeOther,
  notModified,
  useProxy,
  switchProxy,
  temporaryRedirect,
  permanentRedirect,

  badRequest,
  unauthorized,
  paymentRequired,
  forbidden,
  notFound,
  methodNotAllowed,
  notAcceptable,
  proxyAuthenticationRequired,
  requestTimeout,
  conflict,
  gone,
  lengthRequired,
  preconditionFailed,
  payloadTooLarge,
  uriTooLong,
  unsupportedMediaType,
  rangeNotSatisfiable,
  expectationFailed,
  imATeapot,
  misdirectedRequest,
  unprocessableContent,
  locked,
  failedDependency,
  tooEarly,
  upgradeRequired,
  preconditionRequired,
  tooManyRequests,
  requestHeaderFieldsTooLarge,
  unavailableForLegalReasons,

  internalServerError,
  notImplemented,
  badGateway,
  serviceUnavailable,
  gatewayTimeout,
  httpVersionNotSupported,
  variantAlsoNegotiates,
  insufficientStorage,
  loopDetected,
  notExtended,
  networkAuthenticationRequired,
}

Status withInt(int status) {
  Status result = Status.ok;

  switch (status) {
    case 100:
      result = Status.continueStatus;
      break;
    case 101:
      result = Status.switchingProtocols;
    case 102:
      result = Status.processing;
      break;
    case 103:
      result = Status.earlyHints;
      break;

    case 200:
      result = Status.ok;
      break;
    case 201:
      result = Status.created;
      break;
    case 202:
      result = Status.accepted;
      break;
    case 203:
      result = Status.nonAuthoritative;
      break;
    case 204:
      result = Status.noContent;
      break;
    case 205:
      result = Status.resetContent;
      break;
    case 206:
      result = Status.partialContent;
      break;
    case 207:
      result = Status.multiStatus;
      break;
    case 208:
      result = Status.alreadyReported;
      break;
    case 226:
      result = Status.imUsed;
      break;

    case 300:
      result = Status.multipleChoices;
      break;
    case 301:
      result = Status.movedPermanently;
      break;
    case 302:
      result = Status.found;
      break;
    case 303:
      result = Status.seeOther;
      break;
    case 304:
      result = Status.notModified;
      break;
    case 305:
      result = Status.useProxy;
      break;
    case 306:
      result = Status.switchProxy;
      break;
    case 307:
      result = Status.temporaryRedirect;
      break;
    case 308:
      result = Status.permanentRedirect;
      break;

    case 400:
      result = Status.badRequest;
      break;
    case 401:
      result = Status.unauthorized;
      break;
    case 402:
      result = Status.paymentRequired;
      break;
    case 403:
      result = Status.forbidden;
      break;
    case 404:
      result = Status.notFound;
      break;
    case 405:
      result = Status.methodNotAllowed;
      break;
    case 406:
      result = Status.notAcceptable;
      break;
    case 407:
      result = Status.proxyAuthenticationRequired;
      break;
    case 408:
      result = Status.requestTimeout;
      break;
    case 409:
      result = Status.conflict;
      break;
    case 410:
      result = Status.gone;
      break;
    case 411:
      result = Status.lengthRequired;
      break;
    case 412:
      result = Status.preconditionFailed;
      break;
    case 413:
      result = Status.payloadTooLarge;
      break;
    case 414:
      result = Status.uriTooLong;
      break;
    case 415:
      result = Status.unsupportedMediaType;
      break;
    case 416:
      result = Status.rangeNotSatisfiable;
      break;
    case 417:
      result = Status.expectationFailed;
      break;
    case 418:
      result = Status.imATeapot;
      break;
    case 421:
      result = Status.misdirectedRequest;
      break;
    case 422:
      result = Status.unprocessableContent;
      break;
    case 423:
      result = Status.locked;
      break;
    case 424:
      result = Status.failedDependency;
      break;
    case 425:
      result = Status.tooEarly;
      break;
    case 426:
      result = Status.upgradeRequired;
      break;
    case 428:
      result = Status.preconditionRequired;
      break;
    case 429:
      result = Status.tooManyRequests;
      break;
    case 431:
      result = Status.requestHeaderFieldsTooLarge;
      break;
    case 451:
      result = Status.unavailableForLegalReasons;
      break;

    case 500:
      result = Status.internalServerError;
      break;
    case 501:
      result = Status.notImplemented;
      break;
    case 502:
      result = Status.badGateway;
      break;
    case 503:
      result = Status.serviceUnavailable;
      break;
    case 504:
      result = Status.gatewayTimeout;
      break;
    case 505:
      result = Status.httpVersionNotSupported;
      break;
    case 506:
      result = Status.variantAlsoNegotiates;
      break;
    case 507:
      result = Status.insufficientStorage;
      break;
    case 508:
      result = Status.loopDetected;
      break;
    case 510:
      result = Status.notExtended;
      break;
    case 511:
      result = Status.networkAuthenticationRequired;
      break;
  }

  return result;
}

String statusToString(Status status) {
  String result = "";

  switch (status) {
    case Status.continueStatus:
      result = '100 Continue';
      break;
    case Status.switchingProtocols:
      result = '101 Switching Protocols';
      break;
    case Status.processing:
      result = '102 Processing';
      break;
    case Status.earlyHints:
      result = '103 Early Hints';
      break;

    case Status.ok:
      result = '200 OK';
      break;
    case Status.created:
      result = '201 Created';
      break;
    case Status.accepted:
      result = '202 Accepted';
      break;
    case Status.nonAuthoritative:
      result = '203 Non-Authoritative Information';
      break;
    case Status.noContent:
      result = '204 No Content';
      break;
    case Status.resetContent:
      result = '205 Reset Content';
      break;
    case Status.partialContent:
      result = '206 Partial Content';
      break;
    case Status.multiStatus:
      result = '207 Multi-Status';
      break;
    case Status.alreadyReported:
      result = '208 Already Reported';
      break;
    case Status.imUsed:
      result = '226 IM Used';
      break;

    case Status.multipleChoices:
      result = '300 Multiple Choices';
      break;
    case Status.movedPermanently:
      result = '301 Moved Permanently';
      break;
    case Status.found:
      result = '302 Found';
      break;
    case Status.seeOther:
      result = '303 See Other';
      break;
    case Status.notModified:
      result = '304 Not Modified';
      break;
    case Status.useProxy:
      result = '305 Use Proxy';
      break;
    case Status.switchProxy:
      result = '306 Switch Proxy';
      break;
    case Status.temporaryRedirect:
      result = '307 Temporary Redirect';
      break;
    case Status.permanentRedirect:
      result = '308 Permanent Redirect';
      break;

    case Status.badRequest:
      result = '400 Bad Request';
      break;
    case Status.unauthorized:
      result = '401 Unauthorized';
      break;
    case Status.paymentRequired:
      result = '402 Payment Required';
      break;
    case Status.forbidden:
      result = '403 Forbidden';
      break;
    case Status.notFound:
      result = '404 Not Found';
      break;
    case Status.methodNotAllowed:
      result = '405 Method Not Allowed';
      break;
    case Status.notAcceptable:
      result = '406 Not Acceptable';
      break;
    case Status.proxyAuthenticationRequired:
      result = '407 Proxy Authentication Required';
      break;
    case Status.requestTimeout:
      result = '408 Request Timeout';
      break;
    case Status.conflict:
      result = '409 Conflict';
      break;
    case Status.gone:
      result = '410 Gone';
      break;
    case Status.lengthRequired:
      result = '411 Length Required';
      break;
    case Status.preconditionFailed:
      result = '412 Precondition Failed';
      break;
    case Status.payloadTooLarge:
      result = '413 Payload Too Large';
      break;
    case Status.uriTooLong:
      result = '414 URI Too Long';
      break;
    case Status.unsupportedMediaType:
      result = '415 Unsupported Media Type';
      break;
    case Status.rangeNotSatisfiable:
      result = '416 Range Not Satisfiable';
      break;
    case Status.expectationFailed:
      result = '417 Expectation Failed';
      break;
    case Status.imATeapot:
      result = '418 I\'m a teapot';
      break;
    case Status.misdirectedRequest:
      result = '421 Misdirected Request';
      break;
    case Status.unprocessableContent:
      result = '422 Unprocessable Content';
      break;
    case Status.locked:
      result = '423 Locked';
      break;
    case Status.failedDependency:
      result = '424 Failed Dependency';
      break;
    case Status.tooEarly:
      result = '425 Too Early';
      break;
    case Status.upgradeRequired:
      result = '426 Upgrade Required';
      break;
    case Status.preconditionRequired:
      result = '428 Precondition Required';
      break;
    case Status.tooManyRequests:
      result = '429 Too Many Requests';
      break;
    case Status.requestHeaderFieldsTooLarge:
      result = '431 Request Header Fields Too Large';
      break;
    case Status.unavailableForLegalReasons:
      result = '451 Unavailable For Legal Reasons';
      break;

    case Status.internalServerError:
      result = '500 Internal Server Error';
      break;
    case Status.notImplemented:
      result = '501 Not Implemented';
      break;
    case Status.badGateway:
      result = '502 Bad Gateway';
      break;
    case Status.serviceUnavailable:
      result = '503 Service Unavailable';
      break;
    case Status.gatewayTimeout:
      result = '504 Gateway Timeout';
      break;
    case Status.httpVersionNotSupported:
      result = '505 HTTP Version Not Supported';
      break;
    case Status.variantAlsoNegotiates:
      result = '506 Variant Also Negotiates';
      break;
    case Status.insufficientStorage:
      result = '507 Insufficient Storage';
      break;
    case Status.loopDetected:
      result = '508 Loop Detected';
      break;
    case Status.notExtended:
      result = '510 Not Extended';
      break;
    case Status.networkAuthenticationRequired:
      result = '511 Network Authentication Required';
      break;
  }
  return result;
}
