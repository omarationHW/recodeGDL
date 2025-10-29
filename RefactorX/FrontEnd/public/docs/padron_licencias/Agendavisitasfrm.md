# AGENDA DE VISITAS - Módulo de Programación y Control de Inspecciones

## ¿QUÉ ES?
El módulo **Agenda de Visitas** es una herramienta administrativa de consulta, control y reporteo que permite gestionar el calendario completo de visitas de inspección programadas por las diferentes dependencias municipales. Es el sistema central para coordinar todas las inspecciones relacionadas con trámites de licencias y anuncios.

## ¿PARA QUÉ SIRVE?

### Propósito Principal
Proporcionar visibilidad y control sobre las visitas de inspección programadas, permitiendo:
- **Consulta centralizada** de todas las visitas agendadas por dependencia
- **Planificación de recursos** humanos y materiales para inspecciones
- **Seguimiento de compromisos** adquiridos con contribuyentes
- **Generación de evidencia documental** de las agendas programadas
- **Exportación de información** para análisis y seguimiento externo
- **Impresión de rutas** de trabajo para inspectores

### Usuarios del Sistema
1. **Personal de ventanilla**: Consulta de citas agendadas con ciudadanos
2. **Inspectores**: Conocer su agenda de visitas del día/semana
3. **Supervisores**: Planificar cargas de trabajo y rutas
4. **Coordinadores de dependencia**: Seguimiento de compromisos
5. **Área de estadística**: Análisis de productividad y tiempos de respuesta

## ¿CÓMO FUNCIONA?

### Proceso Operativo Completo

#### 1. CONSULTA DE VISITAS
**Paso a paso:**
1. Al abrir el módulo, el sistema carga automáticamente:
   - Lista de dependencias que tienen horarios de visita configurados
   - Fecha actual como rango inicial de consulta (del día a día)

2. El usuario selecciona:
   - **Dependencia**: De un catálogo desplegable (ejemplo: Padrón y Licencias, Ecología, Protección Civil)
   - **Rango de fechas**: Fecha inicial y fecha final del periodo a consultar

3. Al presionar **"Buscar"**, el sistema ejecuta la consulta y muestra en pantalla una cuadrícula con todos los registros que cumplan los criterios

#### 2. VISUALIZACIÓN DE RESULTADOS
La cuadrícula muestra la siguiente información por cada visita:

**Información de la Cita:**
- **Fecha Visita**: Día programado para la inspección
- **Día**: Nombre del día en letras (Lunes, Martes, etc.)
- **Turno**: M (Matutino) o V (Vespertino)
- **Hora**: Hora específica asignada (ej: 10:00-11:00)

**Información del Trámite:**
- **Folio**: Número de trámite asociado
- **Fecha Trám**: Fecha en que se capturó el trámite

**Información del Solicitante:**
- **Propietario**: Nombre completo del propietario/solicitante
- **Actividad**: Giro o actividad comercial a inspeccionar

**Información de Ubicación:**
- **Ubicación**: Domicilio completo donde se realizará la visita (calle, número exterior/interior, letras, colonia)
- **Zona-Subzona**: Clasificación geográfica para organización de rutas

#### 3. EXPORTACIÓN A EXCEL/HTML
**Funcionalidad:**
- Permite guardar toda la información consultada en formato HTML (abrible en Excel)
- Muestra barra de progreso durante el proceso de exportación
- Nombre predeterminado del archivo: "Visitas Agendadas"
- El usuario selecciona la ubicación donde guardar el archivo

**Uso práctico:**
- Compartir información con otras áreas
- Análisis estadístico externo
- Respaldo de información
- Envío por correo a inspectores

#### 4. IMPRESIÓN DE REPORTE
**Características del reporte impreso:**
- **Encabezado oficial**: Logo del Municipio de Guadalajara
- **Identificación**: "DIRECCIÓN DE PADRÓN Y LICENCIAS - REPORTE DE VISITAS AGENDADAS"
- **Filtro aplicado**: Muestra la dependencia seleccionada
- **Detalle de visitas**: Todos los campos en formato tabular organizado
- **Formato**: Tamaño carta, orientación horizontal

**Uso práctico:**
- Documento oficial para entrega a inspectores
- Evidencia de programación para expedientes
- Soporte para auditorías
- Coordinación con otras dependencias

