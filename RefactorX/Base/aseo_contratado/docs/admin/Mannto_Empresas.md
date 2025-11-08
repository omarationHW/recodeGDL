# Mannto_Empresas

## Propósito Administrativo
Módulo de mantenimiento de catálogo del sistema de aseo (recolección de basura/limpieza urbana).

## Funcionalidad Principal
Este módulo se clasifica como: **Mantenimiento**

### Descripción
Permite realizar operaciones de Alta, Baja y Modificación sobre el catálogo de **Empresas**. Este módulo es fundamental para mantener actualizada la información maestra del sistema.

## Proceso de Negocio

### ¿Qué hace?
1. Presenta una interfaz de consulta del catálogo de Empresas
2. Permite dar de alta nuevos registros en el catálogo
3. Facilita la modificación de registros existentes
4. Permite eliminar registros del catálogo (con validaciones correspondientes)
5. Exporta la información a Excel para análisis externo

### ¿Para qué sirve?
- Mantener actualizado el catálogo de Empresas
- Asegurar la integridad de los datos maestros del sistema
- Facilitar la administración de información base para operaciones del sistema
- Permitir auditoría y control de cambios en catálogos

### ¿Cómo lo hace?
1. Carga y muestra los registros existentes en una grilla de datos
2. Proporciona botones de acción para Altas, Bajas y Cambios
3. Abre formularios de mantenimiento para captura o modificación de datos
4. Valida la información antes de grabarla en la base de datos
5. Actualiza la vista después de cada operación

### ¿Qué necesita para funcionar?
- Permisos de usuario para acceso al módulo
- Conexión activa a la base de datos
- Validación de integridad referencial con otras tablas

## Datos y Tablas

### Tabla Principal
- **ta_16_empresas**: Tabla principal que maneja este módulo

### Tablas Relacionadas
- **ta_16_tipos_emp**: Tabla relacionada utilizada en el módulo

### Stored Procedures (SP)
- No se identificaron stored procedures explícitos

### Operaciones SQL
Este módulo realiza operaciones: Select

### Tablas que Afecta
Este módulo es principalmente de consulta, no modifica datos directamente

## Impacto y Repercusiones

### Repercusiones Operativas
- Mantiene la integridad de catálogos maestros
- Asegura consistencia de datos en el sistema
- Facilita operaciones que dependen de estos catálogos
- Permite adaptación a cambios organizacionales

### Repercusiones Financieras
- Impacto indirecto en procesos financieros
- Apoya en la trazabilidad de operaciones
- Facilita auditorías y control interno

### Repercusiones Administrativas
- Genera registros para auditoría
- Mantiene histórico de operaciones
- Facilita generación de reportes gerenciales
- Apoya en indicadores de gestión

## Validaciones y Controles
- Validación de datos requeridos antes de grabar
- Control de duplicados por llaves primarias
- Verificación de integridad referencial
- Confirmación antes de eliminar registros
- Validación de permisos de usuario

## Casos de Uso
1. **Alta de nuevo registro**: Usuario administrativo da de alta un nuevo elemento en el catálogo de Empresas
2. **Modificación de datos**: Actualización de información existente por cambios organizacionales
3. **Baja de registro**: Eliminación de elementos obsoletos o incorrectos del catálogo

## Usuarios del Sistema
- **Administrativos**: Personal administrativo del sistema
- **Capturistas**: Operadores del sistema
- **Consultores**: Usuarios con permisos de consulta

## Relaciones con Otros Módulos
- **Cons_Empresas**: Módulo de consulta del mismo catálogo
- **Rep_Empresas**: Módulo de reportes del mismo catálogo
- **Módulos operativos**: Todos los módulos que utilizan este catálogo como dato maestro


---
**Nota**: Este documento fue generado mediante análisis automatizado del código fuente. La información presentada se enfoca en aspectos administrativos y de negocio del módulo.
