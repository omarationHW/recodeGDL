# Documentación Técnica: Carga de Pagos del Tianguis Cultural

## Descripción General
Este módulo permite la carga masiva y validación de pagos del Tianguis Cultural (Mercado 214) en el sistema de mercados municipales. Incluye la consulta de adeudos, validación de folios contra ingresos, aplicación de descuentos, y registro de pagos, eliminando los adeudos correspondientes.

## Arquitectura
- **Backend**: Laravel Controller (API RESTful, endpoint único `/api/execute`)
- **Frontend**: Vue.js SPA (Single Page Application), componente de página independiente
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures
- **Patrón API**: eRequest/eResponse (todas las operaciones usan el endpoint `/api/execute` con un campo `eRequest` y un `payload`)

## Flujo de Trabajo
1. **Consulta de Adeudos**: El usuario ingresa un rango de folios, periodo y año. El sistema consulta los adeudos pendientes para ese rango.
2. **Edición de Pagos**: El usuario ingresa los datos de pago (fecha, recaudadora, caja, operación, partida) para cada folio.
3. **Validación**: El sistema valida que los folios y operaciones existan en ingresos y no estén duplicados.
4. **Carga de Pagos**: Si la validación es exitosa, los pagos se registran y los adeudos correspondientes se eliminan. Se aplica descuento si corresponde.

## Detalle de Componentes
### Laravel Controller
- **Método principal**: `execute(Request $request)`
- **eRequest soportados**:
    - `getAdeudosTCultural`: Consulta de adeudos
    - `validatePagosTCultural`: Validación de folios de pago
    - `savePagosTCultural`: Registro de pagos y eliminación de adeudos
    - `getTianguisInfo`: Consulta de información de folio en Tianguis
- **Seguridad**: Usa el usuario autenticado para auditoría
- **Transacciones**: Las operaciones de guardado son atómicas

### Vue.js Component
- Página independiente `/carga-tcultural`
- Formulario para búsqueda de adeudos
- Tabla editable para captura de pagos
- Botones para validar y guardar
- Mensajes de error y éxito
- Navegación breadcrumb

### Stored Procedures PostgreSQL
- Toda la lógica de negocio y validación reside en SPs
- Uso de JSON para manejo de lotes de pagos
- Validación de existencia en ingresos y duplicidad
- Aplicación de descuentos
- Auditoría por usuario

### API Unificada
- Todas las operaciones usan `/api/execute` con un JSON:
    - `eRequest`: nombre de la acción
    - `payload`: parámetros
- La respuesta siempre es `{ eResponse: { success, data, message } }`

## Seguridad y Validaciones
- Validación de campos obligatorios en backend y frontend
- Validación de existencia de folios en ingresos
- Validación de duplicidad de pagos
- Aplicación de descuentos sólo si corresponde
- Auditoría de usuario en todos los movimientos

## Manejo de Errores
- Todos los errores se devuelven en el campo `message` de la respuesta
- El frontend muestra mensajes claros al usuario

## Integración
- El frontend consume el endpoint `/api/execute` usando Axios
- El backend ejecuta los SPs según el eRequest
- El frontend espera siempre la estructura eResponse

## Consideraciones de Migración
- El proceso Delphi usaba componentes visuales y lógica procedural; aquí todo es desacoplado y API-driven
- El acceso a la base de datos es a través de SPs, no de SQL embebido en la aplicación
- El frontend es completamente desacoplado y puede ser integrado en cualquier SPA

# Endpoints y Parámetros
- `/api/execute` (POST)
    - `eRequest: getAdeudosTCultural` + `payload: { local_desde, local_hasta, periodo, axo }`
    - `eRequest: validatePagosTCultural` + `payload: { pagos: [...] }`
    - `eRequest: savePagosTCultural` + `payload: { pagos: [...] }`
    - `eRequest: getTianguisInfo` + `payload: { folio }`

# Seguridad
- Requiere autenticación JWT o session para identificar al usuario
- Todos los movimientos quedan auditados con el id_usuario

# Pruebas y Validación
- Incluye casos de uso y escenarios de prueba para asegurar la funcionalidad
