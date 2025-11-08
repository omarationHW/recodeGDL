# Búsqueda SCIAN

## Descripción General

### ¿Qué hace este módulo?
Este módulo proporciona una interfaz de búsqueda y selección de códigos SCIAN (Sistema de Clasificación Industrial de América del Norte). Permite buscar giros económicos mediante código o descripción, filtrar los resultados y seleccionar el giro adecuado para asignarlo a licencias o trámites.

### ¿Para qué sirve en el proceso administrativo?
Sirve como herramienta auxiliar para:
- Buscar y seleccionar el giro económico correcto según la clasificación SCIAN
- Facilitar la identificación del código SCIAN cuando se conoce la descripción de la actividad
- Buscar por código SCIAN cuando se conoce el número específico
- Garantizar que las licencias se clasifiquen correctamente según estándares nacionales
- Evitar errores en la clasificación de actividades económicas

### ¿Quiénes lo utilizan?
- Personal de ventanilla al registrar nuevas solicitudes
- Personal del área de Licencias al capturar trámites
- Supervisores que revisan y validan clasificaciones
- Cualquier usuario que necesite seleccionar un giro SCIAN
- El módulo es invocado automáticamente por otros formularios

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?
1. El módulo se abre como ventana modal desde otro formulario
2. El sistema carga el catálogo completo de códigos SCIAN vigentes
3. El usuario puede buscar de dos formas:
   - **Por código**: Escribe el número de código SCIAN
   - **Por descripción**: Escribe palabras clave de la actividad
4. El sistema filtra automáticamente los resultados mientras se escribe
5. Se muestran los giros que coinciden con el criterio de búsqueda
6. El usuario puede:
   - Hacer doble clic en un registro para seleccionarlo
   - O seleccionar un registro y presionar "Aceptar"
7. Al seleccionar:
   - Se cierra automáticamente el formulario
   - Se retorna el código SCIAN y su descripción
   - El formulario invocador recibe estos datos

### ¿Qué información requiere el usuario?
- **Criterio de búsqueda** (opcional): Código SCIAN o palabras de la descripción
- El usuario puede navegar todo el catálogo sin filtrar si no escribe nada

### ¿Qué validaciones se realizan?
- Solo se muestran giros SCIAN vigentes (vigente='V')
- Solo se muestran giros con id >= 5000 (códigos SCIAN válidos)
- La búsqueda filtra en tiempo real mientras el usuario escribe
- Se valida que se haya seleccionado un registro antes de confirmar

### ¿Qué documentos genera?
Este módulo no genera documentos. Es una herramienta de búsqueda y selección.

## Tablas de Base de Datos

### Tabla Principal
**c_giros**: Catálogo de giros económicos y códigos SCIAN
- Contiene la clasificación completa de actividades económicas
- Incluye código SCIAN y descripción detallada

### Tablas Relacionadas

#### Tablas que consulta:
- **c_giros**:
  - Filtra registros con id_giro >= 5000 (códigos SCIAN)
  - Filtra por vigente = 'V' (solo vigentes)
  - Permite búsqueda por código o descripción

#### Tablas que modifica:
- Ninguna. Este es un módulo de solo lectura/consulta.

## Stored Procedures
Este módulo no consume stored procedures.

## Impacto y Repercusiones

### ¿Qué registros afecta?
No afecta directamente ningún registro. Solo facilita la búsqueda y selección de giros SCIAN.

### ¿Qué cambios de estado provoca?
Ninguno. Es un módulo auxiliar de consulta.

### ¿Qué documentos/reportes genera?
No genera documentos.

### ¿Qué validaciones de negocio aplica?
- Solo giros vigentes
- Solo códigos SCIAN válidos (id >= 5000)
- Permite cancelar sin seleccionar

## Flujo de Trabajo

### Descripción del flujo completo del proceso

