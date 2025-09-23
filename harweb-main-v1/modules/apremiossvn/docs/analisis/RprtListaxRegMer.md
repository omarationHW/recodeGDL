# Documentación Técnica: Migración de Formulario RprtListaxRegMer (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este documento describe la migración del formulario Delphi `RprtListaxRegMer` a una arquitectura moderna basada en Laravel (API REST), Vue.js (SPA) y PostgreSQL (procedimientos almacenados). El objetivo es mantener la lógica de negocio y presentación, pero modernizando la tecnología y facilitando la integración y mantenimiento.

## 2. Arquitectura
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Vue.js 3+, componente de página independiente, sin tabs.
- **Base de Datos:** PostgreSQL, lógica SQL encapsulada en funciones/procedimientos almacenados.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint:** `/api/execute` (POST)
- **Request:**
  ```json
  {
    "eRequest": "getRprtListaxRegMer",
    "params": {
      "oficina": 5,
      "num_mercado": 1,
      "vigencia": "1",
      "clave_practicado": "todas"
    }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## 4. Stored Procedures
Toda la lógica SQL se encapsula en funciones de PostgreSQL:
- `rpt_listax_reg_mer`: Devuelve el reporte principal, filtrando por oficina, mercado, vigencia y clave_practicado.
- `get_recaudadora_zona`: Devuelve los datos de la recaudadora y zona para la cabecera del reporte.

## 5. Laravel Controller
- Controlador único `ExecuteController`.
- Método `execute(Request $request)` que despacha según el valor de `eRequest`.
- Llama a los stored procedures usando `DB::select`.
- Maneja errores y devuelve la respuesta en formato eResponse.

## 6. Vue.js Component
- Página independiente (`RprtListaxRegMerPage.vue`).
- Formulario de filtros (oficina, num_mercado, vigencia, clave_practicado).
- Tabla de resultados con totales y formato amigable.
- Navegación breadcrumb.
- Lógica de presentación y formateo de datos.

## 7. Seguridad
- El endpoint `/api/execute` debe protegerse con autenticación (ej. JWT) en producción.
- Validar y sanear los parámetros recibidos.

## 8. Consideraciones de Migración
- Los nombres de campos y tablas deben mapearse correctamente entre Delphi y PostgreSQL.
- Los tipos de datos deben ser compatibles.
- El reporte puede exportarse a PDF/Excel desde el frontend si se requiere.

## 9. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad y la migración.

## 10. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevos reportes y procesos sin crear nuevos endpoints.

---
