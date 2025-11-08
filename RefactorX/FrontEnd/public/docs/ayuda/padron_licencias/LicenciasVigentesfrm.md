# Reporte de Licencias Vigentes y Control de Bajas Masivas

## Descripción General

### ¿Qué hace este módulo?
Este módulo es una herramienta administrativa avanzada para generar **reportes especializados de licencias** con múltiples criterios de filtrado y realizar **bajas masivas** de licencias que no cumplan con sus obligaciones fiscales. Permite exportar información a Excel y realizar análisis detallados del padrón de contribuyentes.

### ¿Para qué sirve en el proceso administrativo?
Sirve para:
- Generar reportes personalizados de licencias con múltiples filtros
- Analizar el padrón de licencias vigentes, de baja y suspendidas
- Identificar licencias con adeudos fiscales
- Realizar bajas masivas de licencias morosas
- Exportar información a Excel para análisis externos
- Generar estadísticas e indicadores de recaudación
- Identificar licencias para programas de regularización
- Analizar comportamiento de pago por año, giro, zona

### ¿Quiénes lo utilizan?
- **Dirección de Ingresos**: Para análisis de recaudación y adeudos
- **Departamento Jurídico**: Para identificar licencias sujetas a baja o sanción
- **Supervisores**: Para tomar decisiones sobre bajas masivas
- **Auditoría Interna**: Para verificar padrón y cumplimiento fiscal
- **Planeación**: Para estadísticas y proyecciones
- **Cobranza**: Para seguimiento de cartera vencida

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?

**1. Configuración de Filtros de Vigencia**
   - RadioGroup rgVigencia con opciones:
     - **Todas**: Sin filtro de vigencia
     - **Vigentes**: Solo licencias activas (vigente='V')
     - **Dadas de Baja**: Canceladas o bajas (vigente in 'C','B')
     - **Suspendidas**: Licencias suspendidas temporalmente (vigente='A')

**2. Configuración de Clasificación de Giro**
   - RadioGroup rgClasificacion:
     - **Todas**: Sin filtrar por clasificación
     - **Clase A**: Giros de impacto bajo
     - **Clase B**: Giros de impacto medio
     - **Clase C**: Giros de impacto alto
     - **Clase D**: Giros reglamentados (especiales)

**3. Configuración de Tipo de Reporte**
   - RadioGroup rgTipoRep:
     - **Hasta fecha**: Licencias otorgadas/dadas de baja hasta una fecha específica
     - **Rango de fechas**: Licencias en un período determinado

**4. Configuración de Adeudos (rgAdeudo)** - Muy importante
   - **Todas**: Sin filtro de adeudos
   - **Sin adeudo**: Licencias al corriente (saldo=0)
   - **Con adeudo desde año**: Licencias con adeudo específico desde un año inicial hasta actual
   - **Pagado por año desde**: Licencias que SÍ pagaron desde un año en adelante
   - **Sin pago en el año**: Licencias candidatas a baja (no pagaron desde año X)
   - **Con adeudo al año**: Adeudo acumulado hasta un año específico (no incluye años posteriores)
   - **Fecha de pago**: Licencias que pagaron en un rango de fechas específico

**5. Filtros Adicionales**
   - **Año inicial**: Para filtros de adeudo (edtaxoini)
   - **Rango de fechas de pago**: Para filtro de pagos en período
   - **Actividad comercial**: Filtro por patrón de texto (matches)
   - **Grupo de licencias**: Filtro por agrupación predefinida
   - **Tipo de bloqueo**: Filtrar por tipo específico de bloqueo
   - **Zona/Subzona**: Filtros geográficos

**6. Generación del Reporte**
   - Click en BitBtn1 "Generar"
   - Sistema construye consulta SQL dinámica según filtros
   - Ejecuta query y muestra resultados en JvDBGrid1
   - Información mostrada incluye:
     - Número de licencia
     - Tipo de giro
     - Actividad comercial
     - Fecha de otorgamiento
     - Propietario completo (con apellidos)
     - RFC
     - Ubicación completa del negocio
     - Número de empleados
     - Inversión, zona, subzona
     - Teléfono, email
     - Estatus y tipo de bloqueo
     - Según filtro de adeudo: montos, años, desde/hasta, notificaciones, multas
     - Cuenta anuncios asociados

**7. Exportación a Excel**
   - Click en BitBtn2 "Exportar"
   - Sistema solicita nombre y ubicación del archivo
   - Exporta grid completo a formato HTML (visualizable en Excel)
   - Muestra progreso de exportación
   - Opción de enviar por email

