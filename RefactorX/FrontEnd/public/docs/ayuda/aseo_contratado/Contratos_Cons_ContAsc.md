# Contratos_Cons_ContAsc

## Propósito Administrativo
Módulo de consulta de información del sistema de aseo (recolección de basura/limpieza urbana).

## Funcionalidad Principal
Este módulo se clasifica como: **Consulta**

### Descripción
Módulo de consulta del catálogo de **Contratos ContAsc**. Permite visualizar la información registrada sin capacidad de modificación.

## Proceso de Negocio

### ¿Qué hace?
- Presenta una vista de consulta del catálogo de Contratos ContAsc
- Muestra los registros en formato de grilla
- Permite ordenar y filtrar información
- Facilita la exportación de datos

### ¿Para qué sirve?
- Consultar información del catálogo sin riesgo de modificación
- Generar reportes y análisis
- Verificar datos existentes
- Apoyar en la toma de decisiones

### ¿Cómo lo hace?
1. Carga todos los registros del catálogo
2. Los presenta en una grilla de solo lectura
3. Permite ordenamiento por columnas
4. Opcionalmente permite exportación a Excel

### ¿Qué necesita para funcionar?
- Permisos de consulta
- Conexión a la base de datos

## Datos y Tablas

### Tabla Principal
- **ta_16_unidades**: Tabla principal que maneja este módulo

### Tablas Relacionadas
- **ta_16_contratos**: Tabla relacionada utilizada en el módulo
- **ta_16_empresas**: Tabla relacionada utilizada en el módulo
- **ta_16_tipo_aseo**: Tabla relacionada utilizada en el módulo
- **ta_16_tipos_emp**: Tabla relacionada utilizada en el módulo
- **ta_16_zonas**: Tabla relacionada utilizada en el módulo

### Stored Procedures (SP)
- No se identificaron stored procedures explícitos

### Operaciones SQL
Este módulo realiza operaciones: Select

### Tablas que Afecta
Este módulo es principalmente de consulta, no modifica datos directamente

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
- Validación de permisos de usuario
- Control de acceso a funciones
- Verificación de datos de entrada
- Manejo de errores y excepciones

## Casos de Uso
1. Consulta de información del sistema
2. Generación de reportes administrativos
3. Verificación de datos para auditoría
4. Análisis de información operativa

## Usuarios del Sistema
- **Administrativos**: Personal que gestiona contratos
- **Capturistas**: Operadores que registran información
- **Supervisores**: Personal que revisa y autoriza contratos

## Relaciones con Otros Módulos
- Se relaciona con otros módulos del sistema según su funcionalidad
- Comparte información a través de la base de datos común
- Puede ser invocado desde el menú principal o desde otros módulos


---
**Nota**: Este documento fue generado mediante análisis automatizado del código fuente. La información presentada se enfoca en aspectos administrativos y de negocio del módulo.
