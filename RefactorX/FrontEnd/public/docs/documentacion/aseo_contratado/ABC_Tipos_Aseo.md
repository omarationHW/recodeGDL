# DocumentaciÃ³n TÃ©cnica: ABC_Tipos_Aseo

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Catálogo de Tipos de Aseo (ABC_Tipos_Aseo)

## 1. Descripción General
Este módulo permite la administración del catálogo de Tipos de Aseo, incluyendo altas, bajas, cambios y consulta. La funcionalidad está migrada de Delphi a Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos y lógica de negocio).

## 2. Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures.

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "tipos_aseo.create|update|delete|list|get",
      "params": { ... }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": [ ... ]
    }
  }
  ```

## 4. Stored Procedures
- Toda la lógica de negocio (validaciones, reglas de negocio, restricciones) está en stored procedures de PostgreSQL.
- Los procedimientos devuelven un registro con `success` y `msg`.

## 5. Seguridad
- El usuario debe autenticarse (no incluido en este ejemplo, pero el campo `usuario` debe ser llenado correctamente).
- Validaciones de unicidad y restricciones de integridad se hacen en los SP.

## 6. Frontend
- Página independiente para Tipos de Aseo.
- Tabla con selección de fila.
- Botones para Alta, Edición, Baja, Refrescar.
- Modal para formulario de alta/edición/baja.
- Mensajes de éxito/error.

## 7. Backend
- Controlador Laravel único (`ExecuteController`) que enruta la acción a los SP correspondientes.
- Todas las acciones usan el endpoint `/api/execute`.

## 8. Base de Datos
- Tabla principal: `ta_16_tipo_aseo`
- Tabla de referencia: `ta_16_ctas_aplicacion` (para validar cta_aplicacion)
- Restricción: No se puede borrar un tipo de aseo si tiene contratos asociados.

## 9. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- Los SP pueden ser versionados y auditados.

## 10. Pruebas
- Casos de uso y pruebas incluidas para asegurar la funcionalidad.

---


## Casos de Prueba

## Casos de Prueba para ABC_Tipos_Aseo

### 1. Alta exitosa
- **Entrada:** tipo_aseo='Z', descripcion='Aseo Zona Z', cta_aplicacion=100001, usuario=1
- **Acción:** tipos_aseo.create
- **Esperado:** success=true, mensaje de éxito, registro aparece en la lista

### 2. Alta duplicada
- **Entrada:** tipo_aseo='O', descripcion='Aseo Ordinario', cta_aplicacion=100001, usuario=1
- **Acción:** tipos_aseo.create
- **Esperado:** success=false, mensaje 'Ya existe el tipo de aseo'

### 3. Alta con cuenta de aplicación inexistente
- **Entrada:** tipo_aseo='Y', descripcion='Aseo Y', cta_aplicacion=999999, usuario=1
- **Acción:** tipos_aseo.create
- **Esperado:** success=false, mensaje 'La cuenta de aplicación no existe'

### 4. Edición exitosa
- **Entrada:** ctrol_aseo=3, tipo_aseo='H', descripcion='Aseo Hospitalario Mod', cta_aplicacion=100002, usuario=1
- **Acción:** tipos_aseo.update
- **Esperado:** success=true, mensaje de éxito, datos actualizados

### 5. Edición con cuenta de aplicación inexistente
- **Entrada:** ctrol_aseo=3, tipo_aseo='H', descripcion='Aseo Hospitalario Mod', cta_aplicacion=999999, usuario=1
- **Acción:** tipos_aseo.update
- **Esperado:** success=false, mensaje 'La cuenta de aplicación no existe'

### 6. Eliminación exitosa
- **Entrada:** ctrol_aseo=12, usuario=1 (sin contratos asociados)
- **Acción:** tipos_aseo.delete
- **Esperado:** success=true, mensaje de éxito

### 7. Eliminación fallida por contratos asociados
- **Entrada:** ctrol_aseo=2, usuario=1 (con contratos asociados)
- **Acción:** tipos_aseo.delete
- **Esperado:** success=false, mensaje 'Existen contratos con este tipo de aseo. No se puede borrar.'

### 8. Consulta de lista
- **Acción:** tipos_aseo.list
- **Esperado:** success=true, data es arreglo de registros

### 9. Consulta individual
- **Entrada:** ctrol_aseo=2
- **Acción:** tipos_aseo.get
- **Esperado:** success=true, data es el registro solicitado


## Casos de Uso

# Casos de Uso - ABC_Tipos_Aseo

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo Tipo de Aseo

**Descripción:** El usuario desea agregar un nuevo tipo de aseo al catálogo.

**Precondiciones:**
El usuario tiene permisos de administrador. La cuenta de aplicación existe.

**Pasos a seguir:**
1. El usuario accede a la página de Tipos de Aseo.
2. Hace clic en 'Alta'.
3. Llena los campos: Tipo de Aseo (ej: 'X'), Descripción (ej: 'Aseo Experimental'), Cta. Aplicación (ej: 123456).
4. Hace clic en 'Guardar'.

**Resultado esperado:**
El nuevo tipo de aseo aparece en la lista y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "tipo_aseo": "X", "descripcion": "Aseo Experimental", "cta_aplicacion": 123456, "usuario": 1 }

---

## Caso de Uso 2: Edición de un Tipo de Aseo existente

**Descripción:** El usuario edita la descripción y cuenta de aplicación de un tipo de aseo.

**Precondiciones:**
Existe un tipo de aseo con ctrol_aseo=5.

**Pasos a seguir:**
1. El usuario selecciona el registro con ctrol_aseo=5.
2. Hace clic en 'Editar'.
3. Modifica la descripción y/o cta_aplicacion.
4. Hace clic en 'Actualizar'.

**Resultado esperado:**
El registro se actualiza correctamente y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "ctrol_aseo": 5, "tipo_aseo": "O", "descripcion": "Aseo Ordinario Modificado", "cta_aplicacion": 654321, "usuario": 1 }

---

## Caso de Uso 3: Eliminación de un Tipo de Aseo sin contratos asociados

**Descripción:** El usuario elimina un tipo de aseo que no tiene contratos asociados.

**Precondiciones:**
Existe un tipo de aseo con ctrol_aseo=10 y no tiene contratos.

**Pasos a seguir:**
1. El usuario selecciona el registro con ctrol_aseo=10.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
El registro se elimina y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "ctrol_aseo": 10, "usuario": 1 }

---



---
**Componente:** `ABC_Tipos_Aseo.vue`
**MÃ³dulo:** `aseo_contratado`

