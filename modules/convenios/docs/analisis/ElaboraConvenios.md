# Documentación Técnica: Migración de Formulario "ElaboraConvenios" a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite administrar el catálogo de usuarios responsables de la elaboración de convenios, asociando recaudadora, usuario titular y usuario que elabora el convenio. Incluye operaciones de alta, modificación, consulta y eliminación.

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.
- **API:** Todas las operaciones se realizan vía POST a `/api/execute` con parámetros `action` y `params`.

## 3. Endpoints
- **POST /api/execute**
  - **action:** `list`, `create`, `update`, `delete`, `get`
  - **params:** Parámetros según la acción

## 4. Stored Procedures
- `sp_elabora_convenios_list()`: Lista todos los registros.
- `sp_elabora_convenios_create(...)`: Crea un registro.
- `sp_elabora_convenios_update(...)`: Actualiza un registro.
- `sp_elabora_convenios_delete(...)`: Elimina un registro.
- `sp_elabora_convenios_get(...)`: Obtiene un registro específico.

## 5. Validaciones
- Todos los campos requeridos deben ser enviados.
- Las cadenas no deben exceder 10 caracteres para iniciales.
- Los IDs deben ser enteros válidos.

## 6. Seguridad
- El controlador utiliza el usuario autenticado para auditoría.
- Las operaciones de modificación y eliminación requieren autenticación.

## 7. Frontend
- Página Vue.js independiente, sin tabs.
- Tabla con acciones de editar y eliminar.
- Modal para alta/modificación.
- Navegación breadcrumb.

## 8. Flujo de Datos
1. El usuario accede a la página y ve la lista de registros.
2. Puede agregar, editar o eliminar registros usando el formulario modal.
3. Todas las operaciones se envían a `/api/execute` y la tabla se actualiza automáticamente.

## 9. Integración
- El frontend y backend usan el mismo endpoint y formato de datos.
- Los stored procedures encapsulan toda la lógica de negocio y validación de datos.

## 10. Manejo de Errores
- Los errores de validación se devuelven en el campo `errors`.
- Los errores de ejecución se devuelven en el campo `message`.

## 11. Auditoría
- El campo `p_id_usuario` se utiliza para registrar el usuario que realiza la operación.

## 12. Consideraciones
- El frontend asume que los IDs de usuarios y recaudadoras existen y son válidos.
- El backend puede extenderse para validar existencia de usuarios/recaudadoras si se requiere.

---
