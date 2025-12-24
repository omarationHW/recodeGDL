# Bloqueo de Domicilios para Licencias

## Descripción General

### ¿Qué hace este módulo?
Este módulo administra el bloqueo y desbloqueo de domicilios específicos para prevenir el otorgamiento de nuevas licencias en ubicaciones que presentan irregularidades, restricciones urbanísticas, problemas de uso de suelo o situaciones administrativas pendientes.

### ¿Para qué sirve en el proceso administrativo?
- Impide el otorgamiento de licencias en domicilios bloqueados
- Registra historial de bloqueos y desbloqueos de ubicaciones
- Documenta los motivos de restricción para cada dirección
- Permite búsqueda por calle, número o fecha
- Facilita el control de domicilios con situaciones irregulares
- Exporta información a Excel para análisis y reportes
- Mantiene trazabilidad de cambios mediante tabla histórica

### ¿Quiénes lo utilizan?
- Jefes del Departamento de Padrón y Licencias
- Personal autorizado de Padrón y Licencias
- Personal de Ventanilla (consulta)
- Inspectores municipales
- Personal de Catastro
- Personal de Desarrollo Urbano
- Auditores internos

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?

#### PROCESO DE BLOQUEO (AGREGAR)

1. **Inicio del proceso**
   - Usuario presiona botón "Agregar"
   - Sistema muestra panel de captura
   - Deshabilita botones de modificar y eliminar
   - Habilita botones de aceptar y cancelar

2. **Selección de calle**
   - Usuario busca calle mediante:
     - Opción 1: Teclear nombre y seleccionar del lookup
     - Opción 2: Presionar botón "Buscar Calle" para abrir catálogo completo
   - Sistema valida que la calle seleccionada exista en el catálogo

3. **Captura de información del domicilio**
   - Usuario ingresa:
     - **Número exterior** (FloatEdit1)
     - **Letra exterior** (Edit2) - opcional
     - **Número interior** (FloatEdit2) - opcional
     - **Letra interior** (Edit3) - opcional

4. **Validación de selección de calle**
   - Sistema verifica que:
     - El campo de calle no esté vacío
     - La calle seleccionada corresponda a una del catálogo
   - Si no es válida, muestra: "Debe seleccionar una calle..."

5. **Captura de motivo del bloqueo**
   - Usuario ingresa observación/motivo en Memo1
   - Texto se convierte automáticamente a mayúsculas

6. **Registro del bloqueo**
   - Sistema inserta nuevo registro en tabla bloqueo_dom
   - Guarda:
     - Calle (nombre completo)
     - cvecalle (código de la calle)
     - Número exterior, letra exterior
     - Número interior, letra interior
     - Folio (generado automáticamente)
     - Fecha actual
     - Hora actual
     - Estado: 'V' (Vigente)
     - Observación/motivo
     - Usuario que registra (capturista)

7. **Finalización**
   - Oculta panel de captura
   - Limpia campos
   - Actualiza grid con nuevo bloqueo

#### PROCESO DE MODIFICACIÓN (EDITAR)

1. **Selección del registro**
   - Usuario selecciona bloqueo del grid
   - Presiona botón "Modificar"

2. **Carga de datos**
   - Sistema muestra panel de captura
   - Carga información existente:
     - Calle
     - Número exterior y letra
     - Número interior y letra
     - Motivo actual

3. **Modificación de información**
   - Usuario puede modificar:
     - Calle
     - Números y letras del domicilio
     - Observación/motivo

4. **Registro histórico automático**
   - Antes de actualizar, sistema guarda registro en h_bloqueo_dom:
     - Copia completa del registro original
     - Fecha/hora actual
     - Motivo: "Modificado desde Bloqueo de Domicilios"
     - Tipo de movimiento: "MD"
     - Usuario que modifica

5. **Actualización del registro**
   - Sistema actualiza el registro principal
   - Modifica campos cambiados
   - Mantiene folio original

#### PROCESO DE ELIMINACIÓN

1. **Selección del registro**
   - Usuario selecciona bloqueo del grid
   - Presiona botón "Eliminar"

2. **Confirmación**
   - Sistema muestra: "¿Está seguro de eliminar el registro?"
   - Usuario confirma (Sí/No)

3. **Captura de motivo de eliminación**
   - Sistema solicita motivo mediante InputQuery
   - Campo: "Motivo de Eliminación"
   - Si usuario cancela, muestra: "No se Eliminó el Domicilio"

