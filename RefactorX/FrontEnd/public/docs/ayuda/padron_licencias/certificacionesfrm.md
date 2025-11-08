# Certificaciones de Licencias y Anuncios

## Descripción General

### ¿Qué hace este módulo?
Este módulo permite generar **certificaciones oficiales** que certifican el cumplimiento y al corriente de pago tanto de licencias de funcionamiento como de anuncios publicitarios. Es un documento que acredita que el negocio está legalmente constituido y cumpliendo con sus obligaciones fiscales.

### ¿Para qué sirve en el proceso administrativo?
Sirve para:
- Certificar que una licencia de funcionamiento está vigente y al corriente de pagos
- Certificar que un anuncio publicitario está autorizado y al corriente de pagos
- Generar documentos oficiales para trámites bancarios, notariales o judiciales
- Acreditar cumplimiento legal ante autoridades y terceros
- Proporcionar evidencia del buen estado fiscal del establecimiento

### ¿Quiénes lo utilizan?
- **Personal de ventanilla**: Reciben solicitudes y generan certificaciones
- **Supervisores**: Autorizan y validan los documentos
- **Contribuyentes**: Solicitan certificaciones para trámites diversos
- **Instituciones bancarias**: Requieren certificaciones para otorgar créditos
- **Notarios públicos**: Las solicitan para protocolizar compraventas de negocios

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?

**1. Selección de Tipo de Certificación**
   - Al abrir el módulo, aparece un RadioGroup (RGTipo) con dos opciones:
     - **Licencia** (opción 0): Para certificar licencias de funcionamiento
     - **Anuncio** (opción 1): Para certificar anuncios publicitarios
   - Esta selección determina todo el flujo posterior

**2. Búsqueda del Registro**
   - Usuario captura el número (de licencia o anuncio) en CurrencyEdit1
   - Presiona botón "Buscar" (BitBtn2)
   - Sistema valida existencia en la base de datos:
     - Si es licencia: busca en tabla "licencias"
     - Si es anuncio: busca en tabla "anuncios"
   - Muestra información completa del registro encontrado

**3. Generación de Nueva Certificación**
   - Click en botón "Nueva" (b_nueva)
   - Sistema abre panel de captura (Panel2)
   - Prepara el formulario según el tipo seleccionado:
     - Muestra campos correspondientes (algunos campos solo aplican para licencias)
     - Establece visibilidad de campos específicos
   - Pone la tabla "certificaciones" en modo inserción

**4. Captura de Información Adicional**
   - Usuario completa campos opcionales:
     - **Solicita**: Nombre del solicitante
     - **Observaciones**: Notas adicionales
     - **Partida de Pago**: Referencia contable del pago del servicio

**5. Asignación de Folio Único**
   - Al presionar "Aceptar" (b_aceptar), el sistema:
     - Consulta tabla "parametros" campo "certificacion"
     - Obtiene el siguiente folio consecutivo
     - Incrementa el contador automáticamente (folio + 1)
     - Actualiza la tabla parámetros con el nuevo valor

**6. Grabación del Registro**
   - Sistema inserta registro en tabla "certificaciones":
     - axo: Año actual (formato YYYY)
     - folio: Número consecutivo único
     - id_licencia: ID del registro (licencia o anuncio según tipo)
     - tipo: 'L' para licencia, 'A' para anuncio
     - vigente: 'V' (vigente)
     - capturista: Usuario del sistema
     - feccap: Fecha de captura actual
     - Campos opcionales capturados

**7. Búsqueda de Información de Pagos**
   - Sistema busca el último pago registrado:
     - **Primera búsqueda**: En tabla "pagos" (sistema actual)
       - Filtra por id_licencia o id_anuncio
       - Intenta encontrar pago del año de la certificación
       - Si no, toma el más reciente
     - **Segunda búsqueda**: Si no encuentra en pagos actuales, busca en "pagos400" (legacy)
       - Tabla del sistema anterior
       - Convierte formato de fecha YYYYMMDD a DD/MM/YYYY
       - Convierte monto (divide entre 100, estaba en centavos)
   - Si no encuentra pagos: Marca como "S/C" (sin costo)

