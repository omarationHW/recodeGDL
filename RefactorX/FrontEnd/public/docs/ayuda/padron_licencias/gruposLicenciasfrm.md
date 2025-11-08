# Grupos de Licencias

## Descripcion General

### Que hace este modulo
El modulo de Grupos de Licencias permite crear y administrar agrupaciones personalizadas de licencias. Un grupo es un conjunto de licencias que se relacionan por algun criterio definido por el usuario (zona geografica, tipo de giro, proyecto especial, campana de inspeccion, etc.). Facilita el manejo masivo de licencias y la generacion de reportes segmentados.

### Para que sirve en el proceso administrativo
Este modulo sirve para:
- Crear grupos tematicos de licencias para gestion especifica
- Agregar o quitar licencias de grupos existentes
- Generar listados de licencias agrupadas
- Exportar grupos a Excel o HTML para analisis externo
- Facilitar operaciones masivas sobre conjuntos de licencias
- Organizar licencias para campanas de inspeccion
- Segmentar licencias para reportes especializados
- Gestionar proyectos especiales que involucran multiples licencias

### Quienes lo utilizan
- Supervisores que organizan campanas de inspeccion
- Personal de planeacion que analiza zonas o sectores
- Jefes de departamento para seguimiento de casos especiales
- Personal de estadistica para analisis segmentados
- Auditores para revisiones focalizadas
- Personal de sistemas para extraccion de datos

## Proceso Administrativo

### Como funciona el proceso paso a paso

**Gestion de Grupos:**

1. **Visualizar Grupos Existentes:**
   - Al abrir el modulo se muestran todos los grupos creados
   - Usuario puede buscar grupo por descripcion (filtro dinamico)
   - Lista se actualiza conforme se escribe

2. **Crear o Modificar Grupos:**
   - Usuario presiona "Grupos"
   - Se abre ventana de ABC de grupos
   - Puede agregar nuevo grupo con nombre descriptivo
   - Puede editar descripcion de grupos existentes

3. **Trabajar con Licencias del Grupo:**

   Panel izquierdo (Licencias disponibles):
   - Muestra licencias NO incluidas en el grupo
   - Usuario puede filtrar por:
     - Descripcion de actividad (texto libre)
     - Propietario (nombre del contribuyente)
     - Giro especifico (selector)
   - Sistema muestra solo licencias vigentes
   - Permite seleccion multiple

   Panel derecho (Licencias en el grupo):
   - Muestra licencias YA incluidas en el grupo
   - Usuario puede filtrar por texto
   - Permite seleccion multiple para remover

**Agregar Licencias al Grupo:**

1. Usuario selecciona grupo en panel superior
2. En panel izquierdo, aplica filtros para encontrar licencias
3. Selecciona una o multiples licencias (Ctrl+Click o Shift+Click)
4. Presiona boton "Agregar" (flecha derecha)
5. Sistema inserta licencias en tabla lic_detgrupo
6. Licencias aparecen en panel derecho
7. Licencias desaparecen del panel izquierdo

**Quitar Licencias del Grupo:**

1. Usuario selecciona licencias en panel derecho (licencias en grupo)
2. Selecciona una o multiples licencias
3. Presiona boton "Quitar" (flecha izquierda)
4. Sistema elimina registros de lic_detgrupo
5. Licencias regresan a panel izquierdo
6. Panel derecho se actualiza

**Importacion Masiva desde Excel:**

1. Usuario prepara archivo Excel con columna "Licencia"
2. Copia numeros de licencia en Excel
3. En el modulo, pega datos en hoja de calculo integrada
4. Presiona "Filtrar"
5. Sistema procesa lista de numeros de licencia
6. Busca licencias que existan y no esten en el grupo
7. Muestra resultados en panel izquierdo
8. Usuario presiona "Agregar" para incluir todas

**Exportacion de Grupo:**

1. Usuario selecciona grupo
2. Presiona boton "Exportar"
3. Sistema abre dialogo de guardar archivo
4. Nombre sugerido: "Licencias_[NombreGrupo]"
5. Usuario elige ubicacion
6. Sistema exporta a HTML con formato tabular
7. Archivo puede abrirse en Excel o navegador

### Que informacion requiere el usuario

**Para Crear Grupo:**
- Descripcion del grupo (texto libre, descriptivo)

**Para Agregar Licencias:**
- Criterios de busqueda:
  - Texto de actividad o nombre de propietario (parcial)
  - Giro especifico (opcional)
- O lista de numeros de licencia (para importacion masiva)

**Para Exportar:**
- Ruta y nombre de archivo de destino