4. **Registro histórico automático**
   - Sistema guarda en h_bloqueo_dom:
     - Copia completa del registro
     - Fecha/hora actual
     - Motivo capturado por usuario
     - Tipo de movimiento: "ED" (Eliminado desde bloqueo dom.)
     - Usuario que elimina

5. **Eliminación física**
   - Sistema elimina el registro de bloqueo_dom
   - Nota: El registro permanece en h_bloqueo_dom para auditoría

#### PROCESO DE BÚSQUEDA Y CONSULTA

**Búsqueda por calle (filtro dinámico):**
1. Usuario teclea nombre de calle en campo EdtCalle
2. Sistema filtra automáticamente mientras se escribe
3. Muestra solo domicilios de calles que coincidan
4. Respeta orden seleccionado (por calle o por fecha)
5. Si se borra el campo, muestra todos los registros

**Ordenamiento:**
1. **RadioButton1 - Por Calle:**
   - Ordena por: calle, num_ext, num_int
   - Agrupa domicilios de la misma calle

2. **RadioButton2 - Por Fecha:**
   - Ordena por: fecha desc, hora desc
   - Muestra bloqueos más recientes primero

**Búsqueda rápida en grid:**
- Usuario hace clic en encabezado de columna
- Activa búsqueda para esa columna específica

#### PROCESO DE EXPORTACIÓN A EXCEL

1. Usuario presiona botón "Excel"
2. Sistema muestra diálogo de guardar
3. Usuario selecciona ubicación y nombre
4. Sistema exporta grid completo a archivo .XLS

### ¿Qué información requiere el usuario?

#### Para bloquear un domicilio:
- **Calle** (obligatorio): Selección del catálogo de calles
- **Número exterior**: Número de la propiedad (opcional si solo es restricción general de calle)
- **Letra exterior**: Complemento del número exterior (opcional)
- **Número interior**: Para edificios, departamentos, locales (opcional)
- **Letra interior**: Complemento del número interior (opcional)
- **Motivo del bloqueo** (obligatorio): Explicación clara de la restricción

#### Para eliminar:
- **Motivo de eliminación** (obligatorio): Justificación de por qué se libera el domicilio

#### Para buscar:
- **Nombre de calle** (parcial o completo)

### ¿Qué validaciones se realizan?

1. **Validación de calle**
   - Verifica que la calle sea del catálogo oficial
   - No permite calles inexistentes o mal escritas
   - Muestra mensaje: "Debe seleccionar una calle..."

2. **Prevención de pérdida de datos**
   - Solicita confirmación antes de eliminar
   - Requiere motivo obligatorio para eliminar

3. **Registro histórico automático**
   - Guarda automáticamente en tabla histórica antes de modificar o eliminar
   - No requiere intervención del usuario

4. **Integridad de datos**
   - Convierte texto a mayúsculas automáticamente
   - Valida que cvecalle corresponda a la calle seleccionada

### ¿Qué documentos genera?
1. **Archivo Excel** con listado de domicilios bloqueados, incluyendo:
   - Cuenta catastral (si aplica)
   - Clave y nombre de calle
   - Número y letra exterior
   - Número y letra interior
   - Folio del bloqueo
   - Fecha y hora
   - Estado (Vigente)
   - Observaciones
   - Usuario que registró

## Tablas de Base de Datos

### Tabla Principal
**bloqueo_dom**
- Almacena todos los bloqueos de domicilios activos
- Campos principales:
  - cvecuenta: Cuenta catastral (si aplica)
  - cvecalle: Código de la calle
  - calle: Nombre completo de la calle
  - num_ext: Número exterior
  - let_ext: Letra exterior
  - num_int: Número interior
  - let_int: Letra interior
  - folio: Número de folio del bloqueo
  - fecha: Fecha de registro
  - hora: Hora de registro
  - vig: Estado ('V' = Vigente)
  - observacion: Motivo del bloqueo
  - capturista: Usuario que registró

### Tabla Histórica
**h_bloqueo_dom**
- Almacena historial de todos los cambios
- Campos adicionales:
  - Todos los campos de bloqueo_dom
  - fecha_movimiento: Cuándo se hizo el cambio
  - motivo_hist: Razón del cambio
  - tipo_mov: Tipo de movimiento (MD=Modificado, ED=Eliminado)
  - usuario_hist: Quién hizo el cambio

