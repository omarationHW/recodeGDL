# Cancelación de Trámites

## Descripción General

### ¿Qué hace este módulo?
Este módulo permite cancelar trámites de licencias que fueron ingresados al sistema pero que por diversas razones administrativas no pueden o no deben continuar su proceso de revisión y aprobación.

### ¿Para qué sirve en el proceso administrativo?
- Cancela trámites que no cumplieron requisitos
- Detiene el proceso de revisión de solicitudes
- Documenta el motivo de cancelación
- Actualiza el estatus del trámite a cancelado
- Permite depurar trámites incorrectos o duplicados
- Registra la razón administrativa de la cancelación

### ¿Quiénes lo utilizan?
- Personal de Padrón y Licencias con autoridad para cancelar
- Jefes del Departamento de Padrón y Licencias
- Personal administrativo autorizado
- Supervisores con permisos especiales

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?

1. **Búsqueda del trámite**
   - Usuario ingresa el ID del trámite (número de trámite)
   - Presiona ENTER

2. **Carga de información del trámite**
   - Sistema consulta tabla de trámites
   - Muestra información completa:
     - Datos del propietario
     - Domicilio del establecimiento
     - Giro comercial solicitado
     - Ubicación del negocio
     - Fechas del trámite

3. **Validación de existencia**
   - Si el trámite existe:
     - Habilita botón "Dar de Baja"
     - Muestra todos los datos
   - Si NO existe:
     - Deshabilita botón "Dar de Baja"
     - No permite continuar

4. **Intento de cancelación**
   - Usuario presiona botón "Dar de Baja"
   - Sistema realiza validaciones automáticas

5. **Validaciones de estado**

   **Validación 1 - Trámite ya cancelado:**
   - Verifica si estatus = 'C' (Cancelado)
   - Si ya está cancelado:
     - Muestra mensaje: "El trámite ya se encuentra cancelado..."
     - No permite continuar
     - Termina proceso

   **Validación 2 - Trámite aprobado:**
   - Verifica si estatus = 'A' (Aprobado)
   - Si ya está aprobado:
     - Muestra mensaje: "El trámite ya se encuentra aprobado... No se podrá cancelar."
     - BLOQUEA la cancelación
     - Termina proceso
     - Nota: Trámites aprobados NO pueden cancelarse

6. **Confirmación de cancelación**
   - Si pasa validaciones, sistema muestra:
     - "¿Está seguro de cancelar el trámite?"
   - Usuario confirma (Sí/No)

7. **Captura de motivo**
   - Sistema solicita motivo mediante InputBox
   - Campo: "Ingrese el motivo de la cancelación"
   - Usuario captura justificación

8. **Procesamiento de la cancelación**
   - Sistema prepara el motivo:
     - Antepone texto: "CANCELADO POR PADRON Y LICENCIAS."
     - Agrega motivo capturado por usuario
   - Abre tablas de revisiones

9. **Actualización del trámite**
   - Edita registro del trámite
   - Actualiza campos:
     - estatus = 'C' (Cancelado)
     - espubic = motivo completo de cancelación
   - Guarda cambios

10. **Cierre del proceso**
    - Las revisiones asociadas quedan tal como están
    - No se modifican las revisiones de dependencias
    - Proceso completado

### ¿Qué información requiere el usuario?

**Datos obligatorios:**
- **ID del trámite**: Número único del trámite a cancelar
- **Motivo de cancelación**: Justificación clara y completa de por qué se cancela

### ¿Qué validaciones se realizan?

1. **Validación de existencia del trámite**
   - Verifica que el ID de trámite exista en el sistema
   - Solo habilita cancelación si el trámite es válido

2. **Validación de estado cancelado**
   - Impide cancelar un trámite que ya está cancelado
   - Evita duplicidad de operaciones

3. **Validación de estado aprobado**
   - **BLOQUEO CRÍTICO**: No permite cancelar trámites aprobados
   - Protege licencias ya otorgadas
   - Mensaje claro: "No se podrá cancelar"

4. **Validación de campos calculados**
   - El sistema calcula automáticamente el campo propietarionvo
   - Concatena: primer apellido + segundo apellido + nombre

5. **Confirmación obligatoria**
   - Requiere confirmación explícita del usuario
   - Doble validación antes de proceder

