# Cambio de Estatus de Revisiones

## Descripción General

### ¿Qué hace este módulo?
Este módulo permite cambiar el estatus de una revisión de trámite que está siendo evaluada por una dependencia. Proporciona opciones para aprobar, rechazar, prorrogar, requerir información adicional o programar nueva revisión.

### ¿Para qué sirve en el proceso administrativo?
- Actualiza el estado de revisiones de trámites
- Permite aprobar revisiones con calificación
- Facilita el rechazo de trámites con justificación
- Gestiona prórrogas con nueva fecha
- Documenta solicitudes de información adicional
- Programa nuevas fechas de revisión
- Registra decisiones de las dependencias revisoras

### ¿Quiénes lo utilizan?
- Personal de dependencias que revisan trámites
- Inspectores de Protección Civil
- Personal de Desarrollo Urbano
- Revisores de Salud
- Revisores de Medio Ambiente
- Cualquier dependencia que participe en dictaminación

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?

1. **Apertura del módulo**
   - Sistema muestra ventana con opciones de estatus
   - Muestra estatus actual de la revisión (label_estatus)
   - Presenta RadioGroup1 con 5 opciones de nuevo estatus

2. **Visualización de estatus actual**
   - Label muestra el estado en que se encuentra la revisión
   - Sirve como referencia para el usuario

3. **Selección de nuevo estatus**
   - Usuario selecciona una opción del RadioGroup1:
     - **Opción 1**: Rechazada (C)
     - **Opción 2**: Prórroga (P)
     - **Opción 3**: Aprobada (A)
     - **Opción 4**: Información Adicional (N)
     - **Opción 5**: Nueva Revisión (O)

4. **Habilitación de campos según opción**

   **Si selecciona Prórroga (opción 2) o Nueva Revisión (opción 5):**
   - Habilita DateEdit1 (fecha de prórroga/nueva revisión)
   - Usuario debe capturar nueva fecha

   **Si selecciona Aprobada (opción 3):**
   - Habilita CurrencyEdit1 (calificación)
   - Habilita DateEdit2 (fecha de consejo)
   - Usuario debe capturar:
     - Calificación numérica
     - Fecha en que se aprobó en consejo

   **Otras opciones:**
   - No requieren campos adicionales

5. **Confirmación del cambio**
   - Usuario presiona botón "Aceptar" (BitBtn2)

6. **Validaciones antes de guardar**

   **Para Prórroga (opción 2):**
   - Si DateEdit1 está vacío y usuario no confirma:
     - Muestra: "No se ha indicado fecha de prórroga. ¿Desea continuar?"
     - Si dice No: Cancela operación
   - Asigna: nuevoEstado = 'P'

   **Para Aprobada (opción 3):**
   - Si CurrencyEdit1 = 0 O DateEdit2 está vacío:
     - Muestra: "Debes asignar la calificación y la fecha de consejo"
     - No permite continuar
   - Asigna: nuevoEstado = 'A'

   **Para Nueva Revisión (opción 5):**
   - Si DateEdit1 está vacío:
     - Muestra: "Debes indicar la nueva fecha de revisión"
     - No permite continuar
   - Asigna: nuevoEstado = 'O'

   **Para Rechazada (opción 1):**
   - Asigna: nuevoEstado = 'C'

   **Para Información Adicional (opción 4):**
   - Asigna: nuevoEstado = 'N'

7. **Almacenamiento del nuevo estado**
   - Variable nuevoEstado contiene el código del nuevo estatus
   - Variable es accesible desde módulo padre (revisionesfrm)

8. **Cierre del módulo**
   - Sistema cierra ventana
   - Módulo padre toma nuevoEstado y actualiza la revisión

#### CANCELACIÓN

1. **Usuario cancela**
   - Presiona botón "Cancelar" (BitBtn1)

2. **Limpieza**
   - Asigna: nuevoEstado = ''
   - Indica que no hubo cambio

3. **Cierre**
   - Sistema cierra ventana
   - Módulo padre detecta nuevoEstado vacío y no hace cambios

### ¿Qué información requiere el usuario?

#### Datos según tipo de estatus:

**Para Rechazada:**
- Ningún dato adicional (solo la selección)

**Para Prórroga:**
- **Fecha de prórroga** (opcional pero recomendado): Nueva fecha límite de revisión

**Para Aprobada:**
- **Calificación** (obligatorio): Valor numérico de evaluación
- **Fecha de consejo** (obligatorio): Fecha en que se aprobó

