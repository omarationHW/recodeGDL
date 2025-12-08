# DocumentaciÃ³n TÃ©cnica: ABC_Tipos_Emp

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración ABC_Tipos_Emp Delphi a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel API, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend**: Vue.js SPA, cada formulario es una página independiente
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures

## API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Request**:
  - `action`: string (ej: 'list_tipos_emp', 'create_tipos_emp', ...)
  - `payload`: objeto con los parámetros necesarios
- **Response**:
  - `success`: boolean
  - `data`: resultado de la operación
  - `message`: mensaje de error o éxito

## Métodos soportados (acciones)
- `list_tipos_emp`: Lista todos los tipos de empresa
- `get_tipos_emp`: Obtiene un tipo de empresa por su clave
- `create_tipos_emp`: Crea un nuevo tipo de empresa
- `update_tipos_emp`: Actualiza un tipo de empresa
- `delete_tipos_emp`: Elimina un tipo de empresa (si no tiene empresas asociadas)

## Stored Procedures
- Toda la lógica de negocio y validación reside en los SPs de PostgreSQL
- Los SPs devuelven siempre un resultado estructurado (éxito, mensaje, datos)

## Vue.js
- Página independiente `/tipos-emp` (ruta sugerida)
- Tabla con listado, botones de alta, edición y baja
- Formularios modales para alta/edición
- Mensajes de error y éxito
- Navegación breadcrumb

## Seguridad
- Validación de datos en backend y frontend
- Eliminar solo si no hay empresas asociadas

## Consideraciones de Migración
- El flujo de Delphi se respeta: recarga de tabla tras cada operación
- No se usan tabs ni componentes tabulares: cada formulario es una página
- El endpoint es único y centralizado

## Ejemplo de Request
```json
{
  "action": "create_tipos_emp",
  "payload": {
    "ctrol_emp": 10,
    "tipo_empresa": "P",
    "descripcion": "Privada"
  }
}
```

## Ejemplo de Response
```json
{
  "success": true,
  "data": [{"success": true, "message": "Tipo de empresa creado correctamente"}],
  "message": ""
}
```

## Validaciones
- No se permite duplicar `ctrol_emp`
- No se puede eliminar si existen empresas asociadas
- Todos los campos son obligatorios

## Errores comunes
- Si se intenta eliminar un tipo con empresas asociadas, el SP devuelve error y el frontend lo muestra

## Extensibilidad
- El patrón eRequest/eResponse permite agregar más acciones sin cambiar el endpoint
- Los SPs pueden evolucionar sin modificar el frontend


## Casos de Prueba

# Casos de Prueba para ABC_Tipos_Emp

## 1. Alta exitosa
- **Acción:** create_tipos_emp
- **Payload:** { "ctrol_emp": 20, "tipo_empresa": "X", "descripcion": "Experimental" }
- **Resultado esperado:** success=true, message='Tipo de empresa creado correctamente', el registro aparece en el listado.

## 2. Alta duplicada
- **Acción:** create_tipos_emp
- **Payload:** { "ctrol_emp": 20, "tipo_empresa": "X", "descripcion": "Experimental" }
- **Resultado esperado:** success=false, message='Ya existe un tipo de empresa con ese control'.

## 3. Edición exitosa
- **Acción:** update_tipos_emp
- **Payload:** { "ctrol_emp": 20, "tipo_empresa": "Y", "descripcion": "Experimental Modificado" }
- **Resultado esperado:** success=true, message='Tipo de empresa actualizado correctamente', el registro se actualiza.

## 4. Eliminación exitosa (sin empresas asociadas)
- **Acción:** delete_tipos_emp
- **Payload:** { "ctrol_emp": 20 }
- **Resultado esperado:** success=true, message='Tipo de empresa eliminado correctamente', el registro desaparece del listado.

## 5. Eliminación fallida (con empresas asociadas)
- **Acción:** delete_tipos_emp
- **Payload:** { "ctrol_emp": 9 }
- **Resultado esperado:** success=false, message='No se puede eliminar: existen empresas asociadas a este tipo'.

## 6. Consulta individual
- **Acción:** get_tipos_emp
- **Payload:** { "ctrol_emp": 10 }
- **Resultado esperado:** success=true, data contiene el registro correspondiente.

## 7. Listado general
- **Acción:** list_tipos_emp
- **Payload:** { }
- **Resultado esperado:** success=true, data contiene todos los tipos de empresa ordenados por ctrol_emp.


## Casos de Uso

# Casos de Uso - ABC_Tipos_Emp

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo Tipo de Empresa

**Descripción:** El usuario desea agregar un nuevo tipo de empresa al catálogo.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para modificar el catálogo.

**Pasos a seguir:**
1. El usuario navega a la página de Tipos de Empresa.
2. Hace clic en 'Agregar Tipo'.
3. Llena los campos: Control=10, Tipo=P, Descripción=Privada.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
El nuevo tipo de empresa aparece en la tabla y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "ctrol_emp": 10, "tipo_empresa": "P", "descripcion": "Privada" }

---

## Caso de Uso 2: Edición de un Tipo de Empresa existente

**Descripción:** El usuario necesita modificar la descripción de un tipo de empresa.

**Precondiciones:**
Existe un tipo de empresa con ctrol_emp=10.

**Pasos a seguir:**
1. El usuario localiza el registro con Control=10.
2. Hace clic en 'Editar'.
3. Cambia la descripción a 'Privada Actualizada'.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
El registro se actualiza y la tabla muestra la nueva descripción.

**Datos de prueba:**
{ "ctrol_emp": 10, "tipo_empresa": "P", "descripcion": "Privada Actualizada" }

---

## Caso de Uso 3: Intento de eliminar un Tipo de Empresa con empresas asociadas

**Descripción:** El usuario intenta eliminar un tipo de empresa que tiene empresas asociadas.

**Precondiciones:**
Existe un tipo de empresa con ctrol_emp=9 y al menos una empresa asociada.

**Pasos a seguir:**
1. El usuario localiza el registro con Control=9.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
El sistema muestra un mensaje de error: 'No se puede eliminar: existen empresas asociadas a este tipo'.

**Datos de prueba:**
{ "ctrol_emp": 9 }

---



---
**Componente:** `ABC_Tipos_Emp.vue`
**MÃ³dulo:** `aseo_contratado`

