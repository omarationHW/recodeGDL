# Impresión de Solicitud de Inspección

## Descripción General

### ¿Qué hace este módulo?
Genera **documentos oficiales para solicitud de inspección** de campo a diferentes dependencias municipales (Reglamentos, Protección Civil, Ecología, Construcción). Es el formato oficial que se envía a las dependencias para programar visitas de inspección de trámites en proceso.

### ¿Para qué sirve en el proceso administrativo?
- Imprimir oficios de solicitud de inspección a dependencias
- Generar documentos oficiales para programar visitas de campo
- Documentar el proceso de revisión de trámites
- Solicitar verificación técnica de establecimientos
- Registrar fechas de inspecciones programadas

### ¿Quiénes lo utilizan?
- **Personal de trámites**: Para solicitar inspecciones
- **Coordinadores**: Para programar agenda de inspectores
- **Dependencias**: Reciben los oficios para programar visitas
- **Archivo**: Para expediente del trámite

## Proceso Administrativo

### Búsqueda de Trámites

**1. Selección de Criterios**
- Usuario captura:
  - **Número de folio de trámite** (CurrencyEdit1)
  - **Rango de fechas** (DateEdit1, DateEdit2)

**2. Ejecución de Búsqueda**
- Click en "Buscar" (BitBtn1)
- Sistema ejecuta query filtrando por criterios:
  - Si hay folio: WHERE folio = [folio]
  - Si hay fechas: WHERE feccap BETWEEN [fecha1] AND [fecha2]
  - Puede combinar ambos filtros
- Muestra resultados en DBGrid1

**3. Selección de Trámite**
- Usuario selecciona trámite del grid
- Sistema muestra información completa en pantalla:
  - Folio, fecha de captura
  - Propietario (nombre completo con apellidos)
  - Actividad comercial / giro
  - Domicilio del propietario
  - Ubicación del negocio
  - Características técnicas
  - Observaciones

### Generación de Documentos

**Opción 1: Impresión Individual**
- Click en "Imprimir" (b_imprimir)
- Imprime formato estándar de solicitud de inspección (ppReport1)

**Opción 2: Impresión por Dependencia**
- Click en "Imprimir 2" (b_imprimir2)
- Sistema consulta qué dependencias deben revisar el trámite (tabla Dep_giroVerif)
- Genera documentos especializados según dependencia:
  - **ppReportReglamentos**: Solicitud a Reglamentos
  - **ppReportProteccion**: Solicitud a Protección Civil
  - **ppReportEcologia**: Solicitud a Ecología
  - **ppReportConstruccion**: Solicitud a Construcción

### Contenido de los Documentos

**Formato General (ppReport1):**
- Membrete municipal
- Número de folio del trámite
- Fecha de solicitud
- Dirigido a: [Dependencia correspondiente]
- Datos del solicitante:
  - Nombre completo
  - RFC
  - Domicilio
  - Teléfono, email
- Datos del inmueble a inspeccionar:
  - Ubicación completa
  - Cruce de calles
  - Zona y subzona
  - Coordenadas
- Actividad solicitada / Giro
- Características técnicas:
  - Superficie
  - Empleados
  - Cajones
  - Aforo
  - Horario
  - Inversión
- Observaciones del trámite
- Área para que la dependencia registre:
  - Fecha de inspección
  - Nombre del inspector
  - Observaciones de la inspección
  - Dictamen (cumple/no cumple)
- Firmas autorizadas

**Formatos Especializados por Dependencia:**

Cada dependencia tiene su formato con campos específicos según su ámbito de competencia:

**1. Reglamentos (ppReportReglamentos):**
- Verificación de cumplimiento del Reglamento de Giros
- Campos específicos de verificación reglamentaria
- Área para anotar infracciones detectadas

**2. Protección Civil (ppReportProteccion):**
- Verificación de medidas de seguridad
- Campos de verificación:
  - Extintores
  - Salidas de emergencia
  - Señalética
  - Botiquín
  - Plan de emergencia
  - Capacitación del personal