```
1. Inicio (invocado por otro módulo)
2. Sistema carga catálogo de giros SCIAN
   - Filtra id_giro >= 5000
   - Filtra vigente = 'V'
3. Muestra formulario modal con grid
4. Usuario puede:
   a. Buscar por código SCIAN
   b. Buscar por descripción
   c. Navegar sin filtrar
5. ¿Usuario escribió en búsqueda?
   - Sí: Filtrar resultados en tiempo real
   - No: Mostrar todos los giros SCIAN
6. Sistema actualiza grid dinámicamente
7. Usuario navega por los resultados
8. Usuario selecciona un giro:
   - Opción A: Doble clic en el registro
   - Opción B: Seleccionar y presionar "Aceptar"
9. ¿Usuario confirmó selección?
   - Sí: Continuar
   - No (canceló): Retornar vacío y cerrar
10. Sistema guarda id_giro y descripción seleccionados
11. Cerrar formulario modal
12. Retornar valores al formulario invocador
13. Fin
```

## Notas Importantes

### Consideraciones especiales
- **Catálogo SCIAN**: Utiliza la clasificación oficial del INEGI
- **Formulario modal**: Bloquea otras ventanas hasta cerrarse
- **Auto-destrucción**: Se libera de memoria al cerrar (action:=cafree)
- **Búsqueda flexible**: Permite buscar por código o texto
- **Filtrado en tiempo real**: Actualiza resultados al escribir
- **Integración**: Diseñado para múltiples módulos

### Restricciones
- Solo muestra códigos SCIAN válidos (id >= 5000)
- Solo muestra giros vigentes
- No permite modificar el catálogo SCIAN
- No permite agregar nuevos códigos
- La selección está limitada a registros existentes

### Permisos necesarios
- Hereda permisos del formulario que lo invoca
- No tiene validaciones propias de permisos
- Accesible para cualquier usuario con acceso al módulo invocador

### Mejores prácticas de uso
1. **Conocer el SCIAN**: Familiarizarse con la estructura de códigos
2. **Búsqueda efectiva**: Usar palabras clave relevantes
3. **Verificación**: Leer la descripción completa antes de seleccionar
4. **Código correcto**: Verificar que el código corresponda a la actividad real
5. **Consulta de catálogo**: Tener a mano el catálogo SCIAN oficial si hay dudas
6. **Precisión**: Seleccionar el código más específico posible

### Clasificación SCIAN
El Sistema de Clasificación Industrial de América del Norte (SCIAN) es el sistema de clasificación estándar para:
- Actividades económicas en México, Estados Unidos y Canadá
- Estadísticas económicas comparables
- Regulación y normatividad comercial
- Tributación y obligaciones fiscales

Los códigos SCIAN tienen estructura jerárquica:
- 2 dígitos: Sector
- 3 dígitos: Subsector
- 4 dígitos: Rama
- 5 dígitos: Subrama
- 6 dígitos: Clase de actividad

### Integración con otros módulos
Este formulario es invocado por:
- **Registro de solicitudes**: Al seleccionar giro para nueva licencia
- **Modificación de licencias**: Al cambiar el giro de una licencia existente
- **Modificación de trámites**: Al actualizar giro en trámite
- **Catálogo de actividades**: Al asociar actividades con giros

### Formato de retorno de datos
Cuando se selecciona un giro, retorna:
- `id_giro`: Identificador numérico del giro en la base de datos
- `descripcion`: Texto descriptivo del giro SCIAN
- Estos valores son procesados por el formulario invocador

### Diferencia entre Giros y Actividades
- **Giros SCIAN**: Clasificación general de la actividad económica
- **Actividades específicas**: Detalles más precisos dentro de cada giro
- Primero se selecciona el giro SCIAN (este módulo)
- Luego se selecciona la actividad específica (BusquedaActividadFrm)
- Ambos son necesarios para clasificar correctamente una licencia

### Actualización del catálogo
- El catálogo SCIAN se actualiza periódicamente por el INEGI
- Las actualizaciones deben reflejarse en la base de datos
- Los códigos obsoletos se marcan como no vigentes
- No se eliminan para mantener el histórico de licencias antiguas
