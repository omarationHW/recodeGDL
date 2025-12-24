# AutCargaPagos

## AnÃ¡lisis TÃ©cnico

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


## Casos de Uso

# Casos de Uso - AutCargaPagos

**Categoría:** Form

## Caso de Uso 1: Registrar una nueva autorización de carga de pagos

**Descripción:** Un usuario con permisos administrativos necesita autorizar la carga de pagos para una oficina específica en una fecha determinada.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos de administrador.

**Pasos a seguir:**
1. El usuario accede a la página 'Autorizar Carga de Pagos'.
2. Hace clic en 'Agregar'.
3. Completa el formulario con la fecha de ingreso, oficina, opción de autorizar, fecha límite, usuario permiso y comentarios.
4. Hace clic en 'Guardar'.
5. El sistema valida y envía la solicitud al backend.

**Resultado esperado:**
La nueva autorización aparece en la tabla y puede ser consultada o modificada.

**Datos de prueba:**
{
  "fecha_ingreso": "2024-06-01",
  "oficina": 2,
  "autorizar": "S",
  "fecha_limite": "2024-06-10",
  "id_usupermiso": 5,
  "comentarios": "Autorización especial para cierre de mes."
}

---

## Caso de Uso 2: Modificar una autorización existente

**Descripción:** Un usuario necesita cambiar la fecha límite y los comentarios de una autorización ya registrada.

**Precondiciones:**
Debe existir al menos una autorización registrada.

**Pasos a seguir:**
1. El usuario selecciona una fila en la tabla de autorizaciones.
2. Hace clic en 'Modificar'.
3. Cambia la fecha límite y/o los comentarios.
4. Hace clic en 'Guardar'.
5. El sistema actualiza el registro.

**Resultado esperado:**
La autorización se actualiza y los cambios se reflejan en la tabla.

**Datos de prueba:**
{
  "fecha_ingreso": "2024-06-01",
  "oficina": 2,
  "autorizar": "S",
  "fecha_limite": "2024-06-15",
  "id_usupermiso": 5,
  "comentarios": "Extensión de plazo por cierre fiscal."
}

---

## Caso de Uso 3: Consultar detalles y comentarios de una autorización

**Descripción:** Un usuario desea ver los comentarios y detalles de una autorización específica.

**Precondiciones:**
Debe haber al menos una autorización registrada.

**Pasos a seguir:**
1. El usuario selecciona una fila en la tabla.
2. El sistema muestra los comentarios y detalles en la sección inferior.

**Resultado esperado:**
Los comentarios y detalles se muestran correctamente.

**Datos de prueba:**
Seleccionar la autorización con fecha_ingreso = '2024-06-01' y oficina = 2.

---



## Casos de Prueba

# Casos de Prueba: AutCargaPagos

## 1. Crear autorización válida
- **Entrada:** Todos los campos requeridos completos y válidos
- **Acción:** POST /api/execute { action: 'create', params: {...} }
- **Esperado:** success: true, data contiene la autorización creada

## 2. Crear autorización con campo faltante
- **Entrada:** Falta 'fecha_limite'
- **Acción:** POST /api/execute { action: 'create', params: { ...sin fecha_limite... } }
- **Esperado:** success: false, message indica campo requerido

## 3. Modificar autorización existente
- **Entrada:** Cambiar fecha_limite y comentarios
- **Acción:** POST /api/execute { action: 'update', params: {...} }
- **Esperado:** success: true, data contiene la autorización actualizada

## 4. Consultar lista de autorizaciones
- **Entrada:** action: 'list', params: {}
- **Acción:** POST /api/execute
- **Esperado:** success: true, data es un array de autorizaciones

## 5. Consultar detalle de autorización
- **Entrada:** action: 'show', params: { fecha_ingreso, oficina }
- **Acción:** POST /api/execute
- **Esperado:** success: true, data contiene los detalles

## 6. Validar seguridad
- **Entrada:** Usuario no autenticado
- **Acción:** POST /api/execute
- **Esperado:** HTTP 401 Unauthorized

## 7. Validar integridad de datos
- **Entrada:** 'autorizar' con valor inválido ('X')
- **Acción:** POST /api/execute { action: 'create', params: {..., autorizar: 'X', ...} }
- **Esperado:** success: false, message indica valor inválido



