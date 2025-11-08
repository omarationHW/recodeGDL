# Impresión de Dictámenes de Anuncios

## Descripción General

### ¿Qué hace este módulo?
Este módulo genera e imprime dictámenes oficiales de anuncios publicitarios. Produce dos tipos de documentos: dictámenes de autorización y dictámenes de negación, con toda la información técnica y legal del anuncio y la licencia asociada.

### ¿Para qué sirve en el proceso administrativo?
- Imprime dictámenes oficiales de anuncios
- Genera documentos de autorización de anuncios
- Produce documentos de negación de anuncios
- Incluye información completa del anuncio, licencia y giro
- Proporciona documento oficial para contribuyente
- Documenta la resolución administrativa sobre el anuncio

### ¿Quiénes lo utilizan?
- Personal de Padrón y Licencias
- Jefes del departamento que autorizan dictámenes
- Personal autorizado para emitir resoluciones
- Contribuyentes (reciben el dictamen impreso)

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?

1. **Inicio del módulo**
   - Usuario abre módulo de dictámenes
   - Sistema muestra interfaz de captura

2. **Selección de tipo de dictamen**
   - Usuario selecciona en RadioGroup1:
     - **Opción 0**: Dictamen de Autorización (tipo = 1)
     - **Opción 1**: Dictamen de Negación (tipo = 0)

3. **Captura de número de anuncio**
   - Usuario ingresa número de anuncio en Edit1
   - Este es el identificador del anuncio a dictaminar

4. **Generación del dictamen**
   - Usuario presiona botón "Imprimir" (Button1)

5. **Validación de número**
   - Sistema verifica que Edit1 no esté vacío
   - Si está vacío, no continúa

6. **Consulta de información**
   - Sistema cierra Query1 si estaba abierto
   - Ejecuta consulta compleja (Query1) con parámetro: ANUNCIO = número ingresado
   - Esta query une múltiples tablas:
     - Anuncios
     - Licencias
     - Giros

7. **Validación de existencia**
   - Sistema verifica si query devolvió resultados
   - Si no encuentra el anuncio, no imprime

8. **Selección de reporte**
   - Según tipo seleccionado (variable tipo):
     - **Si tipo = 0** (Negación): Imprime ppReport1
     - **Si tipo = 1** (Autorización): Imprime ppReport2

9. **Generación del documento**
   - Sistema genera reporte con:
     - Membrete institucional
     - Logotipo oficial
     - Información completa del anuncio
     - Datos de la licencia asociada
     - Información del giro comercial
     - Características técnicas del anuncio
     - Ubicación exacta
     - Datos del propietario
     - Fecha de emisión
     - Espacio para firmas

10. **Impresión**
    - Envía documento a impresora
    - Genera dictamen oficial

### ¿Qué información requiere el usuario?

**Datos obligatorios:**
- **Número de anuncio**: Identificador del anuncio publicitario
- **Tipo de dictamen**: Selección entre Autorización o Negación

### ¿Qué validaciones se realizan?

1. **Validación de número de anuncio**
   - Verifica que campo Edit1 no esté vacío
   - Si está vacío, no ejecuta impresión

2. **Validación de existencia**
   - Verifica que el anuncio exista en la base de datos
   - Solo imprime si encuentra datos

3. **Selección de tipo**
   - Variable tipo define qué reporte usar
   - RadioGroup controla la selección

### ¿Qué documentos genera?

#### DICTAMEN DE AUTORIZACIÓN (ppReport2)
Documento oficial que incluye:
- Membrete institucional con logotipos
- Título: Indica que es dictamen de autorización
- **Información del anuncio:**
  - Número de anuncio
  - Tipo de anuncio
  - Medidas (medidas1 x medidas2)
  - Área total del anuncio
  - Número de caras
  - Texto del anuncio
  - Ubicación exacta (calle, número exterior/interior, colonia)

- **Información de la licencia:**
  - Número de licencia asociada
  - Propietario del establecimiento
  - RFC y CURP
  - Domicilio del propietario
  - Teléfono y email
  - Giro comercial
  - Actividad autorizada
  - Superficie construida y autorizada
  - Número de cajones de estacionamiento
  - Número de empleados

- **Información del giro:**
  - Código del giro
  - Descripción del giro
  - Características
  - Clasificación
  - Tipo de giro

- **Datos administrativos:**
  - Fecha de otorgamiento de licencia
  - Fecha de consejo (si aplica)
  - Zona y subzona
  - Código postal
  - Número de página
  - Fecha de impresión
  - Espacios para firmas autorizadas

#### DICTAMEN DE NEGACIÓN (ppReport1)
Documento oficial similar al de autorización, pero:
- Encabezado indica que es dictamen de NEGACIÓN
- Incluye misma información técnica
- Formato adaptado para comunicar negación
- Incluye memos/campos para:
  - Fundamentos legales de la negación
  - Observaciones técnicas
  - Razones de la negación
  - Recomendaciones (si aplican)

## Tablas de Base de Datos

### Tablas que Consulta

1. **Query1** (consulta compleja que une):

   **a) Tabla anuncios**
   - id_anuncio
   - anuncio (número)
   - Información del anuncio publicitario:
     - medidas1, medidas2
     - area_anuncio
     - num_caras
     - ubicacion
     - numext_ubic, letraext_ubic
     - numint_ubic, letraint_ubic
     - colonia_ubic
     - texto_anuncio
     - id_fabricante
     - fecha_otorgamiento
     - vigente
     - espubic
     - fecha_baja
     - axo_baja, folio_baja
     - id_licencia (referencia)

   **b) Tabla licencias**
   - id_licencia
   - licencia (número)
   - Información del establecimiento:
     - propietario, primer_ap, segundo_ap
     - rfc, curp
     - domicilio
     - numext_prop, numint_prop
     - colonia_prop
     - telefono_prop, email
     - ubicacion (del negocio)
     - numext_ubic, letraext_ubic
     - numint_ubic, letraint_ubic
     - colonia_ubic
     - sup_construida, sup_autorizada
     - num_cajones, num_empleados
     - fecha_otorgamiento
     - fecha_consejo
     - actividad
     - zona, subzona
     - cp (código postal)
     - vigente
     - fecha_baja
     - espubic
     - id_giro (referencia)

   **c) Tabla giros**
   - id_giro
   - cod_giro
   - cod_anun
   - descripcion
   - caracteristicas
   - clasificacion
   - tipo

