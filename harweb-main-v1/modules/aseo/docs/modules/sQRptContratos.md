# Documentación Técnica: Migración de sQRptContratos a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General

- **Backend:** Laravel API con endpoint único `/api/execute` que recibe un objeto `eRequest` y parámetros.
- **Frontend:** Componente Vue.js de página completa, independiente, para consulta y visualización del reporte.
- **Base de Datos:** PostgreSQL, lógica de reportes encapsulada en stored procedure `rpt_contratos`.
- **Patrón de integración:** eRequest/eResponse para desacoplar lógica de negocio y presentación.

## 2. Endpoint API

- **Ruta:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "RptContratos",
    "params": {
      "seleccion": 1,
      "Ofna": 0,
      "Rep": 0,
      "opcion": 1,
      "Num_emp": 0,
      "Ctrol_Aseo": 0,
      "Vigencia": "T"
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "message": "Reporte generado",
      "data": {
        "contratos": [ ... ],
        "totales": {
          "total": 10,
          "vigentes": 8,
          "cancelados": 2
        }
      }
    }
  }
  ```

## 3. Stored Procedure: `rpt_contratos`

- Recibe parámetros de filtro y clasificación.
- Construye dinámicamente el SQL según los filtros.
- Devuelve todos los campos requeridos para el reporte.
- Permite paginar y filtrar desde el frontend si se desea.

## 4. Frontend (Vue.js)

- Formulario de filtros con todos los parámetros posibles.
- Tabla responsive con todos los campos del reporte.
- Muestra totales de contratos, vigentes y cancelados.
- Manejo de errores y estados de carga.
- Navegación breadcrumb.

## 5. Backend (Laravel)

- Controlador único `ExecuteController`.
- Método `execute` que despacha según `eRequest`.
- Llama al stored procedure y procesa los resultados para totales.
- Responde siempre con el patrón `eResponse`.

## 6. Seguridad

- Validar y sanear parámetros en el backend.
- El stored procedure solo permite SELECT, sin modificaciones.
- Se recomienda proteger el endpoint con autenticación según el contexto del sistema.

## 7. Extensibilidad

- Se pueden agregar más reportes o procesos reutilizando el endpoint `/api/execute`.
- El frontend puede ser extendido para exportar a Excel/PDF si se requiere.

## 8. Consideraciones de Migración

- Los nombres de campos y tablas deben coincidir con los de la base de datos PostgreSQL.
- Si existen diferencias, ajustar el stored procedure y el frontend.
- El reporte es solo de consulta, no hay operaciones de alta/baja/modificación.
