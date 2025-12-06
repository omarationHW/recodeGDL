# ANÁLISIS DE COMPONENTES PENDIENTES DE MIGRACIÓN

**Fecha:** 2025-12-03
**Módulo:** Mercados

---

## 📊 ESTADO ACTUAL DE MIGRACIÓN

### Componentes Migrados (con '---')
Total: **15 componentes completados**

#### Reportes (Rpt)
1. ✅ RptAdeEnergiaGrl - Reporte Adeudos Energía
2. ✅ RptAdeudosLocales - Reporte Adeudos Locales
3. ✅ RptAdeudosEnergia - Reporte Adeudos Energía Detalle
4. ✅ RptAdeudosAnteriores - Reporte Adeudos Anteriores
5. ✅ RptAdeudosAbastos1998 - Reporte Abastos 1998
6. ✅ RptEmisionLaser - Reporte Emisión Laser
7. ✅ RptEmisionEnergia - Reporte Recibos Energía
8. ✅ RptFacturaEmision - Reporte Factura Emisión
9. ✅ RptFacturaEnergia - Reporte Factura Energía
10. ✅ RptPadronEnergia - Reporte Padrón Energía
11. ✅ RptMovimientos - Reporte Movimientos
12. ✅ RptIngresoZonificado - Reporte Ingresos por Zona
13. ✅ RptCuentaPublica - Reporte Cuenta Pública

#### Mantenimiento
14. ✅ CuotasMdoMntto - Mantenimiento Cuotas Mercado

#### Módulos
15. ✅ RptPadronGlobal - Padrón Global de Locales

---

## ⏳ COMPONENTES PENDIENTES (con '*')

### Prioridad Alta - Módulos Principales
1. **PadronLocales** - Padrón de Locales
2. **LocalesMtto** - Mantenimiento de Locales
3. **AdeudosLocales** - Adeudos de Locales
4. **AltaPagos** - Alta de Pagos
5. **EmisionLocales** - Emisión de Recibos
6. **EstadPagosyAdeudos** - Estadística Pagos/Adeudos
7. **CargaPagLocales** - Carga de Pagos
8. **ListadosLocales** - Listados de Locales
9. **RptPagosLocales** - Reporte de Pagos de Locales

### Prioridad Media - Módulos de Energía
10. **PadronEnergia** - Padrón de Energía
11. **EnergiaMtto** - Alta de Energía Eléctrica
12. **AdeudosEnergia** - Adeudos de Energía Eléctrica
13. **AltaPagosEnergia** - Alta de Pagos de Energía

### Prioridad Media - Catálogos
14. **CatalogoMercados** - Catálogo de Mercados
15. **CuotasMdo** - Cuotas de Mercados
16. **Categoria** - Catálogo de Categorías
17. **RecaudadorasMercados** - Administración de Recaudadoras

### Prioridad Media - Consultas
18. **ConsultaDatosLocales** - Consulta de Datos de Locales
19. **ConsultaDatosEnergia** - Consulta de Datos de Energía
20. **ConsPagos** - Consulta de Pagos

---

## 🎯 RECOMENDACIÓN PARA SIGUIENTE BATCH

### Lote Propuesto: Módulos de LOCALES (Alta Prioridad)

Razón: Son los módulos más usados y tienen mayor impacto en usuarios

1. **PadronLocales** - Padrón de Locales
   - Componente central del sistema
   - Lista y gestiona todos los locales

2. **LocalesMtto** - Mantenimiento de Locales
   - CRUD completo de locales
   - Integración con PadronLocales

3. **AltaPagos** - Alta de Pagos
   - Registro de pagos de locales
   - Funcionalidad crítica del negocio

4. **EmisionLocales** - Emisión de Recibos
   - Genera recibos de pago
   - Impresión de documentos

5. **ListadosLocales** - Listados de Locales
   - Reportes varios de locales
   - Exportación de datos

6. **RptPagosLocales** - Reporte de Pagos de Locales
   - Análisis de pagos
   - Estadísticas

---

## 📋 PASOS PARA MIGRAR CADA COMPONENTE

1. **Análisis del componente actual**
   - Leer archivo Vue actual
   - Identificar dependencias
   - Listar SPs utilizados

2. **Migración a Vue 3 Composition API**
   - Convertir a `<script setup>`
   - Migrar data() a ref() / reactive()
   - Convertir methods a funciones
   - Actualizar lifecycle hooks
   - Implementar computed properties

3. **Actualizar API calls**
   - Cambiar a axios
   - Usar /api/generic con eRequest
   - Implementar error handling

4. **Validar SPs**
   - Verificar que existan en BD
   - Corregir schemas si es necesario
   - Desplegar correcciones

5. **Actualizar Router y Sidebar**
   - Agregar marcador '---'
   - Verificar ruta activa

6. **Testing**
   - Probar funcionalidad
   - Validar datos
   - Testing de UX

---

## 🔢 ESTADÍSTICAS

- **Total componentes en Mercados:** ~100+
- **Componentes migrados:** 15
- **Porcentaje completado:** ~15%
- **Componentes pendientes con '*':** ~20+
- **Componentes sin marcador:** ~65+

---

## 💡 ESTRATEGIA RECOMENDADA

### Fase 1 (ACTUAL): Módulos de Locales
- 6 componentes de alta prioridad
- Funcionalidad core del sistema
- Tiempo estimado: 1-2 sesiones

### Fase 2: Módulos de Energía
- 4 componentes relacionados
- Segunda funcionalidad más importante
- Tiempo estimado: 1 sesión

### Fase 3: Catálogos y Consultas
- 8-10 componentes
- Mantenimiento y consultas
- Tiempo estimado: 2 sesiones

### Fase 4: Reportes Restantes
- Componentes Rpt pendientes
- Menor prioridad
- Tiempo estimado: 1-2 sesiones

---

## ✅ CRITERIOS DE SELECCIÓN

Para el siguiente batch consideramos:

1. **Impacto en usuarios** - Módulos más utilizados
2. **Interdependencia** - Componentes relacionados
3. **Complejidad** - Balance entre simple y complejo
4. **Valor de negocio** - Funcionalidad crítica

---

**Última actualización:** 2025-12-03
**Preparado por:** Claude Code
**Estado:** Listo para iniciar Fase 1
