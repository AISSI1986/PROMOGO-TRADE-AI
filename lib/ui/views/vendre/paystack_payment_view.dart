import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:promogoai/ui/common/app_colors.dart';

class PaystackPaymentView extends StatefulWidget {
  final String paymentUrl;
  final String reference;

  const PaystackPaymentView({
    super.key,
    required this.paymentUrl,
    required this.reference,
  });

  @override
  State<PaystackPaymentView> createState() => _PaystackPaymentViewState();
}

class _PaystackPaymentViewState extends State<PaystackPaymentView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Optionnel : gérer la barre de progression
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("WebView Error: ${error.description}");
          },
          onNavigationRequest: (NavigationRequest request) {
            // Intercepter l'URL de redirection de succès de Paystack
            if (request.url.startsWith('https://promogo.com/payment-callback')) {
              debugPrint("🎯 Redirection de succès détectée : ${request.url}");
              // Ferme la WebView et renvoie 'true' (succès de paiement à vérifier)
              Navigator.of(context).pop(true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Demande de confirmation avant de fermer la page de paiement
        final bool? shouldClose = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Annuler le paiement ?"),
            content: const Text("Voulez-vous vraiment abandonner la transaction ?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("NON", style: TextStyle(color: kcPrimaryColor)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("OUI", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        return shouldClose ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Paiement Sécurisé",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          backgroundColor: kcPrimaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).maybePop(false),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: kcTabIndicatorColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
