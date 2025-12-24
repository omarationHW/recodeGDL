# DocumentaciÃ³n TÃ©cnica: ABC_Und_Recolec

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración de Formulario ABC_Und_Recolec (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel API con endpoint unificado `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Frontend**: Vue.js SPA, cada formulario es una página independiente (no tabs), con navegación y breadcrumbs.
- **Base de Datos**: PostgreSQL, lógica de negocio encapsulada en stored procedures.

## API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Entrada**: `{ "eRequest": { "action": "list|create|update|delete", "entity": "unidades_recoleccion", "params": { ... } } }`
- **Salida**: `{ "eResponse": [ ... ] }` (array de resultados o error)

## Controlador Laravel
- Un solo controlador (`ExecuteController`) maneja todas las acciones CRUD para el catálogo de Unidades de Recolección.
- Llama a los stored procedures de PostgreSQL según la acción y entidad.
- Valida parámetros y retorna errores amigables.

## Componente Vue.js
- Página completa para el catálogo de Unidades de Recolección.
- Tabla con listado, botones para crear, editar y eliminar.
- Formularios modales para alta y edición.
- Llama al endpoint `/api/execute` usando fetch/AJAX.
- Maneja errores y muestra mensajes amigables.

## Stored Procedures PostgreSQL
- Toda la lógica de negocio (altas, bajas, cambios, consultas) está en SPs.
- Validaciones de unicidad y restricciones de integridad.
- Devuelven mensajes de error o éxito en formato estándar.

## Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o similar.
- Validar que el usuario tenga permisos para cada acción.

## Nombres de Campos
- `ctrol_recolec`: Identificador único de la unidad.
- `ejercicio_recolec`: Año/ejericio fiscal.
- `cve_recolec`: Clave corta (1 carácter).
- `descripcion`: Descripción textual.
- `costo_unidad`: Costo por unidad.
- `costo_exed`: Costo por excedente.

## Flujo de Trabajo
1. El usuario accede a la página de Unidades de Recolección.
2. El frontend solicita la lista para el ejercicio actual.
3. El usuario puede agregar, editar o eliminar unidades.
4. Cada acción llama al endpoint `/api/execute` con la acción y parámetros.
5. El backend ejecuta el SP correspondiente y retorna el resultado.

## Manejo de Errores
- Si se intenta crear una clave duplicada, el SP retorna `error: clave ya existe`.
- Si se intenta eliminar una unidad referenciada, retorna `error: existen contratos con esta unidad`.
- Todos los errores se muestran en el frontend.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar más entidades y acciones fácilmente.
- Los SPs pueden evolucionar sin cambiar el frontend.


## Casos de Prueba

## Casos de Prueba para Unidades de Recolección

### 1. Alta exitosa
- **Entrada:**
  - ejercicio_recolec: 2024
  - cve_recolec: 'K'
  - descripcion: 'Camión Compactador'
  - costo_unidad: 1500.00
  - costo_exed: 2000.00
- **Acción:** create
- **Esperado:** status: 'ok', ctrol_recolec asignado

### 2. Alta duplicada
- **Entrada:**
  - ejercicio_recolec: 2024
  - cve_recolec: 'K' (ya existe)
- **Acción:** create
- **Esperado:** error: 'clave ya existe'

### 3. Listado por ejercicio
- **Entrada:**
  - ejercicio: 2024
- **Acción:** list
- **Esperado:** Lista de unidades para 2024

### 4. Edición exitosa
- **Entrada:**
  - ctrol_recolec: 5
  - ejercicio_recolec: 2024
  - cve_recolec: 'K'
  - descripcion: 'Camión Compactador 2024'
  - costo_unidad: 1600.00
  - costo_exed: 2000.00
- **Acción:** update
- **Esperado:** status: 'ok'

### 5. Edición de unidad inexistente
- **Entrada:**
  - ctrol_recolec: 9999 (no existe)
- **Acción:** update
- **Esperado:** error: 'unidad no existe'

### 6. Eliminación exitosa
- **Entrada:**
  - ctrol_recolec: 7 (sin contratos)
- **Acción:** delete
- **Esperado:** status: 'ok'

### 7. Eliminación con contratos referenciados
- **Entrada:**
  - ctrol_recolec: 3 (referenciado)
- **Acción:** delete
- **Esperado:** error: 'existen contratos con esta unidad'


## Casos de Uso

# Casos de Uso - ABC_Und_Recolec

**Categoría:** Form

## Caso de Uso 1: Alta de Unidad de Recolección

**Descripción:** El usuario desea agregar una nueva unidad de recolección para el ejercicio actual.

**Precondiciones:**
El usuario tiene permisos de administrador y el ejercicio está abierto.

**Pasos a seguir:**
1. El usuario accede a la página de Unidades de Recolección.
2. Hace clic en 'Agregar Unidad'.
3. Llena los campos: Ejercicio=2024, Clave='K', Descripción='Camión Compactador', Costo Unidad=1500.00, Costo Excedente=2000.00.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
La unidad se agrega correctamente y aparece en la lista. Si la clave ya existe para ese ejercicio, se muestra un error.

**Datos de prueba:**
{ "ejercicio_recolec": 2024, "cve_recolec": "K", "descripcion": "Camión Compactador", "costo_unidad": 1500.00, "costo_exed": 2000.00 }

---

## Caso de Uso 2: Edición de Unidad de Recolección

**Descripción:** El usuario desea modificar la descripción y el costo de una unidad existente.

**Precondiciones:**
Existe una unidad con ctrol_recolec=5, ejercicio=2024.

**Pasos a seguir:**
1. El usuario localiza la unidad con ctrol_recolec=5.
2. Hace clic en 'Editar'.
3. Cambia la descripción a 'Camión Compactador 2024' y el costo a 1600.00.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
La unidad se actualiza correctamente. Si el control no existe, se muestra un error.

**Datos de prueba:**
{ "ctrol_recolec": 5, "ejercicio_recolec": 2024, "cve_recolec": "K", "descripcion": "Camión Compactador 2024", "costo_unidad": 1600.00, "costo_exed": 2000.00 }

---

## Caso de Uso 3: Eliminación de Unidad de Recolección

**Descripción:** El usuario intenta eliminar una unidad de recolección.

**Precondiciones:**
Existe una unidad con ctrol_recolec=7 y no está referenciada en contratos.

**Pasos a seguir:**
1. El usuario localiza la unidad con ctrol_recolec=7.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
La unidad se elimina correctamente. Si está referenciada en contratos, se muestra un error.

**Datos de prueba:**
{ "ctrol_recolec": 7 }

---



---
**Componente:** `ABC_Und_Recolec.vue`
**MÃ³dulo:** `aseo_contratado`