### ¿Qué documentos genera?
Este módulo NO genera documentos impresos. Es un proceso de actualización administrativa en la base de datos.

## Tablas de Base de Datos

### Tabla Principal
**tramites**
- Contiene todos los trámites de licencias registrados
- Se actualiza con la cancelación

### Tablas Relacionadas

#### Tablas que Consulta:
- **tramites**: Obtiene información completa del trámite
  - Datos del propietario (primer_ap, segundo_ap, propietario)
  - Datos del establecimiento
  - Giro comercial
  - Ubicación
  - Estatus actual
  - Fechas relevantes

- **giros**: Consulta información del giro comercial solicitado
  - Descripción del giro
  - Tipo de actividad

- **revisiones**: Consulta las revisiones asociadas al trámite
  - Estatus de cada revisión por dependencia

- **segRevision**: Consulta el seguimiento detallado de cada revisión
  - Historial de cambios de estatus
  - Observaciones de cada dependencia

#### Tablas que Modifica:
- **tramites**:
  - UPDATE: Campos modificados:
    - estatus = 'C' (Cancelado)
    - espubic = "CANCELADO POR PADRON Y LICENCIAS." + motivo

- **Nota importante sobre revisiones**:
  - El código contiene sección comentada que PODRÍA cancelar revisiones
  - En la versión actual, las revisiones NO se modifican
  - Las revisiones quedan tal como las dejaron las dependencias
  - Esto es intencional para mantener historial de revisiones

## Stored Procedures
Este módulo no utiliza stored procedures. Realiza operaciones mediante queries SQL directas.

## Impacto y Repercusiones

### ¿Qué registros afecta?

1. **Registro del trámite**
   - Cambia estatus de 'En proceso' o 'Pendiente' a 'Cancelado'
   - Guarda motivo completo de cancelación en campo espubic

2. **Revisiones asociadas** (NO se modifican en versión actual)
   - Las revisiones permanecen en su estado actual
   - No se cancelan automáticamente
   - Mantienen observaciones de cada dependencia

### ¿Qué cambios de estado provoca?

1. **Estado del trámite**
   - De estado original (P=Pendiente, etc.) a 'C' (Cancelado)
   - Cambio es permanente
   - Trámite queda fuera del flujo de revisión

2. **Efecto en el proceso**
   - El trámite no continuará su proceso de aprobación
   - No se generará licencia
   - Dependencias dejan de revisarlo
   - Queda registro de la cancelación

### ¿Qué documentos/reportes genera?
Ninguno. Este es un módulo de proceso administrativo que actualiza el estado del trámite en base de datos.

### ¿Qué validaciones de negocio aplica?

1. **Protección de trámites aprobados**
   - **CRÍTICO**: No permite cancelar trámites con estatus 'A' (Aprobado)
   - Protege licencias ya otorgadas
   - Previene errores administrativos graves

2. **Prevención de duplicados**
   - No permite cancelar un trámite ya cancelado
   - Evita operaciones redundantes

3. **Trazabilidad**
   - Registra motivo completo de cancelación
   - Identifica origen: "CANCELADO POR PADRON Y LICENCIAS"
   - Mantiene justificación capturada por usuario

4. **Preservación de historial de revisiones**
   - No altera las revisiones de dependencias
   - Mantiene registro de opiniones técnicas emitidas
   - Permite auditoría del proceso completo

## Flujo de Trabajo

```
INICIO
  ↓
Ingresar ID de trámite
  ↓
Presionar ENTER
  ↓
Buscar trámite en base de datos
  ↓
¿Existe trámite? → NO → Deshabilitar "Dar de Baja", FIN
  ↓ SÍ
Cargar y mostrar:
  - Datos del propietario
  - Giro comercial
  - Ubicación del establecimiento
  - Información del trámite
  ↓
Habilitar botón "Dar de Baja"
  ↓
Usuario presiona "Dar de Baja"
  ↓
VALIDACIÓN 1:
¿Estatus = 'C'? → SÍ → Mensaje "Ya cancelado", FIN
  ↓ NO
VALIDACIÓN 2:
¿Estatus = 'A'? → SÍ → Mensaje "Ya aprobado, no se puede cancelar", FIN
  ↓ NO
Mostrar confirmación
  ↓
¿Usuario confirma? → NO → FIN
  ↓ SÍ
Solicitar motivo de cancelación
  ↓
Usuario captura justificación
  ↓
Preparar motivo completo:
  "CANCELADO POR PADRON Y LICENCIAS." + motivo
  ↓
Abrir tablas:
  - revisiones
  - segRevision
  ↓
Editar registro del trámite
  ↓
Actualizar campos:
  - estatus = 'C'
  - espubic = motivo completo
  ↓
Guardar cambios
  ↓
FIN
```

