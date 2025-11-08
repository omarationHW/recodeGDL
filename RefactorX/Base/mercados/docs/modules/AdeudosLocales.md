# Documentación Técnica: AdeudosLocales (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Vue.js 3 (SPA), cada formulario es una página independiente, sin tabs.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 2. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "action": "getAdeudosLocales", // o cualquier acción soportada
    "params": { ... } // parámetros específicos
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [...],
    "message": ""
  }
  ```

## 3. Controlador Laravel
- **AdeudosLocalesController**
  - Método `execute(Request $request)`
  - Recibe el campo `action` y despacha a la lógica correspondiente.
  - Llama a los stored procedures usando DB::select('CALL ...').
  - Devuelve siempre un JSON con los campos `success`, `data`, `message`.

## 4. Componente Vue.js
- Página independiente `/adeudos-locales`.
- Formulario con año, oficina, periodo.
- Botones para consultar, exportar a Excel, imprimir.
- Tabla de resultados con todos los campos relevantes.
- Usa Axios para consumir el endpoint `/api/execute`.
- Maneja loading y errores.

## 5. Stored Procedures
- Toda la lógica de consulta y cálculo de adeudos, meses, renta, etc. está en stored procedures PostgreSQL.
- Los SPs devuelven tablas (RETURNS TABLE) para facilitar el consumo desde Laravel.

## 6. Seguridad
- El endpoint puede requerir autenticación JWT o session según configuración del proyecto.
- Validación de parámetros en el controlador.

## 7. Extensibilidad
- Para agregar nuevas acciones, solo se debe agregar un nuevo case en el controlador y el SP correspondiente.

## 8. Exportación e Impresión
- Las acciones `exportExcel` y `printReport` pueden implementarse como jobs o respuestas de archivo.
- En el demo, solo muestran un alert.

## 9. Consideraciones de Migración
- Los cálculos de campos como Renta, Meses Adeudo, etc., se realizan en el SP o en el frontend según corresponda.
- El frontend no usa tabs ni componentes tabulares: cada formulario es una página completa.

## 10. Pruebas
- Casos de uso y pruebas detalladas en las secciones siguientes.
