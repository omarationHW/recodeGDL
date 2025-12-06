# ANÁLISIS: AppSidebar.vue - Marcadores en Labels

## RESUMEN GENERAL

Total de items en el sidebar: **550**

### Distribución de Marcadores

| Tipo de Marcador | Cantidad | Porcentaje |
|-----------------|----------|------------|
| `*` (Asterisco simple) | **77** | 14.0% |
| `***` (Tres asteriscos) | **5** | 0.9% |
| `-` (Guión simple) | **9** | 1.6% |
| `--` (Dos guiones) | **4** | 0.7% |
| Sin marcador | **455** | 82.7% |
| **TOTAL CON MARCADOR** | **95** | **17.3%** |
| **TOTAL SIN MARCADOR** | **455** | **82.7%** |

## BÚSQUEDA ESPECÍFICA: Patrón `*/-`

❌ **NO se encontraron labels con el patrón `*/-`**

El usuario preguntó específicamente por labels con `*/-`, pero este patrón no existe en el archivo.

## DETALLES POR TIPO DE MARCADOR

### 1. Con ASTERISCO SIMPLE `*` (77 items)

Ejemplos del módulo Mercados:
- `* Padrón de Locales`
- `* Mantenimiento de Locales`
- `* Adeudos de Locales`
- `* Alta de Pagos`
- `* Emisión de Recibos`
- `* Estadística Pagos/Adeudos`
- `* Carga de Pagos`
- `* Listados de Locales`
- `* Reporte de Pagos de Locales`
- `* Alta de Energía Eléctrica`
- `* Adeudos de Energía Eléctrica`
- `* Catálogo de Mercados`
- `* Consulta de Datos de Locales`
- `* Consulta de Datos de Energía`
- `* Cuotas de Mercados`
- `* Catálogo de Categorías`
- `* Administración de Recaudadoras`
- `* Padrón Global de Locales`
- `* Alta de Pagos de Energía`
- `* Consulta de Pagos`
- `* Consulta Individual de Pagos`
- `* Cuotas de Energía`
- `* Datos de Convenio`
- `* Catálogo de Mercados (Mntto)`
- `* Consulta de Requerimientos`
- `* Condonación de Adeudos`
- `* Adeudo Global de Locales`
- `* Adeudos Generales de Energía`
- `* Adeudos Generales del Mercado`

Y otros 48 más en diferentes módulos...

**Interpretación**: El asterisco simple `*` parece indicar **funcionalidades principales o completadas**.

---

### 2. Con TRES ASTERISCOS `***` (5 items)

Todos los 5 items están en el módulo Mercados:

1. `*** Mantenimiento de Cuotas de Energía`
2. `*** Mantenimiento Cuotas Mercado`
3. `*** Claves de Cuota`
4. `*** Claves de Diferencias`
5. `*** Mantenimiento Fechas Descuento`

**Interpretación**: Los tres asteriscos `***` parecen indicar **módulos de mantenimiento o configuración avanzada**.

---

### 3. Con GUIÓN SIMPLE `-` (9 items)

Items en Mercados:
1. `-  Emisión de Recibos de Energía`
2. `-  Datos Individuales del Local`
3. `-  Fechas de Descuento`
4. `-  Datos de Requerimientos`
5. `-  Emisión Libertad` ⚠️ **(Este es el que reportó error)**
6. `-  Desglose Adeudos por Año`
7. `-  Ingreso Captura`
8. `-  Diferencias en Ingresos`
9. `-  Importar Energía`

**Interpretación**: El guión simple `-` parece indicar **funcionalidades en desarrollo o pendientes**.

---

### 4. Con DOS GUIONES `--` (4 items)

Items en Mercados:
1. `--  Giros Comerciales`
2. `--  Consulta General`
3. `--  Consulta Pagos Energía`
4. `--  Fechas de Vencimiento`

**Interpretación**: Los dos guiones `--` parecen indicar **funcionalidades con problemas o deprecadas**.

---

### 5. Sin Marcador (455 items)

La mayoría de los items no tienen marcador. Ejemplos:
- `Dashboard`
- `Módulos Administrativos`
- `Estacionamientos`
- `Padrón de Energía Eléctrica` (Mercados)
- `Secciones de Mercados` (Mercados)
- `Zonas Geográficas` (Mercados)
- `Estadísticas de Adeudos` (Mercados)
- `Acceso al Sistema` (Mercados)

**Interpretación**: Sin marcador indica **funcionalidades estándar y estables**.

---

## ANÁLISIS ESPECÍFICO: Módulo MERCADOS

En el módulo Mercados encontramos:

### Funcionalidades principales (con `*`):
- 29 items con asterisco simple
- Incluyen operaciones CRUD principales, consultas, pagos, adeudos

### Mantenimiento avanzado (con `***`):
- 5 items con tres asteriscos
- Todos son módulos de mantenimiento de cuotas y configuraciones

### En desarrollo/pendientes (con `-`):
- 9 items con guión simple
- **Incluye "Emisión Libertad"** que es el que reportó error
- Sugiere que estos módulos están incompletos

### Con problemas (con `--`):
- 4 items con dos guiones
- Giros Comerciales y consultas relacionadas

### Estándar (sin marcador):
- Varios items como Padrón de Energía, Secciones, Zonas, Estadísticas

---

## INTERPRETACIÓN DE LOS MARCADORES

Basado en el análisis, parece que los marcadores tienen este significado:

| Marcador | Significado Probable | Estado |
|----------|---------------------|--------|
| `*` | Funcionalidad principal/completada | ✅ Funcional |
| `***` | Mantenimiento/Configuración avanzada | ⚙️ Especial |
| `-` | En desarrollo/pendiente/incompleto | ⚠️ En progreso |
| `--` | Con problemas/deprecado | ❌ Problemas |
| Sin marca | Funcionalidad estándar | ✅ Estable |

---

## CONCLUSIÓN

1. **NO existe el patrón `*/-`** en el AppSidebar
2. El módulo **"Emisión Libertad"** tiene marcador `-` (guión simple)
3. Este marcador sugiere que está **en desarrollo o incompleto**
4. Esto coincide con el error reportado: **SPs no desplegados**
5. Hay **9 módulos con guión simple** que podrían tener problemas similares
6. Hay **4 módulos con dos guiones** que probablemente tienen problemas conocidos

---

## RECOMENDACIÓN

Revisar los **9 módulos con guión simple** y los **4 con dos guiones** para verificar si tienen SPs faltantes o problemas similares a Emisión Libertad.

### Módulos a revisar (con `-`):
1. ✅ Emisión Libertad - **YA CORREGIDO**
2. Emisión de Recibos de Energía
3. Datos Individuales del Local
4. Fechas de Descuento
5. Datos de Requerimientos
6. Desglose Adeudos por Año
7. Ingreso Captura
8. Diferencias en Ingresos
9. Importar Energía

### Módulos a revisar (con `--`):
1. Giros Comerciales
2. Consulta General
3. Consulta Pagos Energía
4. Fechas de Vencimiento
