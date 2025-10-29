# Documentación Técnica: Migración de Mannto_Recaudadoras (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel (PHP 8+), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js SPA, cada formulario es una página independiente
- **Base de Datos:** PostgreSQL, lógica de negocio crítica en stored procedures
- **Seguridad:** Validación de datos en backend y frontend, manejo de errores y mensajes claros

## API Unificada `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "list|get|create|update|delete",
    "payload": { ... }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true|false,
    "data": [ ... ] | null,
    "message": "..."
  }
  ```

## Controlador Laravel
- Un solo método `execute` que despacha según el campo `action`.
- Llama a los stored procedures PostgreSQL para las operaciones de negocio.
- Valida datos y retorna mensajes de error claros.
- Ejemplo de uso:
  - `action: 'list'` → lista todas las recaudadoras
  - `action: 'create'` → crea una nueva recaudadora
  - `action: 'update'` → actualiza una recaudadora
  - `action: 'delete'` → elimina una recaudadora (si no tiene contratos)

## Componente Vue.js
- Página independiente para el catálogo de recaudadoras
- Modo lista y modo formulario (alta/edición)
- Navegación breadcrumb
- Validación de campos en frontend
- Llama al endpoint `/api/execute` para todas las operaciones
- Mensajes de éxito/error claros

## Stored Procedures PostgreSQL
- Toda la lógica de negocio crítica (altas, bajas, cambios) está en SPs
- Validan reglas de negocio (no duplicados, no borrar si hay contratos, etc.)
- Manejan errores con `RAISE EXCEPTION` para que Laravel los capture

## Flujo de Operación
1. Usuario accede a la página de recaudadoras (Vue)
2. Vue llama a `/api/execute` con `action: 'list'` para mostrar la tabla
3. Para alta/edición, Vue muestra formulario y envía `action: 'create'` o `action: 'update'`
4. Laravel valida y llama al SP correspondiente
5. Para baja, Vue pide confirmación y envía `action: 'delete'`
6. Laravel verifica que no existan contratos asociados antes de eliminar

## Validaciones
- **num_rec**: obligatorio, entero, único
- **descripcion**: obligatorio, string, máximo 80 caracteres
- No se puede eliminar una recaudadora si tiene contratos asociados

## Seguridad
- Validación de datos en backend y frontend
- Manejo de errores y mensajes claros
- (Opcional) Autenticación de usuario en endpoints

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente
- Los SPs pueden evolucionar sin cambiar el frontend

## Ejemplo de Request/Response
### Alta
```json
{
  "action": "create",
  "payload": { "num_rec": 5, "descripcion": "Recaudadora Norte" }
}
```
Respuesta:
```json
{
  "success": true,
  "message": "Recaudadora creada correctamente."
}
```

### Baja (con contratos asociados)
```json
{
  "action": "delete",
  "payload": { "num_rec": 1 }
}
```
Respuesta:
```json
{
  "success": false,
  "message": "EXISTEN CONTRATOS CON ESTA RECAUDADORA. POR LO TANTO NO LO PUEDES BORRAR, INTENTA CON OTRA."
}
```

## Migración de Lógica Delphi
- El flujo de altas, bajas y cambios se respeta fielmente
- Las validaciones y mensajes de error se mantienen
- El frontend reproduce la experiencia de usuario original, pero modernizada

## Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para QA y UAT
