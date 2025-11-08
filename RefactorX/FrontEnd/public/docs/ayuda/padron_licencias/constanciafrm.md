# Constancias de Licencias

## Descripción General

### ¿Qué hace este módulo?
Este módulo permite generar y administrar **constancias oficiales** relacionadas con licencias de funcionamiento comercial. Es un documento certificado que emite el municipio para hacer constar diferentes situaciones legales de una licencia o propiedad.

### ¿Para qué sirve en el proceso administrativo?
Sirve para:
- Certificar que una licencia está vigente y al corriente de pagos
- Constatar que NO existe licencia en un domicilio específico
- Constatar que un propietario NO tiene licencias a su nombre
- Constatar que no existe licencia VIGENTE en un domicilio
- Generar documentos oficiales con folio único para trámites legales, notariales o bancarios

### ¿Quiénes lo utilizan?
- **Personal de ventanilla**: Para atender solicitudes de ciudadanos
- **Supervisor de licencias**: Para autorizar y validar constancias
- **Contribuyentes**: Solicitan las constancias para trámites diversos (compra-venta, créditos, juicios, etc.)
- **Notarios públicos**: Requieren constancias para protocolizar actos jurídicos

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?

**1. Solicitud de Nueva Constancia**
   - El usuario hace clic en el botón "Nueva"
   - El sistema abre un panel de captura
   - Se debe seleccionar el tipo de constancia mediante RadioGroup:
     - **Opción 0**: Constancia de Licencia Vigente (requiere capturar número de licencia)
     - **Opción 1**: Constancia de NO Licencia en Domicilio
     - **Opción 2**: Constancia de NO Licencia del Propietario
     - **Opción 3**: Constancia de NO Licencia VIGENTE en Domicilio

**2. Captura de Información**
   - Si es constancia de licencia (opción 0):
     - Capturar número de licencia en el campo correspondiente
     - Presionar botón de búsqueda para validar la licencia
     - El sistema muestra datos del propietario, giro, ubicación, etc.
   - Si es constancia de NO licencia (opciones 1, 2 o 3):
     - Capturar domicilio o nombre del propietario en campo libre
     - No requiere búsqueda en base de datos

**3. Generación de Folio**
   - Al presionar "Aceptar", el sistema:
     - Consulta la tabla de **parámetros** para obtener el siguiente folio consecutivo
     - Incrementa automáticamente el contador de constancias
     - Asigna folio único en formato: AÑO/FOLIO (ejemplo: 2025/00234)
     - Registra fecha de captura y usuario que elabora

**4. Validaciones Importantes**
   - Para constancias de licencia vigente:
     - Verifica que la licencia exista en la base de datos
     - Valida el estatus de la licencia (vigente, baja, cancelada)
     - Verifica último pago realizado (busca en pagos actuales y históricos-pagos400)
   - Para todas las constancias:
     - Verifica que no esté cancelada antes de permitir impresión
     - Valida que el folio sea único

**5. Impresión del Documento**
   - Se genera un documento oficial con:
     - Escudo del municipio
     - Folio único
     - Fecha de emisión
     - Datos del titular (nombre completo con apellidos)
     - Para licencias vigentes:
       - Número de licencia
       - Giro comercial autorizado
       - Dirección de ubicación del negocio
       - Fecha de otorgamiento
       - Fecha y monto del último pago
       - Anuncios autorizados asociados (si aplica)
     - Para constancias negativas:
       - Domicilio consultado o nombre del propietario
       - Leyenda específica según el tipo
     - Nombre y firma del funcionario autorizado

### ¿Qué información requiere el usuario?

**Para Constancia de Licencia Vigente:**
- Número de licencia (campo obligatorio)
- Observaciones adicionales (opcional)
- Partida de pago (opcional)

**Para Constancia de NO Licencia:**
- Domicilio completo a certificar (calle, número, colonia)
- O nombre completo del propietario a certificar
- Motivo de la solicitud en observaciones (opcional)

**Datos que captura automáticamente el sistema:**
- Año actual
- Folio consecutivo (automático)
- Fecha de captura (fecha del sistema)
- Usuario que elabora (login del sistema)
- Estatus inicial: "V" (Vigente)

### ¿Qué validaciones se realizan?

