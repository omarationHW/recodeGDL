# Documentación Técnica: Adeudos de Locales

## Descripción General
Este módulo permite consultar, visualizar y exportar el listado de adeudos de locales de mercados municipales, filtrando por año, recaudadora y periodo (mes). Incluye la lógica de cálculo de renta, meses de adeudo y exportación a Excel.

## Arquitectura
- **Backend**: Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend**: Componente Vue.js independiente como página completa.
- **Base de Datos**: PostgreSQL, lógica encapsulada en stored procedures.
- **API**: Todas las operaciones se realizan mediante el endpoint `/api/execute`.

## Flujo de Datos
1. El usuario accede a la página de Adeudos de Locales.
2. Selecciona año, recaudadora y mes.
3. Al consultar, el frontend envía un eRequest con acción `getAdeudosLocales` y los parámetros seleccionados.
4. El backend ejecuta el stored procedure `sp_get_adeudos_locales` y retorna los datos en eResponse.
5. El usuario puede exportar el resultado a Excel (funcionalidad a implementar).

## Endpoints
- **POST /api/execute**
  - **Entrada**: `{ eRequest: { action: string, params: object } }`
  - **Salida**: `{ eResponse: { success: bool, message: string, data: any } }`

## Stored Procedures
- `sp_get_adeudos_locales(axo, oficina, periodo)`
- `sp_get_meses_adeudo(id_local, axo, periodo)`
- `sp_get_renta_local(axo, categoria, seccion, clave_cuota)`

## Validaciones
- Todos los parámetros requeridos deben ser enviados.
- El año debe ser >= 1990.
- El periodo (mes) debe estar entre 1 y 12.
- La recaudadora debe existir.

## Seguridad
- El endpoint debe estar protegido por autenticación (middleware Laravel).
- Validar que el usuario tenga permisos para consultar la recaudadora seleccionada.

## Exportación a Excel
- La exportación debe realizarse en backend, generando un archivo temporal y devolviendo la URL de descarga.

## Errores
- Todos los errores se devuelven en el campo `message` de eResponse.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.