**8. Proceso de Baja Masiva** (Función crítica)
   - Solo disponible cuando rgAdeudo = "Sin pago en el año"
   - Click en b_baja "Activar Baja"
   - Primera activación: Habilita controles de captura
   - Usuario debe capturar:
     - **Año de baja** (FloatEdit2)
     - **Folio de baja** (FloatEdit3)
     - **Motivo de baja** (Edit1)
   - Click nuevamente en b_baja (ahora dice "Aplicar Baja")
   - Sistema solicita confirmación:
     "A continuación se darán de baja las licencias junto con sus anuncios ligados, ¿desea continuar?"
   - Si confirma, ejecuta proceso de baja masiva

**Proceso de Baja Masiva Detallado:**
```
Para cada licencia en el grid:
1. Verifica que esté vigente (V) o suspendida (A) y no sea conveniada (bloqueado<>6)
2. Cancela el adeudo de la licencia:
   - Marca todos los saldos con cvepago=999999
3. Da de baja anuncios asociados:
   - Para cada anuncio de la licencia:
     - Cancela adeudos (cvepago=999999)
     - Cambia vigente='C'
     - Registra fecha_baja, axo_baja, folio_baja
     - Guarda motivo en espubic
4. Da de baja la licencia:
   - vigente='C'
   - fecha_baja=fecha actual
   - axo_baja, folio_baja (capturados)
   - espubic=motivo
5. Continúa con siguiente licencia
```

### ¿Qué información requiere el usuario?

**Para Generación de Reportes:**
- Selección de vigencia (obligatorio)
- Selección de clasificación de giro (opcional)
- Tipo de reporte temporal (obligatorio)
- Filtro de adeudos (obligatorio)
- Fechas según tipo de reporte
- Año inicial para filtros de adeudo
- Filtros opcionales: actividad, grupo, bloqueo, zona

**Para Baja Masiva:**
- **Año de baja** (formato YYYY, obligatorio)
- **Folio de baja** (número consecutivo, obligatorio)
- **Motivo de baja** (texto descriptivo, obligatorio)
- **Confirmación explícita** del usuario

**Datos que genera automáticamente:**
- Fecha de baja (fecha actual del sistema)
- Usuario que realiza la baja (del login)
- Folio de cancelación de adeudos (999999)

### ¿Qué validaciones se realizan?

**Validaciones para Reportes:**
1. Valida que se seleccione un tipo de reporte
2. Valida que se seleccione un filtro de adeudo
3. Para filtros de adeudo con año: valida que se capture edtaxoini
4. Para rango de fechas: valida que fecha inicial <= fecha final
5. Valida formato de fechas

**Validaciones para Baja Masiva:**
1. **Validación de Filtro**: Solo permite bajas cuando rgAdeudo=4 (Sin pago en el año)
   - Mensaje: "Esta Opcion de filtro de adeudo no puede utilizarse para dar de baja"
2. **Validación de Datos Completos**:
   - Verifica que FloatEdit2 (año) no esté vacío
   - Verifica que FloatEdit3 (folio) no esté vacío
   - Verifica que Edit1 (motivo) no esté vacío
   - Mensaje: "Debes indicar año, folio y Motivo de Baja"
3. **Confirmación Explícita**: Solicita confirmación antes de proceder
4. **Validación de Estado de Licencia**:
   - Solo procesa licencias vigentes (V) o suspendidas (A)
   - No procesa licencias conveniadas (bloqueado=6)
   - No procesa licencias ya dadas de baja
5. **Validación de Tablas Activas**: Verifica que las tablas necesarias estén abiertas

**Validaciones de Negocio:**
1. **Integridad Referencial**: Cancela adeudos antes de dar de baja
2. **Bajas en Cascada**: Da de baja anuncios asociados automáticamente
3. **Preservación de Histórico**: No elimina registros, solo cambia estatus
4. **Trazabilidad**: Registra motivo, fecha, folio en todos los registros afectados

### ¿Qué documentos genera?

Este módulo NO genera documentos impresos directamente, pero sí produce:

**1. Archivo Excel/HTML**
- Nombre personalizable por el usuario
- Formato HTML (abre en Excel)
- Contiene todas las columnas del grid con datos del reporte
- Incluye todos los registros filtrados
- Útil para:
  - Análisis en herramientas externas
  - Compartir con otras áreas
  - Presentaciones y reportes ejecutivos
  - Respaldos de información

**2. Resultados en Pantalla (Grid)**
- Grid interactivo con todas las licencias filtradas
- Columnas dinámicas según filtro de adeudo
- Información completa de cada licencia
- Contador de registros
- Ordenamiento y búsqueda

