# Sistema de Cementerios Municipales - Documentación Completa

## Descripción General del Sistema

El **Sistema de Cementerios** es una aplicación integral para la administración de servicios funerarios municipales del Ayuntamiento de Guadalajara. Gestiona el control completo de espacios funerarios (fosas, urnas y gavetas) en los diferentes panteones municipales, incluyendo:

- Registro de concesiones y títulos de propiedad
- Control de pagos de mantenimiento anual
- Gestión de adeudos, recargos, descuentos y bonificaciones
- Traslados de restos entre espacios
- Emisión de títulos de propiedad
- Reportes administrativos y financieros

## Panteones Municipales Administrados

1. **Panteón Municipal de Guadalajara** (GUAD)
2. **Panteón de Mezquitán** (MEZQ)
3. **Panteón de San Andrés** (SAND)
4. **Panteón Jardín** (JARD)

## Estructura del Sistema

El sistema está organizado en módulos funcionales que cubren los siguientes procesos:

### 1. CATÁLOGOS Y REGISTROS

#### Gestión de Espacios Funerarios
- **[ABCementer.md](ABCementer.md)** - Alta, Baja y Cambio de registros de espacios por ubicación
- **[ABCFolio.md](ABCFolio.md)** - Modificación de registros por folio RCM

#### Acceso y Seguridad
- **[Acceso.md](Acceso.md)** - Control de acceso y autenticación de usuarios
- **[sfrm_chgpass.md](sfrm_chgpass.md)** - Cambio de contraseña

#### Infraestructura
- **[Modulo.md](Modulo.md)** - Módulo de datos global (conexiones, funciones, variables)
- **[Menu.md](Menu.md)** - Menú principal del sistema

### 2. OPERACIONES FINANCIERAS

#### Pagos y Cobranza
- **[ABCPagos.md](ABCPagos.md)** - Registro de pagos de mantenimiento anual
- **[ABCPagosxfol.md](ABCPagosxfol.md)** - Pagos por folio (versión rápida)
- **[Liquidaciones.md](Liquidaciones.md)** - Liquidación total de adeudos

#### Descuentos y Bonificaciones
- **[Descuentos.md](Descuentos.md)** - Gestión de descuentos autorizados
- **[Bonificaciones.md](Bonificaciones.md)** - Gestión de bonificaciones por oficio
- **[Bonificacion1.md](Bonificacion1.md)** - Bonificaciones por recaudadora
- **[ABCRecargos.md](ABCRecargos.md)** - Administración de recargos por mora

### 3. TÍTULOS Y DOCUMENTACIÓN

#### Títulos de Propiedad
- **[Titulos.md](Titulos.md)** - Impresión de títulos de propiedad
- **[TitulosSin.md](TitulosSin.md)** - Títulos simplificados
- **[Duplicados.md](Duplicados.md)** - Reimpresión de títulos (duplicados)
- **[RptTitulos.md](RptTitulos.md)** - Reporte de títulos emitidos

### 4. TRASLADOS

#### Gestión de Traslados de Restos
- **[Traslados.md](Traslados.md)** - Gestión general de traslados
- **[TrasladoFol.md](TrasladoFol.md)** - Traslados por folio
- **[TrasladoFolSin.md](TrasladoFolSin.md)** - Traslados simplificados

### 5. CONSULTAS

#### Consultas Individuales
- **[ConsultaFol.md](ConsultaFol.md)** - Consulta individual por folio RCM
- **[ConIndividual.md](ConIndividual.md)** - Consulta individual detallada con reportes

#### Consultas Múltiples
- **[MultipleRCM.md](MultipleRCM.md)** - Consulta múltiple por ubicación física
- **[MultipleNombre.md](MultipleNombre.md)** - Consulta múltiple por nombre
- **[Multiplefecha.md](Multiplefecha.md)** - Consulta múltiple por fecha
- **[ConsultaNombre.md](ConsultaNombre.md)** - Consulta general por nombre
- **[ConsultaRCM.md](ConsultaRCM.md)** - Consulta general por criterios RCM

#### Consultas por Panteón
- **[ConsultaGuad.md](ConsultaGuad.md)** - Consulta del Panteón Guadalajara
- **[ConsultaMezq.md](ConsultaMezq.md)** - Consulta del Panteón Mezquitán
- **[ConsultaSAndres.md](ConsultaSAndres.md)** - Consulta del Panteón San Andrés
- **[ConsultaJardin.md](ConsultaJardin.md)** - Consulta del Panteón Jardín

#### Consultas Especiales
- **[consulta400.md](consulta400.md)** - Consulta de bases históricas (sistema anterior)

### 6. REPORTES Y ESTADÍSTICAS

#### Reportes Financieros
- **[Rep_a_Cobrar.md](Rep_a_Cobrar.md)** - Reporte de cuentas por cobrar
- **[Rep_Bon.md](Rep_Bon.md)** - Reporte de bonificaciones
- **[Estad_adeudo.md](Estad_adeudo.md)** - Estadísticas de adeudos

