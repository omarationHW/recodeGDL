# Bloqueo de RFC para Licencias

## Descripción General

### ¿Qué hace este módulo?
Este módulo administra el bloqueo y desbloqueo de RFC (Registro Federal de Contribuyentes) para prevenir el otorgamiento de nuevas licencias a contribuyentes que presentan irregularidades, adeudos o situaciones administrativas pendientes.

### ¿Para qué sirve en el proceso administrativo?
- Impide el otorgamiento de nuevas licencias a RFC bloqueados
- Registra el historial de bloqueos y desbloqueos
- Documenta los motivos de restricción de cada RFC
- Permite búsqueda y consulta de RFC bloqueados
- Facilita el control y seguimiento de contribuyentes con situaciones irregulares
- Exporta información a Excel para análisis y reportes

### ¿Quiénes lo utilizan?
- Jefes del Departamento de Padrón y Licencias
- Personal autorizado de Padrón y Licencias
- Supervisores administrativos
- Personal de cobranza
- Auditores internos
- Usuarios con permisos especiales para gestión de bloqueos

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?

#### PROCESO DE BLOQUEO (AGREGAR)

1. **Inicio del proceso**
   - Usuario presiona botón "Agregar"
   - Sistema muestra panel de captura
   - Deshabilita botones de modificar y eliminar
   - Habilita botones de aceptar y cancelar

2. **Búsqueda del trámite**
   - Usuario ingresa número de trámite (ID_TRAMITE)
   - Presiona botón "Buscar"
   - Sistema consulta tabla de trámites

3. **Validación y extracción de datos**
   - Sistema valida que el trámite exista
   - Extrae automáticamente:
     - RFC del tramite (campo: rfc)
     - Número de licencia asociada
   - Muestra RFC en campo correspondiente

4. **Captura de información del bloqueo**
   - Usuario ingresa:
     - Número de licencia (si no se llenó automáticamente)
     - Motivo del bloqueo (campo Memo1)

5. **Registro del bloqueo**
   - Sistema crea nuevo registro en tabla bloqueo_rfc_lic
   - Guarda:
     - RFC extraído del trámite
     - ID del trámite de referencia
     - Número de licencia
     - Fecha y hora actual
     - Estado: 'V' (Vigente)
     - Motivo/observación capturada
     - Usuario que registra (capturista)

6. **Finalización**
   - Oculta panel de captura
   - Limpia campos
   - Habilita botones de modificar y eliminar
   - Actualiza grid con el nuevo bloqueo

#### PROCESO DE MODIFICACIÓN (EDITAR)

1. **Selección del registro**
   - Usuario selecciona un bloqueo del grid
   - Presiona botón "Modificar"

2. **Carga de datos**
   - Sistema muestra panel de captura
   - Carga datos existentes:
     - ID de trámite
     - RFC (solo lectura - no modificable directamente)
     - Motivo actual en Memo1
   - Botón "Buscar" se oculta (no se puede cambiar el trámite)

3. **Modificación de información**
   - Usuario puede modificar:
     - Motivo/observación

4. **Actualización del registro**
   - Sistema actualiza el registro existente
   - Mantiene:
     - RFC original
     - ID de trámite original
     - Número de licencia original
   - Actualiza:
     - Fecha y hora (nueva)
     - Observación modificada

#### PROCESO DE DESBLOQUEO (ELIMINAR)

1. **Selección del registro**
   - Usuario selecciona bloqueo del grid
   - Presiona botón "Eliminar"

2. **Carga de datos para desbloqueo**
   - Sistema muestra panel de captura
   - Carga información del bloqueo:
     - ID de trámite
     - RFC
     - Motivo original
   - Botón "Buscar" se oculta

3. **Captura de motivo de desbloqueo**
   - Usuario modifica Memo1 para agregar justificación del desbloqueo
   - Explica razón por la cual se libera el RFC

4. **Registro del desbloqueo**
   - Sistema NO elimina el registro
   - Actualiza el registro:
     - Cambia estado de 'V' (Vigente) a 'C' (Cancelado/desbloqueado)
     - Agrega observación con motivo de desbloqueo
   - Mantiene historial completo

#### PROCESO DE BÚSQUEDA Y CONSULTA

1. **Búsqueda por RFC**
   - Usuario teclea RFC (parcial o completo) en campo de búsqueda
   - Sistema filtra automáticamente mientras se escribe
   - Muestra solo registros que coincidan con el RFC buscado
   - Si se borra el campo, muestra todos los registros

2. **Búsqueda en grid**
   - Usuario hace clic en encabezado de columna
   - Sistema activa búsqueda rápida para esa columna
   - Permite localizar registros específicos

#### PROCESO DE EXPORTACIÓN A EXCEL

