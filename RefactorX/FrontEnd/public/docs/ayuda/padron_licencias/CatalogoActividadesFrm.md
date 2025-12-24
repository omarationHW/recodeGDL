# Catálogo de Actividades

## Descripción General

### ¿Qué hace este módulo?
Este módulo gestiona el catálogo maestro de actividades económicas que pueden realizarse bajo una licencia de funcionamiento. Permite agregar, modificar, consultar y cancelar actividades, así como asociarlas con giros específicos del clasificador SCIAN (Sistema de Clasificación Industrial de América del Norte).

### ¿Para qué sirve en el proceso administrativo?
Sirve para mantener actualizado el catálogo de actividades económicas permitidas en el municipio. Este catálogo es fundamental porque:
- Define qué actividades específicas pueden operar bajo cada giro comercial
- Establece la clasificación detallada de negocios
- Permite el control y regulación de actividades económicas
- Facilita la emisión de licencias con actividades específicas

### ¿Quiénes lo utilizan?
- Personal del área de Licencias y Funcionamiento
- Administradores del catálogo de giros
- Personal de Catastro con permisos administrativos
- Supervisores del área de Regulación Comercial

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?

#### Agregar nueva actividad:
1. El usuario hace clic en el botón "Agregar"
2. El sistema habilita el formulario de captura y deshabilita los botones de navegación
3. El usuario ingresa los datos:
   - Descripción de la actividad
   - Giro asociado (del catálogo SCIAN)
   - Estatus (Vigente/Cancelado)
   - Observaciones (opcional)
4. El usuario hace clic en "Aceptar"
5. El sistema valida que los campos obligatorios estén llenos
6. Se registra automáticamente:
   - Fecha de alta (fecha actual del sistema)
   - Usuario que da de alta (usuario logueado)
7. Se guarda el registro en la base de datos
8. El catálogo se actualiza para mostrar la nueva actividad

#### Modificar actividad existente:
1. El usuario selecciona una actividad del grid
2. Hace clic en "Modificar"
3. El sistema carga los datos en el formulario de edición
4. El usuario modifica los campos necesarios
5. Si cambia el estatus a "Cancelado", el sistema registra automáticamente:
   - Usuario de baja
   - Fecha de baja
6. Hace clic en "Aceptar" para guardar los cambios
7. El catálogo se actualiza con la información modificada

#### Búsqueda de actividad:
1. El usuario escribe en el campo de búsqueda
2. El sistema filtra automáticamente las actividades que coincidan con el texto
3. Se muestran solo las actividades que contienen el texto buscado

### ¿Qué información requiere el usuario?

#### Campos obligatorios:
- **Descripción de la actividad**: Nombre o descripción clara de la actividad económica
- **Estatus**: Vigente (V) o Cancelado (C)

#### Campos opcionales:
- **Giro**: Clasificación SCIAN a la que pertenece la actividad
- **Observaciones**: Notas adicionales sobre la actividad

### ¿Qué validaciones se realizan?
- **Descripción**: No puede estar vacía
- **Estatus**: Debe seleccionarse obligatoriamente (Vigente o Cancelado)
- **Giro**: Se valida que exista en el catálogo de giros (si se selecciona)
- **Usuario y fechas**: Se registran automáticamente, no requieren captura manual

### ¿Qué documentos genera?
Este módulo no genera documentos impresos directamente. Sin embargo, las actividades registradas son utilizadas en:
- Solicitudes de licencias
- Constancias de licencias
- Reportes de actividades autorizadas
- Listados de actividades por giro

## Tablas de Base de Datos

### Tabla Principal
**c_actividades**: Catálogo de actividades económicas
- `id_actividad`: Identificador único de la actividad
- `id_giro`: Relación con el giro SCIAN
- `descripcion`: Nombre de la actividad
- `observaciones`: Notas adicionales
- `vigente`: Estado (V=Vigente, C=Cancelado)
- `fecha_alta`: Fecha de creación del registro
- `usuario_alta`: Usuario que creó el registro
- `fecha_baja`: Fecha de cancelación (si aplica)
- `usuario_baja`: Usuario que canceló (si aplica)
- `motivo_baja`: Razón de la cancelación (si aplica)

### Tablas Relacionadas

#### Tablas que consulta:
- **c_giros**: Catálogo de giros SCIAN para asociar actividades
  - Se consulta para mostrar los giros disponibles en el desplegable
  - Permite filtrar y buscar giros específicos

#### Tablas que modifica:
- **c_actividades**:
  - INSERT: Al agregar nuevas actividades
  - UPDATE: Al modificar actividades existentes o cancelarlas
  - No se realiza DELETE físico, solo se cambia el estatus a "Cancelado"

## Stored Procedures
Este módulo no consume stored procedures. Realiza operaciones directas sobre las tablas mediante:
- Consultas SQL (SELECT)
- Inserciones (INSERT)
- Actualizaciones (UPDATE)

## Impacto y Repercusiones

### ¿Qué registros afecta?
- **Registro de actividades**: Crea, modifica o cancela actividades en el catálogo
- **Licencias futuras**: Las nuevas actividades estarán disponibles para asignarse a licencias
- **Trámites en proceso**: Las modificaciones pueden afectar trámites que referencien estas actividades

