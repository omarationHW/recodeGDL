# Modificación de Trámites

## Descripción General

### ¿Qué hace este módulo?
Este módulo permite modificar la información de trámites en proceso (solicitudes de licencias o anuncios que aún no han sido aprobados). Permite corregir datos capturados erróneamente, actualizar información del solicitante, modificar giros o actividades, y ajustar cualquier dato del trámite antes de su dictamen final.

### ¿Para qué sirve en el proceso administrativo?
Sirve para:
- Corregir errores en la captura inicial de solicitudes
- Actualizar información que cambió durante el proceso de revisión
- Modificar datos del propietario o establecimiento
- Cambiar el giro o actividad solicitada
- Ajustar ubicaciones o datos catastrales
- Mantener actualizados los trámites antes de su dictamen

### ¿Quiénes lo utilizan?
- Personal de ventanilla que capturó originalmente
- Revisores de solicitudes
- Personal del área de Licencias con permisos de modificación
- Supervisores que validan y corrigen trámites
- Usuarios con firma electrónica autorizada

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?

#### Modificación de Trámite de Licencia:
1. Usuario selecciona "Licencia" en el RadioGroup
2. Ingresa el número de folio del trámite
3. Hace clic en "Buscar"
4. Sistema valida que el trámite exista
5. Se cargan todos los datos del trámite:
   - Datos del solicitante
   - Ubicación propuesta
   - Giro y actividad solicitados
   - Datos del establecimiento
   - Documentos requeridos
6. Usuario modifica los campos necesarios:
   - Nombre del propietario (primer apellido, segundo apellido, nombre)
   - RFC y CURP
   - Domicilio fiscal
   - Ubicación del negocio
   - Giro SCIAN y actividad específica
   - Superficie, empleados, cajones
   - Inversión, aforo, horario
7. Puede buscar y seleccionar:
   - Giro SCIAN actualizado
   - Actividad específica dentro del giro
   - Calle y colonia de ubicación
8. Sistema solicita firma electrónica para autorizar cambios
9. Se valida la firma
10. Sistema actualiza el registro del trámite
11. Se actualizan campos de auditoría (fecha modificación, usuario)

#### Modificación de Trámite de Anuncio:
1. Usuario selecciona "Anuncio" en el RadioGroup
2. Ingresa folio del trámite
3. Hace clic en "Buscar"
4. Sistema carga datos del trámite de anuncio:
   - Tipo de anuncio (giro)
   - Medidas y número de caras
   - Ubicación
   - Fabricante
   - Texto del anuncio
5. Usuario modifica los campos necesarios
6. Sistema solicita firma electrónica
7. Se actualizan los datos del trámite

### ¿Qué información requiere el usuario?

#### Para Trámite de Licencia:
**Datos del Solicitante:**
- Primer apellido
- Segundo apellido
- Nombre(s)
- RFC (validación de formato)
- CURP (validación de formato)
- Teléfono
- Email

**Domicilio Fiscal:**
- Calle
- Número exterior y letra
- Número interior y letra
- Colonia
- Código Postal

**Ubicación del Negocio:**
- Calle (búsqueda en catálogo)
- Número exterior y letra
- Número interior y letra
- Colonia (búsqueda)
- Código Postal
- Zona y subzona

**Datos del Establecimiento:**
- Giro SCIAN (búsqueda)
- Actividad específica (búsqueda)
- Superficie construida
- Superficie autorizada
- Número de cajones
- Número de empleados
- Aforo
- Inversión
- Horario de operación

#### Para Trámite de Anuncio:
- Tipo de anuncio (giro)
- Medidas (alto × ancho)
- Número de caras
- Ubicación
- Texto del anuncio
- Fabricante

### ¿Qué validaciones se realizan?

