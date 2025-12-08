# ABCRecargos - Administración de Recargos por Mora

## Propósito Administrativo
Módulo para definir y mantener las tasas de recargo mensual aplicables a adeudos de mantenimiento vencidos, permitiendo establecer porcentajes tanto parciales (por mes) como acumulados globales que se aplican automáticamente en los cobros.

## Funcionalidad Principal
Permite configurar la tabla de recargos mensuales que se aplican automáticamente sobre adeudos vencidos, definiendo porcentaje mensual y calculando automáticamente el porcentaje acumulado desde 1994 hasta el año actual.

## Proceso de Negocio

### ¿Qué hace?
Gestiona la parametrización de recargos por mora:
- Registro de porcentaje de recargo mensual por año y mes
- Cálculo automático de recargo acumulado (global)
- Actualización de tabla histórica de recargos
- Recálculo de acumulados cuando hay cambios
- Control de porcentajes máximos (tope 100% acumulado)
- Modificación de recargos existentes
- Consulta de tabla histórica completa

### ¿Para qué sirve?
Establece las tasas oficiales de recargos:
- Define el costo de mora por pago tardío
- Calcula automáticamente recargos acumulados históricos
- Proporciona base para cobro de recargos en pagos
- Permite ajustes según políticas municipales
- Mantiene histórico de tasas aplicadas

### ¿Cómo lo hace?
1. El operador captura año y mes a configurar
2. El sistema verifica si ya existe recargo para ese período
3. Si es nuevo:
   - Permite capturar porcentaje mensual
   - Inicializa porcentaje acumulado en 0
4. Si ya existe:
   - Muestra porcentaje actual
   - Permite modificarlo
5. Al guardar, el sistema ejecuta procedimiento de cálculo automático:
   - Recorre todos los registros desde 1994 hasta el año actual
   - Calcula porcentaje global acumulado: suma de todos los parciales
   - Si el acumulado supera 100%, lo topa en 100%
   - Actualiza porcentaje global en cada registro
6. Si se modifica el mes/año actual:
   - Recalcula globales de todos los meses posteriores del año
7. Muestra tabla completa de recargos para consulta

### ¿Qué necesita para funcionar?
- Año y mes válidos (no puede ser futuro)
- Porcentaje de recargo mayor a 0
- Tabla ta_13_recargosrcm inicializada desde 1994
- Permisos de usuario para modificar recargos

## Datos y Tablas

### Tabla Principal
**ta_13_recargosrcm** - Tabla de recargos mensuales
Contiene: axo, mes, porcentaje_parcial, porcentaje_global, usuario, fecha_mov

### Tablas Relacionadas
- **QryGlobal** - Consulta para calcular acumulado hasta un mes específico
- **Qryglobal1** - Consulta para calcular acumulado entre años

### Stored Procedures (SP)
Ninguno (usa SQL directo y cálculos en código)

### Tablas que Afecta
**Inserta:**
- ta_13_recargosrcm (nuevos recargos mensuales)

**Actualiza:**
- ta_13_recargosrcm (modificación de porcentajes parciales y globales)

## Impacto y Repercusiones

### Repercusiones Operativas
- Base para cálculo automático de recargos en pagos
- Consistencia en aplicación de mora
- Facilita actualización de tasas oficiales
- Elimina cálculos manuales de recargos

### Repercusiones Financieras
- Define ingresos adicionales por mora
- Incentiva pago oportuno
- Recuperación de valor del dinero por inflación
- Debe cumplir normativa de tasas municipales
- Impacta montos totales a cobrar

### Repercusiones Administrativas
- Transparencia en cálculo de recargos
- Cumplimiento de normativa fiscal
- Histórico de tasas aplicadas
- Base para resolución de controversias
- Soporte para auditorías

## Validaciones y Controles
- Valida que año no esté vacío
- Valida que mes esté entre 1 y 12
- Verifica que porcentaje parcial sea mayor a 0
- Calcula automáticamente porcentaje global (no es capturado)
- Topa porcentaje global en máximo 100%
- Recalcula automáticamente meses posteriores al modificado
- Controla transacciones para mantener consistencia
- Registra usuario y fecha de cada modificación

## Casos de Uso
1. **Alta de recargo mensual**: Configurar recargo de 1.5% para el mes actual
2. **Modificación de recargo**: Ajustar recargo de 1.5% a 1.8% por actualización oficial
3. **Consulta de histórico**: Ver tabla completa de recargos desde 1994
4. **Recálculo de acumulados**: Al modificar un mes, actualizar todos los globales
5. **Configuración anual**: Establecer recargo uniforme para todo el año
6. **Ajuste por inflación**: Modificar recargos según índices oficiales

## Usuarios del Sistema
- **Jefe de Departamento**: Autorización de tasas de recargo
- **Administradores del Sistema**: Captura de recargos autorizados
- **Contabilidad**: Consulta de tasas vigentes
- **Supervisores**: Verificación de cálculos

## Relaciones con Otros Módulos
- **ABCPagos**: Aplica recargos según tabla al procesar pagos
- **Liquidaciones**: Calcula recargos totales usando esta tabla
- **Rep_a_Cobrar**: Reporte de adeudos incluye recargos calculados
- **Sistema de Cálculo de Adeudos**: Usa tabla para determinar mora aplicable
