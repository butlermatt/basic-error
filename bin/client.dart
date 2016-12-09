import 'dart:async';
import 'dart:convert' show UTF8;
import 'dart:io';

Future<Null> main() async {
  var cl = new HttpClient();
  cl.authenticate = (Uri uri, String scheme, String realm) async {
    var cred = new HttpClientBasicCredentials('test', 'test');
    cl.addCredentials(uri, realm, cred);
    return true;
  };

  var req = await cl.post('localhost', 8080, '/hi');
//  req.add(UTF8.encode('Hello World'));
  req.writeln('Hello World!');
  var resp = await req.close();
  resp.transform(UTF8.decoder).listen((String str) {
    print(str);
  });
  cl.close();
}
