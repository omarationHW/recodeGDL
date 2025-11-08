# Documentación del Sistema de ASEO (Recolección de Basura/Limpieza Urbana)

## Resumen Ejecutivo

Este directorio contiene la documentación administrativa completa de los **104 módulos** que componen el sistema de ASEO del Ayuntamiento de Guadalajara. La documentación fue generada mediante análisis automatizado del código fuente, enfocándose exclusivamente en aspectos de negocio y procesos administrativos.

**Fecha de generación**: 29 de Octubre, 2025
**Total de módulos documentados**: 104 archivos .md
**Directorio fuente**: `C:/Sistemas/RefactorX/Guadalajara/Originales/Code/196/aplicaciones/repositories/Ingresos/aseo`

---

## Estructura del Sistema

El sistema de ASEO se organiza en los siguientes subsistemas:

### 1. Catálogos (ABM - Altas, Bajas y Modificaciones)
Módulos para administración de catálogos maestros:

- **ABC_Cves_Operacion.md** - Catálogo de claves de operación
- **ABC_Empresas.md** - Catálogo de empresas recolectoras
- **ABC_Gastos.md** - Catálogo de gastos
- **ABC_Recargos.md** - Catálogo de recargos
- **ABC_Recaudadoras.md** - Catálogo de recaudadoras
- **ABC_Tipos_Aseo.md** - Catálogo de tipos de servicio de aseo
- **ABC_Tipos_Emp.md** - Catálogo de tipos de empresa
- **ABC_Und_Recolec.md** - Catálogo de unidades de recolección
- **ABC_Zonas.md** - Catálogo de zonas geográficas

### 2. Mantenimiento de Catálogos
Módulos de mantenimiento para catálogos:

- **Mannto_Empresas.md** - Mantenimiento de empresas
- **Mannto_Gastos.md** - Mantenimiento de gastos
- **Mannto_Operaciones.md** - Mantenimiento de operaciones
- **Mannto_Recargos.md** - Mantenimiento de recargos
- **Mannto_Recaudadoras.md** - Mantenimiento de recaudadoras
- **Mannto_Tipos_Aseo.md** - Mantenimiento de tipos de aseo
- **Mannto_Tipos_Emp.md** - Mantenimiento de tipos de empresa
- **Mannto_Und_Recolec.md** - Mantenimiento de unidades de recolección
- **Mannto_Zonas.md** - Mantenimiento de zonas

### 3. Gestión de Contratos
Módulos para administración de contratos de servicio:

- **Contratos.md** - Padrón de contratos
- **Contratos_Ins.md** - Alta de nuevos contratos
- **Contratos_Ins_b.md** - Alta de contratos (versión alternativa)
- **Contratos_Upd.md** - Actualización de contratos
- **Contratos_Upd_01.md** - Actualización de contratos (versión 01)
- **Contratos_Upd_IniObl.md** - Actualización de período inicial de obligación
- **Contratos_Upd_Periodo.md** - Actualización de período
- **Contratos_Upd_Und.md** - Actualización de unidades
- **Contratos_Upd_UndC.md** - Actualización de cantidad de unidades
- **Contratos_UpdxCont.md** - Actualización por número de contrato
- **Contratos_Del.md** - Baja de contratos
- **Contratos_Cancela.md** - Cancelación de contratos
- **Contratos_Adeudos.md** - Consulta de contratos con adeudos

### 4. Consultas de Contratos
Módulos de consulta de información de contratos:

- **Contratos_Cons.md** - Consulta general de contratos
- **Contratos_Cons_Admin.md** - Consulta administrativa
- **Contratos_Cons_Cont.md** - Consulta por número de contrato
- **Contratos_Cons_ContAsc.md** - Consulta por contrato ascendente
- **Contratos_Cons_Dom.md** - Consulta por domicilio
- **Contratos_Consulta.md** - Consulta de contratos
- **ContratosEst.md** - Estadísticas de contratos
- **Contratos_EstGral.md** - Estadísticas generales
- **Contratos_EstGral2.md** - Estadísticas generales v2

### 5. Gestión de Adeudos
Módulos para administración de adeudos y cuentas por cobrar:

