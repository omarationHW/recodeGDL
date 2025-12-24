# Reportes Estadisticos de Licencias

## Descripcion General

### Que hace este modulo
El modulo de Reportes Estadisticos genera multiples reportes especializados sobre licencias comerciales, proporcionando analisis detallados de pagos, altas, bajas, distribucion geografica y estadisticas de recaudacion. Es una herramienta fundamental para toma de decisiones gerenciales y analisis del comportamiento del sistema de licencias.

### Para que sirve en el proceso administrativo
Este modulo sirve para:
- Generar estadisticas de pagos de licencias por periodo
- Analizar altas y bajas de licencias por mes
- Reportar distribucion de licencias vigentes por zona geografica y giro
- Generar estadisticas de licencias otorgadas por zona y periodo
- Producir reportes de recaudacion por tipo de licencia y recaudadora
- Analizar comportamiento de licencias reglamentadas vs no reglamentadas
- Proporcionar informacion para direccion y autoridades municipales
- Facilitar reportes de transparencia y rendicion de cuentas

### Quienes lo utilizan
- Directores y subdirectores que requieren estadisticas
- Personal de planeacion y desarrollo economico
- Contadores y personal financiero para analisis de ingresos
- Autoridades municipales para reportes ejecutivos
- Personal de transparencia para cumplimiento normativo
- Analistas que generan reportes gerenciales
- Auditores externos para revision de operaciones

## Proceso Administrativo

### Como funciona el proceso paso a paso

El modulo ofrece 5 tipos diferentes de reportes estadisticos. Usuario selecciona tipo mediante RadioGroup y configura parametros:

**Reporte 1: Pagos por Rango de Fechas**

1. Usuario selecciona "Pagos por fecha"
2. Captura fecha inicial y final
3. Presiona "Imprimir"
4. Sistema genera reporte con:
   - Listado de pagos en el rango
   - Desglose por concepto
   - Totales por columna
   - Agrupacion por tipo de pago

**Reporte 2: Altas y Bajas por Mes del Año Actual**

1. Usuario selecciona "Altas y bajas mensuales"
2. No requiere parametros (usa año actual automaticamente)
3. Presiona "Imprimir"
4. Sistema genera reporte con:
   - Altas por mes
   - Bajas por mes
   - Comparativa mensual
   - Totales anuales

**Reporte 3: Distribucion de Licencias Vigentes por Zona y Giro**

1. Usuario selecciona "Licencias vigentes por zona"
2. Selecciona clasificacion de giro:
   - Todas
   - Solo tipo C
   - Solo tipo D
   - C y D combinadas
3. Presiona "Imprimir"
4. Sistema genera reporte con:
   - Giros en filas
   - Zonas en columnas (1 a 7 + Otros)
   - Cantidad de licencias por cruce
   - Totales por giro y por zona
   - Agrupacion por clasificacion
   - Subtotales por clasificacion

**Reporte 4: Licencias Otorgadas por Zona, Giro y Periodo**

1. Usuario selecciona "Licencias otorgadas por periodo"
2. Captura fecha inicial y final
3. Selecciona clasificacion (Todas, C, D, C y D)
4. Presiona "Imprimir"
5. Sistema genera reporte similar a Reporte 3 pero:
   - Solo licencias otorgadas en el rango de fechas
   - Con vigencia actual
   - Filtradas por clasificacion seleccionada

**Reporte 5: Estadisticas de Recaudacion por Tipo de Licencia**

1. Usuario selecciona "Estadisticas de recaudacion"
2. Captura fecha inicial y final
3. Presiona "Imprimir"
4. Sistema genera reporte complejo con:
   - Total de pagos por recaudadora (1,2,3,4)
   - Licencias reglamentadas nuevas (cantidad e importe)
   - Licencias reglamentadas refrendo (cantidad e importe)
   - Licencias no reglamentadas nuevas (cantidad)
   - Licencias no reglamentadas refrendo (cantidad)
   - Totales generales
   - Desglose por tipo de establecimiento

### Que informacion requiere el usuario

**Parametros Segun Reporte:**

**Reporte 1:**
- Fecha inicial
- Fecha final

**Reporte 2:**
- Ninguno (usa año actual automatico)

**Reporte 3:**
- Clasificacion de giro (opcional: Todas, A, B, C, D)

**Reporte 4:**
- Fecha inicial
- Fecha final
- Clasificacion de giro

**Reporte 5:**
- Fecha inicial
- Fecha final

**Informacion que se Genera:**

Varia segun el reporte, incluye:
- Cantidad de licencias
- Montos de pago
- Distribucion geografica (zonas)
- Distribucion por giro comercial
- Clasificacion de establecimientos
- Totales y subtotales
- Comparativas mensuales
- Analisis por recaudadora

### Que validaciones se realizan