**Validaciones de Negocio:**
1. **Validación de Licencia Existente**: Al capturar número de licencia, busca en la tabla BuscaLicencia para verificar que existe
2. **Validación de Estatus**: Verifica el campo "vigente" de la licencia:
   - V = Vigente (permite constancia)
   - C = Cancelada (marca en el documento)
   - B = Baja (marca en el documento con fecha y folio de baja)
3. **Validación de Pagos**: Busca el último pago en dos tablas:
   - Tabla "pagos" (sistema actual)
   - Tabla "pagos400" (sistema anterior/legado)
   - Muestra fecha del último pago en la constancia
4. **Validación de Constancia Cancelada**: Antes de imprimir, verifica que el campo "vigente" de la constancia sea "V", no permite imprimir si está cancelada

**Validaciones de Integridad:**
1. No permite capturar constancia sin seleccionar tipo
2. Para tipo 0 (licencia), obliga a buscar y validar la licencia antes de aceptar
3. Genera folio único e irrepetible mediante contador en tabla parámetros
4. Registra usuario y fecha para trazabilidad

### ¿Qué documentos genera?

**1. Constancia de Licencia Vigente** (Reporte: ppReport1)
   - Formato oficial con membrete
   - Folio: AÑO/FOLIO
   - Número de licencia
   - Datos completos del propietario (nombre, apellidos, RFC)
   - Domicilio del propietario
   - Giro o actividad comercial autorizada
   - Características del establecimiento (superficie, empleados, cajones, aforo, horario, inversión)
   - Ubicación del negocio
   - Fecha de otorgamiento de la licencia
   - Fecha y monto del último pago de derechos
   - Listado de anuncios autorizados (subreporte)
   - Leyenda: "LICENCIA VIGENTE" o "LICENCIA DADA DE BAJA"
   - Firma del funcionario autorizado

**2. Constancia de NO Licencia en Domicilio** (Reporte: nolicencia)
   - Formato oficial con membrete
   - Folio: AÑO/FOLIO
   - Domicilio investigado
   - Leyenda: "NO SE ENCONTRO REGISTRO DE NINGUN TIPO DE LICENCIA EN EL DOMICILIO:"
   - Solicita: (nombre del solicitante)
   - Observaciones capturadas
   - Firma del funcionario autorizado

**3. Constancia de NO Licencia del Propietario** (Reporte: nolicenciaprop)
   - Formato oficial con membrete
   - Folio: AÑO/FOLIO
   - Nombre del propietario investigado
   - Leyenda certificando que no se encontró registro de licencias a nombre del propietario
   - Solicita: (nombre del solicitante)
   - Firma del funcionario autorizado

**4. Constancia de NO Licencia VIGENTE en Domicilio** (Reporte: nolicencia con leyenda modificada)
   - Similar al formato de NO licencia
   - Leyenda: "NO SE ENCONTRÓ REGISTRO VIGENTE DE NINGÚN TIPO DE LICENCIA EN EL DOMICILIO:"
   - Implica que puede haber licencias dadas de baja en ese domicilio

**5. Listado de Constancias** (Reporte: listado)
   - Reporte para control interno
   - Lista todas las constancias emitidas según criterios de búsqueda
   - Columnas: Folio, Fecha, Licencia, Solicita, Observación, Estatus
   - Incluye conteo total de registros
   - Permite filtrar por: año/folio, licencia, rango de fechas

## Tablas de Base de Datos

### Tabla Principal
**constancias**
- Almacena el registro de todas las constancias emitidas por el sistema
- Campos principales:
  - **axo**: Año de emisión (formato YYYY)
  - **folio**: Número consecutivo de la constancia
  - **id_licencia**: Identificador de la licencia (0 si es constancia negativa)
  - **licencia**: Campo calculado que muestra el número de licencia visible
  - **solicita**: Nombre de quien solicita la constancia
  - **partidapago**: Referencia contable del pago por el servicio
  - **observacion**: Observaciones adicionales o motivo de solicitud
  - **vigente**: Estatus de la constancia (V=Vigente, C=Cancelada)
  - **feccap**: Fecha de captura
  - **capturista**: Usuario que elaboró la constancia
  - **domicilio**: Domicilio para constancias negativas
  - **tipo**: Tipo de constancia (0=Licencia, 1=No licencia dom, 2=No lic prop, 3=No lic vigente)

