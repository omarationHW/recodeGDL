# 📋 PLAN DE IMPLEMENTACIÓN - MÓDULO LICENCIAS

## 🎯 ORDEN DE IMPLEMENTACIÓN RECOMENDADO

### **FASE 1: COMPONENTES BÁSICOS (ALTA PRIORIDAD)**
*Componentes con SP directamente migrados y funcionalidad crítica*

| Orden | Componente Vue | SP Correspondiente | Prioridad | Funcionalidad |
|-------|----------------|-------------------|-----------|---------------|
| 1 | **constanciafrm.vue** | `04_SP_LICENCIAS_CONSTANCIAFRM_EXACTO` | 🔴 ALTA | Gestión de constancias |
| 2 | **consLic400frm.vue** | `03_SP_LICENCIAS_CONSLIC400FRM_EXACTO` | 🔴 ALTA | Consulta licencias 400 |
| 3 | **bajaAnunciofrm.vue** | `02_SP_LICENCIAS_BAJAANUNCIOFRM_EXACTO` | 🔴 ALTA | Baja de anuncios |
| 4 | **Agendavisitasfrm.vue** | `01_SP_LICENCIAS_AGENDAVISITASFRM_EXACTO` | 🔴 ALTA | Agenda de visitas |

### **FASE 2: COMPONENTES CON SP MIGRADOS DISPONIBLES (PRIORIDAD MEDIA)**
*Componentes con SP exactos ya migrados*

| Orden | Componente Vue | SP Migrado Exacto | Prioridad | Funcionalidad |
|-------|----------------|-------------------|-----------|---------------|
| 5 | **BloquearAnunciorm.vue** | `06_SP_LICENCIAS_BLOQUEARANUNCIORM_EXACTO` | 🟡 MEDIA | Bloquear anuncios |
| 6 | **BloquearLicenciafrm.vue** | `07_SP_LICENCIAS_BLOQUEARLICENCIAFRM_EXACTO` | 🟡 MEDIA | Bloquear licencias |
| 7 | **BloquearTramitefrm.vue** | `08_SP_LICENCIAS_BLOQUEARTRAMITEFRM_EXACTO` | 🟡 MEDIA | Bloquear trámites |
| 8 | **BusquedaActividadFrm.vue** | `09_SP_LICENCIAS_BUSQUEDAACTIVIDADFRM_EXACTO` | 🟡 MEDIA | Búsqueda actividades |
| 9 | **BusquedaScianFrm.vue** | `10_SP_LICENCIAS_BUSQUEDASCIANFRM_EXACTO` | 🟡 MEDIA | Búsqueda SCIAN |
| 10 | **CatRequisitos.vue** | `11_SP_LICENCIAS_CATREQUISITOS_EXACTO` | 🟡 MEDIA | Catálogo requisitos |
| 11 | **CatalogoActividadesFrm.vue** | `12_SP_LICENCIAS_CATALOGOACTIVIDADESFRM_EXACTO` | 🟡 MEDIA | Catálogo actividades |
| 12 | **CatastroDM.vue** | `13_SP_LICENCIAS_CATASTRODM_EXACTO` | 🟡 MEDIA | Datos catastrales |

### **FASE 3: COMPONENTES ADICIONALES CON SP MIGRADOS (PRIORIDAD MEDIA)**
*Más componentes con SP exactos disponibles*

| Orden | Componente Vue | SP Migrado Exacto | Prioridad | Funcionalidad |
|-------|----------------|-------------------|-----------|---------------|
| 13 | **Cruces.vue** | `14_SP_LICENCIAS_CRUCES_EXACTO` | 🟡 MEDIA | Gestión cruces |
| 14 | **GirosDconAdeudofrm.vue** | `15_SP_LICENCIAS_GIROSDCONADEUDOFRM_EXACTO` | 🟡 MEDIA | Giros con adeudo |
| 15 | **GruposAnunciosAbcfrm.vue** | `16_SP_LICENCIAS_GRUPOSANUNCIOSABCFRM_EXACTO` | 🟡 MEDIA | Grupos anuncios |
| 16 | **GruposLicenciasAbcfrm.vue** | `17_SP_LICENCIAS_GRUPOSLICENCIASABCFRM_EXACTO` | 🟡 MEDIA | Grupos licencias |
| 17 | **Hastafrm.vue** | `18_SP_LICENCIAS_HASTAFRM_EXACTO` | 🟡 MEDIA | Formulario hasta |
| 18 | **ImpLicenciaReglamentadaFrm.vue** | `19_SP_LICENCIAS_IMPLICENCIAREGLAMENTADAFRM_EXACTO` | 🟡 MEDIA | Licencias reglamentadas |
| 19 | **ImpOficiofrm.vue** | `20_SP_LICENCIAS_IMPOFICIOFRM_EXACTO` | 🟡 MEDIA | Impresión oficios |

### **FASE 4: COMPONENTES RESTANTES (PRIORIDAD BAJA)**
*Componentes que requieren verificación de SP específicos*

| Orden | Componente Vue | Estado SP | Prioridad | Funcionalidad |
|-------|----------------|-----------|-----------|---------------|
| 20-97 | **Otros 77 componentes** | Por verificar en `/ok/` | 🟢 BAJA | Funcionalidades diversas |

### **COMPONENTES PRINCIPALES PENDIENTES:**
- consultaLicenciafrm.vue
- consultaAnunciofrm.vue  
- busque.vue
- modlicfrm.vue
- dictamenfrm.vue
- estatusfrm.vue
- empresasfrm.vue
- tipobloqueofrm.vue
- repestado.vue
- ReporteAnunExcelfrm.vue
- (Y 67+ componentes más)

## 🚀 **ESTRATEGIA DE IMPLEMENTACIÓN**

### **ENFOQUE RECOMENDADO:**
1. **Empezar con FASE 1** - Componentes con SP ya migrados
2. **Validar patrón** con `constanciafrm.vue` 
3. **Replicar patrón** en componentes restantes
4. **Implementar por fases** según prioridad

### **CRITERIOS DE PRIORIZACIÓN:**
- 🔴 **ALTA**: SP ya migrados y funcionalidad crítica
- 🟡 **MEDIA**: Funcionalidad importante, SP por confirmar
- 🟢 **BAJA**: Funcionalidad secundaria o catálogos

### **NOTA IMPORTANTE:**
Los componentes marcados como "SP Estimado" o "SP Requerido" necesitan verificación de los SP migrados específicos en la carpeta `/ok/` del módulo licencias.

---
*Generado: 2025-09-10*
*Total componentes identificados: 97*
*SP migrados confirmados: 90*