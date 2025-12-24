# DatosRequerimientos

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Consulta Individual de Requerimientos (DatosRequerimientos)

## Descripción General
Este módulo permite consultar los datos completos de un requerimiento fiscal por folio, mostrando información del local, mercado, requerimiento y periodos asociados. La solución está compuesta por:

- **Backend Laravel**: Un controlador con endpoint único `/api/execute` que recibe eRequest/eResponse y delega a stored procedures en PostgreSQL.
- **Frontend Vue.js**: Un componente de página completa que permite la consulta interactiva.
- **Stored Procedures PostgreSQL**: Toda la lógica de consulta reside en SPs para eficiencia y seguridad.
- **API Unificada**: Todas las operaciones se realizan a través de `/api/execute` con un campo `action` y parámetros.

## Arquitectura
- **API**: `/api/execute` (POST)
  - Body: `{ action: string, params: object }`
  - Respuesta: `{ success: bool, data: array/object, message?: string }`
- **Frontend**: Página Vue.js independiente, sin tabs, con navegación breadcrumb.
- **Backend**: Controlador Laravel que despacha según `action`.
- **DB**: Stored procedures para cada consulta.

## Flujo de Consulta
1. Usuario ingresa ID Local, Módulo y Folio.
2. Se consulta el local (`sp_get_locales`).
3. Se consulta el mercado asociado (`sp_get_mercado`).
4. Se consulta el requerimiento por folio (`sp_get_requerimientos`).
5. Se consultan los periodos asociados (`sp_get_periodos`).
6. Se muestran todos los datos en la página.

## Seguridad
- Todas las consultas requieren autenticación JWT (middleware Laravel).
- Validación de parámetros en backend.
- Los SPs sólo retornan datos permitidos.

## Extensibilidad
- Se pueden agregar nuevas acciones en el controlador y SPs sin modificar el endpoint.
- El frontend puede consumir nuevas acciones simplemente cambiando el `action`.

## Ejemplo de eRequest/eResponse
```json
{
  "action": "getRequerimientos",
  "params": {
    "modulo": 11,
    "folio": 12345,
    "control_otr": 6789
  }
}
```

## Manejo de Errores
- Si falta un parámetro, se retorna HTTP 422 con mensaje.
- Si no hay datos, se retorna success: false y mensaje.
- Todos los errores son capturados y devueltos en formato JSON.

## Frontend
- El componente Vue.js es una página completa, no usa tabs.
- Incluye navegación breadcrumb.
- Muestra todos los datos relevantes en tablas.
- Usa filtros para formato de moneda.
- Maneja loading y errores.

## Backend
- El controlador Laravel es delgado y sólo despacha a SPs.
- Toda la lógica de negocio y SQL está en los SPs.
- El endpoint es único y flexible.

## Base de Datos
- Todas las consultas usan SPs en PostgreSQL.
- Los SPs están optimizados para retornar sólo los campos necesarios.

## Pruebas
- Se proveen casos de uso y pruebas para asegurar la funcionalidad.


## Casos de Uso

# Casos de Uso - DatosRequerimientos

**Categoría:** Form

## Caso de Uso 1: Consulta de requerimiento existente por folio

**Descripción:** El usuario consulta un requerimiento existente ingresando el ID del local, el módulo y el folio.

**Precondiciones:**
El usuario está autenticado y existe un requerimiento con los datos proporcionados.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Requerimientos.
2. Ingresa el ID Local, Módulo y Folio.
3. Presiona 'Buscar'.
4. El sistema consulta los datos y muestra la información del local, mercado, requerimiento y periodos.

**Resultado esperado:**
Se muestran correctamente todos los datos del local, mercado, requerimiento y periodos asociados.

**Datos de prueba:**
{ "id_local": 1001, "modulo": 11, "folio": 12345 }

---

## Caso de Uso 2: Consulta con folio inexistente

**Descripción:** El usuario intenta consultar un requerimiento con un folio que no existe.

**Precondiciones:**
El usuario está autenticado. El folio no existe para el local y módulo indicados.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Requerimientos.
2. Ingresa un ID Local, Módulo y Folio inexistentes.
3. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el requerimiento no fue encontrado.

**Datos de prueba:**
{ "id_local": 1001, "modulo": 11, "folio": 99999 }

---

## Caso de Uso 3: Validación de campos obligatorios

**Descripción:** El usuario intenta consultar sin ingresar todos los campos requeridos.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Requerimientos.
2. Deja vacío el campo 'folio'.
3. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el campo 'folio' es requerido.

**Datos de prueba:**
{ "id_local": 1001, "modulo": 11, "folio": "" }

---



## Casos de Prueba

# Casos de Prueba: Consulta Individual de Requerimientos

## Caso 1: Consulta exitosa de requerimiento
- **Entrada:** id_local=1001, modulo=11, folio=12345
- **Acción:** POST /api/execute { action: 'getRequerimientos', params: { modulo: 11, folio: 12345, control_otr: 1001 } }
- **Resultado esperado:** success: true, data contiene los campos del requerimiento

## Caso 2: Consulta con folio inexistente
- **Entrada:** id_local=1001, modulo=11, folio=99999
- **Acción:** POST /api/execute { action: 'getRequerimientos', params: { modulo: 11, folio: 99999, control_otr: 1001 } }
- **Resultado esperado:** success: false, message: 'Requerimiento no encontrado'

## Caso 3: Validación de campos obligatorios
- **Entrada:** id_local=1001, modulo=11, folio=""
- **Acción:** POST /api/execute { action: 'getRequerimientos', params: { modulo: 11, folio: "", control_otr: 1001 } }
- **Resultado esperado:** HTTP 422, success: false, message: 'modulo, folio y control_otr requeridos'

## Caso 4: Consulta de periodos asociados
- **Entrada:** control_otr=1001
- **Acción:** POST /api/execute { action: 'getPeriodos', params: { control_otr: 1001 } }
- **Resultado esperado:** success: true, data contiene lista de periodos

## Caso 5: Consulta de local inexistente
- **Entrada:** id_local=9999
- **Acción:** POST /api/execute { action: 'getLocales', params: { id_local: 9999 } }
- **Resultado esperado:** success: false, message: 'Local no encontrado'