### Tablas Relacionadas

#### Tablas que Consulta:
- **bloqueo_dom**: Consulta principal de domicilios bloqueados
- **calles** (tabla catálogo): Obtiene el listado oficial de calles del municipio
  - cvecalle: Código único de la calle
  - calle: Nombre oficial de la calle
- **busca_calle** (query): Búsqueda rápida de calles

#### Tablas que Modifica:
- **bloqueo_dom**:
  - INSERT: Al crear nuevo bloqueo
  - UPDATE: Al modificar bloqueo existente
  - DELETE: Al eliminar bloqueo

- **h_bloqueo_dom** (histórico):
  - INSERT: Automático antes de cada modificación o eliminación
  - Registra:
    - Estado anterior completo
    - Tipo de movimiento (MD, ED)
    - Fecha/hora del cambio
    - Motivo del cambio
    - Usuario que realizó el cambio

## Stored Procedures
Este módulo no utiliza stored procedures. Opera mediante queries SQL directas y operaciones de INSERT/UPDATE/DELETE.

## Impacto y Repercusiones

### ¿Qué registros afecta?

1. **Tabla bloqueo_dom**
   - Inserta nuevos bloqueos de domicilios
   - Actualiza información de bloqueos existentes
   - Elimina bloqueos liberados

2. **Tabla h_bloqueo_dom (histórico)**
   - Inserta automáticamente registro histórico antes de:
     - Modificar un bloqueo (tipo_mov = 'MD')
     - Eliminar un bloqueo (tipo_mov = 'ED')

### ¿Qué cambios de estado provoca?

1. **Bloqueo de domicilio**
   - Domicilio queda bloqueado para nuevas licencias
   - Estado: 'V' (Vigente)
   - Impide otorgamiento hasta que se libere

2. **Liberación de domicilio**
   - Registro se elimina de tabla principal
   - Queda solo en tabla histórica
   - Domicilio liberado para nuevos trámites

### ¿Qué documentos/reportes genera?

1. **Archivo Excel de exportación**
   - Listado completo de domicilios bloqueados
   - Incluye todos los campos del grid
   - Permite análisis externo
   - Útil para auditorías y reportes

### ¿Qué validaciones de negocio aplica?

1. **Validación de calle oficial**
   - Solo permite calles del catálogo municipal
   - Previene errores de captura
   - Garantiza consistencia con sistemas de Catastro

2. **Trazabilidad completa**
   - Registra usuario y fecha/hora de cada operación
   - Mantiene historial de todos los cambios
   - Documenta motivos de modificaciones y eliminaciones

3. **Protección contra pérdida de información**
   - Tabla histórica preserva todos los cambios
   - No se pierde información al modificar o eliminar
   - Permite auditoría completa

4. **Control de domicilios**
   - Impide otorgar licencias en domicilios bloqueados
   - Protege contra irregularidades urbanísticas
   - Facilita control de uso de suelo

## Flujo de Trabajo

### Flujo de bloqueo de domicilio

```
INICIO
  ↓
Clic en botón "Agregar"
  ↓
Mostrar panel de captura
  ↓
Seleccionar calle (lookup o búsqueda)
  ↓
¿Calle válida? → NO → Mostrar error "Debe seleccionar calle"
  ↓ SÍ
Capturar número exterior (opcional)
  ↓
Capturar letra exterior (opcional)
  ↓
Capturar número interior (opcional)
  ↓
Capturar letra interior (opcional)
  ↓
Capturar motivo del bloqueo (Memo1)
  ↓
Clic en "Aceptar"
  ↓
Insertar registro en bloqueo_dom:
  - calle, cvecalle
  - num_ext, let_ext, num_int, let_int
  - folio (auto)
  - fecha = hoy, hora = ahora
  - vig = 'V'
  - observacion = motivo
  - capturista = usuario actual
  ↓
Ocultar panel
  ↓
Limpiar campos
  ↓
Actualizar grid
  ↓
FIN
```

### Flujo de modificación

