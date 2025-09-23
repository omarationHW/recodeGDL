# Documentación Técnica: Migración Formulario Emisión de Recibos (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (API RESTful)
- **Frontend**: Vue.js 3 (SPA, cada formulario es una página independiente)
- **Base de Datos**: PostgreSQL (toda la lógica SQL en stored procedures)
- **API Unificada**: Un solo endpoint `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Patrón de Comunicación**: eRequest/eResponse (JSON)

## Flujo de Trabajo
1. **El usuario accede a la página de Emisión de Recibos** (ruta Vue.js).
2. **Carga de recaudadoras**: El frontend simula o consulta las recaudadoras disponibles.
3. **Al seleccionar una recaudadora**, el frontend llama a `/api/execute` con `action: listarMercados` para obtener los mercados activos.
4. **El usuario selecciona mercado, año y periodo**.
5. **Al presionar 'Emisión'**, el frontend llama a `/api/execute` con `action: emitirRecibos` y los parámetros.
6. **El backend ejecuta el stored procedure correspondiente y retorna los recibos generados**.
7. **El usuario puede grabar la emisión** (persistir en tabla de adeudos) o generar facturación.
8. **Toda la lógica de negocio y validación de reglas está en los stored procedures**.

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**: `{ "eRequest": { "action": "...", ...parámetros... } }`
- **Salida**: `{ "eResponse": { ...resultado... } }`

## Stored Procedures
- Toda la lógica de negocio (emisión, grabado, facturación, detalle) está en SPs.
- Los SPs devuelven tablas o mensajes de estado.
- El controlador Laravel solo enruta y valida parámetros.

## Seguridad
- Se recomienda validar el usuario autenticado en el backend (middleware Laravel Auth).
- Validar que el usuario tenga permisos para la recaudadora/mercado seleccionado.

## Validaciones
- Año entre 2003 y 2999.
- Periodo entre 1 y 12.
- No se puede grabar emisión si ya existe adeudo para ese periodo/local.
- Solo se pueden emitir recibos de mercados activos.

## Extensibilidad
- Para agregar nuevas acciones, solo agregar el case en el controlador y el SP correspondiente.
- El frontend puede extenderse para otros formularios siguiendo el mismo patrón.

## Pruebas
- Se recomienda usar Postman para probar el endpoint `/api/execute` con diferentes acciones y parámetros.
- El frontend puede ser probado con Cypress o Jest.

## Notas
- El frontend NO usa tabs ni componentes tabulares: cada formulario es una página Vue.js independiente.
- El backend NO expone endpoints CRUD directos, solo el endpoint unificado.
- Los reportes y facturación pueden ser generados en el backend y enviados como PDF o datos tabulares.