**Para Información Adicional:**
- Ningún dato adicional

**Para Nueva Revisión:**
- **Fecha de nueva revisión** (obligatorio): Cuándo se revisará nuevamente

### ¿Qué validaciones se realizan?

1. **Validación de selección de estatus**
   - Sistema verifica que RadioGroup tenga selección (itemindex <> -1)
   - Si no hay selección: Muestra "Debes seleccionar un nuevo status"

2. **Validación de fecha de prórroga**
   - Si DateEdit1 vacío, pregunta confirmación
   - Permite continuar con confirmación del usuario

3. **Validación de aprobación**
   - Requiere calificación > 0
   - Requiere fecha de consejo válida
   - Bloquea si falta alguno

4. **Validación de nueva revisión**
   - Requiere fecha válida obligatoriamente
   - No permite continuar sin fecha

5. **Visibilidad de campos**
   - CurrencyEdit1 y CurrencyEdit2 pueden estar visibles u ocultos
   - Validación solo aplica si están visibles

### ¿Qué documentos genera?
Ninguno. Este módulo actualiza el estado de la revisión en memoria.

## Tablas de Base de Datos

### Tablas que Consulta
**Ninguna directamente**. Este módulo trabaja con variables en memoria.

### Tablas que Modifica
**Ninguna directamente**. El módulo padre (revisionesfrm) es quien actualiza:
- Tabla **revisiones**: Campo estatus
- Tabla **segRevision**: Seguimiento de cambios de estatus

## Stored Procedures
No utiliza stored procedures.

## Impacto y Repercusiones

### ¿Qué registros afecta?

**En memoria (temporal):**
1. **Variable nuevoEstado** (tipo String)
   - Definida en módulo padre (revisionesfrm)
   - Almacena código del nuevo estatus:
     - 'C' = Rechazada
     - 'P' = Prórroga
     - 'A' = Aprobada
     - 'N' = Requiere información
     - 'O' = Nueva revisión

**En base de datos (posterior, por módulo padre):**
- **Tabla revisiones**:
  - Campo estatus: Se actualiza con nuevoEstado
  - Campo fecha relevante según el caso

- **Tabla segRevision** (seguimiento):
  - Inserta registro con el cambio de estatus
  - Documenta fecha/hora del cambio
  - Registra usuario que hizo el cambio

### ¿Qué cambios de estado provoca?

**Estados posibles:**
1. **'C' - Rechazada**
   - Revisión no aprobada
   - Bloquea avance del trámite
   - Requiere acción correctiva

2. **'P' - Prórroga**
   - Extiende tiempo de revisión
   - Nueva fecha límite
   - Trámite sigue en proceso

3. **'A' - Aprobada**
   - Revisión favorable
   - Incluye calificación
   - Permite avance del trámite

4. **'N' - Información Adicional**
   - Requiere documentos o datos adicionales
   - Suspende temporalmente
   - Espera respuesta del contribuyente

5. **'O' - Nueva Revisión**
   - Programa nueva inspección
   - Nueva fecha de revisión
   - Requiere seguimiento

### ¿Qué documentos/reportes genera?
Ninguno.

### ¿Qué validaciones de negocio aplica?

1. **Aprobación requiere datos completos**
   - No permite aprobar sin calificación
   - Requiere fecha de consejo
   - Asegura trazabilidad de aprobaciones

2. **Prórrogas documentadas**
   - Recomienda fecha de prórroga
   - Permite rastrear extensiones de tiempo

3. **Nuevas revisiones programadas**
   - Obliga a establecer fecha
   - Asegura seguimiento del trámite

## Flujo de Trabajo