## ¿QUÉ NECESITA PARA FUNCIONAR?

### Datos de Entrada (Parámetros Obligatorios)
1. **Dependencia (id_dependencia)**:
   - Tipo: Número entero
   - Origen: Catálogo de dependencias municipales
   - Ejemplos: 30=Padrón y Licencias, 31=Ecología

2. **Rango de Fechas**:
   - **Fecha inicial**: Día de inicio del periodo de consulta
   - **Fecha final**: Día de fin del periodo de consulta
   - Formato: DD/MM/AAAA

### Información que Consulta
El sistema obtiene datos combinados de múltiples fuentes:
- Detalles de la visita (fecha, hora, turno)
- Información del trámite asociado
- Datos del propietario/solicitante
- Ubicación completa del negocio
- Clasificación geográfica (zona/subzona)
- Actividad económica a inspeccionar

## TABLAS DE BASE DE DATOS

### Tabla Principal
**tramites_visitas**
- **Descripción**: Almacena cada visita de inspección programada
- **Datos clave**:
  - fecha: Día de la visita
  - hora: Horario asignado
  - turno: M (Matutino) / V (Vespertino)
  - id_tramite: Referencia al trámite que generó la visita
  - c_dep_horario_id: Referencia al horario/dependencia

### Tablas de Apoyo (Consultadas)

**1. c_dep_horario**
- **Propósito**: Catálogo de horarios disponibles por dependencia
- **Relación**: Vincula la visita con la dependencia que la agenda
- **Campos usados**:
  - id: Identificador del horario
  - id_dependencia: Dependencia responsable

**2. c_dependencias**
- **Propósito**: Catálogo maestro de dependencias municipales
- **Campos usados**:
  - id_dependencia: Identificador único
  - descripcion: Nombre de la dependencia (ej: "DIRECCIÓN DE PADRÓN Y LICENCIAS")

**3. tramites**
- **Propósito**: Información completa del trámite asociado a la visita
- **Campos usados**:
  - id_tramite: Folio del trámite
  - propietario: Nombre(s) del solicitante
  - primer_ap: Primer apellido
  - segundo_ap: Segundo apellido
  - feccap: Fecha de captura del trámite
  - actividad: Giro o actividad comercial
  - ubicacion: Domicilio del establecimiento
  - numext_ubic, letraext_ubic, numint_ubic, letraint_ubic: Numeración
  - zona, subzona: Clasificación geográfica
  - dia: Número del día de la semana (1-7)

## STORED PROCEDURES (SP) QUE CONSUME

**NINGUNO** - Este módulo NO ejecuta procedimientos almacenados. Utiliza exclusivamente consultas SQL parametrizadas (queries) para obtener la información.

### Consulta SQL Principal
Realiza un JOIN entre 3 tablas:
1. tramites_visitas (v)
2. c_dep_horario (h) - filtra por dependencia
3. tramites (t) - obtiene información del solicitante y ubicación

**Filtros aplicados**:
- Dependencia específica seleccionada
- Rango de fechas (fecha inicial <= fecha visita <= fecha final)

## TABLAS QUE AFECTA

**NINGUNA - MÓDULO DE SOLO LECTURA**

Este módulo **NO modifica** ninguna información en la base de datos. Es exclusivamente de **consulta y reporte**. No realiza:
- Inserciones (INSERT)
- Actualizaciones (UPDATE)
- Eliminaciones (DELETE)

## REPERCUSIONES OPERATIVAS

### Impacto en la Operación Diaria

#### Beneficios Administrativos
1. **Planificación efectiva**: Permite organizar rutas y cargas de trabajo de inspectores
2. **Cumplimiento de compromisos**: Asegura que las citas agendadas se cumplan
3. **Evidencia documental**: Genera comprobantes de las agendas programadas
4. **Coordinación entre áreas**: Facilita comunicación entre dependencias
5. **Transparencia**: El ciudadano puede verificar su cita

#### Consideraciones Operativas
1. **Calidad de datos**: Los reportes dependen de que las visitas estén correctamente agendadas en el sistema
2. **Actualización en tiempo real**: Los cambios en las visitas se reflejan inmediatamente en las consultas
3. **Acceso multi-dependencia**: Cada dependencia solo ve sus propias visitas programadas
4. **Rangos de fecha coherentes**: Fecha inicial debe ser menor o igual a fecha final

