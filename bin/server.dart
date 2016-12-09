// Copyright (c) 2016, matt. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert' show BASE64, UTF8;
import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

void main(List<String> args) {
  var parser = new ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: '8080');

  var result = parser.parse(args);

  var port = int.parse(result['port'], onError: (val) {
    stdout.writeln('Could not parse port value "$val" into a number.');
    exit(1);
  });

  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(_echoRequest);

  io.serve(handler, '0.0.0.0', port).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });
}

Future<shelf.Response> _echoRequest(shelf.Request request) async {
  var aHeader = request.headers['authorization'];
  print('Auth: $aHeader');
  if (aHeader == null) {
    var resp = new shelf.Response(HttpStatus.UNAUTHORIZED, body: 'unauthorized',
          headers: {'www-authenticate': 'Basic realm="superRealm"'});
    return resp;
  }

  var auth = aHeader.split(' ');
  if (auth[0] != 'Basic') {
    return new shelf.Response(HttpStatus.UNAUTHORIZED, body: 'unauthorized',
        headers: {'www-authenticate': 'Basic realm="superRealm"'});
  }
  var userInfo = UTF8.decode(BASE64.decode(auth[1]));
  if (userInfo != 'test:test') {
    return new shelf.Response(HttpStatus.UNAUTHORIZED, body: 'unauthorized',
        headers: {'www-authenticate': 'Basic realm="superRealm"'});
  }

  var reqBody =  await request.readAsString();
  print('Body was: $reqBody');
  return new shelf.Response.ok('Request for "${request.url}"\nBody: $reqBody');
}