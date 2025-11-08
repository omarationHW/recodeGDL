# Grupos de Anuncios

## Descripcion General

### Que hace este modulo
El modulo de Grupos de Anuncios funciona de manera similar a Grupos de Licencias, pero enfocado en anuncios publicitarios. Permite crear y administrar agrupaciones personalizadas de anuncios (espectaculares, letreros, mantas, etc.) para facilitar su gestion masiva, inspeccion y generacion de reportes segmentados.

### Para que sirve en el proceso administrativo
Este modulo sirve para:
- Crear grupos tematicos de anuncios para gestion especifica
- Agregar o quitar anuncios de grupos existentes
- Generar listados de anuncios agrupados
- Exportar grupos a HTML para analisis externo
- Facilitar operaciones masivas sobre conjuntos de anuncios
- Organizar anuncios para campanas de regulacion
- Segmentar anuncios por zona, tipo o propietario
- Gestionar proyectos especiales de imagen urbana

### Quienes lo utilizan
- Personal de Imagen Urbana
- Supervisores de campanas de regulacion de anuncios
- Inspectores que verifican anuncios espectaculares
- Personal de planeacion urbana
- Jefes de reglamentos y normatividad
- Personal de estadistica para analisis sectoriales

## Proceso Administrativo

### Como funciona el proceso paso a paso

El funcionamiento es identico al modulo de Grupos de Licencias, pero aplicado a anuncios:

**Gestion de Grupos:**

1. **Visualizar Grupos Existentes:**
   - Al abrir se muestran todos los grupos de anuncios
   - Usuario puede buscar grupo por descripcion (filtro dinamico)
   - Lista se actualiza conforme se escribe

2. **Crear o Modificar Grupos:**
   - Usuario presiona "Grupos"
   - Se abre ventana de ABC de grupos de anuncios
   - Puede agregar nuevo grupo con nombre descriptivo
   - Puede editar descripcion de grupos existentes

3. **Trabajar con Anuncios del Grupo:**

   Panel izquierdo (Anuncios disponibles):
   - Muestra anuncios NO incluidos en el grupo
   - Usuario puede filtrar por:
     - Descripcion del giro del anuncio
     - Propietario de la licencia asociada
     - Giro especifico
   - Sistema muestra solo anuncios vigentes
   - Permite seleccion multiple

   Panel derecho (Anuncios en el grupo):
   - Muestra anuncios YA incluidos en el grupo
   - Usuario puede filtrar por texto
   - Permite seleccion multiple para remover

**Agregar Anuncios al Grupo:**

1. Usuario selecciona grupo en panel superior
2. En panel izquierdo, aplica filtros para encontrar anuncios
3. Selecciona uno o multiples anuncios (Ctrl+Click o Shift+Click)
4. Presiona boton "Agregar" (flecha derecha)
5. Sistema inserta anuncios en tabla anuncios_detgrupo
6. Anuncios aparecen en panel derecho
7. Anuncios desaparecen del panel izquierdo

**Quitar Anuncios del Grupo:**

1. Usuario selecciona anuncios en panel derecho
2. Selecciona uno o multiples anuncios
3. Presiona boton "Quitar" (flecha izquierda)
4. Sistema elimina registros de anuncios_detgrupo
5. Anuncios regresan a panel izquierdo
6. Panel derecho se actualiza

**Exportacion de Grupo:**

1. Usuario selecciona grupo
2. Presiona boton "Exportar"
3. Sistema abre dialogo de guardar archivo
4. Nombre sugerido: "Anuncios_[NombreGrupo]"
5. Usuario elige ubicacion
6. Sistema exporta a HTML con formato tabular
7. Archivo puede abrirse en Excel o navegador

### Que informacion requiere el usuario

**Para Crear Grupo:**
- Descripcion del grupo (texto libre, descriptivo)

**Para Agregar Anuncios:**
- Criterios de busqueda:
  - Giro del anuncio
  - Propietario de la licencia
  - Giro especifico (selector)

**Para Exportar:**
- Ruta y nombre de archivo destino

**Informacion que Maneja:**
- Numero de anuncio
- Descripcion/Giro del anuncio
- ID de giro
- Zona y subzona
- Fecha de otorgamiento
- Medidas del anuncio (medidas1, medidas2)
- Area total del anuncio
- Numero de caras
- Ubicacion (calle y numero)
- Colonia
- Estado de vigencia
- Si es espacio publico
- Estado de bloqueo
- Licencia asociada
- Empresa asociada
- Propietario

