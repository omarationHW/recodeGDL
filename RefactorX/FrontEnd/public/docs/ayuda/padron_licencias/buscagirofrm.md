# Búsqueda de Giros

## Descripción General

### ¿Qué hace este módulo?
Proporciona una interfaz de búsqueda rápida y selección de giros económicos desde cualquier otro módulo que lo requiera. Es un formulario auxiliar modal que facilita encontrar y seleccionar el giro adecuado.

### ¿Para qué sirve en el proceso administrativo?
Facilita:
- Búsqueda rápida de giros por código o descripción
- Selección precisa del giro correcto
- Evitar errores de captura manual
- Agilizar el proceso de registro de solicitudes

### ¿Quiénes lo utilizan?
- Personal de ventanilla
- Capturistas de licencias
- Cualquier usuario que necesite seleccionar un giro
- Invocado automáticamente por otros formularios

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?
1. Se abre como ventana modal desde otro formulario
2. Muestra catálogo de giros vigentes
3. Usuario puede buscar por código o texto
4. Filtra resultados en tiempo real
5. Usuario selecciona giro
6. Retorna información al formulario invocador

### ¿Qué información requiere el usuario?
- Criterio de búsqueda (opcional): código o texto

### ¿Qué validaciones se realizan?
- Solo giros vigentes
- Validación de selección

### ¿Qué documentos genera?
Ninguno. Es formulario auxiliar de búsqueda.

## Tablas de Base de Datos

### Tabla Principal
**c_giros**: Consulta catálogo de giros

### Tablas Relacionadas
#### Tablas que consulta:
- **c_giros**: Solo lectura

#### Tablas que modifica:
- Ninguna

## Stored Procedures
No utiliza stored procedures.

## Impacto y Repercusiones
No afecta registros. Solo facilita búsqueda y selección.

## Flujo de Trabajo
1. Apertura modal
2. Carga catálogo
3. Búsqueda/filtrado
4. Selección
5. Retorno de valores
6. Cierre

## Notas Importantes

### Consideraciones especiales
- Formulario modal
- Auto-destrucción al cerrar
- Búsqueda en tiempo real
- Doble clic o botón Aceptar

### Restricciones
- Solo giros vigentes
- No modificación de catálogo
- Solo selección

### Permisos necesarios
- Hereda permisos del formulario invocador