### Tablas Relacionadas que Consulta

**1. BuscaLicencia** (Query)
- Busca información de una licencia específica por su número
- Valida existencia de la licencia antes de generar constancia
- Proporciona id_licencia para relacionar con la constancia

**2. licencias**
- Tabla maestra de licencias de funcionamiento
- Consulta datos completos de la licencia para incluir en la constancia:
  - Número de licencia, propietario (nombre y apellidos), RFC, CURP
  - Domicilio del propietario (calle, número, colonia, CP)
  - Ubicación del negocio
  - Datos del establecimiento (superficie, empleados, cajones, aforo, inversión)
  - id_giro (para obtener descripción del giro)
  - Fecha de otorgamiento
  - Estatus (vigente, baja)
  - Si está de baja: fecha_baja, axo_baja, folio_baja
  - Horario de operación

**3. giros** (c_giros)
- Catálogo de giros o actividades comerciales
- Obtiene: descripción del giro, clasificación, código SCIAN
- Se liga por: id_giro de la licencia

**4. anuncios**
- Tabla de anuncios publicitarios autorizados
- Ligada a licencias por: id_licencia
- Muestra anuncios asociados en subreporte de la constancia
- Campos mostrados: número de anuncio, texto, medidas, ubicación

**5. pagos**
- Tabla de pagos realizados en el sistema actual
- Busca el último pago de derechos de la licencia
- Obtiene: fecha y monto del último pago
- Filtra por: cvecuenta = id_licencia

**6. pagos400**
- Tabla histórica de pagos del sistema anterior (legado)
- Si no encuentra pagos en la tabla actual, busca aquí
- Obtiene: fecha de pago (campo fepa3) y monto (campo impe3 o imppag)
- Formato de fecha legacy: YYYYMMDD debe convertirse a DD/MM/YYYY

**7. parametros**
- Tabla de parámetros generales del sistema
- Campo crítico: **constancia** (contador del último folio asignado)
- Se actualiza automáticamente al generar nueva constancia
- Incrementa en 1 cada vez que se emite una constancia

**8. constancia** (Table)
- Tabla auxiliar para generación de constancias negativas
- Proporciona datos al pipeline de impresión
- Se usa para reportes de NO licencia

**9. licencia** (Query)
- Query auxiliar para cálculos de campos
- Obtiene el número de licencia visible para desplegar en grid
- Se usa en CalcFields para mostrar la licencia en el campo calculado

### Tablas que Modifica

**1. constancias** (Inserta y Actualiza)
- **INSERT**: Al generar nueva constancia
  - Crea nuevo registro con folio único
  - Establece vigente = 'V'
  - Registra fecha actual y usuario
  - Guarda tipo de constancia
- **UPDATE**: Al modificar constancia existente
  - Permite cambiar observaciones, solicita, partida de pago
  - **Cancelación**: Cambia vigente de 'V' a 'C' y agrega motivo en observaciones

**2. parametros** (Actualiza)
- **UPDATE**: Al generar nueva constancia
  - Incrementa el campo "constancia" en 1
  - Este cambio es crítico: genera el folio único
  - Fórmula: nuevo_folio = parametros.constancia + 1

**Nota Importante sobre Integridad:**
- El sistema NO modifica las tablas de licencias, pagos o giros
- Solo consulta información para incluir en las constancias
- Las constancias son documentos certificados "de solo lectura" de la información actual

## Stored Procedures

Este módulo **NO utiliza stored procedures**. Toda la lógica se maneja mediante:
- Queries SQL directas (SELECT)
- Actualizaciones simples de tablas (INSERT, UPDATE)
- Lógica de negocio en el código del formulario

Las principales queries que ejecuta son:
- Búsqueda de licencia por número
- Consulta de pagos asociados
- Generación de folio único mediante tabla de parámetros
- Consulta de anuncios ligados a la licencia

## Impacto y Repercusiones

### ¿Qué registros afecta?

**1. Registro en tabla constancias (Nuevo)**
- Crea un registro permanente de cada constancia emitida
- No se elimina, solo se puede cancelar (cambio de estatus)
- Sirve como histórico oficial de documentos expedidos

