# Documentación Técnica: Migración de Formulario RprtCATAL_EJE (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al reporte/listado de ejecutores municipales, mostrando información relevante de cada ejecutor, su recaudadora y zona. El sistema original en Delphi ha sido migrado a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend SPA) y PostgreSQL (base de datos).

## 2. Arquitectura
- **Backend:** Laravel 10+ (API RESTful)
- **Frontend:** Vue.js 2/3 (SPA, componente de página independiente)
- **Base de Datos:** PostgreSQL 13+
- **API Unificada:** Todas las operaciones se realizan a través de un único endpoint `/api/execute` usando el patrón `eRequest`/`eResponse`.
- **Stored Procedures:** Toda la lógica SQL relevante se implementa como funciones almacenadas en PostgreSQL.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "eRequest": "RprtCATAL_EJE.list",
    "params": {
      "id_rec": 1,
      "vigencia": "A"
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedure Principal
- **Nombre:** `rpt_catal_eje`
- **Parámetros:**
  - `p_id_rec` (integer): ID de la recaudadora
  - `p_vigencia` (varchar): Filtro de vigencia ('A' para activos, 'I' para inactivos, vacío para todos)
- **Retorna:** Listado de ejecutores con campos extendidos (ver definición SQL)

## 5. Controlador Laravel
- **Ubicación:** `App\Http\Controllers\Api\ExecuteController.php`
- **Método principal:** `handle(Request $request)`
- **Lógica:**
  - Recibe el `eRequest` y parámetros.
  - Ejecuta el stored procedure correspondiente.
  - Devuelve la respuesta en formato `eResponse`.

## 6. Componente Vue.js
- **Nombre:** `RprtCatalEjePage.vue`
- **Características:**
  - Página independiente (no tabulada).
  - Filtros por ID de recaudadora y vigencia.
  - Tabla de resultados con todos los campos relevantes.
  - Breadcrumb de navegación.
  - Mensajes de carga, error y total de registros.

## 7. Seguridad
- Se recomienda proteger el endpoint `/api/execute` con autenticación JWT o session según la política del sistema.
- Validar que el usuario tenga permisos para consultar ejecutores de la recaudadora seleccionada.

## 8. Consideraciones de Migración
- Los nombres de campos y tablas se han adaptado a la convención PostgreSQL (minúsculas, snake_case).
- El filtro de vigencia se implementa como parámetro opcional.
- El reporte es de solo lectura, no hay operaciones de alta/baja/modificación.

## 9. Extensibilidad
- Para agregar nuevos formularios, basta con implementar nuevos `eRequest` y stored procedures, y crear el componente Vue correspondiente.

## 10. Ejemplo de Uso
- Para obtener todos los ejecutores activos de la recaudadora 1:
  ```json
  {
    "eRequest": "RprtCATAL_EJE.list",
    "params": {
      "id_rec": 1,
      "vigencia": "A"
    }
  }
  ```

## 11. Errores y Manejo de Excepciones
- Todos los errores se devuelven en el campo `message` de `eResponse`.
- Si la consulta falla, `success` será `false` y `data` será `null`.

## 12. Pruebas
- Ver sección de casos de uso y casos de prueba para escenarios detallados.
