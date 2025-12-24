# DocumentaciÃ³n TÃ©cnica: Rep_Recaudadoras

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Módulo de Reporte de Recaudadoras

## 1. Descripción General
Este módulo permite consultar y visualizar un reporte de las recaudadoras registradas en el sistema, ordenando el resultado según el criterio seleccionado por el usuario (Recaudadora, Nombre, Domicilio, Sector). El frontend está implementado en Vue.js como una página independiente, el backend en Laravel expone un endpoint unificado `/api/execute` que utiliza stored procedures en PostgreSQL para obtener los datos.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, componente de página independiente, navegación por rutas, sin tabs.
- **Backend:** Laravel Controller con endpoint único `/api/execute` que recibe un objeto eRequest con acción y parámetros.
- **Base de Datos:** PostgreSQL, lógica de ordenamiento y consulta encapsulada en stored procedure `sp_rep_recaudadoras_report`.

## 3. API eRequest/eResponse
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "getRecaudadorasReport",
    "params": { "order": 1 }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [ { "id_rec": 1, "recaudadora": "Oficina Central", ... } ],
    "message": ""
  }
  ```

## 4. Stored Procedure
- **Nombre:** `sp_rep_recaudadoras_report`
- **Parámetro:** `p_order` (integer)
- **Orden:**
  - 1: Por id_rec
  - 2: Por recaudadora
  - 3: Por domicilio
  - 4: Por sector
- **Retorna:** Tabla con columnas: id_rec, recaudadora, domicilio, sector

## 5. Seguridad
- El endpoint debe estar protegido por autenticación JWT o session según la política del sistema.
- El stored procedure no permite inyección SQL ya que el parámetro de orden es un integer y el ordenamiento se realiza por CASE.

## 6. Extensibilidad
- Se pueden agregar más criterios de orden en el stored procedure y reflejarlos en el frontend.
- El endpoint puede ser extendido para otras acciones relacionadas con recaudadoras.

## 7. Manejo de Errores
- El backend captura excepciones y retorna un mensaje de error en el campo `message` del eResponse.
- El frontend muestra el error en pantalla si ocurre.

## 8. Navegación
- La página incluye breadcrumbs para navegación contextual.
- El botón "Salir" regresa a la página anterior.

## 9. Pruebas
- Se incluyen casos de uso y escenarios de prueba para validar el correcto funcionamiento del módulo.


## Casos de Prueba

## Casos de Prueba para Rep_Recaudadoras

### Caso 1: Consulta exitosa por nombre
- **Precondición:** Existen recaudadoras en la base de datos.
- **Acción:**
  - Enviar POST a /api/execute con `{ "action": "getRecaudadorasReport", "params": { "order": 2 } }`
- **Resultado esperado:**
  - HTTP 200, campo `success: true`, datos ordenados por nombre ascendente.

### Caso 2: Consulta exitosa por sector
- **Precondición:** Existen recaudadoras con diferentes sectores.
- **Acción:**
  - Enviar POST a /api/execute con `{ "action": "getRecaudadorasReport", "params": { "order": 4 } }`
- **Resultado esperado:**
  - HTTP 200, campo `success: true`, datos ordenados por sector ascendente y luego id_rec.

### Caso 3: Error de backend
- **Precondición:** El stored procedure no existe o hay error de conexión.
- **Acción:**
  - Enviar POST a /api/execute con `{ "action": "getRecaudadorasReport", "params": { "order": 1 } }`
- **Resultado esperado:**
  - HTTP 200, campo `success: false`, campo `message` contiene el error.

### Caso 4: Acción no soportada
- **Acción:**
  - Enviar POST a /api/execute con `{ "action": "accionInvalida" }`
- **Resultado esperado:**
  - HTTP 200, campo `success: false`, campo `message` = 'Acción no soportada'.

### Caso 5: Consulta sin parámetros (default)
- **Acción:**
  - Enviar POST a /api/execute con `{ "action": "getRecaudadorasReport" }`
- **Resultado esperado:**
  - HTTP 200, campo `success: true`, datos ordenados por id_rec ascendente.


## Casos de Uso

# Casos de Uso - Rep_Recaudadoras

**Categoría:** Form

## Caso de Uso 1: Visualizar reporte de recaudadoras ordenado por nombre

**Descripción:** El usuario desea obtener un listado de todas las recaudadoras, ordenadas alfabéticamente por el nombre de la recaudadora.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar reportes.

**Pasos a seguir:**
1. El usuario accede a la página de 'Impresiones de Recaudadoras'.
2. Selecciona 'Nombre' como criterio de orden.
3. Hace clic en 'Vista Previa'.
4. El sistema consulta el backend y muestra la tabla ordenada por nombre.

**Resultado esperado:**
Se muestra una tabla con todas las recaudadoras, ordenadas alfabéticamente por el campo 'recaudadora'.

**Datos de prueba:**
Base de datos con al menos 3 recaudadoras con nombres distintos.

---

## Caso de Uso 2: Visualizar reporte de recaudadoras ordenado por sector

**Descripción:** El usuario requiere ver el listado de recaudadoras agrupadas por sector.

**Precondiciones:**
El usuario está autenticado y la tabla ta_12_recaudadoras tiene datos con diferentes sectores.

**Pasos a seguir:**
1. El usuario ingresa a la página de reporte de recaudadoras.
2. Selecciona 'Sector' como criterio de orden.
3. Presiona 'Vista Previa'.
4. El sistema retorna la lista ordenada por sector y luego por id_rec.

**Resultado esperado:**
La tabla muestra las recaudadoras agrupadas por sector, y dentro de cada sector ordenadas por id_rec.

**Datos de prueba:**
Recaudadoras con sectores 'Norte', 'Sur', 'Centro'.

---

## Caso de Uso 3: Manejo de error al fallar la consulta

**Descripción:** El usuario intenta consultar el reporte pero ocurre un error en la base de datos.

**Precondiciones:**
El backend tiene un problema de conexión o el stored procedure no existe.

**Pasos a seguir:**
1. El usuario accede a la página y selecciona cualquier criterio de orden.
2. Hace clic en 'Vista Previa'.
3. El backend lanza una excepción.

**Resultado esperado:**
El frontend muestra un mensaje de error informando que no se pudo obtener el reporte.

**Datos de prueba:**
Simular caída de la base de datos o renombrar temporalmente el stored procedure.

---



---
**Componente:** `Rep_Recaudadoras.vue`
**MÃ³dulo:** `aseo_contratado`

