# Revisiones y Dictamen de Trámites

## Descripción General

### ¿Qué hace este módulo?
Este módulo permite a las dependencias revisoras (Desarrollo Urbano, Protección Civil, Medio Ambiente, etc.) revisar solicitudes de licencias, agregar observaciones, cambiar estados de revisión y generar dictámenes. Es el núcleo del proceso de aprobación o rechazo de licencias.

### ¿Para qué sirve en el proceso administrativo?
- Revisar solicitudes asignadas a cada dependencia
- Registrar observaciones técnicas de cada revisión
- Cambiar estado de la revisión (Pendiente, Aprobado, Rechazado)
- Generar dictámenes oficiales con firma
- Consultar historial de trámites
- Visualizar documentos digitalizados adjuntos
- Imprimir oficios y formatos oficiales

### ¿Quiénes lo utilizan?
- Revisores de cada dependencia (Desarrollo Urbano, Protección Civil, etc.)
- Dictaminadores autorizados
- Supervisores de áreas técnicas
- Personal con firma electrónica para dictámenes

## Proceso Administrativo

### Flujo de Revisión:
1. Usuario accede al módulo y consulta trámites asignados a su dependencia
2. Selecciona dependencia revisora del catálogo
3. Sistema carga todos los trámites con revisión pendiente o en proceso
4. Usuario selecciona un trámite de la lista
5. Se muestran 4 pestañas:
   - **Datos Generales**: Información del solicitante y establecimiento
   - **Revisión**: Estado actual, observaciones, cambio de estatus
   - **Documentos**: Documentos digitalizados adjuntos al trámite
   - **Historial**: Versión anterior del trámite (si existe)
6. En pestaña de Revisión:
   - Usuario escribe observaciones técnicas
   - Selecciona nuevo estatus (Aprobado/Rechazado/Pendiente)
   - Guarda cambios
7. Si todas las dependencias aprueban → Trámite pasa a autorizado
8. Si alguna rechaza → Trámite pasa a rechazado
9. Usuario puede imprimir:
   - Dictamen oficial (requiere firma electrónica)
   - Ficha de trámite
   - Orden de pago
   - Reconsi deración
   - Formato informativo

## Tablas de Base de Datos

### Tablas Principales:
- **tramites**: Solicitudes en proceso
- **revisiones**: Revisión de cada dependencia para cada trámite
- **seg_revision**: Seguimiento y bitácora de cambios de estado

### Tablas que Consulta:
- h_tramites, h_licencias: Historial
- c_giros, giros: Catálogos
- doctos, digdocs: Documentos digitalizados
- usr: Usuarios del sistema
- saldoLic, saldoAnun: Adeudos

### Tablas que Modifica:
- **revisiones**: UPDATE de estatus y descripción
- **seg_revision**: INSERT de cambios de estado
- **tramites**: UPDATE de estatus general del trámite

## Stored Procedures:
- No utiliza SP específicos significativos

## Documentos que Genera:
1. **Dictamen**: Documento oficial con resultado de revisión (firma electrónica)
2. **Orden de Pago**: Para trámites aprobados
3. **Ficha de Trámite**: Resumen del trámite
4. **Formato Informativo**: Información complementaria
5. **Reconsideración**: Para trámites rechazados que se reconsideran

## Impacto y Repercusiones:
- Cambio de estatus de revisión afecta el proceso completo
- Si todas las dependencias aprueban → Licencia puede emitirse
- Si alguna rechaza → Trámite detenido hasta corrección
- Las observaciones quedan registradas permanentemente
- Los dictámenes impresos son documentos oficiales

## Notas Importantes:

### Estados de Revisión:
- **E (En proceso)**: Recién asignado, sin revisar
- **A (Aprobado)**: Revisión aprobada por la dependencia
- **R (Rechazado)**: Revisión rechazada, requiere correcciones
- **P (Pendiente)**: En espera de información adicional

### Proceso de Dictamen:
- Requiere firma electrónica del dictaminador
- Se valida contra tabla de usuarios autorizados
- El dictamen incluye todas las observaciones
- Se genera en formato imprimible oficial

### Documentos Digitalizados:
- Se pueden adjuntar documentos escaneados al trámite
- Se visualizan desde la pestaña de Documentos
- Útil para verificar requisitos sin expediente físico
- Se pueden imprimir los documentos adjuntos

### Historial:
- La pestaña de Historial muestra versión anterior del trámite
- Útil para trámites de modificación o renovación
- Permite comparar datos actuales con anteriores

### Mejores Prácticas:
1. Revisar todos los datos antes de dictaminar
2. Escribir observaciones claras y específicas
3. Verificar documentos digitalizados adjuntos
4. Consultar historial si es modificación
5. Generar dictamen solo cuando la revisión esté completa
6. Coordinar con otras dependencias en casos complejos
7. Registrar observaciones incluso si se aprueba