### ¿Qué cambios de estado provoca?
- **Actividad Nueva**: Estado inicial "Vigente"
- **Actividad Modificada**: Mantiene o cambia su estado
- **Actividad Cancelada**:
  - Cambia estado de "V" a "C"
  - Registra fecha y usuario de baja
  - Ya no estará disponible para nuevas licencias

### ¿Qué documentos/reportes genera?
Aunque no genera reportes directamente, la información es utilizada en:
- Listados de actividades vigentes
- Catálogos para otros módulos
- Reportes estadísticos de licencias por actividad
- Consultas para ventanilla y atención ciudadana

### ¿Qué validaciones de negocio aplica?
- **Unicidad**: Aunque no se valida explícitamente, se debe evitar duplicar actividades
- **Integridad referencial**: Valida que el giro seleccionado exista
- **Auditoría**: Registra automáticamente quién y cuándo se hacen cambios
- **Cancelación controlada**: Al cancelar se requiere documentar la baja

## Flujo de Trabajo

### Descripción del flujo completo del proceso

#### Flujo de Alta de Actividad:
```
1. Inicio
2. Usuario presiona "Agregar"
3. Sistema habilita formulario de captura
4. Usuario llena campos obligatorios
5. Usuario selecciona giro (opcional)
6. Usuario presiona "Aceptar"
7. Sistema valida campos
8. ¿Validación correcta?
   - Sí: Continuar
   - No: Mostrar mensaje y volver a paso 4
9. Sistema asigna fecha/usuario actual
10. Sistema inserta registro en BD
11. Sistema actualiza grid de actividades
12. Sistema limpia formulario
13. Sistema deshabilita formulario de captura
14. Fin
```

#### Flujo de Modificación de Actividad:
```
1. Inicio
2. Usuario selecciona actividad del grid
3. Usuario presiona "Modificar"
4. Sistema carga datos en formulario
5. Sistema habilita campos para edición
6. Usuario modifica campos necesarios
7. ¿Usuario canceló la actividad?
   - Sí: Sistema registra fecha/usuario de baja
   - No: Continuar
8. Usuario presiona "Aceptar"
9. Sistema valida campos
10. Sistema actualiza registro en BD
11. Sistema actualiza grid de actividades
12. Sistema limpia formulario
13. Sistema deshabilita formulario de edición
14. Fin
```

#### Flujo de Búsqueda:
```
1. Inicio
2. Usuario escribe en campo de búsqueda
3. Sistema filtra actividades en tiempo real
4. Sistema muestra solo coincidencias
5. Usuario selecciona actividad deseada
6. Fin
```

## Notas Importantes

### Consideraciones especiales
- **No se eliminan registros físicamente**: Solo se marcan como cancelados
- **Trazabilidad completa**: Se registra quién y cuándo se crean o modifican actividades
- **Búsqueda en tiempo real**: El filtrado de actividades es dinámico mientras se escribe
- **Relación con SCIAN**: Las actividades deben estar asociadas a giros del clasificador SCIAN
- **Integración**: Este catálogo es utilizado por múltiples módulos del sistema

### Restricciones
- Una vez cancelada, una actividad no puede reactivarse desde este módulo
- No se pueden eliminar actividades que estén siendo utilizadas en licencias vigentes
- El campo de descripción tiene un límite de caracteres definido en la BD
- Las observaciones son opcionales pero se recomienda utilizarlas para aclaraciones

### Permisos necesarios
- **Consulta**: Todos los usuarios del sistema de licencias
- **Alta de actividades**: Personal administrativo autorizado
- **Modificación**: Personal con permisos administrativos
- **Cancelación**: Solo supervisores o administradores
- Se recomienda validar permisos antes de permitir operaciones críticas

### Mejores prácticas de uso
1. **Descripción clara**: Usar nombres descriptivos y estandarizados
2. **Clasificación correcta**: Asociar actividades al giro SCIAN correspondiente
3. **Documentación**: Utilizar el campo de observaciones para aclaraciones
4. **Evitar duplicados**: Verificar que no exista la actividad antes de crearla
5. **Cancelación justificada**: Al cancelar, documentar el motivo en observaciones
6. **Revisión periódica**: Mantener el catálogo actualizado conforme a normativa
7. **Coordinación**: Informar a ventanilla sobre nuevas actividades disponibles

### Impacto en otros módulos
Este catálogo es utilizado por:
- **Registro de solicitudes**: Para asignar actividades a nuevas licencias
- **Modificación de licencias**: Para cambiar la actividad de una licencia existente
- **Modificación de trámites**: Para especificar la actividad en trámites
- **Búsqueda de actividades**: Como fuente de datos para búsquedas
- **Reportes**: Como base para estadísticas y consultas

### Mantenimiento recomendado
- Revisar actividades canceladas periódicamente
- Actualizar descripciones conforme a cambios normativos
- Verificar la correcta asociación con giros SCIAN
- Documentar cambios importantes en el campo de observaciones
- Mantener respaldos del catálogo antes de modificaciones masivas
