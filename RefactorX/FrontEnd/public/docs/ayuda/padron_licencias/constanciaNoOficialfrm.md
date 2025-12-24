# Solicitudes de Constancia No Oficial

## Descripción General

### ¿Qué hace este módulo?
Este módulo gestiona las solicitudes de constancias no oficiales para establecimientos que operan sin licencia formal. Permite registrar, consultar, modificar, cancelar e imprimir constancias que certifican la existencia y ubicación de actividades comerciales no oficializadas.

### ¿Para qué sirve en el proceso administrativo?
- Registra solicitudes de constancias para negocios sin licencia oficial
- Genera folios consecutivos anuales para control
- Imprime constancias oficiales con información del solicitante
- Permite búsqueda por propietario o ubicación
- Facilita la modificación de solicitudes capturadas
- Documenta actividades comerciales no formalizadas
- Proporciona certificación temporal de operación

### ¿Quiénes lo utilizan?
- Personal de Padrón y Licencias
- Personal de ventanilla
- Supervisores del departamento
- Personal autorizado para emitir constancias
- Contribuyentes (reciben la constancia impresa)

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?

#### PROCESO DE NUEVA SOLICITUD

1. **Inicio del proceso**
   - Usuario presiona botón "Nueva"
   - Sistema muestra panel de captura
   - Deshabilita botones de consulta y modificación
   - Limpia campo de búsqueda

2. **Búsqueda de trámite de referencia**
   - Usuario ingresa ID de trámite en CurrencyEdit1
   - Presiona TAB o sale del campo

3. **Extracción automática de datos del trámite**
   - Sistema consulta tabla de trámites (Query1)
   - Extrae automáticamente:
     - **Propietario**: primer apellido + segundo apellido + nombre
     - **Actividad**: Giro comercial del trámite
     - **Ubicación**: Dirección completa del establecimiento
       - Calle
       - Número exterior (si existe)
       - Letra exterior (si existe)
       - Número interior (si existe)
       - Letra interior (si existe)
     - **Zona**: Zona catastral
     - **Subzona**: Subzona catastral

4. **Validación de trámite**
   - Si NO encuentra el trámite:
     - Campos quedan vacíos
     - Usuario debe capturar manualmente
   - Si SÍ encuentra el trámite:
     - Datos se cargan automáticamente en campos editables
     - Usuario puede modificar si es necesario

5. **Captura/validación de información**
   - Usuario revisa datos auto-llenados
   - Puede editar cualquier campo:
     - Propietario (DBEdit1)
     - Actividad (DBEdit2)
     - Ubicación (DBEdit3)
     - Zona (DBEdit4)
     - Subzona (DBEdit5)

6. **Confirmación y registro**
   - Usuario presiona botón "Aceptar"
   - Sistema inserta nuevo registro en modo INSERT

7. **Generación de folio**
   - Sistema consulta tabla parametros (Table1)
   - Obtiene último folio de constancias no oficiales (campo: cnooficial)
   - Incrementa folio en 1
   - Actualiza parámetro con nuevo folio
   - Asigna a la nueva solicitud:
     - Año actual (axo)
     - Folio consecutivo
     - Estado: 'V' (Vigente)

8. **Impresión opcional**
   - Variable SeImprime controla si se imprime automáticamente
   - Si está activada, genera reporte ppReport6 automáticamente

9. **Finalización**
   - Oculta panel de captura
   - Habilita botones de consulta
   - Actualiza grid con nueva solicitud

#### PROCESO DE MODIFICACIÓN

1. **Selección de solicitud**
   - Usuario selecciona registro del grid
   - Presiona botón "Modificar"

2. **Carga de datos**
   - Sistema muestra panel de captura
   - Deshabilita campo de ID de trámite (CurrencyEdit1)
   - Carga datos actuales en campos editables

3. **Modificación de información**
   - Usuario edita campos necesarios
   - Puede cambiar: propietario, actividad, ubicación, zona, subzona

