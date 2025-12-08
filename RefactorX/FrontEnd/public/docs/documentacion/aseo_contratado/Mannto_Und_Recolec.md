# Documentación Técnica: Mannto_Und_Recolec

## Análisis

# Documentación Técnica: Catálogo de Unidades de Recolección (Mannto_Und_Recolec)

## Descripción General
Este módulo permite la administración del catálogo de Unidades de Recolección, incluyendo operaciones de alta, baja, modificación y consulta. La lógica de negocio se implementa en stored procedures PostgreSQL, expuesta a través de un endpoint API unificado `/api/execute` bajo el patrón eRequest/eResponse. El frontend es una página Vue.js independiente.

## Arquitectura
- **Backend:** Laravel Controller (`ManntoUndRecolecController`) expone un endpoint `/api/execute` que recibe `{ action, data }` y despacha a los stored procedures correspondientes.
- **Frontend:** Componente Vue.js de página completa, sin tabs, con CRUD y navegación.
- **Base de Datos:** Toda la lógica de negocio reside en stored procedures PostgreSQL.

## API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "list|insert|update|delete|get",
    "data": { ...campos según acción... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true|false,
    "message": "Mensaje de resultado",
    "data": [ ... ]
  }
  ```

## Acciones Soportadas
- `list`: Lista todas las unidades para un ejercicio.
- `get`: Obtiene una unidad por su control.
- `insert`: Inserta una nueva unidad (requiere ejercicio, clave, descripción, costo, costo_exed).
- `update`: Modifica una unidad existente (requiere ctrol_recolec, descripción, costo, costo_exed).
- `delete`: Elimina una unidad (requiere ctrol_recolec, sólo si no tiene contratos asociados).

## Validaciones
- No se permite duplicar clave para el mismo ejercicio.
- No se permite eliminar unidades con contratos asociados.
- Todos los campos requeridos deben estar presentes y válidos.

## Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o similar.
- Validaciones adicionales pueden implementarse en el controlador Laravel.

## Integración Frontend
- El componente Vue.js consume el endpoint `/api/execute` para todas las operaciones.
- El formulario de alta y edición valida los campos antes de enviar.
- Mensajes de error y éxito se muestran al usuario.

## Ejemplo de Request/Response
### Alta de Unidad
```json
POST /api/execute
{
  "action": "insert",
  "data": {
    "ejercicio": 2024,
    "cve": "A",
    "descripcion": "Unidad tipo A",
    "costo": 123.45,
    "costo_exed": 200.00
  }
}
```
**Response:**
```json
{
  "success": true,
  "message": "Unidad creada correctamente",
  "data": { ... }
}
```

## Stored Procedures
- Toda la lógica de negocio reside en los SPs documentados en este entregable.
- Los SPs devuelven mensajes de éxito/error y datos relevantes.

## Consideraciones de Migración
- Los nombres de campos y lógica replican el comportamiento Delphi original.
- El control de errores y mensajes se centraliza en los SPs y el controlador.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- El frontend puede extenderse fácilmente para nuevos campos o validaciones.


## Casos de Uso

# Casos de Uso - Mannto_Und_Recolec

**Categoría:** Form

## Caso de Uso 1: Alta de Unidad de Recolección

**Descripción:** El usuario desea agregar una nueva unidad de recolección para el ejercicio actual.

**Precondiciones:**
El usuario tiene permisos de administrador y el ejercicio está vigente.

**Pasos a seguir:**
1. El usuario accede a la página de Unidades de Recolección.
2. Hace clic en 'Agregar Unidad'.
3. Llena los campos: Ejercicio=2024, Clave='B', Descripción='Unidad tipo B', Costo=150.00, Costo Excedente=250.00.
4. Hace clic en 'Aceptar'.

**Resultado esperado:**
La unidad se agrega correctamente y aparece en la lista. Se muestra mensaje de éxito.

**Datos de prueba:**
{ "ejercicio": 2024, "cve": "B", "descripcion": "Unidad tipo B", "costo": 150.00, "costo_exed": 250.00 }

---

## Caso de Uso 2: Intento de Baja de Unidad con Contratos Asociados

**Descripción:** El usuario intenta eliminar una unidad que tiene contratos asociados.

**Precondiciones:**
Existe al menos un contrato asociado a la unidad.

**Pasos a seguir:**
1. El usuario selecciona una unidad en la lista.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que no se puede eliminar la unidad porque tiene contratos asociados.

**Datos de prueba:**
{ "ctrol_recolec": 101 }

---

## Caso de Uso 3: Modificación de Descripción y Costos

**Descripción:** El usuario edita la descripción y los costos de una unidad existente.

**Precondiciones:**
La unidad existe y no está bloqueada.

**Pasos a seguir:**
1. El usuario selecciona una unidad en la lista.
2. Hace clic en 'Editar'.
3. Cambia la descripción a 'Unidad tipo C', costo a 180.00 y costo excedente a 300.00.
4. Hace clic en 'Aceptar'.

**Resultado esperado:**
La unidad se actualiza correctamente y los nuevos valores se reflejan en la lista.

**Datos de prueba:**
{ "ctrol_recolec": 102, "descripcion": "Unidad tipo C", "costo": 180.00, "costo_exed": 300.00 }

---



## Casos de Prueba

## Casos de Prueba: Catálogo Unidades de Recolección

### 1. Alta exitosa de unidad
- **Input:**
  - action: insert
  - data: { ejercicio: 2024, cve: 'A', descripcion: 'Unidad A', costo: 100.00, costo_exed: 200.00 }
- **Resultado esperado:** success=true, message='Unidad creada correctamente', la unidad aparece en la lista.

### 2. Alta duplicada (misma clave y ejercicio)
- **Input:**
  - action: insert
  - data: { ejercicio: 2024, cve: 'A', descripcion: 'Unidad A', costo: 100.00, costo_exed: 200.00 }
- **Resultado esperado:** success=false, message='Ya existe una clave para ese ejercicio'.

### 3. Baja exitosa de unidad sin contratos
- **Input:**
  - action: delete
  - data: { ctrol_recolec: 105 }
- **Resultado esperado:** success=true, message='Unidad eliminada correctamente'.

### 4. Baja fallida por contratos asociados
- **Input:**
  - action: delete
  - data: { ctrol_recolec: 101 }
- **Resultado esperado:** success=false, message='Existen contratos asociados a esta unidad. No se puede eliminar.'

### 5. Modificación exitosa
- **Input:**
  - action: update
  - data: { ctrol_recolec: 102, descripcion: 'Unidad tipo C', costo: 180.00, costo_exed: 300.00 }
- **Resultado esperado:** success=true, message='Unidad actualizada correctamente'.

### 6. Consulta de lista
- **Input:**
  - action: list
  - data: { ejercicio: 2024 }
- **Resultado esperado:** success=true, data contiene arreglo de unidades del ejercicio 2024.

### 7. Consulta individual
- **Input:**
  - action: get
  - data: { ctrol_recolec: 102 }
- **Resultado esperado:** success=true, data contiene los datos de la unidad 102.


