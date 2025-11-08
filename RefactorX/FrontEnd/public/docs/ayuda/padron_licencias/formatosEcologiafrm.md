# Formatos de Ecologia para Tramites

## Descripcion General

### Que hace este modulo
El modulo de Formatos de Ecologia genera documentos oficiales relacionados con tramites ambientales y de verificacion ecologica para licencias comerciales. Permite imprimir certificados, constancias y formatos requeridos por las autoridades ambientales municipales.

### Para que sirve en el proceso administrativo
Este modulo sirve para:
- Generar Certificados de Anuncio Estandar (Verificacion Tecnica)
- Emitir Certificados de Anuencia para tramites ambientales
- Imprimir formatos oficiales con datos del tramite y contribuyente
- Documentar cumplimiento de requisitos ecologicos
- Proporcionar documentacion legal para establecimientos
- Facilitar inspecciones ambientales con documentacion adecuada

### Quienes lo utilizan
- Personal de Ecologia y Medio Ambiente
- Inspectores ambientales
- Personal de Ventanilla Unica que entrega tramites
- Verificadores tecnicos
- Supervisores del area ambiental
- Personal que atiende solicitudes de anuencias

## Proceso Administrativo

### Como funciona el proceso paso a paso

**Generacion de Formatos:**

1. **Seleccion del Tramite:**
   - El usuario puede buscar por ID de tramite (captura numero y presiona Enter)
   - O buscar por fecha de captura (selecciona fecha y presiona Enter)
   - El sistema carga los datos del tramite encontrado

2. **Visualizacion de Datos:**
   - Se muestra grid con datos del tramite
   - Propietario y datos generales
   - Ubicacion del establecimiento
   - Giro o actividad solicitada
   - Datos tecnicos (superficies, aforos, etc.)

3. **Seleccion de Formato:**
   - El usuario elige en RadioGroup:
     - Opcion 0: Verificacion Tecnica (Certificado Anuncio Estandar)
     - Opcion 1: Certificado de Anuencia

4. **Impresion:**
   - Usuario presiona boton "Imprimir"
   - Sistema genera formato seleccionado
   - Incluye datos del contribuyente, ubicacion y caracteristicas del tramite
   - Formato incluye logo institucional y datos oficiales

### Que informacion requiere el usuario

**Datos de Busqueda (uno u otro):**
- **ID de Tramite:** Numero unico del tramite a imprimir
- **Fecha de Captura:** Fecha en que se registro el tramite

**Informacion que se Imprime:**
- Folio del tramite
- Nombre completo del propietario/solicitante
- RFC del contribuyente
- Domicilio del propietario
- Ubicacion del establecimiento (calle, numero, colonia, CP)
- Cruces de calles cercanas
- Giro o actividad comercial
- Superficie construida y autorizada
- Numero de empleados
- Aforo del establecimiento
- Zona y subzona
- Datos del tramite (fecha, tipo)

### Que validaciones se realizan

1. **Validacion de Tramite:**
   - Verifica que el tramite exista en la base de datos
   - Valida que tenga datos completos para impresion
   - Cruza informacion con tabla de cuentas para completar datos

2. **Datos del Contribuyente:**
   - Concatena apellidos y nombre correctamente
   - Maneja valores nulos en apellidos
   - Formatea domicilio completo con todos sus componentes

3. **Cruces de Calles:**
   - Consulta tabla de cruces de calles asociados al tramite
   - Incluye hasta dos cruces principales en el formato
   - Valida que existan cruces registrados

4. **Habilitacion de Impresion:**
   - Solo habilita boton de impresion si hay un tramite cargado
   - Deshabilita si no se encuentra el tramite buscado

### Que documentos genera

1. **Verificacion Tecnica (RepVerifTec):**
   - Certificado de Anuncio Estandar
   - Incluye datos tecnicos del establecimiento
   - Informacion de ubicacion y caracteristicas
   - Firma y sellos oficiales

2. **Certificado de Anuencia (RepVerifTecCertAnuen):**
   - Documento de anuencia para tramites ambientales
   - Autoriza el giro o actividad desde perspectiva ecologica
   - Incluye restricciones o condicionantes si aplican
   - Formato oficial con validez legal

Ambos formatos incluyen:
- Logo del municipio
- Encabezado oficial
- Datos completos del solicitante
- Informacion del establecimiento
- Ubicacion georeferenciada
- Cruces de calles
- Fecha de emision
- Numero de folio para control

## Tablas de Base de Datos

### Tabla Principal
- **tramites:** Contiene toda la informacion de solicitudes y tramites de licencias, incluyendo datos del solicitante, ubicacion, giro, y caracteristicas del establecimiento

### Tablas Relacionadas

**Tablas que Consulta:**
- **tramites:** Datos principales del tramite
- **convcta (conversion de cuentas):** Para obtener datos adicionales del contribuyente
- **QryCruceCalles (cruces de calles):** Para incluir referencias de ubicacion
- **c_giros:** Para obtener descripcion completa del giro (implicitamente)

**Tablas que Modifica:**
- **Ninguna:** Este modulo solo consulta informacion para impresion, no modifica datos

## Stored Procedures
- **Ninguno:** No ejecuta procedimientos almacenados, solo consultas de lectura

## Impacto y Repercusiones

### Que registros afecta
- **Ningun registro es modificado**
- Es un modulo de consulta e impresion unicamente
- No altera el estado de tramites ni contribuyentes