- **Adeudos_Ins.md** - Alta individual de adeudos
- **AdeudosMult_Ins.md** - Alta múltiple de adeudos
- **Adeudos_Carga.md** - Carga masiva de adeudos
- **Adeudos_Nvo.md** - Nuevo módulo de adeudos
- **Adeudos_EdoCta.md** - Estado de cuenta
- **Adeudos_Venc.md** - Adeudos vencidos
- **Adeudos_UpdExed.md** - Actualización de exedencias
- **Adeudos_OpcMult.md** - Opciones múltiples de adeudos
- **AdeudosExe_Del.md** - Eliminación de exedencias
- **AdeudosCN_Cond.md** - Condonación de cuota normal
- **AdeudosEst.md** - Estadísticas de adeudos

### 6. Gestión de Pagos
Módulos para registro y control de pagos:

- **Adeudos_Pag.md** - Registro de pagos individual
- **Adeudos_PagMult.md** - Registro de pagos múltiples
- **Adeudos_PagUpdPer.md** - Actualización de período pagado
- **Pagos_Con_FPgo.md** - Consulta de pagos por fecha
- **Pagos_Cons_Cont.md** - Consulta de pagos por contrato
- **Pagos_Cons_ContAsc.md** - Consulta de pagos por contrato ascendente

### 7. Consultas de Catálogos
Módulos de consulta de catálogos:

- **Cons_Cves_operacion.md** - Consulta de claves de operación
- **Cons_Empresas.md** - Consulta de empresas
- **Cons_Tipos_Aseo.md** - Consulta de tipos de aseo
- **Cons_Tipos_Emp.md** - Consulta de tipos de empresa
- **Cons_Und_Recolec.md** - Consulta de unidades de recolección
- **Cons_Zonas.md** - Consulta de zonas

### 8. Reportes
Módulos para generación de reportes:

- **Rep_Adeudos.md** - Reporte de adeudos
- **Rep_AdeudCond.md** - Reporte de adeudos condonados
- **Rep_Contratos.md** - Reporte de contratos
- **Rep_Empresas.md** - Reporte de empresas
- **Rep_PadronContratos.md** - Reporte de padrón de contratos
- **Rep_Recaudadoras.md** - Reporte de recaudadoras
- **Rep_Tipos_Aseo.md** - Reporte de tipos de aseo
- **Rep_Tipos_Emp.md** - Reporte de tipos de empresa
- **Rep_Zonas.md** - Reporte de zonas
- **frmRep_Und_Recolec.md** - Reporte de unidades de recolección

### 9. Reportes con Quick Report (sQRpt)
Módulos de reportes con componentes QuickReport:

- **sQRptAdeudos.md** - Reporte de adeudos
- **sQRptAdeudosCond.md** - Reporte de adeudos condonados
- **sQRptAdeudosVenc.md** - Reporte de adeudos vencidos
- **sQRptContratos.md** - Reporte de contratos
- **sQRptContratos_Det.md** - Reporte detallado de contratos
- **sQRptContratos_Est.md** - Reporte estadístico de contratos
- **sQRptContratos_EstGral.md** - Reporte estadístico general
- **sQRptCves_Operacion.md** - Reporte de claves de operación
- **sQRptEmpresas.md** - Reporte de empresas
- **sQRptPagosXContrato.md** - Reporte de pagos por contrato
- **sQRptRecaudadoras.md** - Reporte de recaudadoras
- **sQRptTipos_Aseo.md** - Reporte de tipos de aseo
- **sQRptTipos_Empresas.md** - Reporte de tipos de empresas
- **sQRptUnd_Recolec.md** - Reporte de unidades de recolección
- **sQRptZonas.md** - Reporte de zonas

### 10. Módulos Especiales
Módulos con funcionalidad específica:

- **Menu.md** - Menú principal del sistema
- **ActCont_CR.md** - Actualización de contratos
- **AplicaMultasNormal.md** - Aplicación de multas normales
- **Ctrol_Imp_Cat.md** - Control de impresión de catálogos
- **DatosConvenio.md** - Datos de convenios
- **Dscto_p_pago.md** - Descuento por pronto pago
- **Ejercicios_Ins.md** - Alta de ejercicios fiscales
- **Empresas_Contratos.md** - Relación empresas-contratos
- **Licencias_Relacionadas.md** - Licencias relacionadas
- **ReqsCons.md** - Consulta de requerimientos
- **Prueba.md** - Módulo de pruebas

### 11. Módulos de Infraestructura
Módulos de soporte técnico y acceso:

- **sDM_Procesos.md** - Data Module de procesos
- **uDM_Procesos.md** - Unit Data Module de procesos
- **unAcceso.md** - Unidad de control de acceso
- **unVariables.md** - Unidad de variables globales
- **Unit1.md** - Unidad auxiliar

---

## Tablas Principales del Sistema

