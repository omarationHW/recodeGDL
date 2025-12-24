# Documentación Técnica: Mannto_Recaudadoras

## Análisis

# Documentación Técnica: Migración de Mannto_Recaudadoras (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel (PHP 8+), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js SPA, cada formulario es una página independiente
- **Base de Datos:** PostgreSQL, lógica de negocio crítica en stored procedures
- **Seguridad:** Validación de datos en backend y frontend, manejo de errores y mensajes claros

## API Unificada `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "list|get|create|update|delete",
    "payload": { ... }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true|false,
    "data": [ ... ] | null,
    "message": "..."
  }
  ```

## Controlador Laravel
- Un solo método `execute` que despacha según el campo `action`.
- Llama a los stored procedures PostgreSQL para las operaciones de negocio.
- Valida datos y retorna mensajes de error claros.
- Ejemplo de uso:
  - `action: 'list'` → lista todas las recaudadoras
  - `action: 'create'` → crea una nueva recaudadora
  - `action: 'update'` → actualiza una recaudadora
  - `action: 'delete'` → elimina una recaudadora (si no tiene contratos)

## Componente Vue.js
- Página independiente para el catálogo de recaudadoras
- Modo lista y modo formulario (alta/edición)
- Navegación breadcrumb
- Validación de campos en frontend
- Llama al endpoint `/api/execute` para todas las operaciones
- Mensajes de éxito/error claros

## Stored Procedures PostgreSQL
- Toda la lógica de negocio crítica (altas, bajas, cambios) está en SPs
- Validan reglas de negocio (no duplicados, no borrar si hay contratos, etc.)
- Manejan errores con `RAISE EXCEPTION` para que Laravel los capture

## Flujo de Operación
1. Usuario accede a la página de recaudadoras (Vue)
2. Vue llama a `/api/execute` con `action: 'list'` para mostrar la tabla
3. Para alta/edición, Vue muestra formulario y envía `action: 'create'` o `action: 'update'`
4. Laravel valida y llama al SP correspondiente
5. Para baja, Vue pide confirmación y envía `action: 'delete'`
6. Laravel verifica que no existan contratos asociados antes de eliminar

## Validaciones
- **num_rec**: obligatorio, entero, único
- **descripcion**: obligatorio, string, máximo 80 caracteres
- No se puede eliminar una recaudadora si tiene contratos asociados

## Seguridad
- Validación de datos en backend y frontend
- Manejo de errores y mensajes claros
- (Opcional) Autenticación de usuario en endpoints

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente
- Los SPs pueden evolucionar sin cambiar el frontend

## Ejemplo de Request/Response
### Alta
```json
{
  "action": "create",
  "payload": { "num_rec": 5, "descripcion": "Recaudadora Norte" }
}
```
Respuesta:
```json
{
  "success": true,
  "message": "Recaudadora creada correctamente."
}
```

### Baja (con contratos asociados)
```json
{
  "action": "delete",
  "payload": { "num_rec": 1 }
}
```
Respuesta:
```json
{
  "success": false,
  "message": "EXISTEN CONTRATOS CON ESTA RECAUDADORA. POR LO TANTO NO LO PUEDES BORRAR, INTENTA CON OTRA."
}
```

## Migración de Lógica Delphi
- El flujo de altas, bajas y cambios se respeta fielmente
- Las validaciones y mensajes de error se mantienen
- El frontend reproduce la experiencia de usuario original, pero modernizada

## Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para QA y UAT


## Casos de Uso

# Casos de Uso - Mannto_Recaudadoras

**Categoría:** Form

## Caso de Uso 1: Alta de nueva recaudadora

**Descripción:** El usuario desea dar de alta una nueva recaudadora con un número único y una descripción.

**Precondiciones:**
El número de recaudadora no debe existir previamente.

**Pasos a seguir:**
1. El usuario accede a la página de recaudadoras.
2. Hace clic en 'Nueva Recaudadora'.
3. Ingresa el número (ej: 10) y la descripción (ej: 'Recaudadora Sur').
4. Presiona 'Crear'.

**Resultado esperado:**
La recaudadora se crea exitosamente y aparece en la lista.

**Datos de prueba:**
{ "num_rec": 10, "descripcion": "Recaudadora Sur" }

---

## Caso de Uso 2: Intento de eliminar recaudadora con contratos asociados

**Descripción:** El usuario intenta eliminar una recaudadora que tiene contratos asociados.

**Precondiciones:**
La recaudadora existe y tiene al menos un contrato asociado en ta_16_contratos.

**Pasos a seguir:**
1. El usuario accede a la página de recaudadoras.
2. Hace clic en 'Eliminar' sobre la recaudadora con contratos.
3. Confirma la eliminación.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que no se puede eliminar porque existen contratos asociados.

**Datos de prueba:**
{ "num_rec": 1 }

---

## Caso de Uso 3: Edición de descripción de recaudadora

**Descripción:** El usuario desea actualizar la descripción de una recaudadora existente.

**Precondiciones:**
La recaudadora existe.

**Pasos a seguir:**
1. El usuario accede a la página de recaudadoras.
2. Hace clic en 'Editar' sobre la recaudadora deseada.
3. Modifica la descripción.
4. Presiona 'Actualizar'.

**Resultado esperado:**
La descripción se actualiza correctamente y se refleja en la lista.

**Datos de prueba:**
{ "num_rec": 10, "descripcion": "Recaudadora Sur Actualizada" }

---



## Casos de Prueba

## Casos de Prueba para Mannto_Recaudadoras

### 1. Alta exitosa de recaudadora
- **Input:** { "action": "create", "payload": { "num_rec": 20, "descripcion": "Recaudadora Test" } }
- **Resultado esperado:** success: true, message: 'Recaudadora creada correctamente.'
- **Verificación:** La recaudadora aparece en la lista.

### 2. Alta duplicada (número ya existe)
- **Input:** { "action": "create", "payload": { "num_rec": 20, "descripcion": "Otra" } }
- **Resultado esperado:** success: false, message contiene 'YA EXISTE'

### 3. Baja exitosa (sin contratos asociados)
- **Preparación:** Crear recaudadora 21 sin contratos asociados.
- **Input:** { "action": "delete", "payload": { "num_rec": 21 } }
- **Resultado esperado:** success: true, message: 'Recaudadora eliminada correctamente.'

### 4. Baja fallida (con contratos asociados)
- **Preparación:** Asegurarse que recaudadora 1 tiene contratos asociados.
- **Input:** { "action": "delete", "payload": { "num_rec": 1 } }
- **Resultado esperado:** success: false, message contiene 'EXISTEN CONTRATOS'

### 5. Edición exitosa
- **Input:** { "action": "update", "payload": { "num_rec": 20, "descripcion": "Recaudadora Test Editada" } }
- **Resultado esperado:** success: true, message: 'Recaudadora actualizada correctamente.'

### 6. Edición fallida (no existe)
- **Input:** { "action": "update", "payload": { "num_rec": 9999, "descripcion": "No existe" } }
- **Resultado esperado:** success: false, message contiene 'No existe la recaudadora'

### 7. Listado general
- **Input:** { "action": "list" }
- **Resultado esperado:** success: true, data: array de recaudadoras