4. **Actualización**
   - Usuario presiona "Aceptar"
   - Sistema guarda cambios (modo EDIT)
   - Mantiene: año, folio, estado

5. **Finalización**
   - Oculta panel
   - Actualiza grid

#### PROCESO DE IMPRESIÓN

1. **Selección de solicitud**
   - Usuario selecciona registro del grid
   - Presiona botón "Imprimir"

2. **Validación de estado**
   - Sistema verifica campo 'vigente'
   - Si está cancelado (vigente = 'C'):
     - Muestra mensaje: "Esta solicitud está cancelada, no podrá imprimirse"
     - No permite imprimir
   - Si está vigente (vigente = 'V'):
     - Permite continuar

3. **Generación de constancia**
   - Abre query solic con datos completos
   - Genera reporte ppReport6 con:
     - Logotipo institucional
     - Año y folio de la solicitud
     - Datos del propietario
     - Actividad comercial
     - Ubicación completa
     - Zona y subzona
     - Fecha de emisión
   - Envía a impresora

#### PROCESO DE CANCELACIÓN

1. **Selección de solicitud**
   - Usuario selecciona registro del grid
   - Presiona botón "Cancelar Solicitud"

2. **Confirmación**
   - Sistema muestra: "¿Está seguro de cancelar esta solicitud?"
   - Usuario confirma (Sí/No)

3. **Actualización de estado**
   - Si confirma:
     - Edita registro
     - Cambia vigente de 'V' a 'C'
     - Guarda cambio

#### PROCESO DE BÚSQUEDA

**Búsqueda dinámica:**
1. Usuario selecciona criterio en RadioGroupBusqueda:
   - Opción 0: Por Propietario
   - Opción 1: Por Ubicación

2. Usuario teclea en campo EditDato

3. Sistema filtra automáticamente mientras se escribe:
   - Si Propietario: WHERE propietario LIKE '%texto%'
   - Si Ubicación: WHERE ubicacion LIKE '%texto%'

4. Muestra resultados ordenados por año desc, folio desc

5. Si se borra el campo, muestra todos los registros

### ¿Qué información requiere el usuario?

#### Para crear nueva solicitud:
**Datos obligatorios:**
- **Propietario**: Nombre completo del solicitante
- **Actividad**: Giro o actividad comercial
- **Ubicación**: Dirección del establecimiento
- **Zona y Subzona**: Ubicación catastral

**Dato opcional:**
- **ID de trámite**: Para auto-llenar información (si existe trámite asociado)

#### Para buscar:
- **Texto de búsqueda**: Nombre de propietario o dirección (parcial o completo)
- **Criterio**: Selección entre Propietario o Ubicación

### ¿Qué validaciones se realizan?

1. **Validación de trámite (opcional)**
   - Si se ingresa ID de trámite, valida que exista
   - Si no existe, permite captura manual

2. **Validación de estado para impresión**
   - No permite imprimir solicitudes canceladas
   - Solo imprime solicitudes vigentes

3. **Confirmación de cancelación**
   - Solicita confirmación explícita antes de cancelar
   - Previene cancelaciones accidentales

4. **Generación de folio consecutivo**
   - Obtiene automáticamente siguiente folio disponible
   - Actualiza parámetros para mantener secuencia
   - Folios se reinician cada año

### ¿Qué documentos genera?

**Constancia No Oficial (impresa):**
- Membrete institucional con logotipo
- Título: Información de la constancia
- Año y folio consecutivo
- Datos completos del propietario
- Actividad comercial declarada
- Ubicación completa del establecimiento
- Zona y subzona catastral
- Fecha de emisión
- Espacio para firmas autorizadas
- Número de página y fecha de impresión

## Tablas de Base de Datos

