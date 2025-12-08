# Registro de Solicitudes de Licencias y Anuncios

## Descripción General

### ¿Qué hace este módulo?
Este es uno de los módulos más críticos del sistema. Permite registrar nuevas solicitudes (trámites) de licencias de funcionamiento y anuncios publicitarios. Es el punto de entrada para que los contribuyentes inicien el proceso de obtención de una licencia o anuncio.

### ¿Para qué sirve en el proceso administrativo?
Sirve para:
- Capturar solicitudes de nuevas licencias de funcionamiento
- Registrar trámites de anuncios publicitarios
- Asignar folio de trámite consecutivo
- Capturar todos los datos del solicitante y establecimiento
- Generar fichas de trámite para revisión
- Imprimir dictámenes y formatos informativos
- Registrar documentos presentados
- Iniciar el proceso de revisión y dictamen
- Asociar inspecciones de dependencias (si aplican)
- Registrar parentescos (en caso de licencias de alcohol)
- Verificar adeudos de la licencia o cuenta predial asociada

### ¿Quiénes lo utilizan?
- Personal de ventanilla (uso principal)
- Capturistas del área de Licencias
- Personal de atención ciudadana
- Supervisores que validan solicitudes

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?

#### Registro de Nueva Solicitud de Licencia:
1. Usuario hace clic en "Agregar"
2. Sistema genera folio consecutivo automáticamente
3. Usuario selecciona tipo de trámite (Licencia/Anuncio)
4. **Captura de datos del propietario**:
   - Primer apellido, segundo apellido, nombres
   - RFC y CURP
   - Email y teléfono
5. **Captura domicilio fiscal del propietario**:
   - Calle, número exterior/interior
   - Colonia y código postal
6. **Captura ubicación del establecimiento**:
   - Búsqueda de calle en catálogo
   - Número exterior/interior con letras
   - Búsqueda de colonia
   - Código postal
   - El sistema asigna automáticamente zona y subzona
7. **Selección de giro y actividad**:
   - Búsqueda de giro SCIAN
   - Selección de actividad específica dentro del giro
8. **Captura datos del establecimiento**:
   - Recaudación y UR
   - Cuenta predial (opcional, con búsqueda)
   - Superficie construida y autorizada
   - Número de cajones de estacionamiento
   - Número de empleados
   - Aforo
   - Inversión
   - Horario de atención
9. **Verificación de adeudos**:
   - Si hay cuenta predial, se consultan adeudos
   - Si hay licencia de referencia, se consultan saldos
10. **Opciones especiales** (según aplique):
    - Autoevaluación (checkbox)
    - Pago de solicitud (checkbox)
    - Giro restringido (checkbox)
    - Pacto de permanencia (checkbox)
11. **Registro de parentesco** (para alcohol):
    - Si aplica, registrar familiares del titular
12. **Captura de ubicación en mapa** (opcional):
    - Selección de coordenadas geográficas mediante mapa web
13. **Captura de cruces de calles**:
    - Entre qué calles se ubica el establecimiento
14. **Inspecciones de dependencias**:
    - Sistema determina automáticamente qué dependencias deben revisar según el giro
    - Se agregan automáticamente las revisiones necesarias
15. Usuario hace clic en "Aceptar"
16. Sistema valida todos los campos obligatorios
17. Sistema guarda el trámite en la base de datos
18. Se asigna el folio definitivo
19. Sistema genera revisiones para dependencias que deben dictaminar
20. Sistema permite imprimir:
    - Ficha de trámite
    - Formato de uso de suelo
    - Dictamen de microgeneradores (si aplica)
21. El trámite queda registrado con estatus "En proceso"

#### Registro de Solicitud de Anuncio:
1. Usuario hace clic en "Agregar"
2. Selecciona "Anuncio" en RadioGroup
3. Captura datos similares a licencia más:
   - Tipo de anuncio (giro)
   - Fabricante
   - Texto del anuncio
   - Medidas (alto × ancho)
   - Número de caras
   - Especificaciones técnicas
4. El proceso de guardado es similar

### ¿Qué información requiere el usuario?