**8. Impresión Automática**
   - Una vez grabado el registro, sistema imprime automáticamente:
     - Si es licencia: Genera reporte "ppReport1"
     - Si es anuncio: Genera reporte "ppReport2"
   - Incluye todos los datos de la licencia/anuncio
   - Muestra información del último pago
   - Incluye subreporte de anuncios (solo para licencias)

**9. Restauración de Botones**
   - Sistema habilita: Nueva, Cancelar Cert, Imprimir, Modificar
   - Deshabilita: Aceptar, Cancelar
   - Oculta panel de captura

### ¿Qué información requiere el usuario?

**Para Certificación de Licencia:**
- Número de licencia (campo obligatorio, validado en BD)
- Nombre del solicitante (opcional)
- Observaciones (opcional)
- Partida de pago del servicio (opcional)

**Para Certificación de Anuncio:**
- Número de anuncio (campo obligatorio, validado en BD)
- Nombre del solicitante (opcional)
- Observaciones (opcional)
- Partida de pago del servicio (opcional)

**Datos que captura automáticamente el sistema:**
- Tipo de certificación ('L' o 'A')
- Año actual
- Folio consecutivo único
- Fecha y hora de captura
- Usuario que elabora
- Estatus inicial: 'V' (vigente)
- ID interno de la licencia o anuncio

### ¿Qué validaciones se realizan?

**Validaciones de Existencia:**
1. **Validación de Licencia/Anuncio Existente**
   - Para licencias: Busca en query "BuscaLicencia" por número
   - Para anuncios: Busca en query "BuscaAnuncio" por número
   - Si no existe, no permite continuar con la certificación

2. **Validación de Estatus**
   - Verifica que la licencia/anuncio esté activo
   - Consulta campo "vigente" del registro
   - NO genera certificación para registros dados de baja

**Validaciones de Integridad:**
1. **Unicidad de Folio**: Cada certificación tiene folio único controlado por tabla parámetros
2. **Tipo Obligatorio**: No permite grabar sin seleccionar tipo (L o A)
3. **Certificación Vigente**: Solo permite reimprimir certificaciones con estatus 'V'
4. **Bloqueo de Canceladas**: Verifica que certificación no esté cancelada antes de imprimir

**Validaciones de Datos:**
1. Verifica que id_licencia o id_anuncio corresponda al tipo seleccionado
2. Valida formato de campos de captura
3. Registra usuario automáticamente (no permite manipulación)

### ¿Qué documentos genera?

**1. Certificación de Licencia de Funcionamiento** (ppReport1)
   - Formato oficial con membrete municipal
   - Folio único: AÑO/FOLIO
   - Datos completos del titular:
     - Nombre completo (con apellidos paterno y materno)
     - RFC
     - Domicilio del propietario
   - Información del establecimiento:
     - Número de licencia
     - Giro o actividad comercial
     - Ubicación del negocio (domicilio completo)
     - Características: superficie, número de empleados, cajones de estacionamiento, aforo
     - Horario de operación (si aplica)
   - Información de cumplimiento fiscal:
     - Año del último pago
     - Fecha del último pago (DD de Mes del YYYY)
     - Monto del último pago de derechos
   - **Subreporte de Anuncios Autorizados** (solo para licencias):
     - Lista de todos los anuncios vinculados a la licencia
     - Incluye: número, tipo, medidas, área, ubicación
   - Firmas del funcionario autorizado
   - Sello oficial

**2. Certificación de Anuncio Publicitario** (ppReport2)
   - Formato oficial con membrete municipal
   - Folio único: AÑO/FOLIO
   - Datos del anuncio:
     - Número de anuncio
     - Tipo/descripción del anuncio
     - Medidas (medidas1 x medidas2)
     - Área total del anuncio
     - Número de caras
     - Texto del anuncio
     - Ubicación exacta (calle, número, colonia)
   - Datos del propietario:
     - Nombre completo (con apellidos)
     - RFC
   - Licencia asociada (si existe)
   - Información de pagos:
     - Año del último pago
     - Fecha del último pago
     - Monto pagado
   - Firmas y sello oficial

