# Sistema de APREMIOS - Documentación Administrativa

## Descripción del Sistema

**APREMIOS** es un sistema integral de cobro coactivo y ejecución fiscal diseñado para recuperar adeudos morosos mediante procedimientos administrativos de ejecución. El sistema gestiona el ciclo completo desde la identificación de cuentas morosas hasta la recuperación del adeudo, pasando por notificaciones, requerimientos, embargos y facturación.

### Alcance del Sistema

El sistema APREMIOS maneja el cobro ejecutivo de diversas aplicaciones municipales:
- **Mercados**: Locales comerciales en mercados municipales
- **Aseo**: Servicios de recolección de basura
- **Estacionamientos Públicos**: Estacionamientos operados por el municipio
- **Estacionamientos Exclusivos**: Estacionamientos privados con permiso
- **Infracciones**: Multas de tránsito y estacionómetros
- **Cementerios**: Cuotas de mantenimiento de fosas y panteones

### Objetivo del Sistema

Recuperar la cartera vencida del municipio mediante procedimientos legales de cobro coactivo, garantizando:
- Cumplimiento del marco legal del procedimiento administrativo de ejecución
- Trazabilidad completa de todas las actuaciones
- Eficiencia en la recuperación de adeudos
- Control de ejecutores fiscales y notificadores
- Documentación legal de cada etapa del procedimiento
- Gestión de comisiones y prenómina de ejecutores

## Arquitectura del Sistema

**Tecnología**: Delphi 7/2006
**Base de Datos**: MySQL / Interbase
**Tipo**: Aplicación cliente-servidor MDI (Multiple Document Interface)
**Seguridad**: Autenticación por usuario y contraseña, permisos por nivel

## Módulos del Sistema

### 1. MÓDULOS DE ACCESO Y CONTROL

#### acceso.pas
**Control de Acceso y Autenticación de Usuarios**
- Valida credenciales de usuario
- Establece sesión y permisos
- Controla ejercicio fiscal de trabajo
- [Ver documentación completa](./acceso.md)

#### Menu.pas
**Menú Principal del Sistema**
- Hub central de navegación
- Control de acceso a módulos
- Gestión de permisos por usuario
- [Ver documentación completa](./Menu.md)

#### ModuloDb.pas
**Módulo de Conexión a Base de Datos**
- Gestión centralizada de conexiones
- Funciones utilitarias comunes
- Variables globales del sistema
- [Ver documentación completa](./ModuloDb.md)

#### sfrm_chgpass.pas
**Cambio de Contraseña**
- Permite al usuario cambiar su contraseña
- Valida contraseña actual
- Establece nueva contraseña

### 2. MÓDULOS DE CATÁLOGOS

#### ABCEjec.pas
**Alta, Baja y Cambios de Ejecutores Fiscales**
- Gestión del catálogo de ejecutores
- Alta, modificación y baja de personal ejecutor
- Control de vigencia de nombramientos
- [Ver documentación completa](./ABCEjec.md)

#### Ejecutores.pas
**Búsqueda y Selección de Ejecutores**
- Catálogo de consulta rápida
- Búsqueda por clave o nombre
- Módulo auxiliar para selección
- [Ver documentación completa](./Ejecutores.md)

### 3. MÓDULOS DE CONSULTA

#### Individual.pas
**Consulta Individual de Folios por ID**
- Consulta detallada de folio por ID de control
- Muestra historial completo del folio
- Despliega toda la información del procedimiento

#### Individual_Folio.pas
**Consulta Individual por Número de Folio**
- Búsqueda de folio por número y recaudadora
- Consulta directa sin conocer ID
- Acceso rápido a información del folio

#### ConsultaReg.pas
**Consulta de Registros por Aplicación**
- Búsqueda de folios por datos de cuenta
- Consulta por mercado, aseo, infracciones, etc.
- Localización sin conocer número de folio
- [Ver documentación completa](./ConsultaReg.md)

#### Cons_his.pas
**Consulta de Historial de Folios**
- Historial completo de movimientos
- Trazabilidad de cambios y estados
- Auditoría de procedimiento
- [Ver documentación completa](./Cons_his.md)

#### CMultFolio.pas
**Consulta Múltiple por Rango de Folios**
- Búsqueda por rango de 100 folios consecutivos
- Consulta de bloques de folios
- [Ver documentación completa](./CMultFolio.md)

#### CMultEmision.pas
**Consulta Múltiple por Fecha de Emisión**
- Búsqueda de folios emitidos en fecha específica
- Auditoría de emisiones por fecha
- [Ver documentación completa](./CMultEmision.md)

#### EstadxFolio.pas
**Estado por Folio**
- Consulta rápida del estado actual del folio
- Información resumida de diligencias

