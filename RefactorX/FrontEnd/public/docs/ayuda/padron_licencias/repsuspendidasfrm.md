# Reporte de Licencias Suspendidas/Bloqueadas

## Descripcion General

### Que hace este modulo
El modulo de Reporte de Licencias Suspendidas genera listados de licencias que se encuentran bloqueadas o suspendidas por diversas razones administrativas, legales o regulatorias. Permite filtrar por tipo de bloqueo, periodo de tiempo y generar reportes detallados para seguimiento y control.

### Para que sirve en el proceso administrativo
Este modulo sirve para:
- Generar listados de licencias suspendidas o bloqueadas
- Consultar licencias por tipo especifico de bloqueo
- Filtrar suspensiones por periodo de tiempo
- Producir reportes para seguimiento de inspecciones
- Documentar estatus de licencias irregulares
- Facilitar acciones administrativas o legales
- Proporcionar informacion para auditoria
- Apoyar campanas de regularizacion

### Quienes lo utilizan
- Inspectores que dan seguimiento a establecimientos suspendidos
- Personal juridico que procesa casos de clausura
- Supervisores que monitorean cumplimiento normativo
- Direccion para reportes de establecimientos irregulares
- Auditores que verifican acciones administrativas
- Personal de sistemas para estadisticas

## Proceso Administrativo

### Como funciona el proceso paso a paso

**Configuracion de Parametros:**

1. **Seleccion de Periodo:**
   - Usuario puede filtrar por año especifico:
     - Captura año en formato YYYY
     - Al capturar año, se limpian fechas automaticamente
   - O por rango de fechas:
     - Captura fecha inicial
     - Captura fecha final (opcional si solo quiere un dia)
     - Al capturar fechas, se limpia año automaticamente

2. **Seleccion de Tipo de Bloqueo:**
   Usuario selecciona mediante RadioGroup:
   - **Todas:** Muestra todos los tipos de bloqueo
   - **Bloqueado (1):** Licencias bloqueadas administrativamente
   - **Estado 1 (2):** Primer estado de irregularidad
   - **Cabaret (3):** Establecimientos tipo cabaret (regulacion especial)
   - **Suspendida (4):** Licencias formalmente suspendidas
   - **Responsiva (5):** Con responsiva pendiente

**Generacion del Reporte:**

1. Usuario configura parametros (periodo y tipo)
2. Usuario presiona boton "Imprimir"
3. Sistema realiza validaciones:
   - Verifica que haya año O rango de fechas
   - Si falta, muestra: "Debes indicar el año o las fechas de las licencias..."
   - Si solo hay una fecha del rango, es valido (toma ese dia especifico)

4. Sistema construye query dinamico:
   - Base: SELECT de licencias JOIN bloqueo
   - Filtro de periodo segun lo capturado
   - Filtro de tipo de bloqueo segun seleccion
   - Incluye vigencia = "V" del bloqueo

5. Sistema ejecuta query y valida resultados:
   - Si hay registros: Genera e imprime reporte
   - Si no hay registros: Muestra mensaje "No se encontraron licencias con esas condiciones..."

6. Reporte incluye:
   - Numero de licencia
   - Propietario (nombre completo concatenado)
   - Domicilio de ubicacion
   - Actividad/giro
   - Fecha de suspension/bloqueo
   - Tipo de bloqueo (traducido a texto descriptivo)
   - Motivo u observaciones
   - Total de licencias suspendidas

### Que informacion requiere el usuario

**Parametros de Busqueda (uno u otro):**
- **Año:** Año de la suspension (formato: YYYY)
- **Fechas:** Fecha inicial y/o final de suspension

**Parametros Opcionales:**
- **Tipo de Bloqueo:** Filtrar por categoria especifica

**Informacion que se Genera:**
- Numero de licencia
- Propietario completo (apellidos + nombre)
- Actividad comercial
- Domicilio de ubicacion (calle, numero, colonia)
- Fecha de movimiento (cuando se bloqueo)
- Tipo de bloqueo en texto descriptivo
- Total de licencias en el reporte

### Que validaciones se realizan

1. **Validacion de Periodo:**
   - Debe capturarse año O fechas
   - No permite generar sin este dato
   - Mensaje claro si falta: "Debes indicar el año o las fechas..."

2. **Mutual Exclusividad:**
   - Al capturar año, limpia fechas
   - Al capturar fechas, limpia año
   - Evita confusiones en criterios

3. **Flexibilidad en Fechas:**
   - Si solo captura fecha inicial: Busca ese dia especifico
   - Si captura ambas: Busca en el rango
   - Valida formato de fecha