**Informacion que Maneja:**
- Numero de licencia
- Actividad comercial
- Propietario (nombre completo concatenado)
- Ubicacion (calle y numero)
- Colonia
- Estado de vigencia
- Estado de bloqueo
- Fecha de otorgamiento

### Que validaciones se realizan

1. **Grupos Unicos:**
   - Un grupo se identifica por su ID unico
   - La descripcion puede repetirse pero no es recomendable

2. **Licencias sin Duplicar:**
   - Una licencia no puede estar dos veces en el mismo grupo
   - Si se intenta agregar licencia ya existente, se ignora

3. **Solo Licencias Vigentes:**
   - Los filtros muestran solo licencias con vigente = "V"
   - No permite agregar licencias canceladas o suspendidas

4. **Exclusion Mutua:**
   - Si licencia esta en el grupo, no aparece en panel izquierdo
   - Si se quita del grupo, regresa a panel izquierdo
   - Evita confusion y duplicidad

5. **Validacion de Importacion:**
   - Al importar desde Excel, valida que las licencias existan
   - Excluye licencias ya en el grupo
   - Solo procesa licencias validas y disponibles

### Que documentos genera

1. **Exportacion HTML:**
   - Tabla con todas las licencias del grupo
   - Columnas:
     - Licencia
     - Actividad
     - Fecha otorgamiento
     - Propietario
     - Ubicacion
     - Numero exterior/interior
     - Colonia
     - Estado vigente
     - Estado bloqueo
   - Compatible con Excel
   - Conserva formato tabular

2. **Listados Visuales:**
   - No imprime reportes formales
   - Se apoya en exportacion para documentacion

## Tablas de Base de Datos

### Tabla Principal
- **lic_grupos:** Catalogo de grupos de licencias con ID y descripcion

### Tablas Relacionadas

**Tablas que Consulta:**
- **lic_grupos:** Listado de grupos existentes
- **licencias:** Datos completos de licencias (actividad, propietario, ubicacion, etc.)
- **lic_detgrupo:** Relacion muchos a muchos entre grupos y licencias
- **c_giros:** Catalogo de giros para filtro

**Tablas que Modifica:**
- **lic_grupos:**
  - INSERT al crear nuevo grupo
  - UPDATE al modificar descripcion
- **lic_detgrupo:**
  - INSERT al agregar licencias al grupo
  - DELETE al quitar licencias del grupo

## Stored Procedures
- **Ninguno:** Utiliza queries directos para todas las operaciones

## Impacto y Repercusiones

### Que registros afecta

**Al Crear Grupo:**
- Inserta nuevo registro en lic_grupos
- Genera ID unico automatico
- No afecta licencias hasta agregar miembros

**Al Agregar Licencias:**
- Inserta registros en lic_detgrupo
- Uno por cada licencia agregada
- Relaciona lic_grupos_id con licencia

**Al Quitar Licencias:**
- Elimina registros especificos de lic_detgrupo
- No afecta el grupo ni otras licencias
- No elimina la licencia del sistema

**Al Eliminar Grupo:**
- No disponible en este modulo
- Debe hacerse en modulo de ABC de grupos

### Que cambios de estado provoca
- **Ninguno en las licencias:** El grupo es solo organizacional
- Las licencias mantienen su estado original
- La agrupacion es logica, no afecta el estatus legal

### Que documentos/reportes genera
- Exportacion HTML/Excel de licencias agrupadas
- No genera reportes formales impresos
- El enfoque es analisis en herramientas externas

### Que validaciones de negocio aplica

1. **Integridad Referencial:**
   - Solo permite agregar licencias que existan
   - Valida que el grupo exista antes de agregar licencias

2. **Agrupacion Logica:**
   - Un grupo puede tener 0 a N licencias
   - Una licencia puede estar en 0 a N grupos
   - Relacion muchos a muchos flexible

3. **Filtros de Vigencia:**
   - Solo trabaja con licencias vigentes
   - Protege integridad de analisis

## Flujo de Trabajo

### Descripcion del flujo completo del proceso

**Caso de Uso: Campana de Inspeccion en Zona Centro**

