# 📋 PLAN PARA PRÓXIMOS 10 COMPONENTES
**Fecha:** 2025-11-20
**Estado actual:** 5/97 completados (5.2%)
**Meta:** 15/97 completados (15.5%)

---

## ✅ COMPONENTES YA COMPLETADOS (5)

1. ✅ Agendavisitasfrm.vue
2. ✅ BloquearAnunciorm.vue
3. ✅ BloquearLicenciafrm.vue
4. ✅ BloquearTramitefrm.vue
5. ✅ BusquedaActividadFrm.vue

**Deploy listo:** `DEPLOY_ALL_5_COMPONENTES.sql`

---

## 🎯 PRÓXIMOS 10 COMPONENTES A PROCESAR

### Componente 6: catalogogirosfrm.vue
**Función:** Catálogo ABC de giros comerciales
**SPs disponibles (6):**
- catalogogiros_list
- catalogogiros_get
- catalogogiros_create
- catalogogiros_update
- catalogogiros_cambiar_vigencia
- catalogogiros_estadisticas

**Tablas:** `comun.c_giros`
**Tipo:** CRUD completo + estadísticas

---

### Componente 7: empresasfrm.vue
**Función:** Catálogo ABC de empresas/contribuyentes
**SPs disponibles (6):**
- empresas_list
- empresas_create
- empresas_update
- empresas_delete
- empresas_estadisticas

**Tablas:** `comun.empresas`
**Tipo:** CRUD completo

---

### Componente 8: CatRequisitos.vue
**Función:** Catálogo de requisitos para trámites
**SPs disponibles (5):**
- catrequisitos_list
- catrequisitos_create
- catrequisitos_update
- catrequisitos_delete
- catrequisitos_search

**Tablas:** `public.cat_requisitos`
**Tipo:** CRUD completo + búsqueda

---

### Componente 9: LigaRequisitos.vue
**Función:** Asociar requisitos con giros
**SPs disponibles (5):**
- ligarequisitos_list
- ligarequisitos_add
- ligarequisitos_remove
- ligarequisitos_giros
- ligarequisitos_available

**Tablas:** `public.liga_requisitos`, `comun.c_giros`
**Tipo:** Relaciones many-to-many

---

### Componente 10: ZonaLicencia.vue
**Función:** Gestión de zonas para licencias
**SPs disponibles (5):**
- get_licencia
- get_zonas
- get_subzonas
- get_recaudadoras
- save_licencias_zona

**Tablas:** `public.zonas_licencias`
**Tipo:** Asignación de zonas

---

### Componente 11: ZonaAnuncio.vue
**Función:** Gestión de zonas para anuncios
**SPs disponibles (4):**
- zonaanuncio_list
- zonaanuncio_create
- zonaanuncio_update
- zonaanuncio_delete

**Tablas:** `public.zona_anuncio`
**Tipo:** CRUD zonas

---

### Componente 12: ligaAnunciofrm.vue
**Función:** Asociar anuncios con licencias
**SPs disponibles (4):**
- buscar_anuncio
- buscar_empresa
- buscar_licencia
- ligar_anuncio

**Tablas:** `comun.anuncios`, `comun.licencias`, `comun.empresas`
**Tipo:** Relación anuncio-licencia

---

### Componente 13: Cruces.vue
**Función:** Búsqueda de cruces de calles
**SPs disponibles (3):**
- cruces_search_calle1
- cruces_search_calle2
- cruces_localiza_calle

**Tablas:** `comun.cruces`, `comun.calles`
**Tipo:** Búsqueda especializada

---

### Componente 14: formabuscalle.vue
**Función:** Formulario de búsqueda de calles
**SPs disponibles (2):**
- buscar_calles
- listar_calles

**Tablas:** `comun.calles`
**Tipo:** Búsqueda y catálogo

---