1. **Validacion de Fechas:**
   - Para reportes 1, 4 y 5
   - Verifica que se capture al menos una fecha
   - Mensaje: "Debes indicar al menos una fecha..."
   - No permite generar sin fechas validas

2. **Habilitacion de Campos:**
   - RadioGroup1.Click habilita/deshabilita campos segun reporte
   - Reporte 2: Deshabilita fechas (no las necesita)
   - Reportes 3 y 4: Habilita selector de clasificacion
   - Otros: Deshabilitan clasificacion

3. **Construccion Dinamica de Queries:**
   - Queries SQL se construyen en tiempo de ejecucion
   - Se adaptan a filtros seleccionados
   - Joins y agrupaciones segun reporte

4. **Manejo de Clasificaciones:**
   - Valida clasificacion seleccionada
   - Construye WHERE dinamico
   - Titulo del reporte refleja filtro aplicado

### Que documentos genera

**5 Reportes Diferentes:**

1. **ppReport1:** Pagos por rango de fechas
   - Listado detallado de pagos
   - Totales por concepto
   - Periodo especificado en titulo

2. **ppReport2:** Altas y bajas mensuales
   - Tabla comparativa mensual
   - Grafica de comportamiento
   - Totales anuales

3. **ppReport3:** Licencias vigentes por zona y giro
   - Matriz zona/giro
   - Totales por fila y columna
   - Agrupado por clasificacion
   - Subtotales por tipo

4. **ppReport4:** Licencias otorgadas por periodo
   - Similar a ppReport3
   - Filtrado por rango de fechas
   - Titulo indica periodo

5. **ppReport5:** Estadisticas de recaudacion
   - Resumen ejecutivo
   - Desglose por recaudadora
   - Separacion reglamentadas/no reglamentadas
   - Nuevas vs refrendos
   - Totales generales

Todos incluyen:
- Logo institucional
- Fecha de generacion
- Numero de pagina
- Titulos descriptivos

## Tablas de Base de Datos

### Tabla Principal
- **licencias:** Tabla central con todas las licencias del municipio

### Tablas Relacionadas

**Tablas que Consulta:**
- **licencias:** Datos de licencias (estado, fecha, zona, giro)
- **c_giros:** Catalogo de giros con descripcion y clasificacion
- **pagos:** Registro de pagos de licencias
- **Query1, Query2, Query3, Query4, Query5:** Queries dinamicos construidos segun reporte

**Tablas que Modifica:**
- **Ninguna:** Modulo de solo lectura para reportes

## Stored Procedures
- **Ninguno:** No utiliza procedimientos almacenados, solo queries complejos

## Impacto y Repercusiones

### Que registros afecta
- **Ninguno:** Es un modulo de consulta y reportes
- No modifica datos
- Solo lectura de informacion existente

### Que cambios de estado provoca
- **Ninguno:** No provoca cambios transaccionales
- Es herramienta de analisis sin efectos operativos

### Que documentos/reportes genera
- 5 tipos diferentes de reportes estadisticos
- Todos en formato impreso o PDF
- Diseño profesional con logo y formato oficial

### Que validaciones de negocio aplica

1. **Filtros de Vigencia:**
   - Reportes 3 y 4: Solo licencias vigentes (vigente = "V")
   - Garantiza datos actuales y relevantes

2. **Clasificacion de Giros:**
   - Filtra segun tipo seleccionado (A, B, C, D)
   - Permite analisis sectoriales especificos

3. **Periodos de Analisis:**
   - Reportes por rango de fechas
   - Basados en fecha_otorgamiento o fecha de pago
   - Flexibilidad en periodos historicos

4. **Agrupaciones Inteligentes:**
   - Por zona geografica
   - Por giro comercial
   - Por clasificacion de establecimiento
   - Por recaudadora
   - Por tipo (reglamentado/no reglamentado)

## Flujo de Trabajo

### Descripcion del flujo completo del proceso

**Caso de Uso: Director Requiere Reporte Mensual**

```
1. REQUERIMIENTO:
   a. Director solicita estadisticas de licencias vigentes
   b. Requiere distribucion por zona y tipo de giro
   c. Para presentacion a cabildo

2. ACCESO:
   d. Personal de estadistica abre modulo
   e. Selecciona "Licencias vigentes por zona"
   f. Deja "Todas las clasificaciones"

3. GENERACION:
   g. Presiona "Imprimir"
   h. Sistema construye query complejo
   i. Consulta todas las licencias vigentes
   j. Agrupa por giro y zona
   k. Calcula totales

4. RESULTADO:
   l. Sistema genera ppReport3
   m. Muestra matriz con:
      - Filas: Giros comerciales
      - Columnas: Zonas 1-7 + Otros
      - Celdas: Cantidad de licencias
      - Totales por giro y zona
   n. Personal revisa en vista previa
   o. Confirma datos correctos
   p. Imprime reporte

5. USO:
   q. Director recibe reporte impreso
   r. Analiza distribucion geografica
   s. Identifica concentraciones
   t. Prepara presentacion para cabildo
   u. Usa datos para toma de decisiones
```

