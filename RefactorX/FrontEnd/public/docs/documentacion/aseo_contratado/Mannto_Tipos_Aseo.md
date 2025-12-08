# Documentación Técnica: Mannto_Tipos_Aseo

## Análisis

# Documentación Técnica: Migración de Mannto_Tipos_Aseo (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel API, endpoint único `/api/execute` (eRequest/eResponse)
- **Frontend:** Vue.js SPA, cada formulario es una página independiente
- **Base de Datos:** PostgreSQL, toda la lógica de negocio en stored procedures
- **Patrón de integración:**
  - El frontend envía requests a `/api/execute` con `{ action, data }`
  - El backend interpreta `action` y llama al stored procedure correspondiente
  - El backend retorna `{ success, message, data }`

## Endpoints y Acciones
- `/api/execute` (POST)
  - `action: list` → Lista todos los tipos de aseo
  - `action: get` → Obtiene un tipo de aseo por clave
  - `action: create` → Crea un nuevo tipo de aseo
  - `action: update` → Actualiza un tipo de aseo
  - `action: delete` → Elimina un tipo de aseo
  - `action: validate_cta_aplicacion` → Valida existencia de cuenta de aplicación

## Validaciones
- No se permite crear un tipo de aseo con clave repetida
- No se permite crear/actualizar si la cuenta de aplicación no existe
- No se permite eliminar si existen contratos asociados

## Stored Procedures
- Toda la lógica de negocio y validación reside en los SPs
- El controlador Laravel solo enruta y valida datos básicos

## Frontend
- Página independiente `/tipos-aseo`
- Tabla de consulta, botones de alta/edición/eliminación
- Formulario modal para alta/edición
- Validación en frontend y backend
- Navegación breadcrumb

## Seguridad
- Se recomienda proteger `/api/execute` con autenticación JWT o similar
- Validar permisos de usuario en el backend si aplica

## Errores y Mensajes
- Todos los errores de negocio se retornan en el campo `message` del JSON
- El frontend muestra los mensajes al usuario

## Ejemplo de Request/Response
### Crear tipo de aseo
```json
POST /api/execute
{
  "action": "create",
  "data": {
    "tipo_aseo": "H",
    "descripcion": "Hospitalario",
    "cta_aplicacion": 12345
  }
}
```

### Respuesta
```json
{
  "success": true,
  "message": "Tipo de aseo creado correctamente",
  "data": { "success": true, "message": "Tipo de aseo creado correctamente", "ctrol_aseo": 5 }
}
```

## Estructura de la Tabla
```sql
CREATE TABLE ta_16_tipo_aseo (
    ctrol_aseo serial PRIMARY KEY,
    tipo_aseo varchar(1) UNIQUE NOT NULL,
    descripcion varchar(80) NOT NULL,
    cta_aplicacion integer NOT NULL
);
```

## Integración con Contratos
- Antes de eliminar un tipo de aseo, se verifica que no existan contratos con ese tipo

## Navegación
- El componente Vue es una página completa, sin tabs ni subcomponentes
- Navegación por rutas (ej: `/tipos-aseo`)

## Pruebas
- Se recomienda usar Postman para probar el endpoint `/api/execute`
- El frontend puede ser probado con Cypress o Jest


## Casos de Uso

# Casos de Uso - Mannto_Tipos_Aseo

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo Tipo de Aseo

**Descripción:** El usuario desea registrar un nuevo tipo de aseo con clave 'H', descripción 'Hospitalario' y cuenta de aplicación existente.

**Precondiciones:**
El usuario tiene permisos de alta. La cuenta de aplicación 12345 existe.

**Pasos a seguir:**
- El usuario accede a la página de Tipos de Aseo
- Hace clic en 'Nuevo Tipo de Aseo'
- Llena el formulario: Tipo: 'H', Descripción: 'Hospitalario', Cta. Aplicación: 12345
- Presiona 'Guardar'

**Resultado esperado:**
El registro se crea, aparece en la tabla y se muestra mensaje de éxito.

**Datos de prueba:**
{ "tipo_aseo": "H", "descripcion": "Hospitalario", "cta_aplicacion": 12345 }

---

## Caso de Uso 2: Intento de eliminar un Tipo de Aseo con contratos asociados

**Descripción:** El usuario intenta eliminar un tipo de aseo que ya está en uso por contratos.

**Precondiciones:**
Existe un tipo de aseo 'O' con contratos asociados.

**Pasos a seguir:**
- El usuario accede a la página de Tipos de Aseo
- Hace clic en 'Eliminar' sobre el tipo 'O'
- Confirma la eliminación

**Resultado esperado:**
El sistema muestra un mensaje de error: 'Existen contratos con este tipo de aseo. No se puede eliminar.'

**Datos de prueba:**
{ "tipo_aseo": "O" }

---

## Caso de Uso 3: Validación de cuenta de aplicación inexistente

**Descripción:** El usuario intenta crear un tipo de aseo con una cuenta de aplicación que no existe.

**Precondiciones:**
La cuenta de aplicación 999999 no existe.

**Pasos a seguir:**
- El usuario accede a la página de Tipos de Aseo
- Hace clic en 'Nuevo Tipo de Aseo'
- Llena el formulario: Tipo: 'Z', Descripción: 'Zona X', Cta. Aplicación: 999999
- Presiona 'Guardar'

**Resultado esperado:**
El sistema muestra un mensaje de error: 'La cuenta de aplicación no existe'

**Datos de prueba:**
{ "tipo_aseo": "Z", "descripcion": "Zona X", "cta_aplicacion": 999999 }

---



## Casos de Prueba

# Casos de Prueba para Mannto_Tipos_Aseo

## 1. Alta exitosa
- **Input:** { "action": "create", "data": { "tipo_aseo": "H", "descripcion": "Hospitalario", "cta_aplicacion": 12345 } }
- **Resultado esperado:** success=true, message='Tipo de aseo creado correctamente', data.ctrol_aseo > 0

## 2. Alta duplicada
- **Input:** { "action": "create", "data": { "tipo_aseo": "H", "descripcion": "Hospitalario", "cta_aplicacion": 12345 } }
- **Resultado esperado:** success=false, message='Ya existe el tipo de aseo'

## 3. Alta con cuenta de aplicación inexistente
- **Input:** { "action": "create", "data": { "tipo_aseo": "X", "descripcion": "Prueba", "cta_aplicacion": 999999 } }
- **Resultado esperado:** success=false, message='La cuenta de aplicación no existe'

## 4. Edición exitosa
- **Input:** { "action": "update", "data": { "tipo_aseo": "H", "descripcion": "Hospitalario Modificado", "cta_aplicacion": 12345 } }
- **Resultado esperado:** success=true, message='Tipo de aseo actualizado correctamente'

## 5. Eliminación exitosa (sin contratos asociados)
- **Input:** { "action": "delete", "data": { "tipo_aseo": "Z" } }
- **Resultado esperado:** success=true, message='Tipo de aseo eliminado correctamente'

## 6. Eliminación fallida (con contratos asociados)
- **Input:** { "action": "delete", "data": { "tipo_aseo": "O" } }
- **Resultado esperado:** success=false, message='Existen contratos con este tipo de aseo. No se puede eliminar.'

## 7. Validación de cuenta de aplicación existente
- **Input:** { "action": "validate_cta_aplicacion", "data": { "cta_aplicacion": 12345 } }
- **Resultado esperado:** success=true

## 8. Validación de cuenta de aplicación inexistente
- **Input:** { "action": "validate_cta_aplicacion", "data": { "cta_aplicacion": 999999 } }
- **Resultado esperado:** success=false


