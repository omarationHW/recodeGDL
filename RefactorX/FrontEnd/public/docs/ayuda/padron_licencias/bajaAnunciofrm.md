# Baja de Anuncios

## Descripción General

### ¿Qué hace este módulo?
Este módulo permite dar de baja anuncios publicitarios que han sido registrados en el sistema. Gestiona el proceso completo de cancelación de anuncios, incluyendo la actualización del estado del anuncio, la cancelación de adeudos pendientes y el recálculo de saldos de la licencia asociada.

### ¿Para qué sirve en el proceso administrativo?
- Oficializa el retiro de anuncios publicitarios
- Cancela adeudos pendientes asociados al anuncio
- Actualiza el estado de anuncios en el sistema
- Recalcula los saldos de la licencia de referencia
- Documenta la baja con año y folio de referencia
- Aplica controles especiales según el período del año

### ¿Quiénes lo utilizan?
- Personal de Padrón y Licencias
- Inspectores municipales
- Personal autorizado del departamento de licencias (dependencia 30)
- Supervisores y jefes de departamento con permisos especiales
- Usuarios con nivel 1 del departamento 9 (bajas en cualquier tiempo)

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?

1. **Inicio del proceso**
   - Usuario ingresa número de anuncio
   - Presiona ENTER para buscar

2. **Búsqueda y validación del anuncio**
   - Sistema busca el anuncio en base de datos
   - Carga información de:
     - Datos del anuncio
     - Saldos/adeudos pendientes
     - Licencia asociada

3. **Validaciones automáticas**
   - **Si no existe**: No muestra panel de adeudos y termina
   - **Si ya está dado de baja** (vigente = 'B'):
     - Muestra mensaje: "El anuncio ya se encuentra dado de baja"
     - No permite continuar
   - **Si ya está cancelado** (vigente = 'C'):
     - Muestra mensaje: "El anuncio ya se encuentra cancelado"
     - No permite continuar

4. **Validación de período y adeudos**
   - Si tiene saldos pendientes Y NO es período especial (enero-abril):
     - Muestra panel de adeudos
     - Deshabilita botón "Dar de Baja"
     - Requiere autorización especial (CheckBox2)
   - Si NO tiene adeudos O es período especial:
     - Oculta panel de adeudos
     - Habilita botón "Dar de Baja"
     - Muestra panel para captura de datos de baja

5. **Opciones especiales según permisos**

   **CheckBox1 - Baja por error** (visible solo para ciertos usuarios):
   - Disponible para usuarios de dependencia 30 con nivel > 1
   - Oculta para usuarios fuera de dependencia 30
   - Al activarlo:
     - Oculta panel de adeudos
     - Habilita botón de baja
     - Oculta panel de captura de año/folio

   **CheckBox2 - Baja en tiempo** (visible solo para nivel 1, depto 9):
   - Permite dar de baja aunque haya adeudos fuera del período
   - Al activarlo:
     - Oculta panel de adeudos
     - Habilita botón de baja
     - Oculta panel de captura

6. **Captura de datos de baja**
   - Usuario ingresa:
     - Año de baja (FloatEdit2)
     - Folio de baja (FloatEdit3)
     - Especificación de ubicación (Edit1)

7. **Confirmación final**
   - Sistema muestra: "A continuación se dará de baja el anuncio, ¿desea continuar?"
   - Usuario confirma (Sí/No)

8. **Ejecución de la baja**
   - Actualiza registro del anuncio:
     - vigente = 'C' (Cancelado)
     - fecha_baja = fecha actual
     - axo_baja = año capturado
     - folio_baja = folio capturado
     - espubic = especificación capturada

   - Cancela todos los adeudos asociados:
     - Recorre tabla de saldos
     - Asigna cvepago = 999999 (código de cancelación)

   - Recalcula saldos de la licencia:
     - Ejecuta stored procedure calcSdosLic
     - Actualiza saldos totales de la licencia

9. **Finalización**
   - Deshabilita botón de baja
   - Proceso completado

### ¿Qué información requiere el usuario?

**Datos obligatorios:**
- **Número de anuncio**: Identificador del anuncio a dar de baja

**Datos opcionales (según caso):**
- **Año de baja**: Año de referencia del documento de baja (si aplica)
- **Folio de baja**: Número de folio del documento de baja (si aplica)
- **Especificación de ubicación**: Información adicional sobre la ubicación del anuncio

**Permisos especiales:**
- CheckBox de baja por error (solo usuarios autorizados)
- CheckBox de baja en tiempo (solo nivel 1, depto 9)

### ¿Qué validaciones se realizan?

1. **Validación de existencia**
   - Verifica que el número de anuncio exista
   - Si no existe, no permite continuar

2. **Validación de estado actual**
   - Verifica si ya está dado de baja (vigente = 'B')
   - Verifica si ya está cancelado (vigente = 'C')
   - Muestra mensaje apropiado y bloquea proceso

3. **Validación de adeudos y período**
   - Si tiene saldos Y NO es enero-abril Y NO hay autorización especial:
     - Bloquea la baja
     - Muestra panel de adeudos
   - Período especial (enero-abril): permite baja aunque haya adeudos