**2. Contador de folios en parámetros (Actualización)**
- Incrementa irrevocablemente el contador
- No se puede revertir ni retroceder el folio
- Garantiza unicidad de folios

**3. NO afecta registros de:**
- Licencias (solo consulta, no modifica)
- Pagos (solo consulta)
- Giros (solo consulta)
- Anuncios (solo consulta)

### ¿Qué cambios de estado provoca?

**En la tabla constancias:**

1. **Estado Inicial (al crear):**
   - vigente = 'V' (Vigente y válida)
   - feccap = fecha actual
   - capturista = usuario del sistema

2. **Cancelación de constancia:**
   - vigente cambia de 'V' a 'C'
   - Se agrega motivo de cancelación en campo observacion
   - **Importante**: Una constancia cancelada NO se puede reimprimir
   - Debe generarse una nueva constancia con folio diferente
   - Razones comunes de cancelación:
     - Error en captura de datos
     - Solicitud del contribuyente
     - Documento extraviado
     - Información incorrecta

3. **Modificación de constancia existente:**
   - Permite cambiar: observacion, solicita, partidapago, domicilio
   - NO permite cambiar: folio, año, fecha, tipo, estatus
   - Útil para corregir errores menores antes de imprimir

**NO provoca cambios en:**
- Estatus de licencias (la licencia sigue con su estatus independiente)
- Saldos o pagos (la constancia no afecta obligaciones fiscales)
- Bloqueos o restricciones de licencias

### ¿Qué documentos/reportes genera?

**Documentos Oficiales (con valor legal):**

1. **Constancia de Licencia Vigente**
   - Documento certificado con folio único
   - Incluye todos los datos de la licencia
   - Muestra estatus actual y último pago
   - Válida para trámites legales, notariales, bancarios
   - Caso de uso: Compraventa de negocios, créditos, renovación de contratos

2. **Constancia de NO Licencia (3 variantes)**
   - Certifica ausencia de licencias en un domicilio o propietario
   - Válida para:
     - Apertura de nuevo negocio
     - Trámites ante notarios
     - Comprobación de cumplimiento legal
     - Trámites de regularización

**Reportes Administrativos (para control interno):**

3. **Listado de Constancias**
   - Reporte para auditoría y control
   - Permite filtrar por:
     - Año y folio específico
     - Número de licencia
     - Rango de fechas de emisión
   - Muestra: folio, fecha, licencia, tipo, estatus, solicita
   - Incluye contador de registros
   - Útil para:
     - Auditorías internas
     - Control de ingresos por servicio
     - Estadísticas de trámites
     - Seguimiento de constancias canceladas

### ¿Qué validaciones de negocio aplica?

**Validaciones Críticas:**

1. **Unicidad de Folio**
   - Cada constancia tiene un folio único e irrepetible
   - Formato: AÑO/FOLIO consecutivo
   - Controlado por tabla parámetros
   - Garantiza trazabilidad legal del documento

2. **Existencia de Licencia (para tipo 0)**
   - Valida que el número de licencia exista en la base de datos
   - No permite generar constancia de licencia inexistente
   - Muestra mensaje de error si no encuentra la licencia

3. **Estatus de Constancia**
   - Solo permite imprimir constancias vigentes (V)
   - Bloquea impresión de constancias canceladas (C)
   - Mensaje: "Constancia cancelada, no se podrá imprimir..."

4. **Información de Pagos**
   - Busca último pago en sistema actual y legacy
   - Si no encuentra pagos, muestra campo vacío
   - No bloquea la emisión de constancia
   - Muestra "S/C" si no hay costo o pago registrado

5. **Tipo de Constancia**
   - Valida que se seleccione un tipo antes de aceptar
   - Cada tipo tiene su flujo y validaciones específicas
   - No permite mezclar tipos en un mismo registro

6. **Integridad de Usuario**
   - Registra automáticamente el usuario que elabora
   - No permite cambiar el usuario que capturó
   - Útil para auditorías y responsabilidad administrativa

## Flujo de Trabajo

### Flujo Completo: Emisión de Constancia de Licencia Vigente