**3. Log de Operaciones** (implícito en registros)
- Cada baja masiva queda registrada en:
  - Tabla licencias (cambio de vigente, fecha_baja, folio_baja, motivo)
  - Tabla anuncios (cambio de vigente, fecha_baja, folio_baja, motivo)
  - Tabla detsal_lic (cvepago=999999 para cancelar adeudos)

## Tablas de Base de Datos

### Tabla Principal
**licencias** (Vista dinámica mediante Query)
- No es una tabla directa, es el resultado del query "licencias"
- Contiene información combinada de múltiples tablas
- Campos incluidos dependen del filtro de adeudo seleccionado

### Tablas Relacionadas que Consulta

**1. licencias** (Tabla base)
- Tabla maestra de licencias de funcionamiento
- Campos consultados:
  - Licencia, id_licencia, id_giro, empresa, recaud
  - tipo_registro, actividad, cvecuenta
  - fecha_otorgamiento, fecha_baja, axo_baja, folio_baja
  - propietario (nombre), primer_ap, segundo_ap, RFC, CURP, email
  - domicilio (del propietario), numext_prop, numint_prop, colonia_prop, telefono_prop
  - ubicacion (del negocio), numext_ubic, letraext_ubic, numint_ubic, letraint_ubic, colonia_ubic, CP
  - sup_construida, sup_autorizada, num_cajones, num_empleados, aforo
  - inversion, zona, subzona, rhorario
  - vigente, bloqueado, espubic
  - x, y (coordenadas geográficas)

**2. c_giros**
- Catálogo de giros comerciales
- JOIN obligatorio: ON c.id_giro=l.id_giro
- Campos: clasificacion (A,B,C,D), descripcion, cod_giro (SCIAN)
- Filtro de clasificación se aplica aquí

**3. detsal_lic**
- Detalle de saldos de licencias (por año, concepto)
- JOIN condicional según rgAdeudo
- Campos: id_licencia, id_anuncio, axo, saldo, total, cvepago
- Crucial para cálculos de adeudos
- **Función especial**: spget_lic_deudoxayo y spget_lic_recgosxayo para adeudos calculados

**4. saldos_lic**
- Resumen de saldos por licencia
- Usado para filtro "Sin adeudo" (total=0)
- JOIN: ON d.id_licencia=l.id_licencia

**5. pagos**
- Tabla de pagos realizados
- Usado para filtros de pago en período
- Campos: cvepago, fecha, importe, cvecanc, cveconcepto, cvecuenta
- Filtra: cvecanc is null (no cancelados), cveconcepto=8 (licencias)

**6. convcta**
- Conversión de cuentas (tabla de equivalencias)
- JOIN: LEFT JOIN ON v.cvecuenta=l.cvecuenta
- Campos: recaud, urbrus, cuenta, cvecatnva (clave catastral nueva)

**7. c_tipobloqueo**
- Catálogo de tipos de bloqueo
- JOIN: LEFT JOIN ON t.id=l.bloqueado
- Campos: id, descripcion

**8. anuncios** (para cálculo en bajas)
- Tabla de anuncios publicitarios
- Usado en bajas masivas para dar de baja anuncios asociados
- Filtro: id_licencia, vigente='V'

**9. saldosAnun** (Query para bajas)
- Query de saldos de anuncios
- Usado en proceso de baja para cancelar adeudos de anuncios

**10. GruposLic**
- Tabla de grupos de licencias (agrupaciones administrativas)
- Usado para filtro opcional por grupo
- JOIN a través de subquery: licencia IN (SELECT licencia FROM lic_detgrupo WHERE lic_grupos_id=X)

### Tablas que Modifica

**EN PROCESO DE BAJA MASIVA:**

**1. licencias** (UPDATE masivo)
- **Actualiza para cada licencia procesada**:
  - vigente = 'C' (Cancelada)
  - fecha_baja = fecha actual del sistema
  - axo_baja = año capturado por usuario
  - folio_baja = folio capturado por usuario
  - espubic = motivo de baja capturado

**2. anuncios** (UPDATE múltiple en cascada)
- **Para CADA anuncio asociado a cada licencia**:
  - vigente = 'C'
  - fecha_baja = fecha actual
  - axo_baja = año capturado
  - folio_baja = folio capturado
  - espubic = motivo de baja

**3. detsal_lic** (UPDATE masivo de cancelación de adeudos)
- **Para cada registro de saldo de licencias**:
  - WHERE id_licencia = licencia procesada
  - SET cvepago = 999999
  - Efecto: Cancela el adeudo (marca como "condonado administrativamente")
