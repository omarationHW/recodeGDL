# Contratos_Ins

## Propósito Administrativo
Administración y gestión de contratos de servicio de aseo del sistema de aseo (recolección de basura/limpieza urbana).

## Funcionalidad Principal
Este módulo se clasifica como: **Gestión de Contratos**

### Descripción
Módulo para registrar nuevos contratos de servicio de recolección de basura. Este es uno de los módulos más críticos del sistema ya que establece la relación contractual entre el municipio y las empresas recolectoras.

## Proceso de Negocio

### ¿Qué hace?
1. Captura información de un nuevo contrato de servicio de aseo
2. Asocia el contrato con una empresa recolectora
3. Define el tipo de servicio de aseo contratado
4. Establece la cantidad de unidades de recolección
5. Asigna zona, sector y recaudadora
6. Define el período de inicio de obligación
7. Genera automáticamente los adeudos mensuales correspondientes

### ¿Para qué sirve?
- Formalizar contratos de servicio de recolección de basura
- Establecer la base para la generación de cobros periódicos
- Vincular empresas con servicios específicos
- Definir responsabilidades de recolección por zona

### ¿Cómo lo hace?
1. Solicita número de contrato y tipo de aseo
2. Permite buscar o crear empresa contratante
3. Captura domicilio de recolección
4. Define unidades de recolección (tipo y cantidad)
5. Asigna zona geográfica y recaudadora
6. Establece período de inicio de obligación (mes/año)
7. Ejecuta stored procedure para crear el contrato
8. Genera automáticamente los pagos mensuales proyectados desde el período inicial hasta fin de año y año siguiente

### ¿Qué necesita para funcionar?
- Catálogo de empresas actualizado
- Catálogo de tipos de aseo
- Catálogo de unidades de recolección con costos por ejercicio
- Catálogo de zonas y recaudadoras
- Stored procedure de generación de contratos
- Ejercicio fiscal activo

## Datos y Tablas

### Tabla Principal
- **ta_16_tipos_emp**: Tabla principal que maneja este módulo

### Tablas Relacionadas
- **ta_16_empresas**: Tabla relacionada utilizada en el módulo
- **ta_16_unidades**: Tabla relacionada utilizada en el módulo

### Stored Procedures (SP)
- **SpdGenContrato**: Procedimiento almacenado utilizado
- **SpdGenContratoexpression**: Procedimiento almacenado utilizado
- **StoredProc**: Procedimiento almacenado utilizado

### Operaciones SQL
Este módulo realiza operaciones: Select, Insert

### Tablas que Afecta
Modifica registros en: ta_16_empresas, ta_16_tipos_emp, ta_16_unidades

## Impacto y Repercusiones

### Repercusiones Operativas
- Afecta directamente la gestión de contratos de servicio
- Impacta en la programación de recolección
- Influye en la asignación de recursos
- Determina responsabilidades de servicio

### Repercusiones Financieras
- Impacto directo en ingresos municipales
- Afecta cuentas por cobrar
- Influye en flujo de efectivo
- Determina montos de recaudación

### Repercusiones Administrativas
- Genera registros para auditoría
- Mantiene histórico de operaciones
- Facilita generación de reportes gerenciales
- Apoya en indicadores de gestión

## Validaciones y Controles
- Validación de existencia de empresa
- Control de duplicidad de número de contrato
- Verificación de datos completos antes de grabar
- Validación de período válido (año)
- Control transaccional (rollback en caso de error)
- Generación automática de pagos asociados

## Casos de Uso
1. **Alta de nuevo contrato residencial**: Se registra un nuevo contrato para servicio de recolección domiciliaria, se asocia con el contribuyente (empresa), se define cantidad de tambos, zona y recaudadora
2. **Alta de contrato comercial**: Similar al anterior pero para servicios comerciales con mayor volumen de recolección
3. **Generación automática de adeudos**: Al crear el contrato, el sistema genera automáticamente los períodos de pago mensuales desde la fecha de inicio hasta fin del año actual y todo el año siguiente

## Usuarios del Sistema
- **Administrativos**: Personal que gestiona contratos
- **Capturistas**: Operadores que registran información
- **Supervisores**: Personal que revisa y autoriza contratos

## Relaciones con Otros Módulos
- **ABC_Empresas**: Para seleccionar o crear la empresa contratante
- **ABC_Tipos_Aseo**: Para definir el tipo de servicio
- **ABC_Und_Recolec**: Para seleccionar unidades de recolección y costos
- **ABC_Zonas**: Para asignar zona geográfica
- **ABC_Recaudadoras**: Para asignar recaudadora responsable
- **Adeudos**: Genera automáticamente los adeudos mensuales del contrato
- **Pagos**: Los pagos futuros estarán vinculados a este contrato


---
**Nota**: Este documento fue generado mediante análisis automatizado del código fuente. La información presentada se enfoca en aspectos administrativos y de negocio del módulo.
