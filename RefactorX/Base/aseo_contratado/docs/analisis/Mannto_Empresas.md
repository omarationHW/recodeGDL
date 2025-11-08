# Documentación Técnica: Migración de Formulario Mannto_Empresas (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (NO tabs)
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures
- **Comunicación:** JSON, autenticación recomendada vía JWT (no incluida aquí)

## API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "empresas.create", // o empresas.update, empresas.delete, empresas.list, empresas.get
    "payload": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true|false,
    "message": "Mensaje de resultado",
    "data": { ... }
  }
  ```

## Controlador Laravel
- Un solo método `execute()` que despacha según el campo `action`.
- Valida datos de entrada según la acción.
- Llama a los stored procedures de PostgreSQL usando DB::select.
- Devuelve respuesta estándar eRequest/eResponse.

## Stored Procedures PostgreSQL
- Toda la lógica de negocio (altas, bajas, cambios, validaciones) está en SPs.
- Ejemplo: `sp_empresas_create` valida unicidad, calcula el siguiente número, inserta y retorna mensaje.
- `sp_empresas_delete` verifica que no existan contratos asociados antes de eliminar.
- Todos los SPs devuelven un registro con `success` y `message`.

## Componente Vue.js
- Página independiente `/empresas`.
- Formulario para alta, baja, cambio (modo controlado por variable `mode`).
- Listado de empresas con acciones de editar/eliminar.
- Llama a `/api/execute` con la acción y payload correspondiente.
- Muestra mensajes de éxito/error.
- Usa Bootstrap para estilos (puede adaptarse a cualquier framework CSS).

## Seguridad
- Validación de datos en backend y frontend.
- Eliminar sólo si no hay contratos asociados.
- No se expone SQL directo al frontend.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- Los SPs pueden ser versionados y auditados.

## Integración
- El endpoint `/api/execute` puede ser consumido por cualquier cliente (SPA, móvil, etc).
- El frontend Vue.js puede ser integrado en cualquier SPA o como microfrontend.

## Consideraciones
- El número de empresa es autoincremental por tipo (`ctrol_emp`).
- El listado de tipos de empresa se obtiene de la tabla `ta_16_tipos_emp`.
- El formulario es completamente funcional y desacoplado de otros módulos.

## Migración de lógica Delphi
- Todas las validaciones y flujos (altas, bajas, cambios, consulta) están implementados en los SPs y el controlador.
- El frontend replica la experiencia de usuario del formulario original, pero en SPA.

## Pruebas
- Casos de uso y pruebas incluidas para validar todos los flujos principales.
