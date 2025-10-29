# Documentación Técnica: Modificación Masiva de Requerimientos

## Descripción General
Este módulo permite la modificación masiva de requerimientos (Predial, Multas, Licencias, Anuncios) en el sistema BasePHP, migrando la lógica desde Delphi a una arquitectura moderna Laravel + Vue.js + PostgreSQL. Todas las operaciones se realizan a través de un endpoint unificado `/api/execute` usando el patrón eRequest/eResponse.

## Arquitectura
- **Backend:** Laravel 10+ (PHP 8+), PostgreSQL 13+
- **Frontend:** Vue.js 3 (SPA o multipágina)
- **API:** Endpoint único `/api/execute`
- **Stored Procedures:** Toda la lógica de modificación/cancelación masiva reside en funciones de PostgreSQL.

## Flujo de Trabajo
1. **El usuario accede a la página de modificación masiva** y selecciona el tipo de requerimiento, recaudadora, rango de folios, fecha y acción (modificar/cancelar).
2. **El frontend envía una petición POST** a `/api/execute` con el siguiente payload:
   ```json
   {
     "action": "modificar_predial", // o cancelar_predial, modificar_multa, etc.
     "params": {
       "recaud": 1,
       "folio_ini": 1000,
       "folio_fin": 1100,
       "fecha": "2024-06-01"
     },
     "user": "usuario_actual"
   }
   ```
3. **El backend ejecuta el stored procedure correspondiente** según la acción y retorna el resultado en eResponse.

## Seguridad
- El endpoint requiere autenticación (middleware Laravel, no mostrado aquí).
- El usuario que ejecuta la acción se registra en los campos `capturista` y `feccap`.

## Validaciones
- El rango de folios debe ser válido y pertenecer a la recaudadora seleccionada.
- La fecha de práctica no puede ser mayor a la fecha actual.
- Solo se modifican/cancelan folios vigentes y no diligenciados.

## API: /api/execute
- **Método:** POST
- **Entrada:**
  - `action`: string (ej. modificar_predial, cancelar_multa, etc.)
  - `params`: objeto con parámetros requeridos por el SP
  - `user`: string (usuario autenticado)
- **Salida:**
  - `eResponse.status`: success|error
  - `eResponse.data`: resultado del SP
  - `eResponse.message`: mensaje de error si aplica

## Stored Procedures
- Cada tipo de requerimiento y acción tiene su propio SP.
- Todos los SP devuelven el número de registros afectados.

## Frontend
- Cada formulario es una página independiente.
- El usuario puede seleccionar el tipo de requerimiento, rango de folios, fecha y acción.
- El resultado se muestra en pantalla.

## Ejemplo de Uso
1. El usuario selecciona "Predial", recaudadora 1, folios 1000 a 1100, fecha 2024-06-01, acción "modificar".
2. El sistema marca como practicados todos los folios vigentes en ese rango.
3. El usuario puede repetir el proceso para cancelar, multas, licencias o anuncios.

## Consideraciones
- El sistema es extensible para otros tipos de requerimientos.
- El endpoint es genérico y puede ser usado por otros módulos.

# Esquema de Base de Datos (simplificado)
- reqpredial (cvereq, recaud, folioreq, fecejec, fecent, vigencia, ...)
- reqmultas (cvereq, recaud, folioreq, fecejec, fecpract, vigencia, ...)
- reqlicencias (cvereq, recaud, folioreq, fecentejec, fecprac, vigencia, ...)
- reqanuncios (cvereq, recaud, folioreq, fecentejec, fecprac, vigencia, ...)

# Extensión
- Se pueden agregar logs de auditoría y validaciones adicionales según políticas de negocio.
