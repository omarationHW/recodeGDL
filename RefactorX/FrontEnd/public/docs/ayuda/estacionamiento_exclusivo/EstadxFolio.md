# Estadísticas por Folio

## Propósito Administrativo
Generar estadísticas y reportes de notificaciones de apremios por rangos de folios, permitiendo realizar análisis del estado de los documentos de cobro coactivo.

## Funcionalidad Principal
Este módulo permite consultar y exportar a Excel estadísticas de notificaciones de apremios para uno o varios folios dentro de un rango específico, filtrados por tipo de aplicación (mercados, aseo, estacionómetros, etc.) y oficina recaudadora.

## Proceso de Negocio

### ¿Qué hace?
Genera estadísticas sobre el estado de los folios de apremios emitidos, mostrando información sobre vigencia, estado de practicado, gastos y cantidades de registros por cada combinación de estados.

### ¿Para qué sirve?
- Realizar análisis estadísticos de los documentos de cobro coactivo
- Monitorear el estado de los folios en rangos específicos
- Obtener reportes de gestión sobre notificaciones practicadas
- Exportar información a Excel para análisis adicional
- Supervisar la efectividad de la gestión de cobro

### ¿Cómo lo hace?
1. El usuario selecciona el tipo de aplicación (Mercados, Aseo, Estacionómetros, Estacionamientos Públicos, Exclusivos o Cementerios)
2. Define un rango de folios (folio inicial y folio final)
3. Selecciona la oficina recaudadora (si tiene permisos)
4. El sistema consulta las notificaciones en ese rango
5. Agrupa los resultados por vigencia y estado de practicado
6. Calcula estadísticas de gastos cobrados vs gastos acumulados
7. Presenta el resultado en pantalla o exporta a Excel

### ¿Qué necesita para funcionar?
- Usuario autenticado en el sistema
- Rango de folios válido
- Oficina recaudadora activa
- Módulo de aplicación seleccionado
- Folios existentes en el rango especificado

## Datos y Tablas

### Tabla Principal
- **ta_15_apremios**: Tabla principal que contiene todos los registros de apremios (notificaciones, requerimientos, secuestros)

### Tablas Relacionadas
- **ta_14_recaudadoras**: Información de las oficinas recaudadoras
- **ta_15_claves**: Catálogo de claves de vigencia y estados de practicado

### Stored Procedures (SP)
No utiliza stored procedures específicos. Realiza consultas SQL dinámicas.

### Tablas que Afecta
Este módulo es de solo consulta, no modifica ninguna tabla.

## Impacto y Repercusiones

### Repercusiones Operativas
- Permite monitorear el desempeño de la gestión de cobro coactivo
- Facilita la identificación de folios con problemas
- Ayuda a detectar folios sin movimiento
- Permite supervisar el trabajo de ejecutores fiscales

### Repercusiones Financieras
- Proporciona información sobre gastos de ejecución cobrados
- Muestra el estado financiero de los folios en un rango
- Permite calcular recuperación de gastos de notificación

### Repercusiones Administrativas
- Genera reportes estadísticos para la dirección
- Apoya la toma de decisiones sobre gestión de cobro
- Facilita auditorías y revisiones de expedientes
- Permite validar la efectividad de las acciones de cobro

## Validaciones y Controles
- Valida que el folio inicial no sea mayor que el folio final
- Verifica que existan registros en el rango solicitado
- Controla el acceso por oficina recaudadora según permisos del usuario
- Valida que el módulo seleccionado sea válido

## Casos de Uso
1. **Supervisor de Cobro Coactivo**: Revisa estadísticas mensuales de folios emitidos por rango
2. **Director de Ingresos**: Genera reportes ejecutivos sobre gestión de cobro
3. **Auditor Interno**: Verifica la efectividad de las notificaciones emitidas
4. **Coordinador Administrativo**: Exporta información a Excel para análisis detallado

## Usuarios del Sistema
- Supervisores de cobro coactivo
- Directores de área
- Coordinadores administrativos
- Auditores
- Personal con permisos especiales (acceso a todas las recaudadoras)

## Relaciones con Otros Módulos
- **CMultEmision**: Los folios estadísticamente analizados fueron creados en emisión múltiple
- **Notificaciones**: Estadísticas sobre el estado de las notificaciones practicadas
- **Ejecutores**: Los datos incluyen información sobre ejecutores asignados
- **Requerimientos**: Incluye estadísticas de requerimientos de pago