- **Para cada registro de saldo de anuncios**:
  - WHERE id_anuncio = anuncio procesado
  - SET cvepago = 999999

**IMPORTANTE**: En modo de solo consulta (sin baja masiva), este módulo **NO modifica ninguna tabla**. Solo consulta y muestra información.

## Stored Procedures

**1. spget_lic_deudoxayo**
- **Parámetros**: (id_licencia, año_inicial, año_final, tipo='L')
- **Función**: Calcula el adeudo de una licencia desde un año inicial hasta un año final
- **Uso**: En filtro rgAdeudo=2 (Con adeudo desde año)
- **Retorna**: Monto total adeudado en el rango de años
- **Lógica**: Suma saldos de detsal_lic donde cvepago=0 y axo entre años especificados

**2. spget_lic_recgosxayo**
- **Parámetros**: (id_licencia, año_inicial, año_final, tipo='L')
- **Función**: Calcula recargos acumulados desde un año inicial hasta un año final
- **Uso**: En filtro rgAdeudo=2 (muestra columna adicional de recargos)
- **Retorna**: Monto total de recargos en el rango
- **Lógica**: Calcula recargos moratorios sobre saldos vencidos

**Nota**: Estos SP son funciones de MySQL que retornan valores numéricos y se usan directamente en el SELECT del query dinámico.

## Impacto y Repercusiones

### ¿Qué registros afecta?

**EN MODO CONSULTA** (default):
- **NO afecta ningún registro**
- Solo consulta información
- No modifica bases de datos

**EN MODO BAJA MASIVA**:

**1. Licencias Procesadas**
- Todas las licencias mostradas en el grid (después de aplicar filtros)
- Solo las que estén vigentes (V) o suspendidas (A)
- Excluye conveniadas (bloqueado=6)

**2. Anuncios en Cascada**
- Todos los anuncios asociados a cada licencia procesada
- Se identifican por: id_licencia de la licencia
- Filtro: vigente='V' (solo los vigentes)

**3. Saldos de Licencias**
- Todos los registros de detsal_lic de cada licencia
- Sin importar año o concepto
- Marca cvepago=999999 (cancelación administrativa)

**4. Saldos de Anuncios**
- Todos los registros de saldos de cada anuncio asociado
- Marca cvepago=999999

### ¿Qué cambios de estado provoca?

**BAJAS MASIVAS (Cambios Permanentes):**

**1. En Licencias:**
- **Estado Anterior**: vigente = 'V' (Vigente) o 'A' (Suspendida)
- **Estado Posterior**: vigente = 'C' (Cancelada/Baja definitiva)
- **Información de Baja**: Registra fecha_baja, axo_baja, folio_baja, motivo
- **Irreversible**: Una vez dada de baja, no se puede reactivar (requiere nuevo trámite)

**2. En Anuncios Asociados:**
- **Estado Anterior**: vigente = 'V'
- **Estado Posterior**: vigente = 'C'
- **Baja en Cascada**: Automática al dar de baja la licencia
- **Información de Baja**: Mismos datos que la licencia (fecha, folio, motivo)

**3. En Adeudos (detsal_lic):**
- **Estado Anterior**: cvepago = 0 (adeudo pendiente) o cvepago > 0 (pagado)
- **Estado Posterior**: cvepago = 999999 (cancelado administrativamente)
- **Efecto**: El adeudo ya no aparece en reportes de cartera vencida
- **Contabilidad**: Se debe registrar como "cancelación de adeudo por baja"

**4. Estados Fiscales:**
- La licencia pasa de **contribuyente activo** a **inactivo**
- Ya no genera obligaciones fiscales futuras
- Los adeudos históricos quedan cancelados
- El domicilio queda libre para nueva licencia

**EXPORTACIONES:**
- No provocan cambios de estado
- Solo generan archivos de salida

### ¿Qué documentos/reportes genera?

**1. Archivo Excel/HTML con Reporte Personalizado**
- Nombre: Definido por usuario (default: "Reporte_licencias")
- Formato: HTML (visualizable en Excel, LibreOffice, etc.)
- Contenido dinámico según filtros aplicados
- Columnas variables según filtro de adeudo
- **Casos de uso**:
  - Reportes ejecutivos de cartera vencida
  - Análisis de morosidad por giro o zona
  - Listados para cobranza o notificación
  - Estadísticas de recaudación
  - Respaldos para auditoría

**2. Datos en Pantalla (Grid Interactivo)**
- Vista previa del reporte
- Permite validar datos antes de exportar
- Ordenamiento y búsqueda interactiva
- Contador de registros

