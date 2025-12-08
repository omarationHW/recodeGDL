# Reporte de Giros Vigentes por Cantidad de Licencias

## Descripcion General

### Que hace este modulo
El modulo de Giros Vigentes genera reportes estadisticos que muestran cuantas licencias existen por cada tipo de giro comercial. Permite analizar la distribucion de licencias vigentes y las bajas de licencias, agrupadas por giro economico, facilitando la toma de decisiones y el analisis del comportamiento comercial del municipio.

### Para que sirve en el proceso administrativo
Este modulo sirve para:
- Generar estadisticas de licencias por giro
- Identificar giros con mayor actividad comercial
- Analizar tendencias de altas y bajas de licencias
- Comparar comportamiento entre diferentes tipos de giro
- Proporcionar informacion para planeacion economica
- Generar reportes para direccion y autoridades municipales
- Filtrar analisis por clasificacion de giros (A, B, C, D)
- Consultar datos historicos por año o rango de fechas

### Quienes lo utilizan
- Directores de area que requieren estadisticas
- Personal de planeacion municipal
- Analistas de desarrollo economico
- Autoridades municipales para toma de decisiones
- Personal de sistemas para reportes gerenciales
- Auditores internos y externos
- Personal de transparencia para informacion publica

## Proceso Administrativo

### Como funciona el proceso paso a paso

**Generacion del Reporte:**

1. **Configuracion de Parametros:**
   - Usuario selecciona ordenamiento:
     - Por cantidad (de mayor a menor numero de licencias)
     - Alfabetico (por descripcion del giro)

   - Usuario selecciona tipo de reporte:
     - Licencias vigentes con mayor alta
     - Licencias con mayor baja

   - Usuario selecciona periodo:
     - Por año especifico (captura año)
     - Por rango de fechas (captura fecha inicial y final)

   - Usuario selecciona clasificacion:
     - Todas las clasificaciones
     - Solo tipo A
     - Solo tipo B
     - Solo tipo C
     - Solo tipo D

2. **Validaciones:**
   - Sistema valida que se haya capturado año O rango de fechas
   - Si se captura año, desabilita fechas
   - Si se capturan fechas, desabilita año
   - Valida que ambas fechas esten completas si se usa rango

3. **Generacion:**
   - Usuario presiona boton "Imprimir"
   - Sistema construye consulta dinamica segun filtros
   - Sistema ejecuta query con agrupacion por giro
   - Sistema ordena segun seleccion del usuario
   - Sistema genera reporte con totales

4. **Visualizacion:**
   - Sistema muestra reporte con:
     - Codigo del giro
     - Descripcion del giro
     - Cantidad de licencias
   - Total general al final
   - Titulo dinamico segun filtros aplicados

### Que informacion requiere el usuario

**Parametros Obligatorios (uno u otro):**
- **Año:** Año de alta o baja de licencias (formato: YYYY)
- **Rango de Fechas:** Fecha inicial y fecha final

**Parametros Opcionales:**
- **Ordenamiento:** Como presentar los datos
- **Tipo de Reporte:** Altas o bajas
- **Clasificacion:** Filtrar por tipo de giro

**Informacion que se Muestra:**
- ID del giro
- Codigo del giro
- Descripcion completa del giro
- Cantidad de licencias en ese giro
- Total general de licencias

### Que validaciones se realizan

1. **Validacion de Periodo:**
   - Verifica que se indique año O fechas, no ambos
   - Si falta periodo, muestra mensaje: "Debes indicar el año o el rango de fechas"
   - Si solo hay una fecha del rango, muestra: "Debes indicar ambas fechas"

2. **Mutua Exclusividad:**
   - Al capturar año, limpia las fechas
   - Al capturar fechas, limpia el año
   - Evita confusiones en los criterios

3. **Validacion de Usuario:**
   - Usuarios 'jlopezv' y 'proceso' tienen restricciones especiales
   - Se fuerza clasificacion D y se deshabilita opcion
   - Restringe analisis a giros tipo D unicamente

4. **Construccion de Query:**
   - Query dinamico segun filtros seleccionados
   - Incluye joins para relacionar licencias con giros
   - Agrupa por giro y cuenta licencias

### Que documentos genera

**Reporte Estadistico de Giros:**
- Titulo dinamico que indica:
  - Tipo de reporte (altas o bajas)
  - Periodo analizado (año o rango de fechas)
  - Clasificacion filtrada (si aplica)
- Listado con:
  - Codigo de giro
  - Descripcion del giro
  - Cantidad de licencias
- Total general de licencias
- Logo institucional
- Fecha de emision
- Numero de pagina

## Tablas de Base de Datos

### Tabla Principal
- **licencias:** Tabla de todas las licencias del municipio con sus estados, fechas y relaciones con giros

### Tablas Relacionadas

**Tablas que Consulta:**
- **licencias:** Datos de licencias vigentes o dadas de baja
- **c_giros:** Catalogo de giros con codigo, descripcion y clasificacion
- **buscaGiros (query):** Consulta dinamica que agrupa licencias por giro

**Tablas que Modifica:**
- **Ninguna:** Modulo de solo lectura, no modifica datos

## Stored Procedures
- **Ninguno:** No utiliza procedimientos almacenados, solo queries de consulta

## Impacto y Repercusiones

### Que registros afecta
- **Ninguno:** Es un modulo de consulta y reportes solamente
- No modifica estados ni datos de licencias o giros
- Solo lee informacion existente

### Que cambios de estado provoca
- **Ninguno:** No provoca cambios en el sistema
- Es una herramienta de analisis sin efectos transaccionales

### Que documentos/reportes genera