#### Reportes Operativos
- **[List_Mov.md](List_Mov.md)** - Listado de movimientos y auditoría

## Tablas Principales de la Base de Datos

### Tablas Maestras
- **ta_13_datosrcm** - Registro maestro de espacios funerarios
- **ta_13_datosrcmadic** - Información adicional de concesionarios (RFC, CURP, teléfono)
- **ta_usuarios** - Catálogo de usuarios del sistema
- **ta_cementerios** - Catálogo de cementerios municipales
- **ta_recaudadoras** - Catálogo de oficinas recaudadoras

### Tablas Transaccionales
- **ta_13_pagosrcm** - Registro de pagos de mantenimiento y servicios
- **ta_13_adeudosrcm** - Adeudos pendientes de mantenimiento anual
- **ta_13_recargosrcm** - Tabla de recargos mensuales por mora
- **ta_13_descuentos** - Descuentos autorizados
- **ta_13_bonifrcm** - Bonificaciones autorizadas por oficio
- **ta_13_titulosrcm** - Títulos de propiedad emitidos
- **ta_13_traslados** - Registro de traslados de restos

### Tablas de Control
- **ta_historico** - Histórico de cambios en registros
- **ta_autoriza** - Autorizaciones especiales por usuario
- **ta_contactos** - Contactos adicionales de concesionarios

## Flujos de Proceso Principales

### 1. Venta de Nueva Concesión
```
ABCementer → Captura de datos → Generación de adeudos → ABCPagos (pago inicial) → Titulos (emisión de título)
```

### 2. Pago de Mantenimiento Anual
```
ConsultaFol (verificar adeudo) → ABCPagos (aplicar pago) → Actualización de adeudos
```

### 3. Liquidación de Adeudos Históricos
```
Rep_a_Cobrar (identificar adeudos) → Liquidaciones (pago total) → Actualización de último año pagado
```

### 4. Cesión de Derechos
```
Liquidaciones (requisito) → ABCFolio (cambio de titular) → Titulos (nuevo título) → ABCPagos (pago de cesión)
```

### 5. Traslado de Restos
```
ConsultaFol (verificar origen) → Liquidaciones (requisito) → Traslados (registro) → Actualización de registros
```

## Tipos de Usuarios

### Nivel 1 - Cajeros
- Aplicación de pagos
- Consultas básicas
- Sin modificaciones de registros

### Nivel 2 - Supervisores de Ventanilla
- Todas las funciones de cajeros
- Modificación de registros
- Autorización de descuentos

### Nivel 3 - Administradores de Panteones
- Gestión completa de registros
- Traslados y movimientos
- Reportes operativos

### Nivel 4 - Jefes de Departamento
- Autorización de bonificaciones
- Configuración de recargos
- Acceso a todos los reportes

### Nivel 9 - Administradores del Sistema
- Acceso completo
- Gestión de usuarios
- Configuración del sistema

## Conceptos Clave

### Folio RCM
Número único de control asignado a cada espacio funerario. Es la llave principal para todas las operaciones del sistema.

### Tipos de Espacios
- **F** - Fosa (terreno)
- **U** - Urna (para cenizas)
- **G** - Gaveta (nicho en pared)

### Ubicación Física
Cada espacio se identifica por:
- **Cementerio**: GUAD, MEZQ, SAND, JARD
- **Clase**: 1 (Primera), 2 (Segunda), 3 (Tercera) + variante alfabética
- **Sección**: Número + variante alfabética
- **Línea**: Número + variante alfabética
- **Fosa**: Número + variante alfabética (alfanumérica)

### Conceptos Financieros
- **Adeudo**: Monto pendiente de pago por mantenimiento anual
- **Recargo**: Porcentaje de mora sobre adeudo vencido (tabla mensual)
- **Descuento**: Reducción autorizada sobre adeudo (10% pronto pago automático)
- **Bonificación**: Condonación por oficio oficial

## Generación de esta Documentación

Esta documentación fue generada analizando 36 archivos .pas del sistema CEMENTERIOS ubicado en:
```
C:/Sistemas/RefactorX/Guadalajara/Originales/Code/199/aplicaciones/Ingresos/cementeriosSVN
```

Cada documento .md describe:
- Propósito administrativo del módulo
- Funcionalidad principal
- Proceso de negocio detallado
- Datos y tablas involucradas
- Impacto y repercusiones (operativas, financieras, administrativas)
- Validaciones y controles
- Casos de uso prácticos
- Usuarios del sistema que lo utilizan
- Relaciones con otros módulos

## Nota Importante

Esta documentación se enfoca en los **procesos administrativos y de negocio** que soporta el sistema, **no en detalles técnicos de programación**. El objetivo es que sea comprensible tanto para usuarios técnicos como no técnicos, facilitando:

- Capacitación de nuevo personal
- Comprensión de procesos operativos
- Análisis de requerimientos para refactorización
- Documentación para auditorías
- Base para migración a nuevas tecnologías

---

**Sistema de Cementerios - Ayuntamiento de Guadalajara**
**Documentación generada:** 29 de Octubre de 2025
**Total de módulos documentados:** 36
