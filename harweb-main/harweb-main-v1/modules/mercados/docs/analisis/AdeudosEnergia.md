# Documentación Técnica: Adeudos de Energía Eléctrica

## Descripción General
Este módulo permite consultar, exportar y reportar el listado de adeudos de energía eléctrica por año y oficina recaudadora. Incluye:
- Backend Laravel con endpoint unificado `/api/execute`.
- Frontend Vue.js como página independiente.
- Lógica de negocio y reportes implementados en stored procedures PostgreSQL.
- Exportación a Excel y generación de reportes PDF (integración sugerida).

## Arquitectura
- **API Unificada**: Todas las operaciones se realizan mediante el endpoint `/api/execute` usando el patrón eRequest/eResponse.
- **Stored Procedures**: Toda la lógica de consulta y agregación reside en procedimientos almacenados PostgreSQL.
- **Frontend**: Página Vue.js independiente, sin tabs, con navegación breadcrumb y tabla de resultados.

## Flujo de Datos
1. El usuario selecciona año y oficina y presiona "Buscar".
2. El frontend envía un POST a `/api/execute` con `{ action: 'getAdeudosEnergia', params: { axo, oficina } }`.
3. Laravel ejecuta el stored procedure `sp_get_adeudos_energia` y retorna los resultados.
4. El usuario puede exportar a Excel o imprimir (PDF) usando los botones correspondientes, que llaman a los endpoints `exportExcel` o `printReport`.

## Endpoints y Acciones
- `getRecaudadoras`: Lista de oficinas recaudadoras.
- `getAdeudosEnergia`: Consulta de adeudos por año y oficina.
- `getMesesAdeudoEnergia`: Consulta de meses y cuotas para un local.
- `exportExcel`: Exporta los datos actuales a Excel (integración sugerida con SheetJS o Laravel Excel).
- `printReport`: Genera un PDF del reporte (integración sugerida con dompdf o similar).

## Validaciones
- El año debe estar entre 1994 y 2999.
- La oficina debe ser seleccionada.
- Los errores de backend se muestran en el frontend.

## Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (middleware Laravel).
- Validar que los parámetros sean correctos y sanitizados.

## Integraciones Sugeridas
- **Excel**: SheetJS en frontend o Laravel Excel en backend.
- **PDF**: dompdf o similar en backend.

## Estructura de la Base de Datos
- `ta_11_adeudo_energ`: Adeudos de energía por local, año, periodo.
- `ta_11_energia`: Datos de energía por local.
- `ta_11_locales`: Datos de locales.
- `ta_12_recaudadoras`: Catálogo de oficinas recaudadoras.

## Notas de Migración
- Todas las consultas SQL del sistema Delphi se han migrado a stored procedures PostgreSQL.
- El frontend Vue.js es una página completa, sin tabs, y puede integrarse en cualquier SPA.

# Parámetros de Stored Procedures
- `sp_get_adeudos_energia(axo INTEGER, oficina INTEGER)`
- `sp_get_meses_adeudo_energia(id_energia INTEGER, axo INTEGER)`

# Ejemplo de eRequest/eResponse
```json
{
  "action": "getAdeudosEnergia",
  "params": { "axo": 2024, "oficina": 5 }
}
```

# Respuesta
```json
{
  "success": true,
  "data": [ ... ],
  "message": ""
}
```
