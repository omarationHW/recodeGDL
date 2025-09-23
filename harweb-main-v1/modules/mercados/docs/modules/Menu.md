# Documentación Técnica: Módulo de Adeudos de Energía Eléctrica

## Descripción General
Este módulo permite consultar, visualizar y exportar el listado de adeudos de energía eléctrica por oficina, mercado, año y mes. Incluye la visualización de los meses de adeudo por local y la exportación a Excel.

## Arquitectura
- **Backend**: Laravel Controller con endpoint único `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Frontend**: Componente Vue.js independiente como página completa.
- **Base de Datos**: PostgreSQL, lógica encapsulada en stored procedures.
- **API**: Unificada, patrón eRequest/eResponse.

## Endpoints y Acciones
- `/api/execute` (POST)
  - `eRequest.action = getOficinas` → Lista de oficinas recaudadoras
  - `eRequest.action = getMercadosByOficina` → Mercados por oficina
  - `eRequest.action = getAdeudosEnergia` → Listado de adeudos de energía
  - `eRequest.action = getMesesAdeudoEnergia` → Meses de adeudo por local
  - `eRequest.action = exportExcel` → Exportación a Excel (placeholder)

## Stored Procedures
- `sp_get_adeudos_energia(oficina, mercado, axo, mes)`
- `sp_get_meses_adeudo_energia(id_energia, axo, mes)`

## Flujo de Datos
1. El frontend solicita oficinas → backend responde.
2. El usuario selecciona oficina, solicita mercados → backend responde.
3. El usuario selecciona filtros y consulta adeudos → backend ejecuta SP y responde.
4. El usuario puede ver meses de adeudo por local → backend ejecuta SP y responde.
5. El usuario puede exportar a Excel (implementación futura).

## Validaciones
- Todos los campos de filtro son obligatorios.
- El año debe estar en rango válido (ej. 1994-2999).
- El mes debe estar entre 1 y 12.

## Seguridad
- El endpoint debe estar protegido por autenticación Laravel (middleware `auth:api` recomendado).
- Validar y sanitizar todos los parámetros recibidos.

## Consideraciones de Migración
- Los queries Delphi fueron convertidos a stored procedures PostgreSQL.
- El frontend Delphi fue migrado a Vue.js como página independiente.
- El backend Delphi fue migrado a Laravel Controller.

## Exportación a Excel
- Puede implementarse usando Laravel Excel o similar.
- El frontend puede descargar el archivo generado por el backend.

## Errores y Manejo de Excepciones
- Todos los errores se devuelven en el campo `eResponse.error`.
- Los logs de errores se almacenan en el log de Laravel.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- Los stored procedures pueden ser extendidos para nuevos reportes.
