import 'dart:io';

import 'package:chat/helpers/global_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Webview extends StatefulWidget {
  const Webview({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  final String title;
  final String url;

  @override
  _WebviewState createState() => _WebviewState();
}

class _WebviewState extends State<Webview> {
  InAppWebViewController? webViewController;
  late PullToRefreshController pullToRefreshController;
  var progress = 0.0;
  final buttonStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(const Color(0xFF299EC9)),
  );
  final options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ),
  );

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
            urlRequest: URLRequest(url: await webViewController?.getUrl()),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.chevronCircleLeft),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: generateGradualSpace(
            beginColor: const Color(0xFF299EC9),
            endColor: const Color(0xFF16CCB5),
          ),
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
              initialOptions: options,
              pullToRefreshController: pullToRefreshController,
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              androidOnPermissionRequest:
                  (controller, origin, resources) async {
                return PermissionRequestResponse(
                  resources: resources,
                  action: PermissionRequestResponseAction.GRANT,
                );
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final uri = navigationAction.request.url!;
                final uriSchemes = [
                  "http",
                  "https",
                  "file",
                  "chrome",
                  "data",
                  "javascript",
                  "about"
                ];

                if (uriSchemes.contains(uri.scheme)) {
                  return NavigationActionPolicy.ALLOW;
                }

                if (await canLaunch(uri.toString())) {
                  // Launch the App
                  await launch(uri.toString());
                  // and cancel the request
                  return NavigationActionPolicy.CANCEL;
                }
              },
              onLoadError: (controller, url, code, message) {
                pullToRefreshController.endRefreshing();
              },
              onProgressChanged: (controller, progress) {
                if (progress == 100) pullToRefreshController.endRefreshing();

                setState(() {
                  this.progress = progress / 100;
                });
              },
              onConsoleMessage: (controller, consoleMessage) {
                // ignore: avoid_print
                print(consoleMessage);
              },
            ),
            progress < 1.0
                ? LinearProgressIndicator(value: progress)
                : const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: ButtonBar(
          alignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
              style: buttonStyle,
              child: const FaIcon(FontAwesomeIcons.arrowLeft),
              onPressed: () => webViewController?.goBack(),
            ),
            ElevatedButton(
              style: buttonStyle,
              child: const FaIcon(FontAwesomeIcons.arrowRight),
              onPressed: () => webViewController?.goForward(),
            ),
            ElevatedButton(
              style: buttonStyle,
              child: const FaIcon(FontAwesomeIcons.redoAlt),
              onPressed: () => webViewController?.reload(),
            ),
          ],
        ),
      ),
    );
  }
}
