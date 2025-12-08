# CartaInvitacion - Gestión de Cartas Invitación de Pago

## Propósito Administrativo
Genera y administra cartas invitación previas al procedimiento de apremio. Es una herramienta de cobro preventivo que invita al contribuyente moroso a regularizar su situación antes de iniciar el procedimiento coactivo formal.

## Funcionalidad Principal
Módulo que genera cartas invitación para contribuyentes con adeudos, asigna folios a ejecutores, controla su practicación, imprime documentos oficiales y genera reportes de seguimiento. Funciona como paso previo y menos oneroso que el procedimiento de apremio completo.

## Proceso de Negocio

### ¿Qué hace?
- Genera folios de carta invitación a partir de infracciones vencidas
- Asigna cartas invitación a ejecutores fiscales para notificación
- Controla la practicación de cartas por ejecutores
- Imprime cartas invitación oficiales con datos del adeudo
- Cancela cartas invitación cuando es necesario
- Genera listados y reportes de cartas emitidas, asignadas y practicadas
- Consulta cartas por folio o cuenta
- Exporta información a Excel para análisis
- Rastrea folios pagados en periodo de 90 días

### ¿Para qué sirve?
- Dar oportunidad al contribuyente de pagar voluntariamente antes del apremio
- Reducir costos de cobro coactivo mediante notificación preventiva
- Documentar el proceso de invitación antes de iniciar procedimiento formal
- Asignar carga de trabajo a ejecutores para notificación
- Dar cumplimiento a principios de mínima intervención administrativa
- Incrementar recuperación de cartera por vía voluntaria
- Generar estadísticas de efectividad de cartas invitación

### ¿Cómo lo hace?
**Generación de cartas:**
1. Usuario selecciona colonia y fecha de trabajo
2. Sistema consulta infracciones vencidas de esa colonia
3. Obtiene el último folio de carta usado
4. Genera folios consecutivos para cada infracción
5. Registra carta con datos del adeudo (impuesto, recargos, multas, gastos)
6. Asocia la carta a la infracción correspondiente

**Asignación a ejecutores:**
1. Usuario selecciona rango de folios y ejecutor
2. Sistema muestra folios pendientes de asignación
3. Usuario selecciona folios a asignar
4. Sistema registra ejecutor y fecha de asignación
5. Folios quedan disponibles para practicación

**Practicación:**
1. Usuario selecciona folios asignados a ejecutor
2. Captura fecha de practicación
3. Sistema marca folios como practicados
4. Registra bitácora de practicación

**Cancelación:**
1. Usuario selecciona folios a cancelar
2. Captura motivo de cancelación
3. Sistema cancela folios y registra observación

**Impresión y consultas:**
- Imprime cartas invitación individuales o por lote
- Genera listados por ejecutor, fechas, pagos
- Permite consultas por folio o por cuenta
- Exporta reportes a Excel para análisis externo

### ¿Qué necesita para funcionar?
- Infracciones vencidas en el padrón vehicular
- Catálogo de colonias
- Catálogo de ejecutores activos
- Recaudadora de trabajo
- Fechas de trabajo y practicación
- Plantillas de impresión de cartas
- Permisos de usuario para generar y asignar

## Datos y Tablas

### Tabla Principal
**ta_15_cartasinvitacion**: Registro de cartas invitación generadas

### Tablas Relacionadas
- **ta_14_infracciones** (QryInfracciones): Infracciones de tránsito base para generar cartas
- **ta_14_placas**: Información de vehículos (placa, marca, modelo, serie, motor, color)
- **ta_15_ejecutores**: Ejecutores que practican las cartas
- **ta_catalogo_recaudadoras** (Qryrecase): Recaudadoras del sistema

### Stored Procedures (SP)
**SpGenera**: Genera folios de carta invitación a partir de infracciones vencidas por colonia
**SpAfecta**: Inserta registro de carta invitación con todos sus datos
**SpSeleccion**: Consulta folios para asignar, practicar o cancelar según filtros
**SpDotacion**: Cuenta total de folios asignados a un ejecutor
**SpAsigna**: Asigna, practica o cancela folios de carta invitación
**Sp_Impresion**: Consulta datos para impresión de cartas
**Sp_Listados**: Genera listados de cartas con diversos filtros