El sistema de ASEO utiliza principalmente estas tablas de la base de datos:

### Tablas Maestras (Catálogos)
- **ta_16_empresas** - Empresas recolectoras y contribuyentes
- **ta_16_tipos_emp** - Tipos de empresa
- **ta_16_tipo_aseo** - Tipos de servicio de aseo
- **ta_16_unidades** - Unidades de recolección con costos
- **ta_16_operacion** - Claves de operación
- **ta_16_zonas** - Zonas geográficas
- **ta_16_recaudadoras** - Recaudadoras y cajas
- **ta_16_recargos** - Catálogo de recargos
- **ta_16_gastos** - Catálogo de gastos

### Tablas Transaccionales
- **ta_16_contratos** - Contratos de servicio
- **ta_16_pagos** - Registro de pagos y adeudos
- **ta_16_ejercicios** - Ejercicios fiscales

---

## Procesos de Negocio Principales

### 1. Ciclo de Vida de un Contrato
1. **Alta de Contrato** (`Contratos_Ins.md`)
   - Captura de datos del contrato
   - Asociación con empresa
   - Definición de servicio y unidades
   - Generación automática de adeudos

2. **Actualización de Contrato** (`Contratos_Upd_*.md`)
   - Modificación de unidades
   - Cambio de período
   - Actualización de datos generales

3. **Consulta de Contratos** (`Contratos_Cons_*.md`)
   - Por número de contrato
   - Por empresa
   - Por domicilio
   - Consultas estadísticas

4. **Cancelación** (`Contratos_Cancela.md`)
   - Baja de contratos
   - Cancelación de obligaciones futuras

### 2. Ciclo de Gestión de Adeudos
1. **Generación de Adeudos**
   - Automática al crear contrato
   - Captura manual individual
   - Captura múltiple
   - Carga masiva

2. **Control de Adeudos**
   - Consulta de estado de cuenta
   - Identificación de vencidos
   - Generación de requerimientos

3. **Registro de Pagos** (`Adeudos_Pag.md`)
   - Pago en ventanilla
   - Registro de transacción
   - Actualización de estado

4. **Operaciones Especiales**
   - Condonación
   - Cancelación
   - Prescripción

### 3. Proceso de Recaudación
1. Contribuyente acude a pagar
2. Cajero localiza adeudos pendientes
3. Se muestra cuota normal y exedencias
4. Se capturan datos de pago
5. Se registra transacción
6. Se actualiza estado de cuenta
7. Se genera recibo

---

## Flujo de Información

```
Catálogos Maestros
    ↓
Contratos de Servicio
    ↓
Generación de Adeudos
    ↓
Registro de Pagos
    ↓
Reportes y Estadísticas
```

---

## Usuarios del Sistema

### Perfiles Operativos
- **Capturistas**: Personal que registra información de contratos y datos básicos
- **Cajeros**: Personal de recaudación que procesa pagos
- **Supervisores de Caja**: Personal que supervisa operaciones de caja
- **Administrativos de Cobranza**: Personal que gestiona adeudos y requerimientos

### Perfiles Administrativos
- **Administradores de Catálogos**: Personal que mantiene catálogos maestros
- **Supervisores**: Personal que revisa y autoriza operaciones
- **Gerentes**: Personal directivo que consulta reportes

### Perfiles Técnicos
- **Administradores del Sistema**: Personal técnico con acceso total
- **Auditores**: Personal de control interno

---

## Impacto del Sistema

### Impacto Operativo
- Control completo del servicio de recolección de basura
- Administración de contratos con empresas recolectoras
- Gestión de zonas y sectores de recolección

### Impacto Financiero
- Generación de ingresos por servicio de aseo
- Control de cuentas por cobrar
- Seguimiento de recaudación
- Gestión de cartera vencida

### Impacto Administrativo
- Trazabilidad completa de operaciones
- Generación de reportes gerenciales
- Soporte para auditorías
- Indicadores de gestión

---

## Validaciones y Controles del Sistema

### Controles de Integridad
- Validación de duplicidad en contratos
- Control de integridad referencial entre tablas
- Verificación de existencia de empresas

### Controles Transaccionales
- Uso de transacciones para operaciones críticas
- Rollback automático en caso de error
- Control de concurrencia

### Controles de Seguridad
- Control de acceso por usuario
- Registro de auditoría (usuario, fecha, hora)
- Trazabilidad de cambios

### Controles de Negocio
- Validación de períodos válidos
- Control de status (Vigente/Pagado/Cancelado)
- Validación de datos requeridos

