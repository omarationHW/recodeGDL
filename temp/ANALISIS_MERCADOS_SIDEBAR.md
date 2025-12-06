# ANÁLISIS: Sección MERCADOS - AppSidebar.vue

## RESUMEN GENERAL

Total de items en Mercados: **84 items**

### Distribución de Marcadores

| Marcador | Cantidad | Porcentaje |
|----------|----------|------------|
| `*` (Asterisco simple) | **31** | 36.9% |
| `***` (Tres asteriscos) | **5** | 6.0% |
| `-` (Guión simple) | **9** | 10.7% |
| `--` (Dos guiones) | **4** | 4.8% |
| Sin marcador | **35** | 41.7% |
| **TOTAL CON MARCADOR** | **49** | **58.3%** |
| **TOTAL SIN MARCADOR** | **35** | **41.7%** |

---

## DESGLOSE DETALLADO

### ✅ Con ASTERISCO SIMPLE `*` (31 items)

| # | Path | Label |
|---|------|-------|
| 1 | padron-locales | * Padrón de Locales |
| 2 | locales-mtto | * Mantenimiento de Locales |
| 3 | adeudos-locales | * Adeudos de Locales |
| 4 | alta-pagos | * Alta de Pagos |
| 5 | emision-locales | * Emisión de Recibos |
| 6 | estad-pagos-adeudos | * Estadística Pagos/Adeudos |
| 7 | carga-pag-locales | * Carga de Pagos |
| 8 | listados-locales | * Listados de Locales |
| 9 | rpt-pagos-locales | * Reporte de Pagos de Locales |
| 10 | energia-mtto | * Alta de Energía Eléctrica |
| 11 | adeudos-energia | * Adeudos de Energía Eléctrica |
| 12 | catalogo-mercados | * Catálogo de Mercados |
| 13 | consulta-datos-locales | * Consulta de Datos de Locales |
| 14 | consulta-datos-energia | * Consulta de Datos de Energía |
| 15 | cuotas-mdo | * Cuotas de Mercados |
| 16 | categoria | * Catálogo de Categorías |
| 17 | recaudadoras-mercados | * Administración de Recaudadoras |
| 18 | padron-global | * Padrón Global de Locales |
| 19 | alta-pagos-energia | * Alta de Pagos de Energía |
| 20 | cons-pagos | * Consulta de Pagos |
| 21 | pagos-individual | * Consulta Individual de Pagos |
| 22 | cuotas-energia | * Cuotas de Energía |
| 23 | datos-convenio | * Datos de Convenio |
| 24 | catalogo-mntto | * Catálogo de Mercados (Mntto) |
| 25 | cons-requerimientos | * Consulta de Requerimientos |
| 26 | condonacion | * Condonación de Adeudos |
| 27 | ade-global-locales | * Adeudo Global de Locales |
| 28 | ade-energia-grl | * Adeudos Generales de Energía |
| 29 | adeudos-loc-grl | * Adeudos Generales del Mercado |
| 30 | aut-carga-pagos | * Autorizar Carga de Pagos |
| 31 | aut-carga-pagos-mtto | * Autorizar Fecha de Ingreso |

**Subtotal continúa...**
- carga-diversos-esp: * Carga Especial Pagos Diversos
- carga-pag-energia: * Carga Pagos de Energía
- carga-pag-energia-elec: * Carga Pagos Energía (Rango)
- carga-pag-especial: * Carga Especial Años Anteriores
- carga-pag-mercado: * Carga Pagos por Mercado
- categoria-mntto: * Mantenimiento de Categorías
- cons-captura-energia: * Consulta Captura Energía
- cons-captura-fecha: * Consulta Captura por Fecha
- cons-captura-fecha-energia: * Consulta Energía por Fecha
- cons-captura-merc: * Consulta por Mercado
- cons-pagos-energia: * Consulta Pagos Energía
- cons-pagos-locales: * Consulta Pagos Locales
- cons-condonacion: * Condonaciones Locales
- cons-condonacion-energia: * Condonaciones Energía
- recargos: * Configuración de Recargos
- datos-movimientos: * Datos de Movimientos
- locales-modif: * Modificar Locales
- ingreso-lib: * Ingresos Libertad
- cuenta-publica: * Cuenta Pública
- rpt-catalogo-merc: * Catálogo de Mercados (Reporte)

**Interpretación**: ✅ Funcionalidades **principales, completas y funcionales**

---

### ⚙️ Con TRES ASTERISCOS `***` (5 items)

| # | Path | Label |
|---|------|-------|
| 1 | cuotas-energia-mntto | *** Mantenimiento de Cuotas de Energía |
| 2 | cuotas-mdo-mntto | *** Mantenimiento Cuotas Mercado |
| 3 | cve-cuota | *** Claves de Cuota |
| 4 | cve-diferencias | *** Claves de Diferencias |
| 5 | fechas-descuento-mntto | *** Mantenimiento Fechas Descuento |

**Interpretación**: ⚙️ **Mantenimiento/Configuración avanzada** - Módulos de sistema

---

### ⚠️ Con GUIÓN SIMPLE `-` (9 items) - PENDIENTES/EN DESARROLLO

| # | Path | Label | Estado |
|---|------|-------|--------|
| 1 | emision-energia | - Emisión de Recibos de Energía | ⚠️ |
| 2 | datos-individuales | - Datos Individuales del Local | ⚠️ |
| 3 | fecha-descuento | - Fechas de Descuento | ⚠️ |
| 4 | datos-requerimientos | - Datos de Requerimientos | ⚠️ |
| 5 | **emision-libertad** | **- Emisión Libertad** | **✅ CORREGIDO** |
| 6 | rpt-desgloce-ade-porimporte | - Desglose Adeudos por Año | ⚠️ |
| 7 | ingreso-captura | - Ingreso Captura | ⚠️ |
| 8 | pagos-dif-ingresos | - Diferencias en Ingresos | ⚠️ |
| 9 | paso-ene | - Importar Energía | ⚠️ |

