# Selección de Dependencias para Inspección

## Descripción General

### ¿Qué hace este módulo?
Este módulo permite seleccionar las dependencias municipales que deben realizar inspección y revisión de un trámite de licencia. Funciona como una ventana de diálogo donde el usuario arma el listado de dependencias que participarán en el proceso de dictaminación.

### ¿Para qué sirve en el proceso administrativo?
- Define qué dependencias deben revisar un trámite específico
- Permite agregar dependencias al proceso de inspección
- Facilita la eliminación de dependencias del proceso
- Muestra las dependencias actualmente seleccionadas
- Almacena temporalmente la configuración de inspecciones
- Facilita la personalización del flujo de revisión según tipo de trámite

### ¿Quiénes lo utilizan?
- Personal de ventanilla que captura trámites nuevos
- Personal de Padrón y Licencias que registra solicitudes
- Supervisores que determinan qué áreas deben intervenir
- Personal autorizado para configurar flujos de revisión

## Proceso Administrativo

### ¿Cómo funciona el proceso paso a paso?

#### CARGA INICIAL

1. **Apertura del módulo**
   - Sistema abre tabla de dependencias (Table1 - c_dependencias)
   - Carga inspecciones previamente seleccionadas desde memoria

2. **Visualización de inspecciones actuales**
   - Sistema construye grid (StringGrid - sg)
   - Primera fila: Encabezado "INSPECCIONES ACTUALES"
   - Recorre arreglo de memoria inspecciones[1..20]
   - Por cada inspección con nombre:
     - Agrega fila al grid
     - Muestra nombre de la dependencia

3. **Configuración del grid**
   - Si hay inspecciones (rowcount > 1):
     - Fija primera fila como encabezado
     - Permite navegación por filas

#### AGREGAR DEPENDENCIA

1. **Selección de dependencia**
   - Usuario selecciona dependencia del lookup (RxLookupEdit1)
   - Lookup muestra catálogo completo de dependencias

2. **Acción de agregar**
   - Usuario presiona botón "Agregar" (BitBtn4)

3. **Validación de duplicados**
   - Sistema recorre arreglo inspecciones[1..20]
   - Verifica si id_dependencia ya existe
   - Si existe: variable existe = true

4. **Agregar al grid (si no existe)**
   - Si NO existe:
     - Incrementa rowcount del grid
     - Agrega nombre de dependencia en nueva fila

5. **Agregar al arreglo de memoria (si no existe)**
   - Si NO existe:
     - Busca primer espacio vacío en inspecciones[1..20]
     - Guarda:
       - cvedependencia = id_dependencia
       - nombre = descripción de la dependencia
     - Incrementa contador: cuantasInspecciones++

6. **Configuración de encabezado**
   - Si rowcount > 1:
     - Fija primera fila como encabezado

#### ELIMINAR DEPENDENCIA

1. **Selección de fila**
   - Usuario selecciona una fila del grid
   - Fila contiene nombre de dependencia a eliminar

2. **Acción de eliminar**
   - Usuario presiona botón "Quitar" (BitBtn3)

3. **Eliminación del arreglo**
   - Sistema recorre inspecciones[1..20]
   - Busca coincidencia: inspecciones[i].nombre = celda seleccionada
   - Si encuentra:
     - Limpia: cvedependencia = 0
     - Limpia: nombre = ''
     - Decrementa: cuantasInspecciones--

4. **Recorrimiento del grid**
   - Si fila eliminada NO es la última:
     - Recorre datos hacia arriba:
       - sg.cells[0,i] = sg.cells[0,i+1]
     - Elimina último elemento

5. **Actualización del grid**
   - Decrementa rowcount del grid
   - Remueve visualmente la fila

#### CIERRE DEL MÓDULO

1. **Guardar configuración**
   - Usuario presiona botón "Cerrar" o cierra ventana
   - Configuración queda almacenada en:
     - Arreglo inspecciones[1..20]
     - Variable cuantasInspecciones

2. **Uso posterior**
   - Módulo que invocó (regsolicfrm) usa esta configuración
   - Crea registros de revisión para cada dependencia seleccionada

### ¿Qué información requiere el usuario?