### Tablas que Modifica
**Ninguna**. Este módulo es de solo lectura e impresión.

## Stored Procedures
Este módulo no utiliza stored procedures. Realiza una consulta compleja mediante query con múltiples JOINs.

## Impacto y Repercusiones

### ¿Qué registros afecta?
Ninguno. Es un módulo de consulta e impresión.

### ¿Qué cambios de estado provoca?
Ninguno. No modifica registros en la base de datos.

### ¿Qué documentos/reportes genera?

1. **Dictamen de Autorización**
   - Documento oficial que autoriza el anuncio publicitario
   - Incluye toda la información técnica y legal
   - Base legal para instalación del anuncio
   - Debe entregarse al contribuyente

2. **Dictamen de Negación**
   - Documento oficial que niega el anuncio publicitario
   - Incluye fundamentación de la negación
   - Observaciones técnicas que impiden la autorización
   - Notificación formal al contribuyente

### ¿Qué validaciones de negocio aplica?

1. **Validación de anuncio existente**
   - Solo imprime si el anuncio está registrado
   - Requiere datos completos en base de datos

2. **Integridad de información**
   - Query une correctamente anuncios, licencias y giros
   - Asegura que toda la información esté disponible

## Flujo de Trabajo

```
INICIO
  ↓
Usuario selecciona tipo de dictamen:
  RadioGroup1:
  - Opción 0 = Negación (tipo = 1)
  - Opción 1 = Autorización (tipo = 0)
  ↓
Usuario ingresa número de anuncio en Edit1
  ↓
Presiona botón "Imprimir"
  ↓
¿Edit1 vacío? → SÍ → No hacer nada, FIN
  ↓ NO
Cerrar Query1 (si estaba abierto)
  ↓
Establecer parámetro:
  Query1.ParamByName('ANUNCIO') = número ingresado
  ↓
Abrir Query1
  (consulta compleja: anuncios + licencias + giros)
  ↓
¿Query1.EOF? → SÍ → No hay datos, FIN
  ↓ NO
Evaluar tipo de dictamen:
  ↓
¿tipo = 0? → SÍ → Imprimir ppReport1 (Negación)
  ↓ NO
Imprimir ppReport2 (Autorización)
  ↓
FIN
```

## Notas Importantes

### Consideraciones especiales

1. **Dos tipos de dictamen**
   - Autorización: Aprueba instalación del anuncio
   - Negación: Rechaza el anuncio con fundamento

2. **Información completa**
   - Incluye datos del anuncio, licencia y giro
   - Documento autosuficiente con toda la información necesaria

3. **Query compleja**
   - Une tres tablas principales
   - Más de 100 campos de información
   - Asegura integridad de datos

4. **Documento oficial**
   - Lleva membrete institucional
   - Incluye logotipos oficiales
   - Es base legal para instalación o negación

### Restricciones

1. **Solo impresión**
   - No permite modificar datos del anuncio
   - No cambia estado del anuncio
   - Solo genera documento

2. **Requiere anuncio registrado**
   - El anuncio debe existir en base de datos
   - Debe tener licencia asociada
   - Licencia debe tener giro asignado

3. **No guarda historial de impresiones**
   - No registra cuántas veces se imprimió
   - No guarda quién imprimió

### Permisos necesarios

- Acceso al módulo de Padrón y Licencias
- Permisos para imprimir dictámenes
- Acceso de lectura a tablas:
  - anuncios
  - licencias
  - giros

### Recomendaciones de uso

1. **Antes de imprimir**
   - Verificar que el número de anuncio sea correcto
   - Seleccionar el tipo correcto de dictamen
   - Confirmar que la impresora esté lista
   - Revisar que haya papel membretado disponible

2. **Dictamen de Autorización**
   - Verificar que todos los requisitos estén cumplidos
   - Confirmar que inspecciones fueron favorables
   - Validar que no existan observaciones pendientes
   - Asegurar que documentación esté completa

3. **Dictamen de Negación**
   - Verificar fundamento legal de la negación
   - Documentar claramente las razones
   - Incluir observaciones técnicas específicas
   - Preparar notificación al contribuyente

4. **Después de imprimir**
   - Revisar documento impreso
   - Verificar que información sea correcta
   - Obtener firmas autorizadas
   - Entregar copia al contribuyente
   - Archivar copia en expediente

5. **Control de calidad**
   - Validar que datos del anuncio coincidan con inspección
   - Verificar que licencia esté vigente
   - Confirmar que ubicación sea correcta
   - Validar que medidas del anuncio sean las autorizadas

### Información crítica en el dictamen

**Del Anuncio:**
- Número identificador
- Medidas exactas
- Área total
- Ubicación precisa
- Texto que contendrá

**De la Licencia:**
- Número de licencia madre
- Nombre del propietario
- Giro autorizado
- Ubicación del establecimiento

**Técnica:**
- Número de caras del anuncio
- Tipo de anuncio
- Fabricante (si aplica)
- Características especiales

**Administrativa:**
- Fecha de otorgamiento
- Código postal
- Zona y subzona
- Vigencia