1. **Inicio de exportación**
   - Usuario presiona botón "Excel"
   - Sistema muestra diálogo para guardar archivo

2. **Selección de ubicación**
   - Usuario selecciona carpeta destino
   - Especifica nombre de archivo

3. **Generación del archivo**
   - Sistema exporta todos los registros visibles del grid
   - Incluye encabezados de columna
   - Genera archivo .XLS compatible con Excel

### ¿Qué información requiere el usuario?

#### Para bloquear un RFC:
- **ID de trámite** (obligatorio): Número del trámite que originó la necesidad de bloqueo
- **Número de licencia** (obligatorio): Licencia asociada al bloqueo
- **RFC** (se obtiene automáticamente): Registro Federal de Contribuyentes a bloquear
- **Motivo del bloqueo** (obligatorio): Explicación clara y completa de por qué se bloquea el RFC

#### Para desbloquear:
- **Motivo del desbloqueo** (obligatorio): Justificación de por qué se libera el RFC

#### Para buscar:
- **RFC** (parcial o completo): Para filtrar registros

### ¿Qué validaciones se realizan?

1. **Validación de trámite**
   - Verifica que el ID de trámite exista en la tabla de trámites
   - Extrae automáticamente el RFC asociado al trámite

2. **Validación de datos obligatorios**
   - RFC debe estar presente
   - Número de licencia debe capturarse
   - Observación/motivo debe incluirse

3. **Prevención de duplicados**
   - El sistema permite múltiples bloqueos del mismo RFC
   - Cada bloqueo está asociado a un trámite diferente

4. **Integridad de desbloqueo**
   - Solo cambia estado, no elimina registro
   - Mantiene historial completo para auditoría

### ¿Qué documentos genera?
1. **Archivo Excel** con el listado completo de RFC bloqueados, incluyendo:
   - RFC
   - ID de trámite
   - Número de licencia
   - Fecha y hora de bloqueo
   - Estado (Vigente/Cancelado)
   - Observaciones/motivos
   - Usuario que registró (capturista)

## Tablas de Base de Datos

### Tabla Principal
**bloqueo_rfc_lic**
- Almacena todos los bloqueos de RFC registrados
- Campos principales:
  - rfc: Registro Federal de Contribuyentes bloqueado
  - id_tramite: Trámite que originó el bloqueo
  - licencia: Número de licencia asociada
  - hora: Fecha y hora del registro
  - vig: Estado ('V' = Vigente, 'C' = Cancelado/desbloqueado)
  - observacion: Motivo del bloqueo o desbloqueo
  - capturista: Usuario que realizó la operación

### Tablas Relacionadas

#### Tablas que Consulta:
- **VerTramite** (query compleja que une varias tablas):
  - Obtiene información completa del trámite
  - Extrae el RFC del solicitante
  - Proporciona datos de la licencia asociada
  - Incluye información del propietario, ubicación, giro, etc.

#### Tablas que Modifica:
- **bloqueo_rfc_lic**:
  - INSERT: Al crear nuevo bloqueo (movimiento = 'agregar')
  - UPDATE: Al modificar motivo (movimiento = 'editar')
  - UPDATE: Al desbloquear RFC (movimiento = 'desbloquear', cambia vig a 'C')

## Stored Procedures
Este módulo no utiliza stored procedures. Opera mediante queries SQL directas.

## Impacto y Repercusiones

### ¿Qué registros afecta?

1. **Tabla bloqueo_rfc_lic**
   - Inserta nuevos bloqueos
   - Actualiza observaciones en modificaciones
   - Cambia estado de vigente a cancelado en desbloqueos

### ¿Qué cambios de estado provoca?

1. **Bloqueo de RFC**
   - Estado inicial: 'V' (Vigente)
   - RFC queda bloqueado para nuevas licencias
   - Permanece bloqueado hasta que se desbloquee

2. **Desbloqueo de RFC**
   - Estado cambia de 'V' a 'C' (Cancelado)
   - RFC queda liberado para nuevos trámites
   - Registro permanece en sistema para historial

### ¿Qué documentos/reportes genera?

1. **Archivo Excel de exportación**
   - Listado completo de RFC bloqueados
   - Incluye todos los campos del grid
   - Permite análisis externo y reportes
   - Útil para auditorías y seguimiento

### ¿Qué validaciones de negocio aplica?

1. **Trazabilidad completa**
   - Registra usuario que bloquea/desbloquea
   - Guarda fecha y hora exacta
   - Mantiene motivos documentados

2. **Historial permanente**
   - No elimina registros físicamente
   - Solo cambia estado a cancelado
   - Permite auditoría de todas las operaciones

3. **Vinculación con trámites**
   - Cada bloqueo está asociado a un trámite específico
   - Proporciona contexto y justificación
   - Facilita investigación de casos

