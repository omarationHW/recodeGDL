# Documentación Técnica: Migración de Formulario frmindiv (Construcciones Individuales)

## 1. Descripción General
Este módulo permite la consulta, alta, edición y baja lógica de construcciones individuales asociadas a una clave catastral (cvecatnva) y subpredio, migrando la funcionalidad del formulario Delphi `frmindiv` a una arquitectura moderna Laravel + Vue.js + PostgreSQL.

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js de página completa, sin tabs, con navegación y formulario CRUD.
- **Base de Datos:** PostgreSQL, con stored procedures para todas las operaciones.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "list|get|create|update|delete",
    "params": { ... }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true|false,
    "data": ..., // resultado
    "message": "..."
  }
  ```

## 4. Métodos Disponibles
- `list`: Lista todas las construcciones individuales para una clave catastral.
- `get`: Obtiene una construcción individual por ID.
- `create`: Crea una nueva construcción individual.
- `update`: Actualiza una construcción individual existente.
- `delete`: Marca como no vigente una construcción individual.

## 5. Validaciones
- La clave catastral (`cvecatnva`) debe tener 11 caracteres.
- El subpredio debe ser mayor a 0.
- Los campos numéricos deben ser válidos y positivos.
- No se permite eliminar físicamente, sólo marcar como no vigente (`vigente = 'C'`).

## 6. Seguridad
- Todas las operaciones deben estar autenticadas (middleware Laravel, no incluido aquí).
- Validación de parámetros en backend y frontend.

## 7. Stored Procedures
- Todas las operaciones CRUD y de consulta se realizan mediante stored procedures en PostgreSQL.
- Los procedimientos devuelven datos en formato tabla o VOID según corresponda.

## 8. Frontend (Vue.js)
- Página única para consulta y edición.
- Tabla de resultados y formulario de alta/edición.
- Navegación breadcrumb.
- Mensajes de error y validación en tiempo real.

## 9. Integración
- El componente Vue.js consume el endpoint `/api/execute` para todas las operaciones.
- El backend enruta la acción al método correspondiente y ejecuta el stored procedure.

## 10. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- Los stored procedures pueden ser extendidos para lógica adicional (auditoría, triggers, etc).

# Esquema de Tabla `construc`
```sql
CREATE TABLE construc (
    id SERIAL PRIMARY KEY,
    cvecatnva VARCHAR(11) NOT NULL,
    subpredio SMALLINT NOT NULL,
    cvebloque SMALLINT NOT NULL,
    axoconst SMALLINT NOT NULL,
    areaconst FLOAT NOT NULL,
    cveclasif INT NOT NULL,
    cvecuenta INT NOT NULL,
    estructura SMALLINT,
    factorajus FLOAT,
    numpisos SMALLINT,
    importe NUMERIC,
    cveavaluo INT,
    axovig SMALLINT,
    vigente VARCHAR(1) NOT NULL DEFAULT 'V'
);
```

# 11. Manejo de Errores
- Todos los errores de validación y de base de datos se devuelven en el campo `message` del response.

# 12. Consideraciones de Migración
- El formulario Delphi usaba DataSource y DBGrid; la migración usa API REST y frontend SPA.
- La lógica de apertura/cierre de queries se traduce en llamadas a stored procedures.
- El cierre lógico (vigente = 'C') reemplaza el borrado físico.

# 13. Pruebas y QA
- Se proveen casos de uso y casos de prueba para asegurar la funcionalidad y la migración fiel.