**3. Memo de SQL Generado**
- Para depuración y auditoría
- Muestra la consulta SQL completa ejecutada
- Útil para replicar reportes o análisis

**4. Confirmación de Bajas (implícito)**
- Mensaje final: "Bajas realizadas"
- Log en base de datos (registros modificados)
- Histórico de cambios en tablas

### ¿Qué validaciones de negocio aplica?

**VALIDACIONES CRÍTICAS PARA BAJAS MASIVAS:**

**1. Validación de Filtro Específico**
- **Regla**: Solo permite bajas cuando rgAdeudo.itemindex = 4
- **Razón**: Garantiza que solo se den de baja licencias sin pago en un año específico
- **Control**: Evita bajas masivas accidentales de licencias al corriente

**2. Validación de Datos Completos**
- **Año de baja**: Obligatorio, formato numérico
- **Folio de baja**: Obligatorio, formato numérico
- **Motivo**: Obligatorio, texto descriptivo
- **Mensaje**: "Debes indicar año, folio y Motivo de Baja"

**3. Confirmación Explícita del Usuario**
- **Mensaje**: "A continuación se darán de baja las licencias junto con sus anuncios ligados, ¿desea continuar?"
- **Opciones**: Sí / No
- **Efecto**: Permite cancelar en el último momento

**4. Validación de Estado de Licencia**
- **Regla**: Solo procesa si (vigente='V' OR vigente='A') AND bloqueado<>6
- **Razón**:
  - No da de baja licencias ya canceladas o en baja
  - No afecta licencias conveniadas (tienen acuerdo de pago)
- **Control**: Evita duplicar bajas o afectar acuerdos legales

**5. Validación de Integridad de Datos**
- Verifica que las tablas necesarias estén activas
- Valida que existan registros a procesar
- Controla errores de acceso a base de datos

**VALIDACIONES PARA REPORTES:**

**6. Validación de Fechas**
- Fecha inicial <= fecha final (en rangos)
- Fechas en formato válido
- Año inicial válido (>= 1970, <= año actual)

**7. Validación de Filtros Coherentes**
- Si selecciona filtro con año, exige captura de edtaxoini
- Si selecciona filtro de pago en período, exige fechas de pago

**8. Validación de Grupos**
- Si selecciona grupo de licencias, valida que exista en la BD
- Filtra por subquery a tabla lic_detgrupo

**9. Validación de SQL Dinámico**
- Construye SQL válido según combinación de filtros
- Incluye GROUP BY adecuado según columnas seleccionadas
- Previene errores de sintaxis SQL

## Flujo de Trabajo

### Flujo Principal: Generación de Reporte