```
1. INICIO
   ↓
2. Usuario solicita constancia
   ↓
3. Empleado abre módulo de Constancias
   ↓
4. Click en botón "Nueva"
   ↓
5. Sistema habilita panel de captura
   - Muestra RadioGroup de tipos
   - Habilita campos de captura
   - Deshabilita botones: Nueva, Cancelar Const, Imprimir, Modificar
   - Habilita botones: Aceptar, Cancelar
   ↓
6. Selecciona tipo: "Licencia" (opción 0)
   - Sistema muestra campo de número de licencia
   - Habilita botón de búsqueda
   ↓
7. Captura número de licencia
   ↓
8. Click en botón "Buscar" (BitBtn2)
   ↓
9. Sistema busca en tabla licencias
   - Ejecuta query BuscaLicencia
   - Valida existencia
   ↓
10. ¿Licencia encontrada?
    NO → Muestra mensaje de error
          Usuario debe verificar número
          Regresa a paso 7
    SÍ → Continúa
    ↓
11. Sistema muestra información de la licencia
    - Nombre completo del propietario (con apellidos)
    - RFC y CURP
    - Giro comercial
    - Domicilio del propietario
    - Ubicación del negocio
    - Características (superficie, empleados, cajones, aforo)
    - Fecha de otorgamiento
    - Estatus (vigente/baja)
    ↓
12. Usuario captura datos adicionales (opcional)
    - Campo "Solicita": nombre del solicitante
    - Campo "Observaciones": notas adicionales
    - Campo "Partida de Pago": referencia contable
    ↓
13. Click en botón "Aceptar"
    ↓
14. Sistema ejecuta proceso de grabación:

    14.1. Consulta tabla parámetros
          - Lee campo "constancia" (último folio usado)

    14.2. Calcula nuevo folio
          - folio = parámetros.constancia + 1

    14.3. Actualiza tabla parámetros
          - UPDATE parámetros SET constancia = nuevo_folio

    14.4. Inserta registro en tabla constancias
          - axo = año actual (formato YYYY)
          - folio = nuevo folio calculado
          - id_licencia = id de la licencia consultada
          - tipo = 0 (licencia)
          - solicita = campo capturado
          - observacion = campo capturado
          - partidapago = campo capturado
          - vigente = 'V'
          - feccap = fecha actual del sistema
          - capturista = usuario logueado

    14.5. Confirma transacción (POST)
    ↓
15. Sistema prepara impresión
    - Abre query de licencias con datos completos
    - Abre query de giros para descripción
    - Busca último pago:
      15.1. Busca en tabla "pagos" (sistema actual)
      15.2. Si no encuentra, busca en "pagos400" (legacy)
      15.3. Determina fecha y monto del último pago
    - Carga anuncios autorizados asociados
    ↓
16. Sistema genera el documento
    - Formatea fecha de último pago
    - Construye leyenda según estatus:
      * Si vigente = 'V': "LICENCIA VIGENTE"
      * Si vigente = 'B' o 'C': "LICENCIA DADA DE BAJA, EL DÍA: [fecha], FOLIO: [axo/folio]"
    - Si hay pagos: Muestra monto formateado
    - Si no hay pagos: Muestra "S/C"
    ↓
17. Sistema envía a impresora
    - Reporte: ppReport1
    - Formato: Carta (8.5 x 11 pulgadas)
    - Incluye: membrete, folio, datos, subreporte de anuncios, firmas
    ↓
18. Sistema restaura botones
    - Habilita: Nueva, Cancelar Const, Imprimir, Modificar
    - Deshabilita: Aceptar, Cancelar
    - Oculta panel de captura
    ↓
19. Documento impreso entregado al solicitante
    ↓
20. FIN
```

### Flujo Alternativo: Emisión de Constancia de NO Licencia