```
1. PREPARACION:
   a. Supervisor abre modulo Grupos de Licencias
   b. Presiona "Grupos"
   c. Crea nuevo grupo: "Inspecciones Zona Centro 2024"
   d. Cierra ABC de grupos
   e. Selecciona el grupo recien creado

2. BUSQUEDA Y AGREGADO:
   f. En filtro de texto escribe "Zona Centro"
   g. Sistema muestra licencias con ubicacion en zona centro
   h. Selecciona todas con Ctrl+A
   i. Presiona "Agregar"
   j. Sistema mueve licencias a panel derecho

3. REFINAMIENTO:
   k. Aplica filtro por giro "Restaurantes"
   l. Sistema muestra solo restaurantes disponibles
   m. Selecciona y agrega al grupo

   n. Revisa panel derecho (licencias en grupo)
   o. Si identifica licencias no relevantes, las selecciona
   p. Presiona "Quitar" para removerlas

4. EXPORTACION:
   q. Presiona "Exportar"
   r. Guarda archivo "Licencias_InspeccionesZonaCentro2024.html"
   s. Abre archivo en Excel
   t. Genera listado de trabajo para inspectores

5. USO OPERATIVO:
   u. Inspectores reciben listado
   v. Realizan visitas a establecimientos
   w. Regresan resultados
   x. Supervisor puede regresar al modulo para consultas

6. MANTENIMIENTO:
   y. Si se otorgan nuevas licencias en la zona
   z. Supervisor puede agregarlas al grupo existente
```

**Caso de Uso: Importacion Masiva**

```
1. Preparacion externa:
   a. Usuario tiene lista de licencias en Excel
   b. Lista proviene de analisis externo o reporte

2. En el modulo:
   c. Selecciona grupo destino
   d. Copia columna de licencias desde Excel
   e. Pega en hoja de calculo del modulo (columna A)
   f. Presiona "Filtrar"

3. Procesamiento:
   g. Sistema lee numeros de licencia
   h. Valida que existan en BD
   i. Excluye las ya en el grupo
   j. Muestra licencias validas en panel izquierdo

4. Agregado masivo:
   k. Usuario revisa lista filtrada
   l. Presiona "Agregar"
   m. Sistema inserta todas en el grupo
   n. Panel derecho se actualiza con nuevas licencias
```

## Notas Importantes

### Consideraciones especiales

1. **Grupos Multifuncionales:**
   - No hay limite en numero de grupos
   - Un grupo puede tener cualquier proposito
   - La organizacion depende de necesidades operativas

2. **Licencias en Multiples Grupos:**
   - Una licencia puede estar en varios grupos simultaneamente
   - Util para diferentes perspectivas de analisis
   - Ejemplo: Misma licencia en "Zona Centro" y en "Restaurantes Verificados"

3. **Hoja de Calculo Integrada:**
   - Componente cxSpreadSheet permite pegar desde Excel
   - Solo usa columna "Licencia"
   - Facilita importaciones masivas

4. **Exportacion HTML:**
   - Formato HTML es compatible con Excel y navegadores
   - Mantiene estructura tabular
   - Permite manipulacion posterior

5. **Concatenacion de Nombres:**
   - Sistema construye nombre completo: apellidos + nombre
   - Maneja valores nulos con funcion nvl()
   - Formato consistente en todo el sistema

### Restricciones

1. **No Modificar desde Aqui:**
   - No permite editar datos de licencias
   - Solo agrupa, no modifica atributos

2. **Solo Licencias Vigentes:**
   - No puede agrupar licencias canceladas
   - Si licencia cambia a no vigente, permanece en grupo pero no afecta nuevos filtros

3. **Sin Control de Duplicados entre Grupos:**
   - Sistema no alerta si licencia ya esta en otro grupo
   - Es responsabilidad del usuario gestionar consistencia

### Permisos necesarios

- **Consultar Grupos:** Lectura en lic_grupos y lic_detgrupo
- **Crear/Modificar Grupos:** Escritura en lic_grupos
- **Agregar/Quitar Licencias:** Escritura en lic_detgrupo
- **Consultar Licencias:** Lectura en tabla licencias
- **Exportar:** Permisos de escritura en sistema de archivos

### Casos de Uso Comunes

1. **Campanas de Inspeccion:**
   - Agrupar licencias por zona geografica
   - Organizar calendario de visitas
   - Distribuir trabajo entre inspectores

2. **Proyectos Especiales:**
   - Programas de regularizacion
   - Campanas de descuentos o promociones
   - Estudios de impacto ambiental

3. **Analisis Estadistico:**
   - Segmentar por tipo de giro
   - Analizar comportamiento por zona
   - Comparar grupos de contribuyentes

4. **Control Administrativo:**
   - Seguimiento de tramites especiales
   - Licencias en proceso de renovacion
   - Establecimientos con adeudos

5. **Reportes Gerenciales:**
   - Extraccion de datos para presentaciones
   - Exportar a Excel para analisis avanzado
   - Compartir informacion con otras areas

### Ventajas del Sistema de Grupos

1. **Flexibilidad:** Grupos se adaptan a cualquier necesidad
2. **Reutilizacion:** Un grupo puede usarse multiples veces
3. **Dinamico:** Facil agregar o quitar licencias
4. **Exportable:** Datos disponibles para analisis externo
5. **Multiples Vistas:** Mismas licencias, diferentes agrupaciones
