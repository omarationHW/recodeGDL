# Bloqueo y Desbloqueo de Licencias

## Descripción General

### ¿Qué hace este módulo?
Permite **bloquear y desbloquear licencias de funcionamiento** aplicando diferentes tipos de bloqueo administrativo o legal. Es una herramienta de control para restringir operaciones sobre licencias que tienen situaciones especiales o irregulares.

### ¿Para qué sirve en el proceso administrativo?
- Bloquear licencias con adeudos para evitar trámites hasta regularizar
- Marcar licencias suspendidas por infracciones
- Identificar licencias con acuerdos de pago (conveniadas)
- Bloquear licencias en proceso de responsiva
- Controlar licencias reglamentadas (cabarets, etc.)
- Registrar histórico de bloqueos y desbloqueos
- Bloquear domicilios completos para prevenir nuevas licencias

### ¿Quiénes lo utilizan?
- **Departamento Jurídico**: Para aplicar sanciones o suspensiones
- **Cobranza**: Para bloquear morosos
- **Supervisores**: Para casos especiales que requieren atención
- **Dirección**: Para autorizar desbloqueos

## Proceso Administrativo

### Tipos de Bloqueo Disponibles

**Tipo 1 - BLOQUEADO**: Bloqueo general administrativo
**Tipo 2 - ESTADO 1**: Bloqueo especial (definido por municipio)
**Tipo 3 - CABARETS**: Licencias de giros reglamentados especiales
**Tipo 4 - SUSPENDIDA**: Suspensión temporal por infracción
**Tipo 5 - RESPONSIVA**: En proceso de cambio de propietario
**Tipo 6 - CONVENIADA**: Con convenio de pago de adeudos
**Tipo 7 - DESGLOSAR LIC**: Licencia en proceso de división

### Proceso de Bloqueo

**1. Búsqueda de Licencia**
- Capturar número de licencia
- Presionar Enter
- Sistema muestra información completa de la licencia

**2. Verificación de Estado**
- Sistema verifica si ya está bloqueada
- Muestra etiqueta: "BLOQUEADO" o "NO BLOQUEADO"

**3. Aplicar Bloqueo**
- Click en botón "Bloquear"
- Sistema abre ventana de selección de tipo de bloqueo
- Usuario selecciona tipo y captura motivo
- Sistema valida que no tenga el mismo tipo de bloqueo activo
- Confirma bloqueo

**4. Registro del Bloqueo**
- Actualiza campo `bloqueado` en tabla licencias
- Inserta registro en tabla `bloqueo` con:
  - id_licencia
  - tipo de bloqueo
  - fecha
  - usuario que bloquea
  - observación/motivo
  - vigente='V'
- Si no es bloqueo tipo 5 (responsiva):
  - Inserta registro en tabla `bloqueo_dom` para bloquear el domicilio completo

**Efecto del Bloqueo de Domicilio:**
- Previene que se tramiten nuevas licencias en esa dirección
- Se valida en módulo de altas de licencias
- Protege contra duplicidad de licencias

### Proceso de Desbloqueo

**1. Selección de Bloqueo**
- Visualiza todos los bloqueos activos en la licencia
- Selecciona el tipo de bloqueo a remover del ComboBox
- Puede tener múltiples bloqueos simultáneos

**2. Captura de Motivo**
- InputBox solicita "Motivo del desbloqueo"
- Usuario captura justificación

**3. Aplicar Desbloqueo**
- Click en "Desbloquear"
- Sistema cancela el bloqueo específico seleccionado:
  - Actualiza registro en tabla `bloqueo`: vigente='C'
- Verifica si quedan otros bloqueos activos:
  - Si NO quedan: Actualiza licencias.bloqueado = 0
  - Si SÍ quedan: Actualiza licencias.bloqueado = tipo del bloqueo más reciente activo
- Inserta nuevo registro en `bloqueo` con observación del desbloqueo (bloqueado=0)

**4. Desbloqueo de Domicilio**
- Si ya NO tiene ningún bloqueo activo:
  - Elimina registro de tabla `bloqueo_dom`
  - Mueve registro a tabla `h_bloqueo_dom` (histórico)
  - El domicilio queda liberado para nuevas licencias

## Tablas de Base de Datos

### Tabla Principal
**licencias** - Contiene campo `bloqueado` (entero)

