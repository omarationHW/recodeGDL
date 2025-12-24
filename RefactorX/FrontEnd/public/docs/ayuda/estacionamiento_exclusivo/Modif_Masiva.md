# Modificación Masiva de Folios

## Propósito Administrativo
Modificar múltiples folios de apremios de manera simultánea, permitiendo actualizar fechas, ejecutores asignados y estados de practicado en lote, optimizando los procesos administrativos del área de cobro coactivo.

## Funcionalidad Principal
Este módulo permite seleccionar un rango de folios y aplicar modificaciones masivas como asignación de ejecutor, actualización de fecha de practicado o cancelación, verificando previamente que los folios cumplan con las condiciones necesarias para la modificación.

## Proceso de Negocio

### ¿Qué hace?
Realiza modificaciones simultáneas en múltiples folios de apremios, aplicando cambios como la asignación de ejecutor con fecha de entrega, actualización de fecha de practicado, o cancelación masiva de folios, con validaciones previas y opción de cancelar automáticamente folios sin adeudo.

### ¿Para qué sirve?
- Agilizar la asignación masiva de folios a ejecutores
- Actualizar fechas de practicado en lote
- Cancelar múltiples folios simultáneamente
- Corregir información de forma eficiente
- Optimizar tiempos administrativos
- Depurar registros masivamente

### ¿Cómo lo hace?
1. El usuario selecciona el tipo de aplicación (Mercados, Aseo, Públicos, Exclusivos, Infracciones, Cementerios)
2. Define el rango de folios a modificar
3. Selecciona la oficina recaudadora
4. Elige el tipo de modificación:
   - Asignar ejecutor: Asigna folios sin ejecutor a uno específico
   - Actualizar practicado: Cambia fecha de practicado de folios ya asignados
   - Cancelar: Cancela múltiples folios
5. El sistema ejecuta un stored procedure de verificación
6. Identifica folios sin adeudo y ofrece cancelarlos
7. Filtra los folios que cumplen las condiciones
8. Muestra el listado de folios a modificar
9. El usuario confirma y el sistema aplica los cambios masivamente
10. Registra la modificación con usuario y fecha

### ¿Qué necesita para funcionar?
- Usuario con permisos administrativos
- Rango de folios válido (folio inicial ≤ folio final)
- Oficina recaudadora seleccionada
- Folios vigentes en el rango especificado
- Para asignación: ejecutor válido de la misma oficina
- Para practicado: fecha válida
- Stored procedure de verificación funcional

## Datos y Tablas

### Tabla Principal
- **ta_15_apremios**: Tabla donde se modifican los folios

### Tablas Relacionadas
- **ta_15_ejecutores**: Ejecutores para asignación
- **ta_14_recaudadoras**: Oficinas recaudadoras
- **ta_11_adeudo_local**: Verificación de adeudos en mercados
- **ta_16_adeudos_aseo**: Verificación de adeudos en aseo

### Stored Procedures (SP)
- **sp_verifica_folios_sin_adeudo**: Verifica y opcionalmente cancela folios sin adeudo
  - Parámetros: rango de folios, módulo, oficina, opción de cancelar
  - Retorna: cantidad de folios sin adeudo y observaciones
  - Acción: Si se solicita, cancela automáticamente folios sin adeudo

### Tablas que Afecta
- **UPDATE en ta_15_apremios**: Modifica campos según el tipo de operación:
  - ejecutor, fecha_entrega1 (asignación)
  - clave_practicado='P', fecha_practicado (practicado)
  - vigencia='3', clave_mov='3', fecha_pago (cancelación)
  - usuario, fecha_actualiz (siempre)

## Impacto y Repercusiones

### Repercusiones Operativas
- Agiliza significativamente los procesos administrativos
- Reduce errores de captura al modificar en lote
- Optimiza el tiempo de gestión de folios
- Facilita la distribución de cargas de trabajo
- Permite correcciones masivas eficientes

### Repercusiones Financieras
- No tiene impacto financiero directo
- Mejora la eficiencia operativa del área
- Facilita la gestión oportuna de cobros
- Apoya la correcta asignación de responsabilidades

### Repercusiones Administrativas
- Documenta modificaciones masivas con trazabilidad
- Mantiene registro de usuario y fecha de cambio
- Apoya auditorías con evidencia de modificaciones
- Permite depuración eficiente de bases de datos
- Facilita correcciones ante errores masivos

## Validaciones y Controles
- Valida que el folio inicial no sea mayor que el folio final
- Verifica que los folios estén vigentes (vigencia='1')
- Para asignación: valida que folios no tengan ejecutor o sea cero
- Para practicado: valida que folios tengan ejecutor asignado
- Ejecuta SP para identificar folios sin adeudo
- Ofrece cancelar automáticamente folios sin adeudo
- Muestra el listado de folios antes de aplicar cambios
- Permite selección manual de folios a modificar
- Valida permisos del usuario
- Usa transacciones para garantizar integridad

## Casos de Uso
1. **Jefe de Ejecutores**: Asigna masivamente 100 folios nuevos a un ejecutor
2. **Supervisor**: Actualiza fecha de practicado de folios entregados la semana pasada
3. **Coordinador**: Cancela masivamente folios sin adeudo detectados en auditoría
4. **Director**: Autoriza corrección masiva de fechas erróneas
5. **Auditor**: Identifica y cancela folios duplicados

## Usuarios del Sistema
- Directores y subdirectores
- Jefes de ejecutores fiscales
- Supervisores de cobro coactivo
- Coordinadores administrativos
- Personal con permisos administrativos especiales
- Auditores con autorización

## Relaciones con Otros Módulos
- **Reasignacion**: Reasignación individual de folios
- **Modifcar**: Modificación individual de folios
- **Ejecutores**: Catálogo de ejecutores para asignación
- **ConsultaReg**: Consulta de folios modificados
- **Cons_his**: Registro de cambios (no guarda historial previo)
- **AutorizaDes**: Puede requerir autorización para cancelaciones masivas
