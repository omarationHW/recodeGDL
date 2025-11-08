# Gestión de Responsivas y Supervisiones

## Descripción General

### ¿Qué hace este módulo?
Este módulo administra el registro, consulta, modificación, cancelación e impresión de Responsivas y Supervisiones relacionadas con licencias comerciales. Las responsivas y supervisiones son documentos oficiales que certifican la conformidad de establecimientos con las regulaciones municipales.

### ¿Para qué sirve en el proceso administrativo?
- Genera folios consecutivos para responsivas y supervisiones
- Documenta las visitas de inspección realizadas a establecimientos
- Proporciona certificación oficial de cumplimiento normativo
- Permite el seguimiento histórico de inspecciones
- Facilita la búsqueda y consulta de documentos emitidos
- Genera reportes impresos oficiales

### ¿Quiénes lo utilizan?
- Inspectores municipales
- Personal de Padrón y Licencias
- Supervisores de área
- Jefes de departamento
- Personal administrativo autorizado
- Contribuyentes (reciben el documento impreso)

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?

#### PROCESO DE NUEVA RESPONSIVA/SUPERVISIÓN

1. **Inicio del proceso**
   - Usuario presiona botón "Nueva"
   - Sistema muestra panel de captura
   - Deshabilita botones de consulta

2. **Búsqueda de licencia**
   - Usuario ingresa número de licencia
   - Presiona botón "Buscar" o ENTER
   - Sistema busca y muestra datos del titular y establecimiento

3. **Selección de tipo**
   - Usuario selecciona mediante RadioGroup:
     - Responsiva (tipo 'R')
     - Supervisión (tipo 'S')

4. **Generación de folio**
   - Sistema consulta tabla de parámetros
   - Obtiene último folio utilizado según tipo
   - Incrementa el folio en 1
   - Actualiza el parámetro con el nuevo folio

5. **Registro de documento**
   - Inserta nuevo registro en tabla "responsivas"
   - Guarda datos:
     - ID de licencia
     - Año actual
     - Folio generado
     - Tipo (R o S)
     - Estado: Vigente ('V')
     - Fecha y usuario que captura

6. **Impresión automática**
   - Genera reporte con datos de licencia y giro
   - Encabezado según tipo: "RESPONSIVA" o "SUPERVISIÓN"
   - Envía a impresión automáticamente

#### PROCESO DE CONSULTA Y BÚSQUEDA

1. **Búsqueda por año y folio**
   - Usuario ingresa año (4 dígitos)
   - Ingresa folio (número consecutivo)
   - Presiona botón "Buscar"
   - Sistema filtra y muestra resultados

2. **Búsqueda por número de licencia**
   - Usuario ingresa número de licencia
   - Sistema busca todas las responsivas/supervisiones de esa licencia
   - Muestra resultados ordenados por año y folio descendente

3. **Visualización en grid**
   - Muestra listado de documentos
   - Permite búsqueda rápida haciendo clic en encabezados de columna
   - Filtra automáticamente por tipo seleccionado (R o S)

#### PROCESO DE REIMPRESIÓN

1. **Selección de documento**
   - Usuario selecciona un registro del grid
   - Presiona botón "Imprimir"

2. **Validación de estado**
   - Sistema verifica si está cancelado
   - Si está cancelado, muestra mensaje: "Responsiva/Supervisión cancelada, no se podrá imprimir"
   - Si está vigente, permite la impresión

3. **Generación de impresión**
   - Consulta datos actuales de la licencia
   - Obtiene información del giro
   - Genera reporte con formato oficial
   - Envía a impresora

#### PROCESO DE CANCELACIÓN

1. **Selección para cancelar**
   - Usuario selecciona responsiva/supervisión del grid
   - Presiona botón "Cancelar Responsiva"

2. **Confirmación**
   - Sistema muestra mensaje: "¿Estás seguro de cancelar la responsiva AÑO/FOLIO?"
   - Usuario confirma (Sí/No)

3. **Captura de motivo**
   - Sistema solicita motivo de cancelación mediante InputBox
   - Usuario captura justificación

4. **Actualización de registro**
   - Cambia estado de 'V' (Vigente) a 'C' (Cancelado)
   - Guarda el motivo en campo "observación"
   - Registra cambio permanentemente

### ¿Qué información requiere el usuario?

#### Para crear nueva responsiva/supervisión:
- **Número de licencia** (obligatorio): Identificador de la licencia a inspeccionar
- **Tipo de documento** (obligatorio): Selección entre Responsiva o Supervisión

#### Para buscar:
- **Opción 1 - Por folio**:
  - Año (4 dígitos)
  - Folio (número consecutivo)
- **Opción 2 - Por licencia**:
  - Número de licencia