```
1-6. [Pasos iguales al flujo principal]
    ↓
7. Selecciona tipo: "No Licencia Domicilio" (opción 1)
   - Sistema oculta campo de número de licencia
   - Muestra campo libre de domicilio
   ↓
8. Captura domicilio a certificar
   - Calle, número, colonia
   - Campo libre de texto
   ↓
9. Captura datos adicionales
   - Campo "Solicita": obligatorio
   - Campo "Domicilio": domicilio a certificar
   - Campo "Observaciones": opcional
   ↓
10. Click en "Aceptar"
    ↓
11. Sistema ejecuta grabación
    - Igual que pasos 14.1 a 14.4 del flujo principal
    - Pero: id_licencia = 0 (no hay licencia)
    - Y: tipo = 1, 2 o 3 según selección
    ↓
12. Sistema genera constancia negativa
    - Abre tabla "constancia" (auxiliar)
    - NO busca datos de licencias
    - NO busca pagos
    - Construye leyenda según tipo:
      * Tipo 1: "NO SE ENCONTRO REGISTRO DE NINGUN TIPO DE LICENCIA EN EL DOMICILIO:"
      * Tipo 2: Certifica que propietario no tiene licencias
      * Tipo 3: "NO SE ENCONTRÓ REGISTRO VIGENTE DE NINGÚN TIPO DE LICENCIA EN EL DOMICILIO:"
    ↓
13. Imprime documento
    - Reporte: nolicencia o nolicenciaprop
    - Incluye: membrete, folio, domicilio o propietario, leyenda, firmas
    ↓
14. FIN
```

### Flujo de Cancelación de Constancia

```
1. Usuario selecciona constancia en el grid
   ↓
2. Click en botón "Cancelar Const"
   ↓
3. Sistema muestra cuadro de confirmación
   - Mensaje: "¿Estas seguro de cancelar la constancia? [AÑO]/[FOLIO]?"
   - Opciones: Sí / No
   ↓
4. ¿Usuario confirma?
   NO → Regresa al listado, no hace cambios
   SÍ → Continúa
   ↓
5. Sistema solicita motivo
   - InputBox: "Motivo de Cancelación"
   - Prompt: "Cancelada por:"
   - Precarga: observación actual (si existe)
   ↓
6. Usuario captura motivo de cancelación
   ↓
7. Sistema actualiza registro
   - Pone constancia en modo edición
   - UPDATE constancias SET:
     * vigente = 'C'
     * observacion = [motivo capturado]
   - Confirma cambios (POST)
   ↓
8. Sistema muestra constancia como cancelada
   - Grid muestra estatus "Cancelado"
   - Botón "Imprimir" valida antes: no permite imprimir canceladas
   ↓
9. FIN
```

### Flujo de Reimpresión

```
1. Usuario selecciona constancia del grid
   ↓
2. Click en botón "Imprimir"
   ↓
3. Sistema valida estatus
   - Lee campo "vigente" de la constancia seleccionada
   ↓
4. ¿vigente = 'C' (Cancelada)?
   SÍ → Muestra mensaje: "Constancia cancelada, no se podrá imprimir..."
        Termina proceso
   NO → Continúa
   ↓
5. Identifica tipo de constancia (campo "tipo")
   ↓
6. ¿tipo = 0? (Licencia)
   SÍ → Ejecuta flujo de impresión de licencia
        - Busca datos de licencia
        - Busca último pago
        - Carga anuncios
        - Imprime ppReport1
   NO → Continúa
   ↓
7. ¿tipo = 1 o 3? (No licencia domicilio)
   SÍ → Ejecuta flujo de constancia negativa domicilio
        - Ajusta leyenda según tipo
        - Imprime nolicencia
   NO → Continúa
   ↓
8. ¿tipo = 2? (No licencia propietario)
   SÍ → Ejecuta flujo de constancia negativa propietario
        - Imprime nolicenciaprop
   ↓
9. FIN
```

### Flujo de Consulta/Búsqueda de Constancias