```
INICIO (FormShow)
  ↓
Limpiar campos:
  - dateedit1 = '  /  /  '
  - currencyedit1 = 0
  - currencyedit2 = 0
  - dateedit2 = '  /  /  '
  ↓
Mostrar estatus actual en label_estatus
  ↓
Usuario selecciona opción en RadioGroup1
  ↓
Evento RadioGroup1Click:
  ↓
¿Opción = 2 (Prórroga) o 5 (Nueva Rev.)? → SÍ → Habilitar DateEdit1
  ↓ NO
Deshabilitar DateEdit1
  ↓
¿CurrencyEdit1 visible Y opción = 3 (Aprobada)? → SÍ → Habilitar:
  ↓ NO                                                   - CurrencyEdit1
Deshabilitar CurrencyEdit1 y DateEdit2                  - DateEdit2
  ↓
Usuario presiona botón:
  ↓
┌──────────────┬───────────────┐
│   Aceptar    │   Cancelar    │
└──────────────┴───────────────┘
       ↓              ↓
Validar selección   nuevoEstado = ''
       ↓              Cerrar
¿RadioGroup.itemindex = -1? → SÍ → Mensaje error
       ↓ NO
Evaluar opción seleccionada:
       ↓
┌──────┴──────┬─────────┬─────────┬─────────┐
│      1      │    2    │    3    │    4    │    5
│ Rechazada   │Prórroga │Aprobada │Info Adic│Nueva Rev.
└─────────────┴─────────┴─────────┴─────────┴─────────┘
      ↓           ↓         ↓          ↓         ↓
nuevoEstado   ¿Fecha?   ¿Calif    nuevoEstado ¿Fecha?
    = 'C'     vacía?    y Fecha?     = 'N'    vacía?
              → SÍ      → NO         Cerrar    → SÍ
              Confirmar Mensaje              Mensaje
              → NO      error                 error
              nuevoEstado                     → NO
                = 'P'                      nuevoEstado
              Cerrar   → SÍ                   = 'O'
                      nuevoEstado             Cerrar
                        = 'A'
                       Cerrar
      ↓
Cerrar ventana
      ↓
Módulo padre recibe nuevoEstado
      ↓
FIN
```

## Notas Importantes

### Consideraciones especiales

1. **Variable compartida**
   - nuevoEstado es global en módulo padre
   - Persiste después de cerrar ventana
   - Módulo padre la usa para actualizar BD

2. **Campos condicionales**
   - Algunos campos solo se habilitan según opción
   - CurrencyEdit1 puede estar oculto en algunas versiones
   - Validaciones adaptan según campos visibles

3. **Fechas especiales**
   - DateEdit1: Multiuso (prórroga o nueva revisión)
   - DateEdit2: Específico para fecha de consejo
   - Formato: '  /  /  ' cuando vacío

4. **Calificaciones**
   - CurrencyEdit1: Calificación numérica
   - CurrencyEdit2: Otro valor numérico (uso variable)
   - Solo relevante para aprobaciones

### Restricciones

1. **Una opción a la vez**
   - Solo se puede seleccionar un nuevo estado
   - No permite estados compuestos

2. **Validaciones estrictas para aprobación**
   - Aprobación requiere datos completos
   - No permite aprobar sin calificación y fecha

3. **Fechas obligatorias para algunas opciones**
   - Nueva revisión DEBE tener fecha
   - Aprobación DEBE tener fecha de consejo
   - Prórroga recomienda fecha

### Permisos necesarios

- Acceso al módulo de revisiones
- Permisos de la dependencia correspondiente
- No requiere permisos especiales de BD (no modifica directamente)

### Recomendaciones de uso

1. **Al rechazar (C)**
   - Asegurar que haya motivo válido
   - Documentar razones en observaciones (en módulo padre)
   - Notificar al contribuyente

2. **Al otorgar prórroga (P)**
   - Siempre indicar nueva fecha
   - Justificar la extensión
   - Coordinar con otras dependencias

3. **Al aprobar (A)**
   - Verificar que se cumplieron todos los requisitos
   - Asignar calificación apropiada
   - Registrar fecha de consejo correcta
   - Confirmar que inspección fue completa

4. **Al solicitar información (N)**
   - Ser específico sobre qué se requiere
   - Establecer plazo para respuesta
   - Coordinar con contribuyente

5. **Al programar nueva revisión (O)**
   - Coordinar fecha con contribuyente
   - Asegurar disponibilidad de inspector
   - Considerar tiempo razonable para preparación

### Códigos de estatus y significado

| Código | Nombre | Significado | Requiere |
|--------|--------|-------------|----------|
| C | Rechazada | No cumple requisitos | Nada |
| P | Prórroga | Necesita más tiempo | Fecha (opcional) |
| A | Aprobada | Cumple requisitos | Calificación + Fecha consejo |
| N | Info Adicional | Falta documentación | Nada |
| O | Nueva Revisión | Requiere reinspección | Fecha obligatoria |

### Flujo en el proceso completo

1. Trámite se ingresa (estatus inicial)
2. Se asigna a dependencias revisoras
3. Cada dependencia abre módulo de revisión
4. Usa este módulo para cambiar estatus
5. Sistema registra el cambio
6. Si todas aprueban: Trámite procede
7. Si alguna rechaza: Trámite se detiene
8. Si requiere info: Se notifica a contribuyente
