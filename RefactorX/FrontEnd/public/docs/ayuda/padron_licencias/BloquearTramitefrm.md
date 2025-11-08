# Bloqueo y Desbloqueo de Trámites

## Descripción General

### ¿Qué hace este módulo?
Permite **bloquear y desbloquear trámites en proceso** para controlar expedientes que requieren atención especial, tienen irregularidades o están en situación de suspensión temporal.

### ¿Para qué sirve en el proceso administrativo?
- Detener proceso de trámites con documentación incompleta
- Bloquear trámites con irregularidades detectadas
- Suspender trámites hasta que el contribuyente cumpla requisitos
- Controlar trámites que requieren validación especial
- Registrar histórico de bloqueos y motivos

### ¿Quiénes lo utilizan?
- **Supervisores de trámites**: Para detener procesos
- **Personal de ventanilla**: Para bloquear por documentación faltante
- **Departamento Jurídico**: Para suspender por irregularidades legales
- **Directores**: Para casos especiales que requieren autorización

## Proceso Administrativo

### Proceso Simplificado

**Bloqueo:**
1. Capturar número de trámite (id_tramite)
2. Enter - Sistema muestra información del trámite
3. Click "Bloquear"
4. InputBox solicita observaciones/motivo
5. Sistema marca tramite.bloqueado = 1
6. Registra en tabla `bloqueo`: bloqueado=1, motivo, fecha, usuario

**Desbloqueo:**
1. Trámite ya consultado
2. Click "Desbloquear"
3. InputBox solicita observaciones/motivo del desbloqueo
4. Sistema marca tramite.bloqueado = 0
5. Registra en tabla `bloqueo`: bloqueado=0, motivo, fecha, usuario

### Diferencias con Bloqueo de Licencias

- **Más simple**: Solo dos estados (bloqueado=0/1, no tiene tipos)
- **Sin bloqueo de domicilio**: No afecta la dirección
- **Temporal**: Pensado para situaciones temporales durante el proceso
- **Menos restrictivo**: No requiere ventana de selección de tipo

## Tablas de Base de Datos

### Tabla Principal
**tramites** - Campo `bloqueado` (0 o 1)

### Tablas que Consulta
1. **giros** - Información del giro solicitado
2. **bloqueos** - Histórico de bloqueos del trámite

### Tablas que Modifica

**1. tramites** (UPDATE)
- Campo `bloqueado`: Cambia entre 0 (desbloqueado) y 1 (bloqueado)

**2. bloqueo** (INSERT)
- **Al bloquear**: Inserta con bloqueado=1, observación, fecha, usuario
- **Al desbloquear**: Inserta con bloqueado=0, observación del desbloqueo
- Campo vigente siempre 'C' para el registro anterior (vía cancelaUltimo)

## Stored Procedures
No utiliza stored procedures.

## Impacto y Repercusiones

### ¿Qué registros afecta?
- Trámite bloqueado/desbloqueado
- Histórico en tabla `bloqueo`

### ¿Qué cambios de estado provoca?
- **Al Bloquear**: tramites.bloqueado = 1
- **Al Desbloquear**: tramites.bloqueado = 0
- Registro en histórico de bloqueos

**Efectos de un Trámite Bloqueado:**
- No puede avanzar en el proceso
- Requiere desbloqueo para continuar
- Se identifica visualmente en consultas
- Alerta al personal que hay situación especial

### ¿Qué documentos genera?
**NINGUNO** - Operación administrativa interna sin documentos.

### ¿Qué validaciones aplica?
1. Valida que el trámite exista
2. Al bloquear: Verifica que no esté ya bloqueado
3. Al desbloquear: Verifica que esté bloqueado
4. Requiere captura de motivo (obligatorio)

## Flujo de Trabajo

```
BLOQUEO:
1. Captura id_tramite
2. Enter - Busca y muestra trámite
3. Verifica estado actual
4. Click "Bloquear"
5. InputBox solicita motivo
6. UPDATE tramites SET bloqueado=1
7. INSERT INTO bloqueo (registro de bloqueo)
8. Deshabilita botón "Bloquear"
9. Habilita botón "Desbloquear"
10. FIN

DESBLOQUEO:
1. Trámite bloqueado ya consultado
2. Click "Desbloquear"
3. InputBox solicita motivo
4. UPDATE tramites SET bloqueado=0
5. INSERT INTO bloqueo (registro de desbloqueo)
6. Habilita botón "Bloquear"
7. Deshabilita botón "Desbloquear"
8. FIN
```

## Notas Importantes

### Consideraciones

**1. Uso Durante Proceso**
- Se usa mientras el trámite está en proceso (no autorizado aún)
- Una vez autorizado y convertido a licencia, se usa módulo de bloqueo de licencias
- Es una herramienta de control de flujo administrativo

**2. Bloqueo Binario**
- Solo dos estados: bloqueado (1) o no bloqueado (0)
- No tiene tipos como las licencias
- Más simple de operar

**3. Registro de Histórico**
- Tabla `bloqueo` guarda todos los bloqueos/desbloqueos
- Útil para auditoría del proceso
- Permite rastrear quién y cuándo bloqueó/desbloqueó

**4. Motivos Comunes de Bloqueo**
- Documentación incompleta
- Inconsistencias en datos
- Pendiente de revisión especial
- Irregularidades detectadas
- Espera de autorización superior

### Restricciones
- No se pueden bloquear trámites ya convertidos a licencia
- No afecta el domicilio
- No tiene tipos diferenciados

### Permisos
- Requiere permiso de modificación de trámites
- Generalmente para supervisores o personal autorizado
- Menos restrictivo que bloqueo de licencias
