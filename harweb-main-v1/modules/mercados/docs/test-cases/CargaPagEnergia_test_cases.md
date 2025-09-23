# Casos de Prueba: CargaPagEnergia

## Caso 1: Carga exitosa de pagos de energía
- **Precondición:** Existen adeudos pendientes para el local.
- **Pasos:**
  1. Buscar adeudos para oficina=5, mercado=1, categoria=2, seccion='SS', local=123
  2. Seleccionar todos los adeudos listados
  3. Ingresar fecha_pago='2024-06-10', oficina_pago=5, caja_pago='A', operacion_pago=12345, folio='FOL123'
  4. Ejecutar carga de pagos
- **Resultado esperado:** Los pagos se registran y los adeudos desaparecen de la lista.

## Caso 2: Intento de carga sin seleccionar adeudos
- **Precondición:** Existen adeudos listados
- **Pasos:**
  1. Buscar adeudos para un local
  2. No seleccionar ningún adeudo
  3. Intentar cargar pagos
- **Resultado esperado:** El sistema muestra error 'Debe seleccionar al menos un adeudo para cargar el pago.'

## Caso 3: Consulta de pagos realizados
- **Precondición:** Existen pagos registrados para id_energia=1001
- **Pasos:**
  1. Consultar pagos para id_energia=1001
- **Resultado esperado:** Se muestra la lista de pagos realizados para ese id_energia.

## Caso 4: Validación de campos obligatorios
- **Precondición:** Existen adeudos listados
- **Pasos:**
  1. Seleccionar adeudos
  2. Omitir algún campo obligatorio (ej. fecha_pago)
  3. Intentar cargar pagos
- **Resultado esperado:** El sistema muestra error de validación indicando el campo faltante.

## Caso 5: Integridad transaccional
- **Precondición:** El sistema está operativo
- **Pasos:**
  1. Simular un error de base de datos durante la carga de pagos (ej. duplicidad, error de conexión)
  2. Intentar cargar pagos
- **Resultado esperado:** El sistema revierte la transacción y muestra un mensaje de error.