### Que cambios de estado provoca
- **No provoca cambios de estado**
- Los tramites mantienen su estatus original
- La impresion no marca el tramite como "impreso" o "entregado"

### Que documentos/reportes genera
- Certificados oficiales con valor legal
- Formatos para expedientes administrativos
- Documentacion requerida por otras dependencias
- Comprobantes de cumplimiento ambiental

### Que validaciones de negocio aplica

1. **Existencia del Tramite:**
   - Valida que el ID o fecha corresponda a tramites existentes
   - No permite imprimir si no hay datos

2. **Integridad de Datos:**
   - Verifica que los datos del contribuyente esten completos
   - Valida que la ubicacion este registrada
   - Asegura que el giro este especificado

3. **Formato de Documentos:**
   - Genera documentos con formato oficial estandarizado
   - Incluye todos los elementos requeridos por normativa
   - Mantiene consistencia en la presentacion

## Flujo de Trabajo

### Descripcion del flujo completo del proceso

**Flujo de Impresion por ID de Tramite:**
```
1. Usuario abre modulo de Formatos de Ecologia
2. Usuario captura ID del tramite en campo numerico
3. Usuario presiona Enter
4. Sistema cierra consultas abiertas
5. Sistema construye query con ID del tramite
6. Sistema ejecuta consulta a tabla tramites
7. Sistema carga tabla de conversion de cuentas
8. Sistema verifica si hay registros
9. Si hay datos:
   - Habilita boton de impresion
   - Muestra datos en grid
   - Carga informacion en controles
10. Si no hay datos:
    - Deshabilita boton de impresion
    - Muestra mensaje indicando que no se encontro
11. Usuario selecciona tipo de formato en RadioGroup
12. Usuario presiona "Imprimir"
13. Sistema genera reporte seleccionado
14. Sistema consulta cruces de calles
15. Sistema envia a impresora o vista previa
```

**Flujo de Impresion por Fecha:**
```
1. Usuario abre modulo de Formatos de Ecologia
2. Usuario captura o selecciona fecha en DateEdit
3. Usuario presiona Enter o cambia de campo
4. Sistema valida que la fecha este completa
5. Sistema construye query filtrando por fecha de captura
6. Sistema ejecuta consulta
7. Sistema muestra todos los tramites de esa fecha
8. Usuario selecciona tramite del grid
9. Usuario elige tipo de formato
10. Usuario presiona "Imprimir"
11. Sistema genera reporte con datos del tramite seleccionado
```

## Notas Importantes

### Consideraciones especiales

1. **Multiples Formatos desde un Modulo:**
   - Un solo modulo maneja dos tipos de certificados diferentes
   - Facilita la operacion al tener todo centralizado
   - Reduce duplicidad de codigo

2. **Concatenacion de Nombres:**
   - El sistema construye el nombre completo inteligentemente
   - Maneja casos donde falten apellidos
   - Usa funciones nvl() para evitar valores nulos
   - Formato: "Primer Apellido Segundo Apellido Nombre"

3. **Domicilio Completo:**
   - Se construye domicilio con todos sus componentes
   - Formato: "Calle No.Ext: XXX - Letra Ext No.Int: YYY - Letra Int CP: 12345"
   - Facilita identificacion precisa del establecimiento

4. **Cruces de Calles:**
   - Se consultan dinamicamente al generar el reporte
   - Se cargan en el evento BeforeGenerate del reporte
   - Proporcionan referencia geografica adicional

5. **Fecha de Consulta Flexible:**
   - Permite buscar por fecha exacta
   - O buscar tramites en un rango (aunque la interfaz solo muestra un campo)
   - Facilita localizar tramites cuando no se tiene el ID

### Restricciones

1. **Solo Lectura:**
   - No permite modificar datos del tramite
   - Si hay errores, deben corregirse en el modulo de tramites

2. **Dependencia de Datos:**
   - Requiere que el tramite este completamente capturado
   - Si faltan datos, el formato puede verse incompleto

3. **Un Tramite a la Vez:**
   - Solo puede imprimir un tramite por operacion
   - No permite impresion masiva o por lote

### Permisos necesarios

- **Consulta de Tramites:** Permisos de lectura en tabla de tramites
- **Consulta de Contribuyentes:** Permisos en tabla de cuentas
- **Generacion de Reportes:** Acceso al motor de reportes
- **Impresion:** Permisos de impresion en el sistema

### Integracion con otros modulos

**Modulos Relacionados:**
- **Modulo de Tramites:** Origen de los datos que se imprimen
- **Modulo de Licencias:** Los tramites pueden estar vinculados a licencias
- **Modulo de Inspeccion:** Los certificados pueden requerirse para inspecciones
- **Ventanilla Unica:** Donde se entregan estos documentos al contribuyente

### Uso en el Proceso Global

1. **Inicio del Tramite:** El contribuyente solicita licencia o permiso
2. **Captura en Sistema:** Se registra en modulo de tramites
3. **Verificacion:** Personal revisa cumplimiento de requisitos
4. **Generacion de Certificado:** Se usa este modulo para imprimir formato
5. **Entrega:** El documento se entrega al contribuyente
6. **Archivo:** Una copia queda en expediente administrativo

### Importancia Legal

- Los documentos generados tienen validez oficial
- Forman parte del expediente del tramite
- Pueden ser requeridos por autoridades ambientales
- Sirven como comprobante de cumplimiento normativo
- Deben conservarse segun los plazos legales establecidos