```
1. Usuario abre Panel3 de búsqueda
   ↓
2. Selecciona criterio de búsqueda:

   OPCIÓN A: Por Año y Folio
   - Captura año (CurrencyEdit2)
   - Captura folio (CurrencyEdit3)
   - Click en botón buscar (BitBtn1)
   - Sistema ejecuta SQL: WHERE axo = [año] AND folio = [folio]

   OPCIÓN B: Por Número de Licencia
   - Captura número de licencia (CurrencyEdit4)
   - Click en botón buscar
   - Sistema:
     * Busca id_licencia en tabla BuscaLicencia
     * Ejecuta SQL: WHERE id_licencia = [id encontrado]

   OPCIÓN C: Por Rango de Fechas
   - Selecciona fecha inicial (DateEdit1)
   - Selecciona fecha final (DateEdit2) - opcional
   - Click en botón buscar
   - Sistema ejecuta SQL: WHERE feccap BETWEEN [fecha1] AND [fecha2]
   - O si solo una fecha: WHERE feccap = [fecha1]

   OPCIÓN D: Todas las constancias
   - Dejar todos los campos vacíos
   - Click en botón buscar
   - Sistema ejecuta SQL: SELECT * FROM constancias ORDER BY axo DESC, folio DESC
   ↓
3. Sistema ejecuta consulta
   - Cierra query actual
   - Limpia SQL
   - Construye nueva consulta según criterio
   - Abre query con resultados
   ↓
4. Muestra resultados en DBGrid1
   - Columnas: Año, Folio, Licencia, Solicita, Observación, Vigente, Fecha
   - Ordenado por año descendente, folio descendente (más recientes primero)
   - Label18 muestra contador: "[n] Registro(s)"
   ↓
5. Usuario puede:
   - Navegar por los registros
   - Seleccionar uno para imprimir
   - Seleccionar uno para modificar
   - Seleccionar uno para cancelar
   - Generar listado impreso (BitBtn3 → reporte "listado")
   ↓
6. FIN
```

### Flujo de Modificación de Constancia

```
1. Usuario selecciona constancia del grid
   ↓
2. Click en botón "Modificar"
   ↓
3. Sistema valida que existe constancia seleccionada
   ↓
4. Sistema prepara edición:
   - Carga número de licencia (si tipo = 0)
   - Ejecuta búsqueda automática (BitBtn2Click)
   - Muestra panel de captura (Panel2.visible = true)
   - Establece RadioGroup según tipo de constancia
   - Deshabilita RadioGroup (no se puede cambiar tipo)
   - Pone constancia en modo edición (.edit)
   ↓
5. Deshabilita/habilita botones:
   - Deshabilita: Nueva, Cancelar Const, Imprimir, Modificar
   - Habilita: Aceptar, Cancelar
   ↓
6. Usuario modifica campos permitidos:
   - Solicita
   - Observaciones
   - Partida de pago
   - Domicilio (si es tipo no licencia)
   ↓
7. ¿Usuario hace cambios?

   SÍ → Click en "Aceptar"
        - Sistema confirma cambios (POST)
        - NO imprime (solo modifica)
        - Restaura botones
        - Oculta panel de captura

   NO → Click en "Cancelar"
        - Sistema descarta cambios (CANCEL)
        - Restaura datos originales
        - Restaura botones
        - Oculta panel de captura
   ↓
8. FIN
```

## Notas Importantes

### Consideraciones Especiales

1. **Folio Único e Irrepetible**
   - El folio es el identificador legal del documento
   - Una vez asignado, NO se puede reutilizar
   - Si se cancela una constancia, se debe generar otra con nuevo folio
   - El contador en tabla "parametros" NUNCA retrocede

2. **Constancias Canceladas**
   - NO se pueden reimprimir
   - NO se pueden "descancelar"
   - Quedan en el histórico para auditorías
   - Motivo de cancelación queda registrado en observaciones

3. **Vigencia Legal**
   - Las constancias tienen validez legal formal
   - Incluyen folio oficial único
   - Requieren firma de funcionario autorizado
   - Se usan en trámites notariales, bancarios y judiciales

4. **Integración con Sistemas Legacy**
   - Consulta pagos en sistema actual (tabla "pagos")
   - Si no encuentra, busca en sistema anterior (tabla "pagos400")
   - Formato de fecha legacy debe convertirse: YYYYMMDD → DD/MM/YYYY
   - Montos legacy se dividen entre 100 (están en centavos)

5. **Tipos de Constancias y Sus Usos**
   - **Tipo 0 (Licencia)**: Para acreditar que el negocio tiene licencia vigente
     * Uso: Compraventa, créditos, renovación de contratos
   - **Tipo 1 (No licencia domicilio)**: Certifica que NO hay licencias en una dirección
     * Uso: Apertura de nuevo negocio, trámites de suelo
   - **Tipo 2 (No licencia propietario)**: Certifica que una persona NO tiene licencias
     * Uso: Trámites personales, acreditación de no actividad comercial
   - **Tipo 3 (No licencia VIGENTE domicilio)**: Certifica que NO hay licencias activas (puede haber bajas)
     * Uso: Regularización, trámites legales específicos

