# Documentación: ModifMasiva

## Análisis Técnico

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

## Casos de Uso

# Casos de Uso - ModifMasiva

**Categoría:** Form

## Caso de Uso 1: Modificación masiva de requerimientos de Predial

**Descripción:** El usuario desea marcar como practicados todos los requerimientos de predial de la recaudadora 1, folios del 1000 al 1100, con fecha de práctica 2024-06-01.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos para modificar requerimientos. Los folios deben existir y estar vigentes.

**Pasos a seguir:**
[
  "El usuario accede a la página de Modificación Masiva.",
  "Selecciona 'Predial' como tipo de requerimiento.",
  "Ingresa recaudadora 1, folio inicial 1000, folio final 1100.",
  "Selecciona la fecha de práctica 2024-06-01.",
  "Selecciona la acción 'Marcar como Practicado'.",
  "Presiona 'Ejecutar'.",
  "El sistema envía la petición a /api/execute con los parámetros.",
  "El backend ejecuta el stored procedure correspondiente.",
  "El sistema muestra el número de folios modificados."
]

**Resultado esperado:**
Todos los folios de predial en el rango indicado quedan marcados como practicados con la fecha seleccionada.

**Datos de prueba:**
{
  "action": "modificar_predial",
  "params": {
    "recaud": 1,
    "folio_ini": 1000,
    "folio_fin": 1100,
    "fecha": "2024-06-01"
  },
  "user": "admin"
}

---

## Caso de Uso 2: Cancelación masiva de requerimientos de Multas

**Descripción:** El usuario desea cancelar todos los requerimientos de multas de la recaudadora 2, folios del 2000 al 2100, con fecha de cancelación 2024-06-02.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos para cancelar requerimientos. Los folios deben estar vigentes y no diligenciados.

**Pasos a seguir:**
[
  "El usuario accede a la página de Modificación Masiva.",
  "Selecciona 'Multa' como tipo de requerimiento.",
  "Ingresa recaudadora 2, folio inicial 2000, folio final 2100.",
  "Selecciona la fecha de cancelación 2024-06-02.",
  "Selecciona la acción 'Cancelar'.",
  "Presiona 'Ejecutar'.",
  "El sistema envía la petición a /api/execute con los parámetros.",
  "El backend ejecuta el stored procedure correspondiente.",
  "El sistema muestra el número de folios cancelados."
]

**Resultado esperado:**
Todos los folios de multas en el rango indicado quedan cancelados con la fecha seleccionada.

**Datos de prueba:**
{
  "action": "cancelar_multa",
  "params": {
    "recaud": 2,
    "folio_ini": 2000,
    "folio_fin": 2100,
    "fecha": "2024-06-02"
  },
  "user": "admin"
}

---

## Caso de Uso 3: Modificación masiva de requerimientos de Licencias

**Descripción:** El usuario desea marcar como practicados todos los requerimientos de licencias de la recaudadora 3, folios del 3000 al 3050, con fecha de práctica 2024-06-03.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos para modificar requerimientos. Los folios deben existir y estar vigentes.

**Pasos a seguir:**
[
  "El usuario accede a la página de Modificación Masiva.",
  "Selecciona 'Licencia' como tipo de requerimiento.",
  "Ingresa recaudadora 3, folio inicial 3000, folio final 3050.",
  "Selecciona la fecha de práctica 2024-06-03.",
  "Selecciona la acción 'Marcar como Practicado'.",
  "Presiona 'Ejecutar'.",
  "El sistema envía la petición a /api/execute con los parámetros.",
  "El backend ejecuta el stored procedure correspondiente.",
  "El sistema muestra el número de folios modificados."
]

**Resultado esperado:**
Todos los folios de licencias en el rango indicado quedan marcados como practicados con la fecha seleccionada.

**Datos de prueba:**
{
  "action": "modificar_licencia",
  "params": {
    "recaud": 3,
    "folio_ini": 3000,
    "folio_fin": 3050,
    "fecha": "2024-06-03"
  },
  "user": "admin"
}

---

## Casos de Prueba

## Casos de Prueba para Modificación Masiva

### Caso 1: Modificación masiva de predial exitosa
- **Entrada:**
  - action: modificar_predial
  - params: { recaud: 1, folio_ini: 1000, folio_fin: 1100, fecha: '2024-06-01' }
  - user: admin
- **Resultado esperado:**
  - eResponse.status: success
  - eResponse.data[0].folios_modificados > 0

### Caso 2: Cancelación masiva de multas exitosa
- **Entrada:**
  - action: cancelar_multa
  - params: { recaud: 2, folio_ini: 2000, folio_fin: 2100, fecha: '2024-06-02' }
  - user: admin
- **Resultado esperado:**
  - eResponse.status: success
  - eResponse.data[0].folios_cancelados > 0

### Caso 3: Modificación masiva de licencias con folios inexistentes
- **Entrada:**
  - action: modificar_licencia
  - params: { recaud: 99, folio_ini: 9999, folio_fin: 10010, fecha: '2024-06-03' }
  - user: admin
- **Resultado esperado:**
  - eResponse.status: success
  - eResponse.data[0].folios_modificados = 0

### Caso 4: Error por parámetros faltantes
- **Entrada:**
  - action: modificar_predial
  - params: { folio_ini: 1000, folio_fin: 1100, fecha: '2024-06-01' }
  - user: admin
- **Resultado esperado:**
  - eResponse.status: error
  - eResponse.message contiene 'recaud'

### Caso 5: Acción no soportada
- **Entrada:**
  - action: accion_invalida
  - params: { recaud: 1, folio_ini: 1000, folio_fin: 1100, fecha: '2024-06-01' }
  - user: admin
- **Resultado esperado:**
  - eResponse.status: error
  - eResponse.message contiene 'Acción no soportada.'

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

