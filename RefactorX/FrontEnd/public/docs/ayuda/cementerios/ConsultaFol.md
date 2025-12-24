# ConsultaFol - Consulta Individual por Folio

## Propósito Administrativo
Módulo de consulta integral que muestra toda la información relacionada con un espacio funerario específico, utilizando el folio RCM como llave de búsqueda.

## Funcionalidad Principal
Proporciona una vista completa y detallada del historial de un espacio funerario, incluyendo datos del concesionario, pagos realizados, adeudos pendientes, descuentos aplicados, bonificaciones, histórico de cambios y cualquier contacto adicional registrado.

## Proceso de Negocio

### ¿Qué hace?
Presenta información consolidada del espacio funerario en una sola pantalla:
- Datos generales del espacio (ubicación, metros, tipo)
- Información del concesionario actual
- Datos fiscales y de contacto
- Historial completo de pagos
- Adeudos pendientes con detalle
- Descuentos autorizados
- Bonificaciones aplicadas
- Histórico de modificaciones del registro
- Contactos adicionales registrados
- Estado de cuenta detallado con saldos

### ¿Para qué sirve?
Permite al personal consultar rápidamente:
- Estado de cuenta del concesionario
- Adeudos totales por mantenimiento
- Pagos históricos realizados
- Aplicación de descuentos y bonificaciones
- Cambios realizados al registro
- Información de contacto actual
- Generar reporte impreso del estado de cuenta

### ¿Cómo lo hace?
1. El operador captura el folio RCM a consultar
2. El sistema recupera información de múltiples tablas relacionadas:
   - Datos maestros del espacio
   - Información adicional del concesionario
   - Pagos registrados
   - Adeudos pendientes
   - Descuentos aplicados
   - Bonificaciones autorizadas
   - Histórico de cambios
   - Contactos adicionales
3. Calcula totales de adeudos, recargos y descuentos
4. Presenta la información organizada en pestañas (tabs):
   - Pestaña 1: Pagos realizados
   - Pestaña 2: Adeudos pendientes
   - Pestaña 3: Descuentos autorizados
   - Pestaña 4: Histórico de cambios
   - Pestaña 5: Estado de cuenta consolidado (cajero)
   - Pestaña 6: Contactos adicionales
5. Permite impresión del reporte completo

### ¿Qué necesita para funcionar?
- Folio RCM válido existente en el sistema
- Permisos de consulta
- Acceso a base de datos de ingresos y cementerios

## Datos y Tablas

### Tabla Principal
**ta_13_datosrcm** - Registro maestro del espacio

### Tablas Relacionadas
- **ta_13_datosrcmadic** - Datos fiscales adicionales
- **ta_13_pagosrcm** - Historial de pagos
- **ta_13_adeudosrcm** - Adeudos pendientes
- **ta_13_descuentos** - Descuentos autorizados
- **ta_13_bonifrcm** - Bonificaciones aplicadas
- **ta_historico** - Histórico de cambios del registro
- **ta_contactos** - Contactos adicionales relacionados
- **ta_usuarios** - Información de usuarios que realizaron movimientos

### Stored Procedures (SP)
- **StrdPrcCajero** - Genera estado de cuenta consolidado por cajero
  - par_control: Folio RCM
  - par_axo: Año a consultar
  - Retorna: Resumen de movimientos por línea de servicio

### Tablas que Afecta
**Solo Consulta** (no modifica datos)

## Impacto y Repercusiones

### Repercusiones Operativas
- Información completa para atención de usuarios
- Resolución rápida de dudas sobre estado de cuenta
- Soporte para negociación de pagos
- Base para análisis de cuentas problema

### Repercusiones Financieras
- Visibilidad de toda la cuenta del concesionario
- Identificación de adeudos antiguos
- Control de aplicación de descuentos
- Transparencia en el manejo de bonificaciones

### Repercusiones Administrativas
- Historial completo para auditoría
- Trazabilidad de todos los cambios
- Información para resolución de conflictos
- Documentación de comunicación con concesionarios

## Validaciones y Controles
- Valida existencia del folio antes de consultar
- Calcula descuento del 10% si aplica pronto pago (año actual antes de marzo)
- Muestra vigencia del registro (Activo/Baja)
- Diferencia entre adeudos vigentes y cancelados
- Muestra usuario y fecha de cada modificación
- Identifica tipo de espacio (Fosa/Urna/Gaveta) mediante campo calculado

## Casos de Uso
1. **Atención en ventanilla**: Usuario solicita estado de cuenta de su espacio
2. **Verificación de pagos**: Aclaración sobre pagos realizados
3. **Negociación de adeudos**: Análisis de monto total a pagar con descuentos
4. **Auditoría de cuenta**: Revisión de movimientos históricos
5. **Actualización de contacto**: Verificar información de contacto registrada
6. **Impresión de estado de cuenta**: Generar reporte para el concesionario
7. **Análisis de cambios**: Revisar quién y cuándo modificó el registro

## Usuarios del Sistema
- **Personal de Ventanilla**: Consulta para atención de usuarios
- **Cajeros**: Verificación antes de aplicar pagos
- **Supervisores**: Análisis de cuentas y resolución de problemas
- **Administradores**: Auditoría y control de movimientos
- **Contabilidad**: Verificación de aplicaciones contables

## Relaciones con Otros Módulos
- **ABCementer/ABCFolio**: Consulta datos que fueron registrados/modificados en estos módulos
- **ABCPagos**: Muestra pagos aplicados desde este módulo
- **Liquidaciones**: Consulta previa para procesar liquidación total
- **Descuentos**: Muestra descuentos autorizados en el módulo de descuentos
- **Bonificaciones**: Presenta bonificaciones registradas
- **Histórico**: Acceso al módulo de cambios históricos
- **ConIndividual**: Versión similar con funcionalidad de impresión de reportes
