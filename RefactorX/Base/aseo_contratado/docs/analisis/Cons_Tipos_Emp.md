# Documentación Técnica: Migración Formulario Cons_Tipos_Emp (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la consulta y administración del catálogo de Tipos de Empresa (`ta_16_tipos_emp`). Permite listar, crear, editar y eliminar tipos de empresa, respetando las restricciones de integridad referencial (no se puede eliminar si existen empresas asociadas).

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Componente Vue.js como página independiente
- **Base de Datos:** PostgreSQL con stored procedures para toda la lógica de negocio

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Payload:**
  ```json
  {
    "action": "list|create|update|delete|export",
    "params": { ... },
    "resource": "ConsTiposEmp"
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true|false,
    "data": [ ... ],
    "message": "..."
  }
  ```

## 4. Stored Procedures
- **sp16_tipos_emp_create:** Inserta un nuevo tipo de empresa
- **sp16_tipos_emp_update:** Actualiza un tipo de empresa existente
- **sp16_tipos_emp_delete:** Elimina un tipo de empresa si no tiene empresas asociadas

## 5. Validaciones
- `tipo_empresa`: Obligatorio, máximo 1 carácter
- `descripcion`: Obligatorio, máximo 80 caracteres
- No se puede eliminar un tipo de empresa si existen empresas asociadas

## 6. Seguridad
- Todas las operaciones requieren autenticación (middleware Laravel)
- Validación de parámetros en backend
- Sanitización de campos de ordenamiento

## 7. Frontend
- Página Vue.js independiente
- Tabla con ordenamiento por columna
- Modal para crear/editar
- Exportación a Excel (CSV)
- Acciones CRUD con confirmación

## 8. Integración
- El frontend consume el endpoint `/api/execute` con el recurso `ConsTiposEmp`
- El backend enruta la petición al controlador y ejecuta el stored procedure correspondiente

## 9. Consideraciones
- El campo `ctrol_emp` es autoincremental (serial)
- El ordenamiento solo permite los campos definidos
- El borrado es seguro: si hay empresas asociadas, retorna error

## 10. Ejemplo de llamada API
```json
{
  "action": "create",
  "params": {
    "tipo_empresa": "P",
    "descripcion": "Privada"
  },
  "resource": "ConsTiposEmp"
}
```

## 11. Ejemplo de respuesta
```json
{
  "success": true,
  "data": {
    "ctrol_emp": 5,
    "tipo_empresa": "P",
    "descripcion": "Privada"
  },
  "message": ""
}
```