```
1. INICIO - Usuario abre módulo
   ↓
2. Sistema inicializa:
   - fechaCons.DateTime = Date
   - edtaxoini.Value = Año actual
   - fechaPagoIni, fechaPagofin = Date
   - Abre GruposLic
   ↓
3. Usuario configura filtros:
   3.1. Selecciona VIGENCIA (rgVigencia):
        0=Todas, 1=Vigentes, 2=Baja, 3=Suspendidas
   3.2. Selecciona CLASIFICACIÓN (rgClasificacion):
        0=Todas, 1=Clase A, 2=Clase B, 3=Clase C, 4=Clase D
   3.3. Selecciona TIPO REPORTE (rgTipoRep):
        0=Hasta fecha, 1=Rango de fechas
        - Si 0: Captura fechaCons
        - Si 1: Captura fechaIni y fechaFin
   3.4. Selecciona ADEUDO (rgAdeudo):
        0=Todas
        1=Sin adeudo
        2=Con adeudo desde año
        3=Pagado por año desde
        4=Sin pago en el año (para bajas)
        5=Con adeudo al año
        6=Fecha de pago
        - Si 2,3,4,5: Captura edtaxoini
        - Si 6: Captura fechaPagoIni y fechaPagofin
   3.5. Filtros opcionales:
        - chkboxFiltroAct + edtFiltro (actividad)
        - DBLookupComboBoxGpLicVigencia (grupo)
        - ComboBoxBloq (tipo de bloqueo)
        - EditZona, EditSubzona (geografía)
        - EditTipotramite (tipo)
   ↓
4. Click en BitBtn1 "Generar"
   ↓
5. Sistema construye SQL dinámico:
   5.1. Base SELECT:
        "SELECT Licencia, clasificacion, actividad, fecha_otorgamiento,
         id_giro, descripcion giro, num_empleados, primer_ap, segundo_ap,
         propietario, rfc, ubicacion, numext_ubic, ..., vigente, bloqueado..."
   5.2. Columnas adicionales según rgAdeudo:
        - Si 1: ", sum(d.total) as Adeudo"
        - Si 2: ", spget_lic_deudoxayo(...) as Adeudo_Desde_[año],
                  spget_lic_recgosxayo(...) as Recargos_Desde_[año]"
        - Si 3: ", d.axo, sum(p.importe) as pago"
        - Si 4,5: ", sum(d.saldo) as Adeudo, min(d.axo) as desde,
                    max(d.axo) as hasta, count(anuncios), notificaciones, multas"
        - Si 6: ", p.fecha as fecha_pago, p.importe"
   5.3. FROM: "FROM licencias l INNER JOIN c_giros c ON c.id_giro=l.id_giro"
   5.4. Aplica filtro de clasificación en JOIN de giros
   5.5. JOIN adicionales según rgAdeudo:
        - Si 1: INNER JOIN saldos_lic (total=0)
        - Si 2,3,4,5: INNER JOIN detsal_lic con condiciones específicas
        - Si 6: INNER JOIN pagos + detsal_lic
   5.6. LEFT JOIN convcta, c_tipobloqueo
   5.7. WHERE:
        - "WHERE licencia > 0"
        - Aplica filtro de vigencia
        - Aplica filtro de fecha según rgTipoRep
        - Aplica filtro de bloqueo si ComboBoxBloq >= 1
        - Aplica filtro de actividad si chkboxFiltroAct
        - Aplica filtro de grupo si seleccionado
        - Aplica filtros de zona/subzona si capturados
   5.8. GROUP BY según rgAdeudo (agrupa por columnas seleccionadas)
   5.9. Agrega SQL a Memo1 (log)
   ↓
6. Sistema ejecuta query:
   - licencias.close
   - licencias.sql.clear
   - licencias.sql.add(sql construido)
   - licencias.open
   ↓
7. Resultados se muestran en JvDBGrid1
   - Grid se llena con datos
   - Label1 muestra contador de registros
   ↓
8. FIN - Usuario puede:
   - Revisar datos en pantalla
   - Exportar a Excel (BitBtn2)
   - Activar proceso de baja (b_baja, solo si rgAdeudo=4)
```

### Flujo Crítico: Baja Masiva de Licencias