**3. Listado de Certificaciones** (listado)
   - Reporte administrativo para control interno
   - Permite filtrar por:
     - Año y folio específico
     - Número de licencia o anuncio
     - Rango de fechas de emisión
   - Columnas mostradas:
     - Folio
     - Fecha de emisión
     - Licencia/Anuncio (según tipo)
     - Solicita
     - Observación
     - Estatus (Vigente/Cancelado)
   - Total de registros encontrados
   - Útil para auditorías y estadísticas

## Tablas de Base de Datos

### Tabla Principal
**certificaciones**
- Almacena el registro oficial de todas las certificaciones emitidas
- Campos principales:
  - **axo**: Año de emisión (INTEGER)
  - **folio**: Número consecutivo de la certificación (INTEGER)
  - **id_licencia**: ID de la licencia o anuncio certificado (INTEGER)
  - **licencia**: Campo calculado que muestra el número visible de licencia (INTEGER calculado)
  - **anuncio**: Campo calculado que muestra el número visible de anuncio (INTEGER calculado)
  - **tipo**: Tipo de certificación - 'L'=Licencia, 'A'=Anuncio (STRING)
  - **solicita**: Nombre del solicitante (STRING)
  - **partidapago**: Referencia contable (STRING)
  - **observacion**: Observaciones adicionales (STRING)
  - **vigente**: Estatus - 'V'=Vigente, 'C'=Cancelada (STRING)
  - **feccap**: Fecha de captura (DATE)
  - **capturista**: Usuario que elaboró (STRING)

### Tablas Relacionadas que Consulta

**1. BuscaLicencia** (Query)
- Busca información de licencia por su número
- Valida existencia antes de certificar
- Proporciona id_licencia para vincular con certificación

**2. BuscaAnuncio** (Query)
- Busca información de anuncio por su número
- Valida existencia del anuncio
- Proporciona id_anuncio para vincular

**3. licencias**
- Tabla maestra de licencias de funcionamiento
- Datos consultados:
  - Número de licencia, propietario (nombre, apellidos), RFC, CURP
  - Domicilio del propietario (completo con CP)
  - Ubicación del negocio
  - Características: superficie, empleados, cajones, aforo, inversión
  - Horario de operación
  - id_giro (para obtener descripción)
  - Fecha de otorgamiento
  - Estatus vigente/baja

**4. Anuncio** (Query - para certificaciones de anuncios)
- Tabla de anuncios publicitarios autorizados
- Datos consultados:
  - Número de anuncio, tipo, descripción
  - Medidas (medidas1, medidas2), área total, número de caras
  - Texto del anuncio
  - Ubicación completa
  - Propietario (nombre, apellidos), RFC
  - Licencia asociada
  - id_giro, zona, subzona
  - Fecha de otorgamiento

**5. anuncios** (Table - para subreporte en certificación de licencias)
- Lista de anuncios vinculados a una licencia
- Se usa como subreporte en certificación de licencias
- Muestra todos los anuncios autorizados asociados

**6. c_giros (giros)**
- Catálogo de giros o actividades comerciales
- Obtiene: descripción del giro, clasificación, reglamentación
- Liga por: id_giro

**7. pagos**
- Tabla de pagos del sistema actual
- Busca último pago de derechos
- Campos: fecha, axo, importe/derechos
- Para licencias: cvecuenta = id_licencia, cveconcepto = 8
- Para anuncios: cvecuenta = id_licencia (del anuncio), cveconcepto = 8

**8. pagos400**
- Tabla histórica de pagos (sistema legacy)
- Si no encuentra en "pagos", busca aquí
- Campos legacy:
  - fepa3: Fecha formato YYYYMMDD
  - axopag: Año del pago
  - impe3 o imppag: Monto en centavos (dividir entre 100)

**9. pagosAnun** (Query - específico para anuncios)
- Query especializada para pagos de anuncios
- Busca pagos relacionados al anuncio certificado

**10. pagos400Anun** (Query - legacy de anuncios)
- Query de pagos históricos de anuncios
- Sistema anterior

**11. parametros**
- Tabla de parámetros generales
- Campo crítico: **certificacion** (contador de folios)
- Se actualiza automáticamente al generar nueva certificación