### Tablas Relacionadas que Consulta
1. **giros** - Información del giro comercial
2. **bloqueos** - Histórico de todos los bloqueos (vigentes y cancelados)
3. **c_tipobloqueo** - Catálogo de tipos de bloqueo
4. **BloqueoActivo** (Query) - Bloqueos vigentes de la licencia

### Tablas que Modifica

**1. licencias** (UPDATE)
- Campo `bloqueado`: Se actualiza al bloquear/desbloquear
- Campo `espubic`: Se puede agregar motivo (código comentado)

**2. bloqueo** (INSERT)
- **Al bloquear**: Inserta registro con tipo, observación, vigente='V'
- **Al desbloquear**: Inserta registro con bloqueado=0, observación del desbloqueo

**3. bloqueo** (UPDATE via cancelaUltimo)
- Cambia vigente='V' a 'C' del bloqueo específico a remover

**4. bloqueo_dom** (INSERT al bloquear)
- Inserta registro bloqueando el domicilio:
  - calle, cvecalle, num_ext, let_ext, num_int, let_int
  - observacion, VIG='V', fecha, capturista

**5. bloqueo_dom** (DELETE al desbloquear)
- Elimina registro si ya NO hay bloqueos activos

**6. h_bloqueo_dom** (INSERT al desbloquear)
- Guarda histórico del bloqueo de domicilio eliminado
- Incluye motivo del desbloqueo y marca "EL" (eliminado desde bloq. lic.)

## Stored Procedures
No utiliza stored procedures. Lógica en código del formulario.

## Impacto y Repercusiones

### ¿Qué registros afecta?
- Licencia bloqueada/desbloqueada
- Histórico de bloqueos en tabla `bloqueo`
- Domicilio (en bloqueo_dom) si no es tipo responsiva

### ¿Qué cambios de estado provoca?

**Al Bloquear:**
- licencias.bloqueado cambia de 0 a [tipo]
- Nuevo registro en bloqueo con vigente='V'
- Si no es tipo 5: Nuevo registro en bloqueo_dom

**Al Desbloquear:**
- bloqueo específico: vigente cambia de 'V' a 'C'
- licencias.bloqueado:
  - Si no quedan bloqueos: = 0
  - Si quedan otros: = tipo del más reciente activo
- Si no quedan bloqueos: Elimina bloqueo_dom, crea histórico

**Restricciones que Provoca un Bloqueo:**
- En módulos de trámites: Impide generar nuevos trámites
- En pagos: Puede requerir autorización especial
- En cambios: Requiere desbloqueo previo
- En domicilio: Impide nuevas licencias en esa dirección

### ¿Qué documentos genera?
**NINGUNO** - No genera documentos impresos. Es operación administrativa interna.

### ¿Qué validaciones aplica?

**Al Bloquear:**
1. Valida que la licencia exista
2. Verifica que no tenga el mismo tipo de bloqueo activo
3. Permite múltiples bloqueos de diferentes tipos simultáneos
4. Requiere captura de motivo

**Al Desbloquear:**
1. Valida que la licencia esté bloqueada
2. Valida que existan bloqueos activos
3. Requiere selección del tipo específico a remover
4. Solicita motivo de desbloqueo
5. Verifica permisos del usuario

## Flujo de Trabajo

### Flujo de Bloqueo

```
1. Captura número de licencia
2. Enter - Sistema busca y muestra licencia
3. Click "Bloquear"
4. Sistema abre ventana frmtipobloqueo
5. Usuario selecciona tipo de bloqueo
6. Usuario captura motivo
7. Sistema valida que no tenga ese tipo activo
8. ¿Validación OK?
   NO → Mensaje error, termina
   SÍ → Continúa
9. UPDATE licencias SET bloqueado=[tipo]
10. INSERT INTO bloqueo (datos del bloqueo)
11. Si tipo <> 5:
    - Verifica si ya tiene algún bloqueo activo
    - Si NO tiene ninguno:
      INSERT INTO bloqueo_dom (bloquea domicilio)
12. Refresca datos en pantalla
13. FIN
```

### Flujo de Desbloqueo

