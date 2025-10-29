# Documentación Técnica: Migración Formulario Contratos_Upd_01 (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel API, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend**: Vue.js SPA, cada formulario es una página independiente (NO tabs)
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures

## Flujo de Trabajo
1. **Carga de Catálogos**: Al cargar la página, el frontend solicita catálogos (tipos de aseo, unidades, zonas, recaudadoras) usando la acción correspondiente.
2. **Búsqueda de Contrato**: El usuario ingresa número de contrato y tipo de aseo, el frontend llama a `buscarContrato`.
3. **Selección de Opción de Actualización**: El usuario elige la operación a realizar (unidad, cantidad, empresa, domicilio, etc.). Cada opción muestra un formulario específico.
4. **Actualización**: Al enviar el formulario, el frontend llama a `actualizarContrato` con los parámetros requeridos según la opción.
5. **Licencias de Giro**: Operaciones sobre licencias usan stored procedures específicos.
6. **Todas las operaciones** usan el endpoint `/api/execute` con el patrón:
   ```json
   {
     "eRequest": {
       "action": "nombre_accion",
       "data": { ... }
     }
   }
   ```
   y reciben:
   ```json
   {
     "eResponse": { ... }
   }
   ```

## API: Ejemplo de Uso
- **Obtener tipos de aseo**:
  ```json
  { "eRequest": { "action": "getTipoAseo" } }
  ```
- **Buscar contrato**:
  ```json
  { "eRequest": { "action": "buscarContrato", "data": { "num_contrato": 123, "ctrol_aseo": 9 } } }
  ```
- **Actualizar contrato (cambio de domicilio)**:
  ```json
  { "eRequest": { "action": "actualizarContrato", "data": { "control_cont": 1001, "opcion": 4, "domicilio": "Av. Alcalde 123" } } }
  ```

## Validaciones
- El backend valida la existencia de contratos, empresas, y parámetros requeridos.
- Los stored procedures devuelven un campo `status` y un mensaje `concepto` para indicar éxito o error.

## Seguridad
- Todas las operaciones requieren autenticación Laravel (middleware `auth:api` recomendado).
- Validación de parámetros en el controlador antes de llamar a los SP.

## Extensibilidad
- Para agregar nuevas opciones, basta con crear un nuevo SP y mapear la acción en el controlador.

## Estructura de Componentes Vue
- Cada opción de actualización es un componente Vue independiente.
- El componente principal selecciona el subcomponente según la opción elegida.
- Comunicación entre componentes por eventos (`@actualizar`).

## Manejo de Errores
- Los errores de SP o de validación se devuelven en el campo `error` de la respuesta.
- El frontend muestra mensajes amigables al usuario.

## Pruebas
- Se recomienda usar Postman para pruebas de API y Cypress/Jest para frontend.