**12. licencia** (Query auxiliar)
- Query para cálculos de campos calculados
- Obtiene número de licencia visible para campo calculado "licencia"

**13. anunciolok** (Query auxiliar)
- Query para cálculos de campo calculado "anuncio"
- Obtiene número de anuncio visible

### Tablas que Modifica

**1. certificaciones** (Inserta y Actualiza)
- **INSERT**: Al generar nueva certificación
  - Crea registro con folio único
  - Establece tipo ('L' o 'A')
  - Guarda id_licencia del registro certificado
  - Marca como vigente ('V')
  - Registra fecha, hora y usuario
- **UPDATE**: Al modificar o cancelar
  - Modificación: Permite cambiar observaciones, solicita, partida
  - Cancelación: Cambia vigente de 'V' a 'C', agrega motivo en observaciones

**2. parametros** (Actualiza)
- **UPDATE**: Al generar nueva certificación
  - Incrementa campo "certificacion" en 1
  - Genera folio único consecutivo
  - Fórmula: nuevo_folio = parametros.certificacion + 1

**Nota**: NO modifica tablas de licencias, anuncios, pagos o giros. Solo consulta.

## Stored Procedures

Este módulo **NO utiliza stored procedures explícitos**. Toda la lógica se implementa mediante:
- Queries SQL directas (SELECT)
- Inserciones y actualizaciones simples (INSERT, UPDATE)
- Lógica de negocio en el código del formulario

Las operaciones principales son:
- Búsqueda de licencia/anuncio por número
- Consulta de últimos pagos
- Generación de folio único mediante tabla parámetros
- Consulta de anuncios asociados (para subreporte)

## Impacto y Repercusiones

### ¿Qué registros afecta?

**1. Tabla certificaciones (Nuevo registro)**
- Crea registro permanente de cada certificación emitida
- Cada certificación queda en histórico legal
- No se elimina, solo se puede cancelar

**2. Tabla parametros (Actualización de contador)**
- Incrementa contador de certificaciones
- Cambio irreversible (no retrocede)
- Garantiza unicidad de folios

**3. NO afecta:**
- Licencias (solo consulta)
- Anuncios (solo consulta)
- Pagos (solo consulta)
- Giros (solo consulta)

### ¿Qué cambios de estado provoca?

**En tabla certificaciones:**

**Estado Inicial (al crear):**
- tipo = 'L' o 'A' según selección
- vigente = 'V'
- feccap = fecha actual
- capturista = usuario logueado

**Cancelación:**
- vigente cambia a 'C'
- Motivo en campo observacion
- NO se puede reimprimir
- Debe generar nueva certificación con nuevo folio

**Modificación:**
- Permite cambiar: observacion, solicita, partidapago
- NO permite cambiar: tipo, folio, fecha, estatus

**NO provoca cambios en:**
- Estatus de licencias o anuncios
- Obligaciones fiscales o pagos
- Permisos o autorizaciones

### ¿Qué documentos/reportes genera?

**Documentos Oficiales (valor legal):**

**1. Certificación de Licencia**
- Documento certificado con folio único
- Incluye datos completos de la licencia
- Muestra cumplimiento de pagos
- Incluye subreporte de anuncios asociados
- Uso: Trámites bancarios, notariales, judiciales

**2. Certificación de Anuncio**
- Documento certificado con folio único
- Incluye características técnicas del anuncio
- Acredita autorización vigente
- Muestra cumplimiento fiscal
- Uso: Acreditar legalidad de publicidad exterior

**Reportes Administrativos:**

**3. Listado de Certificaciones**
- Control interno y auditoría
- Filtros múltiples (folio, fecha, licencia/anuncio)
- Muestra estatus de cada certificación
- Contador de registros
- Útil para estadísticas e ingresos

### ¿Qué validaciones de negocio aplica?

**1. Unicidad de Folio**
- Cada certificación tiene folio único e irrepetible
- Formato: AÑO/FOLIO consecutivo
- Controlado por tabla parámetros

**2. Existencia de Licencia/Anuncio**
- Valida que el número exista en BD
- Para licencias: busca en BuscaLicencia
- Para anuncios: busca en BuscaAnuncio
- No permite certificar registros inexistentes

