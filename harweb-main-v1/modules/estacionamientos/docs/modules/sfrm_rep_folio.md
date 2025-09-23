# Documentación Técnica: Migración de Formulario sfrm_rep_folio a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel API con endpoint único `/api/execute` que recibe un objeto `eRequest` y parámetros.
- **Frontend:** Componente Vue.js como página independiente, que consume la API y muestra los reportes.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 2. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": "nombre_operacion",
    "params": { ... }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ],
      "message": "..."
    }
  }
  ```
- **Operaciones soportadas:**
  - `getInspectors`: Lista de inspectores/vigilantes
  - `getFoliosReport`: Reporte de folios (elaborados/capturados)
  - `getFoliosByInspector`: Conteo de folios por inspector
  - `getUsuarios`: Catálogo de usuarios

## 3. Stored Procedures
- Toda la lógica de reportes y catálogos está en funciones PostgreSQL (`sp_get_*`).
- Los procedimientos reciben parámetros y devuelven tablas.
- Se usan para encapsular la lógica y facilitar el mantenimiento.

## 4. Controlador Laravel
- Un solo controlador (`ExecuteController`) maneja todas las operaciones.
- Usa `DB::select` para invocar los stored procedures.
- Elige el procedimiento según el valor de `eRequest`.

## 5. Componente Vue.js
- Página independiente, no usa tabs.
- Permite seleccionar tipo de reporte, fecha, y filtro por vigilante.
- Muestra los resultados en tabla.
- Usa fetch API para consumir `/api/execute`.

## 6. Seguridad
- Se recomienda proteger el endpoint con autenticación (no incluido aquí por simplicidad).

## 7. Consideraciones
- Los nombres de tablas y campos deben coincidir con la estructura migrada a PostgreSQL.
- Los stored procedures pueden ser extendidos para más filtros si es necesario.

## 8. Extensibilidad
- Para agregar nuevos reportes, basta con crear un nuevo stored procedure y agregar el case correspondiente en el controlador.

## 9. Pruebas
- Se recomienda usar los casos de uso y prueba incluidos para validar la funcionalidad.
