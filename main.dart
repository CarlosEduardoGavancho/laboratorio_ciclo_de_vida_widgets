import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PantallaPrincipal(),
    ),
  );
}

// WIDGET PADRE (Controla el Estado Global y el Flujo de Datos)
class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => PantallaPrincipalState();
}

class PantallaPrincipalState extends State<PantallaPrincipal> {
  // ESTADO GLOBAL: La única fuente de la verdad
  int _contadorGlobal = 0;
  bool _mostrarSemaforo = true;

  // EVENTO: Función que muta el estado (Fluye hacia arriba desde los hijos)
  void incrementarContador() {
    setState(() {
      _contadorGlobal++;
    });
  }

  void _destruirSemaforo() {
    setState(() {
      _mostrarSemaforo = !_mostrarSemaforo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ciclo de Vida y Flujo de Datos')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElCartel(valor: _contadorGlobal),
            const SizedBox(height: 20),
            // El semáforo solo existe en el árbol de widgets cuando _mostrarSemaforo es true
            if (_mostrarSemaforo)
              ElSemaforo(
                datosDelPadre: _contadorGlobal,
                onBotonPresionado: incrementarContador,
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _mostrarSemaforo ? Colors.red : Colors.green,
        onPressed: _destruirSemaforo,
        child: Icon(_mostrarSemaforo ? Icons.delete_forever : Icons.restore),
      ),
    );
  }
}

// ======== 1. STATELESS WIDGET: "El Cartel" (Inmutable) ========
class ElCartel extends StatelessWidget {
  final int valor;
  const ElCartel({super.key, required this.valor});

  @override
  Widget build(BuildContext context) {
    print("🚩 ElCartel: build() ejecutado (Se imprimió un cartel nuevo)");
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade100,
      child: Text(
        "Soy un Cartel (Stateless). \nValor recibido: $valor",
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

// ======== 2. STATEFUL WIDGET: "El Semáforo" (Con Ciclo de Vida) ========
class ElSemaforo extends StatefulWidget {
  final int datosDelPadre;
  final VoidCallback onBotonPresionado;

  const ElSemaforo({
    super.key,
    required this.datosDelPadre,
    required this.onBotonPresionado,
  });

  @override
  State<ElSemaforo> createState() {
    print("🚦 ElSemaforo: 1. createState() -> Nace el cerebro del widget");
    return _ElSemaforoState();
  }
}

class _ElSemaforoState extends State<ElSemaforo> {
  Color _colorLuz = Colors.grey;

  @override
  void initState() {
    super.initState();
    _colorLuz = Colors.green; // Configuración inicial
    print("🚦 ElSemaforo: 2. initState() -> Configuración inicial una sola vez");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("🚦 ElSemaforo: 3. didChangeDependencies() -> Escuchando el entorno");
  }

  @override
  void didUpdateWidget(covariant ElSemaforo oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("🚦 ElSemaforo: didUpdateWidget() -> ¡El padre me envió nuevos datos!");
    if (oldWidget.datosDelPadre != widget.datosDelPadre) {
      print("   -> El dato cambió de ${oldWidget.datosDelPadre} a ${widget.datosDelPadre}");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("🚦 ElSemaforo: 4. build() -> Dibujando la interfaz");
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow.shade100,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _colorLuz,
              boxShadow: [
                BoxShadow(
                  color: _colorLuz.withAlpha(180),
                  blurRadius: 12,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Datos del Padre: ${widget.datosDelPadre}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            "Color actual: ${_colorLuz == Colors.green ? 'Verde' : _colorLuz == Colors.red ? 'Rojo' : 'Gris'}",
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _colorLuz = _colorLuz == Colors.green ? Colors.red : Colors.green;
              });
              widget.onBotonPresionado(); // Sube el evento al PADRE
            },
            icon: const Icon(Icons.traffic),
            label: const Text("Cambiar luz / Incrementar"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    print("💀 ElSemaforo: 5. dispose() -> Fui destruido. Liberando memoria...");
    super.dispose();
  }
}