---

## Estructura de la Documentación

Cada archivo .md contiene las siguientes secciones:

1. **Propósito Administrativo**: Descripción general del módulo
2. **Funcionalidad Principal**: Clasificación y descripción
3. **Proceso de Negocio**: Qué hace, para qué sirve, cómo lo hace, qué necesita
4. **Datos y Tablas**: Tablas, stored procedures, operaciones SQL
5. **Impacto y Repercusiones**: Operativas, financieras, administrativas
6. **Validaciones y Controles**: Controles implementados
7. **Casos de Uso**: Ejemplos prácticos
8. **Usuarios del Sistema**: Perfiles de usuario
9. **Relaciones con Otros Módulos**: Dependencias e interacciones

---

## Notas Importantes

1. **Enfoque Administrativo**: Esta documentación se centra en aspectos de negocio y procesos administrativos, omitiendo detalles técnicos de programación.

2. **Generación Automatizada**: Los documentos fueron generados mediante análisis automatizado del código fuente Pascal/Delphi.

3. **Base de Datos**: El sistema utiliza una base de datos denominada `ingresosifx` con tablas prefijadas con `ta_16_`.

4. **Ejercicio Fiscal**: El sistema maneja el concepto de ejercicio fiscal activo, fundamental para operaciones.

5. **Status de Registros**: Los registros utilizan códigos de status:
   - V = Vigente
   - P = Pagado
   - C = Cancelado

---

## Clasificación de Módulos por Función

### Módulos de Catálogo (ABM): 9
Módulos ABC_* para administración de catálogos maestros

### Módulos de Mantenimiento: 9
Módulos Mannto_* para mantenimiento de catálogos

### Módulos de Contratos: 19
Módulos Contratos_* para gestión del ciclo de vida de contratos

### Módulos de Adeudos: 11
Módulos Adeudos* para gestión de cuentas por cobrar

### Módulos de Pagos: 6
Módulos Pagos_* para registro de pagos

### Módulos de Consulta: 6
Módulos Cons_* para consultas de información

### Módulos de Reportes: 25
Módulos Rep_* y sQRpt* para generación de reportes

### Módulos Especiales: 11
Módulos con funcionalidad específica del sistema

### Módulos de Infraestructura: 5
Módulos técnicos de soporte

### Módulo Principal: 1
Menu.md - Menú principal del sistema

---

## Glosario de Términos

- **ASEO**: Servicio de recolección de basura y limpieza urbana
- **Contrato**: Acuerdo de servicio entre el municipio y una empresa/contribuyente
- **Empresa**: Entidad que contrata el servicio (puede ser persona física o moral)
- **Unidad de Recolección**: Tipo de servicio (ej: tambo, contenedor) con costo asociado
- **Cuota Normal**: Pago regular mensual del servicio
- **Exedencia**: Cargo adicional por servicio extraordinario o exceso de recolección
- **Recaudadora**: Entidad autorizada para recibir pagos
- **Zona**: División geográfica para control de servicios
- **Sector**: Subdivisión de zona (H, J, R, L)
- **Ejercicio**: Año fiscal
- **Período**: Mes específico de un ejercicio
- **Status Vigencia**: Estado del registro (V=Vigente, P=Pagado, C=Cancelado)
- **Ctrol**: Abreviatura de "Control" usada en nombres de campos
- **Aso_mes**: Año y mes en formato de fecha

---

## Recomendaciones para Uso de la Documentación

1. **Para Usuarios Operativos**: Consulte los módulos específicos que utiliza en su operación diaria para entender el proceso completo.

2. **Para Administradores**: Revise los módulos de catálogos (ABC_* y Mannto_*) para comprender la información maestra del sistema.

3. **Para Gerentes**: Consulte los módulos de reportes (Rep_* y sQRpt*) y estadísticos para entender los indicadores disponibles.

4. **Para Auditores**: Revise las secciones de "Validaciones y Controles" y "Tablas que Afecta" de cada módulo.

5. **Para Nuevos Usuarios**: Comience por Menu.md para entender la estructura general, luego revise los módulos de su área.

---

## Contacto y Soporte

Para dudas sobre esta documentación o el sistema, contacte al área de Sistemas del Ayuntamiento de Guadalajara.

---

**Última actualización**: 29 de Octubre, 2025
**Versión de documentación**: 1.0
**Estado**: Completado - 104 módulos documentados

---

Este documento fue generado como índice general de la documentación del Sistema de ASEO.
