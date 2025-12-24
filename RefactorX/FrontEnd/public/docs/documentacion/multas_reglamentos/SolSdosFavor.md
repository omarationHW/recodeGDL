# Documentación: SolSdosFavor

## Análisis Técnico

# Documentación Técnica: Migración de Formulario SolSdosFavor (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3 SPA, componente de página independiente para cada formulario.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures.
- **Patrón de integración:** eRequest/eResponse (todas las operaciones pasan por un único endpoint y se identifican por el campo `action`).

## 2. Backend (Laravel)
- **Controlador:** `SolSdosFavorController`.
- **Métodos:**
  - `getSolicitud`: Obtiene una solicitud por folio y año.
  - `createSolicitud`: Crea una nueva solicitud (llama SP).
  - `updateSolicitud`: Actualiza una solicitud existente (llama SP).
  - `cancelSolicitud`: Cancela una solicitud (llama SP).
  - `listSolicitudes`: Lista solicitudes, opcionalmente filtradas por status.
  - Catálogos: `getDoctosCatalog`, `getPeticionariosCatalog`, `getInconformidadesCatalog`.
- **Validación:** Laravel Validator, errores devueltos en el campo `message`.
- **Autenticación:** Se asume JWT o similar, el usuario se obtiene de `$request->user()`.
- **Llamada a SP:** Se usan funciones PostgreSQL vía `DB::select`.

## 3. Frontend (Vue.js)
- **Componente:** `SolSdosFavorPage.vue`.
- **Rutas:** Cada formulario es una página independiente, sin tabs.
- **Navegación:** Breadcrumb simple.
- **Formulario:**
  - Inputs para todos los campos relevantes.
  - Catálogos cargados vía API.
  - Lista de solicitudes recientes editable/cancelable.
  - Validación básica en frontend y backend.
- **UX:**
  - Botón Nuevo limpia el formulario.
  - Botón Cancelar revierte edición.
  - Botón Guardar/Actualizar según modo.
  - Estados visuales para status (colores).

## 4. Stored Procedures (PostgreSQL)
- **sp_sol_sdosfavor_create:** Inserta nueva solicitud, genera folio secuencial por año.
- **sp_sol_sdosfavor_update:** Actualiza solicitud existente.
- **sp_sol_sdosfavor_cancel:** Marca solicitud como cancelada.
- **sp_sol_sdosfavor_list:** Lista solicitudes, join con contribuyentes para nombre.
- **Catálogos:** Tablas y datos para documentos, peticionarios, inconformidades.

## 5. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:** `{ "action": "nombreAccion", "params": { ... } }`
- **Respuesta:** `{ "success": true|false, "data": ..., "message": "..." }`

## 6. Seguridad
- **Autenticación:** JWT o Laravel Sanctum.
- **Autorización:** El usuario autenticado se pasa a los SP como parámetro.
- **Validación:** Tanto en frontend como backend.

## 7. Consideraciones de Migración
- **Delphi CheckBoxes → Array de IDs en doctos**
- **ComboBoxes → Selects con catálogos**
- **Navegación y edición de registros → Tabla editable y formulario**
- **Secuencia de folio:** Usar secuencia PostgreSQL para folio.
- **Fechas:** Usar `now()` en backend, mostrar en formato local en frontend.

## 8. Pruebas y Casos de Uso
- Ver sección de casos de uso y pruebas.

## 9. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin cambiar el endpoint.
- Los catálogos pueden crecer sin modificar el frontend.

## 10. Notas
- El código asume que existen las tablas y secuencias necesarias en PostgreSQL.
- Los catálogos pueden ser gestionados por un administrador.

## Casos de Uso

# Casos de Uso - SolSdosFavor

**Categoría:** Form

## Caso de Uso 1: Alta de Solicitud de Saldo a Favor

**Descripción:** Un usuario autorizado registra una nueva solicitud de saldo a favor para una cuenta catastral.

**Precondiciones:**
El usuario está autenticado y tiene permisos. La cuenta catastral existe.

