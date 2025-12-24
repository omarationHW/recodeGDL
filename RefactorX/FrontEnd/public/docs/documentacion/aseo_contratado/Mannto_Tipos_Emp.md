# Documentación Técnica: Mannto_Tipos_Emp

## Análisis

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


## Casos de Uso

# Casos de Uso - Mannto_Tipos_Emp

**Categoría:** Form

## Caso de Uso 1: Alta de Tipo de Empresa

**Descripción:** El usuario desea registrar un nuevo tipo de empresa en el catálogo.

**Precondiciones:**
El usuario tiene permisos de administrador y no existe un tipo de empresa con la clave indicada.

**Pasos a seguir:**
1. El usuario accede a la página de Tipos de Empresa.
2. Hace clic en 'Nuevo Tipo de Empresa'.
3. Ingresa 'B' como tipo y 'Bares y Restaurantes' como descripción.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
El nuevo tipo de empresa aparece en la lista y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "tipo_empresa": "B", "descripcion": "Bares y Restaurantes" }

---

## Caso de Uso 2: Intento de Eliminación con Empresas Asociadas

**Descripción:** El usuario intenta eliminar un tipo de empresa que tiene empresas asociadas.

**Precondiciones:**
Existe al menos una empresa con ctrol_emp=2.

**Pasos a seguir:**
1. El usuario accede a la página de Tipos de Empresa.
2. Hace clic en 'Eliminar' sobre el tipo con ctrol_emp=2.
3. El sistema verifica si puede eliminar.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no se puede eliminar porque existen empresas asociadas.

**Datos de prueba:**
{ "ctrol_emp": 2 }

---

## Caso de Uso 3: Edición de Descripción de Tipo de Empresa

**Descripción:** El usuario edita la descripción de un tipo de empresa existente.

**Precondiciones:**
Existe un tipo de empresa con tipo_empresa='C'.

**Pasos a seguir:**
1. El usuario accede a la página de Tipos de Empresa.
2. Hace clic en 'Editar' sobre el tipo 'C'.
3. Cambia la descripción a 'Comercial Minorista'.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
La descripción se actualiza correctamente y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "tipo_empresa": "C", "descripcion": "Comercial Minorista" }

---



## Casos de Prueba

# Casos de Prueba: Catálogo de Tipos de Empresa

## 1. Alta exitosa
- **Entrada:** tipo_empresa='D', descripcion='Distribuidor'
- **Acción:** POST /api/execute { eRequest: 'TiposEmp.create', params: { tipo_empresa: 'D', descripcion: 'Distribuidor' } }
- **Esperado:** success=true, message='Tipo de empresa creado correctamente', el registro aparece en la lista

## 2. Alta duplicada
- **Entrada:** tipo_empresa='D', descripcion='Distribuidor'
- **Acción:** POST /api/execute { eRequest: 'TiposEmp.create', params: { tipo_empresa: 'D', descripcion: 'Distribuidor' } }
- **Esperado:** success=false, message='Ya existe el tipo de empresa'

## 3. Edición exitosa
- **Entrada:** tipo_empresa='D', descripcion='Distribuidor Mayorista'
- **Acción:** POST /api/execute { eRequest: 'TiposEmp.update', params: { tipo_empresa: 'D', descripcion: 'Distribuidor Mayorista' } }
- **Esperado:** success=true, message='Tipo de empresa actualizado correctamente'

## 4. Edición de tipo inexistente
- **Entrada:** tipo_empresa='Z', descripcion='Zoológico'
- **Acción:** POST /api/execute { eRequest: 'TiposEmp.update', params: { tipo_empresa: 'Z', descripcion: 'Zoológico' } }
- **Esperado:** success=false, message='No existe el tipo de empresa'

## 5. Eliminación exitosa
- **Precondición:** No existen empresas asociadas a ctrol_emp=10
- **Entrada:** ctrol_emp=10
- **Acción:** POST /api/execute { eRequest: 'TiposEmp.delete', params: { ctrol_emp: 10 } }
- **Esperado:** success=true, message='Tipo de empresa eliminado correctamente'

## 6. Eliminación con empresas asociadas
- **Precondición:** Existen empresas con ctrol_emp=2
- **Entrada:** ctrol_emp=2
- **Acción:** POST /api/execute { eRequest: 'TiposEmp.delete', params: { ctrol_emp: 2 } }
- **Esperado:** success=false, message='No se puede eliminar: existen empresas asociadas.'

## 7. Consulta de todos los tipos
- **Acción:** POST /api/execute { eRequest: 'TiposEmp.list' }
- **Esperado:** success=true, data=array de tipos de empresa

## 8. Consulta de tipo específico
- **Entrada:** tipo_empresa='A'
- **Acción:** POST /api/execute { eRequest: 'TiposEmp.get', params: { tipo_empresa: 'A' } }
- **Esperado:** success=true, data=registro correspondiente

## 9. Validación de eliminación permitida
- **Entrada:** ctrol_emp=99 (sin empresas asociadas)
- **Acción:** POST /api/execute { eRequest: 'TiposEmp.canDelete', params: { ctrol_emp: 99 } }
- **Esperado:** success=true, data.can_delete=true

## 10. Validación de eliminación NO permitida
- **Entrada:** ctrol_emp=1 (con empresas asociadas)
- **Acción:** POST /api/execute { eRequest: 'TiposEmp.canDelete', params: { ctrol_emp: 1 } }
- **Esperado:** success=true, data.can_delete=false