```
PRECONDICIÓN: rgAdeudo.itemindex = 4 (Sin pago en el año)

1. Usuario ha generado reporte con filtro "Sin pago en el año"
   - Grid muestra licencias candidatas a baja
   ↓
2. Click en b_baja "Activar Baja"
   ↓
3. ¿Es primera activación?
   SÍ → b_baja.Caption = 'Activar Baja'
        - Sistema muestra mensaje:
          "Capture año, folio y motivo para dar de baja"
        - Cambia b_baja.Caption a 'Aplicar Baja'
        - Muestra componentes de captura:
          * Label4, FloatEdit2 (año) visible
          * Label6, FloatEdit3 (folio) visible
          * Label7, Edit1 (motivo) visible
        - Termina, espera captura
        ↓
        4. Usuario captura:
           - FloatEdit2: Año de baja (ej: 2025)
           - FloatEdit3: Folio de baja (ej: 12345)
           - Edit1: Motivo (ej: "BAJA POR FALTA DE PAGO 2023-2024")
           ↓
        5. Click nuevamente en b_baja "Aplicar Baja"
           ↓
   NO (segunda vez) → Continúa al paso 6
   ↓
6. Sistema valida datos capturados:
   - ¿FloatEdit2.text vacío O FloatEdit3.text vacío O Edit1.text vacío?
     SÍ → Mensaje: "Debes indicar año, folio y Motivo de Baja"
          exit (termina)
     NO → Continúa
   ↓
7. Sistema solicita confirmación:
   Mensaje: "A continuación se darán de baja las licencias junto con
            sus anuncios ligados, ¿desea continuar?"
   Opciones: Sí / No
   ↓
8. ¿Usuario confirma con Sí?
   NO → exit (cancela proceso, no hace cambios)
   SÍ → Continúa
   ↓
9. Sistema abre tablas necesarias:
   - IF NOT licencia.Active THEN licencia.Open
   - IF NOT saldosLic.Active THEN saldosLic.Open
   - IF NOT anuncios.Active THEN anuncios.Open
   - IF NOT saldosAnun.Active THEN saldosAnun.Open
   ↓
10. Inicia bucle principal: licencias.First
    ↓
    WHILE NOT licencias.Eof DO
    ↓
    11. ¿Licencia cumple condiciones de baja?
        Condiciones:
        - (vigente='V' OR vigente='A') AND
        - (bloqueado <> 6)

        NO → licencias.Next (salta a siguiente)
        SÍ → Continúa con baja de esta licencia
        ↓
        12. PROCESO DE BAJA DE LICENCIA:

            12.1. CANCELAR ADEUDOS DE LICENCIA:
                  - saldosLic.First (posiciona en primer saldo)
                  - WHILE NOT saldosLic.Eof DO:
                    * saldosLic.Edit
                    * saldosLic['cvepago'] = 999999
                    * saldosLic.Post
                    * saldosLic.Next
            ↓
            12.2. DAR DE BAJA ANUNCIOS ASOCIADOS:
                  - ¿anuncios.recordcount <> 0?
                    SÍ → anuncios.First
                         WHILE NOT anuncios.Eof DO:

                         12.2.1. CANCELAR ADEUDOS DEL ANUNCIO:
                                 - WHILE NOT saldosAnun.Eof DO:
                                   * saldosAnun.Edit
                                   * saldosAnun['cvepago'] = 999999
                                   * saldosAnun.Post
                                   * saldosAnun.Next

                         12.2.2. DAR DE BAJA EL ANUNCIO:
                                 - anuncios.Edit
                                 - anuncios['vigente'] = 'C'
                                 - anuncios['fecha_baja'] = Date
                                 - anuncios['axo_baja'] = FloatEdit2.text
                                 - anuncios['folio_baja'] = FloatEdit3.text
                                 - IF Trim(Edit1.text) <> '' THEN
                                   anuncios['espubic'] = Edit1.text
                                 - anuncios.Post
                                 - anuncios.Next (siguiente anuncio)
            ↓
            12.3. DAR DE BAJA LA LICENCIA:
                  - licencia.Edit
                  - licencia['vigente'] = 'C'
                  - licencia['fecha_baja'] = Date
                  - licencia['axo_baja'] = FloatEdit2.text
                  - licencia['folio_baja'] = FloatEdit3.text
                  - IF Trim(Edit1.text) <> '' THEN
                    licencia['espubic'] = Edit1.text
                  - licencia.Post
        ↓
        13. licencias.Next (siguiente licencia del grid)
    ↓
    ENDWHILE (fin del bucle de licencias)
    ↓
14. Sistema cierra tablas:
    - licencia.Close
    - saldosLic.Close
    - anuncios.Close
    - saldosAnun.Close
    ↓
15. Mensaje de confirmación:
    "Bajas realizadas"
    ↓
16. Restaura interfaz:
    - b_baja.Caption = 'Activar Baja'
    - componentesbaja(false) - oculta controles de captura
    ↓
17. FIN - Proceso completado
```

### Flujo de Exportación a Excel

```
1. Usuario ha generado reporte con datos en grid
   ↓
2. Click en BitBtn2 "Exportar"
   ↓
3. Sistema abre SaveDialog1:
   - Nombre default: 'Reporte_licencias'
   - Permite seleccionar ubicación y nombre
   ↓
4. ¿Usuario selecciona archivo y confirma?
   NO → Mensaje: "No se Puede Guardar el archivo"
        exit
   SÍ → Continúa
   ↓
5. Sistema configura exportación:
   - JvDBGridHTMLExport1.FileName = SaveDialog1.FileName
   - JvDBGridHTMLExport1.OnProgress = DoExportProgress
   - JvProgressDialog1.Caption = JvDBGridHTMLExport1.Caption
   - JvProgressDialog1.Show
   ↓
6. Ejecuta exportación:
   - IF NOT JvDBGridHTMLExport1.ExportGrid THEN
     * Mensaje: "No se Puede Exportar"
     * exit
   ↓
7. Durante exportación:
   - JvProgressDialog1 muestra progreso:
     * Min, Max, Position
     * "Exportando (X% Terminado)"
   - Permite cancelar (AContinue := NOT JvProgressDialog1.Cancelled)
   ↓
8. Al terminar:
   - JvProgressDialog1.Hide
   - Archivo HTML creado en ubicación seleccionada
   ↓
9. Opcional: SendMailModulo1.enviar
   - Si está configurado, permite enviar archivo por email
   ↓
10. FIN - Archivo disponible para abrir en Excel
```

## Notas Importantes

### Consideraciones Especiales

**1. Proceso de Baja Masiva - CRÍTICO**
- Es una operación IRREVERSIBLE
- Afecta múltiples licencias simultáneamente
- Modifica licencias Y anuncios asociados en cascada
- Cancela adeudos (cvepago=999999)
- Requiere autorización de nivel superior
- Debe documentarse externamente (oficio, acta)
- **Recomendación**: Exportar reporte a Excel ANTES de aplicar bajas (respaldo)