**Reporte Principal:**
- Estadistica de giros con cantidad de licencias
- Puede filtrarse por multiples criterios
- Util para:
  - Analisis de mercado
  - Planeacion urbana
  - Estudios economicos
  - Reportes a autoridades
  - Informacion publica

### Que validaciones de negocio aplica

1. **Filtro de Vigencia:**
   - Distingue entre licencias vigentes (V) y no vigentes
   - Solo cuenta licencias activas para reporte de altas
   - Solo cuenta licencias no vigentes para reporte de bajas

2. **Agrupacion por Giro:**
   - Suma todas las licencias del mismo giro
   - Proporciona vision consolidada por actividad economica

3. **Clasificacion de Giros:**
   - Permite analizar por tipo de actividad (A, B, C, D)
   - Facilita estudios sectoriales

4. **Periodos de Analisis:**
   - Por año completo (01/ene a 31/dic)
   - Por rango especifico de fechas
   - Basado en fecha_otorgamiento o fecha_baja

## Flujo de Trabajo

### Descripcion del flujo completo del proceso

**Flujo Completo:**

```
1. Usuario abre modulo de Giros Vigentes
2. Si es usuario restringido (jlopezv o proceso):
   - Sistema fuerza clasificacion D
   - Deshabilita selector de clasificacion
3. Usuario configura parametros:
   a. Selecciona ordenamiento (cantidad o alfabetico)
   b. Selecciona tipo (vigentes/altas o bajas)
   c. Captura periodo:
      - Opcion 1: Captura año (limpia fechas automaticamente)
      - Opcion 2: Captura fechas (limpia año automaticamente)
   d. Selecciona clasificacion (si no esta restringido)
4. Usuario presiona "Imprimir"
5. Sistema valida:
   - Que haya año O fechas
   - Que fechas esten completas si se usa rango
6. Sistema construye query:
   - Agrega filtros segun tipo de reporte
   - Agrega filtro de periodo
   - Agrega filtro de clasificacion si aplica
   - Agrega agrupacion por giro
   - Agrega ordenamiento seleccionado
7. Sistema ejecuta query
8. Sistema carga datos en pipeline del reporte
9. Sistema construye titulo dinamico del reporte
10. Sistema genera e imprime reporte
11. Usuario recibe reporte con estadisticas solicitadas
```

## Notas Importantes

### Consideraciones especiales

1. **Usuarios Restringidos:**
   - Usuarios 'jlopezv' y 'proceso' tienen acceso limitado
   - Solo pueden ver giros tipo D
   - Esta restriccion se aplica al abrir el modulo
   - Caso de uso: Personal externo o con acceso parcial

2. **Dinamica de Titulo:**
   - El reporte cambia su titulo segun los filtros
   - Ejemplos:
     - "REPORTE DE GIROS VIGENTES CON MAYOR ALTA DE LICENCIA Y TIPO = C"
     - "REPORTE DE GIROS CON MAYOR BAJA DE LICENCIAS"
     - "Licencias emitidas en el año: 2023"

3. **Ordenamiento Flexible:**
   - Por cantidad: Muestra giros con mas licencias primero
   - Alfabetico: Facilita buscar giro especifico
   - Util para diferentes tipos de analisis

4. **Clasificaciones de Giro:**
   - A, B, C, D representan diferentes categorias
   - La clasificacion esta en el catalogo de giros
   - Permite analisis sectoriales especificos

5. **Total General:**
   - El reporte incluye suma total de licencias
   - Permite validar completitud de datos
   - Facilita comparaciones entre reportes

### Restricciones

1. **No Edita Datos:**
   - Solo consulta, no permite modificar informacion
   - Si hay errores en datos, deben corregirse en modulos origen

2. **Requiere Configuracion:**
   - No genera reporte sin parametros
   - Usuario debe seleccionar al menos periodo

3. **Un Reporte a la Vez:**
   - No permite comparativas en mismo reporte
   - Para comparar periodos, debe generar multiples reportes

### Permisos necesarios

- **Consulta de Licencias:** Lectura en tabla licencias
- **Consulta de Giros:** Lectura en catalogo de giros
- **Generacion de Reportes:** Acceso al motor de reportes
- **Impresion:** Permisos de impresion

### Uso del Reporte

**Casos de Uso Comunes:**

1. **Analisis de Mercado:**
   - Identificar giros con mayor demanda
   - Detectar tendencias de crecimiento
   - Planear inspecc iones segun concentracion

2. **Planeacion Urbana:**
   - Conocer distribucion de actividades economicas
   - Identificar saturacion de ciertos giros
   - Planear desarrollo de zonas comerciales

3. **Reportes Institucionales:**
   - Informes a cabildo
   - Transparencia y acceso a informacion
   - Estadisticas para organismos externos

4. **Control Administrativo:**
   - Monitorear comportamiento de licencias
   - Detectar anomalias en otorgamientos o bajas
   - Validar procesos de recaudacion

5. **Estudios Economicos:**
   - Analizar sectores economicos
   - Comparar periodos historicos
   - Proyectar crecimiento economico

### Interpretacion de Resultados

**Giros con Mayor Cantidad:**
- Indica actividades economicas predominantes
- Puede reflejar vocacion economica del municipio
- Requiere mayor atencion en inspeccion y regulacion

**Giros con Bajas:**
- Identifica sectores en declive
- Puede indicar problemas economicos o regulatorios
- Requiere analisis de causas

**Clasificaciones:**
- Tipo A y B: Generalmente bajo impacto
- Tipo C y D: Mayor impacto y regulacion
- La distribucion indica perfil del municipio
