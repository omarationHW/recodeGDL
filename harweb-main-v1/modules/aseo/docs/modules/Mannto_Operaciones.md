# Documentación Técnica: Migración de Formulario Mannto_Operaciones (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel API, endpoint único `/api/execute` que recibe un objeto `eRequest` con la acción y datos, y responde con `eResponse`.
- **Frontend**: Vue.js SPA, cada formulario es una página independiente (no tabs), navegación por rutas.
- **Base de Datos**: PostgreSQL, toda la lógica de negocio (validaciones, reglas de negocio) se implementa en stored procedures.

## API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "list|create|update|delete|check_usage",
      "data": { ... }
    }
  }
  ```
- **Salida**:
  ```json
  {
    "eResponse": { ... }
  }
  ```

## Controlador Laravel
- Un solo método `execute` que despacha la acción a los stored procedures correspondientes.
- Todas las validaciones de negocio críticas (unicidad, uso en pagos, etc.) se delegan a los SP.
- Manejo de errores y mensajes amigables.

## Stored Procedures PostgreSQL
- **sp16_operaciones_list**: Devuelve todas las claves de operación.
- **sp16_operaciones_create**: Inserta una nueva clave, valida unicidad.
- **sp16_operaciones_update**: Actualiza la descripción de una clave.
- **sp16_operaciones_delete**: Elimina una clave si no tiene pagos asociados.
- **sp16_operaciones_check_usage**: Indica si una clave está en uso en pagos.

## Componente Vue.js
- Página completa, muestra listado, permite alta, edición y baja.
- Modal para alta/edición, modal de confirmación para baja.
- Validaciones en frontend y backend.
- Mensajes de error y éxito.
- Navegación breadcrumb.

## Seguridad
- Todas las acciones críticas requieren validación en SP (no confiar solo en frontend).
- El endpoint debe estar protegido por autenticación (no incluido aquí por simplicidad).

## Flujo de Operación
1. El usuario accede a la página y ve el listado de claves.
2. Puede crear una nueva clave (modal), editar una existente o eliminarla.
3. Antes de eliminar, se verifica si la clave está en uso (pagos asociados).
4. Todas las operaciones se hacen vía `/api/execute` con el patrón eRequest/eResponse.

## Notas de Migración
- El campo `ctrol_operacion` es autoincremental en PostgreSQL.
- El campo `cve_operacion` es único (1 carácter).
- La lógica de Delphi se traduce a lógica de SP y validaciones en backend.
- El frontend no usa tabs ni componentes tabulares, cada formulario es una página.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin cambiar el endpoint.
- Los SP pueden evolucionar para reglas más complejas.

