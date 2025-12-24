# Documentación: SdosFavor_CtrlExp

## Análisis Técnico

# Documentación Técnica: Migración de SdosFavor_CtrlExp (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la consulta, filtrado y asignación de folios de solicitudes de saldos a favor (tabla `solic_sdosfavor`) según su estatus. El formulario original en Delphi se migró a una arquitectura moderna usando Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos).

## 2. Arquitectura
- **Backend:** Laravel 10+, controlador único (`SdosFavorCtrlExpController`) con endpoint `/api/execute` que implementa el patrón eRequest/eResponse.
- **Frontend:** Vue.js 3 SPA, componente de página independiente (`SdosFavorCtrlExp.vue`).
- **Base de datos:** PostgreSQL, lógica SQL encapsulada en stored procedures.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "status": "success|error",
    "data": ...
  }
  ```

### Acciones soportadas
- `getStatusOptions`: Devuelve los estatus posibles para filtrar folios.
- `searchFolios`: Devuelve los folios filtrados por estatus.
- `assignFolios`: Asigna un nuevo estatus a una lista de folios.
- `getTotalFolios`: Devuelve el total de folios para un estatus.

## 4. Stored Procedures
Toda la lógica SQL se encapsula en stored procedures para:
- Consultar folios (`sp_sdosfavor_search_folios`)
- Asignar folios (`sp_sdosfavor_assign_folios`)
- Contar folios (`sp_sdosfavor_total_folios`)

## 5. Frontend (Vue.js)
- Página independiente, sin tabs.
- Permite seleccionar estatus, buscar folios, seleccionar múltiples folios y asignarles un nuevo estatus.
- Muestra el total de folios encontrados.
- Navegación breadcrumb incluida.
- Uso de Axios para consumir el endpoint `/api/execute`.

## 6. Seguridad
- El endpoint requiere autenticación (middleware Laravel, si aplica).
- Validación de parámetros en backend.

## 7. Consideraciones de Migración
- El formulario Delphi usaba componentes visuales propietarios; en Vue.js se usan controles HTML estándar.
- La lógica de filtrado y asignación se centraliza en el backend.
- El acceso a la base de datos se realiza exclusivamente vía stored procedures.

## 8. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- El frontend puede extenderse fácilmente para nuevas operaciones.

## 9. Pruebas y QA
- Se proveen casos de uso y escenarios de prueba para QA manual y automatizado.

## Casos de Uso

# Casos de Uso - SdosFavor_CtrlExp

**Categoría:** Form

## Caso de Uso 1: Consulta de folios por estatus

**Descripción:** El usuario desea consultar todos los folios de solicitudes de saldo a favor con estatus 'PENDIENTES'.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página de Control de Expedientes.
2. Selecciona 'PENDIENTES' en el filtro de estatus.
3. Da clic en 'Buscar Folios'.

**Resultado esperado:**
Se muestra la lista de folios con estatus 'PENDIENTES' y el total correspondiente.

**Datos de prueba:**
Estatus: 'P' (PENDIENTES)

---

## Caso de Uso 2: Asignación masiva de folios

**Descripción:** El usuario selecciona varios folios y los asigna cambiando su estatus a 'ASIGNADOS'.

**Precondiciones:**
El usuario está autenticado y existen folios con estatus 'PENDIENTES'.

**Pasos a seguir:**
1. El usuario filtra por estatus 'PENDIENTES'.
2. Selecciona varios folios de la lista.
3. Da clic en 'Asignar Folios'.

**Resultado esperado:**
Los folios seleccionados cambian su estatus a 'ASIGNADOS' y desaparecen del filtro actual.

**Datos de prueba:**
Folios: [1001, 1002, 1003], Nuevo estatus: 'AS'

---

## Caso de Uso 3: Conteo de folios por estatus

**Descripción:** El sistema debe mostrar el total de folios para un estatus seleccionado.

**Precondiciones:**
Existen folios en la base de datos con diferentes estatus.

**Pasos a seguir:**
1. El usuario selecciona un estatus en el filtro.
2. El sistema consulta el total de folios para ese estatus.

**Resultado esperado:**
El total de folios se muestra correctamente junto al filtro.

**Datos de prueba:**
Estatus: 'AS' (ASIGNADOS)

---

## Casos de Prueba

# Casos de Prueba para SdosFavor_CtrlExp

## 1. Consulta de folios por estatus
- **Entrada:** action=searchFolios, params={"status":"P"}
- **Esperado:** Lista de folios con status 'P', sin error.

## 2. Asignación masiva de folios
- **Entrada:** action=assignFolios, params={"folios":[1001,1002,1003],"new_status":"AS"}
- **Esperado:** Respuesta success, los folios cambian a status 'AS'.

## 3. Conteo de folios por estatus
- **Entrada:** action=getTotalFolios, params={"status":"AS"}
- **Esperado:** Campo data con el número total de folios con status 'AS'.

## 4. Consulta de todos los folios (sin filtro)
- **Entrada:** action=searchFolios, params={}
- **Esperado:** Lista completa de folios.

## 5. Error por falta de folios en asignación
- **Entrada:** action=assignFolios, params={"folios":[],"new_status":"AS"}
- **Esperado:** status=error, message='No folios selected'.

## 6. Error por acción no soportada
- **Entrada:** action=unknownAction, params={}
- **Esperado:** status=error, message='Acción no soportada'.

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

