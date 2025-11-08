# Facturacion - Registro de Pagos de Apremios

## Propósito Administrativo
Registra y documenta los pagos realizados por contribuyentes sobre folios de apremio. Cierra el ciclo de cobro coactivo al registrar la recuperación del adeudo y genera la documentación de pago correspondiente.

## Funcionalidad Principal
Módulo que registra pagos de folios de apremio, actualiza estados, genera documentación de pago, calcula saldos, aplica descuentos autorizados y mantiene el control de recuperación de cartera vencida.

## Proceso de Negocio

### ¿Qué hace?
- Registra pagos de folios de apremio
- Actualiza estado del folio a "pagado"
- Aplica descuentos autorizados al calcular pago
- Registra datos del pago (fecha, recaudadora, caja, operación)
- Genera documentación de pago
- Calcula montos con actualización al día de pago
- Permite pagos parciales o totales
- Cierra folios pagados completamente

### ¿Para qué sirve?
- Documentar recuperación de cartera vencida
- Cerrar el proceso de cobro coactivo exitoso
- Mantener control de ingresos por apremios
- Generar estadísticas de recuperación
- Aplicar correctamente descuentos autorizados
- Facilitar cuadres de caja y recaudación
- Documentar pagos para prenómina de ejecutores

### ¿Cómo lo hace?
1. Usuario localiza folio a pagar
2. Sistema muestra adeudo actualizado
3. Aplica descuento si está autorizado
4. Usuario captura:
   - Fecha de pago
   - Recaudadora que recibe
   - Caja donde se paga
   - Número de operación
   - Importe pagado
5. Sistema valida que importe sea correcto
6. Actualiza registro del folio:
   - Marca como pagado
   - Registra datos del pago
   - Cambia vigencia
7. Genera comprobante o recibo
8. Actualiza estadísticas de recuperación

### ¿Qué necesita para funcionar?
- Folio de apremio vigente y no pagado
- Datos del pago (fecha, recaudadora, caja, operación)
- Importe del pago
- Descuento autorizado (si aplica)
- Permisos para registrar pagos

## Datos y Tablas

### Tabla Principal
**ta_15_apremios**: Actualiza folios con datos de pago

### Tablas Relacionadas
- **ta_15_autorizados**: Descuentos autorizados
- **ta_catalogo_recaudadoras**: Recaudadoras
- **ta_15_ejecutores**: Para prenómina

### Stored Procedures (SP)
Posiblemente utiliza SP para cálculo de montos actualizados

### Tablas que Afecta
**Actualiza:**
- ta_15_apremios (registro de pago, cambio de vigencia)

## Impacto y Repercusiones

### Repercusiones Operativas
- Cierra ciclo de cobro coactivo
- Libera al contribuyente de procedimiento
- Genera estadísticas de efectividad
- Documenta recuperación

### Repercusiones Financieras
- Registra ingreso por apremios
- Documenta recuperación de cartera
- Genera información para prenómina
- Afecta indicadores financieros
- Permite análisis de recuperación

### Repercusiones Administrativas
- Documenta cierre de procedimiento
- Genera evidencia de pago
- Permite cuadres contables
- Facilita auditorías de ingresos

## Validaciones y Controles
- Valida que folio exista y esté vigente
- Verifica que no esté ya pagado
- Valida importe contra adeudo
- Aplica correctamente descuentos
- Control transaccional
- Requiere todos los datos de pago

## Casos de Uso

**Pago en ventanilla:**
- Contribuyente acude a pagar su folio
- Cajero localiza folio en sistema
- Calcula monto con descuento si aplica
- Contribuyente paga
- Sistema registra pago y genera recibo

**Pago con descuento:**
- Contribuyente tiene 50% de descuento autorizado
- Sistema calcula monto con descuento
- Aplica descuento automáticamente
- Registra pago con descuento aplicado

## Usuarios del Sistema
- Cajeros de recaudación
- Personal de ventanilla
- Coordinador de ingresos
- Supervisores de caja

## Relaciones con Otros Módulos
- **AutorizaDes.pas**: Consulta descuentos autorizados
- **Prenomina.pas**: Usa pagos para calcular comisiones
- **Individual.pas**: Consulta estado de pago
- **Listados.pas**: Reportes de pagos
- **Recuperacion.pas**: Estadísticas de recuperación
