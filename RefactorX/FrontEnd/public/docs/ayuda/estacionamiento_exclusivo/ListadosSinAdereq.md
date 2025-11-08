# Listados sin Adeudos (Requerimientos)

## Propósito Administrativo
Generar listados de contribuyentes que tienen requerimientos de pago vigentes pero ya no tienen adeudos pendientes, identificando casos donde el adeudo fue liquidado después de emitir el requerimiento.

## Funcionalidad Principal
Este módulo genera reportes de folios de requerimiento que están vigentes pero cuyos adeudos originales ya fueron pagados, permitiendo identificar casos que requieren cancelación o verificación administrativa.

## Proceso de Negocio

### ¿Qué hace?
Consulta folios de requerimientos vigentes y los cruza con la base de adeudos, identificando aquellos casos donde el contribuyente ya liquidó su deuda pero el folio de apremio aún está activo en el sistema.

### ¿Para qué sirve?
- Identificar requerimientos que deben cancelarse
- Detectar pagos realizados después de la emisión del requerimiento
- Evitar gestiones de cobro innecesarias
- Mantener la integridad de la base de datos
- Generar reportes de conciliación
- Facilitar auditorías de procesos

### ¿Cómo lo hace?
1. El usuario selecciona el tipo de aplicación (Mercados o Aseo)
2. Define el mercado o tipo específico
3. Puede filtrar todos los registros o un rango
4. El sistema consulta folios de apremio vigentes
5. Verifica si existe adeudo en la base de datos
6. Identifica casos donde no hay adeudo pendiente
7. Lista los requerimientos sin adeudo
8. Muestra información del folio y del último movimiento
9. Incluye datos del bloqueo si existe

### ¿Qué necesita para funcionar?
- Usuario con permisos de consulta
- Folios de requerimientos vigentes
- Base de adeudos actualizada
- Información de locales o contratos
- Datos de último movimiento del folio

## Datos y Tablas

### Tabla Principal
- **ta_15_apremios**: Folios de requerimientos vigentes

### Tablas Relacionadas
- **ta_11_locales**: Datos de locales en mercados
- **ta_11_adeudo_local**: Adeudos de locales (para verificar inexistencia)
- **ta_16_contratos_aseo**: Contratos de aseo
- **ta_16_adeudos_aseo**: Adeudos de aseo (para verificar inexistencia)
- **ta_15_bloqueos**: Información de bloqueos en el registro
- **ta_14_recaudadoras**: Oficinas recaudadoras

### Stored Procedures (SP)
No utiliza stored procedures. Realiza consultas SQL con joins y subqueries.

### Tablas que Afecta
Este módulo es de solo consulta. No modifica ninguna tabla.

## Impacto y Repercusiones

### Repercusiones Operativas
- Identifica requerimientos que deben cancelarse
- Evita gestiones de cobro innecesarias
- Optimiza el trabajo de ejecutores fiscales
- Mantiene la calidad de la base de datos
- Facilita la depuración de registros

### Repercusiones Financieras
- Evita costos de gestión en casos ya liquidados
- Permite identificar pagos no aplicados correctamente
- Facilita conciliación de ingresos
- Apoya la depuración de cartera

### Repercusiones Administrativas
- Mantiene la integridad de los registros
- Facilita auditorías de procesos
- Genera información para depuración de bases
- Apoya la mejora continua de procesos
- Documenta casos especiales

## Validaciones y Controles
- Verifica la vigencia de los folios
- Confirma la inexistencia de adeudos
- Valida la información de locales o contratos
- Controla el acceso por oficina recaudadora
- Asegura la integridad de los datos consultados

## Casos de Uso
1. **Supervisor de Cobro**: Identifica requerimientos para cancelación
2. **Auditor**: Detecta inconsistencias en la base de datos
3. **Coordinador**: Genera reporte de casos especiales
4. **Contador**: Concilia pagos con requerimientos vigentes
5. **Jefe de Área**: Solicita depuración de base de datos

## Usuarios del Sistema
- Supervisores de cobro coactivo
- Auditores internos
- Coordinadores administrativos
- Contadores
- Jefes de área
- Personal con permisos especiales

## Relaciones con Otros Módulos
- **ConsultaReg**: Consulta detallada de cada folio
- **Modifcar**: Modificación individual para cancelar folios
- **Recuperacion**: Verificación de pagos realizados
- **Cons_his**: Consulta del historial del folio
- **AutorizaDes**: Autorización para cancelar requerimientos