4. **Traduccion de Tipo de Bloqueo:**
   - En el reporte, traduce codigo numerico a texto:
     - 0 → "NO BLOQUEADO"
     - 1 → "BLOQUEADO"
     - 2 → "ESTADO 1"
     - 3 → "CABARET"
     - 4 → "SUSPENDIDA"
     - 5 → "RESPONSIVA"
     - Otro → "NO DETERMINADO"
   - Se ejecuta en evento GetText del campo

5. **Validacion de Resultados:**
   - Si query no retorna registros
   - Muestra mensaje amigable
   - No intenta imprimir reporte vacio

### Que documentos genera

**Reporte de Licencias Suspendidas/Bloqueadas:**
- Formato oficial con logo institucional
- Titulo: "REPORTE DE LICENCIAS SUSPENDIDAS/BLOQUEADAS"
- Columnas:
  - Numero de Licencia
  - Propietario
  - Actividad
  - Ubicacion
  - Fecha de Bloqueo
  - Tipo de Bloqueo (texto descriptivo)
- Total general de licencias
- Fecha de emision
- Numero de pagina
- Pie de pagina con datos del sistema

## Tablas de Base de Datos

### Tabla Principal
- **licencias:** Tabla de licencias del municipio
- **bloqueo:** Tabla de bloqueos asociados a licencias

### Tablas Relacionadas

**Tablas que Consulta:**
- **licencias:** Datos de la licencia (numero, propietario, actividad, ubicacion)
- **bloqueo:** Registro de bloqueo (fecha, tipo, vigencia, observaciones)
- **Query dinamico:** JOIN entre licencias y bloqueo

**Tablas que Modifica:**
- **Ninguna:** Modulo de solo lectura para reportes

## Stored Procedures
- **Ninguno:** No utiliza procedimientos almacenados

## Impacto y Repercusiones

### Que registros afecta
- **Ninguno:** Modulo de consulta y reportes
- No modifica estados de licencias
- No altera bloqueos existentes
- Solo lectura de informacion

### Que cambios de estado provoca
- **Ninguno:** Es completamente pasivo
- No afecta operacion del sistema
- No desbloquea ni bloquea licencias

### Que documentos/reportes genera
- Reporte impreso de licencias suspendidas/bloqueadas
- Puede generarse en PDF para distribucion
- Formato oficial para documentacion

### Que validaciones de negocio aplica

1. **Vigencia del Bloqueo:**
   - Solo incluye bloqueos vigentes (vigente = "V")
   - No muestra bloqueos historicos levantados
   - Refleja situacion actual de licencias

2. **Relacion Licencia-Bloqueo:**
   - JOIN garantiza que licencia tenga bloqueo activo
   - No incluye licencias sin bloqueo
   - Integridad referencial en la consulta

3. **Filtrado por Tipo:**
   - Permite enfoque en categoria especifica
   - Facilita acciones dirigidas
   - Segmenta problematica por tipo

4. **Periodo de Analisis:**
   - Por año: Licencias bloqueadas en ese ejercicio
   - Por fecha: Precision en el periodo
   - Historico o actual segun necesidad

## Flujo de Trabajo

### Descripcion del flujo completo del proceso

**Caso de Uso: Campana de Regularizacion de Establecimientos Suspendidos**

```
1. PLANEACION:
   a. Direccion decide realizar campana de regularizacion
   b. Requiere listado de establecimientos suspendidos
   c. Periodo: Suspensiones del año actual

2. GENERACION DE LISTADO:
   d. Supervisor abre modulo
   e. Captura año: 2024
   f. Selecciona tipo: "Suspendida (4)"
   g. Presiona "Imprimir"

3. PROCESAMIENTO:
   h. Sistema valida que año este capturado (Ok)
   i. Sistema construye query:
      - Licencias con bloqueo vigente
      - Fecha de movimiento en 2024
      - Tipo de bloqueo = 4 (Suspendida)
   j. Sistema ejecuta consulta
   k. Encuentra 45 licencias suspendidas

4. GENERACION DE REPORTE:
   l. Sistema genera reporte con las 45 licencias
   m. Muestra:
      - Numero de licencia
      - Nombre del propietario
      - Domicilio del establecimiento
      - Fecha de suspension
      - "SUSPENDIDA" en tipo de bloqueo
   n. Total: 45 licencias
   o. Supervisor imprime reporte

5. USO DEL REPORTE:
   p. Se distribuye a inspectores
   q. Cada inspector recibe grupo de establecimientos
   r. Realizan visitas para verificar situacion
   s. Ofrecen opciones de regularizacion
   t. Dan seguimiento hasta levantamiento de suspension
   u. Reportan avances usando listado como guia

6. SEGUIMIENTO:
   v. Conforme se regularizan, se levantan bloqueos en sistema
   w. En proxima generacion de reporte, esas licencias ya no aparecen
   x. Permite medir avance de la campana
```

