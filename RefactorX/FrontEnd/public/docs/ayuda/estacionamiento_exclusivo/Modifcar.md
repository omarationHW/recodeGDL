# Modificación Individual de Folios

## Propósito Administrativo
Modificar datos de folios de apremios de manera individual, permitiendo actualizar información específica de cada requerimiento, corregir errores, actualizar estados y mantener un historial completo de todos los cambios realizados.

## Funcionalidad Principal
Este módulo permite modificar cualquier aspecto de un folio de apremio individual, desde datos operativos (ejecutor, fechas, estados) hasta importes y observaciones, guardando un registro histórico de cada modificación para mantener trazabilidad completa.

## Proceso de Negocio

### ¿Qué hace?
Permite la modificación controlada y documentada de folios individuales de apremios, actualizando cualquier campo del registro (ejecutor, fechas, importes, gastos, multas, estados, observaciones) mientras mantiene un historial completo de todas las versiones anteriores del folio.

### ¿Para qué sirve?
- Corregir errores en la captura de folios
- Actualizar información operativa (ejecutor, fechas)
- Modificar importes de multas y gastos
- Cambiar estados del proceso (vigencia, clave de movimiento)
- Registrar pagos y datos de recaudación
- Actualizar información de secuestro y remate
- Mantener trazabilidad completa de cambios
- Documentar todas las modificaciones del folio

### ¿Cómo lo hace?
1. El usuario selecciona tipo de aplicación y oficina recaudadora
2. Ingresa el número de folio a modificar
3. El sistema busca y muestra toda la información del folio
4. Muestra el historial de modificaciones previas
5. Presenta los datos del contribuyente (local o contrato)
6. Permite modificar:
   - Zona de apremio y observaciones
   - Porcentaje de multa
   - Importes de multa y gastos (si están en cero)
   - Clave y fecha de practicado con hora
   - Ejecutor y fechas de entrega
   - Fecha y hora de citatorio
   - Clave de secuestro, remate y fecha
   - Datos de pago (fecha, recaudadora, caja, operación, importe)
   - Clave de movimiento y vigencia
7. Valida todos los cambios contra reglas de negocio
8. Antes de guardar, inserta un registro en ta_15_historia
9. Aplica las modificaciones al registro original
10. Registra usuario y fecha de actualización

### ¿Qué necesita para funcionar?
- Usuario con permisos de modificación
- Número de folio válido y existente
- Folio con vigencia='1' (vigente)
- Datos completos del folio
- Tabla de gastos vigente para validaciones
- Historial habilitado para trazabilidad
- Catálogos de claves actualizados

## Datos y Tablas

### Tabla Principal
- **ta_15_apremios**: Tabla donde se modifica el folio

### Tablas Relacionadas
- **ta_15_historia**: Registro histórico de modificaciones
- **ta_15_ejecutores**: Validación de ejecutores
- **ta_12_gastos**: Validación de importes de gastos
- **ta_11_locales**: Datos de locales en mercados
- **ta_16_contratos_aseo**: Contratos de aseo
- **ta_14_recaudadoras**: Oficinas recaudadoras
- **ta_15_claves**: Catálogos de estados y vigencias

### Stored Procedures (SP)
No utiliza stored procedures. Realiza operaciones directas con transacciones.

### Tablas que Afecta
- **INSERT en ta_15_historia**: Guarda el estado anterior del folio antes de modificar
- **UPDATE en ta_15_apremios**: Actualiza los campos modificados del folio

## Impacto y Repercusiones

### Repercusiones Operativas
- Permite corrección oportuna de errores
- Mantiene actualizada la información de folios
- Facilita el seguimiento de cambios
- Apoya la gestión correcta del cobro coactivo
- Documenta todas las modificaciones para auditorías

### Repercusiones Financieras
- Permite ajustar importes cuando es necesario
- Valida que los gastos sean correctos según normativa
- Documenta cambios en conceptos financieros
- Mantiene integridad de datos para contabilidad

### Repercusiones Administrativas
- Genera trazabilidad completa de modificaciones
- Documenta quién, cuándo y qué se modificó
- Facilita auditorías con historial completo
- Apoya procesos legales con evidencia documentada
- Permite reversión o análisis de cambios

## Validaciones y Controles
- Valida que el folio exista y esté vigente (vigencia='1')
- Para importe de multa: solo permite modificar si está en cero
- Para importe de gastos: solo permite modificar si está en cero
- Valida que gastos sean acordes a la tabla vigente según fecha de practicado
- Verifica que el ejecutor exista y esté activo
- Valida fechas lógicas (no futuras, secuencia correcta)
- Para pagos: valida datos completos (recaudadora, caja, operación, importe)
- Requiere clave de movimiento válida
- Usa transacciones para garantizar integridad
- Guarda historial ANTES de modificar (rollback si falla historia)
- Valida permisos del usuario según nivel

## Casos de Uso
1. **Supervisor**: Corrige ejecutor asignado erróneamente
2. **Ejecutor**: Actualiza fecha de practicado de requerimiento
3. **Coordinador**: Modifica importe de gastos por cambio en normativa
4. **Jefe de Área**: Cancela folio cambiando vigencia
5. **Auditor**: Revisa historial de modificaciones del folio
6. **Personal de Ventanilla**: Registra pago realizado en caja

## Usuarios del Sistema
- Jefes y supervisores de cobro coactivo
- Ejecutores fiscales (con permisos limitados)
- Coordinadores administrativos
- Personal de ventanilla de cobranza
- Directores y subdirectores (permisos completos)
- Auditores (solo consulta de historial)

## Relaciones con Otros Módulos
- **Modif_Masiva**: Modificación masiva vs individual
- **ConsultaReg**: Consulta previa del folio
- **Cons_his**: Consulta del historial completo
- **Recuperacion**: Registro de pagos
- **Ejecutores**: Validación de ejecutores
- **AutorizaDes**: Puede requerir autorización para ciertos cambios
