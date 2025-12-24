# DocumentaciÃ³n TÃ©cnica: ContratosEst

## AnÃ¡lisis TÃ©cnico

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



## Casos de Prueba

## Casos de Prueba para Estadístico de Contratos

### Caso 1: Consulta General de Contratos Vigentes
- **Entrada:**
  - vigencia: 'V'
  - oficina: 0
  - tipo_aseo: 999
  - vig_adeudos: 'T'
  - grupo_adeudos: 0
  - periodo_inicio: '2023-01'
  - periodo_fin: '2023-12'
  - adeudos_visual: 0
- **Esperado:**
  - Respuesta success=true
  - data: array con al menos una fila por tipo de aseo
  - Los totales de contratos y adeudos corresponden a los datos de la base

### Caso 2: Contratos Cancelados en Oficina Específica
- **Entrada:**
  - vigencia: 'C'
  - oficina: 1
  - tipo_aseo: 999
  - vig_adeudos: 'T'
  - grupo_adeudos: 2
  - periodo_inicio: null
  - periodo_fin: null
  - adeudos_visual: 0
- **Esperado:**
  - Respuesta success=true
  - data: array con contratos cancelados en oficina 1

### Caso 3: Adeudos Pagados por Fecha
- **Entrada:**
  - vigencia: 'T'
  - oficina: 0
  - tipo_aseo: 999
  - vig_adeudos: 'P'
  - grupo_adeudos: 1
  - fecha_inicio: '2023-06-01'
  - fecha_fin: '2023-06-30'
  - adeudos_visual: 0
- **Esperado:**
  - Respuesta success=true
  - data: array con totales de adeudos pagados en ese rango de fechas

### Caso 4: Sin Resultados
- **Entrada:**
  - vigencia: 'V'
  - oficina: 99 (oficina inexistente)
  - tipo_aseo: 999
  - vig_adeudos: 'T'
  - grupo_adeudos: 0
  - periodo_inicio: '2023-01'
  - periodo_fin: '2023-12'
  - adeudos_visual: 0
- **Esperado:**
  - Respuesta success=true
  - data: array vacío

### Caso 5: Error de Parámetros
- **Entrada:**
  - vigencia: null
  - oficina: null
- **Esperado:**
  - Respuesta success=false
  - message: 'Acción no soportada' o mensaje de error de validación


## Casos de Uso

# Casos de Uso - ContratosEst

**Categoría:** Form

## Caso de Uso 1: Consulta de Estadístico General de Contratos Vigentes

**Descripción:** El usuario desea obtener un resumen de contratos y adeudos vigentes agrupados por tipo de aseo.

**Precondiciones:**
El usuario tiene acceso al sistema y existen contratos y adeudos en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página Estadístico de Contratos.
2. Selecciona 'VIGENTES' en Vigencia de Contratos.
3. Selecciona 'Todos' en Oficina y Tipo de Aseo.
4. Selecciona 'CON ADEUDOS' y 'POR PERIODO DE ADEUDO'.
5. Ingresa el periodo de inicio y fin (ej: 2023-01 a 2023-12).
6. Presiona 'Ejecutar'.

**Resultado esperado:**
Se muestra una tabla con los totales de contratos y adeudos vigentes por tipo de aseo.

**Datos de prueba:**
Contratos con status_vigencia='V', adeudos con status_vigencia='V', periodo entre 2023-01 y 2023-12.

---

## Caso de Uso 2: Reporte de Contratos Cancelados en una Oficina Específica

**Descripción:** El usuario desea ver el estadístico de contratos cancelados en la oficina 'Recaudadora Centro'.

**Precondiciones:**
Existen contratos cancelados en la oficina seleccionada.

**Pasos a seguir:**
1. Accede a la página Estadístico de Contratos.
2. Selecciona 'CANCELADOS' en Vigencia de Contratos.
3. Selecciona 'Recaudadora Centro' en Oficina.
4. Selecciona 'Todos los tipos' en Tipo de Aseo.
5. Selecciona 'CON ADEUDOS' y 'HISTORICO'.
6. Presiona 'Ejecutar'.

**Resultado esperado:**
Se muestra la tabla con los totales de contratos y adeudos cancelados en la oficina seleccionada.

**Datos de prueba:**
Contratos con status_vigencia='C', id_rec=1.

---

## Caso de Uso 3: Estadístico de Adeudos Pagados por Fecha de Pago

**Descripción:** El usuario quiere ver el resumen de adeudos pagados en un rango de fechas.

**Precondiciones:**
Existen pagos registrados en el rango de fechas.

**Pasos a seguir:**
1. Accede a la página Estadístico de Contratos.
2. Selecciona 'TODOS' en Vigencia de Contratos.
3. Selecciona 'Todos' en Oficina y Tipo de Aseo.
4. Selecciona 'PAGADOS' en Vigencia de Adeudos.
5. Selecciona 'POR PERIODO DE PAGO'.
6. Ingresa la fecha de inicio y fin (ej: 2023-06-01 a 2023-06-30).
7. Presiona 'Ejecutar'.

**Resultado esperado:**
Se muestra la tabla con los totales de adeudos pagados en el rango de fechas seleccionado.

**Datos de prueba:**
Adeudos con status_vigencia='P', fecha_hora_pago entre 2023-06-01 y 2023-06-30.

---



---
**Componente:** `ContratosEst.vue`
**MÃ³dulo:** `aseo_contratado`

