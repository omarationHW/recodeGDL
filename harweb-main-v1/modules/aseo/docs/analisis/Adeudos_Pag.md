# Documentación Técnica: Migración Formulario Adeudos_Pag (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures.
- **Patrón de Comunicación:** eRequest/eResponse (JSON), desacoplado de la UI.

## Endpoints
- **POST /api/execute**
  - Entrada: `{ eRequest: { action: string, params: {...} } }`
  - Salida: `{ eResponse: { success: bool, data: any, message: string } }`

## Acciones Soportadas
- `ver_adeudos`: Consulta los adeudos de un contrato/periodo.
- `ejecutar_pago`: Marca como pagado los adeudos seleccionados.
- `cancelar`: Cancela la operación (no realiza cambios).
- `cargar_catalogos`: Devuelve catálogos de tipo de aseo, recaudadoras y cajas.

## Stored Procedures
- Toda la lógica de negocio y validación de reglas se implementa en PostgreSQL.
- Los SPs devuelven tablas o mensajes de éxito/error.

## Seguridad
- El endpoint requiere autenticación JWT (no incluido aquí, pero recomendado).
- Validación de parámetros en backend y frontend.

## Flujo de Trabajo
1. El usuario ingresa contrato, tipo de aseo, año y mes.
2. El frontend llama a `ver_adeudos` y muestra los adeudos encontrados.
3. El usuario selecciona qué adeudos pagar, ingresa datos de pago y ejecuta `ejecutar_pago`.
4. El backend actualiza los registros y responde con éxito o error.

## Validaciones
- No se permite pagar si el adeudo ya está pagado.
- No se permite pagar si el contrato no existe o está cancelado.
- Los importes deben coincidir con los mostrados.

## Catálogos
- Los catálogos se cargan al iniciar la página y se usan para poblar selects.

## Errores
- Todos los errores se devuelven en el campo `message` de la respuesta.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- Los SPs pueden ser versionados y auditados.

## Notas
- El usuario logueado debe ser pasado como `usuario_id` en las acciones que lo requieran.
- El frontend debe manejar los estados de éxito/error y mostrar mensajes amigables.

