# Listados por Registro

## Propósito Administrativo
Generar listados de folios de apremios por registro específico (mercado, tipo de aseo, estacionamiento, colonia) mostrando toda la información de los folios agrupados por ubicación o tipo de servicio.

## Funcionalidad Principal
Este módulo genera reportes de folios de apremios organizados por el registro original del adeudo, facilitando el análisis por mercado, tipo de aseo, estacionamiento público, exclusivo o colonia de infracciones.

## Proceso de Negocio

### ¿Qué hace?
Consulta folios de apremios filtrando por el registro específico (mercado, tipo de aseo, estacionamiento o colonia) y genera listados con toda la información del folio, permitiendo filtros adicionales por vigencia y clave de estado.

### ¿Para qué sirve?
- Generar reportes por ubicación geográfica o tipo de servicio
- Analizar la cartera de cobro por mercado o zona
- Evaluar la gestión de cobro por tipo de servicio
- Identificar patrones de morosidad por registro
- Apoyar decisiones de gestión focalizadas
- Generar estadísticas operativas por unidad administrativa

### ¿Cómo lo hace?
1. El usuario selecciona el tipo de aplicación (Mercados, Aseo, Públicos, Infracciones)
2. Define el registro específico:
   - Para Mercados: selecciona un mercado
   - Para Aseo: selecciona un tipo de aseo
   - Para Estacionamientos Públicos: indica número de estacionamiento
   - Para Infracciones: selecciona una colonia
3. Puede filtrar por todas las vigencias o una específica
4. Opcionalmente filtra por clave de practicado
5. El sistema consulta todos los folios del registro
6. Ordena los resultados
7. Genera el reporte con información completa

### ¿Qué necesita para funcionar?
- Usuario con permisos de consulta
- Registro válido seleccionado
- Oficina recaudadora asignada
- Folios registrados para ese registro específico
- Catálogos de vigencias y claves actualizados

## Datos y Tablas

### Tabla Principal
- **ta_15_apremios**: Folios de apremios

### Tablas Relacionadas
- **ta_11_mercados**: Catálogo de mercados municipales
- **ta_16_tipos_aseo**: Tipos de aseo contratado
- **ta_14_colonias**: Catálogo de colonias para infracciones
- **ta_15_claves**: Catálogos de vigencias y estados de practicado
- **ta_14_recaudadoras**: Oficinas recaudadoras

### Stored Procedures (SP)
No utiliza stored procedures. Realiza consultas SQL directas.

### Tablas que Afecta
Este módulo es de solo consulta. No modifica ninguna tabla.

## Impacto y Repercusiones

### Repercusiones Operativas
- Facilita la gestión focalizada por registro
- Permite identificar registros con mayor morosidad
- Apoya la asignación específica de ejecutores
- Genera información para acciones correctivas

### Repercusiones Financieras
- Permite analizar cartera de cobro por registro
- Facilita proyecciones de ingreso por ubicación
- Apoya decisiones de inversión en gestión de cobro
- Documenta el potencial de recuperación por zona

### Repercusiones Administrativas
- Genera reportes operativos específicos
- Apoya la toma de decisiones focalizadas
- Facilita auditorías por registro
- Permite evaluación de gestión por zona
- Documenta patrones de comportamiento de pago

## Validaciones y Controles
- Valida que el registro seleccionado exista
- Verifica que haya folios para ese registro
- Controla el acceso por oficina recaudadora
- Valida la combinación de filtros seleccionados
- Asegura la integridad de los datos consultados

## Casos de Uso
1. **Jefe de Mercados**: Solicita reporte de folios del Mercado Libertad
2. **Coordinador de Aseo**: Genera listado de folios de aseo tipo industrial
3. **Supervisor de Estacionómetros**: Consulta folios de la Colonia Centro
4. **Director**: Analiza la gestión de cobro en estacionamientos públicos
5. **Auditor**: Revisa folios emitidos para mercados específicos

## Usuarios del Sistema
- Directores y subdirectores
- Jefes de área por servicio
- Supervisores de cobro
- Coordinadores administrativos
- Auditores
- Personal de análisis

## Relaciones con Otros Módulos
- **ConsultaReg**: Consulta detallada de folios individuales
- **Listados_Ade**: Listados de adeudos por registro
- **CMultEmision**: Emisión masiva focalizada por registro
- **RprtListaxRegMer**: Reporte de mercados
- **RprtListaxRegAseo**: Reporte de aseo
- **RprtListaxRegPub**: Reporte de estacionamientos públicos
- **RprtListaxRegEstacionometro**: Reporte de infracciones
