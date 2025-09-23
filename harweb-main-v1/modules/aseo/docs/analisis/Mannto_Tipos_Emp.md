# Documentación Técnica: Catálogo de Tipos de Empresa (Mannto_Tipos_Emp)

## Descripción General
Este módulo permite la administración del catálogo de Tipos de Empresa, incluyendo alta, modificación, consulta y eliminación, asegurando integridad referencial con las empresas asociadas. La migración implementa un endpoint API unificado, lógica de negocio en stored procedures PostgreSQL, y una interfaz Vue.js como página independiente.

## Arquitectura
- **Backend:** Laravel (PHP) + PostgreSQL
- **Frontend:** Vue.js (SPA, página independiente)
- **API:** Endpoint único `/api/execute` usando patrón eRequest/eResponse
- **Base de datos:** PostgreSQL, lógica de negocio en stored procedures

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato:**
  ```json
  {
    "eRequest": "TiposEmp.create|TiposEmp.update|TiposEmp.delete|TiposEmp.list|TiposEmp.get|TiposEmp.canDelete",
    "params": { ... }
  }
  ```
- **Respuesta:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": ...
    }
  }
  ```

## Operaciones Soportadas
- `TiposEmp.list`: Lista todos los tipos de empresa
- `TiposEmp.get`: Obtiene un tipo de empresa por clave
- `TiposEmp.create`: Crea un nuevo tipo de empresa
- `TiposEmp.update`: Actualiza la descripción de un tipo de empresa
- `TiposEmp.delete`: Elimina un tipo de empresa (si no tiene empresas asociadas)
- `TiposEmp.canDelete`: Verifica si un tipo de empresa puede ser eliminado

## Validaciones y Reglas de Negocio
- No se puede crear un tipo de empresa con clave duplicada
- No se puede eliminar un tipo de empresa si existen empresas asociadas
- La clave de tipo de empresa es de un solo carácter
- La descripción es obligatoria y máximo 80 caracteres

## Seguridad
- Todas las operaciones deben estar autenticadas (middleware Laravel, no incluido aquí)
- El endpoint debe validar los parámetros recibidos

## Integridad Referencial
- Antes de eliminar, se verifica que no existan empresas asociadas (ver stored procedure `sp_tipos_emp_can_delete`)

## Frontend
- Página Vue.js independiente
- Tabla con listado, botones de editar y eliminar
- Modal para alta/edición
- Validación de campos en frontend y backend
- Mensajes de error claros
- Navegación breadcrumb

## Backend
- Controlador Laravel centralizado (`ExecuteController`)
- Lógica de negocio en stored procedures PostgreSQL
- Todas las operaciones usan transacciones implícitas

## Ejemplo de Uso
### Crear tipo de empresa
```json
{
  "eRequest": "TiposEmp.create",
  "params": {
    "tipo_empresa": "A",
    "descripcion": "Agroindustrial"
  }
}
```

### Eliminar tipo de empresa
```json
{
  "eRequest": "TiposEmp.delete",
  "params": {
    "ctrol_emp": 5
  }
}
```

## Migración de Queries
- Todas las queries y lógica de validación de la versión Delphi han sido migradas a stored procedures y funciones PostgreSQL.
- El controlador Laravel invoca los SPs y retorna el resultado en formato eResponse.

## Consideraciones
- El campo `ctrol_emp` es autoincremental (usar `DEFAULT` en insert)
- El campo `tipo_empresa` es clave lógica (único, 1 carácter)
- El frontend asume que la API retorna errores y mensajes claros

# Fin de Documentación
