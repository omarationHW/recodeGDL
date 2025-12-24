# Documentación Técnica: Cons_Tipos_Emp

## Análisis

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


## Casos de Uso

# Casos de Uso - Cons_Tipos_Emp

**Categoría:** Form

## Caso de Uso 1: Consulta de Tipos de Empresa ordenados por Descripción

**Descripción:** El usuario desea ver todos los tipos de empresa ordenados alfabéticamente por descripción.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Tipos de Empresa.
2. Selecciona 'Descripción' en el selector de orden.
3. El sistema envía una petición a /api/execute con action='list' y order='descripcion'.
4. El backend retorna la lista ordenada.

**Resultado esperado:**
La tabla muestra todos los tipos de empresa ordenados por descripción.

**Datos de prueba:**
Tipos existentes: [ctrol_emp:1, tipo_empresa:'P', descripcion:'Privada'], [ctrol_emp:2, tipo_empresa:'G', descripcion:'Gobierno']

---

## Caso de Uso 2: Alta de un nuevo Tipo de Empresa

**Descripción:** El usuario desea agregar un nuevo tipo de empresa llamado 'Mixto'.

**Precondiciones:**
El usuario está autenticado y tiene permisos de alta.

**Pasos a seguir:**
1. El usuario hace clic en 'Nuevo Tipo'.
2. Ingresa tipo_empresa='M', descripcion='Mixto'.
3. Hace clic en 'Crear'.
4. El sistema envía una petición a /api/execute con action='create'.
5. El backend ejecuta el SP y retorna el nuevo registro.

**Resultado esperado:**
El nuevo tipo de empresa aparece en la tabla.

**Datos de prueba:**
tipo_empresa: 'M', descripcion: 'Mixto'

---

## Caso de Uso 3: Intento de eliminación de Tipo de Empresa con empresas asociadas

**Descripción:** El usuario intenta eliminar un tipo de empresa que tiene empresas asociadas.

**Precondiciones:**
Existe al menos una empresa con ctrol_emp=1.

**Pasos a seguir:**
1. El usuario hace clic en eliminar sobre el tipo de empresa con ctrol_emp=1.
2. El sistema envía una petición a /api/execute con action='delete' y ctrol_emp=1.
3. El backend ejecuta el SP, detecta empresas asociadas y retorna error.

**Resultado esperado:**
El sistema muestra un mensaje de error: 'No se puede eliminar: existen empresas asociadas.'

**Datos de prueba:**
ctrol_emp: 1 (con empresas asociadas)

---



## Casos de Prueba

# Casos de Prueba: Cons_Tipos_Emp

## 1. Consulta básica
- Acción: list
- Parámetro: order = 'ctrol_emp'
- Esperado: Lista de todos los tipos de empresa ordenados por control

## 2. Consulta por descripción
- Acción: list
- Parámetro: order = 'descripcion'
- Esperado: Lista ordenada alfabéticamente por descripción

## 3. Alta exitosa
- Acción: create
- Parámetros: tipo_empresa = 'M', descripcion = 'Mixto'
- Esperado: Registro creado, success=true, data contiene el nuevo registro

## 4. Alta inválida (sin descripción)
- Acción: create
- Parámetros: tipo_empresa = 'X', descripcion = ''
- Esperado: success=false, message indica error de validación

## 5. Edición exitosa
- Acción: update
- Parámetros: ctrol_emp=2, tipo_empresa='G', descripcion='Gobierno Federal'
- Esperado: Registro actualizado, success=true

## 6. Eliminación exitosa (sin empresas asociadas)
- Acción: delete
- Parámetros: ctrol_emp=3
- Precondición: No existen empresas con ctrol_emp=3
- Esperado: success=true, message='Eliminado correctamente.'

## 7. Eliminación fallida (con empresas asociadas)
- Acción: delete
- Parámetros: ctrol_emp=1
- Precondición: Existen empresas con ctrol_emp=1
- Esperado: success=false, message='No se puede eliminar: existen empresas asociadas.'

## 8. Exportación
- Acción: export
- Parámetro: order = 'tipo_empresa'
- Esperado: Datos exportados en formato CSV/Excel