**Pasos a seguir:**
1. El usuario accede a la página de Solicitud de Saldos a Favor.
2. Llena los campos requeridos (domicilio, colonia, solicitante, etc.).
3. Selecciona los documentos entregados (checkboxes).
4. Selecciona la inconformidad y el peticionario.
5. Da clic en 'Guardar'.
6. El sistema valida y envía la petición a /api/execute con action=createSolicitud.
7. El backend crea el registro y devuelve el folio generado.

**Resultado esperado:**
La solicitud queda registrada, aparece en la lista con status 'PENDIENTE' y folio asignado.

**Datos de prueba:**
{
  "domp": "Av. Juárez 123",
  "extp": "123",
  "intp": "A",
  "colp": "Centro",
  "telefono": "3331234567",
  "codp": "44100",
  "solicitante": "Juan Pérez",
  "doctos": [1, 2, 6],
  "status": "P",
  "inconf": 1,
  "peticionario": 1
}

---

## Caso de Uso 2: Edición de Solicitud Existente

**Descripción:** Un usuario edita una solicitud de saldo a favor pendiente para corregir datos.

**Precondiciones:**
Existe una solicitud con status 'PENDIENTE'. El usuario tiene permisos.

**Pasos a seguir:**
1. El usuario selecciona una solicitud de la lista.
2. Da clic en 'Editar'.
3. Modifica los campos necesarios (ej. teléfono, observaciones).
4. Da clic en 'Actualizar'.
5. El sistema valida y envía la petición a /api/execute con action=updateSolicitud.

**Resultado esperado:**
La solicitud se actualiza y los cambios se reflejan en la lista.

**Datos de prueba:**
{
  "id_solic": 123,
  "telefono": "3337654321",
  "observaciones": "Se corrige teléfono."
}

---

## Caso de Uso 3: Cancelación de Solicitud

**Descripción:** Un usuario cancela una solicitud de saldo a favor pendiente.

**Precondiciones:**
Existe una solicitud con status 'PENDIENTE'. El usuario tiene permisos.

**Pasos a seguir:**
1. El usuario selecciona una solicitud pendiente.
2. Da clic en 'Cancelar'.
3. El sistema solicita confirmación.
4. El usuario confirma.
5. El sistema envía la petición a /api/execute con action=cancelSolicitud.

**Resultado esperado:**
La solicitud cambia a status 'CANCELADO' y no puede ser editada.

**Datos de prueba:**
{
  "id_solic": 123
}

---

## Casos de Prueba

# Casos de Prueba para Solicitud de Saldos a Favor

## Caso 1: Alta de Solicitud Exitosa
- **Entrada:** Todos los campos requeridos llenos, documentos seleccionados, status 'P', inconformidad y peticionario válidos.
- **Acción:** createSolicitud
- **Resultado esperado:** success=true, folio generado, status='P', registro en base de datos.

## Caso 2: Alta con Campos Faltantes
- **Entrada:** Falta campo 'solicitante'.
- **Acción:** createSolicitud
- **Resultado esperado:** success=false, message='El campo solicitante es obligatorio.'

## Caso 3: Edición Exitosa
- **Entrada:** id_solic válido, campos modificados.
- **Acción:** updateSolicitud
- **Resultado esperado:** success=true, datos actualizados en base de datos.

## Caso 4: Cancelación Exitosa
- **Entrada:** id_solic válido, status actual 'P'.
- **Acción:** cancelSolicitud
- **Resultado esperado:** success=true, status='C', no editable.

## Caso 5: Listado de Solicitudes
- **Entrada:** action=listSolicitudes, sin filtro.
- **Acción:** listSolicitudes
- **Resultado esperado:** success=true, data es array de solicitudes ordenadas por folio.

## Caso 6: Listado Filtrado por Status
- **Entrada:** action=listSolicitudes, params.status='C'.
- **Acción:** listSolicitudes
- **Resultado esperado:** success=true, data solo solicitudes canceladas.

## Caso 7: Catálogos
- **Entrada:** action=getDoctosCatalog, getPeticionariosCatalog, getInconformidadesCatalog
- **Resultado esperado:** success=true, data es array de catálogos respectivos.

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

