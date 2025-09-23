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
- **Body:** `{ action: string, params: object }
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

# Fin de la documentación