6. **Información de Pagos**
   - Muestra ÚLTIMO pago registrado
   - Intenta buscar pago del mismo año de la constancia
   - Si no encuentra del año actual, muestra el más reciente
   - Si no hay pagos registrados, muestra "S/C" (sin costo)
   - NO valida si hay adeudos pendientes

7. **Subreporte de Anuncios**
   - Solo aplica para constancias de licencia (tipo 0)
   - Muestra todos los anuncios autorizados asociados a la licencia
   - Incluye: número de anuncio, texto, medidas, ubicación
   - Aparece al final del documento de constancia

### Restricciones

1. **Acceso al Módulo**
   - Requiere usuario y contraseña del sistema
   - El usuario queda registrado en cada constancia (campo "capturista")
   - Para auditorías y responsabilidad administrativa

2. **No se Puede:**
   - Eliminar constancias (solo cancelar)
   - Cambiar el folio asignado
   - Modificar fecha de captura
   - Cambiar el tipo de constancia una vez creada
   - Reimprimir constancias canceladas
   - Retroceder el contador de folios
   - Cambiar el usuario que capturó

3. **Se Puede:**
   - Cancelar constancias con motivo justificado
   - Modificar observaciones, solicita, partida de pago
   - Reimprimir constancias vigentes (múltiples veces)
   - Consultar histórico completo
   - Generar reportes y listados

4. **Validaciones de Integridad**
   - Campo "licencia" en grid es calculado (no se puede capturar directamente)
   - La búsqueda de licencia debe ser exitosa antes de crear constancia tipo 0
   - El RadioGroup de tipo es obligatorio antes de aceptar

### Permisos Necesarios

1. **Para Operar el Módulo:**
   - Usuario válido en el sistema de licencias
   - Acceso al módulo de constancias (control de acceso por perfil)
   - Permisos de escritura en tablas: constancias, parametros
   - Permisos de lectura en: licencias, pagos, pagos400, giros, anuncios

2. **Para Acciones Específicas:**
   - **Generar nueva constancia**: Permiso de escritura
   - **Cancelar constancia**: Permiso especial (puede estar restringido a supervisores)
   - **Modificar constancia**: Permiso de edición
   - **Consultar/Reimprimir**: Solo requiere lectura

3. **Para Funciones Administrativas:**
   - **Generar listados**: Solo lectura
   - **Exportar a Excel**: Permiso de exportación (si aplica)
   - **Auditoría de constancias**: Acceso a todos los registros históricos

4. **Seguridad:**
   - El sistema registra automáticamente el usuario en cada operación
   - No se puede suplantar identidad (usa usuario del login)
   - Cada constancia tiene trazabilidad completa
   - Los cambios de estatus (cancelaciones) quedan registrados

### Mantenimiento y Soporte

**Problemas Comunes y Soluciones:**

1. **"No se encontró licencia"**
   - Verificar que el número sea correcto
   - Confirmar que la licencia esté registrada en el sistema
   - Validar que no sea una licencia del sistema anterior sin migrar

2. **"No se puede imprimir constancia cancelada"**
   - Es comportamiento normal
   - Debe generarse nueva constancia con folio diferente
   - Verificar motivo de cancelación en observaciones

3. **No aparece último pago o aparece vacío**
   - Verificar que existan registros en tabla "pagos" o "pagos400"
   - No es un error crítico, la constancia se emite igual
   - Puede indicar que la licencia es muy antigua o sin pagos registrados

4. **Folios duplicados (muy raro)**
   - Puede ocurrir por acceso concurrente a tabla parámetros
   - Reportar a sistemas para corrección manual
   - Implementar control de transacciones o bloqueos

5. **No se actualiza contador de registros**
   - Verificar evento DataChange del DataSource
   - Refrescar la consulta (cerrar y abrir query)

**Respaldos Recomendados:**
- Tabla "constancias": Respaldo diario (histórico legal importante)
- Tabla "parametros": Respaldo antes y después de cada cierre mensual
- Reportes .fr3: Control de versiones de formatos de impresión
