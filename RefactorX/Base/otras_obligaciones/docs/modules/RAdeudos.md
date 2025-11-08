# Documentación Técnica: Migración Formulario RAdeudos (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Backend:** Laravel API (PHP) con endpoint unificado `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Vue.js SPA, cada formulario es una página independiente (no tabs).
- **Base de Datos:** PostgreSQL, lógica de reportes en stored procedures.

## 2. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "eRequest": "RAdeudos.BuscaCont|RAdeudos.BuscaAdeudos01|RAdeudos.BuscaAdeudos02",
    "params": { ... }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true|false,
    "data": [ ... ],
    "message": ""
  }
  ```

## 3. Stored Procedures
- **con34_1detade_01:** Adeudos vencidos.
- **con34_1detade_02:** Adeudos por periodo.
- **Ambos reciben:**
  - `par_Control` (integer): ID del contrato/local.
  - `par_Rep` (varchar): Tipo de reporte ('V' o 'A').
  - `par_Fecha` (varchar): Periodo en formato 'YYYY-MM'.

## 4. Frontend (Vue.js)
- Página independiente `/radeudos`.
- Formulario para capturar número, letra, periodo.
- Consulta datos del local y muestra tabla de adeudos.
- Validaciones y mensajes de error amigables.
- Totales calculados en frontend.

## 5. Backend (Laravel)
- Controlador `ExecuteController` maneja todas las solicitudes.
- Cada eRequest ejecuta el SP o query correspondiente.
- Manejo de errores y mensajes claros.

## 6. Seguridad
- Validar y sanear todos los parámetros recibidos.
- Limitar acceso a endpoints según autenticación (si aplica).

## 7. Consideraciones
- Los nombres de campos pueden variar según la estructura real de la base de datos.
- Los stored procedures deben adaptarse a la lógica de negocio real.
- El frontend asume que los SP devuelven los campos esperados.

## 8. Extensibilidad
- Para agregar nuevos formularios, crear nuevos eRequest y componentes Vue independientes.
- El endpoint `/api/execute` es extensible para cualquier otro formulario/proceso.