```
INICIO
  ↓
Seleccionar bloqueo del grid
  ↓
Clic en botón "Modificar"
  ↓
Mostrar panel con datos actuales
  ↓
Modificar campos necesarios
  ↓
Clic en "Aceptar"
  ↓
GUARDAR HISTORIAL:
  INSERT en h_bloqueo_dom
  - Todos los datos originales
  - fecha_movimiento = ahora
  - motivo_hist = "Modificado desde Bloqueo de Domicilios"
  - tipo_mov = "MD"
  - usuario_hist = usuario actual
  ↓
ACTUALIZAR REGISTRO:
  UPDATE en bloqueo_dom
  - Aplicar cambios realizados
  ↓
Ocultar panel
  ↓
Actualizar grid
  ↓
FIN
```

### Flujo de eliminación

```
INICIO
  ↓
Seleccionar bloqueo del grid
  ↓
Clic en botón "Eliminar"
  ↓
Mostrar confirmación
  ↓
¿Usuario confirma? → NO → Cancelar
  ↓ SÍ
Solicitar motivo de eliminación
  ↓
¿Usuario proporciona motivo? → NO → "No se Eliminó el Domicilio"
  ↓ SÍ
GUARDAR HISTORIAL:
  INSERT en h_bloqueo_dom
  - Todos los datos del registro
  - fecha_movimiento = ahora
  - motivo_hist = motivo capturado
  - tipo_mov = "ED"
  - usuario_hist = usuario actual
  ↓
ELIMINAR REGISTRO:
  DELETE de bloqueo_dom
  ↓
Actualizar grid
  ↓
FIN
```

## Notas Importantes

### Consideraciones especiales

1. **Historial automático**
   - Toda modificación o eliminación se registra automáticamente
   - No requiere intervención del usuario
   - Proporciona auditoría completa
   - Permite rastrear quién, cuándo y por qué se hizo cada cambio

2. **Búsqueda flexible**
   - Filtro por calle funciona en tiempo real
   - Dos opciones de ordenamiento (por calle o por fecha)
   - Búsqueda rápida en columnas del grid

3. **Catálogo de calles oficial**
   - Solo permite usar calles del catálogo municipal
   - Garantiza consistencia con Catastro
   - Facilita integración entre sistemas

4. **Domicilios parciales**
   - Se puede bloquear solo calle (sin número)
   - Se puede bloquear con solo número exterior
   - Se puede especificar hasta letra interior
   - Flexibilidad según necesidad de restricción

### Restricciones

1. **Eliminación física**
   - Los registros se eliminan de tabla principal
   - Permanecen en tabla histórica
   - No se pueden recuperar automáticamente
   - Para volver a bloquear, debe crearse nuevo registro

2. **Calle obligatoria**
   - No se puede bloquear sin especificar calle
   - La calle debe ser del catálogo oficial

3. **Motivo obligatorio para eliminar**
   - No permite eliminar sin justificación
   - El motivo se guarda en tabla histórica

### Permisos necesarios

- Acceso al módulo de Padrón y Licencias
- Permisos para gestión de bloqueos
- Acceso de lectura a tablas:
  - bloqueo_dom
  - calles (catálogo)
  - h_bloqueo_dom (para consultas históricas)
- Acceso de escritura a tablas:
  - bloqueo_dom
  - h_bloqueo_dom
- Permisos de exportación (para generar Excel)

### Recomendaciones de uso

1. **Al bloquear un domicilio**
   - Verificar ortografía de la calle
   - Confirmar número exacto del domicilio
   - Capturar motivo claro y completo
   - Incluir referencia a documentos de soporte (oficios, etc.)
   - Especificar tipo de restricción (uso de suelo, urbanística, administrativa)

2. **Al eliminar bloqueo**
   - Validar que se cumplieron requisitos para liberar
   - Documentar claramente motivo de liberación
   - Verificar que no existan restricciones pendientes
   - Notificar a ventanilla sobre la liberación

3. **Para búsquedas**
   - Usar filtro por calle para ubicaciones específicas
   - Usar ordenamiento por fecha para ver bloqueos recientes
   - Exportar a Excel para análisis periódicos

4. **Control de calidad**
   - Revisar periódicamente bloqueos vigentes
   - Validar que restricciones sigan siendo válidas
   - Liberar domicilios cuando se resuelvan situaciones
   - Mantener coordinación con Catastro y Desarrollo Urbano

5. **Gestión de información**
   - Conservar documentación de respaldo de cada bloqueo
   - Actualizar observaciones cuando cambien condiciones
   - Generar reportes periódicos de domicilios bloqueados
   - Comunicar a ventanilla listado actualizado
   - Consultar tabla histórica para investigaciones
