# Documentación Técnica: RptEmisionLocales (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## Descripción General
Este módulo corresponde a la emisión de recibos de locales de mercados municipales. Permite:
- Previsualizar la emisión de recibos para un mercado/oficina/año/mes.
- Grabar (emitir) los recibos, generando los adeudos correspondientes.
- Consultar mercados disponibles por oficina.

Toda la lógica de negocio y cálculos (renta, recargos, meses adeudados) se realiza en stored procedures PostgreSQL.

## Arquitectura
- **Frontend**: Vue.js SPA, página independiente `/emision-locales`.
- **Backend**: Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Base de Datos**: PostgreSQL, lógica en stored procedures.

## API (Patrón eRequest/eResponse)
- **Endpoint**: `/api/execute` (POST)
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "get|emit|preview|get-mercados",
      "params": { ... }
    }
  }
  ```
- **Salida**:
  ```json
  {
    "eResponse": { ... }
  }
  ```

### Acciones soportadas
- `get`: Previsualización de emisión (no graba nada)
- `emit`: Graba la emisión (genera adeudos)
- `preview`: Alias de `get`
- `get-mercados`: Devuelve mercados de una oficina

## Stored Procedures
- `sp_rpt_emision_locales_get`: Devuelve la previsualización de la emisión (cálculos de renta, recargos, meses adeudados)
- `sp_rpt_emision_locales_emit`: Graba los adeudos del periodo/mercado/oficina/año

## Seguridad
- El endpoint requiere autenticación (token JWT o sesión Laravel).
- El parámetro `usuario_id` debe ser validado contra el usuario autenticado.

## Validaciones
- Todos los parámetros son obligatorios.
- No se permite emitir dos veces el mismo periodo/local.
- Solo mercados con `tipo_emision = 'M'` pueden ser emitidos.

## Errores comunes
- Si ya existe el adeudo para el periodo/local, no se duplica.
- Si faltan parámetros, se devuelve error de validación.

## Frontend
- Página Vue.js independiente, sin tabs.
- Navegación breadcrumb.
- Botón de previsualización y emisión.
- Tabla de previsualización con todos los datos relevantes.

## Backend
- Controlador Laravel centraliza todas las acciones.
- Toda la lógica de negocio está en los stored procedures.

## Base de Datos
- Tablas principales: `ta_11_locales`, `ta_11_cuo_locales`, `ta_11_adeudo_local`, `ta_12_recargos`, `ta_11_mercados`.

# Diagrama de Flujo
1. Usuario selecciona oficina, año, mes, mercado.
2. Frontend llama a `/api/execute` con acción `get`.
3. Backend ejecuta `sp_rpt_emision_locales_get` y devuelve la previsualización.
4. Usuario revisa y confirma emisión.
5. Frontend llama a `/api/execute` con acción `emit`.
6. Backend ejecuta `sp_rpt_emision_locales_emit` y graba los adeudos.

# Notas de Migración
- Todos los cálculos de Delphi (renta, recargos, meses) están migrados a SQL.
- El frontend es una página independiente, no usa tabs.
- El endpoint es único y flexible para futuras extensiones.
