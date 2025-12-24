# Documentación Técnica: BloquearLicenciafrm

## Análisis Técnico

# Documentación Técnica: Migración de BloquearLicenciafrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (SPA, cada formulario es una página independiente)
- **Base de Datos:** PostgreSQL (toda la lógica de negocio crítica en stored procedures)
- **Patrón de integración:** eRequest/eResponse (payload JSON con acción y datos)

## 2. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "action": "nombreAccion",
    "payload": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true|false,
    "message": "...",
    "data": { ... }
  }
  ```

## 3. Flujo de Bloqueo/Desbloqueo
- El usuario busca una licencia por número.
- El sistema muestra los datos de la licencia y su estado actual.
- El usuario puede:
  - Bloquear la licencia (seleccionando tipo y motivo)
  - Desbloquear la licencia (seleccionando el bloqueo activo y motivo)
- El sistema registra el movimiento en la tabla `bloqueo` y actualiza el campo `bloqueado` en `licencias`.
- Si aplica, también bloquea/desbloquea el domicilio en `bloqueo_dom`.

## 4. Seguridad
- Todas las operaciones requieren usuario autenticado (JWT o session).
- El usuario que realiza la acción queda registrado en los movimientos.

## 5. Stored Procedures
- Toda la lógica de bloqueo/desbloqueo está en los SPs `sp_bloquear_licencia` y `sp_desbloquear_licencia`.
- El controlador Laravel solo valida y llama a los SPs.

## 6. Frontend
- El componente Vue es una página completa, sin tabs.
- Permite buscar, bloquear y desbloquear licencias.
- Muestra histórico y bloqueos activos.
- Usa fetch/AJAX para interactuar con `/api/execute`.

## 7. Catálogos
- El catálogo de tipos de bloqueo se obtiene vía la acción `catalogoTipoBloqueo`.

## 8. Consideraciones de Integridad
- No se permite bloquear una licencia ya bloqueada.
- No se permite desbloquear si no hay bloqueos activos.
- El SP asegura atomicidad y consistencia.

## 9. Convenciones
- Todas las fechas se manejan en formato ISO (YYYY-MM-DD).
- Los mensajes de error son claros y orientados al usuario final.

## 10. Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otras acciones de licencias.

---

# Estructura de Tablas Relacionadas
- **licencias**: id_licencia, bloqueado, ...
- **bloqueo**: id, id_licencia, bloqueado, observa, capturista, fecha_mov, vigente
- **c_tipobloqueo**: id, descripcion
- **bloqueo_dom**: ... (domicilios bloqueados)
- **h_bloqueo_dom**: ... (histórico de domicilios bloqueados)

---

# Ejemplo de Request/Response
## Bloquear licencia
```json
POST /api/execute
{
  "action": "bloquearLicencia",
  "payload": {
    "id_licencia": 12345,
    "tipo_bloqueo": 1,
    "motivo": "Incumplimiento de requisitos"
  }
}
```

## Respuesta
```json
{
  "success": true,
  "message": "Licencia bloqueada correctamente"
}
```

---

# Notas
- El frontend debe refrescar el estado tras cada operación.
- El backend valida todos los parámetros antes de ejecutar los SP.

## Casos de Prueba

# Casos de Prueba: BloquearLicenciafrm

## 1. Bloqueo exitoso
- Buscar licencia vigente
- Bloquear con tipo 1 y motivo 'Incumplimiento'
- Verificar que el estado cambia a BLOQUEADO
- Verificar que aparece en el histórico

## 2. Desbloqueo exitoso
- Buscar licencia con bloqueo activo
- Desbloquear seleccionando el bloqueo y motivo 'Cumplió requisitos'
- Verificar que el estado cambia a NO BLOQUEADO o al siguiente bloqueo activo
- Verificar que aparece el movimiento de desbloqueo en el histórico

## 3. Bloqueo duplicado
- Buscar licencia ya bloqueada por tipo 1
- Intentar bloquear de nuevo con tipo 1
- Verificar que el sistema rechaza la operación y muestra mensaje de error

## 4. Desbloqueo sin bloqueos activos
- Buscar licencia sin bloqueos activos
- Intentar desbloquear
- Verificar que el sistema rechaza la operación y muestra mensaje de error

## 5. Validación de campos
- Intentar bloquear sin seleccionar tipo o motivo
- Verificar que el sistema muestra mensaje de error

## 6. Integridad de domicilio bloqueado
- Bloquear licencia y verificar que se inserta en bloqueo_dom si corresponde
- Desbloquear y verificar que se elimina de bloqueo_dom y se guarda en h_bloqueo_dom

## Casos de Uso

# Casos de Uso - BloquearLicenciafrm

**Categoría:** Form

## Caso de Uso 1: Bloquear una licencia por incumplimiento

**Descripción:** El usuario busca una licencia vigente y la bloquea por un motivo específico.

**Precondiciones:**
El usuario está autenticado y tiene permisos de bloqueo. La licencia existe y está vigente.

**Pasos a seguir:**
- El usuario ingresa el número de licencia y presiona Buscar.
- El sistema muestra los datos de la licencia y su estado.
- El usuario hace clic en 'Bloquear licencia'.
- Selecciona el tipo de bloqueo (por ejemplo, 'BLOQUEADO').
- Escribe el motivo (por ejemplo, 'Incumplimiento de requisitos').
- Confirma la operación.
- El sistema ejecuta el SP y actualiza el estado.

**Resultado esperado:**
La licencia queda bloqueada, el movimiento aparece en el histórico y el estado cambia a 'BLOQUEADO'.

**Datos de prueba:**
{ "licencia": 12345, "tipo_bloqueo": 1, "motivo": "Incumplimiento de requisitos" }

---

## Caso de Uso 2: Desbloquear una licencia con bloqueo activo

**Descripción:** El usuario desbloquea una licencia que tiene bloqueos activos.

**Precondiciones:**
El usuario está autenticado. La licencia tiene al menos un bloqueo activo.

**Pasos a seguir:**
- El usuario busca la licencia bloqueada.
- El sistema muestra los bloqueos activos.
- El usuario selecciona el bloqueo a eliminar y escribe el motivo.
- Confirma la operación.
- El sistema ejecuta el SP y actualiza el estado.

**Resultado esperado:**
La licencia queda desbloqueada (o con el siguiente bloqueo activo si hay más de uno). El movimiento aparece en el histórico.

**Datos de prueba:**
{ "licencia": 12345, "tipo_bloqueo": 1, "motivo": "Cumplió requisitos" }

---

## Caso de Uso 3: Intentar bloquear una licencia ya bloqueada

**Descripción:** El usuario intenta bloquear una licencia que ya tiene un bloqueo activo del mismo tipo.

**Precondiciones:**
La licencia ya tiene un bloqueo activo del tipo seleccionado.

**Pasos a seguir:**
- El usuario busca la licencia.
- Intenta bloquearla con el mismo tipo de bloqueo.
- El sistema valida y rechaza la operación.

**Resultado esperado:**
El sistema muestra un mensaje de error: 'La licencia ya está bloqueada por el mismo tipo'.

**Datos de prueba:**
{ "licencia": 12345, "tipo_bloqueo": 1, "motivo": "Duplicado" }

---
