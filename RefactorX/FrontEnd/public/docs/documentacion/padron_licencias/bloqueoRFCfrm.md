# Documentación Técnica: bloqueoRFCfrm

## Análisis Técnico

# Documentación Técnica: Migración Formulario bloqueoRFCfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la gestión de bloqueos de RFC por incumplimiento en el programa de autoevaluación. Incluye:
- Consulta de RFC bloqueados
- Búsqueda por RFC
- Bloqueo (alta), edición de motivo y desbloqueo de RFC
- Consulta de información de trámite para autollenado
- Exportación a Excel

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Componente Vue.js como página independiente
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures

## 3. API (Laravel Controller)
- **Endpoint:** `/api/execute` (POST)
- **Body:** `{ action: string, params: object }`
- **Acciones soportadas:**
  - `getBloqueosRfc`: Lista todos los RFC bloqueados
  - `searchBloqueosRfc`: Busca RFC bloqueados por coincidencia
  - `getTramiteInfo`: Consulta datos de trámite para autollenado
  - `addBloqueoRfc`: Agrega un nuevo bloqueo
  - `editBloqueoRfc`: Edita el motivo de un bloqueo
  - `desbloquearRfc`: Desbloquea un RFC (cambia vig a 'C')
  - `exportBloqueosRfc`: Exporta a Excel (CSV)

## 4. Frontend (Vue.js)
- Página independiente `/bloqueo-rfc`
- Tabla con ordenamiento, búsqueda, exportación y acciones
- Formulario modal para alta, edición y desbloqueo
- Modal de búsqueda de trámite con autollenado
- Manejo de loading y errores

## 5. Stored Procedures
- Toda la lógica SQL se encapsula en funciones/procedimientos PostgreSQL:
  - `sp_get_bloqueos_rfc()`: Catálogo
  - `sp_search_bloqueos_rfc(p_rfc)`
  - `sp_get_tramite_info(p_id_tramite)`
  - `sp_add_bloqueo_rfc(...)`
  - `sp_edit_bloqueo_rfc(...)`
  - `sp_desbloquear_rfc(...)`

## 6. Seguridad
- El controlador obtiene el usuario autenticado para registrar el capturista
- Validaciones de entrada en backend y frontend
- Solo permite un bloqueo vigente por RFC

## 7. Exportación
- El endpoint `exportBloqueosRfc` retorna un archivo CSV con todos los bloqueos

## 8. Integración
- El frontend se comunica exclusivamente con `/api/execute` usando el patrón eRequest/eResponse
- Los stored procedures pueden ser llamados desde Laravel usando DB::select/DB::statement

## 9. Consideraciones
- El formulario es una página independiente, sin tabs ni componentes tabulares
- El frontend es completamente funcional y desacoplado
- El backend es desacoplado y puede ser reutilizado por otros clientes

## 10. Migración de lógica
- Todas las validaciones y flujos del formulario Delphi se replican en el backend y frontend
- El autollenado de RFC, licencia, propietario y actividad se realiza vía consulta de trámite
- El desbloqueo cambia el campo `vig` a 'C' y actualiza la observación

## Casos de Prueba

# Casos de Prueba para Bloqueo de RFC

## 1. Alta de bloqueo exitoso
- **Precondición:** RFC no está bloqueado vigente
- **Acción:** Alta con datos válidos
- **Esperado:** Registro insertado, aparece en la tabla

## 2. Alta de bloqueo duplicado
- **Precondición:** RFC ya bloqueado vigente
- **Acción:** Intentar alta de nuevo
- **Esperado:** Error de duplicidad

## 3. Desbloqueo exitoso
- **Precondición:** RFC bloqueado vigente
- **Acción:** Desbloquear
- **Esperado:** Vig cambia a 'C', ya no aparece como vigente

## 4. Edición de motivo
- **Precondición:** RFC bloqueado vigente
- **Acción:** Editar motivo
- **Esperado:** Motivo actualizado, fecha/hora actualizada

## 5. Búsqueda por RFC parcial
- **Acción:** Buscar por parte del RFC
- **Esperado:** Solo aparecen RFCs que contienen el texto

## 6. Exportación a Excel
- **Acción:** Hacer clic en exportar
- **Esperado:** Descarga de archivo CSV con todos los registros

## 7. Validación de campos obligatorios
- **Acción:** Intentar alta sin RFC o sin motivo
- **Esperado:** Error de validación

## 8. Consulta de trámite inexistente
- **Acción:** Buscar trámite con ID inexistente
- **Esperado:** Error 404

## Casos de Uso

# Casos de Uso - bloqueoRFCfrm

**Categoría:** Form

## Caso de Uso 1: Bloquear un RFC por incumplimiento

**Descripción:** Un usuario de Padron y Licencias detecta que un contribuyente incumplió el programa de autoevaluación y procede a bloquear su RFC.

**Precondiciones:**
El usuario está autenticado y tiene permisos para bloquear RFC. El RFC no debe estar ya bloqueado (vigente).

**Pasos a seguir:**
- El usuario accede a la página de Bloqueo de RFC.
- Hace clic en 'Agregar Bloqueo'.
- Teclea el ID de trámite y usa 'Buscar' para autollenar los datos.
- Verifica que el RFC, licencia, propietario y actividad sean correctos.
- Escribe el motivo del bloqueo.
- Hace clic en 'Aceptar'.

**Resultado esperado:**
El RFC queda bloqueado (vigente) y aparece en la lista. No se permite bloquear dos veces el mismo RFC vigente.

**Datos de prueba:**
{ "id_tramite": 12345, "licencia": 54321, "rfc": "ABC123456XYZ", "observacion": "Incumplimiento autoevaluación" }

---

## Caso de Uso 2: Desbloquear un RFC

**Descripción:** Un usuario autorizado decide desbloquear un RFC previamente bloqueado.

**Precondiciones:**
El RFC debe estar bloqueado (vigente).

**Pasos a seguir:**
- El usuario busca el RFC en la tabla.
- Hace clic en 'Desbloquear'.
- Edita o confirma el motivo.
- Hace clic en 'Aceptar'.

**Resultado esperado:**
El RFC cambia su vigencia a 'C' (cancelado) y ya no aparece como vigente.

**Datos de prueba:**
{ "rfc": "ABC123456XYZ", "observacion": "Se regularizó la situación" }

---

## Caso de Uso 3: Editar el motivo de un bloqueo vigente

**Descripción:** El usuario necesita actualizar el motivo de un bloqueo vigente.

**Precondiciones:**
El RFC está bloqueado (vigente).

**Pasos a seguir:**
- El usuario busca el RFC en la tabla.
- Hace clic en 'Editar'.
- Modifica el campo 'Motivo'.
- Hace clic en 'Aceptar'.

**Resultado esperado:**
El motivo se actualiza correctamente y la fecha/hora se actualiza.

**Datos de prueba:**
{ "rfc": "ABC123456XYZ", "observacion": "Motivo actualizado" }

---