**Para agregar dependencia:**
- **Selección de dependencia** (del catálogo): Dependencia que debe revisar el trámite

**Para eliminar:**
- **Selección de fila**: Clic en la fila de la dependencia a quitar

### ¿Qué validaciones se realizan?

1. **Prevención de duplicados**
   - Al agregar, verifica que la dependencia no esté ya en la lista
   - No permite agregar la misma dependencia dos veces

2. **Límite de inspecciones**
   - Máximo 20 dependencias (tamaño del arreglo)
   - Si se llena el arreglo, no permite agregar más

3. **Integridad del arreglo**
   - Mantiene sincronizado el grid visual con el arreglo en memoria
   - Actualiza contador cuantasInspecciones correctamente

### ¿Qué documentos genera?
Ninguno. Este es un módulo de configuración que almacena selecciones en memoria.

## Tablas de Base de Datos

### Tablas que Consulta

1. **Table1 (c_dependencias)**
   - Catálogo de dependencias municipales
   - Campos consultados:
     - id_dependencia: Código único de la dependencia
     - descripcion: Nombre de la dependencia

### Tablas que Modifica
**Ninguna**. Este módulo trabaja solo con estructuras de memoria (arreglos y variables).

## Stored Procedures
Este módulo no utiliza stored procedures.

## Impacto y Repercusiones

### ¿Qué registros afecta?
Ninguno directamente. Este módulo solo configura qué dependencias participarán en el proceso.

### ¿Qué cambios de estado provoca?

**En memoria (temporal):**
1. **Arreglo inspecciones[1..20]**
   - Estructura en memoria que almacena las dependencias seleccionadas
   - Cada elemento contiene:
     - cvedependencia: ID de la dependencia
     - nombre: Nombre de la dependencia

2. **Variable cuantasInspecciones**
   - Contador de cuántas dependencias están seleccionadas
   - Se incrementa al agregar, se decrementa al eliminar

**En base de datos (posterior):**
- El módulo padre (regsolicfrm) usará esta configuración para:
  - Crear registros en tabla "revisiones"
  - Una revisión por cada dependencia seleccionada
  - Asociadas al trámite que se está registrando

### ¿Qué documentos/reportes genera?
Ninguno.

### ¿Qué validaciones de negocio aplica?

1. **Control de duplicados**
   - Asegura que cada dependencia aparezca solo una vez
   - Previene revisiones duplicadas

2. **Límite de capacidad**
   - Máximo 20 dependencias por trámite
   - Control del tamaño del arreglo

3. **Consistencia de datos**
   - Sincroniza grid visual con arreglo en memoria
   - Mantiene contador actualizado

## Flujo de Trabajo

### Flujo de carga inicial

```
INICIO
  ↓
Abrir tabla c_dependencias
  ↓
Inicializar grid StringGrid (sg)
  ↓
Primera celda = "INSPECCIONES ACTUALES"
  ↓
Recorrer arreglo inspecciones[1..20]
  ↓
Para cada i de 1 a 20:
  ¿inspecciones[i].nombre <> ''? → SÍ → Agregar fila al grid
  ↓ NO                                  Mostrar nombre
Siguiente i
  ↓
¿rowcount > 1? → SÍ → fixedrows = 1 (encabezado)
  ↓ NO
Mostrar grid
  ↓
FIN
```

### Flujo de agregar dependencia

```
INICIO
  ↓
Usuario selecciona dependencia en lookup
  ↓
Clic en botón "Agregar"
  ↓
Inicializar existe = false
  ↓
Recorrer inspecciones[1..20]
  ↓
Para cada i:
  ¿cvedependencia = id_dependencia seleccionado? → SÍ → existe = true
  ↓ NO
Siguiente i
  ↓
¿existe = false? → SÍ → Agregar al grid:
  ↓ NO                  - rowcount++
Salir (ya existe)      - cells[última fila] = nombre
  ↓
Buscar primer espacio vacío en inspecciones[1..20]
  ↓
Para cada i:
  ¿cvedependencia = 0? → SÍ → Guardar aquí:
  ↓ NO                         - cvedependencia = id_dependencia
Siguiente i                    - nombre = descripción
                               - cuantasInspecciones++
                               - BREAK
  ↓
¿rowcount > 1? → SÍ → fixedrows = 1
  ↓ NO
FIN
```

