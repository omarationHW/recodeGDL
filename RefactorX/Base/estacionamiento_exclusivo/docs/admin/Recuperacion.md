# Recuperacion - Reporte de Recuperación de Cartera

## Propósito Administrativo
Genera reportes estadísticos de recuperación de cartera vencida, mostrando montos cobrados, efectividad del cobro y análisis de resultados del procedimiento de apremio.

## Funcionalidad Principal
Módulo de análisis que presenta estadísticas de recuperación de adeudos por diversos criterios (ejecutor, periodo, aplicación), facilitando la evaluación de la gestión de cobro coactivo.

## Proceso de Negocio

### ¿Qué hace?
- Genera estadísticas de recuperación de cartera
- Muestra montos cobrados por periodo
- Analiza efectividad por ejecutor
- Compara metas vs. resultados
- Presenta indicadores de gestión
- Genera reportes ejecutivos

### ¿Para qué sirve?
- Evaluar efectividad del cobro coactivo
- Medir productividad de ejecutores
- Analizar tendencias de recuperación
- Tomar decisiones estratégicas
- Justificar presupuestos del área
- Reportar a dirección y cabildo

### ¿Cómo lo hace?
1. Usuario selecciona criterios de consulta
2. Define periodo de análisis
3. Sistema consulta folios pagados
4. Calcula estadísticas:
   - Monto total recuperado
   - Número de folios cobrados
   - Recuperación por ejecutor
   - Recuperación por tipo de aplicación
   - Porcentajes de efectividad
5. Genera gráficas y reportes
6. Presenta comparativos vs. periodos anteriores

### ¿Qué necesita para funcionar?
- Folios pagados en el sistema
- Periodo de análisis
- Criterios de agrupación (ejecutor, aplicación, recaudadora)
- Metas o presupuestos (opcional)

## Datos y Tablas

### Tabla Principal
**ta_15_apremios**: Folios pagados

### Tablas Relacionadas
- **ta_15_ejecutores**: Información de ejecutores
- **ta_15_detalle**: Detalle de adeudos recuperados
- **ta_catalogo_recaudadoras**: Recaudadoras
- **ta_catalogo_aplicaciones**: Aplicaciones

### Stored Procedures (SP)
Posiblemente utiliza SP para cálculos estadísticos

### Tablas que Afecta
**Solo consulta** (no modifica)

## Impacto y Repercusiones

### Repercusiones Operativas
- Permite evaluar gestión de cobranza
- Identifica áreas de mejora
- Facilita toma de decisiones

### Repercusiones Financieras
- Documenta ingresos por apremios
- Justifica inversión en cobro coactivo
- Permite proyecciones financieras

### Repercusiones Administrativas
- Genera información para reportes ejecutivos
- Facilita evaluación de desempeño
- Documenta resultados del área

## Validaciones y Controles
- Valida periodos de consulta
- Verifica datos completos
- Calcula correctamente estadísticas

## Casos de Uso

**Reporte mensual a dirección:**
- Coordinador requiere reporte del mes
- Genera estadísticas de recuperación
- Presenta monto total cobrado
- Muestra productividad por ejecutor
- Turna reporte a dirección

**Evaluación de desempeño:**
- Supervisor evalúa ejecutores del trimestre
- Genera reporte de recuperación por ejecutor
- Identifica más y menos productivos
- Toma decisiones de incentivos o capacitación

## Usuarios del Sistema
- Coordinador de ejecución fiscal
- Director de ingresos
- Supervisores de cobranza
- Contraloria/auditoría
- Tesorería municipal

## Relaciones con Otros Módulos
- **Facturacion.pas**: Fuente de datos de pagos
- **Prenomina.pas**: Complementa con información de comisiones
- **Listados.pas**: Reportes detallados
- **ABCEjec.pas**: Información de ejecutores