### Impacto en Recursos
- **No afecta tiempos de sistema**: Al ser solo consulta, no genera bloqueos
- **Exportación**: Proceso puede tardar varios segundos si hay muchos registros
- **Impresión**: Genera documentos oficiales con formato estándar

## FLUJO DE TRABAJO TÍPICO

### Escenario 1: Inspector Consulta su Agenda del Día
1. Inspector abre el módulo al inicio de su jornada
2. Selecciona su dependencia (ej: Padrón y Licencias)
3. Mantiene el rango de fechas del día actual (predeterminado)
4. Presiona "Buscar"
5. Revisa en pantalla sus visitas programadas (hora, dirección, actividad)
6. Opcionalmente imprime el reporte para llevar en campo
7. Organiza su ruta según las zonas y horarios

### Escenario 2: Supervisor Planifica la Semana
1. Supervisor abre el módulo
2. Selecciona su dependencia
3. Modifica rango de fechas: Lunes a Viernes de la semana actual
4. Presiona "Buscar"
5. Analiza distribución de visitas por día y zona
6. Exporta a Excel para análisis detallado
7. Asigna inspectores a zonas específicas
8. Genera reportes impresos por día para cada inspector

### Escenario 3: Área de Estadística Genera Informe Mensual
1. Usuario de estadística abre el módulo
2. Selecciona dependencia a analizar
3. Establece rango del 1 al 30/31 del mes
4. Presiona "Buscar"
5. Exporta a Excel todo el mes
6. Analiza:
   - Total de visitas programadas
   - Distribución por zonas
   - Tipos de actividades inspeccionadas
   - Productividad por turno (matutino vs vespertino)
7. Genera indicadores de gestión

## CAMPOS CALCULADOS Y FUNCIONES ESPECIALES

### Día en Letras
- **Campo**: dia_letras
- **Función**: fn_dialetra(dia)
- **Propósito**: Convierte número de día (1-7) a nombre (Lunes-Domingo)
- **Uso**: Facilita lectura del reporte

### Domicilio Completo
- **Campo**: domCompleto
- **Construcción**: Concatena calle + No. ext + Letra ext + No. int + Letra int
- **Formato**: "CALLE No. ext: 123 Letra ext. A No. int. 5 Letra int. B"
- **Uso**: Visualización completa de la dirección en una sola columna

### Propietario Completo
- **Campo**: propietarionvo
- **Construcción**: primer_ap + segundo_ap + propietario
- **Formato**: "GARCÍA LÓPEZ JUAN"
- **Uso**: Nombre completo ordenado (apellidos + nombre)

## VALIDACIONES Y CONTROLES

### Validaciones Automáticas
1. **Dependencia obligatoria**: Debe seleccionarse una dependencia del catálogo
2. **Fechas válidas**: Sistema valida formato de fechas
3. **Dependencias activas**: Solo muestra dependencias que tienen horarios configurados

### Controles de Seguridad
- Solo muestra visitas de la dependencia seleccionada
- No permite modificar datos (solo lectura)
- Genera log de consultas para auditoría

## TIPS Y MEJORES PRÁCTICAS

### Para Inspectores
- Consultar la agenda al inicio del día
- Imprimir reporte para llevar en campo (incluye direcciones completas)
- Revisar zona/subzona para optimizar rutas

### Para Supervisores
- Exportar semanalmente para planificación
- Analizar distribución de carga entre inspectores
- Verificar cumplimiento de citas programadas

### Para Personal Administrativo
- Verificar que todas las visitas estén correctamente agendadas
- Confirmar que los datos de ubicación sean precisos
- Asegurar que se asignó el turno y hora correcta

## INTEGRACIÓN CON OTROS MÓDULOS

Este módulo consume información generada por:
- **Módulo de Registro de Trámites**: Crea los trámites
- **Módulo de Agendamiento**: Programa las visitas
- **Catálogo de Dependencias**: Define qué dependencias pueden agendar
- **Catálogo de Horarios**: Establece disponibilidad de horarios

La información consultada aquí alimenta:
- Reportes de productividad
- Indicadores de gestión
- Seguimiento de compromisos con ciudadanos