4. **Validación de datos de baja**
   - Si NO está marcado CheckBox1 ni CheckBox2:
     - Requiere año y folio de baja
     - Muestra mensaje: "Debes indicar año y folio"

5. **Validación de permisos de usuario**
   - Valida nivel del usuario
   - Valida dependencia del usuario (30)
   - Valida departamento del usuario (9)
   - Habilita/deshabilita opciones especiales según permisos

### ¿Qué documentos genera?
Este módulo NO genera documentos impresos. Es un proceso de actualización de registros en base de datos.

## Tablas de Base de Datos

### Tabla Principal
**anuncio**
- Contiene el registro de todos los anuncios publicitarios
- Se actualiza con la información de baja

### Tablas Relacionadas

#### Tablas que Consulta:
- **anuncio**: Obtiene información completa del anuncio a dar de baja
- **saldos**: Consulta adeudos pendientes asociados al anuncio
- **licencia**: Obtiene datos de la licencia asociada al anuncio
- **usr** (usuarios): Valida permisos del usuario que ejecuta la baja
  - nivel: Nivel de acceso del usuario
  - cvedependencia: Dependencia a la que pertenece
  - cvedepto: Departamento del usuario

#### Tablas que Modifica:
- **anuncio**:
  - UPDATE: Campos modificados:
    - vigente = 'C' (Cancelado)
    - fecha_baja = fecha actual del sistema
    - axo_baja = año capturado por usuario
    - folio_baja = folio capturado por usuario
    - espubic = especificación de ubicación

- **saldos** (detalle de adeudos):
  - UPDATE: Todos los registros asociados al anuncio
  - Campo modificado:
    - cvepago = 999999 (código que indica cancelación)

## Stored Procedures

### calcSdosLic
**Propósito**: Recalcula los saldos totales de una licencia después de cancelar adeudos de un anuncio

**Parámetros**:
- id_licencia: Identificador de la licencia a recalcular

**Funcionalidad**:
- Suma todos los adeudos vigentes de la licencia
- Actualiza el saldo total de la licencia
- Excluye adeudos cancelados (cvepago = 999999)

**Cuándo se ejecuta**:
- Después de dar de baja un anuncio y cancelar sus adeudos
- Garantiza que los saldos de la licencia reflejen correctamente los adeudos reales

## Impacto y Repercusiones

### ¿Qué registros afecta?

1. **Registro del anuncio**
   - Cambia estado de vigente a cancelado
   - Registra fecha, año y folio de baja
   - Guarda especificación de ubicación

2. **Adeudos del anuncio**
   - Cancela TODOS los saldos pendientes asociados
   - No elimina los registros, los marca como cancelados

3. **Saldo de la licencia**
   - Actualiza el saldo total de la licencia de referencia
   - Refleja la cancelación de adeudos del anuncio

### ¿Qué cambios de estado provoca?

1. **Estado del anuncio**
   - De vigente ('V') a cancelado ('C')
   - Cambio es permanente e irreversible

2. **Estado de adeudos**
   - Todos los saldos se marcan como pagados/cancelados
   - cvepago = 999999 indica cancelación administrativa

3. **Saldo de licencia**
   - Se reduce por el monto de los adeudos cancelados
   - Refleja la nueva situación financiera

### ¿Qué documentos/reportes genera?
Ninguno. Este es un módulo de proceso administrativo que actualiza registros en base de datos. No genera reportes impresos.

### ¿Qué validaciones de negocio aplica?

1. **Control por período del año**
   - Enero-Abril: Permite baja incluso con adeudos (período de regularización)
   - Mayo-Diciembre: Requiere autorización especial si hay adeudos

2. **Prevención de duplicados**
   - No permite dar de baja un anuncio ya cancelado
   - Valida estado actual antes de proceder

3. **Trazabilidad**
   - Registra año y folio de documento de baja
   - Guarda especificación de ubicación
   - Registra fecha exacta de la baja

4. **Control de permisos**
   - Baja por error: Solo usuarios autorizados de dependencia 30
   - Baja en tiempo: Solo nivel 1 del departamento 9
   - Usuarios generales: Solo en período sin adeudos

5. **Integridad de saldos**
   - Cancela adeudos automáticamente
   - Recalcula saldos de licencia
   - Mantiene consistencia en registros financieros

## Flujo de Trabajo