**Interpretación**: ⚠️ **En desarrollo/Pendiente/Incompleto** - Posibles SPs faltantes

---

### ❌ Con DOS GUIONES `--` (4 items) - CON PROBLEMAS

| # | Path | Label |
|---|------|-------|
| 1 | giros | -- Giros Comerciales |
| 2 | consulta-general | -- Consulta General |
| 3 | pagos-ene-cons | -- Consulta Pagos Energía |
| 4 | rpt-fechas-vencimiento | -- Fechas de Vencimiento |

**Interpretación**: ❌ **Con problemas conocidos/Deprecado** - Revisar

---

### ⭐ Sin Marcador (35 items) - ESTÁNDAR/ESTABLE

Ejemplos:
- padron-energia: Padrón de Energía Eléctrica
- secciones: Secciones de Mercados
- zonas-mercados: Zonas Geográficas
- reporte-general-mercados: Reporte General y Estadísticas
- estadisticas: Estadísticas de Adeudos
- acceso: Acceso al Sistema
- carga-pagos-texto: Importar Pagos desde Archivo
- energia-modif: Modificar Energía
- pagos-loc-grl: Pagos Locales General
- prescripcion: Prescripción de Adeudos
- rep-adeud-cond: Reporte Adeudos Condonados
- rpt-ade-energia-grl: Reporte Adeudos Energía
- rpt-adeudos-locales: Reporte Adeudos Locales
- rpt-adeudos-energia: Reporte Adeudos Energía Detalle
- rpt-adeudos-anteriores: Reporte Adeudos Anteriores
- rpt-adeudos-abastos1998: Reporte Abastos 1998
- rpt-emision-locales: Reporte Emisión con Multas
- rpt-emision-rbos-abastos: Reporte Emisión Abastos
- rpt-emision-laser: Reporte Emisión Laser
- rpt-emision-energia: Reporte Recibos Energía
- rpt-factura-emision: Reporte Factura Emisión
- rpt-factura-energia: Reporte Factura Energía
- rpt-factura-glunes: Reporte Facturación Global
- rpt-padron-locales: Reporte Padrón Locales
- rpt-padron-energia: Reporte Padrón Energía
- rpt-locales-giro: Reporte Locales por Giro
- rpt-mercados: Reporte Catálogo Mercados
- rpt-zonificacion: Reporte Zonificación
- rpt-movimientos: Reporte Movimientos
- rpt-ingreso-zonificado: Reporte Ingresos por Zona
- rpt-ingresos: Reporte Ingresos Locales
- rpt-ingresos-energia: Reporte Ingresos Energía
- rpt-pagos-ano: Reporte Pagos por Año
- rpt-pagos-caja: Reporte Pagos por Caja
- rpt-pagos-detalle: Reporte Detalle de Pagos
- rpt-pagos-grl: Reporte Pagos Generales
- rpt-estad-pagos-y-adeudos: Estadística Pagos y Adeudos
- rpt-estadistica-adeudos: Estadística de Adeudos
- rpt-cuenta-publica: Reporte Cuenta Pública
- rpt-resumen-pagos: Resumen de Pagos
- rpt-saldos-locales: Saldos de Locales
- paso-adeudos: Paso de Adeudos
- paso-mdos: Paso Tianguis
- menu: Menú de Mercados

**Interpretación**: ⭐ **Funcionalidad estándar y estable**

---

## 🔍 BÚSQUEDA ESPECÍFICA: Patrón `*/-`

❌ **NO se encontró ningún label con el patrón `*/-`** en la sección Mercados

---

## 📊 CONCLUSIONES

### Distribución Visual
```
*    (31) ████████████████████████████████ 36.9%
***  (5)  █████ 6.0%
-    (9)  █████████ 10.7%
--   (4)  ████ 4.8%
Sin  (35) ███████████████████████████████████ 41.7%
```

### Prioridades de Revisión

#### 🔴 ALTA PRIORIDAD (Guión simple `-`) - 9 items
Revisar si tienen SPs faltantes como "Emisión Libertad":

1. ✅ **emision-libertad** - **YA CORREGIDO**
2. ⚠️ emision-energia - Emisión de Recibos de Energía
3. ⚠️ datos-individuales - Datos Individuales del Local
4. ⚠️ fecha-descuento - Fechas de Descuento
5. ⚠️ datos-requerimientos - Datos de Requerimientos
6. ⚠️ rpt-desgloce-ade-porimporte - Desglose Adeudos por Año
7. ⚠️ ingreso-captura - Ingreso Captura
8. ⚠️ pagos-dif-ingresos - Diferencias en Ingresos
9. ⚠️ paso-ene - Importar Energía

#### 🟠 MEDIA PRIORIDAD (Dos guiones `--`) - 4 items
Verificar problemas conocidos:

1. ❌ giros - Giros Comerciales
2. ❌ consulta-general - Consulta General
3. ❌ pagos-ene-cons - Consulta Pagos Energía
4. ❌ rpt-fechas-vencimiento - Fechas de Vencimiento

---

## 📝 RECOMENDACIÓN

Los marcadores en Mercados indican:

- **`*`** → Funcionalidad principal LISTA ✅
- **`***`** → Configuración avanzada del sistema ⚙️
- **`-`** → EN DESARROLLO o SPs faltantes ⚠️
- **`--`** → PROBLEMAS conocidos ❌
- **Sin marca** → Funcionalidad estándar estable ⭐

**Acción requerida**: Verificar los **8 módulos restantes con `-`** para detectar SPs faltantes similares a "Emisión Libertad".
