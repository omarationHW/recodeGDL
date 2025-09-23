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
