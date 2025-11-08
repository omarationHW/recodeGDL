# Documentación Técnica: Migración Formulario Rep_a_Cobrar (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Backend:** Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js 3 (SPA, cada formulario es una página independiente)
- **Base de Datos:** PostgreSQL 13+ (toda la lógica SQL en stored procedures)
- **Patrón API:** eRequest/eResponse (entrada y salida JSON)

## 2. Endpoint API Unificado
- **Ruta:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "getReport|getRecaudadora|getMeses",
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": { ... }
  }
  ```

## 3. Controlador Laravel
- Un solo método `execute` que despacha según `action`.
- Llama a los stored procedures PostgreSQL usando `DB::select`.
- Valida parámetros y retorna errores claros en `eResponse.error`.

## 4. Stored Procedures PostgreSQL
- Toda la lógica de negocio y reportes está en SPs.
- Ejemplo: `sp_rep_a_cobrar(par_mes, par_id_rec)` retorna el reporte de años, mantenimiento y recargos.
- SPs pueden ser extendidos para lógica más compleja.

## 5. Componente Vue.js
- Página independiente (no tabs, no subcomponentes).
- Formulario con selección de mes y muestra de recaudadora.
- Botón para generar reporte (llama API y muestra tabla de resultados).
- Manejo de errores y loading.
- Filtros para formato de moneda.

## 6. Seguridad
- El `id_rec` debe obtenerse del usuario autenticado (simulado en el ejemplo).
- Validar siempre los parámetros en backend.

## 7. Extensibilidad
- El endpoint `/api/execute` puede despachar cualquier acción del sistema.
- Los SPs pueden ser versionados y ampliados.

## 8. Pruebas
- Casos de uso y pruebas incluidas para asegurar la funcionalidad.

## 9. Consideraciones
- El frontend asume que el usuario ya está autenticado y conoce su `id_rec`.
- El reporte es sólo de consulta, no hay edición ni eliminación.

