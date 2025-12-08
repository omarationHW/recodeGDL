# Documentación Técnica: TramiteBajaAnun

## Análisis Técnico

# Documentación Técnica: Trámite de Baja de Anuncio

## Descripción General
Este módulo permite tramitar la baja administrativa de un anuncio publicitario, asegurando que:
- El anuncio esté vigente.
- No existan adeudos pendientes (o se permita baja por error/tiempo según permisos).
- Se registre la baja en la bitácora (tabla lic_cancel).
- Se recalculen los saldos de la licencia asociada.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures.

## Flujo de Proceso
1. **Búsqueda de Anuncio:**
   - El usuario ingresa el número de anuncio.
   - El sistema consulta datos del anuncio, saldos y licencia asociada.
2. **Validación:**
   - Si el anuncio no existe o ya está cancelado, se muestra error.
   - Si hay adeudos, se bloquea la baja salvo permisos especiales.
3. **Trámite de Baja:**
   - Se actualiza el estado del anuncio a cancelado.
   - Se cancelan los adeudos pendientes (cvepago=999999).
   - Se recalcula el saldo de la licencia (SP `calc_sdosl`).
   - Se registra la baja en la tabla `lic_cancel` (folios).

## API (Laravel Controller)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "tramitarBaja",
    "params": {
      "anuncio": 12345,
      "motivo": "Motivo de la baja",
      "usuario": "usuario_actual",
      "axo_baja": 2024,
      "folio_baja": 1
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "message": "Baja tramitada correctamente"
  }
  ```

## Frontend (Vue.js)
- Página independiente, sin tabs.
- Permite búsqueda, visualización y trámite de baja.
- Muestra mensajes de error y éxito.

## Seguridad y Permisos
- El backend debe validar que el usuario tenga permisos para tramitar bajas por error o fuera de tiempo.
- Todas las acciones quedan registradas con usuario y fecha.

## Integración con PostgreSQL
- Toda la lógica de negocio crítica (cancelación, recalculo, bitácora) está en stored procedures.
- El backend sólo orquesta y valida.

## Consideraciones
- El endpoint es genérico y puede ser extendido para otros trámites.
- El frontend puede ser adaptado para otros formularios similares.


## Casos de Prueba

# Casos de Prueba: Trámite de Baja de Anuncio

## Caso 1: Baja exitosa de anuncio sin adeudos
- **Input:** anuncio=12345, motivo="Cierre de negocio", usuario="admin"
- **Acción:** POST /api/execute { action: 'tramitarBaja', params: {...} }
- **Esperado:** success=true, mensaje de éxito, anuncio en estado cancelado, adeudos cancelados, registro en lic_cancel

## Caso 2: Baja de anuncio ya cancelado
- **Input:** anuncio=54321, motivo="Duplicado", usuario="admin"
- **Acción:** POST /api/execute { action: 'tramitarBaja', params: {...} }
- **Esperado:** success=false, mensaje de error "El anuncio ya se encuentra cancelado."

## Caso 3: Baja de anuncio con adeudos y permiso especial
- **Input:** anuncio=67890, motivo="Error administrativo", usuario="supervisor", baja_error=true
- **Acción:** POST /api/execute { action: 'tramitarBaja', params: {...} }
- **Esperado:** success=true, mensaje de éxito, anuncio cancelado, adeudos cancelados, registro en lic_cancel

## Caso 4: Buscar anuncio inexistente
- **Input:** anuncio=99999
- **Acción:** POST /api/execute { action: 'buscarAnuncio', params: { anuncio: 99999 } }
- **Esperado:** success=false, mensaje de error "No se encontró el anuncio"

## Caso 5: Validación de campos obligatorios
- **Input:** anuncio='', motivo='', usuario=''
- **Acción:** POST /api/execute { action: 'tramitarBaja', params: {...} }
- **Esperado:** success=false, mensaje de error de validación

## Casos de Uso

# Casos de Uso - TramiteBajaAnun

**Categoría:** Form

## Caso de Uso 1: Tramitar baja de anuncio vigente sin adeudos

**Descripción:** El usuario tramita la baja de un anuncio que está vigente y no tiene adeudos.

**Precondiciones:**
El anuncio existe, está vigente (vigente='V'), y no tiene adeudos en detsal_lic.

**Pasos a seguir:**
1. El usuario ingresa el número de anuncio en la página de baja.
2. El sistema muestra los datos del anuncio y confirma que no hay adeudos.
3. El usuario ingresa el motivo de la baja y confirma la acción.
4. El sistema ejecuta el stored procedure para cancelar el anuncio, cancelar adeudos y registrar la baja.

**Resultado esperado:**
El anuncio queda cancelado, los adeudos se marcan como cancelados, y se registra la baja en lic_cancel.

**Datos de prueba:**
{ "anuncio": 12345, "motivo": "Cierre de negocio", "usuario": "admin", "axo_baja": 2024, "folio_baja": 1 }

---

## Caso de Uso 2: Intentar tramitar baja de anuncio ya cancelado

**Descripción:** El usuario intenta tramitar la baja de un anuncio que ya está cancelado.

**Precondiciones:**
El anuncio existe pero su campo vigente <> 'V'.

**Pasos a seguir:**
1. El usuario ingresa el número de anuncio cancelado.
2. El sistema muestra mensaje de error indicando que ya está cancelado.

**Resultado esperado:**
No se realiza ninguna acción y se muestra error.

**Datos de prueba:**
{ "anuncio": 54321, "motivo": "Duplicado", "usuario": "admin" }

---

## Caso de Uso 3: Tramitar baja de anuncio con adeudos usando permiso especial

**Descripción:** El usuario con permiso especial tramita la baja de un anuncio con adeudos.

**Precondiciones:**
El anuncio existe, está vigente, tiene adeudos, y el usuario tiene permiso para baja por error o fuera de tiempo.

**Pasos a seguir:**
1. El usuario ingresa el número de anuncio con adeudos.
2. El sistema muestra los adeudos y permite la baja por error/tiempo.
3. El usuario marca la opción de baja por error y confirma la acción.
4. El sistema ejecuta el stored procedure y tramita la baja.

**Resultado esperado:**
El anuncio queda cancelado y se registra la baja, aunque existían adeudos.

**Datos de prueba:**
{ "anuncio": 67890, "motivo": "Error administrativo", "usuario": "supervisor", "baja_error": true }

---