```
1. Licencia ya consultada y bloqueada
2. Usuario selecciona tipo de bloqueo del ComboBox
3. Click "Desbloquear"
4. Sistema valida que haya bloqueo seleccionado
5. InputBox solicita motivo de desbloqueo
6. Usuario captura motivo
7. ¿Capturó motivo?
   NO → Cancela operación
   SÍ → Continúa
8. UPDATE bloqueo SET vigente='C' WHERE tipo=[seleccionado] AND vigente='V'
9. Verifica si quedan otros bloqueos activos
10. ¿Quedan bloqueos?
    SÍ → UPDATE licencias SET bloqueado=[tipo más reciente activo]
    NO → UPDATE licencias SET bloqueado=0
         Y elimina bloqueo_dom:
         - INSERT INTO h_bloqueo_dom (histórico)
         - DELETE FROM bloqueo_dom
11. INSERT INTO bloqueo (registro de desbloqueo con bloqueado=0)
12. Refresca datos
13. FIN
```

## Notas Importantes

### Consideraciones Especiales

**1. Múltiples Bloqueos Simultáneos**
- Una licencia puede tener varios tipos de bloqueo activos a la vez
- Ejemplo: Puede estar suspendida (4) Y conveniada (6)
- Al desbloquear, se remueve solo el tipo seleccionado
- El campo licencias.bloqueado muestra el tipo del bloqueo "principal" o más reciente

**2. Bloqueo de Domicilio**
- Se aplica automáticamente en todos los bloqueos EXCEPTO tipo 5 (responsiva)
- Protege el domicilio para evitar que se tramiten nuevas licencias
- Se valida en módulo de altas de licencias
- Solo se elimina cuando la licencia queda sin NINGÚN bloqueo activo

**3. Histórico de Bloqueos**
- Tabla `bloqueo` guarda histórico completo
- Registros vigentes: vigente='V'
- Registros históricos (desbloqueados): vigente='C'
- Útil para auditorías y seguimiento
- También registra los desbloqueos (con bloqueado=0)

**4. Bloqueo Tipo 6 - CONVENIADA**
- Licencias con convenio de pago
- NO se dan de baja en proceso de bajas masivas
- Requieren manejo especial
- Se desbloquean al cumplir el convenio

**5. Bloqueo Tipo 5 - RESPONSIVA**
- NO bloquea el domicilio
- Se usa para cambios de propietario en proceso
- Permite tramitar la responsiva sin afectar el domicilio

**6. Función TieneBloqueo**
- Verifica si una licencia tiene bloqueo específico activo
- Parámetro tipo=0: Verifica si tiene cualquier bloqueo
- Parámetro tipo>0: Verifica si tiene ese tipo específico
- Retorna el tipo de bloqueo encontrado o 0

### Restricciones

**No se puede:**
- Bloquear con el mismo tipo si ya tiene ese bloqueo activo
- Desbloquear sin capturar motivo
- Desbloquear licencia no bloqueada
- Manipular bloqueado directamente (debe usar este módulo)

**Se debe:**
- Documentar motivos claramente
- Usar tipo de bloqueo adecuado
- Verificar histórico antes de desbloquear
- Coordinar con áreas involucradas (jurídico, cobranza)

### Permisos Necesarios

**Para Bloquear:**
- Usuario con permiso de bloqueo
- Generalmente restringido a supervisores
- Acceso de escritura a tablas: licencias, bloqueo, bloqueo_dom

**Para Desbloquear:**
- Permiso especial (más restrictivo que bloquear)
- Puede requerir autorización de nivel superior
- Casos especiales: requiere visto bueno de jurídico o dirección

### Mantenimiento y Soporte

**Problemas Comunes:**

1. **"La licencia ya está bloqueada por el mismo tipo"**
   - Es una validación, no un error
   - Verificar bloqueos activos
   - Si es necesario, desbloquear primero y volver a bloquear con nuevo motivo

2. **"No se puede desbloquear"**
   - Verificar que tenga bloqueos activos
   - Seleccionar tipo correcto del ComboBox
   - Verificar permisos del usuario

3. **Domicilio sigue bloqueado después de desbloquear**
   - Verificar si quedan otros bloqueos activos en la licencia
   - El domicilio solo se desbloquea cuando NO quedan bloqueos
   - Revisar tabla bloqueo_dom manualmente si es necesario

4. **Campo bloqueado no se actualiza**
   - Refrescar consulta de licencia
   - Verificar query BloqueoActivo
   - Puede haber problema de transacciones

**Respaldos:**
- Tabla bloqueo: Respaldo semanal (histórico importante)
- Tabla bloqueo_dom: Respaldo diario
- Tabla h_bloqueo_dom: Preservar siempre (histórico legal)