#### Para cancelar:
- **Motivo de cancelación** (obligatorio): Justificación de por qué se cancela el documento

### ¿Qué validaciones se realizan?

1. **Validación de licencia existente**
   - Verifica que el número de licencia exista en el sistema
   - Muestra mensaje si no se encuentra

2. **Validación de estado para impresión**
   - Bloquea impresión de documentos cancelados
   - Solo permite imprimir documentos vigentes

3. **Validación de datos de búsqueda**
   - Si busca por año/folio, requiere ambos campos
   - Muestra mensaje: "Debes indicar año y folio"

4. **Confirmación de cancelación**
   - Solicita confirmación explícita antes de cancelar
   - Requiere motivo obligatorio

5. **Generación de folio consecutivo**
   - Obtiene automáticamente el siguiente folio disponible
   - Actualiza parámetros para mantener secuencia

### ¿Qué documentos genera?

1. **Responsiva oficial**
   - Documento con formato oficial
   - Membrete institucional
   - Año y folio consecutivo
   - Datos completos del titular
   - Información del giro comercial
   - Datos del establecimiento (ubicación)
   - Fecha de emisión
   - Campo para firma del inspector

2. **Supervisión oficial**
   - Mismo formato que responsiva
   - Encabezado diferente: "SUPERVISIÓN"
   - Todos los elementos de la responsiva

## Tablas de Base de Datos

### Tabla Principal
**responsivas**
- Almacena el registro de todas las responsivas y supervisiones emitidas
- Campos principales:
  - axo: Año de emisión
  - folio: Número consecutivo
  - id_licencia: Referencia a la licencia inspeccionada
  - tipo: 'R' (Responsiva) o 'S' (Supervisión)
  - vigente: 'V' (Vigente) o 'C' (Cancelado)
  - observacion: Motivo de cancelación o notas
  - feccap: Fecha de captura
  - capturista: Usuario que registró

### Tablas Relacionadas

#### Tablas que Consulta:
- **licencias**: Obtiene datos completos del titular y establecimiento
- **giros**: Consulta información del giro comercial de la licencia
- **parametros**: Obtiene folios consecutivos (campos: responsiva, supervision)
- **pagos**: Información de pagos asociados a la licencia
- **BuscaLicencia** (query): Búsqueda rápida de licencias por número

#### Tablas que Modifica:
- **responsivas**:
  - INSERT: Al crear nueva responsiva/supervisión
  - UPDATE: Al cancelar documento (cambia vigente a 'C', guarda observación)
- **parametros**:
  - UPDATE: Incrementa el folio consecutivo (responsiva o supervision) cada vez que se genera un nuevo documento

## Stored Procedures
Este módulo no utiliza stored procedures directamente. Realiza las operaciones mediante queries SQL directas.

## Impacto y Repercusiones

### ¿Qué registros afecta?

1. **Tabla responsivas**
   - Inserta nuevo registro por cada responsiva/supervisión generada
   - Actualiza estado (vigente/cancelado) de documentos existentes
   - Modifica campo observación al cancelar

2. **Tabla parametros**
   - Incrementa contador de folios consecutivos
   - Mantiene dos contadores independientes: uno para responsivas y otro para supervisiones

### ¿Qué cambios de estado provoca?

1. **Estado de documentos**
   - Crea documentos con estado 'V' (Vigente)
   - Puede cambiar a 'C' (Cancelado) mediante proceso de cancelación
   - Estado cancelado es permanente (no reversible)

2. **Secuencia de folios**
   - Cada documento generado incrementa el folio consecutivo
   - Los folios son únicos por año y tipo

### ¿Qué documentos/reportes genera?

1. **Responsiva impresa**
   - Formato oficial con membrete
   - Información completa del establecimiento
   - Datos del titular de la licencia
   - Giro comercial autorizado
   - Año y folio para control
   - Fecha de emisión

2. **Supervisión impresa**
   - Mismo formato que responsiva
   - Encabezado identifica como "SUPERVISIÓN"
   - Utiliza numeración independiente de responsivas

### ¿Qué validaciones de negocio aplica?

1. **Integridad de folios**
   - Garantiza folios consecutivos sin saltos
   - Mantiene secuencias independientes por tipo

2. **Trazabilidad**
   - Registra usuario y fecha de captura
   - Guarda motivo al cancelar

3. **Protección de documentos cancelados**
   - Impide impresión de documentos cancelados
   - Mantiene historial completo

4. **Validación de licencias**
   - Solo permite generar documentos para licencias existentes y válidas

## Flujo de Trabajo

### Flujo de creación de nueva responsiva/supervisión

