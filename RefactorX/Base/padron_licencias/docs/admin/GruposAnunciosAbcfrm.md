# ABCde Grupos de Anuncios

## Descripción General

### ¿Qué hace este módulo?
Permite **crear, editar y gestionar grupos de anuncios publicitarios**. Los grupos son agrupaciones administrativas que permiten organizar anuncios por criterios definidos (zona, tipo, campaña, etc.) para facilitar operaciones masivas y reportes específicos.

### ¿Para qué sirve en el proceso administrativo?
- Crear agrupaciones de anuncios para operaciones masivas
- Organizar anuncios por campañas o características comunes
- Facilitar generación de reportes de grupos específicos
- Agrupar anuncios para programas de regularización
- Clasificar anuncios por zonas geográficas o tipos

### ¿Quiénes lo utilizan?
- **Supervisores**: Para crear y gestionar agrupaciones
- **Personal administrativo**: Para organizar padrones
- **Coordinadores de programas**: Para campañas específicas

## Proceso Administrativo

**Operaciones ABCde (Alta, Baja, Cambio, Consulta):**

**Alta (Agregar Grupo):**
1. Click en "Agregar"
2. Sistema pone tabla en modo inserción
3. Captura nombre del grupo (ej: "Anuncios Zona Centro 2025")
4. Click en "Aceptar"
5. Sistema graba el nuevo grupo

**Modificación (Editar Grupo):**
1. Seleccionar grupo del grid
2. Click en "Editar"
3. Modificar descripción
4. Click en "Aceptar"
5. Sistema actualiza el registro

**Consulta:**
1. Campo de búsqueda: Capturar texto
2. Sistema filtra grupos que contengan ese texto
3. Lista se actualiza en tiempo real

**Navegación:**
- DBNavigator permite moverse entre registros
- Grid muestra ID y descripción de cada grupo

## Tablas de Base de Datos

### Tabla Principal
**anuncios_grupos** - Catálogo de grupos de anuncios

**Campos:**
- **id**: Identificador único del grupo (autoincremental)
- **descripcion**: Nombre del grupo (texto)

### Tabla Relacionada
**anuncios_detgrupo** - Detalle de qué anuncios pertenecen a cada grupo (no se maneja en este módulo)

### Tablas que Modifica

**1. anuncios_grupos** (INSERT, UPDATE)
- **INSERT**: Al agregar nuevo grupo
- **UPDATE**: Al editar descripción de grupo existente

**Nota**: Este módulo NO modifica anuncios_detgrupo. La asignación de anuncios a grupos se hace en otros módulos (ConsultaTramite, ReporteAnunExcel).

## Stored Procedures
No utiliza stored procedures.

## Impacto y Repercusiones

### ¿Qué registros afecta?
- Catálogo de grupos de anuncios
- NO afecta anuncios individuales
- NO asigna anuncios a grupos (eso se hace en otro módulo)

### ¿Qué cambios de estado provoca?
- Creación de nuevos grupos disponibles para uso
- Modificación de nombres de grupos existentes
- NO elimina grupos (no hay opción de baja)

### ¿Qué documentos genera?
**NINGUNO** - Es un módulo de configuración/catálogo

### ¿Qué validaciones aplica?
1. Valida que se capture descripción (no permite vacío)
2. No permite duplicar exactamente el mismo nombre (restricción de BD)

## Flujo de Trabajo

```
AGREGAR GRUPO:
1. Click "Agregar"
2. Deshabilita: Agregar, Editar, Imprimir, Navigator, Grid
3. Habilita: Aceptar, Cancelar
4. Modo INSERT en tabla
5. Usuario captura descripción
6. Click "Aceptar"
7. POST (graba)
8. Cierra y reabre tabla (refresca)
9. Restaura botones
10. FIN

EDITAR GRUPO:
1. Selecciona grupo en grid
2. Click "Editar"
3. Deshabilita: Agregar, Editar, Imprimir, Navigator, Grid
4. Habilita: Aceptar, Cancelar
5. Modo EDIT en tabla
6. Usuario modifica descripción
7. Click "Aceptar"
8. POST (graba cambios)
9. Restaura botones
10. FIN

BUSCAR:
1. Usuario escribe en Edit1
2. Evento OnChange se activa automáticamente
3. Sistema ejecuta query con filtro:
   WHERE descripcion LIKE "%[texto]%"
4. Grid se actualiza con resultados filtrados
5. Búsqueda en tiempo real
```

## Notas Importantes

### Consideraciones Especiales

**1. Solo Catálogo**
- Este módulo SOLO maneja el catálogo de grupos
- NO asigna anuncios a grupos
- La asignación se hace en:
  - Módulo ConsultaTramite (botón "Agregar a grupo")
  - Al generar reportes en ReporteAnunExcel

**2. Grupos como Filtro**
- Los grupos se usan en módulos de:
  - Consulta de trámites
  - Reportes de anuncios
  - Bajas masivas (potencialmente)
- Permiten operaciones sobre conjuntos específicos

**3. No Hay Baja de Grupos**
- No existe función para eliminar grupos
- Si un grupo ya no se usa, simplemente no se utiliza
- Se mantiene el histórico

**4. Búsqueda en Tiempo Real**
- Al escribir en el campo de búsqueda, la lista se filtra automáticamente
- Muy útil cuando hay muchos grupos
- No requiere presionar botón de búscar

### Restricciones
- No se pueden eliminar grupos
- No se pueden asignar anuncios aquí
- Solo permite gestionar nombres de grupos

### Permisos Necesarios
- Usuario con permiso de modificar catálogos
- Acceso de escritura a tabla anuncios_grupos

### Uso Recomendado
- Crear grupos antes de necesitarlos en reportes
- Usar nombres descriptivos y claros
- Incluir año o periodo si es relevante
- Ejemplos de grupos útiles:
  - "Anuncios Regularización 2025"
  - "Zona Centro Histórico"
  - "Pendientes Renovación"
  - "Campaña Verificación Enero"
