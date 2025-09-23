# Documentación Técnica: Migración de Formulario Descuentos Predial (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Backend:** Laravel 10+, PostgreSQL 13+
- **Frontend:** Vue.js 3 SPA (Single Page Application)
- **API:** Unificada, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Stored Procedures:** Toda la lógica SQL y reglas de negocio en PostgreSQL
- **Autenticación:** JWT o sesión Laravel (no incluido aquí)

## 2. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "action": "list|get|create|update|delete|reactivate|catalogs",
    "params": { ... },
    "user": "usuario_actual"
  }
  ```
- **Salida:**
  ```json
  {
    "status": "success|error",
    "data": { ... },
    "message": "..."
  }
  ```

## 3. Controlador Laravel
- Un solo método `execute` que enruta la acción a los métodos privados.
- Cada método llama a un stored procedure y retorna el resultado.
- Validación de parámetros con `Validator`.
- Manejo de errores y mensajes amigables.

## 4. Stored Procedures PostgreSQL
- Toda la lógica de negocio y validación de reglas críticas se implementa en SPs.
- Los SPs devuelven siempre un registro (o tabla) para facilitar el consumo desde Laravel.
- Ejemplo de SPs: `sp_descpred_list`, `sp_descpred_create`, `sp_descpred_update`, etc.

## 5. Frontend Vue.js
- **Página principal:** Listado de descuentos, acciones de alta, edición, baja, reactivación.
- **Cada formulario (alta, edición, baja, reactivación, detalle):** Página independiente (NO tabs).
- **Navegación:** Breadcrumbs y rutas dedicadas.
- **Consumo de API:** Axios, siempre usando `/api/execute`.
- **Catálogos:** Se cargan al inicio y se mantienen en memoria.
- **Validación:** Frontend y backend.

## 6. Seguridad y Auditoría
- El usuario que realiza la acción se pasa siempre como parámetro a los SPs.
- Los SPs registran usuario y fecha de alta/baja/modificación.

## 7. Consideraciones de Migración
- Los triggers y lógica de negocio crítica (validaciones de reglas, fechas, etc.) deben estar en los SPs.
- El frontend sólo muestra/oculta acciones según el estado (`status`) del descuento.
- El backend es responsable de validar reglas de negocio (no permitir duplicados, etc.).

## 8. Ejemplo de Flujo
1. El usuario entra a `/descuentos-predial` y ve el listado.
2. Puede dar de alta un nuevo descuento (formulario independiente).
3. Puede editar, dar de baja o reactivar descuentos según el estado.
4. Todas las acciones se ejecutan vía `/api/execute`.

## 9. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin cambiar el endpoint.
- Los SPs pueden evolucionar sin afectar el frontend.

## 10. Pruebas y QA
- Los casos de uso y pruebas deben cubrir todos los flujos: alta, edición, baja, reactivación, errores, validaciones, etc.

---
