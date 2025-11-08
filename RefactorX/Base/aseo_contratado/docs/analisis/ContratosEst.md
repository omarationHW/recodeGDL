# Documentación Técnica: Estadístico de Contratos (ContratosEst)

## Descripción General
El módulo "Estadístico de Contratos" permite generar reportes estadísticos sobre contratos y sus adeudos, agrupados por tipo de aseo, vigencia, oficina recaudadora, periodo, etc. El sistema está compuesto por:

- **Backend Laravel**: Un controlador con endpoint unificado `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend Vue.js**: Un componente de página completa que permite seleccionar filtros y visualizar los resultados.
- **Stored Procedure PostgreSQL**: Toda la lógica de agregación y filtrado se realiza en el SP `sp_contratos_estadistico`.

## Arquitectura

- **API Unificada**: Todas las operaciones se realizan mediante el endpoint `/api/execute` usando el patrón eRequest/eResponse. El campo `action` determina la operación.
- **Stored Procedure**: El SP recibe todos los parámetros de filtro y retorna una tabla con los datos agregados.
- **Frontend**: El componente Vue.js es una página independiente, sin tabs, con todos los filtros y resultados en la misma vista.

## Flujo de Datos

1. El usuario accede a la página y el frontend solicita los filtros iniciales (`getFilters`).
2. El usuario selecciona los filtros y ejecuta la consulta (`getEstadistico`).
3. El backend llama al SP `sp_contratos_estadistico` con los parámetros recibidos.
4. El SP retorna los datos agregados, que el frontend muestra en una tabla.

## Detalles Técnicos

### Endpoint API
- **URL**: `/api/execute`
- **Método**: POST
- **Body**:
  - `action`: string (ej: `getEstadistico`)
  - `params`: objeto con los parámetros de filtro

### Parámetros del SP
- `p_vigencia`: Vigencia de contratos ('T', 'V', 'C')
- `p_oficina`: ID de oficina recaudadora (0 = todas)
- `p_tipo_aseo`: ID tipo de aseo (999 = todos)
- `p_vig_adeudos`: Vigencia de adeudos ('T', 'V', 'C', 'P', 'S')
- `p_grupo_adeudos`: 0=por periodo, 1=por fecha, 2=histórico
- `p_periodo_inicio`, `p_periodo_fin`: Periodo en formato 'YYYY-MM'
- `p_fecha_inicio`, `p_fecha_fin`: Fechas para filtro por fecha
- `p_adeudos_visual`: 0=con adeudos, 1=sin adeudos

### Respuesta
- `success`: boolean
- `data`: array de resultados
- `message`: string de error si aplica

### Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o similar.

### Validaciones
- El frontend valida que los periodos/fechas sean correctos antes de enviar la consulta.
- El backend valida los parámetros y retorna errores claros en caso de inconsistencia.

## Consideraciones de Migración
- Todos los queries y lógica de agregación del Delphi original se han migrado al SP.
- El frontend es una página independiente, sin tabs ni componentes tabulares.
- El backend es desacoplado y solo expone el endpoint unificado.

## Extensibilidad
- Se pueden agregar más columnas al SP y a la tabla de resultados según se requiera.
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.