#### Validaciones de Datos:
- El trámite debe existir
- El folio debe ser válido
- Los campos obligatorios no pueden estar vacíos
- RFC debe cumplir formato oficial
- CURP debe cumplir formato oficial
- El giro y actividad deben existir en catálogos
- Las calles y colonias deben estar registradas

#### Validaciones de Seguridad:
- Requiere firma electrónica para confirmar cambios
- Validación de permisos del usuario
- Solo se pueden modificar trámites en ciertos estados
- No se pueden modificar trámites dictaminados

#### Validaciones de Negocio:
- El giro seleccionado debe estar vigente
- La actividad debe corresponder al giro
- Los datos catastrales deben ser consistentes
- Las medidas del anuncio deben ser coherentes

### ¿Qué documentos genera?
Este módulo no genera documentos impresos directamente, pero las modificaciones impactan en:
- Fichas de trámite actualizadas
- Dictámenes con información correcta
- Licencias emitidas con datos precisos
- Reportes de trámites

## Tablas de Base de Datos

### Tabla Principal

**tramites**: Almacena todas las solicitudes de licencias y anuncios en proceso
- Datos del solicitante
- Información del establecimiento o anuncio
- Giro y actividad solicitados
- Estado del trámite
- Fechas y usuarios de captura/modificación

### Tablas Relacionadas

#### Tablas que consulta:
- **tramites**: Para cargar el trámite a modificar
- **c_giros**: Catálogo de giros SCIAN
- **c_scian_qry**: Sistema de clasificación industrial
- **giros_nvo_qry**: Actividades específicas por giro
- **c_callesQry**: Catálogo de calles
- **cp_correos**: Colonias por código postal
- **convcta**: Cuentas prediales (si hay relación)

#### Tablas que modifica:
- **tramites**: UPDATE de todos los campos modificados
- No modifica tablas de catálogos (giros, calles, etc.)

## Stored Procedures

### verifica_firma
**Propósito**: Valida la firma electrónica del usuario
**Parámetros**:
- `p_usuario`: Usuario del sistema
- `p_login`: Login
- `p_firma`: Contraseña/firma a validar
- `p_modulos_id`: ID del módulo
**Descripción**: Verifica que el usuario tenga permisos para modificar trámites y que la firma sea correcta.

## Impacto y Repercusiones

### ¿Qué registros afecta?
- **Registro del trámite**: Actualización directa de campos modificados
- **Auditoría interna**: Registro de usuario y fecha de modificación
- **Proceso de dictamen**: Los dictaminadores ven información actualizada

### ¿Qué cambios de estado provoca?
- Actualización de campos de datos
- No cambia el estado del trámite (sigue en proceso)
- Actualiza fecha de última modificación
- Registra usuario que realizó el cambio

### ¿Qué documentos/reportes genera?
Indirectamente, las correcciones se reflejan en:
- Fichas de trámite para revisión
- Documentos de dictamen
- Licencias emitidas (una vez aprobadas)
- Reportes de trámites en proceso

### ¿Qué validaciones de negocio aplica?
- **Existencia**: El trámite debe existir
- **Estado válido**: Solo trámites en ciertos estados pueden modificarse
- **Coherencia**: Los datos modificados deben ser coherentes entre sí
- **Catálogos**: Validación contra catálogos vigentes
- **Autorización**: Firma electrónica obligatoria
- **Formato**: RFC y CURP con formato correcto

## Flujo de Trabajo

### Flujo de Modificación de Trámite de Licencia

