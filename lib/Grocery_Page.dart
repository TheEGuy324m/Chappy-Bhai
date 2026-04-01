import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cheffy/widgets/common_ui.dart';

class GroceryPage extends StatefulWidget {
  @override
  _GroceryPageState createState() => _GroceryPageState();
}

class _GroceryPageState extends State<GroceryPage> {
  late final WebViewController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {},
          onPageFinished: (url) {},
        ),
      )
      ..loadRequest(
        Uri.parse(
          'https://grocerapp.pk/?srsltid=AfmBOooq9Ls6NhMyJirN_xuLBHXnc_QzknPVXllF8vQonfmoAXNdSuSr',
        ),
      );
  }

  /// Handle back button (WebView navigation)
  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,

        /// ✅ COMMON DRAWER
        drawer: buildDrawer(context),

        body: Column(
          children: [
            /// ✅ COMMON HEADER
            buildHeader(
              context: context,
              scaffoldKey: _scaffoldKey,
              screenWidth: screenWidth,
            ),

            /// ✅ WEBVIEW (FULL SCREEN)
            Expanded(
              child: WebViewWidget(controller: _controller),
            ),
          ],
        ),
      ),
    );
  }
}