**3. Tipo Obligatorio**
- Debe seleccionar tipo antes de capturar
- Tipo determina flujo y validaciones
- No se puede cambiar tipo después de crear

**4. Estatus de Certificación**
- Solo permite imprimir certificaciones vigentes
- Bloquea impresión de canceladas
- Mensaje: "Certificacion cancelada, no se podrá imprimir..."

**5. Búsqueda de Pagos Inteligente**
- Busca primero en sistema actual
- Si no encuentra, busca en sistema legacy
- Intenta encontrar pago del año de la certificación
- Si no, muestra el más reciente
- No bloquea emisión si no hay pagos (muestra "S/C")

**6. Campos Calculados**
- licencia y anuncio son campos calculados (no capturables)
- Se calculan mediante queries auxiliares
- Muestran número visible en el grid

## Flujo de Trabajo

### Flujo Completo: Certificación de Licencia

```
1. INICIO
   ↓
2. Selecciona tipo: "Licencia" en RadioGroup
   ↓
3. Sistema ajusta interfaz para licencias
   - Campo buscar muestra "Licencia"
   - Grid muestra columna "Licencia"
   - Habilita campos específicos de licencias
   ↓
4. Captura número de licencia
   ↓
5. Click en "Buscar"
   ↓
6. Sistema busca en BuscaLicencia
   ↓
7. ¿Licencia existe?
   NO → Mensaje de error
         Regresa a captura
   SÍ → Muestra datos completos
   ↓
8. Sistema muestra:
   - Nombre del propietario
   - RFC
   - Giro comercial
   - Ubicación del negocio
   - Características del establecimiento
   - Horario (si aplica)
   - Aforo (si aplica)
   ↓
9. Click en "Nueva"
   ↓
10. Sistema prepara captura:
    - Abre Panel2
    - Modo inserción en tabla certificaciones
    - Deshabilita botones: Nueva, Cancelar Cert, Imprimir, Modificar
    - Habilita: Aceptar, Cancelar
    ↓
11. Usuario captura datos opcionales:
    - Solicita
    - Observaciones
    - Partida de pago
    ↓
12. Click en "Aceptar"
    ↓
13. Sistema genera folio:
    13.1. Consulta parametros.certificacion
    13.2. nuevo_folio = certificacion + 1
    13.3. UPDATE parametros SET certificacion = nuevo_folio
    ↓
14. Sistema graba certificación:
    - tipo = 'L'
    - axo = año actual
    - folio = nuevo_folio
    - id_licencia = id de la licencia buscada
    - vigente = 'V'
    - feccap = fecha actual
    - capturista = usuario logueado
    - Campos opcionales capturados
    - POST
    ↓
15. Sistema busca último pago:
    15.1. Busca en tabla pagos
          - Filtra: cvecuenta = id_licencia, cveconcepto = 8
          - Intenta encontrar pago del año actual
          - Si no, toma el más reciente (LAST)
    15.2. Si no encuentra:
          - Busca en pagos400
          - Convierte fecha: YYYYMMDD → DD/MM/YYYY
          - Convierte monto: centavos / 100
    15.3. Si no hay pagos:
          - Marca "S/C" en el reporte
    ↓
16. Sistema prepara impresión:
    - Abre query licencias con datos completos
    - Abre query giros para descripción
    - Abre query anuncios para subreporte
    - Construye etiquetas:
      * ppReport1Label34 = año del pago
      * ppReport1Label13 = fecha formato texto
      * ppReport1Label14 = monto o "S/C"
    ↓
17. Imprime ppReport1
    - Documento completo con membrete
    - Folio: AÑO/FOLIO
    - Datos de licencia y propietario
    - Información de pagos
    - Subreporte de anuncios
    - Firmas y sello
    ↓
18. Restaura interfaz:
    - Oculta Panel2
    - Habilita: Nueva, Cancelar Cert, Imprimir, Modificar
    - Deshabilita: Aceptar, Cancelar
    ↓
19. FIN - Documento entregado al solicitante
```

### Flujo Alternativo: Certificación de Anuncio

