# Documentación Técnica: Padrón Global de Locales

## Descripción General
Este módulo permite consultar y exportar el padrón global de locales de mercados, mostrando información relevante como ubicación, nombre, superficie, renta calculada y estado de pagos (corriente o con adeudo). Incluye filtros por año, mes y estado del local (vigente, baja, etc.), y permite exportar la información a Excel.

## Arquitectura
- **Backend (Laravel):**
  - Un único endpoint `/api/execute` que recibe peticiones eRequest/eResponse.
  - El controlador `PadronGlobalController` interpreta la acción (`action`) y delega a métodos internos.
  - Toda la lógica SQL reside en stored procedures de PostgreSQL.
- **Frontend (Vue.js):**
  - Componente de página independiente (`PadronGlobalPage.vue`), sin tabs.
  - Filtros de búsqueda, tabla de resultados, exportación a Excel y navegación breadcrumb.
- **Base de Datos (PostgreSQL):**
  - Stored procedures para consulta y lógica de negocio.

## API
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "getPadronGlobal",
    "params": {
      "axo": 2024,
      "mes": 6,
      "vig": "A"
    }
  }
  ```
- **Acciones soportadas:**
  - `getPadronGlobal`: Consulta el padrón global.
  - `exportPadronGlobalExcel`: Exporta el padrón global a Excel.
  - `getVencimientoRec`: Consulta vencimientos de recargos/descuentos.

## Stored Procedures
- `sp_padron_global(axo, mes, vig)`
- `sp_vencimiento_rec(mes)`

## Seguridad
- Validación de parámetros en backend.
- El endpoint requiere autenticación (middleware Laravel, no mostrado aquí).

## Manejo de Errores
- Respuestas JSON con `success: false` y mensaje de error.
- El frontend muestra notificaciones en caso de error.

## Exportación a Excel
- El backend genera el archivo y devuelve una URL temporal para descarga.

## Consideraciones
- El frontend es completamente independiente y funcional como página.
- No se usan tabs ni componentes tabulares.
- El backend es desacoplado y puede ser reutilizado por otros clientes.

# Esquema de Datos Relevante
- `ta_11_locales`: Información de locales.
- `ta_11_mercados`: Catálogo de mercados.
- `ta_11_cuo_locales`: Cuotas por local.
- `ta_11_adeudo_local`: Adeudos de locales.
- `ta_11_fecha_desc`: Fechas de vencimiento y descuentos.

# Ejemplo de eRequest/eResponse
**Request:**
```json
{
  "action": "getPadronGlobal",
  "params": { "axo": 2024, "mes": 6, "vig": "A" }
}
```
**Response:**
```json
{
  "success": true,
  "data": [
    { "id_local": 1, "oficina": 1, ... }
  ]
}
```

# Notas de Migración
- Todas las reglas de negocio de Delphi se trasladan a los stored procedures.
- El frontend Vue.js es una SPA moderna, sin dependencias de componentes legacy.
- El endpoint `/api/execute` es unificado para facilitar integración y pruebas.
