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
