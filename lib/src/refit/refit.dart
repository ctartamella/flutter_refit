import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

typedef FutureOr<RefitRequest> RequestInterceptor(RefitRequest request);
typedef FutureOr<RefitResponse> ResponseInterceptor(RefitResponse response);

class RefitHttp {
  final String name;

  const RefitHttp({this.name});
}

class Req {
  final String method;
  final String url;

  const Req(this.method, this.url);
}

class Param {
  final String name;

  const Param([this.name]);
}

class QueryParam {
  final String name;

  const QueryParam([this.name]);
}

class Body {
  const Body();
}

class Get extends Req {
  const Get([String url = "/"]) : super("GET", url);
}

class Post extends Req {
  const Post([String url = "/"]) : super("POST", url);
}

class Put extends Req {
  const Put([String url = "/"]) : super("PUT", url);
}

class Delete extends Req {
  const Delete([String url = "/"]) : super("DELETE", url);
}

class Patch extends Req {
  const Patch([String url = "/"]) : super("PATCH", url);
}

class RefitResponse<T> {
  final T body;
  final http.Response rawResponse;

  RefitResponse(this.body, this.rawResponse);
  RefitResponse.error(this.rawResponse) : body = null;

  bool isSuccessful() => 
    rawResponse.statusCode >= 200 && rawResponse.statusCode < 300;
  
  String toString() => "RefitResponse($body)";
}

class RefitRequest<T> {
  T body;
  String method;
  String url;
  Map<String, String> headers;

  RefitRequest({this.method, this.headers, this.body, this.url});

  Future<http.Response> send(http.Client client) async {
    switch(method) {
      case "POST":
        return client.post(url, headers: headers, body: body);
      case "PUT":
        return client.put(url, headers: headers, body: body);
      case "PATCH":
        return client.patch(url, headers: headers, body: body);
      case "DELETE":
        return client.delete(url, headers: headers);
      default:
        return client.get(url, headers: headers);
    }
  }
}

abstract class RefitApiDefinition {
  final String baseUrl;
  final Map headers;
  final http.Client client;
  
  RefitApiDefinition(this.client, this.baseUrl, Map headers)
    : headers = headers ?? {'content-type': 'application/json'};
    
  final List<RequestInterceptor> requestInterceptors = [];
  final List<ResponseInterceptor> responseInterceptors = [];

  @protected
  FutureOr<RefitRequest> interceptRequest(RefitRequest request) async {
    for (var i in requestInterceptors) {
      request = await i(request);
    }
    return request;
  }

  @protected
  FutureOr<RefitResponse> interceptResponse(RefitResponse response) async {
    for (var i in responseInterceptors) {
      response = i(response);
    }
    return response;
  }
}