**Caso de Uso: Auditoria de Ingresos**

```
1. REQUERIMIENTO:
   a. Contraloria solicita estadisticas de recaudacion
   b. Periodo: Primer trimestre del año
   c. Desglose por tipo de licencia y recaudadora

2. ACCESO:
   d. Contador abre modulo
   e. Selecciona "Estadisticas de recaudacion"
   f. Captura fechas: 01/01/YYYY a 31/03/YYYY

3. GENERACION:
   g. Presiona "Imprimir"
   h. Sistema ejecuta 5 consultas diferentes:
      - Total de pagos por recaudadora
      - Reglamentadas nuevas (cantidad e importe)
      - Reglamentadas refrendo (cantidad e importe)
      - No reglamentadas nuevas (cantidad)
      - No reglamentadas refrendo (cantidad)

4. PROCESAMIENTO:
   i. Sistema itera sobre cada consulta
   j. Acumula totales por recaudadora (1,2,3,4)
   k. Llena campos del reporte dinamicamente
   l. Calcula totales generales

5. RESULTADO:
   m. Sistema genera ppReport5
   n. Muestra resumen ejecutivo con:
      - Total pagos: 1,250
      - Reglamentadas nuevas: 45 ($450,000)
      - Reglamentadas refrendo: 800 ($2,400,000)
      - No reglamentadas nuevas: 120
      - No reglamentadas refrendo: 285
      - Desglose por recaudadora
   o. Contador verifica cifras
   p. Imprime para expediente de auditoria

6. USO:
   q. Contraloria recibe reporte
   r. Compara con ingresos reportados
   s. Valida consistencia de datos
   t. Archiva como evidencia documental
```

## Notas Importantes

### Consideraciones especiales

1. **Multiples Reportes en Un Modulo:**
   - Centralizacion de reportes estadisticos
   - Facilita mantenimiento
   - Interfaz consistente

2. **Queries Dinamicos:**
   - SQL se construye en tiempo de ejecucion
   - Flexibilidad en filtros
   - Optimizacion segun necesidad

3. **Complejidad del Reporte 3 y 4:**
   - Usa OUTER JOINS para incluir ceros
   - Crea columnas virtuales por zona
   - Agrupacion y totales complejos
   - Requiere buen diseño de query

4. **Reporte 5 es Computacionalmente Intensivo:**
   - 5 queries separados
   - Iteraciones sobre resultados
   - Llenado manual de campos del reporte
   - Puede tardar en cuentas grandes

5. **Reportes con Agrupacion:**
   - ppReport3 y ppReport4 tienen Group Headers y Footers
   - Subtotales por clasificacion
   - Total general al final

### Restricciones

1. **No Permite Personalizacion:**
   - Reportes estan prediseñados
   - No se pueden modificar columnas o agrupaciones
   - Usuario debe usar reporte tal cual

2. **Fechas en Algunos Reportes:**
   - No todos los reportes usan fechas
   - Reporte 2 fuerza año actual
   - No hay opcion de cambiar

3. **Un Reporte a la Vez:**
   - No permite comparativas multiples en un reporte
   - Para comparar periodos, generar multiples reportes

4. **Sin Exportacion:**
   - No incluye exportacion a Excel
   - Solo impresion o PDF
   - Para analisis en Excel, requiere modulo diferente

### Permisos necesarios

- **Consulta de Licencias:** Lectura en tabla licencias
- **Consulta de Giros:** Lectura en c_giros
- **Consulta de Pagos:** Lectura en tabla pagos
- **Generacion de Reportes:** Acceso al motor de reportes
- **Impresion:** Permisos de impresion o generacion de PDF

### Interpretacion de Resultados

**Reporte 1 - Pagos:**
- Permite ver detalle de transacciones
- Util para auditoria de caja
- Identifica picos de recaudacion

**Reporte 2 - Altas y Bajas:**
- Muestra tendencias mensuales
- Identifica estacionalidad
- Detecta anomalias en altas/bajas

**Reporte 3 - Distribucion Vigentes:**
- Identifica concentracion de giros
- Muestra distribucion geografica
- Apoya planeacion urbana

**Reporte 4 - Otorgamiento por Periodo:**
- Analiza nuevas licencias
- Compara crecimiento entre zonas
- Identifica sectores en expansion

**Reporte 5 - Recaudacion:**
- Vision ejecutiva de ingresos
- Compara recaudadoras
- Separa tipos de licencia
- Distingue nuevas de refrendos
- Base para proyecciones financieras

### Importancia Gerencial

Estos reportes son fundamentales para:
- Toma de decisiones estrategicas
- Planeacion fiscal y presupuestal
- Analisis de comportamiento del sistema
- Identificacion de areas de oportunidad
- Cumplimiento de transparencia
- Reportes a autoridades superiores
- Auditoria y control interno
