# Documentación Técnica: Migración Formulario Preferencial (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la gestión de tasas preferenciales para transmisiones patrimoniales con tasa irregular. Incluye:
- Consulta de tasas preferenciales por folio de trámite
- Alta, edición y baja lógica de tasas preferenciales
- Consulta de tasas válidas por año de efectos

## 2. Arquitectura
- **Backend**: Laravel Controller con endpoint unificado `/api/execute` (patrón eRequest/eResponse)
- **Frontend**: Componente Vue.js como página independiente
- **Base de Datos**: PostgreSQL con stored procedures para toda la lógica

## 3. API Unificada
- **Endpoint**: `POST /api/execute`
- **Request**:
  - `action`: Nombre de la acción (ej: `getPreferencialList`, `addPreferencial`, ...)
  - `payload`: Objeto con los parámetros necesarios
- **Response**:
  - `success`: boolean
  - `message`: string
  - `data`: resultado (array u objeto)

## 4. Stored Procedures
- Toda la lógica de negocio y validación reside en stored procedures PostgreSQL.
- Los procedimientos devuelven tablas o mensajes de éxito/error.

## 5. Seguridad
- El usuario autenticado se pasa en el payload (`user` o `user_baja`).
- Todas las acciones de alta/baja/edición quedan auditadas por usuario y fecha.

## 6. Frontend (Vue.js)
- Página independiente, sin tabs.
- Permite buscar por folio, listar, agregar, editar y dar de baja tasas preferenciales.
- Navegación breadcrumb incluida.
- Validaciones en frontend y backend.

## 7. Backend (Laravel)
- Un solo controlador maneja todas las acciones vía `switch`.
- Validación de parámetros con `Validator`.
- Llama a los stored procedures vía `DB::select`.

## 8. Base de Datos
- Tablas principales: `preferencial`, `actos`, `c_tasas`.
- Índices en `preferencial.folio`, `preferencial.id`.
- Todos los cambios de baja son lógicos (no se borra el registro, sólo se marca fecha y usuario de baja).

## 9. Flujo de Trabajo
1. Usuario ingresa folio y consulta tasas preferenciales.
2. Puede agregar una nueva tasa, seleccionando de las tasas válidas para el año.
3. Puede editar una tasa existente.
4. Puede dar de baja una tasa (marca fecha y usuario de baja).

## 10. Validaciones
- No se permite agregar tasas si el folio está bloqueado (ej: abstención).
- No se permite editar/bajar tasas ya dadas de baja.
- Solo usuarios autenticados pueden operar.

## 11. Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otras acciones del sistema.
- Los stored procedures pueden ser reutilizados en otros módulos.

---
