# ABCPagos - Registro de Pagos de Mantenimiento

## Propósito Administrativo
Módulo central para registrar los pagos de derechos de mantenimiento anual de espacios funerarios, vinculando los ingresos de caja con los adeudos pendientes de cada concesionario.

## Funcionalidad Principal
Permite registrar pagos realizados por los concesionarios, aplicándolos automáticamente contra sus adeudos de mantenimiento anual, considerando descuentos por pronto pago, bonificaciones autorizadas y recargos por mora.

## Proceso de Negocio

### ¿Qué hace?
Administra el ciclo completo de cobro de mantenimiento:
- Captura de pagos de caja contra folio RCM
- Selección de períodos (años) a pagar
- Aplicación automática de descuentos por pronto pago (10% si es año actual antes de marzo)
- Validación de importes contra ingresos registrados en caja
- Actualización de último año pagado en el registro maestro
- Generación de recibos de pago
- Cancelación de pagos erróneos (con autorización)

### ¿Para qué sirve?
Garantiza el control financiero del cobro de mantenimiento:
- Asocia cada pago de caja con el espacio funerario correspondiente
- Mantiene actualizado el estado de cuenta de cada concesionario
- Aplica políticas de descuentos automáticamente
- Evita cobros duplicados o errores de aplicación
- Genera información para reportes financieros y contables

### ¿Cómo lo hace?
1. El cajero captura: fecha de pago, recaudadora, caja, número de operación y folio RCM
2. El sistema verifica que el pago exista en el sistema de ingresos
3. Muestra los adeudos pendientes del concesionario
4. El cajero selecciona los períodos (años) a cubrir
5. El sistema calcula automáticamente descuentos si aplica pronto pago
6. Valida que el importe del ingreso sea suficiente para cubrir los períodos seleccionados
7. Permite sobrepaso de importe con autorización especial
8. Genera el registro del pago en ta_13_pagosrcm
9. Actualiza los adeudos marcándolos como pagados (id_pago)
10. Actualiza el último año pagado en el registro maestro
11. Recalcula adeudos futuros si es necesario

### ¿Qué necesita para funcionar?
- Pago registrado previamente en sistema de ingresos
- Folio RCM válido con adeudos pendientes
- Cuenta aplicadora configurada para el cementerio
- Autorización especial para casos excepcionales (pagos mayores al ingreso)
- Usuario con nivel de recaudadora asignado

## Datos y Tablas

### Tabla Principal
**ta_13_pagosrcm** - Registro de cada pago aplicado
Contiene: fecha, recaudadora, caja, operación, folio RCM, año desde, año hasta, importe, recargos, vigencia

### Tablas Relacionadas
- **ta_13_datosrcm** - Registro del espacio (actualiza último año pagado)
- **ta_13_adeudosrcm** - Adeudos pendientes (marca como pagados)
- **ta_ingresos** - Ingresos registrados en caja (validación de existencia y monto)
- **ta_cementerios** - Información de cada cementerio (cuenta aplicadora)
- **ta_autoriza** - Control de autorizaciones especiales

### Stored Procedures (SP)
- **StrdPrcABpago** - Procedimiento principal de aplicación de pagos
  - par_control: Folio RCM
  - par_fec: Fecha del pago
  - par_rec: Recaudadora
  - par_caja: Caja
  - par_ope: Número de operación
  - par_axod: Año desde
  - par_axoh: Año hasta
  - par_importe: Importe total
  - par_usu: Usuario
  - par_opc: 1=Alta de pago, 2=Baja de pago
  - par_id: ID del pago (para bajas)
  - Retorna: par_ok, par_observ (estado del proceso)

- **StrdPrcABC** - Actualiza adeudos del registro
  - par_control: Folio RCM
  - par_opc: 3=Recálculo de adeudos
  - par_usu: Usuario

### Tablas que Afecta
**Inserta:**
- ta_13_pagosrcm (nuevo pago registrado)

**Actualiza:**
- ta_13_adeudosrcm (marca adeudos como pagados, asigna id_pago)
- ta_13_datosrcm (actualiza último año pagado)

**Marca como Cancelado:**
- ta_13_pagosrcm (vigencia="C" para cancelación)
- ta_13_adeudosrcm (libera adeudos, id_pago=null)

## Impacto y Repercusiones

### Repercusiones Operativas
- Control diario de cobranza de mantenimiento
- Conciliación automática con ingresos de caja
- Reducción de errores de aplicación manual
- Agiliza atención en ventanilla

### Repercusiones Financieras
- Actualización en tiempo real de cuentas por cobrar
- Aplicación correcta de descuentos por pronto pago
- Control de recargos por mora
- Base para reportes de ingresos diarios
- Información para pólizas contables

### Repercusiones Administrativas
- Trazabilidad completa de cada cobro
- Soporte documental para auditorías
- Estado de cuenta actualizado para usuarios
- Cumplimiento de normativa fiscal municipal

## Validaciones y Controles
- Verifica existencia del folio RCM antes de aplicar pago
- Valida que el pago exista en ta_ingresos con el mismo importe
- Impide aplicar pagos si la suma ya registrada más el nuevo excede el ingreso
- Calcula descuento del 10% automático si es año actual y antes de marzo
- Respeta descuentos previamente autorizados en adeudos
- Requiere autorización especial para aplicar pagos mayores al ingreso registrado
- Valida que los períodos seleccionados estén en secuencia (sin brincar años)
- Impide cancelar pagos si existen pagos posteriores
- Control transaccional completo (todo o nada)

## Casos de Uso
1. **Pago anual único**: Concesionario paga mantenimiento del año en curso
2. **Pago múltiple anualidades**: Cliente pone al corriente varios años atrasados
3. **Pago con descuento**: Aplicación automática del 10% por pronto pago
4. **Pago con bonificación**: Aplicación de descuento previamente autorizado
5. **Cancelación de pago**: Reversa de pago aplicado incorrectamente
6. **Pago adelantado**: Cliente paga años futuros
7. **Pago parcial autorizado**: Con permiso especial, pago menor al adeudo total

## Usuarios del Sistema
- **Cajeros de Recaudadoras**: Aplicación diaria de pagos
- **Supervisores de Caja**: Autorización de casos especiales
- **Contabilidad**: Conciliación y pólizas
- **Auditoría Interna**: Verificación de aplicaciones

## Relaciones con Otros Módulos
- **ABCementer/ABCFolio**: Los espacios deben estar registrados para recibir pagos
- **Liquidaciones**: Alternativa para pagos totales de adeudos acumulados
- **Descuentos**: Consulta descuentos autorizados antes de aplicar
- **Bonificaciones**: Considera bonificaciones en el cálculo
- **Rep_a_Cobrar**: Reporte de adeudos considera pagos aplicados
- **List_Mov**: Listado de movimientos incluye pagos registrados
- **Sistema de Ingresos**: Validación cruzada de pagos registrados