**2. Folios de Baja**
- El folio capturado debe ser único y consecutivo
- **No está controlado automáticamente** por el sistema
- Es responsabilidad del usuario asignar folios únicos
- Debe existir un registro manual externo de folios asignados
- Usualmente se documenta en libro de oficios o actas

**3. Cancelación de Adeudos con cvepago=999999**
- 999999 es un código especial que significa "cancelado administrativamente"
- NO es un pago real
- Se usa para "limpiar" el adeudo de licencias dadas de baja
- Permite que no aparezcan en reportes de cartera vencida
- Debe registrarse contablemente como "cancelación por baja"

**4. Licencias Conveniadas (bloqueado=6)**
- NO se pueden dar de baja masivamente
- Tienen un acuerdo legal de pago (convenio)
- Deben manejarse caso por caso
- Requieren revisión y autorización especial

**5. Filtros de Adeudo - Funciones Especializadas**
- **spget_lic_deudoxayo**: Stored procedure que calcula adeudo en rango de años
- **spget_lic_recgosxayo**: Calcula recargos moratorios acumulados
- Permiten análisis precisos de morosidad histórica
- Se ejecutan en el SELECT (pueden ser lentos con muchos registros)

**6. Exportación HTML vs CSV**
- El código incluye JvDBGridCSVExport1 (comentado)
- Actualmente usa JvDBGridHTMLExport1
- HTML se visualiza mejor en Excel con formato
- CSV es más ligero y compatible con otras herramientas

**7. Grupos de Licencias**
- Permite agrupar licencias por criterios administrativos
- Ejemplo: "Licencias de regularización 2024"
- Facilita operaciones masivas sobre conjuntos específicos
- Se configuran en módulo GruposLicenciasAbc

### Restricciones

**No se puede:**
- Revertir bajas masivas (operación irreversible)
- Dar de baja licencias conveniadas masivamente
- Exportar sin tener datos en el grid
- Aplicar bajas sin capturar año, folio y motivo
- Usar el módulo sin permisos de escritura (para bajas)

**Se debe:**
- Respaldar información antes de bajas masivas
- Documentar folios de baja externamente
- Validar listado antes de aplicar bajas
- Tener autorización de nivel superior para bajas
- Registrar contablemente las cancelaciones de adeudos

### Permisos Necesarios

**Para Consultas y Reportes:**
- Usuario válido del sistema
- Permiso de lectura en tablas principales
- Acceso al módulo de reportes

**Para Baja Masiva:**
- **Permiso especial de escritura** (operación crítica)
- Generalmente restringido a:
  - Director de Ingresos
  - Jefe de Licencias
  - Personal autorizado específicamente
- Acceso a tablas: licencias, anuncios, detsal_lic (UPDATE)
- **Recomendación**: Implementar log de auditoría para bajas

**Para Exportación:**
- Permiso de exportación de datos
- Puede estar restringido por políticas de seguridad
- Acceso al sistema de archivos para guardar

### Mantenimiento y Soporte

**Problemas Comunes:**

1. **"No se pueden aplicar bajas con este filtro"**
   - Verificar que rgAdeudo.itemindex = 4
   - Solo ese filtro permite bajas masivas
   - Cambiar filtro y regenerar reporte

2. **"Debe indicar año, folio y motivo"**
   - Capturar los tres campos obligatorios
   - Verificar que no estén vacíos
   - Usar formato numérico en año y folio

3. **Query muy lento con stored procedures**
   - Funciones spget_lic_deudoxayo y spget_lic_recgosxayo pueden ser lentas
   - Con muchos registros (>10,000) puede tomar varios minutos
   - Considerar ejecutar en horarios de baja demanda
   - Usar filtros adicionales para reducir conjunto de datos

4. **Exportación falla o se congela**
   - Verificar que haya espacio en disco
   - Grid con muchas columnas y registros puede tardar
   - Probar exportar subconjuntos menores

5. **Anuncios no se dan de baja**
   - Verificar que tabla "anuncios" esté activa
   - Query saldosAnun debe estar configurado correctamente
   - Puede ser problema de permisos en BD

**Respaldos Recomendados:**
- **ANTES de cada baja masiva**: Respaldo completo de tablas licencias, anuncios, detsal_lic
- Exportar reporte a Excel como evidencia
- Documentar folios de baja en registro externo
- Log de auditoría de operaciones de baja

**Monitoreo:**
- Revisar registros con cvepago=999999 mensualmente
- Validar coherencia entre licencias y anuncios dados de baja
- Verificar que folios de baja no se dupliquen
- Auditar motivos de baja para detectar patrones