## Notas Importantes

### Consideraciones especiales

1. **Trámites aprobados NO pueden cancelarse**
   - Esta es una restricción ABSOLUTA del sistema
   - Protege licencias ya otorgadas
   - Si se requiere revertir licencia aprobada, debe usarse otro proceso

2. **Motivo estandarizado**
   - Todos los motivos inician con: "CANCELADO POR PADRON Y LICENCIAS."
   - Identifica claramente el origen de la cancelación
   - Diferencia de cancelaciones por otras causas

3. **Revisiones no se cancelan**
   - Las opiniones técnicas de dependencias se preservan
   - Historial de revisiones permanece intacto
   - Permite analizar qué revisiones se habían realizado

4. **Campo calculado propietarionvo**
   - Se genera automáticamente al consultar
   - Concatena primer apellido + segundo apellido + nombre
   - Facilita la identificación del solicitante

### Restricciones

1. **Cancelación permanente**
   - Una vez cancelado, el trámite no puede reactivarse
   - El estatus 'C' es final
   - Para procesar nuevamente, debe iniciarse nuevo trámite

2. **No permite cancelar aprobados**
   - Trámites con estatus 'A' están protegidos
   - No existe override para esta regla
   - Debe usarse proceso de baja de licencia si aplica

3. **Motivo obligatorio**
   - No se puede cancelar sin capturar justificación
   - El motivo queda registrado permanentemente

### Permisos necesarios

- Acceso al módulo de Padrón y Licencias
- Permisos para cancelación de trámites
- Acceso de lectura a tablas:
  - tramites
  - giros
  - revisiones
  - segRevision
- Acceso de escritura a tabla:
  - tramites (campo estatus y espubic)

### Recomendaciones de uso

1. **Antes de cancelar un trámite**
   - Verificar que sea el trámite correcto
   - Revisar el estatus actual
   - Confirmar que no esté aprobado
   - Validar motivo de cancelación con supervisor
   - Documentar en expediente físico

2. **Al capturar el motivo**
   - Ser claro y específico
   - Incluir razón administrativa precisa
   - Ejemplos de motivos válidos:
     - "Documentación incompleta y contribuyente no respondió en tiempo"
     - "Duplicado del trámite XXXX"
     - "Contribuyente desistió de la solicitud"
     - "No cumple requisitos de uso de suelo"
     - "Información falsa en documentos presentados"

3. **Después de cancelar**
   - Notificar al contribuyente (si aplica)
   - Actualizar expediente físico
   - Registrar en bitácora departamental
   - Si pagó derechos, gestionar devolución según proceda

4. **Para casos especiales**
   - Si necesita cancelar trámite aprobado: Consultar con área jurídica
   - Si es error de captura: Documentar claramente
   - Si es duplicado: Referenciar el trámite correcto
   - Si es por irregularidades: Incluir número de oficio o documento de soporte

5. **Control de calidad**
   - Revisar periódicamente trámites cancelados
   - Analizar motivos recurrentes
   - Identificar áreas de mejora en el proceso
   - Capacitar personal para evitar cancelaciones por errores de captura
   - Mantener estadísticas de cancelaciones

### Diferencia con otros procesos

**Cancelar Trámite vs. Dar de Baja Licencia:**
- Cancelar Trámite: Solicitud que aún NO está aprobada
- Baja de Licencia: Licencia ya otorgada y en operación

**Cancelar Trámite vs. Rechazar Revisión:**
- Cancelar Trámite: Decisión administrativa de Padrón y Licencias
- Rechazar Revisión: Opinión técnica negativa de una dependencia

**Estados posibles de un trámite:**
- P = Pendiente (recién ingresado)
- R = En revisión
- C = Cancelado (por este módulo)
- A = Aprobado (NO puede cancelarse)
- N = Negado (por dictamen de dependencias)