#### Datos Obligatorios para Licencia:
**Del Propietario:**
- Primer apellido
- Nombre(s)
- RFC (formato válido)
- CURP (formato válido)
- Teléfono
- Email

**Ubicación del Negocio:**
- Calle (del catálogo)
- Número exterior
- Colonia (del catálogo)
- Código postal

**Del Establecimiento:**
- Giro SCIAN
- Actividad específica
- Recaudación
- UR
- Superficie construida
- Número de empleados

#### Datos Opcionales:
- Segundo apellido
- Cuenta predial
- Superficie autorizada
- Cajones de estacionamiento
- Aforo
- Inversión
- Horario
- Coordenadas geográficas
- Cruces de calles

### ¿Qué validaciones se realizan?

#### Validaciones de Formato:
- RFC con formato oficial
- CURP con formato oficial
- Email válido
- Números positivos en campos numéricos
- Fechas en formato correcto

#### Validaciones de Catálogos:
- El giro debe existir y estar vigente
- La actividad debe existir y corresponder al giro
- La calle debe estar en el catálogo
- La colonia debe estar registrada
- El código postal debe ser válido

#### Validaciones de Negocio:
- No puede haber duplicado de RFC activo en el mismo giro
- Si hay cuenta predial, debe existir
- Si hay licencia de referencia, debe estar vigente
- Las dependencias de inspección se asignan según el giro
- Para giros de alcohol, se requiere registro de parentesco

#### Validaciones de Consistencia:
- Zona y subzona se asignan automáticamente según la calle
- La ubicación debe estar completa
- Los datos de superficie deben ser coherentes
- La inversión debe ser razonable según el giro

### ¿Qué documentos genera?

#### Impresos que se generan:
1. **Ficha de Trámite**:
   - Folio de trámite
   - Datos completos del solicitante
   - Ubicación del establecimiento
   - Giro y actividad
   - Incluye código QR con el folio
   - Para entregar al contribuyente

2. **Formato de Uso de Suelo**:
   - Documento oficial para desarrollo urbano
   - Incluye datos de ubicación
   - Firma del funcionario autorizado
   - Para proceso de dictamen

3. **Dictamen de Microgeneradores**:
   - Para giros que generan residuos especiales
   - Formato para medio ambiente
   - Requiere firma electrónica

4. **Formato Informativo**:
   - Información complementaria del trámite
   - Datos técnicos del establecimiento

## Tablas de Base de Datos

### Tabla Principal

**tramites**: Almacena todas las solicitudes
- Datos del propietario
- Ubicación fiscal y del establecimiento
- Giro y actividad
- Datos del establecimiento/anuncio
- Estado del trámite
- Fechas y usuarios

### Tablas Relacionadas

#### Tablas que consulta:
- **c_giros**: Catálogo de giros SCIAN
- **c_actividades**: Actividades específicas
- **c_callesQry**: Catálogo de calles
- **cp_correos**: Colonias por código postal
- **convcta**: Cuentas prediales
- **folios**: Para obtener siguiente folio
- **licencias**: Para validar licencia de referencia
- **anuncios**: Para validar anuncio de referencia
- **parametros_lic**: Parámetros del sistema
- **dep_giro**: Dependencias que deben revisar cada giro
- **saldos_lic**: Adeudos de licencias
- **saldosAnun**: Adeudos de anuncios

#### Tablas que modifica:
- **tramites**: INSERT del nuevo trámite
- **revisiones**: INSERT de revisiones por dependencia
- **seg_revision**: INSERT de seguimiento de revisiones
- **lic_ubic**: INSERT de coordenadas geográficas
- **crucecalles**: INSERT de cruces de calles
- **parentesco**: INSERT de parentesco (alcohol)
- **tramites_detgrupo**: INSERT en grupos de trámites (pactos)
- **lic_autoev**: INSERT si es autoevaluación
- **bloqueo_rfc_lic**: INSERT si hay bloqueo de RFC
- **lic_ubicses**: Coordenadas temporales de sesión de mapa

## Stored Procedures

