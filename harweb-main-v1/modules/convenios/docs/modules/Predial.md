# Documentación Técnica: Migración Formulario Predial Delphi a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), PostgreSQL 13+, API RESTful unificada
- **Frontend**: Vue.js 3 SPA (Single Page Application)
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures
- **API Unificada**: Un solo endpoint `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`
- **Patrón de integración**: eRequest/eResponse, desacoplando lógica de UI y backend

## Endpoints
- **POST /api/execute**
  - Entrada: `{ eRequest: { action: string, params: object } }`
  - Salida: `{ eResponse: { success: bool, message: string, data: any } }`

## Controlador Laravel
- Un solo método `execute(Request $request)`
- Despacha la acción (`action`) a la función/procedimiento almacenado correspondiente
- Valida parámetros según la acción
- Maneja errores y devuelve mensajes claros
- Ejemplo de acciones:
  - `buscarCuenta`: Busca datos de la cuenta predial
  - `calcularLiquidacion`: Calcula liquidación de adeudos
  - `confirmarPago`: Registra el pago y afecta tablas
  - `imprimirRecibo`: Devuelve datos para impresión
  - `mostrarDescuentos`: Devuelve descuentos aplicados

## Componente Vue.js
- Página independiente `/predial`
- Formulario de búsqueda de cuenta (recaudadora, urb-rus, cuenta)
- Muestra datos del contribuyente y detalle de adeudos
- Permite seleccionar forma de pago (efectivo, cheque, tarjeta)
- Permite incluir aportación voluntaria
- Botones para confirmar pago, liquidación parcial, pago mínimo, pago especial, imprimir recibo
- Mensajes de error y éxito
- No usa tabs ni componentes tabulares, cada formulario es una página

## Stored Procedures PostgreSQL
- Toda la lógica de negocio y cálculos se implementa en stored procedures
- Los procedimientos devuelven tablas (RETURNS TABLE) o JSONB según el caso
- Ejemplo: `sp_predial_confirmar_pago` registra el pago y retorna el folio
- Se recomienda usar transacciones en procedimientos críticos

## Seguridad
- Validación de parámetros en backend y frontend
- El usuario autenticado se obtiene del token/session en Laravel
- Los procedimientos almacenados validan existencia de la cuenta y reglas de negocio

## Flujo de Uso
1. Usuario accede a `/predial` en la SPA
2. Busca cuenta predial (recaudadora, urb-rus, cuenta)
3. El sistema muestra datos del contribuyente y detalle de adeudos
4. Usuario selecciona forma de pago, puede agregar aportación voluntaria
5. Usuario confirma pago, el sistema registra el pago y muestra mensaje de éxito
6. Usuario puede imprimir recibo

## Integración
- El frontend sólo interactúa con `/api/execute` y no conoce detalles de la base de datos
- El backend sólo expone el endpoint `/api/execute` y delega la lógica a stored procedures
- Los stored procedures encapsulan toda la lógica de negocio y cálculos

## Consideraciones
- El sistema es extensible: nuevas acciones sólo requieren agregar stored procedures y mapearlas en el controlador
- El frontend puede ser adaptado a otros frameworks fácilmente
- El backend puede ser adaptado a otros motores de base de datos si se reescriben los SPs
