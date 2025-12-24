# Consulta de Licencias

## Descripción General

### ¿Qué hace este módulo?
Módulo de consulta integral de licencias de funcionamiento. Permite buscar licencias por múltiples criterios, visualizar información completa, consultar adeudos, ver historial, generar extractos y exportar información.

### ¿Para qué sirve en el proceso administrativo?
- Consultar información de licencias vigentes y canceladas
- Verificar adeudos y pagos realizados
- Generar extractos de cuenta
- Exportar información para análisis
- Consultar historial de cambios
- Ver anuncios asociados a la licencia
- Bloquear/desbloquear licencias
- Consultar zona catastral
- Ver permisos de pago parcial

### ¿Quiénes lo utilizan?
- Personal de ventanilla
- Área de cobros
- Personal de consultas ciudadanas
- Supervisores
- Auditores
- Personal administrativo

## Proceso Administrativo

### Métodos de Búsqueda:

#### 1. Por Número de Licencia:
- Ingresar número de licencia
- Búsqueda directa y rápida

#### 2. Por Ubicación:
- Calle (búsqueda o selección)
- Número exterior (puede ser rango)
- Número interior
- Letras exterior/interior
- Permite rangos de números

#### 3. Por Propietario:
- Nombre completo o parcial
- Búsqueda por coincidencias

#### 4. Por Tramite:
- Folio de trámite que generó la licencia

#### 5. Por RFC:
- Búsqueda por RFC del titular

#### 6. Por Email:
- Búsqueda por correo electrónico

#### 7. Por Fechas:
- Rango de fechas de otorgamiento

#### 8. Por Giro:
- Tipo de licencia/giro económico
- Con o sin adeudo
- Fecha de otorgamiento

#### 9. Por Características:
- Vigencia (vigente/cancelada)
- Con/sin adeudo
- Zona y subzona
- Recaudación
- Bloqueadas/desbloqueadas
- Empresa

#### 10. Por Empresa:
- Número de empresa

#### 11. Por Autoevaluación:
- Rango de fechas de autoevaluaciones

### Información que se Visualiza:

**Pestaña Datos Generales:**
- Número de licencia y empresa
- Nombre del propietario
- RFC, CURP
- Domicilio fiscal
- Ubicación del establecimiento
- Giro y actividad
- Fecha de otorgamiento
- Estado (vigente/cancelado)
- Bloqueado/desbloqueado

**Pestaña Anuncios:**
- Lista de anuncios asociados
- Datos de cada anuncio
- Estado de cada uno

**Pestaña Saldos:**
- Adeudos por año
- Derechos, recargos, formas
- Total adeudado
- Gastos y multas

**Pestaña Pagos:**
- Historial de pagos
- Recaudación, caja, folio
- Fecha y hora
- Montos pagados
- Detalle de cada pago

**Pestaña Historial:**
- Versiones anteriores de la licencia
- Cambios realizados

**Pestaña Permisos de Pago Parcial:**
- Autorizaciones para baja
- Usuario que autorizó
- Fecha de autorización

**Pestaña Zona Catastral:**
- Zona y subzona asignadas
- Historial de cambios de zona

## Tablas de Base de Datos

### Tablas Principales:
- **licencias**: Datos de las licencias

### Tablas que Consulta:
- anuncios: Anuncios de la licencia
- c_giros: Catálogo de giros
- detsaldos: Detalle de adeudos
- saldos_lic: Saldos totales
- pagos: Historial de pagos
- detpago: Detalle de pagos
- h_licencias: Historial
- convctaQry: Cuentas catastrales
- spget_lic_adeudos: SP de adeudos
- get_gastoslic: SP de gastos y multas
- get_reqlicpag: SP de requerimientos pagados
- licencias_zona: Zonas catastrales
- bloqueos: Bloqueos de la licencia
- lic_pagoparcial: Permisos especiales

### Tablas que Modifica:
- **bloqueaLic**: UPDATE para bloquear
- **cancelaUltimo**: UPDATE historial de bloqueos
- **addbloqueo**: INSERT nuevo bloqueo

## Stored Procedures:

**spget_lic_adeudos**: Calcula adeudos detallados por año
**get_gastoslic**: Obtiene gastos de ejecución y multas
**get_reqlicpag**: Requerimientos pagados

## Documentos que Genera:
1. **Extracto de Adeudo**: Estado de cuenta completo con adeudos
2. **Listado**: Reporte de todas las licencias consultadas
3. **Exportación**: Archivo de texto con información de licencias

## Funcionalidades Especiales:

### Bloqueo de Licencias:
- Permite bloquear licencias masivamente
- Requiere motivo de bloqueo
- Marca como bloqueado=1
- Registra en historial

### Desbloqueo:
- Desbloquea licencias previamente bloqueadas
- Requiere observaciones
- Marca como bloqueado=0

### Exportación:
- Genera archivo de texto con información
- Incluye todos los resultados de la búsqueda
- Formato compatible con Excel
- Incluye datos de adeudos

### Extracto:
- Documento imprimible con estado de cuenta
- Incluye derechos, recargos, formas
- Muestra gastos y multas
- Detalle de pagos realizados

## Impacto y Repercusiones:
- Consultas no modifican datos (excepto bloqueos)
- Información en tiempo real
- Base para atención ciudadana
- Herramienta de auditoría y control

## Notas Importantes:

### Estados de Vigencia:
- **V (Vigente)**: Licencia activa
- **C (Cancelada)**: Licencia cancelada
- **B (Baja)**: Licencia dada de baja
- **A (Estado 1)**: Suspensión temporal

### Bloqueos:
- Bloqueo impide renovaciones y trámites
- Se registra motivo y usuario
- Se puede desbloquear posteriormente
- Queda en historial

### Adeudos:
- Se calculan en tiempo real
- Incluyen derechos, recargos, formas
- Suman gastos de ejecución y multas
- Consideran descuentos aplicables

### Mejores Prácticas:
1. Verificar vigencia antes de tramitar
2. Revisar adeudos completos
3. Consultar anuncios asociados
4. Verificar historial en casos dudosos
5. Usar búsqueda por ubicación para verificar direcciones
6. Exportar cuando se necesiten análisis masivos
7. Generar extracto para entregar al contribuyente
8. Documentar motivo al bloquear