```
INICIO
  ↓
Ingresar número de anuncio
  ↓
Presionar ENTER
  ↓
Buscar anuncio, saldos y licencia
  ↓
¿Existe? → NO → Ocultar panel adeudos, FIN
  ↓ SÍ
¿Estado = 'B'? → SÍ → Mensaje "Ya dado de baja", FIN
  ↓ NO
¿Estado = 'C'? → SÍ → Mensaje "Ya cancelado", FIN
  ↓ NO
¿Tiene adeudos? → NO → Habilitar baja, ir a CAPTURA
  ↓ SÍ
¿Es enero-abril? → SÍ → Habilitar baja, ir a CAPTURA
  ↓ NO
┌────────────────────────────────┐
│ VALIDACIÓN DE PERMISOS         │
├────────────────────────────────┤
│ Usuario dependencia 30, nivel>1│ → CheckBox1 visible
│ Usuario nivel 1, depto 9       │ → CheckBox2 visible
│ Otros usuarios                 │ → Mostrar adeudos, bloquear baja
└────────────────────────────────┘
  ↓
¿CheckBox1 activado? → SÍ → Habilitar baja, ocultar captura
  ↓ NO
¿CheckBox2 activado? → SÍ → Habilitar baja, ocultar captura
  ↓ NO
Mostrar panel adeudos, bloquear baja, FIN
  ↓
CAPTURA:
  ↓
¿Checkbox1 o 2? → SÍ → Omitir captura año/folio
  ↓ NO
Capturar año de baja
  ↓
Capturar folio de baja
  ↓
Capturar especificación ubicación
  ↓
Clic en "Dar de Baja"
  ↓
¿Año y folio capturados? → NO → Mensaje error, retornar
  ↓ SÍ
Mostrar confirmación
  ↓
¿Usuario confirma? → NO → FIN
  ↓ SÍ
Actualizar anuncio:
  - vigente = 'C'
  - fecha_baja = hoy
  - axo_baja, folio_baja, espubic
  ↓
Cancelar adeudos:
  - Recorrer tabla saldos
  - cvepago = 999999
  ↓
Ejecutar SP calcSdosLic
  - Recalcular saldos de licencia
  ↓
Deshabilitar botón baja
  ↓
FIN
```

## Notas Importantes

### Consideraciones especiales

1. **Período de regularización (enero-abril)**
   - Durante estos meses se permite dar de baja anuncios aunque tengan adeudos
   - Es el período donde se regulariza la situación de anuncios
   - No requiere autorizaciones especiales

2. **Cancelación de adeudos**
   - Los adeudos NO se eliminan físicamente
   - Se marcan con cvepago = 999999 (cancelación administrativa)
   - Permanecen en el sistema para auditoría

3. **Recálculo automático de saldos**
   - El sistema recalcula automáticamente los saldos de la licencia
   - Garantiza que los totales sean correctos
   - Proceso transparente para el usuario

4. **Baja por error**
   - Opción especial para corregir altas erróneas
   - No requiere captura de año/folio de baja
   - Restringida a personal autorizado

### Restricciones

1. **Permanencia de la baja**
   - Una vez dado de baja, el anuncio no puede reactivarse
   - El proceso es irreversible
   - Requiere nuevo trámite para dar de alta nuevamente

2. **Período restrictivo (mayo-diciembre)**
   - No se puede dar de baja anuncios con adeudos
   - Excepto con autorizaciones especiales (CheckBox1 o 2)
   - Protege contra bajas que dejen adeudos sin cobrar

3. **Validación de estado**
   - No permite procesar anuncios ya dados de baja
   - No permite procesar anuncios ya cancelados
   - Previene duplicidad de operaciones

4. **Permisos jerárquicos**
   - Cada tipo de baja especial requiere permisos específicos
   - Los permisos están vinculados a nivel, dependencia y departamento
   - No son configurables desde este módulo

### Permisos necesarios

**Acceso básico:**
- Acceso al módulo de Padrón y Licencias
- Permisos de lectura en tablas:
  - anuncio
  - saldos
  - licencia
  - usr

**Permisos de escritura:**
- Modificar tabla anuncio
- Modificar tabla saldos
- Ejecutar stored procedure calcSdosLic

**Permisos especiales:**
- **Baja por error (CheckBox1)**:
  - Dependencia = 30 (Padrón y Licencias)
  - Nivel > 1 (supervisor o superior)

- **Baja en tiempo (CheckBox2)**:
  - Nivel = 1 (jefe de departamento)
  - Departamento = 9

### Recomendaciones de uso

1. **Antes de dar de baja**
   - Verificar que sea el anuncio correcto
   - Consultar historial de pagos
   - Validar que corresponda al establecimiento indicado
   - Revisar adeudos pendientes

2. **Durante el proceso**
   - Capturar correctamente año y folio de referencia
   - Incluir especificación de ubicación cuando sea relevante
   - Verificar dos veces antes de confirmar
   - Documentar el motivo de la baja en expediente físico

3. **Después de la baja**
   - Verificar que los saldos se hayan actualizado correctamente
   - Confirmar que los adeudos se cancelaron
   - Archivar documentación de respaldo
   - Notificar al contribuyente si es necesario

4. **Uso de opciones especiales**
   - CheckBox1 (baja por error): Solo para correcciones de altas equivocadas
   - CheckBox2 (baja en tiempo): Solo cuando exista justificación administrativa
   - Documentar siempre el uso de estas opciones

5. **Control de calidad**
   - Revisar que el anuncio realmente deba darse de baja
   - Confirmar que no existan trámites pendientes asociados
   - Validar con inspección física cuando sea posible
   - Mantener expediente completo y ordenado
