# Documentación Técnica: Mantenimiento de Claves para la Cuota (CveCuotaMntto)

## Descripción General
Este módulo permite la administración de las claves de cuota (catálogo) utilizadas en el sistema de mercados municipales. Incluye la creación, edición, listado y eliminación de claves de cuota.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## API (Laravel Controller)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato:**
  - `action`: Acción a ejecutar (`list_cve_cuota`, `get_cve_cuota`, `create_cve_cuota`, `update_cve_cuota`, `delete_cve_cuota`)
  - `params`: Parámetros requeridos para la acción
- **Ejemplo de request:**
```json
{
  "action": "create_cve_cuota",
  "params": {
    "clave_cuota": 5,
    "descripcion": "CUOTA ESPECIAL"
  }
}
```
- **Ejemplo de response:**
```json
{
  "success": true,
  "data": null,
  "message": "Clave de cuota creada correctamente."
}
```

## Stored Procedures (PostgreSQL)
- `sp_cve_cuota_insert(p_clave_cuota, p_descripcion)`
- `sp_cve_cuota_update(p_clave_cuota, p_descripcion)`
- `sp_cve_cuota_delete(p_clave_cuota)`

## Frontend (Vue.js)
- Página independiente para el catálogo de claves de cuota.
- Permite listar, crear, editar y eliminar claves de cuota.
- Validación de campos en frontend y backend.
- Mensajes de éxito/error.

## Seguridad
- Validación de datos en backend (Laravel) y frontend (Vue).
- Uso de stored procedures para evitar SQL injection.
- Eliminar claves sólo si no están en uso (recomendación: agregar validación referencial en la base de datos).

## Flujo de Trabajo
1. El usuario accede a la página de claves de cuota.
2. Puede ver el listado, crear una nueva clave, editar o eliminar una existente.
3. Las operaciones se realizan vía API `/api/execute`.
4. El backend ejecuta el stored procedure correspondiente.
5. El frontend muestra el resultado y actualiza la vista.

## Errores Comunes
- Intentar crear una clave existente: retorna mensaje de error.
- Intentar eliminar una clave en uso: debe manejarse a nivel de base de datos o con validación adicional.

## Recomendaciones
- Agregar auditoría de cambios si es necesario.
- Validar integridad referencial en la base de datos.

# Esquema de la Tabla
```sql
CREATE TABLE ta_11_cve_cuota (
    clave_cuota INTEGER PRIMARY KEY,
    descripcion VARCHAR(60) NOT NULL
);
```
