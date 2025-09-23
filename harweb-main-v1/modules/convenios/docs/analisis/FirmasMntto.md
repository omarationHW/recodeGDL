# Documentación Técnica: Migración de FirmasMntto (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al mantenimiento del catálogo de firmas de recaudadoras (`ta_17_firmaconv`). Permite listar, crear, editar y eliminar registros de firmas, cada uno asociado a una recaudadora y sus responsables.

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint unificado `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Vue.js SPA (Single Page Application), cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato:**
  ```json
  {
    "action": "firmas.create|firmas.update|firmas.delete|firmas.list|firmas.get",
    "params": { ... }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true|false,
    "message": "...",
    "data": { ... }
  }
  ```

## 4. Stored Procedures
- **sp_firmas_create:** Inserta un registro.
- **sp_firmas_update:** Actualiza un registro.
- **sp_firmas_delete:** Elimina un registro.

## 5. Validaciones
- Todos los campos son obligatorios.
- `recaudadora` es clave primaria (entero).
- `letras` máximo 3 caracteres.
- Todos los nombres y cargos máximo 100 caracteres.

## 6. Seguridad
- El endpoint debe estar protegido por autenticación (Laravel Sanctum o JWT recomendado).
- Validar permisos de usuario para acceso a mantenimiento de catálogos.

## 7. Frontend (Vue.js)
- Página independiente para mantenimiento de firmas.
- Listado con acciones de editar y eliminar.
- Formulario para alta/modificación.
- Mensajes de éxito/error.
- Navegación breadcrumb.

## 8. Integración
- El frontend consume el endpoint `/api/execute` usando fetch/AJAX.
- El backend ejecuta el stored procedure correspondiente según la acción.

## 9. Ejemplo de Request
### Crear Firma
```json
{
  "action": "firmas.create",
  "params": {
    "recaudadora": 1,
    "titular": "JUAN PEREZ",
    "cargotitular": "DIRECTOR",
    "recaudador": "MARIA LOPEZ",
    "cargorecaudador": "RECAUDADOR",
    "testigo1": "PEDRO RAMIREZ",
    "testigo2": "ANA GARCIA",
    "letras": "ZC1"
  }
}
```

## 10. Migración de SQL
- Todas las operaciones de inserción, actualización y borrado se realizan vía stored procedures.
- El frontend nunca accede directamente a la base de datos.

## 11. Consideraciones
- El campo `recaudadora` debe existir en el catálogo de recaudadoras.
- El campo `letras` debe ser único por recaudadora.
- El sistema debe manejar errores de integridad y mostrar mensajes claros al usuario.

## 12. Pruebas
- Ver sección de Casos de Uso y Casos de Prueba.
