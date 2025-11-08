# Reporte de Anuncios a Excel

## Descripción General

### ¿Qué hace este módulo?
Genera **reportes especializados de anuncios publicitarios** con múltiples criterios de filtrado y permite exportar la información a Excel. Es similar al módulo de LicenciasVigentes pero enfocado específicamente en anuncios.

### ¿Para qué sirve en el proceso administrativo?
- Generar reportes personalizados de anuncios publicitarios
- Analizar padrón de anuncios vigentes y dados de baja
- Identificar anuncios con adeudos fiscales
- Exportar información para análisis externos
- Generar estadísticas de anuncios por zona, tipo, propietario
- Identificar anuncios para programas de regularización
- Analizar comportamiento de pago de anuncios

### ¿Quiénes lo utilizan?
- **Dirección de Ingresos**: Para análisis de recaudación de anuncios
- **Departamento de Imagen Urbana**: Para control de publicidad exterior
- **Supervisores**: Para estadísticas y seguimiento
- **Auditoría**: Para verificar padrón de anuncios
- **Cobranza**: Para seguimiento de cartera vencida de anuncios

## Proceso Administrativo

### Configuración de Filtros

**1. Filtro de Vigencia (rgVigencia)**
- **Todas**: Sin filtro de vigencia
- **Vigentes**: Solo anuncios activos (vigente='V')
- **Dadas de Baja**: Cancelados (vigente in 'C','B')
- **Suspendidos**: Anuncios suspendidos (vigente='A')

**2. Filtro de Tipo de Reporte (rgTipoRep)**
- **Hasta fecha**: Anuncios autorizados/dados de baja hasta una fecha específica
- **Rango de fechas**: Anuncios en un período determinado

**3. Filtro de Adeudos (rgAdeudo)** - Similar a licencias
- **Todas**: Sin filtro de adeudos
- **Sin adeudo**: Anuncios al corriente
- **Con adeudo desde año**: Adeudos desde un año específico hasta actual
- **Pagado por año desde**: Anuncios que SÍ pagaron desde un año
- **Sin pago en el año**: Anuncios morosos desde año X
- **Con adeudo al año**: Adeudo acumulado hasta un año específico
- **Fecha de pago**: Anuncios que pagaron en un rango de fechas

**4. Filtros Adicionales**
- **Año inicial**: Para filtros de adeudo (edtaxoini)
- **Rango de fechas de pago**: Para filtro de pagos en período
- **Grupo de anuncios**: Filtro por agrupación predefinida (DBLookupComboBoxGpAnunVigencia)

### Información que Muestra

**Datos del Anuncio:**
- Número de anuncio
- Fecha de otorgamiento
- Propietario completo (con apellidos)
- Licencia asociada
- Empresa
- Tipo de anuncio (descripción del giro)
- Medidas (medidas1 x medidas2)
- Área del anuncio
- Número de caras
- Ubicación completa (calle, número exterior, letra, interior, colonia, CP)
- Zona y subzona
- Estatus (vigente/baja)
- Tipo de bloqueo (si aplica)
- Fecha de baja y folio de baja (si aplica)
- Especificaciones

**Según Filtro de Adeudo:**
- Monto de adeudo
- Año desde/hasta de adeudo
- Fecha y monto de pago
- Etc.

### Proceso de Generación

**1. Configurar Filtros**
- Usuario selecciona vigencia
- Selecciona tipo de reporte y fechas
- Selecciona filtro de adeudo
- Configura filtros opcionales

**2. Generar Reporte**
- Click en BitBtn1 "Generar"
- Sistema construye query SQL dinámico según filtros
- Ejecuta consulta
- Muestra resultados en JvDBGrid1

**3. Exportar a Excel**
- Click en BitBtn2 "Exportar"
- Sistema solicita nombre y ubicación del archivo
- Exporta grid completo a formato HTML
- Muestra progreso de exportación
- Opción de enviar por email