### Tablas que Afecta
**Inserta en:**
- ta_15_cartasinvitacion (al generar nuevas cartas)

**Actualiza:**
- ta_15_cartasinvitacion (al asignar, practicar o cancelar)

## Impacto y Repercusiones

### Repercusiones Operativas
- Reduce carga de trabajo de apremios mediante cobro preventivo
- Permite asignación eficiente de ejecutores por zonas
- Agiliza recuperación mediante invitación antes que procedimiento formal
- Facilita seguimiento de notificaciones por ejecutor
- Optimiza rutas de notificación por colonia
- Permite priorizar cuentas por antigüedad o monto

### Repercusiones Financieras
- Incrementa recuperación voluntaria de cartera vencida
- Reduce costos de procedimiento de apremio completo
- Mejora flujo de efectivo mediante cobro más rápido
- Permite proyectar recuperación por cartas emitidas
- Facilita análisis costo-beneficio de cartas vs. apremios
- Genera ingresos adicionales sin incurrir en gastos de ejecución

### Repercusiones Administrativas
- Documenta fase previa al procedimiento administrativo formal
- Genera estadísticas de efectividad de cobro persuasivo
- Permite auditar asignaciones a ejecutores
- Facilita reportes de gestión por ejecutor y periodo
- Cumple principio de economía procesal (vía menos gravosa primero)
- Mantiene trazabilidad de notificaciones

## Validaciones y Controles
- Valida que existan infracciones vencidas en la colonia
- Asigna folios consecutivos sin duplicados
- Controla que un folio solo se asigne a un ejecutor
- Valida estado de folio para practicar (debe estar asignado)
- Impide cancelar folios ya pagados
- Control transaccional con rollback en errores
- Registra usuario, fecha y hora de cada operación
- Valida que el ejecutor exista y esté activo
- Requiere captura de motivo en cancelaciones

## Casos de Uso

**Emisión masiva de cartas por colonia:**
- Se identifica colonia con alto índice de morosidad
- Se genera lote de cartas para todas las infracciones vencidas
- Sistema crea folios consecutivos automáticamente
- Cartas quedan disponibles para asignación

**Asignación a ejecutor para notificación:**
- Supervisor asigna rango de folios a ejecutor
- Ejecutor recibe cartas para notificar en su zona
- Sistema registra fecha de asignación
- Ejecutor tiene dotación de trabajo documentada

**Practicación de cartas:**
- Ejecutor entrega cartas a contribuyentes
- Captura fecha de entrega en sistema
- Folios quedan marcados como practicados
- Se genera evidencia de notificación

**Seguimiento de pagos por carta:**
- Se consultan cartas practicadas hace 90 días
- Sistema identifica cuáles fueron pagadas
- Permite calcular tasa de efectividad de cartas
- Las no pagadas pasan a apremio formal

**Cancelación por error o duplicidad:**
- Se detecta carta emitida por error
- Usuario cancela folio con motivo documentado
- Folio queda inactivo sin afectar consecutivos

## Usuarios del Sistema
- Coordinador de cobranza coactiva
- Supervisor de notificadores
- Ejecutores fiscales
- Personal de control de cartas invitación
- Analistas de recuperación de cartera
- Generadores de estadísticas de cobranza

## Relaciones con Otros Módulos
- **Individual_Folio.pas**: Consulta si una cuenta tiene carta invitación
- **Listados.pas**: Reportes de cuentas con cartas emitidas
- **Requerimientos.pas**: Si la carta no funciona, se emite requerimiento formal
- **Ejecutores.pas / ABCEjec.pas**: Consulta ejecutores para asignar cartas
- **Prenomina.pas**: Puede considerar cartas practicadas para comisiones
- **Facturacion.pas**: Registra pago referenciando folio de carta
- **Recuperacion.pas**: Reportes de recuperación por cartas invitación