- Área para observaciones de seguridad

**3. Ecología (ppReportEcologia):**
- Verificación de impacto ambiental
- Campos de verificación:
  - Manejo de residuos
  - Ruido
  - Emisiones
  - Descargas
- Área para condicionantes ambientales

**4. Construcción (ppReportConstruccion):**
- Verificación de aspectos estructurales y urbanos
- Campos de verificación:
  - Uso de suelo conforme
  - Construcción autorizada
  - Cajones de estacionamiento
  - Accesibilidad
- Área para observaciones técnicas

## Tablas de Base de Datos

### Tabla Principal
**tramites** - Información del trámite a inspeccionar

### Tablas Relacionadas que Consulta

**1. tramites** - Datos completos del trámite
- Todos los campos del trámite:
  - id_tramite, folio, tipo_tramite
  - propietario (nombre), primer_ap, segundo_ap
  - RFC, CURP, domicilio, teléfono, email
  - actividad, id_giro
  - ubicacion (del negocio), numext_ubic, colonia_ubic, CP
  - zona, subzona, x, y (coordenadas)
  - sup_construida, sup_autorizada, num_cajones, num_empleados, aforo
  - inversion, rhorario
  - observaciones, espubic
  - feccap, capturista, estatus

**2. Dep_giroVerif** (Query)
- Relaciona qué dependencias deben revisar según el giro
- Campos: id_dependencia, id_giro, descripcion
- Usado para imprimir formatos especializados

**3. QryCruceCalles** (Query)
- Obtiene las calles de cruce para ubicación precisa
- Ayuda a localizar el inmueble

**4. QryRevisiones** (Query)
- Consulta revisiones ya programadas o realizadas
- Para no duplicar solicitudes

### Tablas que Modifica
**NINGUNA** - Módulo de solo consulta e impresión. No modifica datos.

## Stored Procedures
No utiliza stored procedures.

## Impacto y Repercusiones

### ¿Qué registros afecta?
**NINGUNO** - Solo consulta e imprime documentos

### ¿Qué cambios de estado provoca?
**NINGUNO** - No modifica estatus ni datos del trámite

**Nota**: La programación de la inspección y el registro de resultados se hace en otro módulo (registro de revisiones).

### ¿Qué documentos genera?

**1. Solicitud de Inspección General (ppReport1)**
- Formato estándar
- Para cualquier dependencia
- Incluye todos los datos básicos

**2. Solicitudes Especializadas (según dependencia):**
- **ppReportReglamentos**: Con checklist reglamentario
- **ppReportProteccion**: Con checklist de seguridad
- **ppReportEcologia**: Con checklist ambiental
- **ppReportConstruccion**: Con checklist urbano/constructivo

**Cada documento incluye:**
- Secciones para llenar durante la inspección
- Campos para observaciones
- Espacio para dictamen
- Firmas del inspector y responsable

### ¿Qué validaciones aplica?
1. Valida que existan trámites con los criterios de búsqueda
2. Valida formato de fechas
3. Valida que el folio sea numérico
4. No valida estatus del trámite (puede imprimir aunque ya esté dictaminado)

## Flujo de Trabajo

