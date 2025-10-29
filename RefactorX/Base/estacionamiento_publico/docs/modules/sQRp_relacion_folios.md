# Documentación Técnica: Migración de Formulario sQRp_relacion_folios

## 1. Descripción General
Este módulo implementa la migración del formulario Delphi `sQRp_relacion_folios` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El objetivo es mantener la funcionalidad de generación de reportes de folios de estacionómetros, permitiendo filtrar por diferentes tipos de fechas.

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful unificada vía `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend:** Vue.js 3+, componente de página independiente, sin tabs.
- **Base de Datos:** PostgreSQL, lógica de reportes encapsulada en stored procedures (functions).

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "sQRp_relacion_folios_report",
    "params": {
      "opcion": 1,
      "fecha": "2024-06-01"
    }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": "Reporte generado correctamente.",
    "errors": []
  }
  ```

## 4. Stored Procedure
- **Nombre:** `sQRp_relacion_folios_report`
- **Parámetros:**
  - `opcion` (integer): Tipo de filtro (1=fecha_folio, 2=fecha_alta, 3=fecha_baja pago, 4=fecha_baja cancelación)
  - `fecha` (date): Fecha a consultar
- **Retorno:** Tabla con columnas: axo, folio, placa, fecha_folio, estado, infraccion, tarifa

## 5. Frontend (Vue.js)
- Página independiente `/relacion-folios`
- Formulario para seleccionar tipo de fecha y fecha
- Tabla de resultados con columnas: AÑO, FOLIO, PLACA, CLAVE, ESTADO, TARIFA
- Mensajes de carga, error y "no hay datos"

## 6. Validaciones
- El backend valida que `opcion` esté en [1,2,3,4] y que `fecha` sea una fecha válida.
- El frontend requiere ambos campos antes de enviar la consulta.

## 7. Seguridad
- El endpoint puede protegerse con middleware de autenticación según la política del sistema.
- El stored procedure no permite inyección SQL, ya que los parámetros son tipados y el query es parametrizado.

## 8. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevos formularios y reportes reutilizando el mismo endpoint y estructura.

## 9. Pruebas
- Casos de uso y pruebas incluidas para asegurar la funcionalidad y robustez del módulo.
