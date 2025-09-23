# Documentación Técnica: Migración de BusquedaActividadFrm a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa la funcionalidad de búsqueda de actividades económicas (giro) migrando el formulario Delphi `BusquedaActividadFrm` a una arquitectura moderna basada en Laravel (API), Vue.js (frontend) y PostgreSQL (base de datos).

- **Backend**: Laravel expone un endpoint unificado `/api/execute` que recibe un objeto `eRequest` y parámetros, y responde con `eResponse`.
- **Frontend**: Vue.js implementa una página independiente para la búsqueda y selección de actividades.
- **Base de Datos**: Toda la lógica SQL se encapsula en stored procedures PostgreSQL.

## 2. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "eRequest": "buscar_actividades",
    "params": {
      "scian": 12345,
      "descripcion": "TEXTO OPCIONAL"
    }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "error": null
    }
  }
  ```

## 3. Stored Procedures
- **buscar_actividades**: Devuelve actividades filtradas por SCIAN y descripción, incluyendo costo y refrendo del año actual.
- **buscar_actividad_por_id**: Devuelve una actividad específica por su id_giro.

## 4. Frontend (Vue.js)
- Página independiente `/busqueda-actividad`.
- Recibe el parámetro `scian` (por query string, prop o route param).
- Permite filtrar por descripción en tiempo real.
- Muestra resultados en tabla y permite seleccionar una actividad.
- Botón "Aceptar" habilitado solo si hay selección.

## 5. Backend (Laravel)
- Controlador `ExecuteController` maneja todas las solicitudes bajo `/api/execute`.
- Llama a los stored procedures según el valor de `eRequest`.
- Maneja errores y responde en formato unificado.

## 6. Seguridad
- Validar que el parámetro `scian` sea numérico y obligatorio.
- Sanitizar la descripción para evitar SQL Injection (los procedimientos usan parámetros tipados).

## 7. Consideraciones
- El frontend espera que el parámetro `scian` esté presente para realizar la búsqueda.
- El stored procedure maneja búsquedas insensibles a mayúsculas/minúsculas (`ILIKE`).
- El endpoint puede ser extendido para otros formularios reutilizando el patrón `eRequest`.

## 8. Estructura de la Base de Datos
- **c_giros**: Catálogo de giros/actividades económicas.
- **c_valoreslic**: Valores de licencia asociados a cada giro y año.

## 9. Ejemplo de Uso
- El usuario ingresa una descripción y el sistema filtra actividades vigentes del SCIAN seleccionado.
- Al seleccionar una fila y presionar "Aceptar", se puede emitir un evento o navegar a otra página.

## 10. Extensibilidad
- Se pueden agregar más stored procedures y casos de uso siguiendo el mismo patrón.
