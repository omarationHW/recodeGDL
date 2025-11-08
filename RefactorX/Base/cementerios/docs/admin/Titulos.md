# Títulos - Impresión de Títulos de Propiedad

## Propósito Administrativo
Módulo para generar e imprimir los títulos de propiedad oficiales de espacios funerarios, documento legal que acredita la concesión a perpetuidad del terreno en el cementerio municipal.

## Funcionalidad Principal
Permite la impresión formal de títulos de propiedad de fosas, urnas y gavetas, incorporando todos los datos legales necesarios, información del beneficiario, datos del pago inicial, y el formato oficial del Ayuntamiento.

## Proceso de Negocio

### ¿Qué hace?
Administra la emisión de títulos de propiedad:
- Impresión de títulos por primera vez (pago de ingreso)
- Reimpresión de títulos (duplicados)
- Títulos de cesión de derechos
- Títulos preventivos
- Registro de datos del beneficiario en el título
- Control de libro, año y folio del título emitido
- Impresión en diferentes formatos según recaudadora

### ¿Para qué sirve?
Formaliza legalmente la concesión del espacio funerario:
- Documento oficial que acredita derecho de uso a perpetuidad
- Especifica ubicación exacta del espacio
- Registra datos completos del beneficiario
- Documenta pago inicial realizado
- Base para trámites de cesión o herencia
- Cumplimiento de obligaciones legales municipales

### ¿Cómo lo hace?
1. El operador captura: fecha, folio RCM y número de operación del pago
2. El sistema verifica que exista un pago de título registrado
3. Permite capturar/actualizar datos del beneficiario:
   - Nombre completo
   - Domicilio completo
   - Teléfono
   - Número de libro, año y folio del título
   - Partida catastral (opcional)
4. Consulta datos almacenados si el título ya fue impreso previamente
5. Genera el título en formato oficial con:
   - Escudo del Ayuntamiento
   - Datos completos del espacio (clase, sección, línea, fosa)
   - Metros cuadrados
   - Nombre y domicilio del beneficiario
   - Información del pago (fecha, caja, operación)
   - Libro, año y folio del título
   - Texto legal de concesión
   - Observaciones del pago
   - Firmas autorizadas
6. Imprime en formato correspondiente a la recaudadora
7. Actualiza la base de datos con información del título emitido

### ¿Qué necesita para funcionar?
- Pago de título registrado en ta_13_pagosrcm (tipo 4 o 5)
- Folio RCM válido con datos completos del espacio
- Datos del beneficiario (pueden capturarse en el momento)
- Formatos de impresión configurados
- Permisos para imprimir títulos

## Datos y Tablas

### Tabla Principal
**ta_13_pagosrcm** - Pagos de títulos registrados (tipo 4=Inhumación con título, 5=Título sin inhumación)

### Tablas Relacionadas
- **ta_13_datosrcm** - Información completa del espacio funerario
- **ta_13_datosrcmadic** - Datos fiscales del concesionario
- **ta_13_titulosrcm** - Registro de títulos emitidos con datos del beneficiario
- **ta_cementerios** - Información de cada cementerio
- **ta_recaudadoras** - Datos de la recaudadora emisora

### Stored Procedures (SP)
- **StoredProc1** - Actualiza información del título emitido
  - par_control: Folio RCM
  - par_tit: Número de título
  - par_fecha: Fecha de impresión
  - par_libro: Número de libro
  - par_axo: Año del título
  - par_folio: Folio del título
  - par_nombre: Nombre del beneficiario
  - par_dom: Domicilio del beneficiario
  - par_col: Colonia
  - par_tel: Teléfono
  - par_part: Partida catastral
  - Retorna: par_ok, sobserv

### Tablas que Afecta
**Inserta/Actualiza:**
- ta_13_titulosrcm (información del título emitido)

**Consulta:**
- ta_13_datosrcm
- ta_13_pagosrcm
- ta_13_datosrcmadic
- ta_cementerios
- ta_recaudadoras

## Impacto y Repercusiones

### Repercusiones Operativas
- Formaliza la entrega del espacio al concesionario
- Documento oficial para trámites posteriores
- Control de títulos emitidos
- Trazabilidad de beneficiarios registrados

### Repercusiones Financieras
- Documentación del ingreso por venta de concesión
- Sustenta cobro de derechos funerarios
- Base para auditorías financieras
- Comprobante de pago para el contribuyente

### Repercusiones Administrativas
- Cumplimiento de normativa municipal
- Documento legal de concesión
- Control de folios de títulos emitidos
- Registro en libros oficiales del Ayuntamiento
- Base para trámites de cesión, herencia, traslados

## Validaciones y Controles
- Verifica existencia del pago de título
- Valida que el folio RCM exista y esté activo
- Requiere datos mínimos del beneficiario
- Convierte números a texto para importes y ubicación
- Maneja diferentes formatos según tipo de título
- Genera números de control únicos
- Control de libro, año y folio consecutivos
- Valida que el pago corresponda a la fecha indicada

## Casos de Uso
1. **Título por primera compra**: Cliente adquiere espacio y recibe título original
2. **Título por cesión**: Se emite nuevo título al nuevo beneficiario tras cesión de derechos
3. **Duplicado de título**: Reimpresión por extravío del original
4. **Título preventivo**: Emisión anticipada de título
5. **Actualización de beneficiario**: Cambio de nombre en título por corrección
6. **Impresión masiva**: Procesamiento de múltiples títulos pendientes

## Usuarios del Sistema
- **Personal de Títulos**: Emisión y control de títulos
- **Jefe de Oficina**: Autorización y firma de títulos
- **Archivo**: Registro en libros oficiales
- **Ventanilla**: Entrega de títulos a beneficiarios

## Relaciones con Otros Módulos
- **ABCementer**: Los espacios deben estar registrados previamente
- **ABCPagos**: Requiere pago de título registrado
- **Duplicados**: Módulo específico para reimpresión de títulos
- **Traslados**: Título se actualiza cuando hay traslado de restos
- **ConIndividual**: Consulta muestra si ya se emitió título
- **Sistema de Ingresos**: Valida pago de título registrado