## Tablas de Base de Datos

### Tabla Principal
**anuncios** (Vista dinámica mediante Query)

### Tablas Relacionadas que Consulta

**1. anuncios** - Tabla base de anuncios publicitarios
- Todos los datos del anuncio:
  - anuncio, id_anuncio, id_giro, id_licencia
  - fecha_otorgamiento, fecha_baja, axo_baja, folio_baja
  - medidas1, medidas2, area_anuncio, num_caras
  - ubicacion (calle), numext_ubic, letraext_ubic, numint_ubic, letraint_ubic, colonia_ubic, CP
  - zona, subzona
  - vigente, bloqueado, espubic

**2. licencias** - Información de la licencia asociada
- LEFT JOIN: ON l.id_licencia=a.id_licencia
- Campos: licencia, empresa, propietario (nombre), primer_ap, segundo_ap

**3. c_giros** - Catálogo de tipos de anuncios
- INNER JOIN: ON c.id_giro=a.id_giro
- Campos: descripcion (tipo de anuncio)

**4. detsal_lic** - Detalle de saldos de anuncios
- JOIN condicional según rgAdeudo
- Campos: id_anuncio, id_licencia, axo, saldo, cvepago

**5. pagos** - Pagos realizados
- Usado para filtros de pago en período
- Filtros: cvecanc is null, cveconcepto=8

**6. GruposAnun** (anuncios_grupos)
- Grupos de anuncios para filtro opcional
- JOIN vía subquery: anuncio IN (SELECT anuncio FROM anuncios_detgrupo WHERE anuncios_grupos_id=X)

### Tablas que Modifica
**NINGUNA** - Módulo de solo consulta. No modifica datos.

## Stored Procedures
No utiliza stored procedures. Lógica mediante queries SQL dinámicas.

## Impacto y Repercusiones

### ¿Qué registros afecta?
**NINGUNO** - Solo consulta información

### ¿Qué cambios de estado provoca?
**NINGUNO** - Es solo de consulta y reporte

### ¿Qué documentos genera?

**1. Archivo Excel/HTML**
- Nombre: Definido por usuario (default: "Reporte_Anuncios")
- Formato: HTML (visualizable en Excel)
- Contenido dinámico según filtros
- Columnas variables según filtro de adeudo

**2. Datos en Pantalla**
- Grid interactivo con resultados
- Permite validar antes de exportar
- Ordenamiento y búsqueda

**3. Memo de SQL**
- Para depuración y auditoría
- Muestra la consulta ejecutada

### ¿Qué validaciones aplica?

**Validaciones de Filtros:**
1. Valida que se seleccione tipo de reporte
2. Valida que se seleccione filtro de adeudo
3. Para filtros con año: valida captura de edtaxoini
4. Para rango de fechas: valida coherencia

**Validaciones de Datos:**
1. Formato de fechas válido
2. Año inicial válido
3. Rangos de fechas lógicos

## Flujo de Trabajo

### Flujo Principal: Generación de Reporte

```
1. INICIO - Usuario abre módulo
2. Sistema inicializa:
   - fechaCons.DateTime = Date
   - edtaxoini.Value = Año actual
   - fechaPagoIni, fechaPagofin = Date
   - Abre GruposAnun
3. Usuario configura filtros:
   - rgVigencia (0-3)
   - rgTipoRep (0-1) con fechas
   - rgAdeudo (0-6) con año si aplica
   - Opcional: Grupo de anuncios
4. Click en BitBtn1 "Generar"
5. Sistema construye SQL dinámico:
   5.1. Base SELECT:
        "SELECT a.anuncio, a.fecha_otorgamiento,
         TRIM(TRIM(NVL(l.primer_ap,''))||' '||...) as propietario,
         l.licencia, l.empresa, c.descripcion as tipo_anuncio,
         a.medidas1, a.medidas2, a.area_anuncio, num_caras,
         a.ubicacion, a.numext_ubic, ..., a.vigente, a.bloqueado,
         a.fecha_baja, a.folio_baja, a.espubic"
   5.2. Columnas adicionales según rgAdeudo
   5.3. FROM: "FROM anuncios a
        LEFT JOIN licencias l ON l.id_licencia=a.id_licencia
        INNER JOIN c_giros c ON c.id_giro=a.id_giro"
   5.4. JOIN adicionales según rgAdeudo
   5.5. WHERE: "WHERE a.anuncio > 0"
   5.6. Aplica filtros de vigencia, fecha, grupo
   5.7. GROUP BY según rgAdeudo
   5.8. Agrega SQL a Memo1
6. Ejecuta query y muestra en grid
7. FIN
```

