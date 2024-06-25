import "package:flutter/material.dart";

mostrarSnackBar(
    {required BuildContext context,
    required String texto,
    bool isErro = true}) {
  SnackBar snackBar = SnackBar(
    content: Text(texto),
    backgroundColor: (isErro) ? Colors.red : Colors.green,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
      top: Radius.circular(16),
    )),
    duration: const Duration(seconds: 3),
    action: SnackBarAction(
      label: "Página inicial!",
      textColor: Colors.white,
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Navigator.pop(context);
      },
    ),
    showCloseIcon: true,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
