# Documentación Administrativa - RptPadronLocales.pas

## Información General
**Archivo**: RptPadronLocales.pas
**Sistema**: Mercados de Guadalajara
**Módulo**: Reportes
**Tipo**: Formulario de Reporte (QuickReport)
**Fecha de Documentación**: 2025-11-04

---

## Descripción General
Módulo generador de reportes del padrón de locales de mercados. Genera un reporte detallado que incluye información completa de cada local (propietario, arrendatario, superficie, giro, renta mensual) filtrado por recaudadora y mercado. Incluye cálculos de renta según tipo de local y visualización de totales acumulados.

---

## Propósito Administrativo
Proporcionar reportes impresos del padrón completo de locales para consulta administrativa, auditoría, control de rentas y verificación de información de arrendatarios y propietarios.

---

## Estructura del Formulario

### Componentes Principales
| Componente | Tipo | Propósito |
|-----------|------|-----------|
| QRptPadronLocales | TQuickRep | Contenedor principal del reporte |
| QRbTitulos | TQRBand | Banda de títulos y encabezados |
| QRbDetalle | TQRBand | Banda de detalle de locales |
| QRBdTotal | TQRBand | Banda de totales |
| PageFooterBand1 | TQRBand | Pie de página con numeración |
| QRImage1 | TQRImage | Logotipo del ayuntamiento |

### Queries (Consultas)
| Query | Tabla | Propósito |
|-------|-------|-----------|
| QryLocales | ta_11_locales | Información de locales |
| QryRenta | ta_11_cuotas_mercados | Cuotas de renta por categoría |
| QryMercado | ta_11_mercados | Datos del mercado |
| Qryrecaudadora | ta_recaudadoras | Datos de la recaudadora |
| QryVencimientoRec | ta_11_vencimientos_rec | Fechas de vencimiento y sábados acumulados |

---

## Funcionalidad Principal

### Procedimiento: Inicio
**Descripción**: Inicializa el reporte con filtros específicos
**Parámetros**:
- `oficina` (integer): ID de la recaudadora
- `mercado` (integer): Número del mercado

**Proceso**:
1. Inicializa total de renta en 0
2. Obtiene el mes actual del sistema
3. Abre query de vencimientos para el mes actual
4. Abre query de locales filtrado por recaudadora y mercado
5. Abre query de recaudadora
6. Abre query de datos del mercado
7. Configura impresora y muestra vista previa

**Uso Administrativo**: Genera el reporte cuando el usuario selecciona una recaudadora y mercado específicos desde el menú de consultas.

---

## Cálculos y Campos Calculados

### QryLocalesCalcFields
**Campos Calculados**:
- `VigDescripcion`: Descripción textual del estado de vigencia
  - 'B' → 'BAJA'
  - 'C' → 'BAJA POR ACUERDO'
  - 'D' → 'BAJA ADMINISTRATIVA'
  - Otro → 'VIGENTE'
- `datosmercado`: Concatenación de sección + local + letra + bloque

### QryRentaCalcFields
**Cálculo de Renta Mensual**:

1. **Locales Tipo PS (Piso Secado)**:
   - Si clave_cuota = 4: `Renta = superficie × importe_cuota`
   - Otro: `Renta = (importe_cuota × superficie) × 30`

2. **Mercado 214 (Especial)**:
   - `Renta = superficie × importe_cuota × sábados_acumulados`

3. **Otros Locales**:
   - `Renta = superficie × importe_cuota`

---

## Eventos y Comportamiento

### QryLocalesAfterScroll
**Descripción**: Actualiza query de renta al cambiar de local
**Proceso**:
1. Cierra query de renta si está activa
2. Filtra renta por año actual, categoría, sección y clave de cuota del local
3. Abre query con la cuota correspondiente

### QRbDetalleBeforePrint
**Descripción**: Acumula el total de renta antes de imprimir cada línea
**Proceso**: Suma la renta del local actual al total general