```
1-2. [Similar a flujo de licencia]
   ↓
3. Selecciona tipo: "Anuncio" en RadioGroup
   ↓
4. Sistema ajusta interfaz para anuncios
   - Campo buscar muestra "Anuncio"
   - Grid muestra columna "Anuncio"
   - Oculta campos específicos de licencias
   ↓
5-12. [Pasos similares: buscar, nueva, capturar, aceptar]
   ↓
13. Sistema graba certificación:
    - tipo = 'A' (diferente a licencia)
    - id_licencia = id del anuncio (no de licencia)
    - Resto igual
    ↓
14. Sistema busca último pago:
    - Usa query pagosAnun
    - Si no, usa pagos400Anun
    - Mismo proceso de conversión
    ↓
15. Sistema prepara impresión:
    - Abre query Anuncio con datos completos
    - Abre query giros
    - NO carga subreporte de anuncios
    - Construye etiquetas:
      * ppReport2Label34 = año del pago
      * ppReport2Label13 = fecha
      * ppReport2Label14 = monto
    ↓
16. Imprime ppReport2
    - Documento de anuncio
    - Incluye: medidas, área, número de caras
    - Texto del anuncio
    - Ubicación exacta
    - Datos del propietario
    - Información de pago
    - Firmas y sello
    ↓
17. FIN
```

### Flujo de Cancelación

```
1. Selecciona certificación en grid
   ↓
2. Click en "Cancelar Cert"
   ↓
3. Cuadro de confirmación:
   "¿Estas seguro de cancelar la certificación [AÑO]/[FOLIO]?"
   ↓
4. ¿Confirma?
   NO → Regresa, sin cambios
   SÍ → Continúa
   ↓
5. InputBox solicita motivo:
   "Motivo de Cancelación"
   "Cancelada por:"
   ↓
6. Usuario captura motivo
   ↓
7. Sistema actualiza:
   - certificaciones.EDIT
   - vigente = 'C'
   - observacion = motivo capturado
   - POST
   ↓
8. Grid muestra estatus Cancelado
   ↓
9. FIN
```

### Flujo de Modificación

```
1. Selecciona certificación en grid
   ↓
2. Click en "Modificar"
   ↓
3. Sistema prepara edición:
   - Carga número de licencia/anuncio según tipo
   - Ejecuta búsqueda automática
   - Muestra Panel2
   - Ajusta visibilidad según tipo
   - Modo EDIT en tabla certificaciones
   ↓
4. Deshabilita: Nueva, Cancelar Cert, Imprimir, Modificar
   Habilita: Aceptar, Cancelar
   ↓
5. Usuario modifica campos permitidos:
   - Solicita
   - Observaciones
   - Partida de pago
   ↓
6. Click en "Aceptar"
   - POST confirma cambios
   - NO imprime automáticamente
   ↓
7. O Click en "Cancelar"
   - CANCEL descarta cambios
   ↓
8. Restaura interfaz
   ↓
9. FIN
```

### Flujo de Búsqueda y Listado

```
1. Usuario abre Panel3 de búsqueda
   ↓
2. Selecciona criterio:

   OPCIÓN A: Por Año y Folio
   - CurrencyEdit2 = año
   - CurrencyEdit3 = folio
   - SQL: WHERE axo = [año] AND folio = [folio] AND tipo = [L/A]

   OPCIÓN B: Por Licencia/Anuncio
   - CurrencyEdit4 = número
   - Busca primero en BuscaLicencia o BuscaAnuncio
   - Obtiene id_licencia o id_anuncio
   - SQL: WHERE id_licencia = [id] AND tipo = [L/A]

   OPCIÓN C: Por Rango de Fechas
   - DateEdit1 = fecha inicial
   - DateEdit2 = fecha final (opcional)
   - SQL: WHERE feccap BETWEEN [fecha1] AND [fecha2] AND tipo = [L/A]

   OPCIÓN D: Todas
   - Campos vacíos
   - SQL: SELECT * WHERE tipo = [L/A] ORDER BY axo DESC, folio DESC
   ↓
3. Sistema ejecuta query
   ↓
4. Muestra resultados en grid
   - Columnas según tipo
   - Label18 muestra contador de registros
   ↓
5. Usuario puede:
   - Seleccionar para imprimir
   - Seleccionar para modificar
   - Seleccionar para cancelar
   - Generar listado impreso (BitBtn3)
   ↓
6. FIN
```

