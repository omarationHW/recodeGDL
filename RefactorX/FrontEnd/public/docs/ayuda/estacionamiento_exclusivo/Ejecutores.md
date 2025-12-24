# Ejecutores - Búsqueda y Selección de Ejecutores Fiscales

## Propósito Administrativo
Herramienta de búsqueda rápida para localizar y seleccionar ejecutores fiscales del catálogo. Funciona como ventana auxiliar de consulta para otros módulos que necesitan asignar o identificar ejecutores.

## Funcionalidad Principal
Catálogo de búsqueda que permite localizar ejecutores fiscales por clave o nombre, facilitando su selección para asignación de folios, reportes o consultas. Funciona como módulo de apoyo invocado por otros procesos.

## Proceso de Negocio

### ¿Qué hace?
- Muestra catálogo completo de ejecutores fiscales
- Permite buscar ejecutor por clave numérica
- Permite buscar ejecutor por nombre (búsqueda parcial)
- Facilita selección de ejecutor mediante doble clic o enter
- Regresa el ejecutor seleccionado al módulo que lo invocó

### ¿Para qué sirve?
- Facilitar selección de ejecutores en otros módulos
- Localizar rápidamente un ejecutor sin conocer su clave completa
- Buscar ejecutores por nombre cuando no se recuerda la clave
- Proporcionar catálogo actualizado de ejecutores activos
- Agilizar captura en módulos que requieren asignación de ejecutor

### ¿Cómo lo hace?
1. Abre ventana mostrando lista completa de ejecutores
2. Usuario puede capturar clave de ejecutor para búsqueda directa
3. Usuario puede capturar nombre (o parte) para búsqueda por nombre
4. Sistema localiza ejecutor coincidente en tiempo real
5. Usuario selecciona ejecutor de la lista
6. Sistema regresa ejecutor seleccionado al módulo origen

### ¿Qué necesita para funcionar?
- Catálogo de ejecutores (ta_15_ejecutores)
- Ser invocado desde otro módulo con necesidad de seleccionar ejecutor
- Variable para regresar el ejecutor seleccionado

## Datos y Tablas

### Tabla Principal
**ta_15_ejecutores** (QryBancos): Catálogo de ejecutores fiscales

### Tablas Relacionadas
Ninguna

### Stored Procedures (SP)
No utiliza stored procedures

### Tablas que Afecta
**Solo consulta** (no modifica):
- ta_15_ejecutores

## Impacto y Repercusiones

### Repercusiones Operativas
- Acelera procesos de asignación de folios
- Facilita captura de información en diversos módulos
- Mejora experiencia de usuario en búsqueda de ejecutores

### Repercusiones Financieras
- Indirecto: facilita procesos que impactan recuperación de cartera

### Repercusiones Administrativas
- Estandariza la selección de ejecutores en el sistema
- Reduce errores de captura de claves
- Agiliza operación del sistema

## Validaciones y Controles
- Búsqueda en tiempo real (tecla por tecla)
- Búsqueda parcial (no requiere nombre completo)
- Validación de formato numérico en búsqueda por clave

## Casos de Uso

**Asignación de folios:**
- Usuario está asignando folios de apremio
- Invoca catálogo de ejecutores
- Busca por nombre "García"
- Selecciona ejecutor correcto
- Sistema asigna folios a ese ejecutor

**Consulta rápida:**
- Usuario necesita verificar clave de ejecutor
- Abre catálogo y busca por nombre
- Identifica clave correcta
- Cierra catálogo

## Usuarios del Sistema
- Todos los usuarios que requieran seleccionar ejecutores
- Invocado automáticamente por otros módulos

## Relaciones con Otros Módulos
- **Requerimientos.pas**: Selección de ejecutor para asignar requerimientos
- **Prenomina.pas**: Selección para generar prenómina
- **Reasignacion.pas**: Selección para reasignar folios
- **Listados.pas**: Selección para filtrar reportes
- Cualquier módulo que requiera seleccionar un ejecutor