4. **Control de RFC**
   - Impide otorgar nuevas licencias a RFC bloqueados
   - Protege intereses municipales
   - Previene situaciones irregulares

## Flujo de Trabajo

### Flujo de bloqueo de RFC

```
INICIO
  ↓
Clic en botón "Agregar"
  ↓
Mostrar panel de captura
  ↓
Ingresar ID de trámite
  ↓
Clic en "Buscar"
  ↓
Consultar tabla de trámites
  ↓
¿Existe trámite? → NO → Mensaje error
  ↓ SÍ
Extraer RFC del trámite
  ↓
Mostrar RFC en campo
  ↓
Capturar número de licencia
  ↓
Capturar motivo del bloqueo
  ↓
Clic en "Aceptar"
  ↓
Insertar registro en bloqueo_rfc_lic:
  - rfc
  - id_tramite
  - licencia
  - hora = ahora
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

### Flujo de desbloqueo de RFC

```
INICIO
  ↓
Seleccionar bloqueo del grid
  ↓
Clic en botón "Eliminar"
  ↓
Mostrar panel con datos del bloqueo
  ↓
Modificar observación (agregar motivo de desbloqueo)
  ↓
Clic en "Aceptar"
  ↓
Actualizar registro:
  - observacion = motivo desbloqueo
  - vig = 'C'
  ↓
Ocultar panel
  ↓
Actualizar grid
  ↓
FIN
```

### Flujo de búsqueda

```
INICIO
  ↓
Usuario teclea en campo de búsqueda RFC
  ↓
¿Campo vacío? → SÍ → Mostrar todos los registros
  ↓ NO
Filtrar query:
  - WHERE rfc LIKE "%texto%"
  ↓
Ejecutar consulta
  ↓
Mostrar resultados filtrados en grid
  ↓
Usuario continúa teclando
  ↓
Repetir filtrado en tiempo real
  ↓
FIN
```

## Notas Importantes

### Consideraciones especiales

1. **Extracción automática de RFC**
   - El RFC se obtiene automáticamente del trámite
   - No se captura manualmente
   - Reduce errores de captura
   - Garantiza consistencia de datos

2. **Historial no destructivo**
   - Los desbloqueos no eliminan registros
   - Solo cambian el estado a 'C'
   - Permite auditoría completa
   - Mantiene trazabilidad total

3. **Búsqueda dinámica**
   - El filtro por RFC funciona en tiempo real
   - Muestra resultados mientras se teclea
   - Facilita localización rápida
   - No requiere botón de búsqueda

4. **Exportación flexible**
   - Permite exportar a Excel para análisis
   - Incluye todos los campos visibles
   - Útil para reportes gerenciales

### Restricciones

1. **Dependencia de trámites**
   - Requiere ID de trámite existente para bloquear
   - No se puede bloquear RFC sin trámite asociado

2. **RFC no editable**
   - El RFC se extrae del trámite automáticamente
   - No se puede modificar manualmente
   - Para cambiar RFC, debe crearse nuevo bloqueo

3. **Desbloqueo permanente**
   - Una vez desbloqueado (vig = 'C'), no se puede reactivar
   - Para volver a bloquear, debe crearse nuevo registro

4. **Modificación limitada**
   - Solo se puede editar la observación
   - RFC, trámite y licencia no son modificables

### Permisos necesarios

- Acceso al módulo de Padrón y Licencias
- Permisos especiales para gestión de bloqueos
- Acceso de lectura a tablas:
  - bloqueo_rfc_lic
  - Tramites (query VerTramite)
- Acceso de escritura a tabla:
  - bloqueo_rfc_lic
- Permisos de exportación (para generar Excel)

### Recomendaciones de uso

1. **Al bloquear un RFC**
   - Verificar que el trámite sea correcto
   - Capturar motivo claro y completo
   - Incluir referencia a documentos de soporte
   - Documentar situación irregular detectada
   - Conservar expediente de respaldo

2. **Al desbloquear**
   - Validar que se cumplieron los requisitos para liberar
   - Documentar claramente el motivo del desbloqueo
   - Actualizar expediente físico
   - Notificar a áreas involucradas

3. **Para búsquedas**
   - Usar búsqueda por RFC para consultas rápidas
   - Exportar a Excel para análisis periódicos
   - Revisar regularmente bloqueos vigentes
   - Verificar que desbloqueos estén justificados

4. **Control de calidad**
   - Revisar periódicamente bloqueos vigentes
   - Validar que los motivos estén documentados
   - Verificar que RFC bloqueados sean correctos
   - Actualizar estado según sea necesario

5. **Gestión de información**
   - Mantener observaciones actualizadas
   - Archivar documentación de soporte
   - Generar reportes periódicos
   - Comunicar bloqueos a ventanilla
   - Asegurar que personal de captura conozca RFC bloqueados