## Notas Importantes

### Consideraciones Especiales

1. **Diferencia entre Certificación y Constancia**
   - **Certificación**: Acredita cumplimiento y estado al corriente
   - **Constancia**: Solo hace constar existencia o datos
   - La certificación tiene mayor peso legal y fiscal

2. **Tipos de Certificación**
   - **Tipo 'L' (Licencia)**: Para negocios establecidos
   - **Tipo 'A' (Anuncio)**: Para publicidad exterior
   - Cada tipo tiene su formato y datos específicos
   - No se pueden mezclar en una misma certificación

3. **Subreporte de Anuncios**
   - Solo aplica para certificaciones de licencia
   - Muestra TODOS los anuncios autorizados asociados
   - Útil para acreditar publicidad ligada al negocio
   - No aplica para certificaciones de anuncios individuales

4. **Información de Pagos**
   - Muestra ÚLTIMO pago registrado
   - Intenta buscar pago del año actual
   - Si no encuentra, muestra el más reciente
   - NO valida si hay adeudos pendientes
   - La certificación se emite aunque no haya pagos (marca "S/C")

5. **Integración con Sistema Legacy**
   - Busca pagos en sistema actual primero
   - Si no encuentra, consulta pagos400 (legacy)
   - Convierte formatos: fecha YYYYMMDD, monto en centavos
   - Garantiza continuidad histórica

6. **Folio Único Legal**
   - Cada certificación tiene folio único e irrepetible
   - Formato: AÑO/FOLIO consecutivo
   - No se reutiliza aunque se cancele
   - Base para trazabilidad legal y auditorías

7. **Campos Calculados**
   - "licencia" y "anuncio" son campos calculados
   - Se calculan mediante queries auxiliares (licencia, anunciolok)
   - No se pueden capturar directamente
   - Muestran número visible al usuario en el grid

### Restricciones

**No se puede:**
- Eliminar certificaciones (solo cancelar)
- Cambiar el folio asignado
- Modificar fecha de captura
- Cambiar tipo de certificación una vez creada
- Reimprimir certificaciones canceladas
- Cambiar usuario capturista
- Retroceder contador de folios
- Certificar licencias/anuncios inexistentes

**Se puede:**
- Cancelar con motivo justificado
- Modificar observaciones, solicita, partida
- Reimprimir certificaciones vigentes
- Consultar histórico completo
- Generar listados y reportes

### Permisos Necesarios

**Para operar:**
- Usuario válido del sistema
- Acceso al módulo de certificaciones
- Permisos de escritura: certificaciones, parametros
- Permisos de lectura: licencias, anuncios, pagos, giros

**Para acciones específicas:**
- Generar certificación: Permiso de escritura
- Cancelar: Permiso especial (puede estar restringido)
- Modificar: Permiso de edición
- Consultar/Reimprimir: Solo lectura

**Seguridad:**
- Usuario registrado automáticamente
- Trazabilidad completa de operaciones
- No se puede suplantar identidad
- Histórico permanente para auditorías

### Mantenimiento y Soporte

**Problemas comunes:**

1. **"No se encontró licencia/anuncio"**
   - Verificar número correcto
   - Confirmar registro en BD
   - Validar migración desde sistema anterior

2. **"No se puede imprimir certificación cancelada"**
   - Comportamiento normal
   - Generar nueva con folio diferente
   - Verificar motivo en observaciones

3. **No aparece pago o aparece "S/C"**
   - Verificar registros en pagos y pagos400
   - No es error crítico
   - Certificación se emite igual

4. **Subreporte de anuncios vacío**
   - Normal si la licencia no tiene anuncios
   - No afecta validez de la certificación

5. **Folios duplicados (muy raro)**
   - Problema de concurrencia
   - Reportar a sistemas
   - Implementar bloqueos o transacciones

**Respaldos recomendados:**
- Tabla certificaciones: Respaldo diario
- Tabla parametros: Respaldo antes de cierres
- Reportes .fr3: Control de versiones