**Caso de Uso: Auditoria de Acciones Administrativas**

```
1. REQUERIMIENTO:
   a. Contraloria solicita evidencia de acciones administrativas
   b. Requiere listado de clausuras del ultimo trimestre
   c. Para verificar cumplimiento de procedimientos

2. GENERACION:
   d. Auditor abre modulo
   e. Captura fechas:
      - Inicial: 01/01/2024
      - Final: 31/03/2024
   f. Selecciona tipo: "Todas"
   g. Presiona "Imprimir"

3. RESULTADO:
   h. Sistema genera reporte con todas las suspensiones del trimestre
   i. Incluye todos los tipos de bloqueo
   j. Muestra 128 registros
   k. Auditor imprime para expediente

4. ANALISIS:
   l. Auditor revisa cada caso
   m. Verifica que haya expediente administrativo
   n. Comprueba que procedimiento fue correcto
   o. Identifica casos que requieren atencion
   p. Prepara informe para contraloria

5. DOCUMENTACION:
   q. Reporte se anexa a expediente de auditoria
   r. Sirve como evidencia de acciones realizadas
   s. Base para recomendaciones de mejora
```

## Notas Importantes

### Consideraciones especiales

1. **Tipos de Bloqueo:**
   - Cada tipo representa situacion administrativa diferente
   - Cabaret (3) tiene regulacion especial
   - Responsiva (5) implica compromiso del propietario
   - Suspendida (4) es la mas severa

2. **Vigencia del Bloqueo:**
   - Solo muestra bloqueos activos (vigente = "V")
   - Bloqueos levantados no aparecen
   - Refleja situacion actual, no historica

3. **Concatenacion de Nombres:**
   - Sistema construye nombre completo
   - Maneja valores nulos con nvl()
   - Formato: "Apellido1 Apellido2 Nombre"

4. **Flexibilidad de Periodo:**
   - Por año: Vision anual completa
   - Por fecha unica: Analisis de dia especifico
   - Por rango: Periodo personalizado

5. **Uso en Campanas:**
   - Listado es base para planear acciones
   - Distribucion de trabajo entre inspectores
   - Seguimiento de avances

### Restricciones

1. **Solo Bloqueos Vigentes:**
   - No muestra historico de bloqueos levantados
   - Para eso existe modulo de historial

2. **No Permite Desbloquear:**
   - Es modulo de reporte, no de operacion
   - Para levantar bloqueos, usar modulo correspondiente

3. **Un Tipo de Reporte:**
   - Siempre el mismo formato
   - No permite personalizacion de columnas

4. **Sin Exportacion:**
   - Solo impresion o PDF
   - No exporta a Excel

### Permisos necesarios

- **Consulta de Licencias:** Lectura en tabla licencias
- **Consulta de Bloqueos:** Lectura en tabla bloqueo
- **Generacion de Reportes:** Acceso al motor de reportes
- **Impresion:** Permisos de impresion o PDF

### Interpretacion de Tipos de Bloqueo

**Bloqueado (1):**
- Bloqueo administrativo general
- Puede ser temporal
- Por incumplimiento menor

**Estado 1 (2):**
- Primer nivel de irregularidad
- Advertencia formal
- Previa a suspension

**Cabaret (3):**
- Giros con regulacion especial
- Requieren permisos adicionales
- Horarios restringidos

**Suspendida (4):**
- Suspension formal de operaciones
- Requiere levantamiento oficial
- Proceso administrativo completo

**Responsiva (5):**
- Compromiso firmado por propietario
- Condicionamiento de operacion
- Seguimiento especial requerido

### Importancia del Reporte

- Evidencia de acciones administrativas
- Base para campanas de regularizacion
- Control de establecimientos irregulares
- Proteccion del interes publico
- Cumplimiento de reglamentos
- Transparencia en actuaciones

### Uso en Diferentes Escenarios

**Inspeccion:**
- Planear rutas de verificacion
- Distribuir trabajo entre inspectores
- Dar seguimiento a casos

**Legal:**
- Documentar acciones administrativas
- Evidencia en procedimientos
- Respaldo en litigios

**Gerencial:**
- Estadisticas de irregularidades
- Efectividad de acciones
- Toma de decisiones

**Auditoria:**
- Verificar cumplimiento normativo
- Validar procedimientos
- Identificar areas de mejora