### calcSdosLic
**Propósito**: Consultar adeudos de licencia de referencia
**Parámetros**: id_licencia
**Descripción**: Obtiene el saldo total de una licencia

### verifica_firma
**Propósito**: Validar firma electrónica para imprimir dictámenes
**Parámetros**: usuario, firma, módulo
**Descripción**: Verifica permisos para generar documentos oficiales

### get_sess
**Propósito**: Obtener ID de sesión para ubicación en mapa
**Descripción**: Genera sesión única para captura de coordenadas

## Impacto y Repercusiones

### ¿Qué registros afecta?
- Crea nuevo trámite en tabla tramites
- Genera revisiones para dependencias involucradas
- Registra inspecciones requeridas
- Crea seguimiento de revisión
- Puede registrar parentesco
- Registra ubicación geográfica
- Registra cruces de calles

### ¿Qué cambios de estado provoca?
- Trámite creado en estado "E" (En proceso)
- Revisiones creadas en estado inicial
- Folio asignado y bloqueado
- Proceso de dictamen iniciado
- Dependencias notificadas (implícitamente)

### ¿Qué documentos/reportes genera?
- Ficha de trámite con QR
- Uso de suelo
- Dictamen de microgeneradores
- Formato informativo
- Base para dictámenes posteriores

### ¿Qué validaciones de negocio aplica?
- Control de folios consecutivos
- Validación de RFC único por giro
- Asignación automática de dependencias revisoras
- Verificación de adeudos previos
- Control de giros restringidos
- Validación de parentesco para alcohol
- Verificación de bloqueos de RFC

## Flujo de Trabajo

### Flujo Principal de Registro

```
1. Inicio - Usuario presiona "Agregar"
2. Sistema genera folio automático (temporal)
3. Usuario selecciona tipo: Licencia o Anuncio
4. CAPTURA DE DATOS:
   4.1. Datos del propietario
   4.2. Domicilio fiscal
   4.3. Ubicación del establecimiento
   4.4. Giro y actividad
   4.5. Datos específicos del establecimiento
   4.6. Opciones especiales (checkboxes)
5. VALIDACIONES EN TIEMPO REAL:
   5.1. Formato de RFC y CURP
   5.2. Existencia de calles y colonias
   5.3. Validez de cuenta predial (si aplica)
   5.4. Coherencia de datos numéricos
6. PROCESOS AUTOMÁTICOS:
   6.1. Asignación de zona/subzona por calle
   6.2. Determinación de dependencias revisoras
   6.3. Consulta de adeudos (si hay referencias)
7. OPCIONES ESPECIALES:
   7.1. ¿Requiere mapa? → Captura coordenadas
   7.2. ¿Es alcohol? → Registra parentesco
   7.3. ¿Tiene cruces? → Registra calles
   7.4. ¿Es autoevaluación? → Marca flag
8. Usuario presiona "Aceptar"
9. VALIDACIONES FINALES:
   9.1. Todos los campos obligatorios llenos
   9.2. Formatos correctos
   9.3. Referencias válidas
10. GUARDADO:
    10.1. Asigna folio definitivo
    10.2. Inserta en tabla tramites
    10.3. Determina dependencias revisoras según giro
    10.4. Crea registros en revisiones
    10.5. Crea seguimiento en seg_revision
    10.6. Guarda coordenadas si hay
    10.7. Guarda cruces de calles si hay
    10.8. Guarda parentesco si aplica
11. GENERACIÓN DE DOCUMENTOS:
    11.1. Usuario presiona botón de impresión
    11.2. Selecciona documento a imprimir
    11.3. Sistema genera documento
    11.4. Se imprime o exporta
12. Fin - Trámite registrado exitosamente
```

## Notas Importantes

### Consideraciones especiales

#### Folios Consecutivos:
- Se generan automáticamente por año
- No se pueden modificar una vez asignados
- Son únicos por periodo
- Se consultan y actualizan en tabla folios

#### Dependencias Revisoras:
- Se asignan automáticamente según el giro
- Tabla dep_giro define qué dependencias revisan cada giro
- Cada dependencia recibe una revisión individual
- El estado del trámite depende de todas las revisiones

