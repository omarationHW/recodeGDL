# Exportar a Excel

## Propósito Administrativo
Exportar información de folios pagados a formato Excel para análisis externo, auditorías y presentación de informes detallados sobre la gestión de cobro.

## Funcionalidad Principal
Este módulo permite consultar folios de apremios que han sido pagados dentro de un rango específico y exportar toda su información detallada a un archivo de Excel, facilitando el análisis y reporteo externo.

## Proceso de Negocio

### ¿Qué hace?
Genera una consulta de folios pagados filtrando por múltiples criterios (oficina, módulo, rango de folios, fechas de emisión y pago) y exporta los resultados a un archivo Excel con toda la información detallada de cada folio.

### ¿Para qué sirve?
- Generar reportes de folios pagados para auditorías
- Exportar información para análisis en herramientas externas
- Crear respaldos de información de pagos
- Proporcionar evidencia documental de cobros realizados
- Facilitar la reconciliación contable de ingresos por apremios

### ¿Cómo lo hace?
1. El usuario selecciona el tipo de aplicación (Mercados, Aseo, Estacionómetros, Públicos, Exclusivos o Cementerios)
2. Define el rango de folios a consultar
3. Establece la fecha de emisión de los folios
4. Define el rango de fechas de pago
5. Selecciona la oficina recaudadora
6. El sistema ejecuta el stored procedure que consulta los folios pagados
7. Muestra los resultados en pantalla
8. Permite exportar directamente a Excel con todos los detalles

### ¿Qué necesita para funcionar?
- Usuario autenticado con acceso al sistema
- Rango de folios válido (folio inicial menor o igual a folio final)
- Oficina recaudadora activa
- Fechas válidas de emisión y pago
- Stored procedure de consulta funcional
- Permiso para exportar información

## Datos y Tablas

### Tabla Principal
- **ta_15_apremios**: Registros de apremios con información de pagos

### Tablas Relacionadas
- **ta_14_recaudadoras**: Información de oficinas recaudadoras
- **ta_11_locales**: Datos de locales en mercados (cuando aplica)
- **ta_16_contratos_aseo**: Contratos de aseo contratado (cuando aplica)
- **dbestacion::pubmain**: Estacionamientos públicos (cuando aplica)
- **dbestacion::ex_contrato**: Estacionamientos exclusivos (cuando aplica)
- **ta_14_infracciones_placas**: Infracciones de estacionómetros (cuando aplica)
- **ta_13_cementerios**: Contratos de cementerios (cuando aplica)

### Stored Procedures (SP)
- **sp_folios_pagados**: Consulta folios pagados con todos sus detalles
  - Parámetros: oficina recaudadora, módulo, rango de folios, fecha de emisión, rango de fechas de pago
  - Retorna: Todos los campos del folio incluyendo datos del registro original (local, contrato, estacionamiento, etc.)

### Tablas que Afecta
Este módulo es de solo consulta, no modifica ninguna tabla.

## Impacto y Repercusiones

### Repercusiones Operativas
- Facilita la generación de reportes de gestión
- Agiliza la preparación de información para auditorías
- Permite análisis detallado de la efectividad del cobro
- Apoya el seguimiento de metas de recaudación

### Repercusiones Financieras
- Proporciona evidencia documental de ingresos por apremios
- Facilita la reconciliación contable de pagos
- Permite análisis de recuperación de adeudos
- Apoya el cálculo de indicadores financieros de cobro

### Repercusiones Administrativas
- Genera información para reportes gerenciales
- Facilita el cumplimiento de obligaciones de transparencia
- Apoya la toma de decisiones basada en datos
- Permite auditorías internas y externas

## Validaciones y Controles
- Valida que el folio inicial no sea mayor que el folio final
- Verifica que las fechas de pago sean válidas
- Controla el acceso por oficina según permisos del usuario
- Valida que existan registros antes de exportar
- Asegura que el módulo seleccionado sea válido

## Casos de Uso
1. **Auditor Externo**: Solicita información de pagos de un periodo para auditoría
2. **Contador**: Necesita conciliar ingresos por apremios con registros contables
3. **Director de Ingresos**: Genera reportes ejecutivos de recuperación de cartera vencida
4. **Coordinador Administrativo**: Prepara información para informes de transparencia
5. **Supervisor de Cobro**: Analiza la efectividad de las acciones de cobro coactivo

## Usuarios del Sistema
- Directores y subdirectores de área
- Contadores y personal de finanzas
- Auditores internos y externos
- Coordinadores administrativos
- Supervisores de cobro coactivo
- Personal con permisos especiales

## Relaciones con Otros Módulos
- **Recuperacion**: Los folios exportados son resultado de la gestión de cobro
- **Notificaciones**: Los pagos corresponden a folios notificados
- **Facturacion**: Los pagos pueden estar relacionados con certificados de pago
- **ConsultaReg**: Permite consultar el detalle individual de los folios exportados
