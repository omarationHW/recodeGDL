# Documentación Técnica: sQRptRecaudadoras

## Análisis

# Documentación Técnica: Catálogo de Recaudadoras (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo implementa el catálogo de recaudadoras, migrando la funcionalidad de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El reporte permite visualizar la lista de recaudadoras con diferentes criterios de ordenamiento.

## 2. Arquitectura
- **Backend**: Laravel API, endpoint único `/api/execute` que recibe un objeto `eRequest` y parámetros.
- **Frontend**: Componente Vue.js como página independiente, consulta el API y muestra los datos en tabla.
- **Base de Datos**: PostgreSQL, lógica de consulta encapsulada en stored procedure.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request Body**:
  ```json
  {
    "eRequest": "getRecaudadorasReport",
    "params": { "opcion": 1 }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": "getRecaudadorasReport",
    "data": [ ... ]
  }
  ```

## 4. Stored Procedure
- **Nombre**: `sp_recaudadoras_report`
- **Parámetro**: `opcion` (integer)
  - 1: Ordenar por id_rec
  - 2: Ordenar por recaudadora
  - 3: Ordenar por domicilio
  - 4: Ordenar por sector, id_rec
- **Retorno**: Tabla con columnas `id_rec`, `recaudadora`, `domicilio`, `sector`

## 5. Frontend (Vue.js)
- Página independiente, muestra encabezados, selección de criterio de ordenamiento y tabla de resultados.
- Actualiza automáticamente al cambiar el criterio.
- Incluye breadcrumb y fecha/hora de impresión.

## 6. Backend (Laravel)
- Controlador `ExecuteController` maneja todas las solicitudes `/api/execute`.
- Llama al stored procedure según el valor de `eRequest`.
- Devuelve los datos en formato JSON.

## 7. Seguridad
- El endpoint puede protegerse con middleware de autenticación según necesidades del proyecto.

## 8. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas operaciones sin crear nuevos endpoints.

## 9. Pruebas
- Casos de uso y pruebas detallados en las secciones siguientes.


## Casos de Uso

# Casos de Uso - sQRptRecaudadoras

**Categoría:** Form

## Caso de Uso 1: Visualizar catálogo de recaudadoras ordenado por número de recaudadora

**Descripción:** El usuario accede a la página de recaudadoras y visualiza la lista ordenada por el número de recaudadora (id_rec).

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen registros en la tabla ta_12_recaudadoras.

**Pasos a seguir:**
1. El usuario navega a la página 'Catálogo de Recaudadoras'.
2. El sistema muestra la tabla ordenada por 'Rec' (id_rec) por defecto.
3. El usuario verifica que los datos estén correctamente ordenados.

**Resultado esperado:**
La tabla muestra todas las recaudadoras ordenadas ascendentemente por id_rec.

**Datos de prueba:**
Registros de ejemplo en ta_12_recaudadoras con diferentes valores de id_rec.

---

## Caso de Uso 2: Cambiar criterio de ordenamiento a 'Nombre'

**Descripción:** El usuario selecciona 'Nombre' en el selector de clasificación y la tabla se actualiza automáticamente.

**Precondiciones:**
El usuario está en la página de recaudadoras y existen registros con diferentes nombres.

**Pasos a seguir:**
1. El usuario selecciona 'Nombre' en el selector de clasificación.
2. El sistema envía la solicitud al backend con opcion=2.
3. El backend devuelve los datos ordenados por recaudadora.
4. La tabla se actualiza mostrando los datos ordenados por nombre.

**Resultado esperado:**
La tabla muestra las recaudadoras ordenadas alfabéticamente por el campo 'recaudadora'.

**Datos de prueba:**
Registros con nombres variados en el campo recaudadora.

---

## Caso de Uso 3: Visualizar recaudadoras ordenadas por sector y recaudadora

**Descripción:** El usuario selecciona 'Sector y Recaudadora' y verifica que la tabla esté agrupada por sector y ordenada por id_rec dentro de cada sector.

**Precondiciones:**
Existen recaudadoras con diferentes valores de sector.

**Pasos a seguir:**
1. El usuario selecciona 'Sector y Recaudadora' en el selector.
2. El sistema envía la solicitud con opcion=4.
3. El backend devuelve los datos ordenados por sector y luego por id_rec.
4. El usuario verifica la agrupación y orden.

**Resultado esperado:**
La tabla muestra las recaudadoras agrupadas por sector y ordenadas por id_rec dentro de cada sector.

**Datos de prueba:**
Registros con sectores 'A', 'B', 'C' y varios id_rec por sector.

---



## Casos de Prueba

# Casos de Prueba: Catálogo de Recaudadoras

## Caso 1: Consulta por defecto (opcion=1)
- **Entrada:**
  - eRequest: getRecaudadorasReport
  - params: { opcion: 1 }
- **Acción:**
  - POST a /api/execute
- **Resultado esperado:**
  - Respuesta JSON con lista de recaudadoras ordenadas por id_rec ascendente.

## Caso 2: Consulta por nombre (opcion=2)
- **Entrada:**
  - eRequest: getRecaudadorasReport
  - params: { opcion: 2 }
- **Acción:**
  - POST a /api/execute
- **Resultado esperado:**
  - Respuesta JSON con lista de recaudadoras ordenadas alfabéticamente por recaudadora.

## Caso 3: Consulta por domicilio (opcion=3)
- **Entrada:**
  - eRequest: getRecaudadorasReport
  - params: { opcion: 3 }
- **Acción:**
  - POST a /api/execute
- **Resultado esperado:**
  - Respuesta JSON con lista de recaudadoras ordenadas alfabéticamente por domicilio.

## Caso 4: Consulta por sector y recaudadora (opcion=4)
- **Entrada:**
  - eRequest: getRecaudadorasReport
  - params: { opcion: 4 }
- **Acción:**
  - POST a /api/execute
- **Resultado esperado:**
  - Respuesta JSON con lista de recaudadoras agrupadas por sector y ordenadas por id_rec dentro de cada sector.

## Caso 5: Consulta sin registros
- **Preparación:**
  - Vaciar la tabla ta_12_recaudadoras.
- **Entrada:**
  - eRequest: getRecaudadorasReport
  - params: { opcion: 1 }
- **Resultado esperado:**
  - Respuesta JSON con data vacía ([]).

## Caso 6: Error de parámetro
- **Entrada:**
  - eRequest: getRecaudadorasReport
  - params: { opcion: 99 }
- **Resultado esperado:**
  - Respuesta JSON con data vacía o error manejado.

## Caso 7: eRequest desconocido
- **Entrada:**
  - eRequest: unknownRequest
- **Resultado esperado:**
  - Respuesta JSON con error 400 y mensaje 'Unknown eRequest: unknownRequest'.