```
BÚSQUEDA Y SELECCIÓN:
1. Usuario abre módulo
2. Captura criterios:
   - Folio (opcional)
   - Rango de fechas (opcional)
3. Click en "Buscar"
4. Sistema ejecuta query:
   - SQL dinámico según criterios capturados
   - WHERE folio = X (si capturó folio)
   - AND/OR feccap BETWEEN fecha1 AND fecha2
5. Muestra resultados en DBGrid1
6. Usuario revisa listado
7. Selecciona trámite de interés
8. Sistema muestra detalle en pantalla

IMPRESIÓN FORMATO GENERAL:
1. Trámite seleccionado en grid
2. Click en "Imprimir" (b_imprimir)
3. Sistema prepara reporte:
   - Carga datos del trámite
   - Llena campos del reporte
   - Consulta cruces de calles
4. Imprime ppReport1
5. Documento generado para enviar a dependencia
6. FIN

IMPRESIÓN FORMATOS ESPECIALIZADOS:
1. Trámite seleccionado en grid
2. Click en "Imprimir 2" (b_imprimir2)
3. Sistema identifica dependencias que deben revisar:
   - Consulta Dep_giroVerif según id_giro del trámite
   - Obtiene lista de dependencias requeridas
4. Para cada dependencia encontrada:
   4.1. ¿Es Reglamentos?
        SÍ → Imprime ppReportReglamentos
   4.2. ¿Es Protección Civil?
        SÍ → Imprime ppReportProteccion
   4.3. ¿Es Ecología?
        SÍ → Imprime ppReportEcologia
   4.4. ¿Es Construcción?
        SÍ → Imprime ppReportConstruccion
5. Se generan tantos documentos como dependencias deban revisar
6. Cada documento con formato especializado
7. FIN
```

## Notas Importantes

### Consideraciones Especiales

**1. Múltiples Formatos**
- Un trámite puede requerir inspección de varias dependencias
- Se generan documentos separados para cada una
- Cada documento con checklist específico de su competencia

**2. Tabla Dep_giroVerif (Crítica)**
- Define qué dependencias revisan cada tipo de giro
- Ejemplo:
  - Restaurante → Reglamentos + Protección Civil + Ecología
  - Bar → Reglamentos + Protección Civil + Ecología
  - Tienda → Solo Reglamentos
  - Taller → Reglamentos + Protección Civil + Ecología
- Debe estar correctamente configurada

**3. Documentos para Campo**
- Los inspectores llevan estos documentos a la visita
- Llenan información durante la inspección
- Los regresan con observaciones y dictamen
- Se escanean y archivan en expediente digital

**4. No Programa la Visita**
- Este módulo solo IMPRIME la solicitud
- La programación de fecha/hora se hace en otro módulo
- Este es el documento oficial que formaliza la solicitud

**5. Cruces de Calles**
- Query QryCruceCalles obtiene calles de cruce
- Ayuda a inspectores a localizar el domicilio
- Muy útil en zonas complejas

**6. Observaciones Importantes**
- Campo observaciones del trámite se imprime
- Puede contener indicaciones especiales para la inspección
- Ejemplo: "Solicita inspección urgente", "Caso especial", etc.

**7. Subreportes**
- Los formatos incluyen subreportes (ppSubReport...)
- Para mostrar información adicional por secciones
- Optimiza el formato y legibilidad

### Restricciones
- No modifica datos del trámite
- No programa fechas de inspección (solo imprime solicitud)
- No valida si ya existe inspección programada
- No envía electrónicamente (solo imprime)

### Permisos Necesarios
- Usuario válido del sistema
- Permiso de consulta de trámites
- Acceso a impresora
- No requiere permisos especiales (solo consulta)

### Uso Recomendado

**Flujo Ideal:**
1. Personal de trámites recibe solicitud
2. Captura el trámite en el sistema
3. Usa este módulo para imprimir solicitudes de inspección
4. Envía documentos a dependencias correspondientes
5. Dependencias programan fecha de inspección (otro módulo)
6. Inspectores llevan documento a campo
7. Regresan documento con observaciones
8. Se captura resultado de inspección (otro módulo)

**Mejores Prácticas:**
- Imprimir solicitudes justo después de capturar trámite
- Revisar que se impriman TODAS las dependencias requeridas
- Verificar datos en pantalla antes de imprimir
- Mantener actualizada tabla Dep_giroVerif
- Archivar copias en expediente físico y digital

**Coordinación con Dependencias:**
- Definir claramente formatos de cada dependencia
- Capacitar inspectores en llenado de formatos
- Establecer tiempos de respuesta comprometidos
- Seguimiento de solicitudes enviadas vs recibidas
