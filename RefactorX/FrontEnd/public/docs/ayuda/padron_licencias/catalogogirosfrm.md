# Catálogo de Giros

## Descripción General

### ¿Qué hace este módulo?
Este módulo administra el catálogo maestro de giros económicos del sistema SCIAN (Sistema de Clasificación Industrial de América del Norte). Permite visualizar, agregar, modificar y gestionar los códigos de clasificación industrial utilizados para categorizar las actividades económicas de las licencias.

### ¿Para qué sirve en el proceso administrativo?
Sirve para:
- Mantener actualizado el catálogo oficial de giros SCIAN
- Clasificar correctamente las actividades económicas
- Proporcionar la base para la asignación de licencias
- Controlar qué giros están disponibles para nuevas solicitudes
- Gestionar la vigencia de giros según cambios normativos

### ¿Quiénes lo utilizan?
- Administradores del sistema de licencias
- Personal autorizado para mantener catálogos
- Supervisores del área administrativa
- Personal técnico responsable de actualizaciones normativas

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?
1. El usuario abre el módulo de catálogo de giros
2. El sistema carga todos los giros registrados en el catálogo
3. Se muestran en un grid con toda la información
4. El usuario puede:
   - **Navegar**: Ver todos los giros existentes
   - **Buscar**: Filtrar giros por código o descripción
   - **Agregar**: Registrar nuevos giros SCIAN
   - **Modificar**: Actualizar información de giros existentes
   - **Cancelar**: Marcar giros como no vigentes

### ¿Qué información requiere el usuario?
- **Código SCIAN**: Identificador único del giro
- **Descripción**: Nombre completo de la actividad económica
- **Nivel**: Jerarquía del código (sector, subsector, rama, etc.)
- **Vigencia**: Si el giro está activo o cancelado

### ¿Qué validaciones se realizan?
- El código SCIAN debe ser único
- La descripción no puede estar vacía
- Se valida la estructura jerárquica del código
- No se pueden eliminar giros en uso por licencias vigentes

### ¿Qué documentos genera?
No genera documentos impresos, pero el catálogo es base para:
- Listados de giros vigentes
- Solicitudes de licencias
- Reportes estadísticos
- Constancias oficiales

## Tablas de Base de Datos

### Tabla Principal
**c_giros**: Catálogo de giros y códigos SCIAN
- Contiene todos los códigos de clasificación industrial
- Estructura jerárquica de actividades económicas

### Tablas Relacionadas
#### Tablas que consulta:
- **c_giros**: Para mostrar el catálogo completo

#### Tablas que modifica:
- **c_giros**: INSERT, UPDATE de registros

## Stored Procedures
No utiliza stored procedures específicos.

## Impacto y Repercusiones

### ¿Qué registros afecta?
- Catálogo de giros SCIAN
- Indirectamente: licencias que usan estos giros

### ¿Qué cambios de estado provoca?
- Creación de nuevos giros disponibles
- Cancelación de giros obsoletos
- Actualización de descripciones

## Flujo de Trabajo
1. Consulta de catálogo
2. Búsqueda/filtrado
3. Modificación o alta de giros
4. Validación de cambios
5. Actualización de base de datos

## Notas Importantes

### Consideraciones especiales
- Catálogo basado en clasificación oficial INEGI
- Actualizar según versiones vigentes del SCIAN
- No eliminar, solo marcar como no vigente
- Mantener trazabilidad de cambios

### Restricciones
- Códigos únicos
- No eliminar giros en uso
- Respetar estructura jerárquica

### Permisos necesarios
- Solo personal autorizado
- Permisos administrativos
- Validación de cambios normativos
