# Documentación Técnica: sQRptCves_Operacion

## Análisis

# Documentación Técnica: Migración de Formulario sQRptCves_Operacion

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `sQRptCves_Operacion` a una arquitectura moderna basada en Laravel (API RESTful), Vue.js (SPA) y PostgreSQL (procedimientos almacenados). El objetivo es listar el catálogo de claves de operación con opciones de clasificación dinámica.

## 2. Arquitectura
- **Backend:** Laravel 10+ (PHP 8+), PostgreSQL 13+
- **Frontend:** Vue.js 3+, Bootstrap 5 (opcional para estilos)
- **API:** Endpoint único `/api/execute` que recibe un objeto `eRequest` y parámetros, y responde con `eResponse`.
- **Base de Datos:** Toda la lógica de consulta reside en procedimientos almacenados PostgreSQL.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "get_operaciones",
    "params": { "opcion": 1 }
  }
  ```
  - `opcion`: 1=ctrol_operacion, 2=cve_operacion, 3=descripcion
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ { "ctrol_operacion": ..., "cve_operacion": ..., "descripcion": ... }, ... ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedure
- **Nombre:** `sp_get_operaciones`
- **Parámetro:** `opcion` (integer)
- **Retorno:** SETOF json (cada fila como objeto JSON)
- **Lógica:** Ordena según el campo seleccionado.

## 5. Laravel Controller
- **Ruta:** Definir en `routes/api.php`:
  ```php
  Route::post('/execute', [\App\Http\Controllers\Api\ExecuteController::class, 'handle']);
  ```
- **Controlador:** `ExecuteController` maneja el patrón eRequest/eResponse y ejecuta el SP correspondiente.

## 6. Vue.js Component
- **Página independiente** con ruta propia (ej: `/cves-operacion`)
- **Funcionalidad:**
  - Selector de clasificación (Control, Clave, Descripción)
  - Tabla de resultados
  - Breadcrumb de navegación
  - Footer con fecha/hora de impresión
- **Consumo:** Llama a `/api/execute` con el eRequest y muestra los datos.

## 7. Seguridad
- Validar que sólo se acepten eRequests válidos.
- Sanitizar parámetros antes de pasarlos al SP.

## 8. Pruebas
- Pruebas unitarias y de integración para el endpoint y el SP.
- Pruebas de UI para el componente Vue.

## 9. Consideraciones
- El SP devuelve cada fila como JSON para facilitar la integración y desacoplar la lógica de presentación.
- El endpoint es extensible para otros formularios/futuros eRequests.


## Casos de Uso

# Casos de Uso - sQRptCves_Operacion

**Categoría:** Form

## Caso de Uso 1: Visualizar catálogo de claves de operación ordenado por Número de Control

**Descripción:** El usuario accede a la página y visualiza el listado de claves de operación ordenado por el campo 'ctrol_operacion'.

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen registros en la tabla 'ta_16_operacion'.

**Pasos a seguir:**
1. El usuario navega a la página 'Catálogo de Claves de Operación'.
2. Por defecto, la clasificación es 'Número de Control'.
3. La aplicación realiza una petición POST a '/api/execute' con eRequest 'get_operaciones' y opcion=1.
4. El backend ejecuta el SP y retorna los datos ordenados.
5. El frontend muestra la tabla con los datos.

**Resultado esperado:**
El usuario ve la tabla de claves de operación ordenada por 'ctrol_operacion'.

**Datos de prueba:**
Registros de ejemplo en 'ta_16_operacion' con diferentes valores en 'ctrol_operacion'.

---

## Caso de Uso 2: Cambiar clasificación a 'Clave' y visualizar resultados

**Descripción:** El usuario selecciona la opción 'Clave' en el selector de clasificación y la tabla se actualiza.

**Precondiciones:**
El usuario está en la página y existen registros con diferentes 'cve_operacion'.

**Pasos a seguir:**
1. El usuario selecciona 'Clave' en el selector.
2. El frontend envía POST a '/api/execute' con opcion=2.
3. El backend ejecuta el SP y retorna los datos ordenados por 'cve_operacion'.
4. El frontend actualiza la tabla.

**Resultado esperado:**
La tabla muestra los datos ordenados por 'cve_operacion'.

**Datos de prueba:**
Registros con valores variados en 'cve_operacion'.

---

## Caso de Uso 3: Visualizar catálogo ordenado por 'Descripción'

**Descripción:** El usuario selecciona 'Descripción' y la tabla se ordena alfabéticamente por ese campo.

**Precondiciones:**
El usuario está en la página y existen descripciones distintas.

**Pasos a seguir:**
1. El usuario selecciona 'Descripción' en el selector.
2. El frontend envía POST a '/api/execute' con opcion=3.
3. El backend ejecuta el SP y retorna los datos ordenados por 'descripcion'.
4. El frontend muestra la tabla actualizada.

**Resultado esperado:**
La tabla se muestra ordenada alfabéticamente por 'descripcion'.

**Datos de prueba:**
Registros con descripciones variadas.

---



## Casos de Prueba

# Casos de Prueba: Catálogo de Claves de Operación

## Caso 1: Consulta por Número de Control
- **Entrada:**
  - eRequest: get_operaciones
  - params: { opcion: 1 }
- **Acción:** POST a /api/execute
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array ordenado por ctrol_operacion ascendente

## Caso 2: Consulta por Clave
- **Entrada:**
  - eRequest: get_operaciones
  - params: { opcion: 2 }
- **Acción:** POST a /api/execute
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array ordenado por cve_operacion ascendente

## Caso 3: Consulta por Descripción
- **Entrada:**
  - eRequest: get_operaciones
  - params: { opcion: 3 }
- **Acción:** POST a /api/execute
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array ordenado alfabéticamente por descripcion

## Caso 4: Sin registros en la tabla
- **Precondición:** ta_16_operacion está vacía
- **Entrada:**
  - eRequest: get_operaciones
  - params: { opcion: 1 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data = []

## Caso 5: eRequest inválido
- **Entrada:**
  - eRequest: get_operaciones_x
  - params: { opcion: 1 }
- **Esperado:**
  - eResponse.success = false
  - eResponse.message indica eRequest desconocido