### Flujo de Exportación

```
1. Usuario ha generado reporte
2. Click en BitBtn2 "Exportar"
3. SaveDialog1 solicita ubicación
   - Default: 'Reporte_Anuncios'
4. ¿Usuario confirma?
   NO → Mensaje error, termina
   SÍ → Continúa
5. Configura exportación:
   - JvDBGridHTMLExport1.FileName = archivo seleccionado
   - JvDBGridHTMLExport1.OnProgress = DoExportProgress
   - JvProgressDialog1.Show
6. Ejecuta exportación:
   - IF NOT JvDBGridHTMLExport1.ExportGrid THEN
     * Error, termina
7. Durante exportación:
   - JvProgressDialog1 muestra progreso %
8. Al terminar:
   - JvProgressDialog1.Hide
   - Archivo creado
9. Opcional: SendMailModulo1.enviar (si configurado)
10. FIN
```

## Notas Importantes

### Consideraciones Especiales

**1. Diferencias con Reporte de Licencias**
- Enfocado en anuncios publicitarios, no establecimientos
- Muestra medidas físicas del anuncio (importante para regulación)
- Liga con licencia pero puede existir sin licencia (anuncios sin establecimiento)
- Filtros similares pero adaptados a anuncios

**2. Anuncios sin Licencia**
- LEFT JOIN con licencias (puede ser NULL)
- Algunos anuncios pueden no tener licencia asociada
- Importante para identificar anuncios irregulares

**3. Medidas y Área**
- medidas1, medidas2: Dimensiones del anuncio
- area_anuncio: Metros cuadrados
- num_caras: Importante para cálculo de impuesto
- Datos críticos para regulación urbana

**4. Grupos de Anuncios**
- Permite agrupar anuncios por criterios administrativos
- Similar a grupos de licencias
- Útil para operaciones sobre conjuntos específicos

**5. Adeudos de Anuncios**
- Proceso similar a licencias
- Consulta detsal_lic pero filtra por id_anuncio
- Importante: Un anuncio puede tener adeudo independiente de su licencia

**6. Exportación HTML**
- Formato HTML compatible con Excel
- Preserva formato mejor que CSV
- Permite filtros y ordenamiento en Excel

### Restricciones
- Solo consulta, no modifica datos
- No permite bajas masivas (a diferencia de LicenciasVigentes)
- No permite exportar sin datos en grid

### Permisos Necesarios
- Usuario válido del sistema
- Permiso de lectura en tablas de anuncios y licencias
- Para exportar: permiso de exportación
- Acceso al sistema de archivos

### Uso Recomendado
- Generación periódica para seguimiento de anuncios
- Control de publicidad exterior
- Identificación de anuncios morosos
- Campañas de regularización de imagen urbana
- Estadísticas de recaudación por concepto de anuncios
- Verificación de cumplimiento de medidas autorizadas

**Casos de Uso Típicos:**
- "Anuncios vigentes sin adeudo en Zona Centro"
- "Anuncios con adeudo desde 2023"
- "Anuncios dados de baja en último trimestre"
- "Anuncios que pagaron en diciembre"
- "Grupo: Anuncios pendientes renovación"