### Tabla Principal
**solicnooficial**
- Almacena todas las solicitudes de constancias no oficiales
- Campos principales:
  - axo: Año de emisión
  - folio: Número consecutivo anual
  - propietario: Nombre del solicitante
  - actividad: Giro comercial
  - ubicacion: Dirección del establecimiento
  - zona: Zona catastral
  - subzona: Subzona catastral
  - vigente: Estado ('V'=Vigente, 'C'=Cancelado)
  - feccap: Fecha de captura
  - capturista: Usuario que registró

### Tablas Relacionadas

#### Tablas que Consulta:
- **solicnooficial**: Consulta principal de solicitudes
- **Query1** (tramites): Obtiene datos de trámites para auto-llenar información
  - Consulta por id_tramite
  - Extrae: primer_ap, segundo_ap, propietario, actividad, ubicación, zona, subzona
- **solic** (query): Datos completos para impresión
- **Table1** (parametros): Obtiene y actualiza folio consecutivo (campo: cnooficial)

#### Tablas que Modifica:
- **solicnooficial**:
  - INSERT: Al crear nueva solicitud
  - UPDATE: Al modificar solicitud existente
  - UPDATE: Al cancelar (cambia vigente a 'C')

- **Table1** (parametros):
  - UPDATE: Incrementa contador de folios (cnooficial) cada vez que se crea nueva solicitud

## Stored Procedures
Este módulo no utiliza stored procedures. Opera mediante queries SQL directas.

## Impacto y Repercusiones

### ¿Qué registros afecta?

1. **Tabla solicnooficial**
   - Inserta nuevas solicitudes
   - Actualiza información de solicitudes existentes
   - Cambia estado a cancelado cuando se requiere

2. **Tabla parametros**
   - Incrementa contador de folios consecutivos por cada nueva solicitud

### ¿Qué cambios de estado provoca?

1. **Estado de solicitudes**
   - Se crean con estado 'V' (Vigente)
   - Pueden cambiar a 'C' (Cancelado)
   - Estado cancelado impide reimprimir

2. **Secuencia de folios**
   - Cada solicitud incrementa el folio consecutivo
   - Folios son únicos por año

### ¿Qué documentos/reportes genera?

**Constancia No Oficial Impresa:**
- Documento oficial con formato institucional
- Certifica existencia y ubicación del establecimiento
- Incluye datos completos del solicitante
- Tiene año y folio para control y seguimiento
- NO constituye licencia formal de operación

### ¿Qué validaciones de negocio aplica?

1. **Control de folios consecutivos**
   - Garantiza numeración única
   - Mantiene secuencia sin saltos
   - Reinicia cada año

2. **Trazabilidad**
   - Registra usuario y fecha de captura
   - Mantiene historial completo
   - Permite auditoría

3. **Protección de documentos cancelados**
   - Impide reimprimir constancias canceladas
   - Mantiene registro histórico

4. **Asociación con trámites**
   - Permite vincular con trámite formal si existe
   - Facilita auto-llenado de información
   - Reduce errores de captura

## Flujo de Trabajo

### Flujo de nueva solicitud

```
INICIO
  ↓
Clic en "Nueva"
  ↓
Mostrar panel de captura
  ↓
Insertar nuevo registro (modo INSERT)
  ↓
¿Usuario ingresa ID de trámite? → NO → Captura manual
  ↓ SÍ
Consultar Query1 con id_tramite
  ↓
¿Encuentra trámite? → NO → Campos vacíos, captura manual
  ↓ SÍ
Auto-llenar campos:
  - Propietario = concat(apellidos, nombre)
  - Actividad = giro
  - Ubicacion = dirección completa
  - Zona, Subzona
  ↓
Usuario revisa/edita datos
  ↓
Clic en "Aceptar"
  ↓
Abrir Table1 (parametros)
  ↓
Obtener cnooficial actual
  ↓
nvofolio = cnooficial + 1
  ↓
Actualizar Table1:
  cnooficial = nvofolio
  ↓
Completar registro solicitud:
  - axo = año actual
  - folio = nvofolio
  - vigente = 'V'
  ↓
POST (guardar registro)
  ↓
¿SeImprime = true? → SÍ → Imprimir ppReport6
  ↓ NO
Ocultar panel
  ↓
Habilitar botones consulta
  ↓
FIN
```