### 4. MÓDULOS DE PROCESOS PRINCIPALES

#### Requerimientos.pas
**Generación de Requerimientos de Pago**
- Genera folios de apremio
- Calcula adeudos con recargos y gastos
- Imprime requerimientos oficiales
- Asigna ejecutores fiscales
- [Ver documentación completa](./Requerimientos.md)

#### Notificaciones.pas
**Generación de Notificaciones Oficiales**
- Notificaciones subsecuentes al requerimiento
- Control de entregas y citatorios
- Actualización de gastos por diligencias
- [Ver documentación completa](./Notificaciones.md)

#### NotificacionesMes.pas
**Reporte Mensual de Notificaciones**
- Estadísticas de notificaciones por mes
- Control de productividad de notificadores
- Reporte ejecutivo mensual

#### CartaInvitacion.pas
**Gestión de Cartas Invitación de Pago**
- Genera cartas previas al apremio formal
- Asigna y controla cartas por ejecutor
- Imprime cartas invitación oficiales
- Seguimiento de efectividad
- [Ver documentación completa](./CartaInvitacion.md)

#### Facturacion.pas
**Registro de Pagos de Apremios**
- Registra pagos de folios
- Aplica descuentos autorizados
- Cierra ciclo de cobro
- [Ver documentación completa](./Facturacion.md)

### 5. MÓDULOS DE MODIFICACIÓN

#### Modifcar.pas / Modificar_bien.pas
**Modificación de Folios y Bienes**
- Modificación de datos de folios
- Actualización de información de bienes embargados
- Corrección de datos del procedimiento

#### Modif_Masiva.pas
**Modificación Masiva de Folios**
- Actualización masiva de folios
- Cambios en lote
- Reasignación masiva de ejecutores

#### Reasignacion.pas
**Reasignación de Folios entre Ejecutores**
- Cambio de ejecutor asignado
- Redistribución de carga de trabajo
- Control de reasignaciones

### 6. MÓDULOS DE DESCUENTOS

#### AutorizaDes.pas
**Autorización de Descuentos en Apremios**
- Autoriza descuentos sobre adeudos
- Control de funcionarios autorizantes
- Validación de porcentajes
- Recálculo de montos con descuento
- [Ver documentación completa](./AutorizaDes.md)

#### ReportAutor.pas
**Reporte de Descuentos Autorizados**
- Listado de descuentos otorgados
- Reporte por funcionario autorizante
- Auditoría de descuentos

### 7. MÓDULOS DE REPORTES Y LISTADOS

#### Listados.pas
**Listados Generales de Apremios**
- Reportes de folios por diversos filtros
- Listados por estado, ejecutor, fecha
- Exportación de información

#### Listados_Ade.pas
**Listados de Adeudos**
- Reportes de adeudos pendientes
- Análisis de cartera vencida

#### ListadosSinAdereq.pas
**Listados Sin Adeudos de Requerimiento**
- Folios sin requerimiento aún
- Cuentas pendientes de generar apremio

#### List_Eje.pas / Lista_Eje.pas
**Listados de Ejecutores**
- Reportes de productividad de ejecutores
- Estadísticas por ejecutor
- Carga de trabajo

#### ListxFec.pas
**Listados por Fecha**
- Reportes filtrados por fechas
- Análisis por periodos

#### ListxReg.pas
**Listados por Registro/Aplicación**
- Reportes por tipo de aplicación
- Mercados, aseo, infracciones, etc.

#### Lista_GastosCob.pas
**Listado de Gastos Cobrados**
- Reporte de gastos de ejecución recuperados
- Análisis de costos vs. recuperación

#### Prenomina.pas
**Generación de Prenómina de Ejecutores**
- Cálculo de comisiones
- Prenómina por periodo
- Distribución de pagos
- [Ver documentación completa](./Prenomina.md)

#### Recuperacion.pas
**Reporte de Recuperación de Cartera**
- Estadísticas de recuperación
- Análisis de efectividad del cobro
- Indicadores de gestión

### 8. MÓDULOS DE REPORTES ESPECÍFICOS (RprtXXX.pas)

Los módulos que inician con "Rprt" y "Rpt" son reportes específicos para impresión:

- **RprtCATAL_EJE.pas**: Catálogo de ejecutores
- **RprtEstadxfolio.pas**: Reporte de estado por folio
- **RprtList_Eje.pas**: Reporte de lista de ejecutores
- **RprtListados.pas**: Reporte de listados generales
- **RprtListaxFec.pas**: Reporte por fecha
- **RprtListaxRegAseo.pas**: Reporte por registro de aseo
- **RprtListaxRegEstacionometro.pas**: Reporte de estacionómetros
- **RprtListaxRegMer.pas**: Reporte por registro de mercados
- **RprtListaxRegPub.pas**: Reporte de estacionamientos públicos
- **RptFact_Merc.pas**: Facturación de mercados
- **RptLista_mercados.pas**: Lista de mercados
- **RptListado_Aseo.pas**: Listado de aseo
- **RptPrenomina.pas**: Reporte de prenómina
- **RptRecup_Aseo.pas / RptRecup_Merc.pas**: Recuperación por tipo
- **RptReq_Aseo.pas / RptReq_Merc.pas / RptReq_pba.pas / RptReq_Pba_Aseo.pas**: Requerimientos por tipo

### 9. MÓDULOS DE UTILIDADES

#### ExportarExcel.pas
**Exportación a Excel**
- Exporta reportes y listados a Excel
- Facilita análisis externo
- Genera archivos para auditorías

#### FirmaElectronica.pas
**Firma Electrónica de Documentos**
- Integración con firma electrónica
- Validación de documentos oficiales
- Cumplimiento de normatividad digital

## Flujo del Proceso de Apremios

### 1. Identificación de Cuentas Morosas
- El sistema identifica cuentas con adeudos vencidos
- Se consultan adeudos por aplicación (mercados, aseo, etc.)

### 2. Generación de Cartas Invitación (Opcional)
- **CartaInvitacion.pas**: Genera cartas previas al apremio
- Se da oportunidad de pago voluntario
- Se reduce costo del procedimiento

### 3. Emisión de Requerimientos
- **Requerimientos.pas**: Genera folios de apremio oficiales
- Se calculan adeudos con recargos y gastos
- Se asignan ejecutores fiscales
- Se imprimen documentos oficiales

### 4. Notificación
- **Notificaciones.pas**: Ejecutores notifican requerimientos
- Se registran entregas y citatorios
- Se documentan diligencias
- Se actualizan gastos

### 5. Descuentos (Si Aplica)
- **AutorizaDes.pas**: Se autoriza descuento si procede
- Se recalculan montos
- Se documenta autorización

### 6. Pago
- **Facturacion.pas**: Se registra pago del contribuyente
- Se aplican descuentos autorizados
- Se cierra folio

### 7. Prenómina
- **Prenomina.pas**: Se calcula comisión del ejecutor
- Se genera prenómina por periodo
- Se documenta productividad

### 8. Reportes y Auditoría
- Múltiples módulos de listados y reportes
- Se generan estadísticas de recuperación
- Se audita el proceso completo

## Tablas Principales de la Base de Datos

### Tablas Maestras de Apremios
- **ta_15_apremios**: Folios de apremio (tabla principal)
- **ta_15_detalle**: Detalle de periodos adeudados por folio
- **ta_15_ejecutores**: Catálogo de ejecutores fiscales
- **ta_15_gastos**: Gastos de ejecución por año/mes
- **ta_15_recargos**: Porcentajes de recargos moratorios
- **ta_15_autorizados**: Descuentos autorizados
- **ta_15_quienautor**: Funcionarios autorizados para descuentos
- **ta_15_cartasinvitacion**: Cartas invitación generadas

### Tablas de Aplicaciones (Cuentas Morosas)
- **ta_11_locales / ta_11_adeudos**: Mercados
- **ta_16_contratos_aseo / ta_16_adeudos**: Aseo
- **ta_24_estacionamientospublicos**: Estacionamientos públicos
- **ta_28_estacionamientosexclusivos**: Estacionamientos exclusivos
- **ta_14_infracciones / ta_14_placas**: Infracciones de tránsito
- **ta_13_cementerios**: Cementerios y panteones

### Tablas de Control
- **ta_usuarios**: Usuarios del sistema
- **ta_catalogo_recaudadoras**: Recaudadoras del municipio
- **ta_catalogo_aplicaciones**: Módulos/aplicaciones del sistema
- **ta_versiones**: Control de versiones de aplicaciones
- **ta_permiso_adic**: Permisos adicionales de usuarios

## Conceptos Clave del Sistema

### Folio de Apremio
Documento oficial que inicia el procedimiento administrativo de ejecución. Contiene:
- Identificación única del procedimiento
- Datos del contribuyente y cuenta morosa
- Desglose del adeudo (impuesto, recargos, gastos, multas)
- Fundamentación legal
- Ejecutor asignado
- Control de diligencias

### Ejecutor Fiscal
Servidor público facultado legalmente para:
- Practicar notificaciones
- Realizar embargos
- Documentar diligencias
- Representar a la autoridad fiscal