### Que validaciones se realizan

1. **Grupos Unicos:**
   - Un grupo se identifica por su ID unico
   - La descripcion puede repetirse

2. **Anuncios sin Duplicar:**
   - Un anuncio no puede estar dos veces en el mismo grupo
   - Si se intenta agregar anuncio existente, se ignora

3. **Solo Anuncios Vigentes:**
   - Los filtros muestran solo anuncios con vigente = "V"
   - No permite agregar anuncios cancelados

4. **Exclusion Mutua:**
   - Si anuncio esta en grupo, no aparece en panel izquierdo
   - Si se quita del grupo, regresa a panel izquierdo

5. **Join con Licencias:**
   - Sistema relaciona anuncios con licencias para mostrar propietario
   - Cruza con giros para mostrar descripcion completa
   - Construccion de nombre completo del propietario

### Que documentos genera

**Exportacion HTML:**
- Tabla con todos los anuncios del grupo
- Columnas:
  - Numero de anuncio
  - Descripcion/Giro
  - Zona y subzona
  - Fecha otorgamiento
  - Medidas y area
  - Numero de caras
  - Ubicacion completa
  - Colonia
  - Estado vigente
  - Propietario
  - Licencia y empresa asociadas
- Compatible con Excel
- Formato tabular

## Tablas de Base de Datos

### Tabla Principal
- **anuncios_grupos:** Catalogo de grupos de anuncios con ID y descripcion

### Tablas Relacionadas

**Tablas que Consulta:**
- **anuncios_grupos:** Listado de grupos existentes
- **anuncios:** Datos completos de anuncios (ubicacion, medidas, tipo, etc.)
- **licencias:** Para obtener datos del propietario asociado
- **c_giros:** Descripcion del giro del anuncio
- **anuncios_detgrupo:** Relacion entre grupos y anuncios

**Tablas que Modifica:**
- **anuncios_grupos:**
  - INSERT al crear nuevo grupo
  - UPDATE al modificar descripcion
- **anuncios_detgrupo:**
  - INSERT al agregar anuncios al grupo
  - DELETE al quitar anuncios del grupo

## Stored Procedures
- **Ninguno:** Utiliza queries directos para todas las operaciones

## Impacto y Repercusiones

### Que registros afecta

**Al Crear Grupo:**
- Inserta nuevo registro en anuncios_grupos
- Genera ID unico automatico
- No afecta anuncios hasta agregar miembros

**Al Agregar Anuncios:**
- Inserta registros en anuncios_detgrupo
- Uno por cada anuncio agregado
- Relaciona anuncios_grupos_id con anuncio

**Al Quitar Anuncios:**
- Elimina registros especificos de anuncios_detgrupo
- No afecta el grupo ni otros anuncios
- No elimina el anuncio del sistema

### Que cambios de estado provoca
- **Ninguno en los anuncios:** El grupo es solo organizacional
- Los anuncios mantienen su estado original
- La agrupacion es logica, no afecta estatus legal

### Que documentos/reportes genera
- Exportacion HTML/Excel de anuncios agrupados
- No genera reportes formales impresos
- Enfoque en analisis en herramientas externas

### Que validaciones de negocio aplica

1. **Integridad Referencial:**
   - Solo permite agregar anuncios que existan
   - Valida que el grupo exista antes de agregar anuncios

2. **Agrupacion Logica:**
   - Un grupo puede tener 0 a N anuncios
   - Un anuncio puede estar en 0 a N grupos
   - Relacion muchos a muchos flexible

3. **Filtros de Vigencia:**
   - Solo trabaja con anuncios vigentes
   - Protege integridad de analisis

4. **Relacion con Licencias:**
   - Cada anuncio debe estar asociado a una licencia
   - Permite rastrear propietario responsable

## Flujo de Trabajo

### Descripcion del flujo completo del proceso

**Caso de Uso: Campana de Regulacion de Espectaculares**