#### Giros Restringidos:
- Algunos giros requieren autorizaciones especiales
- Checkbox de giro restringido marca el trámite
- Puede requerir proceso especial de dictamen

#### Autoevaluación:
- Sistema simplificado para ciertos giros
- Marca el trámite para proceso rápido
- Puede tener flujo diferente de dictamen

#### Parentesco (Alcohol):
- Giros relacionados con alcohol requieren declaración de parentesco
- Se registra información de familiares del titular
- Validación para evitar acaparamiento de licencias

#### Mapa de Ubicación:
- Opcional pero recomendado
- Abre interfaz web para seleccionar ubicación
- Las coordenadas se guardan para georeferenciación
- Útil para análisis espaciales y estadísticas

#### Cruces de Calles:
- Registra entre qué calles se encuentra
- Ayuda a ubicar establecimientos
- Usado en inspecciones y verificación

#### Cuenta Predial:
- Opcional pero recomendado
- Vincula el trámite con el predio
- Permite verificar adeudos prediales
- Facilita validaciones de uso de suelo

### Restricciones

- Un RFC solo puede tener una solicitud activa por giro
- Los giros deben estar vigentes
- Las actividades deben corresponder al giro seleccionado
- La ubicación debe tener calle y colonia válidas
- Para anuncios, se requiere fabricante
- Para alcohol, se requiere registro de parentesco
- RFC bloqueado no puede solicitar licencia

### Permisos necesarios

- Acceso al módulo de registro de solicitudes
- Permisos para generar folios
- Firma electrónica para imprimir dictámenes oficiales
- Nivel adecuado para giros restringidos

### Mejores prácticas de uso

1. **Verificación previa**: Revisar que no exista solicitud activa del mismo RFC
2. **Datos completos**: Llenar todos los campos obligatorios
3. **Validación de documentos**: Verificar físicamente RFC y CURP
4. **Ubicación precisa**: Usar mapa para coordenadas exactas
5. **Giro correcto**: Seleccionar el giro que mejor describe la actividad
6. **Actividad específica**: Elegir actividad detallada dentro del giro
7. **Adeudos**: Verificar situación de adeudos antes de tramitar
8. **Documentación**: Entregar ficha de trámite al contribuyente
9. **Cruces**: Registrar calles de referencia para ubicación
10. **Impresión**: Generar ficha inmediatamente después de guardar

### Casos especiales

#### Trámites relacionados:
- Cambio de titular: Requiere licencia de referencia
- Ampliación de giro: Requiere licencia existente
- Anuncio nuevo: Puede requerir licencia activa

#### Bloqueos de RFC:
- Sistema valida si el RFC está bloqueado
- Muestra advertencia si hay bloqueos vigentes
- Puede impedir el registro según el tipo de bloqueo

#### Pago de solicitud:
- Checkbox indica si se pagó en ventanilla
- Marca el trámite para control de pagos
- No valida el pago, solo lo registra

### Impacto en otros módulos

Este módulo es origen de:
- **Revisiones**: Crea expedientes para dictaminadores
- **Inspecciones**: Genera órdenes de inspección
- **Dictamen**: Base para aprobación o rechazo
- **Emisión de licencia**: Si se aprueba, genera licencia
- **Estadísticas**: Base de datos de solicitudes
- **Cobros**: Genera adeudos de trámite

### Mantenimiento y auditoría

- Todos los trámites son auditables
- Se registra usuario y fecha de captura
- Los folios son correlativos y verificables
- Las modificaciones posteriores se rastrean
- Importante mantener integridad de folios
- Verificar periódicamente asignación de dependencias
- Revisar que las coordenadas sean correctas
- Auditar uso de opciones especiales (autoevaluación, giros restringidos)

### Integración con otros sistemas

- **Mapa web**: Para captura de coordenadas
- **Catastro**: Para cuentas prediales
- **Padrón predial**: Para validar propiedades
- **Sistema de pagos**: Para verificar pagos de solicitud
- **Portal ciudadano**: Puede recibir pre-solicitudes
