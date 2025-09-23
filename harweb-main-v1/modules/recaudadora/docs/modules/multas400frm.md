# Documentación Técnica: Migración Formulario multas400frm

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `multas400frm` a una arquitectura moderna basada en Laravel (API), Vue.js (frontend) y PostgreSQL (base de datos). Permite consultar registros de multas federales y municipales por diferentes criterios: acta, nombre o domicilio.

## 2. Arquitectura
- **Frontend**: Componente Vue.js independiente, página completa, sin tabs.
- **Backend**: Laravel Controller con endpoint único `/api/execute` usando patrón `eRequest`/`eResponse`.
- **Base de Datos**: PostgreSQL, lógica de consulta encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "eRequest": "multas400_search_by_acta_fed", // o el que corresponda
    "params": { ... }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```
- **eRequest posibles**:
  - multas400_search_by_acta_fed
  - multas400_search_by_nombre_fed
  - multas400_search_by_domici_fed
  - multas400_search_by_acta_mpal
  - multas400_search_by_nombre_mpal
  - multas400_search_by_domici_mpal

## 4. Stored Procedures
Cada consulta se implementa como una función PostgreSQL que retorna un conjunto de registros (`SETOF`). Los parámetros se pasan desde Laravel y se usan en la consulta SQL.

## 5. Frontend (Vue.js)
- Página única, con formulario para seleccionar tipo de multa y criterios de búsqueda.
- Botones para buscar por acta, nombre o domicilio.
- Resultados en tabla dinámica.
- Manejo de errores y estados de carga.

## 6. Seguridad
- Todas las consultas son de solo lectura.
- Los parámetros se validan en el backend.
- No se exponen detalles internos de la base de datos.

## 7. Consideraciones
- El LIKE en PostgreSQL es case-sensitive, por eso se usa UPPER() para búsquedas insensibles a mayúsculas/minúsculas.
- El frontend espera que los stored procedures devuelvan los mismos campos que las tablas originales.

## 8. Extensibilidad
- Se pueden agregar nuevos criterios de búsqueda creando nuevos stored procedures y mapeando nuevos `eRequest` en el controlador.

## 9. Pruebas
- Se recomienda probar con datos reales y casos límite (sin resultados, datos inválidos, etc).

## 10. Dependencias
- Laravel >= 8.x
- Vue.js >= 3.x
- PostgreSQL >= 12