### Flujo de eliminar dependencia

```
INICIO
  ↓
Usuario selecciona fila del grid
  ↓
Clic en botón "Quitar"
  ↓
Obtener nombre = sg.cells[0, fila seleccionada]
  ↓
Recorrer inspecciones[1..20]
  ↓
Para cada i:
  ¿nombre = inspecciones[i].nombre? → SÍ → Eliminar:
  ↓ NO                                     - cvedependencia = 0
Siguiente i                                - nombre = ''
  ↓                                        - cuantasInspecciones--
Continuar                                  - BREAK
  ↓
¿Fila < rowcount-1? → SÍ → Recorrer filas hacia arriba:
  ↓ NO                     Para j = fila hasta rowcount-1:
Saltar recorrido             cells[0,j] = cells[0,j+1]
  ↓
rowcount-- (eliminar última fila)
  ↓
FIN
```

## Notas Importantes

### Consideraciones especiales

1. **Arreglo de memoria**
   - inspecciones[1..20]: Almacena temporalmente las dependencias
   - Definido en módulo padre (regsolicfrm)
   - Persiste mientras el módulo padre esté abierto

2. **Límite de 20 dependencias**
   - Tamaño fijo del arreglo
   - Suficiente para la mayoría de trámites
   - Rara vez se requieren más de 20 dependencias

3. **Sincronización grid-arreglo**
   - Grid es solo visualización
   - Datos reales están en arreglo inspecciones[]
   - Ambos deben mantenerse sincronizados

4. **Uso en registro de trámite**
   - Este módulo es auxiliar
   - El módulo principal (regsolicfrm) usa la configuración
   - Crea las revisiones en base de datos

### Restricciones

1. **Máximo 20 dependencias**
   - Limitación del tamaño del arreglo
   - No es configurable

2. **No persiste automáticamente**
   - Configuración solo en memoria
   - Se guarda en BD cuando el trámite se registra
   - Si se cancela el trámite, se pierde la configuración

3. **Dependencias del catálogo**
   - Solo se pueden seleccionar dependencias existentes en c_dependencias
   - No se pueden agregar dependencias "al vuelo"

### Permisos necesarios

- Acceso al módulo de registro de trámites
- Permisos de lectura a tabla:
  - c_dependencias (catálogo de dependencias)

### Recomendaciones de uso

1. **Al seleccionar dependencias**
   - Considerar el tipo de trámite
   - Agregar solo dependencias necesarias
   - Dependencias comunes:
     - Desarrollo Urbano (uso de suelo)
     - Protección Civil (seguridad)
     - Medio Ambiente (si aplica)
     - Salud (giros alimenticios)
     - Tránsito (cajones de estacionamiento)
     - Bomberos (seguridad contra incendios)

2. **Validación previa**
   - Revisar qué dependencias ya están en la lista
   - No duplicar dependencias
   - Quitar dependencias que no apliquen

3. **Flujo típico**
   - Agregar todas las dependencias necesarias
   - Revisar la lista completa
   - Eliminar las que no correspondan
   - Cerrar cuando la lista esté correcta

4. **Por tipo de giro**
   - **Alimentos**: Salud, Protección Civil, Medio Ambiente
   - **Comercio general**: Desarrollo Urbano, Protección Civil
   - **Servicios**: Según actividad específica
   - **Entretenimiento**: Protección Civil, Tránsito, Seguridad Pública

5. **Consideraciones administrativas**
   - Más dependencias = más tiempo de revisión
   - Solo agregar las estrictamente necesarias
   - Considerar precedentes de trámites similares
   - Coordinarse con áreas técnicas

### Variables y estructuras importantes

**inspecciones[1..20]** (arreglo)
- Tipo: Estructura con campos:
  - cvedependencia: Integer
  - nombre: String
- Alcance: Global en módulo padre
- Uso: Almacena dependencias seleccionadas

**cuantasInspecciones** (variable)
- Tipo: Integer
- Alcance: Global en módulo padre
- Uso: Contador de dependencias seleccionadas

**sg** (StringGrid)
- Componente visual
- Muestra lista de dependencias
- Permite selección para eliminar
