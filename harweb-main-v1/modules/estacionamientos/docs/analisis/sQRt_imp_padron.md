# Documentación Técnica: Migración de Formulario sQRt_imp_padron a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `sQRt_imp_padron` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El objetivo es permitir la consulta y reporte del padrón vehicular del Estado de Jalisco, filtrando por rangos de ID.

## 2. Arquitectura
- **Backend:** Laravel, expone un endpoint unificado `/api/execute` que recibe peticiones con el patrón `eRequest/eResponse`.
- **Frontend:** Vue.js, página independiente para el formulario de consulta de padrón vehicular.
- **Base de Datos:** PostgreSQL, con lógica de consulta encapsulada en stored procedure.

## 3. Endpoint API
- **URL:** `/api/execute`
- **Método:** POST
- **Formato de entrada:**
  ```json
  {
    "eRequest": "get_padron_report",
    "params": {
      "id1": 100,
      "id2": 200
    }
  }
  ```
- **Formato de salida:**
  ```json
  {
    "eResponse": "success",
    "data": [
      { "id": 100, "placa": "ABC123", ... },
      ...
    ]
  }
  ```

## 4. Stored Procedure
- **Nombre:** `sp_get_padron_report`
- **Parámetros:**
  - `p_id1` (integer): ID inicial
  - `p_id2` (integer): ID final
- **Retorna:** Tabla con los campos del padrón vehicular entre los IDs especificados.

## 5. Frontend (Vue.js)
- Página independiente con formulario para ingresar `ID Inicial` y `ID Final`.
- Al enviar, consulta la API y muestra los resultados en tabla.
- Incluye navegación breadcrumb.

## 6. Seguridad
- Validación de parámetros en backend.
- Manejo de errores y respuestas estructuradas.

## 7. Extensibilidad
- El endpoint unificado permite agregar nuevas operaciones fácilmente usando el patrón `eRequest`.

## 8. Pruebas
- Casos de uso y escenarios de prueba incluidos para asegurar la funcionalidad y robustez del módulo.