### Diligencias
Actuaciones del ejecutor en el procedimiento:
- **Emisión**: Generación del folio de apremio
- **Practicación**: Entrega del requerimiento al contribuyente
- **Primera Entrega**: Primer intento de notificación
- **Segunda Entrega**: Segundo intento de notificación
- **Citatorio**: Llamado oficial cuando no se localiza al contribuyente
- **Secuestro/Embargo**: Aseguramiento de bienes
- **Remate**: Venta de bienes embargados

### Gastos de Ejecución
Costos del procedimiento que se suman al adeudo:
- Gastos de notificación
- Gastos de requerimiento
- Gastos de embargo
- Gastos de avalúo
- Gastos de publicación

### Recargos
Porcentaje mensual que se aplica sobre el adeudo principal por concepto de mora. Se calculan desde la fecha de vencimiento hasta la fecha de pago.

### Descuentos Autorizados
Porcentajes de descuento que funcionarios autorizados pueden otorgar sobre adeudos para incentivar el pago voluntario y recuperación de cartera.

## Usuarios Típicos del Sistema

- **Coordinador de Ejecución Fiscal**: Supervisa todo el proceso
- **Ejecutores Fiscales**: Practican diligencias y notificaciones
- **Personal de Emisión**: Genera folios de apremio
- **Cajeros/Recaudación**: Registran pagos
- **Supervisores de Cobranza**: Controlan gestión de cobranza
- **Personal de Auditoría**: Verifican procedimientos
- **Jefes de Recaudadora**: Administran su área
- **Director de Ingresos**: Toma decisiones estratégicas

## Reportes y Estadísticas

El sistema genera múltiples reportes para control y toma de decisiones:
- Folios emitidos por periodo
- Folios practicados y pendientes
- Pagos y recuperación de cartera
- Productividad de ejecutores
- Descuentos autorizados
- Gastos de ejecución cobrados
- Prenómina de ejecutores
- Antigüedad de adeudos
- Efectividad de cobro

## Consideraciones Legales

El sistema APREMIOS debe cumplir con:
- Código Fiscal de la Federación
- Ley de Hacienda Municipal
- Reglamentos municipales
- Procedimiento Administrativo de Ejecución
- Derechos del contribuyente
- Fundamentación y motivación de actos
- Plazos legales del procedimiento

## Seguridad y Auditoría

- Autenticación por usuario y contraseña
- Permisos por nivel de usuario
- Registro de usuario en cada operación
- Bitácora de modificaciones
- Control de versiones de aplicación
- Trazabilidad completa de operaciones
- Respaldos de base de datos

## Archivos de Documentación Generados

En este directorio encontrarás documentación detallada para cada módulo del sistema:

1. [ABCEjec.md](./ABCEjec.md) - Alta, Baja y Cambios de Ejecutores
2. [acceso.md](./acceso.md) - Control de Acceso
3. [AutorizaDes.md](./AutorizaDes.md) - Autorización de Descuentos
4. [CartaInvitacion.md](./CartaInvitacion.md) - Cartas Invitación
5. [CMultEmision.md](./CMultEmision.md) - Consulta Múltiple por Emisión
6. [CMultFolio.md](./CMultFolio.md) - Consulta Múltiple por Folio
7. [Cons_his.md](./Cons_his.md) - Consulta de Historial
8. [ConsultaReg.md](./ConsultaReg.md) - Consulta por Registro
9. [Ejecutores.md](./Ejecutores.md) - Búsqueda de Ejecutores
10. [Facturacion.md](./Facturacion.md) - Registro de Pagos
11. [Menu.md](./Menu.md) - Menú Principal
12. [ModuloDb.md](./ModuloDb.md) - Módulo de Base de Datos
13. [Notificaciones.md](./Notificaciones.md) - Notificaciones Oficiales
14. [Prenomina.md](./Prenomina.md) - Prenómina de Ejecutores
15. [Requerimientos.md](./Requerimientos.md) - Requerimientos de Pago

## Mantenimiento y Soporte

Para mantenimiento del sistema se recomienda:
- Respaldar base de datos regularmente
- Mantener actualizado el catálogo de ejecutores
- Revisar y actualizar gastos de ejecución periódicamente
- Actualizar porcentajes de recargos según normatividad
- Mantener control de versiones actualizado
- Capacitar constantemente a usuarios
- Realizar auditorías periódicas

## Conclusión

El sistema APREMIOS es una herramienta integral para la gestión del cobro coactivo municipal. Automatiza y controla todo el procedimiento administrativo de ejecución, desde la identificación de cuentas morosas hasta la recuperación del adeudo, garantizando cumplimiento legal, trazabilidad completa y eficiencia operativa.

---

**Fecha de Documentación**: Octubre 2025
**Sistema**: APREMIOS - Cobro Coactivo y Ejecución Fiscal
**Municipio**: Guadalajara, Jalisco
**Tecnología**: Delphi + MySQL/Interbase