```
INICIO
  ↓
Clic en botón "Nueva"
  ↓
Mostrar panel de captura
  ↓
Seleccionar tipo (Responsiva/Supervisión)
  ↓
Ingresar número de licencia
  ↓
Clic en "Buscar"
  ↓
¿Existe licencia? → NO → Mostrar error y retornar
  ↓ SÍ
Mostrar datos de licencia
  ↓
Clic en "Aceptar"
  ↓
Consultar tabla parametros
  ↓
Obtener último folio según tipo
  ↓
Incrementar folio + 1
  ↓
Actualizar parametros con nuevo folio
  ↓
Insertar registro en tabla responsivas
  ↓
Cargar datos de licencia y giro
  ↓
Generar reporte impreso
  ↓
Imprimir automáticamente
  ↓
Ocultar panel de captura
  ↓
Habilitar botones de consulta
  ↓
FIN
```

### Flujo de cancelación

```
INICIO
  ↓
Seleccionar documento del grid
  ↓
Clic en "Cancelar Responsiva"
  ↓
Mostrar confirmación
  ↓
¿Usuario confirma? → NO → Cancelar operación
  ↓ SÍ                     ↓
Mostrar ventana para capturar motivo
  ↓
Ingresar justificación
  ↓
Editar registro en tabla responsivas
  ↓
Cambiar vigente = 'C'
  ↓
Guardar motivo en observacion
  ↓
Confirmar cambios
  ↓
FIN
```

### Flujo de búsqueda y reimpresión

```
INICIO
  ↓
Seleccionar método de búsqueda
  ↓
┌──────────────┬──────────────┐
│ Por Año/Folio│ Por Licencia │
└──────────────┴──────────────┘
       ↓                ↓
  Capturar año    Capturar número
  y folio         de licencia
       ↓                ↓
  └────────┬───────────┘
           ↓
     Clic en "Buscar"
           ↓
     Ejecutar consulta filtrada
           ↓
     Mostrar resultados en grid
           ↓
     Seleccionar registro
           ↓
     Clic en "Imprimir"
           ↓
     ¿Está cancelado? → SÍ → Mostrar error
           ↓ NO
     Cargar datos actuales
           ↓
     Generar reporte
           ↓
     Enviar a impresora
           ↓
     FIN
```

## Notas Importantes

### Consideraciones especiales

1. **Folios independientes**
   - Responsivas y supervisiones tienen numeración independiente
   - Cada tipo mantiene su propia secuencia consecutiva

2. **Impresión automática**
   - Al crear un nuevo documento, se imprime automáticamente
   - No requiere paso adicional de impresión

3. **Datos dinámicos en impresión**
   - Al reimprimir, se obtienen los datos actuales de la licencia
   - Permite reflejar cambios recientes en información del titular

4. **Histórico completo**
   - Los documentos cancelados permanecen en el sistema
   - No se eliminan físicamente, solo cambian de estado

5. **Búsqueda flexible**
   - Permite búsqueda por año/folio o por número de licencia
   - Búsqueda rápida en grid mediante clic en columnas

### Restricciones

1. **Documentos cancelados**
   - No se pueden reimprimir
   - No se pueden reactivar
   - Permanecen en historial para auditoría

2. **Folios consecutivos**
   - No se pueden editar manualmente
   - Son generados automáticamente por el sistema
   - No se pueden saltar números

3. **Modificación limitada**
   - Una vez creado, solo se puede cancelar
   - No se permite editar datos del documento
   - Datos provienen de la licencia asociada

### Permisos necesarios

- Acceso al módulo de Padrón y Licencias
- Permisos para:
  - Crear nuevas responsivas/supervisiones
  - Consultar historial
  - Imprimir documentos
  - Cancelar documentos (puede requerir nivel especial)
- Acceso de lectura a tablas:
  - responsivas
  - licencias
  - giros
  - parametros
  - pagos
- Acceso de escritura a tablas:
  - responsivas
  - parametros

### Recomendaciones de uso

1. **Antes de crear documento**
   - Verificar que el número de licencia sea correcto
   - Confirmar el tipo de documento a generar (R o S)
   - Asegurar que la impresora esté lista

2. **Al cancelar**
   - Capturar motivo claro y completo
   - Verificar dos veces antes de confirmar
   - Recordar que la cancelación es irreversible

3. **Para búsquedas**
   - Usar búsqueda por licencia para ver historial completo
   - Usar búsqueda por año/folio para localizar documento específico

4. **Control de calidad**
   - Revisar documento impreso antes de entregarlo
   - Verificar que los datos sean correctos
   - Conservar copia para archivo

5. **Gestión de folios**
   - Los folios se reinician cada año automáticamente
   - No intentar corregir folios manualmente en base de datos
   - Reportar inconsecuencias al área de sistemas
