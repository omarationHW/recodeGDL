# Documentación Técnica: AutCargaPagos (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## Descripción General
Este módulo permite la gestión de autorizaciones para la carga de pagos en el sistema de mercados. Incluye la visualización, creación y modificación de autorizaciones, así como la consulta de detalles y comentarios asociados.

## Arquitectura
- **Backend:** Laravel Controller (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (componente de página independiente, sin tabs)
- **Base de Datos:** PostgreSQL (toda la lógica SQL encapsulada en stored procedures)
- **Comunicación:** Patrón eRequest/eResponse (acción + parámetros)

## Endpoints
- **POST /api/execute**
  - **action:** `list`, `create`, `update`, `show`
  - **params:** Parámetros según la acción

## Stored Procedures
- `sp_autcargapag_list(p_oficina)` — Lista autorizaciones
- `sp_autcargapag_create(...)` — Crea autorización
- `sp_autcargapag_update(...)` — Actualiza autorización
- `sp_autcargapag_show(p_fecha_ingreso, p_oficina)` — Detalle de autorización

## Flujo de Datos
1. **Frontend** solicita datos o envía cambios mediante `/api/execute`.
2. **Laravel Controller** interpreta la acción y llama al stored procedure correspondiente.
3. **Stored Procedure** ejecuta la lógica y retorna los datos.
4. **Frontend** actualiza la vista según la respuesta.

## Validaciones
- Todos los campos requeridos son validados tanto en frontend como en backend.
- Solo se permite autorizar con valores 'S' (Sí) o 'N' (No).
- Las fechas deben ser válidas y coherentes.

## Seguridad
- El endpoint requiere autenticación (Laravel Auth).
- El ID de usuario se toma del contexto de sesión para auditoría.

## Componentes Vue.js
- Página independiente, sin tabs.
- Tabla de autorizaciones con selección de fila.
- Modal para agregar/modificar autorización.
- Visualización de comentarios.

## Consideraciones de Migración
- Los nombres de campos y lógica de negocio se mantienen fieles al sistema original.
- Se eliminan dependencias de UI específicas de Delphi.
- Se utiliza un solo endpoint para todas las operaciones (eRequest/eResponse).

## Ejemplo de eRequest/eResponse
```json
{
  "action": "create",
  "params": {
    "fecha_ingreso": "2024-06-01",
    "oficina": 2,
    "autorizar": "S",
    "fecha_limite": "2024-06-10",
    "id_usupermiso": 5,
    "comentarios": "Autorización especial para cierre de mes."
  }
}
```

## Respuesta
```json
{
  "success": true,
  "data": { ... },
  "message": ""
}
```

## Errores
- Si falta un campo requerido, se retorna `success: false` y un mensaje de error.
- Si ocurre un error de base de datos, se retorna el mensaje correspondiente.

## Auditoría
- Todos los cambios registran el usuario y la fecha/hora de actualización.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.

---
