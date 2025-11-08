# Reporte de Autorizaciones de Descuento

## Propósito Administrativo
Generar documentos oficiales de autorización de descuentos en multas y recargos, con fundamento legal y firmas electrónicas de los funcionarios competentes según el porcentaje de condonación autorizado.

## Funcionalidad Principal
Este módulo genera formatos oficiales de autorización de descuentos en multas de apremios pagados, incluyendo el fundamento legal, porcentaje de condonación, datos del contribuyente, información del pago y firmas de los funcionarios autorizados según el monto del descuento.

## Proceso de Negocio

### ¿Qué hace?
Genera documentos oficiales de autorización de descuentos en multas, imprimiendo hasta 3 autorizaciones por hoja, con toda la información legal necesaria, fundamentos jurídicos y firmas electrónicas de los funcionarios competentes, además de actualizar automáticamente el estado de las autorizaciones pagadas.

### ¿Para qué sirve?
- Formalizar legalmente las autorizaciones de descuento
- Generar documentos oficiales con validez jurídica
- Certificar las condonaciones otorgadas
- Documentar el fundamento legal de cada autorización
- Incluir firmas electrónicas de funcionarios competentes
- Mantener evidencia para auditorías
- Cumplir con requisitos de transparencia
- Actualizar automáticamente registros de autorizaciones pagadas

### ¿Cómo lo hace?
1. El usuario selecciona el rango de fechas de alta de autorizaciones
2. Opcionalmente puede filtrar por oficina recaudadora
3. El sistema consulta autorizaciones en ese periodo
4. Para cada autorización obtiene:
   - Datos del folio de apremio
   - Información del contribuyente
   - Datos del pago realizado
   - Porcentaje de descuento autorizado
   - Funcionario que autorizó
5. Determina el funcionario firmante según porcentaje:
   - 21-50% con cve_aut≠2: Director de Ingresos (con fundamento legal completo)
   - 21-50% con cve_aut=2: Secretario General del Ayuntamiento
   - 51-75%: Tesorero Municipal (con fundamento legal completo)
   - 76-99%: Presidente Municipal
   - 100%: Director de Catastro
6. Genera el documento con formato oficial incluyendo:
   - Escudo del municipio
   - Número de folio de autorización
   - Fecha de autorización
   - Datos del contribuyente
   - Concepto del adeudo (mercado, aseo, etc.)
   - Importe de la sanción
   - Porcentaje de descuento
   - Importe a pagar
   - Datos del pago (recaudadora, operación, caja, fecha, importe)
   - Fundamento legal (para descuentos de Director y Tesorero)
   - Nombre y cargo del funcionario autorizante
7. Imprime hasta 3 autorizaciones por hoja
8. Después de imprimir, ejecuta queries para:
   - Cancelar autorizaciones vigentes que ya fueron pagadas
   - Actualizar porcentaje a 100% en autorizaciones pagadas al 100%

### ¿Qué necesita para funcionar?
- Usuario con permisos para generar autorizaciones
- Rango de fechas válido
- Autorizaciones registradas con estado de alta
- Información completa del pago
- Datos del contribuyente
- Catálogos de funcionarios actualizados
- Formato oficial de documento

## Datos y Tablas

### Tabla Principal
- **ta_15_autorizaciones**: Registros de autorizaciones de descuento

### Tablas Relacionadas
- **ta_15_apremios**: Folios de apremios relacionados
- **ta_11_locales**: Datos de locales en mercados
- **ta_16_contratos_aseo**: Contratos de aseo
- **ta_14_recaudadoras**: Oficinas recaudadoras
- **ta_15_usuarios**: Usuarios que autorizaron

### Stored Procedures (SP)
No utiliza stored procedures para generar el reporte, pero ejecuta queries de actualización.

### Tablas que Afecta
- **UPDATE en ta_15_autorizaciones**:
  - Cancela autorizaciones vigentes que ya fueron pagadas (estado=0, fecha_baja=hoy)
  - Actualiza porcentaje a 100% en autorizaciones pagadas al 100%

## Impacto y Repercusiones

### Repercusiones Operativas
- Formaliza legalmente las condonaciones
- Genera documentos oficiales certificados
- Agiliza el proceso de autorización
- Mantiene trazabilidad completa
- Actualiza automáticamente registros pagados

### Repercusiones Financieras
- Documenta la condonación de ingresos
- Certifica el monto de descuentos otorgados
- Facilita auditorías financieras
- Apoya conciliaciones contables
- Registra evidencia de pagos con descuento

### Repercusiones Administrativas
- Cumple requisitos legales de autorización
- Genera evidencia para expedientes
- Documenta competencia del funcionario autorizante
- Facilita auditorías de legalidad
- Apoya transparencia y rendición de cuentas
- Mantiene actualizado el estado de autorizaciones

## Validaciones y Controles
- Valida que fecha desde sea menor o igual a fecha hasta
- Verifica que existan autorizaciones en el periodo
- Controla el acceso por oficina recaudadora
- Valida que las autorizaciones tengan pago registrado
- Determina automáticamente el funcionario competente
- Incluye fundamentos legales según corresponda
- Actualiza automáticamente registros pagados

## Casos de Uso
1. **Coordinador de Autorizaciones**: Genera reportes diarios de autorizaciones
2. **Director de Ingresos**: Firma electrónicamente autorizaciones de 21-50%
3. **Tesorero**: Autoriza descuentos de 51-75% con fundamento legal
4. **Auditor**: Revisa autorizaciones y sus fundamentos legales
5. **Contador**: Concilia descuentos autorizados con ingresos

## Usuarios del Sistema
- Coordinadores de autorizaciones
- Directores de área
- Tesorero municipal
- Personal administrativo
- Auditores
- Contadores

## Relaciones con Otros Módulos
- **AutorizaDes**: Captura de autorizaciones de descuento
- **Recuperacion**: Registro de pagos con descuento
- **ConsultaReg**: Consulta de folios con autorización
- **Facturacion**: Certificación de pagos