### Flujo de búsqueda dinámica

```
INICIO
  ↓
Usuario selecciona criterio:
  - RadioButton 0 = Propietario
  - RadioButton 1 = Ubicación
  ↓
Usuario teclea en EditDato
  ↓
Evento EditDatoChange se dispara
  ↓
Cerrar query solicnooficial
  ↓
Limpiar SQL
  ↓
¿Campo EditDato vacío? → SÍ → SELECT * FROM solicnooficial
  ↓ NO                         ORDER BY axo DESC, folio DESC
Construir query con filtro:
  ↓
¿Criterio = Propietario? → SÍ → WHERE propietario LIKE '%texto%'
  ↓ NO
WHERE ubicacion LIKE '%texto%'
  ↓
Agregar ORDER BY axo DESC, folio DESC
  ↓
Abrir query
  ↓
Mostrar resultados en grid
  ↓
Usuario continúa teclando → Repetir filtrado
  ↓
FIN
```

## Notas Importantes

### Consideraciones especiales

1. **Constancia NO es licencia**
   - Documento informativo, no otorga derechos de operación
   - No exime de obtener licencia oficial
   - No constituye autorización municipal

2. **Auto-llenado desde trámites**
   - Facilita captura de información
   - Reduce errores de tecleo
   - Vincula con trámites formales existentes

3. **Folios consecutivos anuales**
   - Numeración se reinicia cada año
   - Formato: AÑO/FOLIO
   - Permite control cronológico

4. **Búsqueda dinámica**
   - Filtra mientras se teclea
   - No requiere botón de búsqueda
   - Respuesta inmediata

### Restricciones

1. **Constancias canceladas**
   - No se pueden reimprimir
   - Permanecen en sistema para historial
   - No se pueden reactivar

2. **Folios consecutivos**
   - Generados automáticamente
   - No se pueden modificar manualmente
   - Secuencia controlada por sistema

3. **Modificación limitada**
   - Solo se pueden editar datos descriptivos
   - No se puede cambiar año, folio ni estado vigente manualmente

### Permisos necesarios

- Acceso al módulo de Padrón y Licencias
- Permisos para:
  - Crear nuevas solicitudes
  - Modificar solicitudes
  - Cancelar solicitudes
  - Imprimir constancias
- Acceso de lectura a tablas:
  - solicnooficial
  - tramites (Query1)
  - parametros (Table1)
- Acceso de escritura a tablas:
  - solicnooficial
  - parametros

### Recomendaciones de uso

1. **Al crear nueva solicitud**
   - Si existe trámite relacionado, usar auto-llenado
   - Verificar datos auto-llenados antes de guardar
   - Capturar información completa y correcta
   - Validar zona y subzona con catastro si hay duda

2. **Al imprimir**
   - Verificar que sea la solicitud correcta
   - Confirmar que datos sean actuales
   - Explicar al contribuyente que NO es licencia oficial
   - Entregar con aclaraciones sobre su validez

3. **Para búsquedas**
   - Usar búsqueda por propietario para contribuyentes conocidos
   - Usar búsqueda por ubicación para localizar por dirección
   - Aprovechar filtro dinámico para localizar rápidamente

4. **Control de calidad**
   - Revisar periódicamente solicitudes vigentes
   - Cancelar solicitudes cuando se otorgue licencia oficial
   - Mantener información actualizada
   - Coordinar con ventanilla sobre uso apropiado de constancias

5. **Consideraciones legales**
   - Aclarar que la constancia NO autoriza operación
   - Explicar diferencia entre constancia y licencia
   - Informar sobre requisitos para obtener licencia oficial
   - Documentar que es solo constancia informativa
