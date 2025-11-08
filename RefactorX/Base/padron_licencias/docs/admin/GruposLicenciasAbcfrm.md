# ABCde Grupos de Licencias

## Descripción General

### ¿Qué hace este módulo?
Permite **crear, editar y gestionar grupos de licencias**. Los grupos son agrupaciones administrativas que permiten organizar licencias por criterios definidos para facilitar operaciones masivas, reportes específicos y programas especiales.

### ¿Para qué sirve en el proceso administrativo?
- Crear agrupaciones de licencias para operaciones masivas
- Organizar licencias por programas o características comunes
- Facilitar generación de reportes de grupos específicos
- Agrupar licencias para programas de regularización
- Clasificar licencias por zonas geográficas, giros o campañas
- Base para bajas masivas selectivas

### ¿Quiénes lo utilizan?
- **Supervisores**: Para crear y gestionar agrupaciones
- **Personal administrativo**: Para organizar padrones
- **Coordinadores de programas**: Para campañas específicas
- **Dirección**: Para programas estratégicos

## Proceso Administrativo

**Operaciones ABCde (Alta, Baja, Cambio, Consulta):**

**Alta (Agregar Grupo):**
1. Click en "Agregar"
2. Sistema pone tabla en modo inserción
3. Captura nombre del grupo (ej: "Licencias Regularización 2025")
4. Click en "Aceptar"
5. Sistema graba el nuevo grupo

**Modificación (Editar Grupo):**
1. Seleccionar grupo del grid
2. Click en "Editar"
3. Modificar descripción
4. Click en "Aceptar"
5. Sistema actualiza el registro

**Consulta/Búsqueda:**
1. Campo de búsqueda: Capturar texto
2. Sistema filtra grupos que contengan ese texto
3. Lista se actualiza en tiempo real (OnChange)

**Navegación:**
- DBNavigator permite moverse entre registros
- Grid muestra ID y descripción de cada grupo

## Tablas de Base de Datos

### Tabla Principal
**lic_grupos** - Catálogo de grupos de licencias

**Campos:**
- **id**: Identificador único del grupo (autoincremental)
- **descripcion**: Nombre descriptivo del grupo (texto)

### Tabla Relacionada
**lic_detgrupo** - Detalle de qué licencias pertenecen a cada grupo (no se maneja en este módulo)

**Campos (referencia):**
- lic_grupos_id: FK a lic_grupos.id
- licencia: Número de licencia
- Otros campos según necesidad

### Tablas que Modifica

**1. lic_grupos** (INSERT, UPDATE)
- **INSERT**: Al agregar nuevo grupo
- **UPDATE**: Al editar descripción de grupo existente

**Nota**: Este módulo NO modifica lic_detgrupo. La asignación de licencias a grupos se hace en otros módulos (principalmente ConsultaTramite y LicenciasVigentes).

## Stored Procedures
No utiliza stored procedures.

## Impacto y Repercusiones

### ¿Qué registros afecta?
- Catálogo de grupos de licencias
- NO afecta licencias individuales
- NO asigna licencias a grupos (eso se hace en otro módulo)

### ¿Qué cambios de estado provoca?
- Creación de nuevos grupos disponibles para uso
- Modificación de nombres de grupos existentes
- NO elimina grupos (no hay opción de baja física)

### ¿Qué documentos genera?
**NINGUNO** - Es un módulo de configuración/catálogo

### ¿Qué validaciones aplica?
1. Valida que se capture descripción (no permite vacío)
2. No permite duplicar exactamente el mismo nombre (restricción de BD)
3. Campo descripción es obligatorio

## Flujo de Trabajo

```
AGREGAR GRUPO:
1. Click "Agregar"
2. Sistema:
   - Cierra tabla actual
   - Reconstruye SQL: SELECT * FROM lic_grupos ORDER BY descripcion
   - Abre tabla
   - Modo INSERT
3. Deshabilita: Agregar, Editar, Imprimir, Navigator, Grid
4. Habilita: Aceptar, Cancelar
5. Usuario captura descripción
6. Click "Aceptar"
7. POST (graba)
8. Cierra y reabre tabla (refresca con nuevo registro)
9. Restaura estado de botones
10. FIN

EDITAR GRUPO:
1. Usuario selecciona grupo en grid
2. Click "Editar"
3. Modo EDIT en tabla
4. Deshabilita: Agregar, Editar, Imprimir, Navigator, Grid
5. Habilita: Aceptar, Cancelar
6. Usuario modifica descripción
7. Click "Aceptar"
8. POST (graba cambios)
9. Restaura estado de botones
10. FIN

BUSCAR (Filtro en Tiempo Real):
1. Usuario escribe en Edit1
2. Evento OnChange se dispara automáticamente
3. Sistema:
   - Cierra tabla
   - Reconstruye SQL:
     SELECT * FROM lic_grupos
     WHERE descripcion LIKE "%[texto]%"
     ORDER BY descripcion
   - Abre tabla con filtro
4. Grid se actualiza mostrando solo coincidencias
5. Búsqueda instantánea sin presionar botón
```

## Notas Importantes

### Consideraciones Especiales

**1. Solo Catálogo**
- Este módulo SOLO maneja el catálogo (nombres de grupos)
- NO asigna licencias a grupos
- La asignación se realiza en:
  - Módulo ConsultaTramite (botón "Agregar a detalle grupo")
  - Al aplicar bajas masivas en LicenciasVigentes
  - Programas masivos específicos

**2. Grupos como Filtro Potente**
- Los grupos se usan en módulos de:
  - LicenciasVigentes: Para filtrar reportes de licencias específicas
  - ReporteAnunExcel: Para filtrar conjunto de licencias
  - Bajas masivas: Para afectar solo grupos específicos
  - Consultas: Para análisis segmentados
- Permite operaciones masivas controladas

**3. No Hay Baja de Grupos**
- No existe función para eliminar grupos
- Si un grupo ya no se usa, simplemente no se selecciona
- Mantiene histórico completo
- Útil para auditorías y referencias históricas

**4. Búsqueda Interactiva**
- OnChange del Edit1 dispara búsqueda automática
- No requiere presionar Enter o botón
- Lista se filtra en tiempo real
- Muy útil con muchos grupos

**5. Ordenamiento Alfabético**
- Los grupos siempre se muestran ordenados por descripción
- Facilita localización visual
- SQL siempre incluye "ORDER BY descripcion"

### Restricciones
- No se pueden eliminar grupos físicamente
- No se pueden asignar licencias desde este módulo
- Solo permite gestionar nombres de grupos
- Descripción es campo obligatorio

### Permisos Necesarios
- Usuario con permiso de modificar catálogos
- Acceso de escritura a tabla lic_grupos
- Generalmente permitido a supervisores y personal administrativo

### Uso Recomendado

**Ejemplos de Grupos Útiles:**
- "Regularización 2025"
- "Morosos más de 3 años"
- "Zona Centro Histórico"
- "Giros Clase D - Especiales"
- "Pendientes Renovación 2024"
- "Campaña Verificación Enero"
- "Licencias Temporal COVID"
- "Programa Descuento Anualidad"

**Buenas Prácticas:**
- Usar nombres descriptivos y claros
- Incluir año o periodo si es relevante
- Indicar propósito (regularización, campaña, etc.)
- Evitar abreviaturas confusas
- Mantener nomenclatura consistente
- Documentar externamente el criterio de cada grupo

**Coordinación:**
- Coordinar con áreas que usarán el grupo
- Definir claramente criterios de inclusión
- Documentar cómo se pobló el grupo
- Revisar periódicamente vigencia del grupo
