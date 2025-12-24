# Documentación Técnica: Menu

## Análisis

# Documentación Técnica: Migración Formulario Menu (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel 10+ (PHP 8.1+), API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente (no tabs).
- **Base de Datos**: PostgreSQL 13+, toda la lógica SQL encapsulada en stored procedures.
- **Comunicación**: Patrón eRequest/eResponse, siempre vía POST JSON.

## 2. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "catalog.list.unidades",
      "params": { "ejercicio": 2024 }
    }
  }
  ```
- **Salida**:
  ```json
  {
    "eResponse": {
      "result": [ ... ],
      "error": null
    }
  }
  ```
- **Acciones soportadas**: `catalog.list.unidades`, `catalog.create.unidad`, `catalog.update.unidad`, `catalog.delete.unidad`, `catalog.list.tipos_aseo`, etc.

## 3. Stored Procedures
- Toda la lógica de negocio y validación reside en stored procedures (SPs) de PostgreSQL.
- Los SPs devuelven errores como filas con texto 'ERROR: ...' o lanzan excepciones.
- Los SPs CRUD para catálogos siguen el patrón:
  - `sp_cat_<entidad>_list([params])`
  - `sp_cat_<entidad>_create([params])`
  - `sp_cat_<entidad>_update([params])`
  - `sp_cat_<entidad>_delete([params])`
- Los reportes usan SPs tipo `sp_rep_<reporte>_export([params])`.

## 4. Frontend Vue.js
- Cada catálogo/consulta es una página Vue independiente.
- Navegación por rutas (ejemplo: `/catalogos/unidades`).
- Cada página implementa:
  - Breadcrumb de navegación.
  - Tabla de datos.
  - Modales para alta/edición.
  - Acciones CRUD conectadas al endpoint `/api/execute`.
- Manejo de errores y mensajes de usuario.

## 5. Seguridad
- Autenticación recomendada vía JWT o Laravel Sanctum.
- Validación de parámetros en backend y frontend.
- Los SPs validan integridad referencial (por ejemplo, no eliminar unidad con contratos asociados).

## 6. Ejemplo de Flujo CRUD (Unidades)
1. El usuario accede a la página de Unidades.
2. El frontend llama a `/api/execute` con acción `catalog.list.unidades` y el ejercicio seleccionado.
3. El backend ejecuta el SP correspondiente y retorna los datos.
4. Para crear, el frontend muestra un modal, el usuario llena los campos y envía acción `catalog.create.unidad`.
5. El backend ejecuta el SP de creación, valida duplicados y responde éxito o error.
6. Para editar/eliminar, se usan las acciones `catalog.update.unidad` y `catalog.delete.unidad`.

## 7. Extensibilidad
- Para agregar nuevos catálogos, reportes o procesos, basta con:
  - Crear el SP correspondiente en PostgreSQL.
  - Agregar el case en el controlador Laravel.
  - Crear la página Vue si aplica.

## 8. Notas de Migración
- Todos los formularios Delphi se migran a páginas independientes.
- No se usan tabs ni componentes tabulares.
- Los reportes/exportaciones se implementan como SPs y pueden ser consumidos por el frontend para descarga.
- El endpoint `/api/execute` es el único punto de entrada para todas las operaciones del sistema.


## Casos de Uso

# Casos de Uso - Menu

**Categoría:** Form

## Caso de Uso 1: Alta de Unidad de Recolección

**Descripción:** El usuario desea agregar una nueva unidad de recolección para el ejercicio 2024.

**Precondiciones:**
El usuario tiene permisos de administrador y el ejercicio 2024 existe.

**Pasos a seguir:**
1. El usuario accede a la página de Catálogo de Unidades.
2. Selecciona el ejercicio 2024.
3. Hace clic en 'Agregar Unidad'.
4. Llena los campos: Clave='K', Descripción='Unidad K', Costo Unidad=100.00, Costo Excedente=150.00.
5. Hace clic en 'Guardar'.
6. El sistema envía la petición a /api/execute con acción 'catalog.create.unidad'.

**Resultado esperado:**
La unidad se agrega correctamente y aparece en la tabla. Si la clave ya existe, se muestra un error.

**Datos de prueba:**
{ "ejercicio": 2024, "clave": "K", "descripcion": "Unidad K", "costo_unidad": 100.00, "costo_exed": 150.00 }

---

## Caso de Uso 2: Edición de Unidad de Recolección

**Descripción:** El usuario desea modificar la descripción y costos de una unidad existente.

**Precondiciones:**
Existe una unidad con clave 'K' para el ejercicio 2024.

**Pasos a seguir:**
1. El usuario accede a la página de Catálogo de Unidades.
2. Selecciona el ejercicio 2024.
3. Localiza la unidad 'K' y hace clic en 'Editar'.
4. Cambia la descripción a 'Unidad K Modificada', Costo Unidad=120.00, Costo Excedente=170.00.
5. Hace clic en 'Guardar'.
6. El sistema envía la petición a /api/execute con acción 'catalog.update.unidad'.

**Resultado esperado:**
La unidad se actualiza correctamente y los nuevos valores se reflejan en la tabla.

**Datos de prueba:**
{ "id": 1, "descripcion": "Unidad K Modificada", "costo_unidad": 120.00, "costo_exed": 170.00 }

---

## Caso de Uso 3: Eliminación de Unidad de Recolección

**Descripción:** El usuario desea eliminar una unidad de recolección que no tiene contratos asociados.

**Precondiciones:**
Existe una unidad con id=2 y no tiene contratos asociados.

**Pasos a seguir:**
1. El usuario accede a la página de Catálogo de Unidades.
2. Selecciona el ejercicio correspondiente.
3. Localiza la unidad y hace clic en 'Eliminar'.
4. Confirma la eliminación.
5. El sistema envía la petición a /api/execute con acción 'catalog.delete.unidad'.

**Resultado esperado:**
La unidad se elimina correctamente. Si tiene contratos asociados, se muestra un error.

**Datos de prueba:**
{ "id": 2 }

---



## Casos de Prueba

## Casos de Prueba para Catálogo de Unidades

### Caso 1: Alta exitosa de unidad
- **Entrada:** ejercicio=2024, clave='K', descripcion='Unidad K', costo_unidad=100.00, costo_exed=150.00
- **Acción:** catalog.create.unidad
- **Esperado:** Respuesta 'OK', la unidad aparece en la lista.

### Caso 2: Alta duplicada de unidad
- **Entrada:** ejercicio=2024, clave='K', descripcion='Unidad K', costo_unidad=100.00, costo_exed=150.00
- **Acción:** catalog.create.unidad (clave ya existe)
- **Esperado:** Error 'Ya existe la clave para ese ejercicio'.

### Caso 3: Edición exitosa de unidad
- **Entrada:** id=1, descripcion='Unidad K Modificada', costo_unidad=120.00, costo_exed=170.00
- **Acción:** catalog.update.unidad
- **Esperado:** Respuesta 'OK', los valores se actualizan.

### Caso 4: Eliminación exitosa de unidad sin contratos
- **Entrada:** id=2
- **Acción:** catalog.delete.unidad
- **Esperado:** Respuesta 'OK', la unidad desaparece de la lista.

### Caso 5: Eliminación fallida de unidad con contratos
- **Entrada:** id=3 (tiene contratos asociados)
- **Acción:** catalog.delete.unidad
- **Esperado:** Error 'Existen contratos asociados, no se puede eliminar'.


