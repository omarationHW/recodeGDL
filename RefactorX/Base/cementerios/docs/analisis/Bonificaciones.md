# Documentación Técnica: Migración Formulario Bonificaciones (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Backend**: Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend**: Vue.js 3 (SPA, cada formulario es una página independiente)
- **Base de Datos**: PostgreSQL (todas las operaciones de negocio en stored procedures)
- **Patrón API**: eRequest/eResponse (un solo endpoint, acción y parámetros)

## 2. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Payload**:
  ```json
  {
    "action": "bonificaciones.create|bonificaciones.update|bonificaciones.delete|bonificaciones.getByOficio|bonificaciones.getByFolio",
    "params": { ... }
  }
  ```
- **Respuesta**:
  ```json
  {
    "success": true|false,
    "message": "Mensaje de resultado",
    "data": { ... }
  }
  ```

## 3. Stored Procedures (PostgreSQL)
- Toda la lógica de inserción, actualización y borrado de bonificaciones se realiza en SPs.
- Los SPs reciben todos los parámetros necesarios y devuelven errores por parámetro OUT o excepción.

## 4. Controlador Laravel
- Un solo método `execute` que enruta la acción a la función correspondiente.
- Validación de parámetros con Validator.
- Llama a los SPs usando DB::select (o DB::statement si no hay retorno).
- Devuelve respuesta estándar eResponse.

## 5. Componente Vue.js
- Página independiente (no tab, no modal, no tabular).
- Permite buscar por oficio/axo/doble y por folio.
- Permite alta, modificación y baja de bonificaciones.
- Calcula automáticamente el importe pendiente.
- Mensajes de éxito/error claros.
- Navegación simple (limpiar formulario, volver a buscar, etc).

## 6. Seguridad
- El endpoint requiere autenticación (middleware Laravel `auth:api`).
- El id de usuario se obtiene del token y se pasa a los SPs para auditoría.

## 7. Validaciones
- Todos los campos requeridos se validan tanto en frontend como en backend.
- No se permite alta si ya existe bonificación para ese oficio/axo/doble.
- No se permite modificación/baja si no existe el registro.

## 8. Manejo de Errores
- Los errores de SP se devuelven en el campo `message`.
- Los errores de validación se devuelven con código 422.
- Los errores de sistema con código 500.

## 9. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para QA y UAT.

## 10. Migración de Datos
- Los datos existentes deben migrarse a PostgreSQL respetando los tipos y restricciones.
- Las claves foráneas deben mantenerse (ej: control_rcm referencia a ta_13_datosrcm).

## 11. Consideraciones
- El frontend es responsivo y usable en desktop y tablet.
- El backend es desacoplado y puede ser consumido por otros sistemas.
- El código es extensible para futuras operaciones (reportes, auditoría, etc).