```
1. Inicio
2. Usuario selecciona "Licencia"
3. Ingresa folio del trámite
4. Presiona "Buscar"
5. ¿Trámite existe?
   - No: Mostrar error y terminar
   - Sí: Continuar
6. Sistema carga todos los datos en pantalla
7. Sistema carga giro SCIAN y actividad
8. Usuario modifica campos necesarios
9. ¿Usuario modificó giro?
   - Sí:
     a. Abre búsqueda de giros SCIAN
     b. Usuario selecciona giro
     c. Carga actividades del giro
     d. Usuario selecciona actividad
   - No: Continuar
10. ¿Usuario modificó ubicación?
    - Sí:
      a. Buscar calle en catálogo
      b. Actualizar zona/subzona automáticamente
    - No: Continuar
11. Usuario presiona "Actualizar"
12. Sistema valida campos obligatorios
13. ¿Todos los campos válidos?
    - No: Mostrar errores y volver a paso 8
    - Sí: Continuar
14. Sistema solicita firma electrónica
15. ¿Firma válida?
    - No: Mostrar error y cancelar
    - Sí: Continuar
16. Sistema actualiza registro en tabla tramites
17. Sistema actualiza fecha de modificación
18. Sistema registra usuario que modificó
19. Mostrar mensaje de confirmación
20. Fin
```

## Notas Importantes

### Consideraciones especiales

#### Nuevas Actividades (Sistema 2023):
- A partir de 2023 se usa nuevo catálogo de actividades
- Primero se selecciona giro SCIAN
- Luego actividad específica del giro
- Las actividades tienen id >= 5000

#### Estados Modificables:
- Solo se pueden modificar trámites que no han sido dictaminados
- Trámites con dictamen aprobado no pueden modificarse aquí
- Para cambios después del dictamen, usar otro módulo

#### Cambio de Giro:
- Al cambiar giro, se deben actualizar actividades disponibles
- El sistema valida que la actividad corresponda al giro
- Puede afectar el costo y requisitos del trámite

### Restricciones
- No se puede modificar un trámite que no existe
- No se pueden modificar trámites dictaminados o autorizados
- Los cambios requieren firma electrónica
- No se puede cambiar el folio del trámite
- No se puede cambiar el tipo de trámite (licencia vs anuncio)

### Permisos necesarios
- Firma electrónica válida
- Permisos para modificar trámites
- Acceso al formulario de modificación
- Nivel de usuario adecuado

### Mejores prácticas de uso
1. **Verificación**: Confirmar que es el trámite correcto antes de modificar
2. **Completitud**: Verificar que todos los campos obligatorios estén llenos
3. **Validación de RFC/CURP**: Usar herramientas de validación
4. **Ubicación precisa**: Verificar dirección en catálogos
5. **Giro correcto**: Seleccionar el giro que mejor describe la actividad
6. **Documentación**: Si el cambio es significativo, documentar en observaciones
7. **Comunicación**: Informar al solicitante si hay cambios importantes
8. **Revisión final**: Verificar todos los datos antes de confirmar
9. **Coordinación**: Notificar a revisores sobre modificaciones importantes
10. **Respaldo**: Verificar que los cambios se guardaron correctamente

### Diferencias con Modificación de Licencias
- **Trámites**: Solicitudes en proceso, no aprobadas
- **Licencias**: Registros ya autorizados y vigentes
- Los trámites se modifican con este módulo
- Las licencias se modifican con modlicfrm
- Diferentes validaciones y procesos

### Impacto en otros módulos
Este módulo afecta a:
- **Revisiones**: Los revisores ven datos actualizados
- **Dictamen**: La información modificada se usa en el dictamen
- **Generación de licencia**: Si se aprueba, se crea con datos correctos
- **Reportes**: Estadísticas de trámites con información actualizada
- **Consultas**: Personal puede ver datos corregidos

### Casos especiales
- **Cambio de propietario durante trámite**: Puede requerir nueva solicitud
- **Cambio de ubicación**: Verificar que siga siendo viable
- **Cambio de giro**: Puede requerir documentación adicional
- **Corrección de errores menores**: Proceso más simple
- **Modificaciones sustanciales**: Pueden requerir autorización especial

### Auditoría y control
- Todos los cambios quedan registrados
- Se guarda usuario y fecha de modificación
- Los cambios son auditables
- Se puede rastrear el historial de modificaciones
- Importante para casos de aclaraciones o disputas