### Componente 15: formabuscolonia.vue
**Función:** Formulario de búsqueda de colonias
**SPs disponibles (3):**
- buscar_colonias
- listar_colonias
- obtener_colonia_seleccionada

**Tablas:** `comun.colonias`
**Tipo:** Búsqueda y catálogo

---

## 📊 RESUMEN DE SPs

| Componente | SPs | Tipo | Complejidad |
|------------|-----|------|-------------|
| catalogogirosfrm | 6 | CRUD + Stats | Media |
| empresasfrm | 5 | CRUD | Media |
| CatRequisitos | 5 | CRUD + Search | Media |
| LigaRequisitos | 5 | Relaciones | Alta |
| ZonaLicencia | 5 | Asignación | Media |
| ZonaAnuncio | 4 | CRUD | Baja |
| ligaAnunciofrm | 4 | Relación | Media |
| Cruces | 3 | Búsqueda | Baja |
| formabuscalle | 2 | Búsqueda | Baja |
| formabuscolonia | 3 | Búsqueda | Baja |
| **TOTAL** | **42 SPs** | | |

---

## 🔧 PATRÓN DE IMPLEMENTACIÓN

Para cada componente seguir:

### 1. CREAR SQL DEPLOY
```sql
-- Verificar esquemas en postgreok.csv
-- Crear SPs con esquemas correctos (public/comun)
-- Incluir validaciones y mensajes
-- Agregar script de verificación
```

### 2. ACTUALIZAR VUE
```javascript
// Aplicar patrón establecido:
execute(
  'sp_nombre_minusculas',
  'padron_licencias',
  [...params],
  'guadalajara',
  null,
  'public' // o 'comun'
)
```

### 3. VERIFICAR ROUTER
- Todos los componentes YA ESTÁN registrados
- No requiere modificación

---

## ⏱️ ESTIMACIÓN DE TIEMPO

| Componente | Tiempo estimado |
|------------|----------------|
| Componentes 6-10 (CRUD complejos) | 20 min c/u = 100 min |
| Componentes 11-15 (más simples) | 12 min c/u = 60 min |
| **Total** | **160 minutos (~2.7 horas)** |

---

## 🎯 ESTRATEGIA RECOMENDADA

### Opción A: Por complejidad (RECOMENDADO)
1. Primero los simples (13-15): 36 min
2. Luego los medios (6-8, 11-12): 80 min
3. Finalmente los complejos (9-10): 40 min

### Opción B: Secuencial
Procesar en orden 6 → 15

### Opción C: Por funcionalidad
1. Catálogos (6-8): 60 min
2. Relaciones (9, 12): 40 min
3. Zonas (10-11): 32 min
4. Búsquedas (13-15): 28 min

---

## 📦 ENTREGABLES ESPERADOS

Al completar los 10 componentes:

- **10 archivos SQL** de deploy individuales
- **1 archivo SQL** consolidado (DEPLOY_BATCH_2.sql)
- **10 componentes Vue** actualizados
- **42 SPs** desplegados
- **1 documento** de registro de cambios
- **Progreso:** 15/97 (15.5%)

---

## 🚀 COMANDO DE INICIO

Para iniciar el procesamiento:

```bash
# Los archivos están disponibles en:
cd C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\Base\padron_licencias\database\database

# Componentes Vue en:
cd C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\FrontEnd\src\views\modules\padron_licencias
```

---

## ✅ CHECKLIST POR COMPONENTE

- [ ] Leer SPs originales
- [ ] Verificar esquemas en postgreok.csv
- [ ] Crear archivo SQL deploy con esquemas correctos
- [ ] Actualizar componente Vue con patrón establecido
- [ ] Verificar que esté en router
- [ ] Documentar cambios
- [ ] Marcar como completado

---

**Próxima acción:** Comenzar con el componente más simple (formabuscalle o formabuscolonia) para ganar velocidad, luego atacar los CRUD complejos.

**Estado:** ⏳ LISTO PARA INICIAR BATCH 2
