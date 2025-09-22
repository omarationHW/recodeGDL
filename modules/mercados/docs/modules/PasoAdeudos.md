# PasoAdeudos (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## Descripción General
El formulario PasoAdeudos permite generar e insertar adeudos masivos para los locales del Tianguis (Mercado 214) en un año y trimestre específico. El proceso consiste en:

1. Consultar los locales del tianguis y su cuota vigente para el año seleccionado.
2. Calcular el importe de adeudo para cada local.
3. Previsualizar los adeudos generados.
4. Insertar los adeudos en la tabla `ta_11_adeudo_local`.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## API (Laravel)
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "generarAdeudos", // o "insertarAdeudos", "getTianguisLocales"
      "params": { ... }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": { ... }
    }
  }
  ```

### Acciones soportadas
- `getTianguisLocales`: Devuelve los locales del tianguis para un año.
- `generarAdeudos`: Devuelve la matriz de adeudos calculados para previsualización.
- `insertarAdeudos`: Inserta los adeudos generados en la base de datos.

## Stored Procedures
- `sp_insertar_adeudo_local`: Inserta un adeudo local.
- `sp_get_tianguis_locales`: Devuelve los locales del tianguis y su cuota para un año.

## Frontend (Vue.js)
- Página independiente `/paso-adeudos`.
- Selección de trimestre y año.
- Botón para generar/previsualizar adeudos.
- Tabla de previsualización.
- Botón para insertar adeudos.
- Mensajes de éxito/error.

## Seguridad
- El endpoint requiere autenticación (token JWT o sesión Laravel).
- El usuario debe tener permisos para ejecutar la acción.

## Validaciones
- El año debe ser >= 2009.
- El trimestre debe estar entre 1 y 4.
- No se permite insertar adeudos duplicados para el mismo local/año/periodo.

## Errores comunes
- Año/trimestre fuera de rango.
- Error de conexión a base de datos.
- Adeudos ya existentes para el periodo.

## Ejemplo de flujo
1. Usuario selecciona año y trimestre.
2. Presiona "Generar Adeudos" → ve la tabla de previsualización.
3. Presiona "Insertar Adeudos" → se insertan los registros en la base de datos.
4. Mensaje de éxito.

## Tablas involucradas
- `ta_11_locales` (Mercado 214)
- `ta_11_cuo_locales` (Cuotas por año)
- `ta_11_adeudo_local` (Adeudos generados)

## Notas
- El cálculo del importe es: `superficie * importe_cuota * 13`.
- El proceso es idempotente si se valida la no duplicidad antes de insertar.