```
1. PREPARACION:
   a. Inspector de Imagen Urbana abre modulo
   b. Presiona "Grupos"
   c. Crea nuevo grupo: "Espectaculares Via Rapida 2024"
   d. Cierra ABC de grupos
   e. Selecciona el grupo recien creado

2. BUSQUEDA Y AGREGADO:
   f. En filtro selecciona giro "Anuncio Espectacular"
   g. Sistema muestra todos los espectaculares disponibles
   h. Aplica filtro de texto con "Via Rapida"
   i. Sistema filtra por ubicacion
   j. Selecciona todos los anuncios mostrados
   k. Presiona "Agregar"
   l. Sistema mueve anuncios a panel derecho

3. REFINAMIENTO:
   m. Revisa panel derecho (anuncios en grupo)
   n. Identifica anuncios fuera del area de interes
   o. Selecciona y presiona "Quitar"
   p. Anuncios regresan a panel izquierdo

4. EXPORTACION Y USO:
   q. Presiona "Exportar"
   r. Guarda "Anuncios_EspectacularesViaRapida2024.html"
   s. Abre archivo en Excel
   t. Genera mapa de ubicaciones
   u. Programa ruta de inspeccion
   v. Distribuye trabajo a inspectores de campo

5. SEGUIMIENTO:
   w. Inspectores verifican cumplimiento normativo
   x. Reportan anuncios irregulares
   y. Supervisor puede consultar grupo para dar seguimiento
   z. Si se retiran anuncios, se pueden quitar del grupo
```

## Notas Importantes

### Consideraciones especiales

1. **Diferencia con Licencias:**
   - Los anuncios son elementos separados de las licencias
   - Pero cada anuncio debe estar ligado a una licencia
   - Un establecimiento puede tener multiples anuncios

2. **Medidas y Areas:**
   - Sistema registra dimensiones del anuncio
   - Calcula area total
   - Importante para calculo de derechos

3. **Numero de Caras:**
   - Un espectacular puede tener multiples caras
   - Cada cara puede requerir pago separado
   - Relevante para regulacion y cobro

4. **Ubicacion Especifica:**
   - Anuncios tienen ubicacion independiente de la licencia
   - Pueden estar en diferente lugar que el establecimiento
   - Importante para verificacion en campo

5. **Join Complejo:**
   - Consultas relacionan anuncios, licencias y giros
   - Construccion dinamica de nombre de propietario
   - Optimizado para carga rapida

### Restricciones

1. **Solo Vigentes:**
   - No puede agrupar anuncios cancelados o vencidos
   - Si anuncio cambia a no vigente, permanece en grupo

2. **No Edicion de Datos:**
   - No permite modificar datos del anuncio
   - Solo agrupa, no modifica atributos

3. **Dependencia de Licencia:**
   - Si licencia se cancela, puede afectar visualizacion
   - Sistema maneja con outer joins para evitar errores

### Permisos necesarios

- **Consultar Grupos:** Lectura en anuncios_grupos y anuncios_detgrupo
- **Crear/Modificar Grupos:** Escritura en anuncios_grupos
- **Agregar/Quitar Anuncios:** Escritura en anuncios_detgrupo
- **Consultar Anuncios:** Lectura en tablas anuncios, licencias, c_giros
- **Exportar:** Permisos de escritura en sistema de archivos

### Casos de Uso Comunes

1. **Regulacion de Imagen Urbana:**
   - Agrupar anuncios por vialidad o avenida
   - Identificar anuncios irregulares
   - Planear retiros o regularizaciones

2. **Inspecciones Programadas:**
   - Organizar rutas de verificacion
   - Distribuir trabajo entre inspectores
   - Dar seguimiento a cumplimiento

3. **Analisis de Ingresos:**
   - Agrupar por tipo de anuncio
   - Calcular derechos por zona
   - Proyectar ingresos futuros

4. **Proyectos Especiales:**
   - Renovacion de imagen de avenidas principales
   - Programas de retiro de anuncios obsoletos
   - Campanas de regularizacion

5. **Reportes a Autoridades:**
   - Inventario de anuncios por zona
   - Estado de cumplimiento normativo
   - Estadisticas de ocupacion de espacios

### Importancia en Gestion Municipal

- Los anuncios son fuente importante de ingresos
- Su regulacion afecta imagen urbana
- Requieren inspeccion periodica en campo
- Deben cumplir reglamentos de construccion y ubicacion
- Su control impacta en ordenamiento territorial