### QRBdTotalBeforePrint
**Descripción**: Formatea y muestra el total de renta acumulado
**Proceso**: Convierte el total a formato moneda y lo asigna al label

### QuickRepBeforePrint
**Descripción**: Reinicia el total al inicio del reporte
**Proceso**: Resetea TotalRenta a 0

---

## Reglas de Negocio

### Tratamiento Especial de Locales
1. **Locales PS**: Tienen cálculo especial según clave de cuota
2. **Mercado 214**: Multiplica por sábados acumulados (mercado tipo tianguis)
3. **Estados de Vigencia**: Diferencia entre baja normal, por acuerdo o administrativa

### Filtros y Criterios
- Filtro obligatorio por recaudadora (oficina)
- Filtro obligatorio por mercado
- Usa año actual del sistema para consultar cuotas
- Usa mes actual para consultar vencimientos

---

## Campos del Reporte

### Información del Local
- Sección, Local, Letra, Bloque
- Categoría y descripción
- Propietario
- Arrendatario
- Superficie
- Giro
- Estado de vigencia

### Información Financiera
- Importe de cuota por m²
- Renta mensual calculada
- Total general de rentas

### Información Adicional
- Datos del mercado
- Recaudadora asignada
- Fecha del sistema
- Numeración de páginas

---

## Exportación y Salidas

### Formato de Salida
- Vista previa en pantalla
- Impresión directa
- Exportación a PDF (QRPDFFilter1)

---

## Variables Globales del Módulo
```pascal
var
  QRptPadronLocales: TQRptPadronLocales;
  Roficina, Rmercado: integer;      // Filtros del reporte
  TotalRenta: double;                // Acumulador de rentas
  alo, mes, dia: word;               // Componentes de fecha
```

---

## Dependencias del Sistema

### Módulos Requeridos
- ModuloBD: Acceso a base de datos y funciones generales
- Quickrpt: Componentes QuickReport
- QRExport: Exportación de reportes
- QRPDFFilt: Filtro para PDF

### Tablas Relacionadas
- ta_11_locales
- ta_11_cuotas_mercados
- ta_11_mercados
- ta_recaudadoras
- ta_11_vencimientos_rec

---

## Uso desde el Sistema

### Acceso
Desde el menú principal → Locales → Reportes → Padrón de Locales

### Flujo de Uso
1. Usuario selecciona recaudadora
2. Usuario selecciona mercado
3. Sistema genera reporte con todos los locales
4. Usuario visualiza en pantalla
5. Usuario puede imprimir o exportar a PDF

---

## Consideraciones Técnicas

### Rendimiento
- El reporte puede contener cientos de locales
- Realiza consulta adicional (QryRenta) por cada local
- Importante tener índices en las tablas por oficina y mercado

### Precisión de Cálculos
- Usa tipo Currency para importes monetarios
- Maneja diferentes fórmulas según tipo de local
- Acumula totales con tipo double

### Manejo de Fechas
- Obtiene fecha del servidor de base de datos
- Usa año actual para determinar cuotas vigentes
- Usa mes actual para vencimientos

---

## Observaciones Administrativas

### Casos Especiales
1. **Mercado 214**: Requiere cálculo especial con sábados acumulados (probablemente tianguis)
2. **Locales PS**: Tienen dos modalidades de cálculo según clave de cuota
3. **Bajas**: Diferencia entre tres tipos de baja

### Información para Auditoría
- Fecha de generación del reporte
- Identificación del mercado y recaudadora
- Total general de rentas esperadas
- Estado de vigencia de cada local
- Superficie y cálculo detallado de renta

---

## Mejoras Potenciales
1. Agregar filtro por estado de vigencia (solo activos, solo bajas, todos)
2. Permitir selección múltiple de mercados
3. Agregar subtotales por categoría o sección
4. Incluir estadísticas: promedio de renta, ocupación, etc.
5. Agregar gráficos de distribución
6. Opción de reporte resumido vs detallado

---

**Notas**: Este reporte es fundamental para el control administrativo del padrón de locales y la proyección de ingresos por renta de mercados.
